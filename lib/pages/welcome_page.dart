import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';
import 'package:metropulse/pages/shell/home_shell.dart';
import 'package:metropulse/theme.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            decoration: const BoxDecoration(gradient: MPDecorations.purpleHeaderGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🚇', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text('Reclaim Your Commute',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text('Powering Bengaluru\'s Metro with People Data',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text('Enable Location Access',
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll show nearby stations and live crowd levels. You can skip and enable later.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Placeholder: location request. Continue to app for now.
                                ref.read(sessionProvider.notifier).completeOnboarding();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const HomeShell()),
                                );
                              },
                              child: const Text('📍 Enable Location Access'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref.read(sessionProvider.notifier).completeOnboarding();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const HomeShell()),
                              );
                            },
                            child: const Text('Skip for Now'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We respect your privacy. Location is only used while the app is in use.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
