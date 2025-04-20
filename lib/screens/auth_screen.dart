import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../utils/navigation_service.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login / Sign Up"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Login"),
              Tab(text: "Sign Up"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginTab(),
            SignUpTab(),
          ],
        ),
      ),
    );
  }
}

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  LoginTabState createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email') ?? '';
      final savedPassword = prefs.getString('password') ?? '';
      final remember = prefs.getBool('remember_me') ?? false;

      if (remember) {
        setState(() {
          emailController.text = savedEmail;
          passwordController.text = savedPassword;
          rememberMe = true;
        });
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  Future<void> saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('email', emailController.text);
        await prefs.setString('password', passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveCredentials();
      if (!mounted) return;
      NavigationService.navigateAndRemoveUntil('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account has been disabled';
      default:
        return 'Login failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) => setState(() => rememberMe = val!),
                    ),
                    const Text("Remember Me"),
                  ],
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class SignUpTab extends StatefulWidget {
  const SignUpTab({super.key});

  @override
  SignUpTabState createState() => SignUpTabState();
}

class SignUpTabState extends State<SignUpTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      NavigationService.navigateAndRemoveUntil('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Sign up failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: const InputDecoration(labelText: "Confirm Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}