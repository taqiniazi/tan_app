import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tan_network/models/user_model.dart';
import 'package:tan_network/models/withdrawal_model.dart';
import 'package:tan_network/core/navigation.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  static const String _lastActivityKey = 'last_activity';
  static const int _inactivityTimeoutHours = 48;
  static const String _baseUrl = 'https://5tansolution.com/tan_network/api';
  String get baseUrl => _baseUrl;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          
          if (token != null) {
            // Check Inactivity Timeout
            final lastActivityStr = await _storage.read(key: _lastActivityKey);
            if (lastActivityStr != null) {
              final lastActivity = DateTime.parse(lastActivityStr);
              final difference = DateTime.now().difference(lastActivity);
              
              if (difference.inHours >= _inactivityTimeoutHours) {
                await logout();
                navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
                return handler.reject(DioException(
                  requestOptions: options,
                  message: 'Session expired due to 48 hours of inactivity.',
                ));
              }
            }
            
            // Update last activity on every request
            await _storage.write(key: _lastActivityKey, value: DateTime.now().toIso8601String());
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await logout();
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            return handler.reject(e.copyWith(message: 'Session expired. Please login again.'));
          }
          
          String message = 'An error occurred';
          if (e.response?.data != null) {
            if (e.response?.data is Map) {
              message = e.response?.data['message'] ?? e.response?.data['error'] ?? message;
            }
          }
          return handler.next(e.copyWith(message: message));
        },
      ),
    );
  }

  // --- AUTH METHODS ---

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;

    // Check Inactivity Timeout
    final lastActivityStr = await _storage.read(key: _lastActivityKey);
    if (lastActivityStr != null) {
      final lastActivity = DateTime.parse(lastActivityStr);
      final difference = DateTime.now().difference(lastActivity);
      if (difference.inHours >= _inactivityTimeoutHours) {
        await logout();
        return false;
      }
    }
    return true;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email, 
        'password': password
      });
      
      if (response.data is! Map) {
        throw 'Unexpected response from server. Check if the API is deployed correctly.';
      }
      
      final token = response.data['token'];
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _lastActivityKey, value: DateTime.now().toIso8601String());
      
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map 
          ? (e.response?.data['message'] ?? e.response?.data['error']) 
          : (e.response?.data?.toString() ?? e.message ?? 'Login failed');
      throw errorMsg.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> signup(String name, String email, String password, String? referralCode, String? country, String? city) async {
    try {
      final response = await _dio.post('/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'country': country,
        'city': city,
        'referredBy': referralCode,
      });
      
      final token = response.data['token'];
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _lastActivityKey, value: DateTime.now().toIso8601String());
      
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Signup failed';
      throw errorMsg;
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      await _dio.post('/update-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Failed to update password';
      throw errorMsg;
    }
  }

  Future<String> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/update-profile-image', data: formData);
      return response.data['imageUrl'];
    } on DioException catch (e) {
      final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Failed to upload image';
      throw errorMsg;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.message ?? 'Failed to fetch profile';
    }
  }

  Future<List<Map<String, dynamic>>> getActivity() async {
    try {
      final response = await _dio.get('/activity');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw e.message ?? 'Failed to fetch activity';
    }
  }

  // --- MINING METHODS ---

  Future<Map<String, dynamic>> getReferrals() async {
    try {
      final response = await _dio.get('/referrals');
      return response.data;
    } catch (e) {
      return {'referrals': []};
    }
  }

  Future<void> startMining() async {
    try {
      await _dio.post('/start-mining');
    } on DioException catch (e) {
      throw e.message ?? 'Could not start mining';
    }
  }

  Future<Map<String, dynamic>> getMiningStatus() async {
    try {
      final response = await _dio.get('/mining-status');
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Could not fetch status';
    }
  }

  Future<void> claimReward() async {
    try {
      await _dio.post('/claim-reward');
    } on DioException catch (e) {
      throw e.message ?? 'Could not claim reward';
    }
  }

  // --- BALANCE & WITHDRAWAL METHODS ---

  Future<double> getBalance() async {
    try {
      final response = await _dio.get('/balance');
      return (response.data['balance'] as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> withdraw(double amount, String address, String network) async {
    try {
      await _dio.post('/withdraw', data: {
        'amount': amount,
        'address': address,
        'network': network,
      });
    } on DioException catch (e) {
      throw e.message ?? 'Withdrawal failed';
    }
  }

  Future<List<WithdrawalModel>> getWithdrawals() async {
    try {
      final response = await _dio.get('/withdrawals');
      final List data = response.data;
      return data.map((json) => WithdrawalModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getConfig() async {
    try {
      final response = await _dio.get('/config');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<void> verifyPayment(String txHash, String network) async {
    try {
      await _dio.post('/verify-payment', data: {
        'txHash': txHash,
        'network': network,
      });
    } on DioException catch (e) {
      throw e.message ?? 'Verification failed';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      final List data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _lastActivityKey);
  }
}
