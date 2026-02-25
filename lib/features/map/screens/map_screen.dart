import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Map — Coming Soon', style: AppTextStyles.levelLabel),
      ),
    );
  }
}
