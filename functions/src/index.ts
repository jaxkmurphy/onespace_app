import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {createHash} from "crypto";

admin.initializeApp();

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

const maxFailedClassroomLoginAttempts = 5;
const classroomLoginWindowMinutes = 15;
const classroomLoginLockoutMinutes = 15;
const schoolSetupCodeSecret = defineSecret("SCHOOL_SETUP_CODE");

/**
 * Creates a timestamp a fixed number of minutes in the future.
 *
 * @param {number} minutes Number of minutes to add to the current time.
 * @return {admin.firestore.Timestamp} Future Firestore timestamp.
 */
function minutesFromNow(minutes: number): admin.firestore.Timestamp {
  return Timestamp.fromMillis(Date.now() + minutes * 60 * 1000);
}

/**
 * Builds a hashed Firestore reference for a classroom login attempt bucket.
 *
 * @param {string} schoolCode Normalized school code.
 * @param {string} classroomCode Normalized classroom code.
 * @param {string} ipAddress Caller IP address.
 * @return {admin.firestore.DocumentReference} Attempt tracking document.
 */
function classroomLoginAttemptRef(
  schoolCode: string,
  classroomCode: string,
  ipAddress: string
): admin.firestore.DocumentReference {
  const rawKey = [
    schoolCode || "missing-school",
    classroomCode || "missing-classroom",
    ipAddress || "unknown-ip",
  ].join("|");

  const hashedKey = createHash("sha256").update(rawKey).digest("hex");

  return db
    .collection("_security")
    .doc("classroomLogin")
    .collection("attempts")
    .doc(hashedKey);
}

/**
 * Extracts the caller IP address used to scope classroom login lockouts.
 *
 * @param {object} request Callable request wrapper.
 * @return {string} Best-effort caller IP address.
 */
function clientIpAddress(request: {
  rawRequest?: {
    ip?: string;
    headers?: {
      [key: string]: string | string[] | undefined;
    };
  };
}): string {
  const forwardedFor = request.rawRequest?.headers?.["x-forwarded-for"];

  if (Array.isArray(forwardedFor)) {
    return forwardedFor[0]?.split(",")[0]?.trim() || "unknown";
  }

  if (typeof forwardedFor == "string") {
    return forwardedFor.split(",")[0]?.trim() || "unknown";
  }

  return request.rawRequest?.ip || "unknown";
}

/**
 * Stops classroom login while the current attempt bucket is locked.
 *
 * @param {admin.firestore.DocumentReference} ref Attempt tracking document.
 */
async function assertClassroomLoginNotLocked(
  ref: admin.firestore.DocumentReference
): Promise<void> {
  const snapshot = await ref.get();
  const data = snapshot.data();
  const lockedUntil =
    data?.lockedUntil as admin.firestore.Timestamp | undefined;

  if (lockedUntil && lockedUntil.toMillis() > Date.now()) {
    logger.warn("Classroom login temporarily locked");

    throw new HttpsError(
      "resource-exhausted",
      "Too many attempts. Please wait and try again."
    );
  }
}

/**
 * Records a failed classroom login and starts a short lockout when needed.
 *
 * @param {admin.firestore.DocumentReference} ref Attempt tracking document.
 */
async function recordFailedClassroomLogin(
  ref: admin.firestore.DocumentReference
): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data();
    const windowStartedAt =
      data?.windowStartedAt as admin.firestore.Timestamp | undefined;

    const windowExpired =
      !windowStartedAt ||
      Date.now() - windowStartedAt.toMillis() >
        classroomLoginWindowMinutes * 60 * 1000;

    const currentFailedAttempts =
      windowExpired ? 0 : Number(data?.failedAttempts || 0);
    const failedAttempts = currentFailedAttempts + 1;
    const lockedUntil =
      failedAttempts >= maxFailedClassroomLoginAttempts ?
        minutesFromNow(classroomLoginLockoutMinutes) :
        FieldValue.delete();

    transaction.set(
      ref,
      {
        failedAttempts,
        windowStartedAt: windowExpired ? Timestamp.now() : windowStartedAt,
        lockedUntil,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  });
}

/**
 * Clears failed classroom login state after a successful login.
 *
 * @param {admin.firestore.DocumentReference} ref Attempt tracking document.
 */
async function clearFailedClassroomLogins(
  ref: admin.firestore.DocumentReference
): Promise<void> {
  await ref.delete().catch(() => {
    logger.warn("Could not clear classroom login attempt record");
  });
}

/**
 * Records a failed classroom login and throws the safest client-facing error.
 *
 * @param {admin.firestore.DocumentReference} ref Attempt tracking document.
 * @param {string} logMessage Safe server-side message.
 * @param {Record<string, string>} logData Optional safe server-side metadata.
 */
async function rejectClassroomLogin(
  ref: admin.firestore.DocumentReference,
  logMessage: string,
  logData?: Record<string, string>
): Promise<never> {
  await recordFailedClassroomLogin(ref);

  logger.warn(logMessage, logData);

  const snapshot = await ref.get();
  const lockedUntil =
    snapshot.data()?.lockedUntil as admin.firestore.Timestamp | undefined;

  if (lockedUntil && lockedUntil.toMillis() > Date.now()) {
    throw new HttpsError(
      "resource-exhausted",
      "Too many attempts. Please wait and try again."
    );
  }

  throw new HttpsError(
    "permission-denied",
    "Classroom login details are incorrect."
  );
}

export const loginClassroomWithCode = onCall(async (request) => {
  const schoolCode = String(request.data.schoolCode || "").trim().toUpperCase();
  const classroomCode = String(request.data.classroomCode || "")
    .trim()
    .toUpperCase();
  const pin = String(request.data.pin || "").trim();
  const attemptRef = classroomLoginAttemptRef(
    schoolCode,
    classroomCode,
    clientIpAddress(request)
  );

  logger.info("Classroom login attempt received", {
    hasSchoolCode: schoolCode.length > 0,
    hasClassroomCode: classroomCode.length > 0,
    hasPin: pin.length > 0,
  });

  if (!schoolCode || !classroomCode || !pin) {
    logger.warn("Missing classroom login fields");

    throw new HttpsError(
      "invalid-argument",
      "School code, classroom code and PIN are required."
    );
  }

  await assertClassroomLoginNotLocked(attemptRef);

  const schoolSnap = await db
    .collection("schools")
    .where("schoolCode", "==", schoolCode)
    .where("active", "==", true)
    .limit(1)
    .get();

  if (schoolSnap.empty) {
    return rejectClassroomLogin(
      attemptRef,
      "Classroom login failed: school not found or inactive"
    );
  }

  const schoolDoc = schoolSnap.docs[0];

  const classroomSnap = await schoolDoc.ref
    .collection("classrooms")
    .where("classroomCode", "==", classroomCode)
    .where("active", "==", true)
    .limit(1)
    .get();

  if (classroomSnap.empty) {
    return rejectClassroomLogin(
      attemptRef,
      "Classroom login failed: classroom not found or inactive"
    );
  }

  const classroomDoc = classroomSnap.docs[0];
  const classroomData = classroomDoc.data();

  const storedPin = String(classroomData.pin || "").trim();

  if (storedPin !== pin) {
    return rejectClassroomLogin(
      attemptRef,
      "Classroom login failed: invalid PIN",
      {
        schoolId: schoolDoc.id,
        classroomId: classroomDoc.id,
      }
    );
  }

  await clearFailedClassroomLogins(attemptRef);

  const uid = `classroom_${schoolDoc.id}_${classroomDoc.id}`;

  const customToken = await admin.auth().createCustomToken(uid, {
    role: "classroom",
    schoolId: schoolDoc.id,
    classroomId: classroomDoc.id,
  });

  logger.info("Classroom login successful", {
    schoolId: schoolDoc.id,
    classroomId: classroomDoc.id,
  });

  return {
    token: customToken,
    schoolId: schoolDoc.id,
    classroomId: classroomDoc.id,
    classroomName: classroomData.name || "Classroom",
  };
});

export const registerSchoolAdminWithSetupCode = onCall(
  {secrets: [schoolSetupCodeSecret]},
  async (request) => {
    const expectedSetupCode = schoolSetupCodeSecret.value().trim();
    const setupCode = String(request.data.setupCode || "").trim();
    const email = String(request.data.email || "").trim().toLowerCase();
    const password = String(request.data.password || "");
    const schoolName = String(request.data.schoolName || "").trim();
    const schoolCode = String(request.data.schoolCode || "").trim()
      .toUpperCase();

    logger.info("School admin registration attempt received", {
      hasSetupCode: setupCode.length > 0,
      hasEmail: email.length > 0,
      hasPassword: password.length > 0,
      hasSchoolName: schoolName.length > 0,
      hasSchoolCode: schoolCode.length > 0,
    });

    if (!expectedSetupCode) {
      logger.error("School setup code secret is not configured");
      throw new HttpsError(
        "failed-precondition",
        "School registration is not configured."
      );
    }

    if (
      !setupCode ||
      !email ||
      !password ||
      !schoolName ||
      !schoolCode
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Setup code, email, password, school name and school code are required."
      );
    }

    if (setupCode !== expectedSetupCode) {
      logger.warn("School admin registration failed: invalid setup code");
      throw new HttpsError(
        "permission-denied",
        "School registration details are incorrect."
      );
    }

    const existingSchool = await db
      .collection("schools")
      .where("schoolCode", "==", schoolCode)
      .limit(1)
      .get();

    if (!existingSchool.empty) {
      throw new HttpsError(
        "already-exists",
        "That school code is already in use."
      );
    }

    let userRecord: admin.auth.UserRecord;

    try {
      userRecord = await admin.auth().createUser({
        email,
        password,
      });
    } catch (error) {
      logger.warn("School admin auth user creation failed");
      throw new HttpsError(
        "already-exists",
        "Could not create admin account."
      );
    }

    const schoolRef = db.collection("schools").doc();
    const now = FieldValue.serverTimestamp();

    try {
      const batch = db.batch();

      batch.set(schoolRef, {
        name: schoolName,
        schoolCode,
        classroomLimit: 3,
        active: true,
        createdAt: now,
      });

      batch.set(schoolRef.collection("members").doc(userRecord.uid), {
        uid: userRecord.uid,
        schoolId: schoolRef.id,
        email,
        role: "schoolAdmin",
        active: true,
        createdAt: now,
      });

      batch.set(db.collection("account_lookup").doc(userRecord.uid), {
        schoolId: schoolRef.id,
        role: "schoolAdmin",
        email,
        active: true,
        createdAt: now,
      });

      await batch.commit();
    } catch (error) {
      await admin.auth().deleteUser(userRecord.uid).catch(() => {
        logger.warn("Could not clean up auth user after school create failure");
      });

      logger.error("School admin registration Firestore write failed");
      throw new HttpsError(
        "internal",
        "Could not create school admin account."
      );
    }

    const token = await admin.auth().createCustomToken(userRecord.uid);

    logger.info("School admin registration successful", {
      schoolId: schoolRef.id,
      uid: userRecord.uid,
    });

    return {
      token,
      schoolId: schoolRef.id,
      schoolName,
    };
  }
);
