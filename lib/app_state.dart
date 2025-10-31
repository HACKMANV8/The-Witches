import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:metropulse/supabase/supabase_config.dart';
import 'package:metropulse/models/user_model.dart';
import 'package:metropulse/services/user_service.dart';

class SessionState {
  final bool isFirstLaunch;
  final bool isAuthenticated;
  final bool isGuest;
  final User? authUser;
  final UserModel? userProfile;

  const SessionState({
    required this.isFirstLaunch,
    required this.isAuthenticated,
    required this.isGuest,
    this.authUser,
    this.userProfile,
  });

  SessionState copyWith({
    bool? isFirstLaunch,
    bool? isAuthenticated,
    bool? isGuest,
    User? authUser,
    UserModel? userProfile,
  }) =>
      SessionState(
        isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isGuest: isGuest ?? this.isGuest,
        authUser: authUser ?? this.authUser,
        userProfile: userProfile ?? this.userProfile,
      );
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    _initAuthListener();
    final currentUser = SupabaseConfig.auth.currentUser;
    return SessionState(
      isFirstLaunch: true,
      isAuthenticated: currentUser != null && !currentUser.isAnonymous,
      isGuest: currentUser?.isAnonymous ?? false,
      authUser: currentUser,
    );
  }

  void _initAuthListener() {
    SupabaseConfig.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: !user.isAnonymous,
          isGuest: user.isAnonymous,
          isFirstLaunch: false,
          authUser: user,
        );
        _loadUserProfile(user.id);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isGuest: false,
          authUser: null,
          userProfile: null,
        );
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    final profile = await UserService.getUserById(userId);
    state = state.copyWith(userProfile: profile);
  }

  void completeOnboarding() {
    state = state.copyWith(isFirstLaunch: false);
  }

  void signIn(User user) {
    state = state.copyWith(
      isAuthenticated: true,
      isGuest: false,
      isFirstLaunch: false,
      authUser: user,
    );
  }

  void continueAsGuest(User user) {
    state = state.copyWith(
      isAuthenticated: false,
      isGuest: true,
      isFirstLaunch: false,
      authUser: user,
    );
  }

  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
    state = state.copyWith(
      isAuthenticated: false,
      isGuest: false,
      authUser: null,
      userProfile: null,
    );
  }

  Future<void> updateUserProfile(UserModel updatedProfile) async {
    final updated = await UserService.updateUser(updatedProfile);
    state = state.copyWith(userProfile: updated);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
