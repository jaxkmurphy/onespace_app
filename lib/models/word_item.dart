class WordItem {
  final String id;
  final String text;
  final String imageType;
  final String imageValue;
  final String difficulty;

  WordItem({
    required this.id,
    required this.text,
    required this.imageType,
    required this.imageValue,
    this.difficulty = 'easy',
  });

  factory WordItem.fromMap(String id, Map<String, dynamic> data) {
    return WordItem(
      id: id,
      text: data['text'] ?? '',
      imageType: data['imageType'] ?? 'emoji',
      imageValue: data['imageValue'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageType': imageType,
      'imageValue': imageValue,
      'difficulty': difficulty,
    };
  }

  WordItem copyWith({
    String? id,
    String? text,
    String? imageType,
    String? imageValue,
    String? difficulty,
  }) {
    return WordItem(
      id: id ?? this.id,
      text: text ?? this.text,
      imageType: imageType ?? this.imageType,
      imageValue: imageValue ?? this.imageValue,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}