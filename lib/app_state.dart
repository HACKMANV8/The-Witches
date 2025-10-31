import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final bool isFirstLaunch;
  final bool isAuthenticated;
  final bool isGuest;

  const SessionState({
    required this.isFirstLaunch,
    required this.isAuthenticated,
    required this.isGuest,
  });

  SessionState copyWith({bool? isFirstLaunch, bool? isAuthenticated, bool? isGuest}) {
    return SessionState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const SessionState(isFirstLaunch: true, isAuthenticated: false, isGuest: false);
  }

  void completeOnboarding() {
    state = state.copyWith(isFirstLaunch: false);
  }

  void signIn() {
    state = state.copyWith(isAuthenticated: true, isGuest: false, isFirstLaunch: false);
  }

  void continueAsGuest() {
    state = state.copyWith(isAuthenticated: false, isGuest: true, isFirstLaunch: false);
  }

  void signOut() {
    state = state.copyWith(isAuthenticated: false, isGuest: false);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
