import 'package:flutter/material.dart';
import '../database_helper.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  _AdminRegisterPageState createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController _workIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _errorMessage = '';

  Future<void> _registerAdmin() async {
    String workId = _workIdController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String name = _nameController.text.trim();

    if (workId.isEmpty) {
      setState(() => _errorMessage = "Please enter your Work ID");
      return;
    }
    if (name.isEmpty) {
      setState(() => _errorMessage = "Please enter your full name");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email address");
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters");
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    try {
      int? adminId = await _dbHelper.registerAdmin(workId, email, password, name);
      if (!mounted) return;

      if (adminId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Admin Registration successful!")),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = "Error: Work ID or Email might already exist.");
      }
    } catch (e) {
      setState(() => _errorMessage = "An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3b7f41), Color(0xff1b5e20)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 20, top: 60),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), // 👤 Admin Icon
            SizedBox(width: 10),
            Text(
              "Admin\nRegister",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3b7f41), Color(0xff1b5e20)],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          _buildTextField(label: 'Work ID', controller: _workIdController, icon: Icons.badge),
          _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person),
          _buildTextField(label: 'Email', controller: _emailController, icon: Icons.email),
          _buildTextField(label: 'Password', controller: _passwordController, icon: Icons.lock, isPassword: true),
          _buildTextField(label: 'Confirm Password', controller: _confirmPasswordController, icon: Icons.lock, isPassword: true),

          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ),

          const SizedBox(height: 20),
          _buildButton(text: 'REGISTER', onTap: _registerAdmin),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff1b5e20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff3b7f41), Color(0xff1b5e20)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
