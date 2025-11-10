import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onGoogleSignIn() {

  }

  void _onFacebookSignIn() {

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
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email / Username",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                           fillColor: const Color.fromARGB(255, 224, 223, 223),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 15.0),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Contact Number",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactNumberController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 15.0),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _createPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 15.0),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Confirm Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 40, 145, 47),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size.fromHeight(47),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Signed up successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }, 
                  child: const Text('Sign up', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                },
                child: const Text('Continue with',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              )
              ,
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _onGoogleSignIn,
                    child: Image.asset(
                      'assets/google_logo.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _onFacebookSignIn,
                    iconSize: 32,
                    icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                  ),
                ],
              )
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