import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dplanner/models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.onEdit,
  });

  Color _getPriorityColor() {
    switch (todo.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    // Calculate difference in days
    final difference = dueDay.difference(today).inDays;

    // Format time
    final timeStr =
        '${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';

    if (difference == 0) {
      return 'Today at $timeStr';
    } else if (difference == 1) {
      return 'Tomorrow at $timeStr';
    } else if (difference == -1) {
      return 'Yesterday at $timeStr';
    } else if (difference > 1 && difference <= 7) {
      return '${dueDate.weekday == 1
          ? 'Mon'
          : dueDate.weekday == 2
          ? 'Tue'
          : dueDate.weekday == 3
          ? 'Wed'
          : dueDate.weekday == 4
          ? 'Thu'
          : dueDate.weekday == 5
          ? 'Fri'
          : dueDate.weekday == 6
          ? 'Sat'
          : 'Sun'} at $timeStr';
    } else if (difference > 7) {
      return '${dueDate.day}/${dueDate.month} at $timeStr';
    } else {
      return '${dueDate.day}/${dueDate.month} at $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        // Glassmorphism effect
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Minimalistic checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.isCompleted
                            ? Colors.white.withOpacity(0.8)
                            : Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      color: todo.isCompleted
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: todo.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),

                      // Description (only if not completed and has description)
                      if (todo.description.isNotEmpty && !todo.isCompleted) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Tags row (only if not completed)
                      if (!todo.isCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Priority indicator
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Due date and time (if exists)
                            if (todo.dueDate != null) ...[
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(todo.dueDate!),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Action buttons (minimalistic)
                if (!todo.isCompleted)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue.withOpacity(0.8),
                              size: 16,
                            ),
                          ),
                        ),
                      if (onEdit != null) const SizedBox(width: 8),
                      // Delete button
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red.withOpacity(0.8),
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
