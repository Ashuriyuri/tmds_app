import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Profile',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xffffe8e9),
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: AppColors.burgundy,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'admin@tmds.com',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const ListTile(
          leading: Icon(Icons.business_outlined, color: AppColors.burgundy),
          title: Text('Business'),
          subtitle: Text('Tony Marapao Car Detailing Services'),
        ),
        const ListTile(
          leading: Icon(
            Icons.verified_user_outlined,
            color: AppColors.burgundy,
          ),
          title: Text('Account type'),
          subtitle: Text('Administrator'),
        ),
      ],
    ),
  );
}
