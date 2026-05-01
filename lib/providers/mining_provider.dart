import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';

class MiningState {
  final bool isMining;
  final DateTime? lastActivation;
  final Duration remainingTime;
  final double miningRate;
  final bool canClaim;

  MiningState({
    this.isMining = false,
    this.lastActivation,
    this.remainingTime = Duration.zero,
    this.miningRate = 0.01,
    this.canClaim = false,
  });

  MiningState copyWith({
    bool? isMining,
    DateTime? lastActivation,
    Duration? remainingTime,
    double? miningRate,
    bool? canClaim,
  }) {
    return MiningState(
      isMining: isMining ?? this.isMining,
      lastActivation: lastActivation ?? this.lastActivation,
      remainingTime: remainingTime ?? this.remainingTime,
      miningRate: miningRate ?? this.miningRate,
      canClaim: canClaim ?? this.canClaim,
    );
  }
}

class MiningNotifier extends StateNotifier<MiningState> {
  final ApiService _apiService;
  Timer? _timer;
  static const Duration _miningDuration = Duration(hours: 24);

  MiningNotifier(this._apiService) : super(MiningState()) {
    syncWithBackend();
  }

  Future<void> syncWithBackend() async {
    try {
      final status = await _apiService.getMiningStatus();
      final bool isMining = status['isMining'] == true || status['isMining'] == 'true';
      final String? startTimeStr = status['startTime'];
      final double rate = double.tryParse(status['rate']?.toString() ?? '0.01') ?? 0.01;

      if (isMining && startTimeStr != null) {
        final startTime = DateTime.parse(startTimeStr);
        final now = DateTime.now();
        final difference = now.difference(startTime);

        if (difference < _miningDuration) {
          state = state.copyWith(
            isMining: true,
            lastActivation: startTime,
            remainingTime: _miningDuration - difference,
            miningRate: rate,
            canClaim: false,
          );
          _startCountdown();
        } else {
          // Session expired but not claimed in backend
          state = state.copyWith(
            isMining: false,
            remainingTime: Duration.zero,
            miningRate: rate,
            canClaim: true,
          );
        }
      } else {
        state = state.copyWith(
          isMining: false,
          remainingTime: Duration.zero,
          miningRate: rate,
          canClaim: false,
        );
      }
    } catch (e) {
      // Keep existing state or handle error
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.lastActivation == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = now.difference(state.lastActivation!);
      final remaining = _miningDuration - difference;

      if (remaining.isNegative) {
        state = state.copyWith(
          isMining: false,
          remainingTime: Duration.zero,
          canClaim: true,
        );
        timer.cancel();
      } else {
        state = state.copyWith(remainingTime: remaining);
      }
    });
  }

  Future<void> startMining() async {
    if (state.isMining || state.canClaim) return;

    try {
      await _apiService.startMining();
      await syncWithBackend();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> claimReward() async {
    try {
      await _apiService.claimReward();
      await syncWithBackend();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final miningProvider = StateNotifierProvider<MiningNotifier, MiningState>((
  ref,
) {
  return MiningNotifier(ref.watch(apiServiceProvider));
});
