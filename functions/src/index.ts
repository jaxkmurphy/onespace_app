import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

const db = admin.firestore();

export const loginClassroomWithCode = onCall(async (request) => {
  const schoolCode = String(request.data.schoolCode || "").trim().toUpperCase();
  const classroomCode = String(request.data.classroomCode || "")
    .trim()
    .toUpperCase();
  const pin = String(request.data.pin || "").trim();

  logger.info("Classroom login attempt", {
    schoolCode,
    classroomCode,
    pinLength: pin.length,
  });

  if (!schoolCode || !classroomCode || !pin) {
    logger.warn("Missing classroom login fields");

    throw new HttpsError(
      "invalid-argument",
      "School code, classroom code and PIN are required."
    );
  }

  const schoolSnap = await db
    .collection("schools")
    .where("schoolCode", "==", schoolCode)
    .where("active", "==", true)
    .limit(1)
    .get();

  logger.info("School query result", {
    empty: schoolSnap.empty,
    count: schoolSnap.size,
  });

  if (schoolSnap.empty) {
    throw new HttpsError("permission-denied", "Invalid school code.");
  }

  const schoolDoc = schoolSnap.docs[0];

  const classroomSnap = await schoolDoc.ref
    .collection("classrooms")
    .where("classroomCode", "==", classroomCode)
    .where("active", "==", true)
    .limit(1)
    .get();

  logger.info("Classroom query result", {
    schoolId: schoolDoc.id,
    empty: classroomSnap.empty,
    count: classroomSnap.size,
  });

  if (classroomSnap.empty) {
    throw new HttpsError("permission-denied", "Invalid classroom code.");
  }

  const classroomDoc = classroomSnap.docs[0];
  const classroomData = classroomDoc.data();

  const storedPin = String(classroomData.pin || "").trim();

  logger.info("PIN check", {
    classroomId: classroomDoc.id,
    enteredPinLength: pin.length,
    storedPinLength: storedPin.length,
    pinMatches: storedPin === pin,
  });

  if (storedPin !== pin) {
    throw new HttpsError("permission-denied", "Invalid classroom PIN.");
  }

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
