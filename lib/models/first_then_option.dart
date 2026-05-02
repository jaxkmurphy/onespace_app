class FirstThenOption {
  final String id;
  final String label;
  final String iconName;

  FirstThenOption({
    required this.id,
    required this.label,
    required this.iconName,
  });

  factory FirstThenOption.fromMap(String id, Map<String, dynamic> data) {
    return FirstThenOption(
      id: id,
      label: data['label'] ?? '',
      iconName: data['iconName'] ?? 'task',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'iconName': iconName,
    };
  }

  Map<String, dynamic> toFirstThenMap() {
    return {
      'id': id,
      'label': label,
      'iconName': iconName,
    };
  }
}