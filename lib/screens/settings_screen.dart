import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, '外観'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'ダークモード',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(_getThemeModeLabel(themeProvider.themeMode)),
                    trailing: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'データ管理'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                icon: Icons.upload_outlined,
                title: 'データをエクスポート',
                subtitle: 'すべてのデータをJSON形式でコピー',
                onTap: () => _exportData(context),
              ),
              Divider(height: 1, color: isDarkMode ? Colors.grey.shade700 : null),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'すべてのデータを削除',
                subtitle: 'アプリのデータを完全に削除',
                textColor: Colors.red,
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'アプリ情報'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: const [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'バージョン',
                subtitle: '1.1.0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'オン';
      case ThemeMode.light:
        return 'オフ';
      case ThemeMode.system:
        return 'システム設定に従う';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final data = await DatabaseService.instance.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      await Clipboard.setData(ClipboardData(text: jsonString));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データをクリップボードにコピーしました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エクスポートに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データの削除'),
        content: const Text(
          'すべてのデータを削除しますか？\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await DatabaseService.instance.clearAllData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('すべてのデータを削除しました'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            )
          : null,
      onTap: onTap,
    );
  }
}
