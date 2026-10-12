import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

// Model for chat messages in FoodScreen
class FoodChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final ParsedFoodLog? loggedFood;
  final int timestamp;
  bool isUndone;

  FoodChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.loggedFood,
    required this.timestamp,
    this.isUndone = false,
  });
}

// Model for parsed food result from natural language
class ParsedFoodLog {
  final String foodName;
  final int calories;
  final double proteinG;
  final double fatG;
  final String mealType;
  final String emoji;
  final bool isEstimated;

  ParsedFoodLog({
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.mealType,
    required this.emoji,
    this.isEstimated = false,
  });
}

class FoodScreen extends ConsumerStatefulWidget {
  final String? initialMeal;

  const FoodScreen({super.key, this.initialMeal});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> {
  late String _selectedMeal;

  // Chat controllers
  final _chatInputController = TextEditingController();
  final _chatScrollController = ScrollController();
  final List<FoodChatMessage> _chatMessages = [];

  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMeal ?? _getMealByCurrentTime();
    _initChatMessages();
  }

  void _initChatMessages() {
    final defaultMeal = _getMealByCurrentTime();
    _chatMessages.add(
      FoodChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: "Tell me casually what you ate with calories, protein, and fat!\n\n"
            "• “2 eggs and toast, 350 cal, 20g protein, 12g fat for breakfast”\n"
            "• “Chicken rice bowl, 600 cal, 45g protein, 15g fat”\n"
            "• Or tap your daily routine presets below! 🥛🍳🥗\n\n"
            "Auto-categorized into $defaultMeal based on timing, or what you mention!",
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // Timing Categorization Helper
  // ==========================================
  String _getMealByCurrentTime() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'Lunch';
    } else if (hour >= 16 && hour < 22) {
      return 'Dinner';
    } else {
      return 'Snack';
    }
  }

  String _getMealTimingLabel(String meal) {
    switch (meal) {
      case 'Breakfast':
        return '4 AM - 11 AM';
      case 'Lunch':
        return '11 AM - 4 PM';
      case 'Dinner':
        return '4 PM - 10 PM';
      case 'Snack':
      default:
        return 'Anytime';
    }
  }

  String _getMealEmoji(String meal) {
    switch (meal) {
      case 'Breakfast':
        return '🍳';
      case 'Lunch':
        return '🥗';
      case 'Dinner':
        return '🍲';
      case 'Snack':
      default:
        return '🍪';
    }
  }

  String _getFoodEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('protein') || lower.contains('shake') || lower.contains('whey')) return '🥛';
    if (lower.contains('egg')) return '🍳';
    if (lower.contains('toast') || lower.contains('bread')) return '🍞';
    if (lower.contains('chicken') || lower.contains('meat') || lower.contains('steak')) return '🍗';
    if (lower.contains('salad') || lower.contains('veggie') || lower.contains('bowl')) return '🥗';
    if (lower.contains('rice') || lower.contains('curry')) return '🍚';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('burger')) return '🍔';
    if (lower.contains('fish') || lower.contains('salmon') || lower.contains('tuna')) return '🐟';
    if (lower.contains('coffee') || lower.contains('tea')) return '☕';
    if (lower.contains('oat') || lower.contains('cereal')) return '🥣';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('apple')) return '🍎';
    if (lower.contains('fruit') || lower.contains('berry')) return '🍓';
    if (lower.contains('yogurt')) return '🥛';
    if (lower.contains('pasta') || lower.contains('noodle')) return '🍝';
    if (lower.contains('snack') || lower.contains('cookie') || lower.contains('nut')) return '🍪';
    return '🍽️';
  }

  // ==========================================
  // Casual Saying NLP Parser with Routine Detection
  // ==========================================
  ParsedFoodLog _parseCasualFoodText(String input, List<FoodItem> allFoods) {
    final lower = input.toLowerCase();

    // 1. Determine Meal Category from user text or timing
    String mealType = _selectedMeal;
    if (lower.contains('breakfast') || lower.contains('morning') || lower.contains('brunch')) {
      mealType = 'Breakfast';
    } else if (lower.contains('lunch') || lower.contains('afternoon') || lower.contains('midday') || lower.contains('noon')) {
      mealType = 'Lunch';
    } else if (lower.contains('dinner') || lower.contains('supper') || lower.contains('evening') || lower.contains('night')) {
      mealType = 'Dinner';
    } else if (lower.contains('snack') || lower.contains('tea time')) {
      mealType = 'Snack';
    }

    // 2. Check for Routine Presets (e.g. "same routine", "usual protein", "repeat yesterday")
    final isRoutineQuery = lower.contains('same') ||
        lower.contains('routine') ||
        lower.contains('usual') ||
        lower.contains('repeat');

    if (isRoutineQuery) {
      if (lower.contains('protein') || lower.contains('shake') || lower.contains('whey')) {
        return ParsedFoodLog(
          foodName: 'Daily Whey Protein Shake',
          calories: 180,
          proteinG: 30.0,
          fatG: 2.0,
          mealType: mealType,
          emoji: '🥛',
        );
      } else if (mealType == 'Breakfast') {
        return ParsedFoodLog(
          foodName: 'Routine Eggs & Toast',
          calories: 350,
          proteinG: 20.0,
          fatG: 12.0,
          mealType: 'Breakfast',
          emoji: '🍳',
        );
      } else if (mealType == 'Lunch') {
        return ParsedFoodLog(
          foodName: 'Routine Chicken & Rice Bowl',
          calories: 600,
          proteinG: 45.0,
          fatG: 15.0,
          mealType: 'Lunch',
          emoji: '🥗',
        );
      } else if (mealType == 'Dinner') {
        return ParsedFoodLog(
          foodName: 'Routine Salmon & Veggies',
          calories: 650,
          proteinG: 50.0,
          fatG: 18.0,
          mealType: 'Dinner',
          emoji: '🍲',
        );
      } else {
        return ParsedFoodLog(
          foodName: 'Daily Protein Snack',
          calories: 200,
          proteinG: 20.0,
          fatG: 5.0,
          mealType: 'Snack',
          emoji: '🍪',
        );
      }
    }

    // 3. Extract Calories
    int? calories;
    final calMatch = RegExp(r'(\d+)\s*(?:kcal|calories|cal|cals)\b', caseSensitive: false).firstMatch(input);
    if (calMatch != null) {
      calories = int.tryParse(calMatch.group(1)!);
    }

    // 4. Extract Protein
    double? protein;
    final protMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g\s*protein|g\s*p|protein|prot)\b', caseSensitive: false).firstMatch(input);
    if (protMatch != null) {
      protein = double.tryParse(protMatch.group(1)!);
    }

    // 5. Extract Fat
    double? fat;
    final fatMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g\s*fat|g\s*f|fat|fats)\b', caseSensitive: false).firstMatch(input);
    if (fatMatch != null) {
      fat = double.tryParse(fatMatch.group(1)!);
    }

    // 6. Clean Food Name
    String cleanName = input;
    if (calMatch != null) cleanName = cleanName.replaceFirst(calMatch.group(0)!, ' ');
    if (protMatch != null) cleanName = cleanName.replaceFirst(protMatch.group(0)!, ' ');
    if (fatMatch != null) cleanName = cleanName.replaceFirst(fatMatch.group(0)!, ' ');

    cleanName = cleanName.replaceAll(
      RegExp(r'\b(?:i\s+had|i\s+ate|ate|had|log|logged|just\s+had|just\s+ate|eating|for\s+breakfast|for\s+lunch|for\s+dinner|for\s+snack|breakfast|lunch|dinner|snack)\b', caseSensitive: false),
      ' ',
    );
    cleanName = cleanName.replaceAll(RegExp(r'[:;,]+'), ' ');
    cleanName = cleanName.replaceAll(RegExp(r'\b(?:with)\b', caseSensitive: false), ' ');
    cleanName = cleanName.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Check database match if values are missing
    bool isEstimated = false;
    FoodItem? matchedFood;
    if (cleanName.isNotEmpty) {
      for (final f in allFoods) {
        if (f.name.toLowerCase() == cleanName.toLowerCase() ||
            cleanName.toLowerCase().contains(f.name.toLowerCase())) {
          matchedFood = f;
          break;
        }
      }
    }

    if (matchedFood != null) {
      calories ??= matchedFood.calories;
      protein ??= matchedFood.proteinG;
      fat ??= (matchedFood.calories * 0.22 / 9).clamp(0.0, 80.0);
    } else {
      if (calories == null) {
        calories = 300;
        isEstimated = true;
      }
      protein ??= (calories * 0.15 / 4).clamp(2.0, 120.0);
      fat ??= (calories * 0.25 / 9).clamp(1.0, 80.0);
    }

    if (cleanName.isEmpty) {
      cleanName = matchedFood?.name ?? '$mealType Item';
    } else {
      cleanName = cleanName.split(' ').map((w) {
        if (w.isEmpty) return '';
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');
    }

    final emoji = matchedFood?.emoji ?? _getFoodEmoji(cleanName);

    return ParsedFoodLog(
      foodName: cleanName,
      calories: calories,
      proteinG: double.parse(protein.toStringAsFixed(1)),
      fatG: double.parse(fat.toStringAsFixed(1)),
      mealType: mealType,
      emoji: emoji,
      isEstimated: isEstimated,
    );
  }

  // ==========================================
  // Handle Chat Input Submission
  // ==========================================
  Future<void> _handleChatSubmit(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    _chatInputController.clear();

    // 1. Parse food details from casual user saying
    final allFoods = ref.read(foodsProvider);
    final parsed = _parseCasualFoodText(clean, allFoods);

    // 2. Create chat messages (user saying & assistant confirmation card)
    final userMsg = FoodChatMessage(
      id: const Uuid().v4(),
      isUser: true,
      text: clean,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final botMsg = FoodChatMessage(
      id: const Uuid().v4(),
      isUser: false,
      text: "Logged to ${parsed.mealType} ${_getMealEmoji(parsed.mealType)}!",
      loggedFood: parsed,
      timestamp: DateTime.now().millisecondsSinceEpoch + 1,
    );

    setState(() {
      _chatMessages.add(userMsg);
      _chatMessages.add(botMsg);
      _selectedMeal = parsed.mealType;
    });
    _scrollChatToBottom();

    // 3. Save as food item & log to mealLogsProvider
    final customFood = FoodItem(
      id: const Uuid().v4(),
      name: parsed.foodName,
      calories: parsed.calories,
      proteinG: parsed.proteinG,
      servingLabel: '1 serving (${parsed.fatG.round()}g fat)',
      category: parsed.mealType,
      emoji: parsed.emoji,
      isCustom: true,
    );

    ref.read(mealLogsProvider.notifier).logFood(
      mealType: parsed.mealType,
      food: customFood,
      quantity: 1,
    );

    ref.read(foodsProvider.notifier).addCustomFood(
      name: customFood.name,
      calories: customFood.calories,
      proteinG: customFood.proteinG,
    );
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _undoChatMessage(FoodChatMessage msg) async {
    setState(() {
      msg.isUndone = true;
    });
    final popped = await ref.read(mealLogsProvider.notifier).undoLast();
    if (mounted) {
      MallowToast.show(context, 'Undid ${popped?.foodName ?? msg.loggedFood?.foodName ?? "item"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MallowCircleButton(
                    size: 38,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/today');
                      }
                    },
                    child: const Icon(Icons.arrow_back, size: 20, color: MallowColors.charcoal),
                  ),
                  Column(
                    children: [
                      Text(
                        'Add food',
                        style: MallowTypography.headlineMedium(),
                      ),
                      Text(
                        '💬 Chat Logger',
                        style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                      ),
                    ],
                  ),
                  MallowAvatar(
                    size: 38,
                    onTap: () => context.go('/pet'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 2. Meal Timing Selector & Auto-detection Pill Bar
            _buildMealTimingHeader(),
            const SizedBox(height: 10),

            // 3. Conversational Chat & Routine Logging
            Expanded(
              child: _buildChatLogMode(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Meal Timing Header with Badges
  // ==========================================
  Widget _buildMealTimingHeader() {
    final suggestedMeal = _getMealByCurrentTime();

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _meals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final meal = _meals[index];
              final isSelected = _selectedMeal == meal;
              final isSuggested = suggestedMeal == meal;

              return GestureDetector(
                onTap: () => setState(() => _selectedMeal = meal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MallowColors.hotPink
                        : isSuggested
                            ? const Color(0xFFF0E8D8)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
                      width: isSelected ? 2.0 : 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getMealEmoji(meal), style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        meal,
                        style: MallowTypography.buttonText(
                          color: MallowColors.charcoal,
                        ),
                      ),
                      if (isSuggested) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: MallowColors.oliveGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⏰ Auto-categorized by time: $suggestedMeal',
                style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
              ),
              Text(
                _getMealTimingLabel(_selectedMeal),
                style: MallowTypography.bodySmall(
                  color: MallowColors.charcoal,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CHAT LOG MODE
  // ==========================================
  Widget _buildChatLogMode() {
    return Column(
      children: [
        // 1. Chat Messages View
        Expanded(
          child: ListView.separated(
            controller: _chatScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _chatMessages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              return _buildChatMessageItem(msg);
            },
          ),
        ),

        // 2. Same Routine & Quick Presets Row
        _buildRoutinePresetsRow(),

        // 3. Casual Saying Chat Input Box
        _buildChatInputBar(),
      ],
    );
  }

  Widget _buildChatMessageItem(FoodChatMessage msg) {
    if (msg.isUser) {
      // User casual saying bubble
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: MallowColors.charcoal,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: MallowTypography.bodyMedium(
              color: Colors.white,
              weight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Assistant response with logged meal card
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mascot Avatar Mini
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: MallowColors.hotPinkLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MallowColors.charcoal, width: 1.5),
            ),
            child: const Center(
              child: Text('🎀', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: MallowTypography.bodyMedium(
                      weight: FontWeight.w600,
                      color: MallowColors.charcoal,
                    ),
                  ),

                  // If this message contains a logged food card
                  if (msg.loggedFood != null) ...[
                    const SizedBox(height: 10),
                    _buildLoggedFoodCard(msg),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedFoodCard(FoodChatMessage msg) {
    final food = msg.loggedFood!;
    final isUndone = msg.isUndone;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUndone ? const Color(0xFFF5EFE6) : MallowColors.cardCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUndone ? Colors.grey : MallowColors.charcoal,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(food.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    food.foodName,
                    style: MallowTypography.headlineSmall(fontSize: 16),
                  ),
                ],
              ),
              // Meal Timing Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUndone ? Colors.grey.shade400 : MallowColors.hotPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  food.mealType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Macro Breakdown Pills
          Row(
            children: [
              _buildMacroPill('🔥', '${food.calories} kcal', MallowColors.charcoal),
              const SizedBox(width: 6),
              _buildMacroPill('🥩', '${food.proteinG.round()}g P', MallowColors.oliveGreen),
              const SizedBox(width: 6),
              _buildMacroPill('🥑', '${food.fatG.round()}g F', MallowColors.slateBlue),
            ],
          ),
          const SizedBox(height: 8),

          // Undo or Status footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isUndone ? 'Removed from log' : 'Saved to daily tracker',
                style: MallowTypography.bodySmall(
                  color: isUndone ? Colors.red : MallowColors.textSubtle,
                  weight: FontWeight.w600,
                ),
              ),
              if (!isUndone)
                GestureDetector(
                  onTap: () => _undoChatMessage(msg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: MallowColors.charcoal, width: 1),
                    ),
                    child: Text(
                      'Undo',
                      style: MallowTypography.bodySmall(
                        color: MallowColors.charcoal,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Same Routine Presets & Quick Logging Options
  Widget _buildRoutinePresetsRow() {
    final presets = [
      {
        'label': 'Banana',
        'sub': '105 cal, 1.3g P',
        'saying': 'Banana, 105 calories, 1g protein, 0g fat',
      },
      {
        'label': 'Apple',
        'sub': '95 cal, 0.5g P',
        'saying': 'Apple, 95 calories, 1g protein, 0g fat',
      },
      {
        'label': '🥛 Same Protein',
        'sub': '180 cal, 30g P',
        'saying': 'Daily whey protein shake, 180 cal, 30g protein, 2g fat',
      },
      {
        'label': '🔁 Same Routine',
        'sub': 'Repeat $_selectedMeal',
        'saying': 'Same routine for $_selectedMeal',
      },
      {
        'label': '🍳 Routine Breakfast',
        'sub': '350 cal, 20g P',
        'saying': 'Routine eggs and toast, 350 calories, 20g protein, 12g fat for breakfast',
      },
      {
        'label': '🥗 Routine Lunch',
        'sub': '600 cal, 45g P',
        'saying': 'Routine chicken rice bowl, 600 calories, 45g protein, 15g fat for lunch',
      },
      {
        'label': '🍗 Routine Dinner',
        'sub': '650 cal, 50g P',
        'saying': 'Routine salmon and veggies, 650 calories, 50g protein, 18g fat for dinner',
      },
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: presets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = presets[index];
          final label = p['label']!;
          final sub = p['sub']!;
          final saying = p['saying']!;

          return GestureDetector(
            onTap: () => _handleChatSubmit(saying),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: label.contains('Same') || label.contains('Routine')
                      ? MallowColors.hotPink
                      : MallowColors.borderSubtle,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: MallowTypography.bodySmall(
                      color: MallowColors.charcoal,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($sub)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: MallowColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Casual Saying Chat Input Box
  Widget _buildChatInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: MallowColors.cardCream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
              ),
              child: TextField(
                controller: _chatInputController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleChatSubmit,
                style: MallowTypography.bodyMedium(),
                decoration: InputDecoration(
                  hintText: 'e.g. 2 eggs toast 350 cal 20g p, or "same protein"...',
                  hintStyle: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleChatSubmit(_chatInputController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: MallowColors.charcoal,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
