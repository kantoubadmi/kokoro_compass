import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/happiness_provider.dart';
import '../models/happiness_record.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  late DateTime _currentMonth;
  Map<String, List<HappinessRecord>> _recordsByDate = {};

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _loadRecords() {
    final provider = context.read<HappinessProvider>();
    _recordsByDate = {};
    for (final record in provider.records) {
      final key = '${record.createdAt.year}-${record.createdAt.month}-${record.createdAt.day}';
      _recordsByDate.putIfAbsent(key, () => []);
      _recordsByDate[key]!.add(record);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  double? _getAverageScoreForDate(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    final records = _recordsByDate[key];
    if (records == null || records.isEmpty) return null;
    final sum = records.fold<int>(0, (prev, r) => prev + r.score);
    return sum / records.length;
  }

  Color _getMoodColor(double? score) {
    if (score == null) return Colors.grey.shade200;
    if (score >= 8) return const Color(0xFF4CAF50);
    if (score >= 6) return const Color(0xFF8BC34A);
    if (score >= 4) return const Color(0xFFFFC107);
    if (score >= 2) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getMoodEmoji(double? score) {
    if (score == null) return '';
    if (score >= 8) return '😊';
    if (score >= 6) return '🙂';
    if (score >= 4) return '😐';
    if (score >= 2) return '😔';
    return '😢';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('ムードカレンダー'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<HappinessProvider>(
        builder: (context, provider, child) {
          _loadRecords();

          return Column(
            children: [
              // Month navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '${_currentMonth.year}年${_currentMonth.month}月',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              // Weekday headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['月', '火', '水', '木', '金', '土', '日'].map((day) {
                    final isWeekend = day == '土' || day == '日';
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isWeekend ? Colors.red.shade300 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Calendar grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCalendarGrid(),
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '凡例',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem('😊', 'とても幸せ', const Color(0xFF4CAF50)),
                            _buildLegendItem('🙂', '幸せ', const Color(0xFF8BC34A)),
                            _buildLegendItem('😐', 'まあまあ', const Color(0xFFFFC107)),
                            _buildLegendItem('😔', '落ち込み', const Color(0xFFFF9800)),
                            _buildLegendItem('😢', 'つらい', const Color(0xFFF44336)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Monday = 1, Sunday = 7
    int startWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final score = _getAverageScoreForDate(date);
      final isToday = _isToday(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () => _showDayDetails(context, date, score),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getMoodColor(score),
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: score != null ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                if (score != null)
                  Text(
                    _getMoodEmoji(score),
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.9,
      children: dayWidgets,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _showDayDetails(BuildContext context, DateTime date, double? score) {
    final key = '${date.year}-${date.month}-${date.day}';
    final records = _recordsByDate[key] ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'この日の記録はありません',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...records.map((record) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getMoodColor(record.score.toDouble()).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${record.score}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getMoodColor(record.score.toDouble()),
                            ),
                          ),
                        ),
                      ),
                      title: Text(_getMoodEmoji(record.score.toDouble())),
                      subtitle: record.note != null ? Text(record.note!) : null,
                      trailing: Text(
                        '${record.createdAt.hour}:${record.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
