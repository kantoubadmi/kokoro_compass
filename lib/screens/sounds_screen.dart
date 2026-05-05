import 'package:flutter/material.dart';
import 'dart:async';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen>
    with TickerProviderStateMixin {
  String? _playingSound;
  int _remainingMinutes = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 'rain',
      'name': '雨音',
      'emoji': '🌧️',
      'color': const Color(0xFF5C6BC0),
      'description': '穏やかな雨の音',
    },
    {
      'id': 'ocean',
      'name': '波の音',
      'emoji': '🌊',
      'color': const Color(0xFF26A69A),
      'description': '海辺の波音',
    },
    {
      'id': 'forest',
      'name': '森林',
      'emoji': '🌲',
      'color': const Color(0xFF66BB6A),
      'description': '森の自然音',
    },
    {
      'id': 'fire',
      'name': '焚き火',
      'emoji': '🔥',
      'color': const Color(0xFFFF7043),
      'description': '暖炉のぱちぱち音',
    },
    {
      'id': 'birds',
      'name': '小鳥',
      'emoji': '🐦',
      'color': const Color(0xFF42A5F5),
      'description': '鳥のさえずり',
    },
    {
      'id': 'wind',
      'name': '風',
      'emoji': '🍃',
      'color': const Color(0xFF78909C),
      'description': '穏やかな風',
    },
    {
      'id': 'thunder',
      'name': '雷雨',
      'emoji': '⛈️',
      'color': const Color(0xFF7E57C2),
      'description': '遠くの雷',
    },
    {
      'id': 'stream',
      'name': '小川',
      'emoji': '💧',
      'color': const Color(0xFF29B6F6),
      'description': 'せせらぎの音',
    },
    {
      'id': 'night',
      'name': '夜の森',
      'emoji': '🌙',
      'color': const Color(0xFF3F51B5),
      'description': '虫の声と夜風',
    },
  ];

  final List<int> _durations = [5, 10, 15, 30, 60];
  int _selectedDuration = 15;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _playSound(String soundId) {
    if (_playingSound == soundId) {
      _stopSound();
      return;
    }

    setState(() {
      _playingSound = soundId;
      _remainingMinutes = _selectedDuration;
    });

    _pulseController.repeat(reverse: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _remainingMinutes--;
        if (_remainingMinutes <= 0) {
          _stopSound();
        }
      });
    });
  }

  void _stopSound() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _playingSound = null;
      _remainingMinutes = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('リラクゼーション'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          // Now playing section
          if (_playingSound != null) _buildNowPlaying(isDark),

          // Duration selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '再生時間',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _durations.map((duration) {
                      final isSelected = _selectedDuration == duration;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$duration分'),
                          selected: isSelected,
                          onSelected: _playingSound == null
                              ? (selected) {
                                  setState(() => _selectedDuration = duration);
                                }
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Sounds grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final sound = _sounds[index];
                final isPlaying = _playingSound == sound['id'];
                return _SoundCard(
                  sound: sound,
                  isPlaying: isPlaying,
                  onTap: () => _playSound(sound['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(bool isDark) {
    final currentSound = _sounds.firstWhere(
      (s) => s['id'] == _playingSound,
      orElse: () => _sounds.first,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (currentSound['color'] as Color),
            (currentSound['color'] as Color).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      currentSound['emoji'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSound['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '残り $_remainingMinutes 分',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _stopSound,
                icon: const Icon(Icons.stop_circle, size: 48),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _remainingMinutes / _selectedDuration,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  final Map<String, dynamic> sound;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SoundCard({
    required this.sound,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = sound['color'] as Color;

    return Card(
      color: isPlaying ? color : color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sound['emoji'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                sound['name'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPlaying ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
              ),
              if (isPlaying)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.volume_up,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
