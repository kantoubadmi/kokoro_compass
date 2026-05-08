import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen>
    with TickerProviderStateMixin {
  String? _playingSound;
  int _remainingSeconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0.7;

  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 'rain',
      'name': '雨音',
      'emoji': '🌧️',
      'color': const Color(0xFF5C6BC0),
      'description': '穏やかな雨の音',
      'asset': 'sounds/rain.mp3',
    },
    {
      'id': 'ocean',
      'name': '波の音',
      'emoji': '🌊',
      'color': const Color(0xFF26A69A),
      'description': '海辺の波音',
      'asset': 'sounds/ocean.mp3',
    },
    {
      'id': 'forest',
      'name': '森林',
      'emoji': '🌲',
      'color': const Color(0xFF66BB6A),
      'description': '森の自然音',
      'asset': 'sounds/forest.mp3',
    },
    {
      'id': 'fire',
      'name': '焚き火',
      'emoji': '🔥',
      'color': const Color(0xFFFF7043),
      'description': '暖炉のぱちぱち音',
      'asset': 'sounds/fire.mp3',
    },
    {
      'id': 'birds',
      'name': '小鳥',
      'emoji': '🐦',
      'color': const Color(0xFF42A5F5),
      'description': '鳥のさえずり',
      'asset': 'sounds/birds.mp3',
    },
    {
      'id': 'wind',
      'name': '風',
      'emoji': '🍃',
      'color': const Color(0xFF78909C),
      'description': '穏やかな風',
      'asset': 'sounds/wind.mp3',
    },
    {
      'id': 'thunder',
      'name': '雷雨',
      'emoji': '⛈️',
      'color': const Color(0xFF7E57C2),
      'description': '遠くの雷',
      'asset': 'sounds/thunder.mp3',
    },
    {
      'id': 'stream',
      'name': '小川',
      'emoji': '💧',
      'color': const Color(0xFF29B6F6),
      'description': 'せせらぎの音',
      'asset': 'sounds/stream.mp3',
    },
    {
      'id': 'night',
      'name': '夜の森',
      'emoji': '🌙',
      'color': const Color(0xFF3F51B5),
      'description': '虫の声と夜風',
      'asset': 'sounds/night.mp3',
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
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundId, String assetPath) async {
    if (_playingSound == soundId) {
      await _stopSound();
      return;
    }

    try {
      // Stop any existing playback before starting new sound
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource(assetPath));

      setState(() {
        _playingSound = soundId;
        _remainingSeconds = _selectedDuration * 60;
      });

      _pulseController.repeat(reverse: true);

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _stopSound();
          }
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('再生エラー: $e')),
        );
      }
    }
  }

  Future<void> _stopSound() async {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _playingSound = null;
        _remainingSeconds = 0;
      });
    }
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    try {
      await _audioPlayer.setVolume(value);
    } catch (_) {}
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _volume == 0
                          ? Icons.volume_off
                          : _volume < 0.5
                              ? Icons.volume_down
                              : Icons.volume_up,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        onChanged: _setVolume,
                        min: 0,
                        max: 1,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(_volume * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
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
                  onTap: () => _playSound(
                    sound['id'] as String,
                    sound['asset'] as String,
                  ),
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
    final totalSeconds = _selectedDuration * 60;

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
                      currentSound['emoji'] as String,
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
                      currentSound['name'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '残り ${_formatTime(_remainingSeconds)}',
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
            value: totalSeconds == 0 ? 0 : _remainingSeconds / totalSeconds,
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
                sound['emoji'] as String,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                sound['name'] as String,
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
