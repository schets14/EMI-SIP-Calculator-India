class SavedPlan {
  final String id;
  final String title;
  final String type;
  final String summary;
  final DateTime createdAt;
  final Map<String, dynamic> inputs;

  const SavedPlan({required this.id, required this.title, required this.type, required this.summary, required this.createdAt, required this.inputs});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'type': type, 'summary': summary, 'createdAt': createdAt.toIso8601String(), 'inputs': inputs};
  factory SavedPlan.fromJson(Map<String, dynamic> json) => SavedPlan(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    title: json['title'] as String? ?? 'Saved plan',
    type: json['type'] as String? ?? 'plan',
    summary: json['summary'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    inputs: Map<String, dynamic>.from(json['inputs'] as Map? ?? {}),
  );
}

class FinanceReminder {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  final String type;
  final bool completed;

  const FinanceReminder({required this.id, required this.title, required this.note, required this.dueDate, required this.type, this.completed = false});
  FinanceReminder copyWith({bool? completed}) => FinanceReminder(id: id, title: title, note: note, dueDate: dueDate, type: type, completed: completed ?? this.completed);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'note': note, 'dueDate': dueDate.toIso8601String(), 'type': type, 'completed': completed};
  factory FinanceReminder.fromJson(Map<String, dynamic> json) => FinanceReminder(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    title: json['title'] as String? ?? 'Reminder',
    note: json['note'] as String? ?? '',
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    type: json['type'] as String? ?? 'finance',
    completed: json['completed'] as bool? ?? false,
  );
}

class FinancialHealth {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double existingEmi;
  final double monthlyInvestments;
  final double emergencyFund;
  final double savings;
  const FinancialHealth({required this.monthlyIncome, required this.monthlyExpenses, required this.existingEmi, required this.monthlyInvestments, required this.emergencyFund, required this.savings});
  Map<String, dynamic> toJson() => {'monthlyIncome': monthlyIncome, 'monthlyExpenses': monthlyExpenses, 'existingEmi': existingEmi, 'monthlyInvestments': monthlyInvestments, 'emergencyFund': emergencyFund, 'savings': savings};
  factory FinancialHealth.fromJson(Map<String, dynamic> json) => FinancialHealth(
    monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
    monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0,
    existingEmi: (json['existingEmi'] as num?)?.toDouble() ?? 0,
    monthlyInvestments: (json['monthlyInvestments'] as num?)?.toDouble() ?? 0,
    emergencyFund: (json['emergencyFund'] as num?)?.toDouble() ?? 0,
    savings: (json['savings'] as num?)?.toDouble() ?? 0,
  );
}
