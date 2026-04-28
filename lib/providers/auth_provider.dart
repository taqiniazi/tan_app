import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/models/user_model.dart';
import 'package:tan_network/services/api_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signup(String name, String email, String password, String? referralCode, String? country, String? city) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.signup(name, email, password, referralCode, country, city);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchProfile() async {
    try {
      final user = await _api.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      // Don't set error state for background refresh unless necessary
    }
  }

  Future<void> checkAuth() async {
    if (await _api.isAuthenticated()) {
      await fetchProfile();
    }
  }

  void logout() {
    _api.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});
