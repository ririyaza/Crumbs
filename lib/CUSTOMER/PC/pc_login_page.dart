import 'package:provider/provider.dart';

import 'components/helper/cart_manager.dart';
import 'pages/dashboard.dart';
import 'pc_registration_page.dart';
import 'package:flutter/material.dart';
import '../../database_service.dart'; 

class PcLoginPage extends StatefulWidget {
  const PcLoginPage({super.key});

  @override
  State<PcLoginPage> createState() => _PcLoginPageState();
}

class _PcLoginPageState extends State<PcLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool passwordVisible = false;

  String usernameError = "";
  String passwordError = "";
  String loginError = "";
  bool isLoading = false;

 Future<void> login() async {
  setState(() {
    usernameError = "";
    passwordError = "";
    loginError = "";
    isLoading = true;
  });

  final username = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (username.isEmpty) {
    setState(() { usernameError = "Please enter your email/username"; isLoading = false; });
    return;
  }
  if (password.isEmpty) {
    setState(() { passwordError = "Please enter your password"; isLoading = false; });
    return;
  }

  try {
    final db = DatabaseService();
    final snapshot = await db.firebaseDatabase
        .child('Customer')
        .orderByChild('customer_email')
        .equalTo(username)
        .get();

    if (!snapshot.exists) {
      setState(() { loginError = "Incorrect username or password"; isLoading = false; });
      return;
    }

    final snapshotValue = snapshot.value;

    Map<String, dynamic>? matchedCustomer;

    if (snapshotValue is Map) {
      for (var entry in snapshotValue.values) {
        final user = Map<String, dynamic>.from(entry);
        if (user['customer_password'] == password) {
          matchedCustomer = user;
          break;
        }
      }
    } else if (snapshotValue is List) {
      for (var entry in snapshotValue) {
        if (entry == null) continue; 
        final user = Map<String, dynamic>.from(entry);
        if (user['customer_password'] == password) {
          matchedCustomer = user;
          break;
        }
      }
    } else {
      setState(() {
        loginError = "Unexpected data format from database.";
        isLoading = false;
      });
      return;
    }

    setState(() { isLoading = false; });

    if (matchedCustomer == null) {
      setState(() { loginError = "Incorrect username or password"; });
      return;
    }

    final customerId = matchedCustomer['customer_id'].toString();
    final customerfName = matchedCustomer['customer_Fname'].toString();
    final customerlName = matchedCustomer['customer_Lname'].toString();
    final customerName = '$customerfName $customerlName';

    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CartManager(customerId: customerId, customerName: customerName),
        child: DashboardPage(
          customerId: customerId,
          selectedIndex: 0,
        ),
      ),
    ),
  );
  } catch (e) {
    setState(() {
      loginError = "Login failed: $e";
      isLoading = false;
    });
  }
}



  void _onGoogleSignIn() {}
  void _onFacebookSignIn() {}

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.8;
    if (maxWidth > 600) maxWidth = 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SizedBox.expand(
        child: Stack(
          children: [
            Image.asset(
              'assets/background.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', width: 200, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    const Text(
                      "Log in with an existing account",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email / Username", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(255, 224, 223, 223),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          if (usernameError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(usernameError, style: const TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !passwordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(255, 224, 223, 223),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => passwordVisible = !passwordVisible),
                              ),
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

                    const SizedBox(height: 8),
                    SizedBox(
                      width: maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                              const Text('Remember me', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color.fromARGB(255, 95, 37, 255),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerRight,
                            ),
                            onPressed: () {},
                            child: const Text('Forgot password?', style: TextStyle(decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (loginError.isNotEmpty)
                      Text(loginError, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 40, 145, 47),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(60),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: isLoading ? null : login,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Log in', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(decoration: TextDecoration.underline, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationPage()),
                        );
                      },
                      child: const Text('Sign up', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                    const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
