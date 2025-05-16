import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final String backendUrl = "https://1383-176-29-31-14.ngrok-free.app";
  // ✅ Register User
  Future<int?> registerUser(
    String email,
    String password,
    String name,
    String language,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'language': language,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        print("❌ Registration failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error registering user: $e");
      return null;
    }
  }

  // ✅ Register Admin
  Future<int?> registerAdmin(
    String workId,
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/admins/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'work_id': workId,
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        print("❌ Admin registration failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error registering admin: $e");
      return null;
    }
  }

  // ✅ User Login
  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error logging in user: $e");
      return false;
    }
  }

  // ✅ Admin Login
  Future<bool> loginAdmin(String workId, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/admins/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'work_id': workId,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error logging in admin: $e");
      return false;
    }
  }

  // ✅ Fetch Admin Login Logs
  Future<List<Map<String, dynamic>>> getAdminLogs() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/api/admins/logs'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("❌ Failed to fetch logs: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching admin logs: $e");
      return [];
    }
  }

  // ✅ Reset User Password
  Future<bool> resetUserPassword(String email, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/api/users/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error resetting user password: $e");
      return false;
    }
  }

  // ✅ Reset Admin Password
  Future<bool> resetAdminPassword(
    String workId,
    String email,
    String newPassword,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/api/admins/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'work_id': workId,
          'email': email,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error resetting admin password: $e");
      return false;
    }
  }
}
