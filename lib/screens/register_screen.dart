import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// استيراد الشاشتين حسب مكانهم
import 'owner_dashboard_screen.dart';
import 'alert_fire_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? selectedRole;
  final List<String> roles = ['owner', 'firefighter'];

  bool isLoading = false;

  void registerUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedRole == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('من فضلك املأ كل البيانات')),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 1. تسجيل المستخدم في Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. حفظ معلوماته في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. التوجيه حسب نوع المستخدم
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => selectedRole == 'owner'
                ? const OwnerDashboardScreen()
                : const FireAlertScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ أثناء التسجيل: ')),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع المستخدم'),
                value: selectedRole,
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role == 'owner' ? 'صاحب مصنع' : 'الدفاع المدني'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
