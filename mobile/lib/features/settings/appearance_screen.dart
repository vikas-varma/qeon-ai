import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            const SectionTitle('Theme'),
            Row(
              children: [
                _ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                  selected: mode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.light),
                ),
                const SizedBox(width: 10),
                _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  selected: mode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.dark),
                ),
                const SizedBox(width: 10),
                _ThemeOption(
                  label: 'System',
                  icon: Icons.devices_rounded,
                  selected: mode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionTitle('Preview'),
            const QeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good afternoon, Vikas',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10),
                  Text('Here’s your productivity plan for today.'),
                  SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: .72,
                    minHeight: 8,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Accent color'),
            const QeonCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ColorDot(color: AppColors.primary, selected: true),
                  _ColorDot(color: Color(0xFF2F6BFF)),
                  _ColorDot(color: Color(0xFF12B89A)),
                  _ColorDot(color: Color(0xFFFFA31A)),
                  _ColorDot(color: Color(0xFFFF4E86)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const QeonCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.text_fields_rounded,
                    title: 'Font',
                    subtitle: 'Inter — clean and readable',
                  ),
                  Divider(),
                  SettingsTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat style',
                    subtitle: 'Comfortable spacing',
                  ),
                  Divider(),
                  SettingsTile(
                    icon: Icons.motion_photos_off_outlined,
                    title: 'Reduce motion',
                    subtitle: 'Minimize animation effects',
                    trailing: Switch(value: false, onChanged: null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.text),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.selected = false});
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
