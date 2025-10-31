import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool createAccount = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(createAccount ? 'Create Account' : 'Sign In', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(controller: emailController, decoration: const InputDecoration(hintText: 'Email')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Placeholder for auth via Supabase later
                          ref.read(sessionProvider.notifier).signIn();
                          Navigator.of(context).pop();
                        },
                        child: Text(createAccount ? 'Create Account' : 'Sign In'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => createAccount = !createAccount),
                      child: Text(createAccount ? 'Have an account? Sign In' : 'Create an account'),
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(sessionProvider.notifier).continueAsGuest();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
