class CalculationRecord {
  final String type;
  final String title;
  final String summary;
  final DateTime createdAt;
  final Map<String, dynamic> inputs;

  const CalculationRecord({
    required this.type,
    required this.title,
    required this.summary,
    required this.createdAt,
    required this.inputs,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'summary': summary,
        'createdAt': createdAt.toIso8601String(),
        'inputs': inputs,
      };

  factory CalculationRecord.fromJson(Map<String, dynamic> json) {
    return CalculationRecord(
      type: json['type'] as String? ?? 'other',
      title: json['title'] as String? ?? 'Calculation',
      summary: json['summary'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      inputs: Map<String, dynamic>.from(json['inputs'] as Map? ?? {}),
    );
  }
}
