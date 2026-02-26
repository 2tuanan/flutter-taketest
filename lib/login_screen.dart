import 'package:flutter/material.dart';
import 'package:taketest/forgot_password_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isSignUpMode = false;

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    String? result;

    if (_isSignUpMode) {
      result = await _auth.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
    } else {
      result = await _auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      setState(() => _isLoading = false);

      if (result != null) {
        setState(() => _error = result);
        return;
      }
    }

    if (_isSignUpMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email to confirm your account!'),
          duration: Duration(seconds: 6),
        ),
      );
    // } else {
    //   if (context.mounted) {
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (_) => const HomeScreen()),
    //       (route) => false, // clear all previous routes
    //     );
    //   }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUpMode ? 'Sign Up' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _isSignUpMode = !_isSignUpMode);
                _error = null;
              },
              child: Text(
                _isSignUpMode
                    ? 'Already have an account? Login'
                    : 'No account? Sign Up',
              ),
            ),
          ],
        ),
      ),
    );
  }
}