import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';

final activityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getActivity();
});
