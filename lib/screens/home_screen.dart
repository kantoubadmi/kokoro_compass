import 'package:flutter/material.dart';
import 'gratitude_screen.dart';
import 'meditation_screen.dart';
import 'happiness_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'breathing_screen.dart';
import 'mood_calendar_screen.dart';
import 'sleep_screen.dart';
import 'weekly_report_screen.dart';
import 'achievements_screen.dart';
import 'sounds_screen.dart';
import 'goals_screen.dart';
import 'prompts_screen.dart';
import 'insights_screen.dart';
import '../widgets/quick_mood_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getDailyAffirmation() {
    final affirmations = [
      '今日も素晴らしい一日になります',
      'あなたは十分に頑張っています',
      '自分を大切にすることを忘れずに',
      '小さな幸せに気づける心を持とう',
      '今この瞬間を大切に生きよう',
      '自分のペースで進めば大丈夫',
      '深呼吸して、心を落ち着けよう',
      'あなたの存在は誰かの支えになっている',
      '完璧でなくていい、前に進むことが大切',
      '今日できることに集中しよう',
      '笑顔は心の栄養です',
      '感謝の気持ちが幸せを呼ぶ',
      '自分を信じて、一歩ずつ前へ',
      '休むことも大切な時間です',
      'あなたは愛される価値がある',
    ];

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return affirmations[dayOfYear % affirmations.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'こころコンパス',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AchievementsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Affirmation Card
              _AffirmationCard(message: _getDailyAffirmation()),
              const SizedBox(height: 12),

              // Quick Mood Widget
              const QuickMoodWidget(),
              const SizedBox(height: 20),

              // Section: Record
              _buildSectionHeader(context, '記録する', Icons.edit_note),
              const SizedBox(height: 12),
              _buildFeatureRow(context, [
                _FeatureItem(
                  icon: Icons.auto_awesome,
                  title: '感謝日記',
                  color: const Color(0xFF7B9E89),
                  onTap: () => _navigateTo(context, const GratitudeScreen()),
                ),
                _FeatureItem(
                  icon: Icons.favorite,
                  title: '幸福度',
                  color: const Color(0xFFD4A5A5),
                  onTap: () => _navigateTo(context, const HappinessScreen()),
                ),
                _FeatureItem(
                  icon: Icons.bedtime,
                  title: '睡眠',
                  color: const Color(0xFF5C6BC0),
                  onTap: () => _navigateTo(context, const SleepScreen()),
                ),
                _FeatureItem(
                  icon: Icons.flag,
                  title: '今日の目標',
                  color: const Color(0xFFFFB347),
                  onTap: () => _navigateTo(context, const GoalsScreen()),
                ),
              ]),
              const SizedBox(height: 20),

              // Section: Relax
              _buildSectionHeader(context, 'リラックス', Icons.spa),
              const SizedBox(height: 12),
              _buildFeatureRow(context, [
                _FeatureItem(
                  icon: Icons.self_improvement,
                  title: '瞑想',
                  color: const Color(0xFFA8C5B0),
                  onTap: () => _navigateTo(context, const MeditationScreen()),
                ),
                _FeatureItem(
                  icon: Icons.air,
                  title: '呼吸法',
                  color: const Color(0xFF89B0AE),
                  onTap: () => _navigateTo(context, const BreathingScreen()),
                ),
                _FeatureItem(
                  icon: Icons.music_note,
                  title: 'サウンド',
                  color: const Color(0xFF7E57C2),
                  onTap: () => _navigateTo(context, const SoundsScreen()),
                ),
                _FeatureItem(
                  icon: Icons.edit_document,
                  title: 'プロンプト',
                  color: const Color(0xFF26A69A),
                  onTap: () => _navigateTo(context, const PromptsScreen()),
                ),
              ]),
              const SizedBox(height: 20),

              // Section: Analyze
              _buildSectionHeader(context, '振り返る', Icons.analytics),
              const SizedBox(height: 12),
              _buildFeatureRow(context, [
                _FeatureItem(
                  icon: Icons.calendar_month,
                  title: 'カレンダー',
                  color: const Color(0xFFE8A87C),
                  onTap: () => _navigateTo(context, const MoodCalendarScreen()),
                ),
                _FeatureItem(
                  icon: Icons.insights,
                  title: '統計',
                  color: const Color(0xFF9EADC5),
                  onTap: () => _navigateTo(context, const StatisticsScreen()),
                ),
                _FeatureItem(
                  icon: Icons.psychology,
                  title: 'インサイト',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _navigateTo(context, const InsightsScreen()),
                ),
                _FeatureItem(
                  icon: Icons.summarize,
                  title: '週間レポート',
                  color: const Color(0xFF78909C),
                  onTap: () => _navigateTo(context, const WeeklyReportScreen()),
                ),
              ]),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, List<_FeatureItem> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _FeatureCard(item: item),
          ),
        );
      }).toList(),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _AffirmationCard extends StatelessWidget {
  final String message;

  const _AffirmationCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B9E89),
            const Color(0xFF7B9E89).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B9E89).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;

  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color.withValues(alpha: 0.1),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 28,
                color: item.color,
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: item.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
