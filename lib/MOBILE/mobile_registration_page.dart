import 'package:final_project/MOBILE/mobile_login_page.dart';
import 'package:flutter/material.dart';

class MobileRegistrationPage extends StatefulWidget {
  const MobileRegistrationPage({super.key});

  @override
  State<MobileRegistrationPage> createState() => _MobileRegistrationPageState();
}

class _MobileRegistrationPageState extends State<MobileRegistrationPage> {
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onGoogleSignIn() {
    // TODO: Hook up Google Sign-In
  }

  void _onFacebookSignIn() {
    // TODO: Hook up Facebook Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mobile_design.png'),
                fit: BoxFit.fill,
                repeat: ImageRepeat.repeatX,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Padding(
                      padding: const EdgeInsets.only(top: 60.0), // adds extra breathing space
                      child: Transform.translate(
                        offset: const Offset(0, -70), // matches login page alignment
                        child: Image.asset(
                          'assets/logo.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ), 
              const SizedBox(height: 1),
              Transform.translate(
                offset: const Offset(0, -70),
                child: Text(
                  "Create an account",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email / Username",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                     TextFormField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                      ),
                    ],
                  ),
                ),  
              ),
              ),
                   Transform.translate(
              offset: const Offset(0, -54),
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Contact Number",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactController,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                      ),
                    ],
                  ),
                ),  
              ),
              ),
              Transform.translate(
                offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 12.0, bottom: 10.0),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Password",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _createPasswordController,
                        style: const TextStyle(fontSize: 20),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                      ),        
                    ],
                  ),
                ),
              ), 
              ),
               Transform.translate(
                offset: const Offset(0, -69),
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 12.0, bottom: 10.0),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Confirm Password",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                       TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(fontSize: 20),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 224, 223, 223),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                      ),   
                    ],
                  ),
                ),
              ), 
              ),
              Transform.translate(
                offset: const Offset(0, -60),
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 40, 145, 47),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size.fromHeight(50),
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
              ),
               Transform.translate(
              offset: const Offset(0, -65),
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 159, 124, 124),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                   Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (context) => const MobileLoginPage(),
                      ),
                    );
                },
                child: const Text('Cancel',
                  style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                ),
              ),
              ),
              ),
              Transform.translate(
              offset: const Offset(0, -55),
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                   Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (context) => const MobileLoginPage(),
                      ),
                    );
                },
                child: const Text('Continue with',
                  style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                ),
              ),
              ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                  offset: const Offset(0, -60),
                  child: InkWell(
                    onTap: _onGoogleSignIn,
                    child: Image.asset(
                      'assets/google_logo.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  ),
                  const SizedBox(width: 1),
                  Transform.translate(
                  offset: const Offset(0, -60),
                  child: IconButton(
                    onPressed: _onFacebookSignIn,
                    iconSize: 32,
                    icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                  ),
                  ),
                ],
              )
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
);
}
}