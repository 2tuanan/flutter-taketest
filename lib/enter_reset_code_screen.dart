import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taketest/reset_new_password_screen.dart';
import 'auth_service.dart';

class EnterResetCodeScreen extends StatefulWidget {
  final String email;
  const EnterResetCodeScreen({super.key, required this.email});

  @override
  State<EnterResetCodeScreen> createState() => _EnterResetCodeScreenState();
}

class _EnterResetCodeScreenState extends State<EnterResetCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  bool _canResend = true;
  int _resendCooldown = 0; // seconds
  Timer? _timer;

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final err = await AuthService().verifyResetCode(
      email: widget.email,
      code: code,
    );

    setState(() => _isLoading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetNewPasswordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Code')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('We sent a code to ${widget.email}'),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, letterSpacing: 16),
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: '------',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red[700])),
            ],
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 54)),
                onPressed: _verifyCode,
                child: const Text('Verify Code', style: TextStyle(fontSize: 18)),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _canResend
                  ? () async {
                    setState(() {
                      _canResend = false;
                      _resendCooldown = 60; // 60 seconds cooldown
                    });

                    final err = await AuthService().requestPasswordReset(widget.email);

                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error resending code: $err')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code resent! Check your email.')),
                      );
                    }
                    _timer?.cancel();
                    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                      if (!mounted) {
                        timer.cancel();
                        return;
                      }
                      setState(() {
                        if (_resendCooldown > 0) {
                          _resendCooldown--;
                        } else {
                          _canResend = true;
                          timer.cancel();
                        }
                      });
                    });
                  } : null,
                child: Text(
                  _canResend ? 'Resend Code' : 'Resend in $_resendCooldown s',
                  style: TextStyle(
                    color: _canResend ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}