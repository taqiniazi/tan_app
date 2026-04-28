import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getAdminStats();
});

final pendingWithdrawalsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPendingWithdrawals();
});
