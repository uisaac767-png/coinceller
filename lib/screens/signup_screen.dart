import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Optional: any startup logic with delay
    Future.delayed(const Duration(seconds: 3), () {});
  }

  void signup() async {
    setState(() => loading = true);

    try {
      final ok = await ApiService.signup(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup successful. Now login."),
            backgroundColor: BybitTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot connect to server. Try again."),
          backgroundColor: BybitTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CustomTextField(
              controller: emailController,
              hintText: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: "Sign Up",
              loading: loading,
              onPressed: signup,
            ),
          ],
        ),
      ),
    );
  }
}
