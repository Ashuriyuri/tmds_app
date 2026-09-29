import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool compactCards = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.paper,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.ink),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    ),
    drawer: const TmdsDrawer(currentRoute: 'Settings'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: notifications,
                onChanged: (value) => setState(() => notifications = value),
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.burgundy,
                ),
                title: const Text('Notifications'),
                subtitle: const Text('Receive reminders for upcoming services'),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: compactCards,
                onChanged: (value) => setState(() => compactCards = value),
                secondary: const Icon(
                  Icons.view_compact_outlined,
                  color: AppColors.burgundy,
                ),
                title: const Text('Compact lists'),
                subtitle: const Text('Use smaller rows when viewing records'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.burgundy),
            title: Text('About TMDS'),
            subtitle: Text('Detailing Management System\nVersion 1.0.0'),
          ),
        ),
      ],
    ),
  );
}
