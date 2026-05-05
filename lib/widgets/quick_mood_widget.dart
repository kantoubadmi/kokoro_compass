import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/happiness_provider.dart';

class QuickMoodWidget extends StatelessWidget {
  const QuickMoodWidget({super.key});

  static const List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'score': 2, 'label': 'つらい'},
    {'emoji': '😔', 'score': 4, 'label': '落ち込み'},
    {'emoji': '😐', 'score': 5, 'label': 'ふつう'},
    {'emoji': '🙂', 'score': 7, 'label': '良い'},
    {'emoji': '😊', 'score': 9, 'label': '最高'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2D2A)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '今の気分は？',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.map((mood) {
                return _MoodButton(
                  emoji: mood['emoji'] as String,
                  score: mood['score'] as int,
                  label: mood['label'] as String,
                  onTap: () => _recordMood(context, mood['score'] as int),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordMood(BuildContext context, int score) async {
    try {
      await context.read<HappinessProvider>().addRecord(score);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_getEmoji(score)),
                const SizedBox(width: 8),
                const Text('気分を記録しました'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  String _getEmoji(int score) {
    for (final mood in moods) {
      if (mood['score'] == score) return mood['emoji'] as String;
    }
    return '😐';
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final int score;
  final String label;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.score,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
