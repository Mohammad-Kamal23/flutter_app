import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'admin_login_page.dart';
import 'admin_register_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showRoleSelection(BuildContext context, bool isSignIn) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Continue as"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roleButton(context, "User", isSignIn ? const LoginPage() : const RegisterPage()),
              const SizedBox(height: 10),
              _roleButton(context, "Admin", isSignIn ? const AdminLoginPage() : const AdminRegisterPage()),
            ],
          ),
        );
      },
    );
  }

  Widget _roleButton(BuildContext context, String role, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(role, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2E7D32), Color(0xff1B5E20)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text('Welcome Back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            _buildButton(context, text: 'SIGN IN', isSignIn: true),
            const SizedBox(height: 20),
            _buildButton(context, text: 'SIGN UP', isSignIn: false, isWhite: true),
            const SizedBox(height: 40),
            const Text('Login with Social Media', style: TextStyle(fontSize: 17, color: Colors.white)),
            const SizedBox(height: 12),
            _buildSocialMediaIcons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text, required bool isSignIn, bool isWhite = false}) {
    return GestureDetector(
      onTap: () => _showRoleSelection(context, isSignIn),
      child: Container(
        height: 53,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isWhite ? null : const LinearGradient(colors: [Color(0xff2E7D32), Color(0xff1B5E20)]),
          color: isWhite ? Colors.white : null,
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isWhite ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.facebook, color: Colors.white, size: 40),
        SizedBox(width: 20),
        Icon(Icons.g_translate, color: Colors.white, size: 40),
        SizedBox(width: 20),
        Icon(Icons.apple, color: Colors.white, size: 40),
      ],
    );
  }
}
