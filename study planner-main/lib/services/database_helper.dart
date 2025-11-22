import 'package:sqflite/sqflite.dart';
import 'package:dplanner/models/todo.dart';

class SimpleDatabaseHelper {
  static final SimpleDatabaseHelper _instance = SimpleDatabaseHelper._internal();
  factory SimpleDatabaseHelper() => _instance;
  SimpleDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = 'dplanner.db';
      print('Using simple database path: $path');
      
      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      // If migration fails, try to recreate the database
      try {
        print('Attempting to recreate database...');
        return await _recreateDatabase();
      } catch (recreateError) {
        print('Failed to recreate database: $recreateError');
        rethrow;
      }
    }
  }

  Future<Database> _recreateDatabase() async {
    // Delete existing database and create new one
    final path = 'dplanner.db';
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onOpen: (db) {
        print('Database recreated successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        hasReminder INTEGER NOT NULL DEFAULT 0,
        reminderMinutes INTEGER NOT NULL,
        isHidden INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print('Database table created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // Add isHidden column
      await db.execute('ALTER TABLE todos ADD COLUMN isHidden INTEGER NOT NULL DEFAULT 0');
      print('Added isHidden column to todos table');
    }
    
    if (oldVersion < 3) {
      // Add reminder columns
      try {
        await db.execute('ALTER TABLE todos ADD COLUMN hasReminder INTEGER NOT NULL DEFAULT 0');
        print('Added hasReminder column to todos table');
      } catch (e) {
        print('hasReminder column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE todos ADD COLUMN reminderMinutes INTEGER NOT NULL DEFAULT 10');
        print('Added reminderMinutes column to todos table');
      } catch (e) {
        print('reminderMinutes column might already exist: $e');
      }
    }
  }

  // Create a new todo
  Future<String> insertTodo(Todo todo) async {
    try {
      final db = await database;
      await db.insert('todos', todo.toMap());
      print('Todo inserted successfully: ${todo.id}');
      return todo.id;
    } catch (e) {
      print('Error inserting todo: $e');
      rethrow;
    }
  }

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('todos');
      print('Retrieved ${maps.length} todos from database');
      return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all todos: $e');
      rethrow;
    }
  }

  // Get todos by date
  Future<List<Todo>> getTodosByDate(DateTime date) async {
    final db = await database;
    final String dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate = ?',
      whereArgs: [dateStr],
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get pending todos
  Future<List<Todo>> getPendingTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'isCompleted = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Update todo
  Future<int> updateTodo(Todo todo) async {
    try {
      final db = await database;
      final result = await db.update(
        'todos',
        todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
      print('Todo updated successfully: ${todo.id}');
      return result;
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  // Delete todo
  Future<int> deleteTodo(String id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Todo deleted successfully: $id');
      return result;
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // Toggle todo completion
  Future<int> toggleTodo(String id) async {
    try {
      final db = await database;
      final todo = await getTodoById(id);
      if (todo != null) {
        final result = await db.update(
          'todos',
          {'isCompleted': todo.isCompleted ? 0 : 1},
          where: 'id = ?',
          whereArgs: [id],
        );
        print('Todo toggled successfully: $id');
        return result;
      }
      return 0;
    } catch (e) {
      print('Error toggling todo: $e');
      rethrow;
    }
  }

  // Hide a todo (set isHidden to true)
  Future<int> hideTodo(String id) async {
    try {
      final db = await database;
      final result = await db.update(
        'todos',
        {'isHidden': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Todo hidden successfully: $id');
      return result;
    } catch (e) {
      print('Error hiding todo: $e');
      rethrow;
    }
  }

  // Show a todo (set isHidden to false)
  Future<int> showTodo(String id) async {
    try {
      final db = await database;
      final result = await db.update(
        'todos',
        {'isHidden': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Todo shown successfully: $id');
      return result;
    } catch (e) {
      print('Error showing todo: $e');
      rethrow;
    }
  }

  // Get todo by id
  Future<Todo?> getTodoById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  // Get completion rate
  Future<double> getCompletionRate() async {
    final db = await database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM todos');
    final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM todos WHERE isCompleted = 1');
    
    final total = totalResult.first['count'] as int;
    final completed = completedResult.first['count'] as int;
    
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      print('Database connection test successful');
      return true;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
