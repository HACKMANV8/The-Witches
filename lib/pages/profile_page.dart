import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (session.isAuthenticated) ...[
            const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 8),
            Center(child: Text('user@example.com', style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.person_outline, size: 40)),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Push notifications'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Anonymous reporting'),
          ),
          ListTile(
            title: const Text('Help & Feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          if (session.isAuthenticated || session.isGuest)
            ElevatedButton(
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
              child: const Text('Sign Out'),
            ),
        ],
      ),
    );
  }
}
