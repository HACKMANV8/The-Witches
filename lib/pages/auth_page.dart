import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';
import 'package:metropulse/auth/supabase_auth_manager.dart';
import 'package:metropulse/pages/create_account_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool createAccount = false;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authManager = SupabaseAuthManager();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = createAccount
        ? await authManager.createAccountWithEmail(context, emailController.text.trim(), passwordController.text)
        : await authManager.signInWithEmail(context, emailController.text.trim(), passwordController.text);

    setState(() => isLoading = false);

    if (user != null && mounted) {
      ref.read(sessionProvider.notifier).signIn(user);
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => isLoading = true);
    final user = await authManager.signInAnonymously(context);
    setState(() => isLoading = false);

    if (mounted) {
      ref.read(sessionProvider.notifier).continueAsGuest();
      Navigator.of(context).pop();
    }
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
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      obscureText: true,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleAuth(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleAuth,
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(createAccount ? 'Create Account' : 'Sign In'),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (!createAccount) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const CreateAccountPage()),
                                );
                              } else {
                                setState(() => createAccount = false);
                              }
                            },
                      child: Text(createAccount ? 'Have an account? Sign In' : 'Create an account'),
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: isLoading ? null : _handleGuestSignIn,
                      child: const Text('Continue as Guest'),
                    ),
                    const SizedBox(height: 8),
                    // OAuth sign-in: starts external browser flow. SessionController
                    // will pick up the authenticated user via onAuthStateChange.
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    await authManager.signInWithGoogle(context);
                                    setState(() => isLoading = false);
                                  },
                            icon: const Icon(Icons.login),
                            label: const Text('Sign in with Google'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    await authManager.signInWithGithub(context);
                                    setState(() => isLoading = false);
                                  },
                            icon: const Icon(Icons.code),
                            label: const Text('Sign in with GitHub'),
                          ),
                        ),
                      ],
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
