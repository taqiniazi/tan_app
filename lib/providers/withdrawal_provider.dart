import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/models/withdrawal_model.dart';
import 'package:tan_network/services/api_service.dart';

final withdrawalHistoryProvider = FutureProvider<List<WithdrawalModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getWithdrawals();
});

class WithdrawalState {
  final bool isLoading;
  final String? error;
  final bool success;

  WithdrawalState({this.isLoading = false, this.error, this.success = false});

  WithdrawalState copyWith({bool? isLoading, String? error, bool? success}) {
    return WithdrawalState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class WithdrawalNotifier extends StateNotifier<WithdrawalState> {
  final ApiService _api;

  WithdrawalNotifier(this._api) : super(WithdrawalState());

  Future<void> submit(double amount, String address, String network) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _api.withdraw(amount, address, network);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final withdrawalProvider = StateNotifierProvider<WithdrawalNotifier, WithdrawalState>((ref) {
  return WithdrawalNotifier(ref.watch(apiServiceProvider));
});
