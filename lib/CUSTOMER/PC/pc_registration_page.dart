import 'package:final_project/CUSTOMER/PC/pc_login_page.dart';
import 'package:flutter/material.dart';
import '../../database_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final DatabaseService dbServices = DatabaseService();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String emailError = "";
  String contactError = "";
  String passwordError = "";
  String confirmPasswordError = "";

  void _onGoogleSignIn() {}
  void _onFacebookSignIn() {}

  void _register() {
    setState(() {
      emailError = "";
      contactError = "";
      passwordError = "";
      confirmPasswordError = "";
    });

    final email = _emailController.text.trim();
    final contact = _contactNumberController.text.trim();
    final password = _createPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      emailError = "Please enter your email/username";
      hasError = true;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailError = "Enter a valid email address";
      hasError = true;
    }

    if (contact.isEmpty) {
      contactError = "Please enter your contact number";
      hasError = true;
    } else if (!RegExp(r'^\d+$').hasMatch(contact)) {
      contactError = "Contact number should be numeric";
      hasError = true;
    } else if (contact.length < 7) {
      contactError = "Contact number is too short";
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError = "Please create a password";
      hasError = true;
    } else if (password.length < 6) {
      passwordError = "Password must be at least 6 characters";
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
      hasError = true;
    } else if (confirmPassword != password) {
      confirmPasswordError = "Passwords do not match";
      hasError = true;
    }

    setState(() {});

    if (hasError) return;

      dbServices.registerUser(email,email,contact,password);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Signed up successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PcLoginPage(),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Image.asset('assets/logo.png', width: 200, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Email / Username",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 223, 223),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            if (emailError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(emailError, style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Contact Number",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _contactNumberController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 223, 223),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            if (contactError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(contactError, style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Create Password",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _createPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 223, 223),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            if (passwordError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(passwordError, style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Confirm Password",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 223, 223),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            if (confirmPasswordError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(confirmPasswordError,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 40, 145, 47),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(47),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _register,
                        child: const Text('Sign up', style: TextStyle(fontSize: 20)),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: _onGoogleSignIn,
                          child: Image.asset('assets/google_logo.png', width: 36, height: 36),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _onFacebookSignIn,
                          iconSize: 32,
                          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
