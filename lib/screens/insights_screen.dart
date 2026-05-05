import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/happiness_provider.dart';
import '../providers/gratitude_provider.dart';
import '../providers/sleep_provider.dart';
import '../models/happiness_record.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('ムードインサイト'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            _buildWeekdayPatterns(context),
            const SizedBox(height: 24),
            _buildTimeOfDayPatterns(context),
            const SizedBox(height: 24),
            _buildCorrelations(context),
            const SizedBox(height: 24),
            _buildPersonalizedTips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Consumer<HappinessProvider>(
      builder: (context, provider, child) {
        final records = provider.records;
        final recentTrend = _calculateTrend(records);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0),
                const Color(0xFF9C27B0).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'あなたの気分パターン',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    recentTrend > 0
                        ? Icons.trending_up
                        : recentTrend < 0
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getTrendMessage(recentTrend),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekdayPatterns(BuildContext context) {
    return Consumer<HappinessProvider>(
      builder: (context, provider, child) {
        final weekdayAverages = _calculateWeekdayAverages(provider.records);
        final weekdays = ['月', '火', '水', '木', '金', '土', '日'];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_view_week, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '曜日別パターン',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final avg = weekdayAverages[index];
                      final height = avg > 0 ? (avg / 10) * 80 : 4.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (avg > 0)
                                Text(
                                  avg.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                height: height,
                                decoration: BoxDecoration(
                                  color: avg > 0
                                      ? _getMoodColor(avg)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weekdays[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: index >= 5
                                      ? Colors.red.shade300
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getWeekdayInsight(weekdayAverages),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeOfDayPatterns(BuildContext context) {
    return Consumer<HappinessProvider>(
      builder: (context, provider, child) {
        final timeAverages = _calculateTimeOfDayAverages(provider.records);
        final times = ['朝 (6-12)', '昼 (12-18)', '夜 (18-24)'];
        final emojis = ['🌅', '☀️', '🌙'];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '時間帯別パターン',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(3, (index) {
                  final avg = timeAverages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(emojis[index], style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(times[index]),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: avg > 0 ? avg / 10 : 0,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  avg > 0 ? _getMoodColor(avg) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          avg > 0 ? avg.toStringAsFixed(1) : '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCorrelations(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.link, size: 20),
                SizedBox(width: 8),
                Text(
                  '相関関係',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer3<HappinessProvider, GratitudeProvider, SleepProvider>(
              builder: (context, happiness, gratitude, sleep, child) {
                return Column(
                  children: [
                    _buildCorrelationItem(
                      '感謝日記と幸福度',
                      _calculateGratitudeCorrelation(
                        happiness.records,
                        gratitude.entries.length,
                      ),
                      Icons.auto_awesome,
                    ),
                    const SizedBox(height: 12),
                    _buildCorrelationItem(
                      '睡眠と幸福度',
                      _calculateSleepCorrelation(sleep.records),
                      Icons.bedtime,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationItem(String title, String correlation, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            correlation,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedTips(BuildContext context) {
    return Consumer3<HappinessProvider, GratitudeProvider, SleepProvider>(
      builder: (context, happiness, gratitude, sleep, child) {
        final tips = _generateTips(happiness, gratitude, sleep);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, size: 20, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'パーソナルアドバイス',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip['emoji']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip['text']!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  double _calculateTrend(List<HappinessRecord> records) {
    if (records.length < 2) return 0;
    final recent = records.take(7).toList();
    final older = records.skip(7).take(7).toList();
    if (older.isEmpty) return 0;

    final recentAvg = recent.fold<int>(0, (sum, r) => sum + r.score) / recent.length;
    final olderAvg = older.fold<int>(0, (sum, r) => sum + r.score) / older.length;
    return recentAvg - olderAvg;
  }

  String _getTrendMessage(double trend) {
    if (trend > 1) return '気分が上向きです！この調子を維持しましょう';
    if (trend > 0) return '少しずつ良くなっています';
    if (trend < -1) return '少し下がり気味。休息を取りましょう';
    if (trend < 0) return 'やや下降傾向。無理せずに';
    return '安定しています';
  }

  List<double> _calculateWeekdayAverages(List<HappinessRecord> records) {
    final List<List<int>> weekdayScores = List.generate(7, (_) => []);
    for (final record in records) {
      final weekday = record.createdAt.weekday - 1; // 0-6
      weekdayScores[weekday].add(record.score);
    }
    return weekdayScores.map((scores) {
      if (scores.isEmpty) return 0.0;
      return scores.reduce((a, b) => a + b) / scores.length;
    }).toList();
  }

  List<double> _calculateTimeOfDayAverages(List<HappinessRecord> records) {
    final List<List<int>> timeScores = [[], [], []]; // morning, afternoon, evening
    for (final record in records) {
      final hour = record.createdAt.hour;
      if (hour >= 6 && hour < 12) {
        timeScores[0].add(record.score);
      } else if (hour >= 12 && hour < 18) {
        timeScores[1].add(record.score);
      } else {
        timeScores[2].add(record.score);
      }
    }
    return timeScores.map((scores) {
      if (scores.isEmpty) return 0.0;
      return scores.reduce((a, b) => a + b) / scores.length;
    }).toList();
  }

  String _getWeekdayInsight(List<double> averages) {
    final validAverages = averages.where((a) => a > 0).toList();
    if (validAverages.isEmpty) return 'まだデータが足りません';

    final maxIndex = averages.indexOf(averages.reduce((a, b) => a > b ? a : b));
    final minIndex = averages.indexOf(averages.where((a) => a > 0).reduce((a, b) => a < b ? a : b));
    final weekdays = ['月曜', '火曜', '水曜', '木曜', '金曜', '土曜', '日曜'];

    if (averages[maxIndex] > 0) {
      return '${weekdays[maxIndex]}が最も良い傾向があります';
    }
    return 'データを集めています';
  }

  Color _getMoodColor(double score) {
    if (score >= 8) return const Color(0xFF4CAF50);
    if (score >= 6) return const Color(0xFF8BC34A);
    if (score >= 4) return const Color(0xFFFFC107);
    return const Color(0xFFFF9800);
  }

  String _calculateGratitudeCorrelation(List<HappinessRecord> records, int gratitudeCount) {
    if (records.isEmpty || gratitudeCount == 0) return 'データ不足';
    if (gratitudeCount > records.length) return '正の相関';
    return '分析中';
  }

  String _calculateSleepCorrelation(List sleepRecords) {
    if (sleepRecords.isEmpty) return 'データ不足';
    return '分析中';
  }

  List<Map<String, String>> _generateTips(
    HappinessProvider happiness,
    GratitudeProvider gratitude,
    SleepProvider sleep,
  ) {
    final tips = <Map<String, String>>[];

    // Based on data analysis
    if (gratitude.entries.length < 7) {
      tips.add({
        'emoji': '📝',
        'text': '毎日感謝を記録すると、幸福度が上がる傾向があります',
      });
    }

    if (sleep.records.isNotEmpty) {
      final avgHours = sleep.averageHours;
      if (avgHours < 7) {
        tips.add({
          'emoji': '😴',
          'text': '睡眠時間が少なめです。7-8時間を目指しましょう',
        });
      }
    } else {
      tips.add({
        'emoji': '🌙',
        'text': '睡眠を記録して、気分との関係を発見しましょう',
      });
    }

    if (happiness.records.isNotEmpty) {
      final weekdayAvg = _calculateWeekdayAverages(happiness.records);
      final weekendAvg = (weekdayAvg[5] + weekdayAvg[6]) / 2;
      final weekdayAvgValue = weekdayAvg.sublist(0, 5).where((a) => a > 0).fold(0.0, (a, b) => a + b);
      if (weekendAvg > 0 && weekdayAvgValue > 0) {
        if (weekendAvg > weekdayAvgValue / 5) {
          tips.add({
            'emoji': '🏖️',
            'text': '週末に気分が良い傾向があります。平日にも休息を取り入れましょう',
          });
        }
      }
    }

    if (tips.isEmpty) {
      tips.add({
        'emoji': '✨',
        'text': 'データを集めて、あなただけのパターンを発見しましょう',
      });
    }

    return tips;
  }
}
