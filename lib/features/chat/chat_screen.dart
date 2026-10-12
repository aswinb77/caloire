import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessageData> _messages = [];

  final List<String> _quickChips = [
    "What's left?",
    "Suggest dinner",
    "Log banana",
    "Undo",
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    // Initial welcome message matching Screenshot 5
    _messages.add(
      ChatMessageData(
        id: const Uuid().v4(),
        isUser: false,
        text: "Hey Robyn! Tell me what you ate and I will log it.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String userText) async {
    final clean = userText.trim();
    if (clean.isEmpty) return;

    _textController.clear();

    // 1. Add user message
    setState(() {
      _messages.add(
        ChatMessageData(
          id: const Uuid().v4(),
          isUser: true,
          text: clean,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
    _scrollToBottom();

    // 2. Process Intent
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = clean.toLowerCase();

    String replyText;
    String? matchedIntent;

    final remaining = ref.read(remainingProvider);
    final totals = ref.read(todayTotalsProvider);
    final allFoods = ref.read(foodsProvider);

    if (lower.contains('undo')) {
      matchedIntent = 'undo_last';
      final popped = await ref.read(mealLogsProvider.notifier).undoLast();
      if (popped != null) {
        replyText = "Undid ${popped.foodName} (${popped.calories} kcal). Restored to your daily budget!";
      } else {
        replyText = "There's nothing in your log stack to undo right now.";
      }
    } else if (lower.contains('left') || lower.contains('remaining') || lower.contains('budget')) {
      matchedIntent = 'get_remaining';
      final remKcal = remaining.remainingKcal;
      final eatenProtein = totals.proteinG.round();
      replyText = "You have ${remKcal.abs()} kcal ${remaining.isOver ? 'over' : 'left'} today, and $eatenProtein g of protein so far.";
    } else if (lower.contains('suggest') || lower.contains('dinner') || lower.contains('lunch') || lower.contains('idea')) {
      matchedIntent = 'suggest_meal';
      replyText = "Try Chicken breast or Salmon fillet. Say “log chicken” and I'll add it.";
    } else if (lower.startsWith('log ') || lower.startsWith('ate ')) {
      matchedIntent = 'log_food';
      final query = lower.replaceFirst('log ', '').replaceFirst('ate ', '').trim();
      final match = allFoods.firstWhere(
        (f) => f.name.toLowerCase().contains(query),
        orElse: () => allFoods.first,
      );

      await ref.read(mealLogsProvider.notifier).logFood(
        mealType: 'Snack',
        food: match,
        quantity: 1,
      );
      replyText = "Logged 1 serving of ${match.name} (${match.calories} kcal) to Snack!";
    } else {
      matchedIntent = 'fallback';
      replyText = "You can ask “What's left?”, “Suggest dinner”, “Log banana”, or “Undo”.";
    }

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessageData(
            id: const Uuid().v4(),
            isUser: false,
            text: replyText,
            intentTag: matchedIntent,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching Screenshot 5: Mallow avatar, "Ask Mallow", circular "x" close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MallowAvatar(size: 38, animate: true),
                  Text(
                    'Ask Mallow',
                    style: MallowTypography.headlineMedium(),
                  ),
                  MallowCircleButton(
                    size: 38,
                    backgroundColor: MallowColors.cardCream,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        context.pop();
                      } else {
                        context.go('/today');
                      }
                    },
                    child: const Icon(Icons.close, size: 20, color: MallowColors.charcoal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Messages Stream
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageRow(msg);
                },
              ),
            ),

            // Quick Reply Chips Row matching Screenshot 5
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _quickChips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = _quickChips[index];
                  return GestureDetector(
                    onTap: () => _handleUserMessage(chip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: MallowColors.charcoal, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          chip,
                          style: MallowTypography.buttonText(
                            color: MallowColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Bottom Input Bar with Pink Upward Arrow Button matching Screenshot 5
            Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12 + MediaQuery.of(context).padding.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: MallowColors.charcoal, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: TextField(
                          controller: _textController,
                          onSubmitted: _handleUserMessage,
                          style: MallowTypography.bodyLarge(
                            color: MallowColors.charcoal,
                            weight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Log or ask anything',
                            hintStyle: MallowTypography.bodyLarge(
                              color: MallowColors.textSubtle,
                              weight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Hot Pink Circular Send Button with Upward Arrow
                  GestureDetector(
                    onTap: () => _handleUserMessage(_textController.text),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: MallowColors.hotPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: MallowColors.charcoal,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageRow(ChatMessageData msg) {
    if (msg.isUser) {
      // User message: Black pill bubble with white text matching Screenshot 5
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: MallowColors.charcoal,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            msg.text,
            style: MallowTypography.bodyLarge(
              color: Colors.white,
              weight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // Bot message: Beige rounded card with optional pink intent tag matching Screenshot 5
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: MallowColors.cardCream,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: MallowTypography.bodyLarge(
                  color: MallowColors.charcoal,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

