// Authentication Manager - Base interface for auth implementations
//
// This abstract class and mixins define the contract for authentication systems.
// Implement this with concrete classes for Firebase, Supabase, or local auth.
//
// Usage:
// 1. Create a concrete class extending AuthManager
// 2. Mix in the required authentication provider mixins
// 3. Implement all abstract methods with your auth provider logic

// No UI imports here; AuthManager is UI-agnostic.
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Core authentication operations that all auth implementations must provide
abstract class AuthManager {
  Future signOut();
  Future deleteUser();
  Future updateEmail({required String email});
  Future resetPassword({required String email});
}

// Email/password authentication mixin
mixin EmailSignInManager on AuthManager {
  Future<supabase.User?> signInWithEmail(
    String email,
    String password,
  );

  Future<supabase.User?> createAccountWithEmail(
    String email,
    String password,
  );
}

// Anonymous authentication for guest users
mixin AnonymousSignInManager on AuthManager {
  Future<supabase.User?> signInAnonymously();
}

// Apple Sign-In authentication (iOS/web)
mixin AppleSignInManager on AuthManager {
  Future<supabase.User?> signInWithApple();
}

// Google Sign-In authentication (all platforms)
mixin GoogleSignInManager on AuthManager {
  Future<supabase.User?> signInWithGoogle();
}

// JWT token authentication for custom backends
mixin JwtSignInManager on AuthManager {
  Future<supabase.User?> signInWithJwtToken(
    String jwtToken,
  );
}

// Phone number authentication with SMS verification
mixin PhoneSignInManager on AuthManager {
  Future beginPhoneAuth({
    required String phoneNumber,
    required void Function() onCodeSent,
  });

  Future verifySmsCode({
    required String smsCode,
  });
}

// Facebook Sign-In authentication
mixin FacebookSignInManager on AuthManager {
  Future<supabase.User?> signInWithFacebook();
}

// Microsoft Sign-In authentication (Azure AD)
mixin MicrosoftSignInManager on AuthManager {
  Future<supabase.User?> signInWithMicrosoft(
    List<String> scopes,
    String tenantId,
  );
}

// GitHub Sign-In authentication (OAuth)
mixin GithubSignInManager on AuthManager {
  Future<supabase.User?> signInWithGithub();
}
