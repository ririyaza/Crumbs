import 'package:final_project/database_service.dart';
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

  String usernameError = "";
  String passwordError = "";
  String loginError = "";

  bool isLoading = false;
  bool passwordVisible = false; 

  Future<void> login() async {
    setState(() {
      usernameError = "";
      passwordError = "";
      loginError = "";
    });

    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool hasError = false;

    if (username.isEmpty) {
      setState(() => usernameError = "Please enter your username");
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Please enter your password");
      hasError = true;
    }

    if (hasError) return;

    setState(() => isLoading = true);

  final db = DatabaseService();
  final staffInfo = await db.validateStaffLogin(
    username: username,
    password: password,
  );

  setState(() => isLoading = false);

    if (staffInfo == null) {
      setState(() => loginError = "Incorrect username or password");
      return;
    }

    final staffId = staffInfo['staff_id'].toString();

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      PageRouteBuilder(
        pageBuilder: (context, a, b) => DashboardPage(
          selectedIndex: 0,
          staffId: staffId,      
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 200,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Log in with an existing account",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email / Username",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 224, 223, 223),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (usernameError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              usernameError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 224, 223, 223),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        if (passwordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              passwordError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: 600,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 95, 37, 255),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (loginError.isNotEmpty)
                    Text(
                      loginError,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 40, 145, 47),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size.fromHeight(60),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Log in', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
