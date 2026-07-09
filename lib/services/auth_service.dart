import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user profile in Firestore
      await _userService.createUserProfile(credential.user!.uid, {
        'name': name,
        'email': email,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'unexpected_error'.tr(args: [e.toString()]);
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'unexpected_error'.tr(args: [e.toString()]);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Error Handling
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'auth_error_email_already_in_use'.tr();
      case 'weak-password':
        return 'auth_error_weak_password'.tr();
      case 'user-not-found':
        return 'auth_error_user_not_found'.tr();
      case 'wrong-password':
        return 'auth_error_wrong_password'.tr();
      case 'invalid-email':
        return 'auth_error_invalid_email'.tr();
      case 'invalid-credential':
        return 'auth_error_invalid_credential'.tr();
      case 'user-disabled':
        return 'auth_error_user_disabled'.tr();
      case 'too-many-requests':
        return 'auth_error_too_many_requests'.tr();
      case 'operation-not-allowed':
        return 'auth_error_operation_not_allowed'.tr();
      default:
        return 'auth_error_generic'.tr(args: [e.message ?? e.code]);
    }
  }
}
