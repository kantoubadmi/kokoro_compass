import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sleep_provider.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('睡眠トラッカー'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<SleepProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Stats card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF5C6BC0),
                      const Color(0xFF5C6BC0).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context,
                      '平均睡眠時間',
                      '${provider.averageHours.toStringAsFixed(1)}時間',
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildStatColumn(
                      context,
                      '平均品質',
                      _getQualityEmoji(provider.averageQuality),
                    ),
                  ],
                ),
              ),

              // Records list
              Expanded(
                child: provider.records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bedtime_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '睡眠記録がまだありません',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.records.length,
                        itemBuilder: (context, index) {
                          final record = provider.records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onLongPress: () =>
                                  _confirmDelete(context, record.id ?? 0),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getQualityColor(
                                                    record.quality)
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getQualityEmojiSingle(
                                                  record.quality),
                                              style: const TextStyle(
                                                  fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.durationString,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDate(record.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              i < record.quality
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 16,
                                              color: i < record.quality
                                                  ? Colors.amber
                                                  : Colors.grey.shade300,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    if (record.note != null &&
                                        record.note!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 60,
                                        ),
                                        child: Text(
                                          record.note!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.75),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('記録する'),
        backgroundColor: const Color(0xFF5C6BC0),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getQualityEmoji(double quality) {
    if (quality >= 4.5) return '😴 最高';
    if (quality >= 3.5) return '😊 良い';
    if (quality >= 2.5) return '😐 普通';
    if (quality >= 1.5) return '😔 悪い';
    return '😫 最悪';
  }

  String _getQualityEmojiSingle(int quality) {
    switch (quality) {
      case 5:
        return '😴';
      case 4:
        return '😊';
      case 3:
        return '😐';
      case 2:
        return '😔';
      default:
        return '😫';
    }
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    // Use Japanese locale, fall back to ISO format if locale not initialized
    try {
      return DateFormat('M月d日 (E)', 'ja').format(date);
    } catch (_) {
      return DateFormat('M/d').format(date);
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この睡眠記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SleepProvider>().deleteRecord(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記録を削除しました')),
        );
      }
    }
  }

  Future<void> _showAddDialog(BuildContext context) async {
    int selectedQuality = 3;
    int selectedHours = 7;
    int selectedMinutes = 0;
    final noteController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('睡眠を記録'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '睡眠時間',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedHours,
                        decoration: const InputDecoration(
                          labelText: '時間',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(24, (i) => i).map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Text('$h'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedHours = value ?? 7);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMinutes,
                        decoration: const InputDecoration(
                          labelText: '分',
                          border: OutlineInputBorder(),
                        ),
                        items: [0, 15, 30, 45].map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text('$m'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedMinutes = value ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '睡眠の質',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (i) {
                    final quality = i + 1;
                    final isSelected = selectedQuality == quality;
                    return GestureDetector(
                      onTap: () => setState(() => selectedQuality = quality),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getQualityColor(quality)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(
                                  color: _getQualityColor(quality),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _getQualityEmojiSingle(quality),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'メモ (任意)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  maxLength: 100,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('記録'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      try {
        await context.read<SleepProvider>().addRecord(
              selectedQuality,
              selectedHours,
              selectedMinutes,
              note: noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim(),
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('睡眠を記録しました')),
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
  }
}
