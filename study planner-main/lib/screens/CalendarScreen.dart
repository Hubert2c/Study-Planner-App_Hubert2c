import 'package:flutter/material.dart';
import 'package:dplanner/widgets/main_layout.dart';
import 'package:dplanner/widgets/calendar_widget.dart';
import 'package:dplanner/models/todo.dart';
import 'package:dplanner/services/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<Todo> calendarTasks = [];
  final SimpleDatabaseHelper _dbHelper = SimpleDatabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final todosList = await _dbHelper.getAllTodos();
      setState(() {
        calendarTasks = todosList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading todos: $e')),
        );
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Calendar',
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Colors.orange,
                )
              : CalendarWidget(
                  todos: calendarTasks,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    _onDateSelected(date);
                    // Navigate back to home with selected date
                    Navigator.pop(context, date);
                  },
                ),
        ),
      ),
    );
  }
}