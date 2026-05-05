import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gratitude_provider.dart';

class PromptsScreen extends StatefulWidget {
  const PromptsScreen({super.key});

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _prompts = [
    // Gratitude
    {
      'category': 'gratitude',
      'emoji': '🙏',
      'prompt': '今日、感謝したいことは何ですか？',
      'hint': '小さなことでも構いません',
    },
    {
      'category': 'gratitude',
      'emoji': '💝',
      'prompt': '最近、誰かにしてもらって嬉しかったことは？',
      'hint': '思い出してみましょう',
    },
    {
      'category': 'gratitude',
      'emoji': '🌟',
      'prompt': '当たり前だけど、実は有り難いことは？',
      'hint': '日常の中の幸せ',
    },

    // Self-reflection
    {
      'category': 'reflection',
      'emoji': '🪞',
      'prompt': '今日の自分を一言で表すと？',
      'hint': '素直な気持ちで',
    },
    {
      'category': 'reflection',
      'emoji': '💭',
      'prompt': '最近、成長を感じたことは？',
      'hint': '小さな変化も成長です',
    },
    {
      'category': 'reflection',
      'emoji': '🌱',
      'prompt': '今の自分に必要なものは何ですか？',
      'hint': '心の声に耳を傾けて',
    },
    {
      'category': 'reflection',
      'emoji': '🔮',
      'prompt': '理想の1日はどんな1日ですか？',
      'hint': '具体的にイメージして',
    },

    // Emotions
    {
      'category': 'emotions',
      'emoji': '❤️',
      'prompt': '今、どんな気持ちですか？',
      'hint': '感情に名前をつけてみて',
    },
    {
      'category': 'emotions',
      'emoji': '😌',
      'prompt': '心が穏やかになる瞬間は？',
      'hint': 'リラックスできる時間',
    },
    {
      'category': 'emotions',
      'emoji': '🌈',
      'prompt': '最近、幸せを感じた瞬間は？',
      'hint': '思い出してみましょう',
    },

    // Goals
    {
      'category': 'goals',
      'emoji': '🎯',
      'prompt': '今週、達成したいことは？',
      'hint': '具体的な目標を',
    },
    {
      'category': 'goals',
      'emoji': '🚀',
      'prompt': '将来の自分へのメッセージ',
      'hint': '1年後の自分に向けて',
    },
    {
      'category': 'goals',
      'emoji': '💪',
      'prompt': '克服したい課題は何ですか？',
      'hint': '一歩ずつ前進',
    },

    // Mindfulness
    {
      'category': 'mindfulness',
      'emoji': '🧘',
      'prompt': '今、五感で感じていることは？',
      'hint': '見える、聞こえる、感じる...',
    },
    {
      'category': 'mindfulness',
      'emoji': '🍃',
      'prompt': '今この瞬間、大切にしたいことは？',
      'hint': '今に集中',
    },
    {
      'category': 'mindfulness',
      'emoji': '☀️',
      'prompt': '今日を良い1日にするには？',
      'hint': '自分でコントロールできること',
    },
  ];

  final Map<String, String> _categories = {
    'all': '全て',
    'gratitude': '感謝',
    'reflection': '振り返り',
    'emotions': '感情',
    'goals': '目標',
    'mindfulness': 'マインドフルネス',
  };

  List<Map<String, dynamic>> get _filteredPrompts {
    if (_selectedCategory == 'all') return _prompts;
    return _prompts.where((p) => p['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('ジャーナリング'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = entry.key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Prompts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _filteredPrompts[index];
                return _PromptCard(
                  prompt: prompt,
                  onTap: () => _showWriteDialog(context, prompt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWriteDialog(
    BuildContext context,
    Map<String, dynamic> prompt,
  ) async {
    final controller = TextEditingController();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  prompt['emoji'],
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prompt['prompt'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: prompt['hint'],
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 500,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('感謝日記に保存'),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.trim().isNotEmpty && context.mounted) {
      final entry = '${prompt['emoji']} ${prompt['prompt']}\n\n$result';
      try {
        await context.read<GratitudeProvider>().addEntry(entry);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('感謝日記に保存しました')),
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

class _PromptCard extends StatelessWidget {
  final Map<String, dynamic> prompt;
  final VoidCallback onTap;

  const _PromptCard({
    required this.prompt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    prompt['emoji'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt['prompt'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prompt['hint'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
