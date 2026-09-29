import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

class TmdsApp extends StatelessWidget {
  const TmdsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TMDS',
    theme: AppTheme.light,
    home: const LoginScreen(),
  );
}
