import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('History — Coming Soon', style: AppTextStyles.levelLabel),
      ),
    );
  }
}
