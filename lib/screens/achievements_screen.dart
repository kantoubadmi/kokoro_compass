import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('アチーブメント'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress header
                _buildProgressHeader(context, provider),
                const SizedBox(height: 24),

                // Unlocked achievements
                if (provider.unlockedAchievements.isNotEmpty) ...[
                  _buildSectionTitle(context, '獲得済み', provider.unlockedCount),
                  const SizedBox(height: 12),
                  ...provider.unlockedAchievements.map(
                    (a) => _AchievementCard(achievement: a, isUnlocked: true),
                  ),
                  const SizedBox(height: 24),
                ],

                // Locked achievements
                if (provider.lockedAchievements.isNotEmpty) ...[
                  _buildSectionTitle(
                    context,
                    '未獲得',
                    provider.lockedAchievements.length,
                  ),
                  const SizedBox(height: 12),
                  ...provider.lockedAchievements.map(
                    (a) => _AchievementCard(achievement: a, isUnlocked: false),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, AchievementProvider provider) {
    final progress = provider.totalAchievements > 0
        ? provider.unlockedCount / provider.totalAchievements
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFB347),
            const Color(0xFFFFB347).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                '${provider.unlockedCount} / ${provider.totalAchievements}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% 達成',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFFFFB347).withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              isUnlocked ? achievement.emoji : '🔒',
              style: TextStyle(
                fontSize: 24,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.grey,
              ),
            ),
            if (isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                '${DateFormat('yyyy/M/d').format(achievement.unlockedAt!)} に獲得',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Color(0xFFFFB347))
            : null,
      ),
    );
  }
}
