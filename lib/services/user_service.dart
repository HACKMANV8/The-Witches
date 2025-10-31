import 'package:metropulse/models/user_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class UserService {
  static bool _createUserWarned = false;
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final data = await SupabaseService.selectSingle('users', filters: {'id': userId});
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel> createUser(UserModel user) async {
    try {
      final data = await SupabaseService.insert('users', user.toJson());
      return UserModel.fromJson(data.first);
    } catch (e) {
      // If the users table is missing or insert fails (e.g., schema not present),
      // log and gracefully return the provided user object so sign-in flow can continue.
      // This avoids fatal errors when the Supabase project hasn't created the
      // application 'users' table yet.
      // In production you should create the `users` table in Supabase or handle
      // this error more explicitly.
      // Log once to avoid spamming logs when the users table is missing.
      if (!_createUserWarned) {
        // ignore: avoid_print
        debugPrint('UserService.createUser warning: could not insert users table: $e');
        _createUserWarned = true;
      }
      return user;
    }
  }

  static Future<UserModel> updateUser(UserModel user) async {
    final data = await SupabaseService.update(
      'users',
      user.toJson(),
      filters: {'id': user.id},
    );
    return UserModel.fromJson(data.first);
  }

  static Future<void> deleteUser(String userId) async {
    await SupabaseService.delete('users', filters: {'id': userId});
  }
}
