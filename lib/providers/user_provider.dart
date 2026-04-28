import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  void setUser(UserModel user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

final userStateProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
