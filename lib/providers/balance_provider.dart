import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';

class BalanceNotifier extends StateNotifier<double> {
  final ApiService _apiService;
  Timer? _timer;

  BalanceNotifier(this._apiService) : super(0.0) {
    _startPoller();
  }

  void _startPoller() {
    // Initial fetch
    _fetch();
    
    // Refresh every 8 seconds (mid-range of 5-10s requirement)
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _fetch());
  }

  Future<void> _fetch() async {
    try {
      final newBalance = await _apiService.getBalance();
      state = newBalance;
    } catch (e) {
      // Keep existing state on error
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, double>((ref) {
  return BalanceNotifier(ref.watch(apiServiceProvider));
});
