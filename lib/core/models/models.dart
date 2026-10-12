class UserProfile {
  final String goal; // 'lose', 'steady', 'build'
  final int dailyTargetKcal;
  final double proteinGoalG;
  final int burnGoalKcal;
  final double weightKg;
  final double heightCm;
  final double waistCm;
  final double targetWeightKg;

  const UserProfile({
    this.goal = 'lose',
    this.dailyTargetKcal = 2000,
    this.proteinGoalG = 110.0,
    this.burnGoalKcal = 500,
    this.weightKg = 68.4,
    this.heightCm = 172.0,
    this.waistCm = 78.0,
    this.targetWeightKg = 65.0,
  });

  UserProfile copyWith({
    String? goal,
    int? dailyTargetKcal,
    double? proteinGoalG,
    int? burnGoalKcal,
    double? weightKg,
    double? heightCm,
    double? waistCm,
    double? targetWeightKg,
  }) {
    return UserProfile(
      goal: goal ?? this.goal,
      dailyTargetKcal: dailyTargetKcal ?? this.dailyTargetKcal,
      proteinGoalG: proteinGoalG ?? this.proteinGoalG,
      burnGoalKcal: burnGoalKcal ?? this.burnGoalKcal,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      waistCm: waistCm ?? this.waistCm,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'goal': goal,
      'dailyTargetKcal': dailyTargetKcal,
      'proteinGoalG': proteinGoalG,
      'burnGoalKcal': burnGoalKcal,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'waistCm': waistCm,
      'targetWeightKg': targetWeightKg,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      goal: map['goal'] as String? ?? 'lose',
      dailyTargetKcal: map['dailyTargetKcal'] as int? ?? 2000,
      proteinGoalG: (map['proteinGoalG'] as num?)?.toDouble() ?? 110.0,
      burnGoalKcal: map['burnGoalKcal'] as int? ?? 500,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 68.4,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 172.0,
      waistCm: (map['waistCm'] as num?)?.toDouble() ?? 78.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 65.0,
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double proteinG;
  final String servingLabel;
  final String category;
  final String emoji;
  final bool isCustom;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.servingLabel,
    required this.category,
    required this.emoji,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteinG': proteinG,
      'servingLabel': servingLabel,
      'category': category,
      'emoji': emoji,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: map['calories'] as int,
      proteinG: (map['proteinG'] as num).toDouble(),
      servingLabel: map['servingLabel'] as String,
      category: map['category'] as String,
      emoji: map['emoji'] as String,
      isCustom: (map['isCustom'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MealLog {
  final String id;
  final String date; // YYYY-MM-DD
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final String foodItemId;
  final String foodName;
  final int calories;
  final double proteinG;
  final int quantity;
  final int createdAt;

  const MealLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodItemId,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mealType': mealType,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'calories': calories,
      'proteinG': proteinG,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'] as String,
      date: map['date'] as String,
      mealType: map['mealType'] as String,
      foodItemId: map['foodItemId'] as String,
      foodName: map['foodName'] as String,
      calories: map['calories'] as int,
      proteinG: (map['proteinG'] as num).toDouble(),
      quantity: map['quantity'] as int,
      createdAt: map['createdAt'] as int,
    );
  }
}

class WorkoutLog {
  final String id;
  final String date;
  final String exerciseName;
  final String category;
  final double met;
  final int minutes;
  final int caloriesBurned;
  final int createdAt;

  const WorkoutLog({
    required this.id,
    required this.date,
    required this.exerciseName,
    required this.category,
    required this.met,
    required this.minutes,
    required this.caloriesBurned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'exerciseName': exerciseName,
      'category': category,
      'met': met,
      'minutes': minutes,
      'caloriesBurned': caloriesBurned,
      'createdAt': createdAt,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'] as String,
      date: map['date'] as String,
      exerciseName: map['exerciseName'] as String,
      category: map['category'] as String,
      met: (map['met'] as num).toDouble(),
      minutes: map['minutes'] as int,
      caloriesBurned: map['caloriesBurned'] as int,
      createdAt: map['createdAt'] as int,
    );
  }
}

class WeightLog {
  final String id;
  final String date;
  final double weightKg;
  final int createdAt;

  const WeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weightKg': weightKg,
      'createdAt': createdAt,
    };
  }

  factory WeightLog.fromMap(Map<String, dynamic> map) {
    return WeightLog(
      id: map['id'] as String,
      date: map['date'] as String,
      weightKg: (map['weightKg'] as num).toDouble(),
      createdAt: map['createdAt'] as int,
    );
  }
}

class PetStateData {
  final int energy; // 0-100
  final int joy; // 0-100
  final int lastUpdated;

  const PetStateData({
    this.energy = 85,
    this.joy = 75,
    required this.lastUpdated,
  });

  PetStateData copyWith({int? energy, int? joy, int? lastUpdated}) {
    return PetStateData(
      energy: energy ?? this.energy,
      joy: joy ?? this.joy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'energy': energy,
      'joy': joy,
      'lastUpdated': lastUpdated,
    };
  }

  factory PetStateData.fromMap(Map<String, dynamic> map) {
    return PetStateData(
      energy: map['energy'] as int? ?? 85,
      joy: map['joy'] as int? ?? 75,
      lastUpdated: map['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class ChatMessageData {
  final String id;
  final bool isUser;
  final String text;
  final String? intentTag;
  final int timestamp;

  const ChatMessageData({
    required this.id,
    required this.isUser,
    required this.text,
    this.intentTag,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isUser': isUser ? 1 : 0,
      'text': text,
      'intentTag': intentTag,
      'timestamp': timestamp,
    };
  }

  factory ChatMessageData.fromMap(Map<String, dynamic> map) {
    return ChatMessageData(
      id: map['id'] as String,
      isUser: (map['isUser'] as int) == 1,
      text: map['text'] as String,
      intentTag: map['intentTag'] as String?,
      timestamp: map['timestamp'] as int,
    );
  }
}

const List<FoodItem> kDefaultFoodItems = [
  FoodItem(id: '1', name: 'Banana', calories: 105, proteinG: 1.3, servingLabel: 'for 1 medium', category: 'Fruit', emoji: '🍌'),
  FoodItem(id: '2', name: 'Apple', calories: 95, proteinG: 0.5, servingLabel: 'for 1 medium', category: 'Fruit', emoji: '🍎'),
  FoodItem(id: '3', name: 'Avocado', calories: 120, proteinG: 1.5, servingLabel: 'for half a fruit', category: 'Fruit', emoji: '🥑'),
  FoodItem(id: '4', name: 'Boiled egg', calories: 78, proteinG: 6.3, servingLabel: 'for 1 large', category: 'Protein', emoji: '🥚'),
  FoodItem(id: '5', name: 'Chicken breast', calories: 165, proteinG: 31.0, servingLabel: 'for 100 g', category: 'Protein', emoji: '🍗'),
  FoodItem(id: '6', name: 'Salmon fillet', calories: 206, proteinG: 22.0, servingLabel: 'for 100 g', category: 'Protein', emoji: '🐟'),
  FoodItem(id: '7', name: 'Greek yogurt', calories: 100, proteinG: 17.0, servingLabel: 'for 170 g', category: 'Protein', emoji: '🥛'),
  FoodItem(id: '8', name: 'Steamed rice', calories: 200, proteinG: 4.2, servingLabel: 'for 1 cup', category: 'Grains', emoji: '🍚'),
  FoodItem(id: '9', name: 'Rolled oats', calories: 150, proteinG: 5.0, servingLabel: 'for 40 g', category: 'Grains', emoji: '🥣'),
  FoodItem(id: '10', name: 'Whole wheat toast', calories: 80, proteinG: 4.0, servingLabel: 'for 1 slice', category: 'Grains', emoji: '🍞'),
  FoodItem(id: '11', name: 'Whey protein shake', calories: 130, proteinG: 25.0, servingLabel: 'for 1 scoop', category: 'Protein', emoji: '🥤'),
  FoodItem(id: '12', name: 'Mixed almonds', calories: 160, proteinG: 6.0, servingLabel: 'for 30 g', category: 'Snacks', emoji: '🥜'),
  FoodItem(id: '13', name: 'Dark chocolate', calories: 140, proteinG: 2.2, servingLabel: 'for 25 g', category: 'Snacks', emoji: '🍫'),
  FoodItem(id: '14', name: 'Black coffee', calories: 5, proteinG: 0.3, servingLabel: 'for 1 cup', category: 'Drinks', emoji: '☕'),
  FoodItem(id: '15', name: 'Green tea', calories: 2, proteinG: 0.0, servingLabel: 'for 1 cup', category: 'Drinks', emoji: '🍵'),
  FoodItem(id: '16', name: 'Puttu & Kadala', calories: 340, proteinG: 12.0, servingLabel: 'for 1 portion', category: 'Grains', emoji: '🥥'),
  FoodItem(id: '17', name: 'Matta rice & Fish curry', calories: 420, proteinG: 28.0, servingLabel: 'for 1 plate', category: 'Protein', emoji: '🍛'),
  FoodItem(id: '18', name: 'Paneer tikka', calories: 260, proteinG: 18.0, servingLabel: 'for 100 g', category: 'Protein', emoji: '🧀'),
];
