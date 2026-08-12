import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserPhone = 'auth_user_phone';
  static const String _keyUserRole = 'auth_user_role';

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userJson = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        await saveUserSession(user);
        return user;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        final msg = e.toString().replaceAll('Exception: ', '');
        throw Exception(msg);
      }
      throw Exception('Failed to login: $e');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'role': role.toUpperCase(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final userJson = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        await saveUserSession(user);
        return user;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        final msg = e.toString().replaceAll('Exception: ', '');
        throw Exception(msg);
      }
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserPhone, user.phone);
    await prefs.setString(_keyUserRole, user.role);
  }

  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) {
      return null;
    }
    return UserModel(
      id: id,
      name: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      phone: prefs.getString(_keyUserPhone) ?? '',
      role: prefs.getString(_keyUserRole) ?? 'CUSTOMER',
    );
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserRole);
  }
}
