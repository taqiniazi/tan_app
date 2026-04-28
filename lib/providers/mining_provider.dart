import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiningState {
  final bool isMining;
  final DateTime? lastActivation;
  final Duration remainingTime;
  final double miningRate;

  MiningState({
    this.isMining = false,
    this.lastActivation,
    this.remainingTime = Duration.zero,
    this.miningRate = 0.1,
  });

  MiningState copyWith({
    bool? isMining,
    DateTime? lastActivation,
    Duration? remainingTime,
    double? miningRate,
  }) {
    return MiningState(
      isMining: isMining ?? this.isMining,
      lastActivation: lastActivation ?? this.lastActivation,
      remainingTime: remainingTime ?? this.remainingTime,
      miningRate: miningRate ?? this.miningRate,
    );
  }
}

class MiningNotifier extends StateNotifier<MiningState> {
  Timer? _timer;
  static const String _lastActivationKey = 'last_mining_activation';
  static const Duration _miningDuration = Duration(hours: 24);

  MiningNotifier() : super(MiningState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString(_lastActivationKey);
    
    if (lastTimeStr != null) {
      final lastTime = DateTime.parse(lastTimeStr);
      final now = DateTime.now();
      final difference = now.difference(lastTime);

      if (difference < _miningDuration) {
        state = state.copyWith(
          isMining: true,
          lastActivation: lastTime,
          remainingTime: _miningDuration - difference,
        );
        _startCountdown();
      }
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
        state = state.copyWith(isMining: false, remainingTime: Duration.zero);
        timer.cancel();
      } else {
        state = state.copyWith(remainingTime: remaining);
      }
    });
  }

  Future<void> startMining() async {
    if (state.isMining) return;

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivationKey, now.toIso8601String());

    state = state.copyWith(
      isMining: true,
      lastActivation: now,
      remainingTime: _miningDuration,
    );
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final miningProvider = StateNotifierProvider<MiningNotifier, MiningState>((ref) {
  return MiningNotifier();
});
