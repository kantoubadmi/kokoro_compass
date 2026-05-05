import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalsProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('今日の目標'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Consumer<GoalsProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily intention
                  _buildIntentionCard(context, provider),
                  const SizedBox(height: 24),

                  // Progress
                  if (provider.goals.isNotEmpty) ...[
                    _buildProgressCard(context, provider),
                    const SizedBox(height: 24),
                  ],

                  // Goals list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '今日の目標',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddGoalDialog(context, provider),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('追加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (provider.goals.isEmpty)
                    _buildEmptyState(context, provider)
                  else
                    ...provider.goals.map(
                      (goal) => _GoalTile(
                        goal: goal,
                        onToggle: () => provider.toggleGoal(goal.id),
                        onDelete: () => provider.removeGoal(goal.id),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Suggested goals
                  const Text(
                    'おすすめの目標',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.suggestedGoals.map((suggestion) {
                      return ActionChip(
                        avatar: Text(suggestion['emoji']!),
                        label: Text(suggestion['title']!),
                        onPressed: () {
                          provider.addGoal(
                            suggestion['title']!,
                            suggestion['emoji']!,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntentionCard(BuildContext context, GoalsProvider provider) {
    return Card(
      child: InkWell(
        onTap: () => _showIntentionDialog(context, provider),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '今日の意図',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.dailyIntention ?? 'タップして今日の意図を設定...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: provider.dailyIntention != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontStyle: provider.dailyIntention != null
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, GoalsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今日の進捗',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${provider.completedCount}/${provider.totalCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.completionRate,
                minHeight: 12,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getProgressMessage(provider.completionRate),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressMessage(double rate) {
    if (rate >= 1.0) return '素晴らしい！全ての目標を達成しました！🎉';
    if (rate >= 0.75) return 'もう少しで完了です！頑張って！💪';
    if (rate >= 0.5) return '半分達成しました！この調子で！✨';
    if (rate >= 0.25) return '良いスタートです！続けましょう！🌱';
    return '一つずつ達成していきましょう！🚀';
  }

  Widget _buildEmptyState(BuildContext context, GoalsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'まだ目標がありません',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '下のおすすめから選ぶか、新しく追加してください',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showIntentionDialog(
    BuildContext context,
    GoalsProvider provider,
  ) async {
    final controller = TextEditingController(text: provider.dailyIntention);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今日の意図'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例: 今日は穏やかに過ごす',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          maxLength: 100,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('設定'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      provider.setDailyIntention(result.trim());
    }
  }

  Future<void> _showAddGoalDialog(
    BuildContext context,
    GoalsProvider provider,
  ) async {
    final titleController = TextEditingController();
    String selectedEmoji = '🎯';

    final emojis = ['🎯', '✨', '💪', '🌟', '🔥', '💡', '🌈', '🍀', '⭐', '🚀'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新しい目標'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: '目標を入力',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emojis.map((emoji) {
                  final isSelected = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => selectedEmoji = emoji),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      provider.addGoal(titleController.text.trim(), selectedEmoji);
    }
  }
}

class _GoalTile extends StatelessWidget {
  final DailyGoal goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalTile({
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: goal.isCompleted
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: goal.isCompleted ? Colors.green : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: goal.isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : Text(goal.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            decoration:
                goal.isCompleted ? TextDecoration.lineThrough : null,
            color: goal.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onDelete,
          color: Colors.grey,
        ),
      ),
    );
  }
}
