import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';
import 'package:metropulse/pages/auth_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userProfile = session.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (session.isAuthenticated) ...[
            const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                userProfile?.name ?? userProfile?.email ?? 'Metro Commuter',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (userProfile?.email != null && userProfile?.name != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  userProfile!.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ] else if (session.isGuest) ...[
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.person_outline, size: 40)),
            const SizedBox(height: 8),
            const Center(child: Text('Guest Mode', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthPage())),
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.person_outline, size: 40)),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthPage())),
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SwitchListTile(
            value: userProfile?.notificationsEnabled ?? true,
            onChanged: (value) {
              if (userProfile != null) {
                ref.read(sessionProvider.notifier).updateUserProfile(
                      userProfile.copyWith(notificationsEnabled: value, updatedAt: DateTime.now()),
                    );
              }
            },
            title: const Text('Push notifications'),
          ),
          SwitchListTile(
            value: userProfile?.anonymousReportingEnabled ?? true,
            onChanged: (value) {
              if (userProfile != null) {
                ref.read(sessionProvider.notifier).updateUserProfile(
                      userProfile.copyWith(anonymousReportingEnabled: value, updatedAt: DateTime.now()),
                    );
              }
            },
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
