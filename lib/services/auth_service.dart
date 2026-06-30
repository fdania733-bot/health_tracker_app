import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      print('🔵🔵🔵 REGISTRATION ATTEMPT STARTED 🔵🔵🔵');
      print('🔵 Email: $email');
      print('🔵 Password length: ${password.length}');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Registration successful!');
      print('✅ User UID: ${result.user?.uid}');
      print('✅ User Email: ${result.user?.email}');

      return result;

    } on FirebaseAuthException catch (e) {
      print('❌❌ REGISTRATION FAILED ❌❌❌');
      print('❌ Error Code: ${e.code}');
      print('❌ Error Message: ${e.message}');

      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('🔵🔵 LOGIN ATTEMPT STARTED 🔵🔵🔵');
      print('🔵 Email: $email');
      print('🔵 Password length: ${password.length}');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful!');
      print('✅ User UID: ${result.user?.uid}');
      print('✅ User Email: ${result.user?.email}');

      return result;

    } on FirebaseAuthException catch (e) {
      print('❌❌❌ LOGIN FAILED ❌❌❌');
      print('❌ Error Code: ${e.code}');
      print('❌ Error Message: ${e.message}');

      if (e.code == 'invalid-credential') {
        print('⚠️ Checking if account exists...');
        try {
          final methods = await _auth.fetchSignInMethodsForEmail(email);
          print('⚠️ Sign-in methods: $methods');

          if (methods.contains('google.com') && !methods.contains('password')) {
            throw Exception('This account was created with Google. Please use "Continue with Google" button.');
          }
        } catch (checkError) {
          print('⚠️ Could not check sign-in methods: $checkError');
        }

        throw Exception('Invalid email or password. Please check your credentials.');
      }

      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      print('🔵 Signing out...');
      await _auth.signOut();
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Sign out failed: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('🔵 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Password reset failed: $e');
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled. Please enable it in Firebase Console.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication error: $code';
    }
  }
}