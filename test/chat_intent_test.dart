import 'package:flutter_test/flutter_test.dart';

String routeIntent(String input) {
  final lower = input.toLowerCase().trim();
  if (lower.contains('undo')) {
    return 'undo_last';
  } else if (lower.contains('left') || lower.contains('remaining') || lower.contains('budget')) {
    return 'get_remaining';
  } else if (lower.contains('suggest') || lower.contains('dinner') || lower.contains('idea') || lower.contains('eat')) {
    return 'suggest_meal';
  } else if (lower.startsWith('log ') || lower.startsWith('ate ')) {
    return 'log_food';
  } else {
    return 'fallback';
  }
}

void main() {
  group('Chat Intent Router Tests', () {
    test('routes undo command to undo_last', () {
      expect(routeIntent('undo'), equals('undo_last'));
      expect(routeIntent('please undo last item'), equals('undo_last'));
    });

    test('routes remaining queries to get_remaining', () {
      expect(routeIntent("What's left today?"), equals('get_remaining'));
      expect(routeIntent('remaining calories'), equals('get_remaining'));
      expect(routeIntent('check my budget'), equals('get_remaining'));
    });

    test('routes suggestion queries to suggest_meal', () {
      expect(routeIntent('Suggest dinner'), equals('suggest_meal'));
      expect(routeIntent('Any idea for lunch?'), equals('suggest_meal'));
      expect(routeIntent('What should I eat?'), equals('suggest_meal'));
    });

    test('routes logging commands to log_food', () {
      expect(routeIntent('Log banana'), equals('log_food'));
      expect(routeIntent('ate rice'), equals('log_food'));
    });

    test('routes unknown message to fallback', () {
      expect(routeIntent('hello there'), equals('fallback'));
      expect(routeIntent('random phrase'), equals('fallback'));
    });
  });
}
