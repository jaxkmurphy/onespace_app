class WordItem {
  final String id;
  final String text;
  final String imageType;
  final String imageValue;
  final String difficulty;
  final String hint;

  WordItem({
    required this.id,
    required this.text,
    required this.imageType,
    required this.imageValue,
    this.difficulty = 'easy',
    this.hint = '',
  });

  factory WordItem.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return WordItem(
      id: id,
      text: data['text'] as String? ?? '',
      imageType: data['imageType'] as String? ?? 'emoji',
      imageValue: data['imageValue'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'easy',
      hint: data['hint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageType': imageType,
      'imageValue': imageValue,
      'difficulty': difficulty,
      'hint': hint,
    };
  }

  WordItem copyWith({
    String? id,
    String? text,
    String? imageType,
    String? imageValue,
    String? difficulty,
    String? hint,
  }) {
    return WordItem(
      id: id ?? this.id,
      text: text ?? this.text,
      imageType: imageType ?? this.imageType,
      imageValue: imageValue ?? this.imageValue,
      difficulty: difficulty ?? this.difficulty,
      hint: hint ?? this.hint,
    );
  }
}