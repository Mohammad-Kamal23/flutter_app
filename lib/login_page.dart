/*
import 'package:flutter/material.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: _buildLoginForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xffB81736),
          Color(0xff281537),
        ]),
      ),
      child: const Padding(
        padding: EdgeInsets.only(top: 60.0, left: 22),
        child: Text(
          'Hello\nSign in!',
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        color: Colors.white,
      ),
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField('Email', Icons.email),
            _buildTextField('Password', Icons.visibility_off, obscureText: true),
            const SizedBox(height: 20),
            _buildForgotPassword(context),
            const SizedBox(height: 40),
            _buildSignInButton(),
            const SizedBox(height: 50),
            _buildSignUp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        suffixIcon: Icon(icon, color: Colors.grey),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffB81736))),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordPage()));
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xff281537)),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      height: 55,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xffB81736), Color(0xff281537)]),
      ),
      child: const Center(
        child: Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
      },
      child: const Text(
        "Don't have an account? Sign up",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _errorMessage = '';

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email address");
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = "Enter your password");
      return;
    }

    try {
      bool isValidUser = await _dbHelper.loginUser(email, password);
      if (!mounted) return;

      if (isValidUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Login successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() => _errorMessage = "Invalid email or password");
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
      height: 160,
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
            Icon(Icons.eco, color: Colors.white, size: 40),
            SizedBox(width: 10),
            Text(
              "Welcome Back!\nSign in",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            _buildTextField(label: 'Email', controller: _emailController, icon: Icons.email),
            _buildTextField(label: 'Password', controller: _passwordController, icon: Icons.lock, isPassword: true),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            _buildButton(text: 'SIGN IN', onTap: _login),
            _buildForgotPassword(),
            const SizedBox(height: 10),
            _buildSignUpLink(),
          ],
        ),
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

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          "Forgot Password?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: const Column(
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
          ),
          Text(
            "Sign up",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
