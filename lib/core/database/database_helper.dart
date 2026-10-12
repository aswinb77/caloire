import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _dbFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _dbFuture ??= _initDB('mallow_app.db');
    _database = await _dbFuture!;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.delete('log_entry');
        await db.delete('workout_log');
        try {
          final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM food')) ?? 0;
          if (count == 0) {
            for (final f in kDefaultFoodItems) {
              await db.insert('food', f.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        } catch (_) {}
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Profile table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        goal TEXT,
        dailyTargetKcal INTEGER,
        proteinGoalG REAL,
        burnGoalKcal INTEGER,
        weightKg REAL,
        heightCm REAL,
        waistCm REAL,
        targetWeightKg REAL
      )
    ''');

    // 2. Food items table
    await db.execute('''
      CREATE TABLE food (
        id TEXT PRIMARY KEY,
        name TEXT,
        calories INTEGER,
        proteinG REAL,
        servingLabel TEXT,
        category TEXT,
        emoji TEXT,
        isCustom INTEGER
      )
    ''');

    // 3. Meal logs table
    await db.execute('''
      CREATE TABLE log_entry (
        id TEXT PRIMARY KEY,
        date TEXT,
        mealType TEXT,
        foodItemId TEXT,
        foodName TEXT,
        calories INTEGER,
        proteinG REAL,
        quantity INTEGER,
        createdAt INTEGER
      )
    ''');

    // 4. Workout logs table
    await db.execute('''
      CREATE TABLE workout_log (
        id TEXT PRIMARY KEY,
        date TEXT,
        exerciseName TEXT,
        category TEXT,
        met REAL,
        minutes INTEGER,
        caloriesBurned INTEGER,
        createdAt INTEGER
      )
    ''');

    // 5. Weight entries table
    await db.execute('''
      CREATE TABLE weight_entry (
        id TEXT PRIMARY KEY,
        date TEXT,
        weightKg REAL,
        createdAt INTEGER
      )
    ''');

    // 6. Pet state table
    await db.execute('''
      CREATE TABLE pet_state (
        id INTEGER PRIMARY KEY,
        energy INTEGER,
        joy INTEGER,
        lastUpdated INTEGER
      )
    ''');

    // 7. Chat messages table
    await db.execute('''
      CREATE TABLE chat_message (
        id TEXT PRIMARY KEY,
        isUser INTEGER,
        text TEXT,
        intentTag TEXT,
        timestamp INTEGER
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // 1. Seed Profile
    // Target = 1700 (lose weight: 2000 - 300) so that 1700 + 320 burn - 530 eaten = 1490 left!
    await db.insert('profile', {
      'id': 1,
      'goal': 'lose',
      'dailyTargetKcal': 1700,
      'proteinGoalG': 110.0,
      'burnGoalKcal': 500,
      'weightKg': 68.4,
      'heightCm': 172.0,
      'waistCm': 78.0,
      'targetWeightKg': 65.0,
    });

    // 2. Seed Foods
    for (final food in kDefaultFoodItems) {
      await db.insert('food', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // New user starts fresh with 0 kcal eaten and 0 kcal burned today!
    final now = DateTime.now();

    // 3. Seed 8-point weight history (Matching baseline: 7 weeks ago 70.1 to today 68.4)
    final weights = [70.1, 69.8, 69.5, 69.6, 69.2, 69.0, 68.7, 68.4];
    for (int i = 0; i < weights.length; i++) {
      final weekDate = now.subtract(Duration(days: (7 - i) * 7));
      final dateStr = '${weekDate.year}-${weekDate.month.toString().padLeft(2, '0')}-${weekDate.day.toString().padLeft(2, '0')}';
      await db.insert('weight_entry', {
        'id': const Uuid().v4(),
        'date': dateStr,
        'weightKg': weights[i],
        'createdAt': weekDate.millisecondsSinceEpoch,
      });
    }

    // 6. Seed Pet State (Joy = 75, Energy = 80)
    await db.insert('pet_state', {
      'id': 1,
      'energy': 80,
      'joy': 75,
      'lastUpdated': now.millisecondsSinceEpoch,
    });

    // 7. Seed Initial Chat message
    await db.insert('chat_message', {
      'id': const Uuid().v4(),
      'isUser': 0,
      'text': 'Hi! You have 1,490 kcal and 82 g protein left today. How can I help?',
      'intentTag': 'get_remaining',
      'timestamp': now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
    });
  }

  // Database Accessors

  Future<UserProfile> getProfile() async {
    try {
      final db = await database;
      final res = await db.query('profile', where: 'id = ?', whereArgs: [1]);
      if (res.isNotEmpty) {
        return UserProfile.fromMap(res.first);
      }
    } catch (_) {}
    return const UserProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      final db = await database;
      await db.insert('profile', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }


  Future<List<FoodItem>> getFoods() async {
    final db = await database;
    final res = await db.query('food');
    if (res.isEmpty) {
      for (final food in kDefaultFoodItems) {
        await db.insert('food', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return kDefaultFoodItems;
    }
    return res.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<void> insertFood(FoodItem food) async {
    final db = await database;
    await db.insert('food', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MealLog>> getMealLogsForDate(String date) async {
    final db = await database;
    final res = await db.query('log_entry', where: 'date = ?', whereArgs: [date], orderBy: 'createdAt ASC');
    return res.map((m) => MealLog.fromMap(m)).toList();
  }

  Future<void> insertMealLog(MealLog log) async {
    final db = await database;
    await db.insert('log_entry', log.toMap());
  }

  Future<void> deleteMealLog(String id) async {
    final db = await database;
    await db.delete('log_entry', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkoutLog>> getWorkoutLogsForDate(String date) async {
    final db = await database;
    final res = await db.query('workout_log', where: 'date = ?', whereArgs: [date], orderBy: 'createdAt DESC');
    return res.map((m) => WorkoutLog.fromMap(m)).toList();
  }

  Future<void> insertWorkoutLog(WorkoutLog log) async {
    try {
      final db = await database;
      await db.insert('workout_log', log.toMap());
    } catch (_) {}
  }

  Future<void> deleteWorkoutLog(String id) async {
    try {
      final db = await database;
      await db.delete('workout_log', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }


  Future<List<WeightLog>> getWeightHistory() async {
    final db = await database;
    final res = await db.query('weight_entry', orderBy: 'createdAt ASC');
    return res.map((m) => WeightLog.fromMap(m)).toList();
  }

  Future<void> insertWeightLog(WeightLog log) async {
    final db = await database;
    await db.insert('weight_entry', log.toMap());
  }

  Future<PetStateData> getPetState() async {
    final db = await database;
    final res = await db.query('pet_state', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return PetStateData.fromMap(res.first);
    }
    return PetStateData(lastUpdated: DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> updatePetState(PetStateData state) async {
    final db = await database;
    await db.update('pet_state', state.toMap(), where: 'id = ?', whereArgs: [1]);
  }

  Future<List<ChatMessageData>> getChatMessages() async {
    final db = await database;
    final res = await db.query('chat_message', orderBy: 'timestamp ASC');
    return res.map((m) => ChatMessageData.fromMap(m)).toList();
  }

  Future<void> insertChatMessage(ChatMessageData message) async {
    final db = await database;
    await db.insert('chat_message', message.toMap());
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('log_entry');
    await db.delete('workout_log');
    await db.delete('chat_message');
    await _seedDatabase(db);
  }
}
