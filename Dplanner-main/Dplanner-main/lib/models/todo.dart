class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String priority;
  final bool hasReminder;
  final int reminderMinutes;
  final bool isHidden;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 'medium',
    this.hasReminder = false,
    required this.reminderMinutes, // Make it required so it must be explicitly set
    this.isHidden = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? priority,
    bool? hasReminder,
    int? reminderMinutes,
    bool? isHidden,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  // Convert Todo to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'hasReminder': hasReminder ? 1 : 0,
      'reminderMinutes': reminderMinutes,
      'isHidden': isHidden ? 1 : 0,
    };
  }

  // Create Todo from Map (from SQLite)
  factory Todo.fromMap(Map<String, dynamic> map) {
    try {
      return Todo(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        isCompleted: (map['isCompleted'] ?? 0) == 1,
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'].toString()) : null,
        priority: map['priority']?.toString() ?? 'medium',
        hasReminder: (map['hasReminder'] ?? 0) == 1,
        reminderMinutes: int.tryParse(map['reminderMinutes']?.toString() ?? '10') ?? 10,
        isHidden: (map['isHidden'] ?? 0) == 1,
      );
    } catch (e) {
      print('Error parsing Todo from map: $e');
      // Return a default Todo if parsing fails
      return Todo(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title']?.toString() ?? 'Unknown Task',
        description: '',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: null,
        priority: 'medium',
        hasReminder: false,
        reminderMinutes: 10,
        isHidden: false,
      );
    }
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
