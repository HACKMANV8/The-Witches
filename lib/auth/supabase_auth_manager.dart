import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:metropulse/auth/auth_manager.dart';
import 'package:metropulse/models/user_model.dart';
import 'package:metropulse/services/user_service.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager, AnonymousSignInManager {
  @override
  Future<User?> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        return response.user;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  @override
  Future<User?> createAccountWithEmail(BuildContext context, String email, String password) async {
    try {
      final response = await SupabaseConfig.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please check your email for verification.')),
          );
        }
        return response.user;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  @override
  Future<User?> signInAnonymously(BuildContext context) async {
    try {
      final response = await SupabaseConfig.auth.signInAnonymously();
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        return response.user;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anonymous sign in failed: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  @override
  Future signOut() async {
    await SupabaseConfig.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        await UserService.deleteUser(user.id);
        await SupabaseConfig.client.rpc('delete_user');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future updateEmail({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update email: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future resetPassword({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _ensureUserRecord(User authUser) async {
    final existingUser = await UserService.getUserById(authUser.id);
    if (existingUser == null) {
      final now = DateTime.now();
      await UserService.createUser(
        UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          name: authUser.userMetadata?['name'] as String?,
          phone: authUser.phone,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}
