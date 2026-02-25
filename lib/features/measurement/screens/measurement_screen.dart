import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Measurement — Coming Soon', style: AppTextStyles.levelLabel),
      ),
    );
  }
}
