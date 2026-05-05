import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/happiness_provider.dart';
import '../providers/gratitude_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/sleep_provider.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('週間レポート'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildHappinessReport(context),
            const SizedBox(height: 16),
            _buildGratitudeReport(context),
            const SizedBox(height: 16),
            _buildMeditationReport(context),
            const SizedBox(height: 16),
            _buildSleepReport(context),
            const SizedBox(height: 24),
            _buildWeeklySummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Container(
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
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '今週のあなたの記録',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHappinessReport(BuildContext context) {
    return Consumer<HappinessProvider>(
      builder: (context, provider, child) {
        final weekRecords = _getWeeklyRecords(
          provider.records.map((r) => r.createdAt).toList(),
        );
        final weekScores = provider.records
            .where((r) => _isThisWeek(r.createdAt))
            .map((r) => r.score)
            .toList();

        final avgScore = weekScores.isEmpty
            ? 0.0
            : weekScores.reduce((a, b) => a + b) / weekScores.length;

        return _ReportCard(
          title: '幸福度',
          emoji: _getHappinessEmoji(avgScore),
          color: const Color(0xFFD4A5A5),
          stats: [
            _StatItem(label: '記録回数', value: '${weekRecords}回'),
            _StatItem(label: '平均スコア', value: avgScore.toStringAsFixed(1)),
          ],
          message: _getHappinessMessage(avgScore, weekRecords),
        );
      },
    );
  }

  Widget _buildGratitudeReport(BuildContext context) {
    return Consumer<GratitudeProvider>(
      builder: (context, provider, child) {
        final weekCount = provider.entries
            .where((e) => _isThisWeek(e.createdAt))
            .length;

        return _ReportCard(
          title: '感謝日記',
          emoji: weekCount >= 7 ? '🌟' : weekCount >= 3 ? '✨' : '🌱',
          color: const Color(0xFF7B9E89),
          stats: [
            _StatItem(label: '記録回数', value: '${weekCount}回'),
            _StatItem(label: '目標達成率', value: '${((weekCount / 7) * 100).clamp(0, 100).toInt()}%'),
          ],
          message: _getGratitudeMessage(weekCount),
        );
      },
    );
  }

  Widget _buildMeditationReport(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, provider, child) {
        final weekSessions = provider.sessions
            .where((s) => _isThisWeek(DateTime.parse(s['created_at'])))
            .toList();

        final totalMinutes = weekSessions.fold<int>(
          0,
          (prev, s) => prev + ((s['duration'] as int?) ?? 0),
        ) ~/ 60;

        return _ReportCard(
          title: '瞑想',
          emoji: totalMinutes >= 30 ? '🧘' : totalMinutes > 0 ? '🕯️' : '💭',
          color: const Color(0xFFA8C5B0),
          stats: [
            _StatItem(label: 'セッション数', value: '${weekSessions.length}回'),
            _StatItem(label: '合計時間', value: '$totalMinutes分'),
          ],
          message: _getMeditationMessage(weekSessions.length, totalMinutes),
        );
      },
    );
  }

  Widget _buildSleepReport(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final weekRecords = provider.records
            .where((r) => _isThisWeek(r.createdAt))
            .toList();

        final avgHours = weekRecords.isEmpty
            ? 0.0
            : weekRecords.fold<int>(0, (prev, r) => prev + r.totalMinutes) /
                weekRecords.length /
                60;

        final avgQuality = weekRecords.isEmpty
            ? 0.0
            : weekRecords.fold<int>(0, (prev, r) => prev + r.quality) /
                weekRecords.length;

        return _ReportCard(
          title: '睡眠',
          emoji: avgQuality >= 4 ? '😴' : avgQuality >= 3 ? '🌙' : '💤',
          color: const Color(0xFF5C6BC0),
          stats: [
            _StatItem(label: '記録日数', value: '${weekRecords.length}日'),
            _StatItem(label: '平均睡眠時間', value: '${avgHours.toStringAsFixed(1)}時間'),
          ],
          message: _getSleepMessage(avgHours, avgQuality),
        );
      },
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '今週のアドバイス',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getWeeklyAdvice(context),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeeklyAdvice(BuildContext context) {
    final happiness = context.read<HappinessProvider>();
    final gratitude = context.read<GratitudeProvider>();
    final meditation = context.read<MeditationProvider>();

    final happinessRecords = happiness.records.where((r) => _isThisWeek(r.createdAt)).length;
    final gratitudeRecords = gratitude.entries.where((e) => _isThisWeek(e.createdAt)).length;
    final meditationSessions = meditation.sessions.where((s) => _isThisWeek(DateTime.parse(s['created_at']))).length;

    List<String> advice = [];

    if (gratitudeRecords < 3) {
      advice.add('感謝日記を毎日書くことで、ポジティブな気持ちが増えます。');
    }
    if (meditationSessions < 2) {
      advice.add('週に数回の瞑想で、心の安定を取り戻せます。');
    }
    if (happinessRecords < 3) {
      advice.add('気分を定期的に記録すると、自分の感情パターンが見えてきます。');
    }

    if (advice.isEmpty) {
      return '素晴らしい1週間でした！この調子で心のケアを続けていきましょう。自分を大切にすることが、幸せへの第一歩です。';
    }

    return advice.join('\n');
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart.subtract(const Duration(days: 1)));
  }

  int _getWeeklyRecords(List<DateTime> dates) {
    return dates.where((d) => _isThisWeek(d)).length;
  }

  String _getHappinessEmoji(double score) {
    if (score >= 8) return '😊';
    if (score >= 6) return '🙂';
    if (score >= 4) return '😐';
    if (score >= 2) return '😔';
    if (score > 0) return '😢';
    return '📝';
  }

  String _getHappinessMessage(double avg, int count) {
    if (count == 0) return 'まだ記録がありません。気分を記録してみましょう。';
    if (avg >= 8) return '素晴らしい1週間でしたね！';
    if (avg >= 6) return '良い調子をキープしています！';
    if (avg >= 4) return '少し休息を取ることも大切です。';
    return '無理せず、自分のペースで進みましょう。';
  }

  String _getGratitudeMessage(int count) {
    if (count >= 7) return '毎日感謝を見つけられています！';
    if (count >= 5) return '素晴らしい習慣が身についています。';
    if (count >= 3) return '良いスタートです！継続を心がけましょう。';
    if (count >= 1) return '感謝の記録を始めましたね。';
    return '小さな幸せを見つけてみましょう。';
  }

  String _getMeditationMessage(int sessions, int minutes) {
    if (minutes >= 60) return '素晴らしい瞑想の習慣です！';
    if (minutes >= 30) return '心が落ち着いてきていますね。';
    if (sessions >= 1) return '瞑想を始めましたね。続けていきましょう。';
    return '心を落ち着ける時間を作ってみましょう。';
  }

  String _getSleepMessage(double hours, double quality) {
    if (hours == 0) return '睡眠の記録を始めてみましょう。';
    if (hours >= 7 && quality >= 4) return '理想的な睡眠が取れています！';
    if (hours >= 7) return '十分な睡眠時間が取れています。';
    if (hours >= 6) return 'もう少し睡眠時間を増やせるといいですね。';
    return '睡眠不足に注意しましょう。';
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final List<_StatItem> stats;
  final String message;

  const _ReportCard({
    required this.title,
    required this.emoji,
    required this.color,
    required this.stats,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: stats.map((stat) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem({required this.label, required this.value});
}
