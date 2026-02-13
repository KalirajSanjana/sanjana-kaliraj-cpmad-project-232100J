import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'home_page.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

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
                      "Register",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F3CFF),
                      ),
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _InputLabel("Username"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? "Enter your name"
                          : null,
                      onSaved: (val) => name = val!.trim(),
                    ),
                    const SizedBox(height: 18),

                    _InputLabel("Email"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Enter email";
                        if (!val.contains('@')) return "Enter a valid email";
                        return null;
                      },
                      onSaved: (val) => email = val!.trim(),
                    ),
                    const SizedBox(height: 18),

                    _InputLabel("Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter password";
                        if (val.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      onSaved: (val) => password = val!,
                    ),
                    const SizedBox(height: 18),

                    _InputLabel("Confirm Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(),
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Confirm your password";
                        if (val.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      onSaved: (val) => confirmPassword = val!,
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3CFF),
                          foregroundColor:
                              Colors.white, 
                          disabledBackgroundColor:
                              const Color(0xFF1F3CFF).withOpacity(0.6),
                          disabledForegroundColor:
                              Colors.white, 
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

                                // manual confirm password check (toast style)
                                if (password != confirmPassword) {
                                  Fluttertoast.showToast(
                                    msg: "Passwords do not match",
                                    gravity: ToastGravity.TOP,
                                  );
                                  return;
                                }

                                final success = await context
                                    .read<AuthProvider>()
                                    .signUp(name, email, password);

                                if (success && mounted) {
                                  Fluttertoast.showToast(
                                    msg: "Registration successful!",
                                    gravity: ToastGravity.TOP,
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomePage()),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Registration failed. Try again.",
                                    gravity: ToastGravity.TOP,
                                  );
                                }
                              },
                        child: Text(
                          auth.isLoading ? "Registering..." : "Register",
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
                          "Have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
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
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );
}
