import 'pages/dashboard.dart';
import 'package:flutter/material.dart';

class PcLoginPage extends StatefulWidget {
  const PcLoginPage({super.key});

  @override
  State<PcLoginPage> createState() => _PcLoginPageState();
}

class _PcLoginPageState extends State<PcLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  "Log in with an existing account",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
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
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 12.0, bottom: 30.0),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 95, 37, 255),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            decoration: TextDecoration.underline
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
                    minimumSize: const Size.fromHeight(60),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Logged in successfully!'),
                        actions: [
                          TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(selectedIndex: 0),
                              ),
                            );
                          },
                          child: const Text('OK'),
                        ),
                        ],
                      ),
                    );
                  }, 
                  child: const Text('Log in', style: TextStyle(fontSize: 20)),
                ),
              ),
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