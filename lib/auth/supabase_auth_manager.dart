import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:metropulse/auth/auth_manager.dart';
import 'package:metropulse/models/user_model.dart';
import 'package:metropulse/services/user_service.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager, AnonymousSignInManager {
  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        return response.user;
      }
      return null;
    } catch (e) {
      // Caller should handle UI notifications; return null to indicate failure.
      return null;
    }
  }

  @override
  Future<User?> createAccountWithEmail(String email, String password) async {
    try {
      final response = await SupabaseConfig.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        // Caller may show notifications on success
        return response.user;
      }
      return null;
    } catch (e) {
      // If the user already exists, attempt to sign in instead.
      final msg = e.toString().toLowerCase();
      if (msg.contains('already') || msg.contains('user') && msg.contains('exists')) {
        try {
          final signin = await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
          if (signin.user != null) {
            await _ensureUserRecord(signin.user!);
            return signin.user;
          }
        } catch (_) {}
      }
      // Caller should handle UI notifications; return null to indicate failure.
      return null;
    }
  }

  @override
  Future<User?> signInAnonymously() async {
    try {
      final response = await SupabaseConfig.auth.signInAnonymously();
      if (response.user != null) {
        await _ensureUserRecord(response.user!);
        return response.user;
      }
      return null;
    } catch (e) {
      // Caller should handle UI notifications; return null to indicate failure.
      return null;
    }
  }

  @override
  Future signOut() async {
    await SupabaseConfig.auth.signOut();
  }

  @override
  Future deleteUser() async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        await UserService.deleteUser(user.id);
        await SupabaseConfig.client.rpc('delete_user');
      }
    } catch (e) {
      // Caller should handle UI notifications; swallow error for best-effort.
    }
  }

  @override
  Future updateEmail({required String email}) async {
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: email));
      // Caller may notify user on success
    } catch (e) {
      // Caller should handle UI notifications; swallow error here.
    }
  }

  @override
  Future resetPassword({required String email}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      // Caller may notify user on success
    } catch (e) {
      // Caller should handle UI notifications; swallow error here.
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

  /// Start OAuth sign-in for the given provider. This will open the browser
  /// and rely on the `onAuthStateChange` listener in `SessionController` to
  /// pick up the authenticated user when the flow completes.
  Future<void> signInWithGoogle() async {
    try {
      // Construct the Supabase authorize URL and open it in the external browser.
      final callback = '${SupabaseConfig.supabaseUrl}/auth/v1/callback';
      final url = '${SupabaseConfig.supabaseUrl}/auth/v1/authorize?provider=google&redirect_to=${Uri.encodeComponent(callback)}';
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Caller should handle UI notifications; ignore here.
    }
  }

  Future<void> signInWithGithub() async {
    try {
      final callback = '${SupabaseConfig.supabaseUrl}/auth/v1/callback';
      final url = '${SupabaseConfig.supabaseUrl}/auth/v1/authorize?provider=github&redirect_to=${Uri.encodeComponent(callback)}';
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Caller should handle UI notifications; ignore here.
    }
  }
}
