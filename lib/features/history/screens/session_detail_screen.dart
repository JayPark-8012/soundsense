import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: Center(
        child: Text('Session $sessionId — Coming Soon', style: AppTextStyles.levelLabel),
      ),
    );
  }
}
