import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings — Coming Soon', style: AppTextStyles.levelLabel),
      ),
    );
  }
}
