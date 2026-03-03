import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool isInRecoveryFlow = false;
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns null on success, or error message on failure
  Future<String?> signUpWithEmail({
  required String email,
  required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'taketest42xk9q://login-callback',   // ← fixed: no options
      );

      if (res.user != null && res.session == null) {
        // Confirmation email sent (most common when confirm email = ON)
        return null; // success
      }

      return null;
    } on AuthException catch (e) {
      if (e.code == 'user_already_registered') {
        try {
          await supabase.auth.resend(
            type: OtpType.signup,
            email: email,
            emailRedirectTo: 'taketest42xk9q://login-callback',
          );
          return 'Confirmation email re-sent';
        } catch (resendError) {
          return 'Resend failed: $resendError';
        }
      }
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Returns null on success, or error message
  Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print('signInWithPassword success');
      await supabase.auth.refreshSession(); // force refresh to test if it helps

      final role = await getUserRole();
      if (role != null) {
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await supabase.from('user_roles').upsert({
            'user_id': userId,
            'role_id': 2, 
          });
          print('Default role assigned for new user');
        }
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> requestPasswordReset(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      AuthService.isInRecoveryFlow = true;
      await supabase.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: OtpType.recovery,
      );
      return null;
    } on AuthException catch (e) {
      AuthService.isInRecoveryFlow = false;
      return e.message;
    } catch (e) {
      AuthService.isInRecoveryFlow = false;
      return 'Unexpected error: $e';
    }
  }

  Future<String?> updatePasswordAfterReset(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      AuthService.isInRecoveryFlow = false;
      await supabase.auth.signOut(); // Force sign out after password change
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<int?> getUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', user.id)
          .maybeSingle(); 
      return response?['role_id'] as int?;
    } catch (e) {
      print('Error fetching role: $e');
      return null;
    }
  }

  Future<void> signOut() => supabase.auth.signOut();
}