// To Login to Current User use jhonnylim@gmail.com pwd jhonnylim123

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'register_page.dart';
import 'home_page.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _HeartLogo(),
                    const SizedBox(height: 16),

                    const Text(
                      "ElderCare +",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F3CFF),
                      ),
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      "Your Health Companion",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _InputLabel("Email"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? "Enter email" : null,
                      onSaved: (val) => email = val!.trim(),
                    ),
                    const SizedBox(height: 18),

                    _InputLabel("Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      obscureText: true,
                      validator: (val) => (val == null || val.length < 6)
                          ? "Password must be at least 6 characters"
                          : null,
                      onSaved: (val) => password = val!,
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3CFF),
                          foregroundColor:
                              Colors.white, //  makes "Login" visible
                          disabledBackgroundColor:
                              const Color(0xFF1F3CFF).withOpacity(0.6),
                          disabledForegroundColor:
                              Colors.white, // 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final ok = _formKey.currentState!.validate();
                                if (!ok) return;
                                _formKey.currentState!.save();

                                final success = await context
                                    .read<AuthProvider>()
                                    .signIn(email, password);

                                if (success && mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomePage()),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Login failed. Please check your email/password.",
                                    gravity: ToastGravity.TOP,
                                  );
                                }
                              },
                        child: Text(
                          auth.isLoading ? "Logging in..." : "Login",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F3CFF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartLogo extends StatelessWidget {
  const _HeartLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: Color(0xFF1F3CFF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_border,
        color: Colors.white,
        size: 44,
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF1F3F6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );
}
