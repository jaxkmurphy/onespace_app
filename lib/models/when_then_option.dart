class WhenThenOption {
  final String id;
  final String label;
  final String iconName;

  WhenThenOption({
    required this.id,
    required this.label,
    required this.iconName,
  });

  factory WhenThenOption.fromMap(String id, Map<String, dynamic> data) {
    return WhenThenOption(
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

  Map<String, dynamic> toWhenThenMap() {
    return {
      'id': id,
      'label': label,
      'iconName': iconName,
    };
  }
}
