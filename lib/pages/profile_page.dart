import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';
import 'package:metropulse/pages/auth_page.dart';
import 'package:metropulse/services/crowd_report_service.dart';
import 'package:metropulse/models/crowd_report_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userProfile = session.userProfile;
    final userId = session.authUser?.id;

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
            if (userId != null) ...[
              FutureBuilder<List<CrowdReportModel>>(
                future: CrowdReportService.getUserReports(userId, limit: 200),
                builder: (context, snapshot) {
                  final reports = snapshot.data ?? const <CrowdReportModel>[];
                  final reportsCount = reports.length;
                  final streak = _computeDailyStreak(reports);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(label: 'Reports', value: reportsCount.toString()),
                      _StatChip(label: 'Streak', value: '${streak}d'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
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

int _computeDailyStreak(List<CrowdReportModel> reports) {
  if (reports.isEmpty) return 0;
  final dates = reports
      .map((r) => DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));
  int streak = 0;
  DateTime current = DateTime.now();
  for (final d in dates) {
    final day = DateTime(current.year, current.month, current.day).subtract(Duration(days: streak));
    if (d == day) {
      streak++;
    } else if (d.isBefore(day)) {
      break;
    }
  }
  return streak;
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
