import 'package:metropulse/models/user_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class UserService {
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final data = await SupabaseService.selectSingle('users', filters: {'id': userId});
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel> createUser(UserModel user) async {
    final data = await SupabaseService.insert('users', user.toJson());
    return UserModel.fromJson(data.first);
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
