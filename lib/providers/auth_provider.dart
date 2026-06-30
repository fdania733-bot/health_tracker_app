import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { uninitialized, initializing, authenticated, authenticating, unauthenticated, registering }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _appUser;

  AuthProvider() {
    print('🔵🔵 AUTH PROVIDER CREATED 🔵🔵🔵');
    _initializeAuth();
  }

  AuthStatus get status => _status;
  UserModel? get user => _appUser;
  UserModel? get appUser => _appUser;

  Future<void> _initializeAuth() async {
    print('🔵 Starting auth initialization...');
    try {
      _status = AuthStatus.initializing;
      notifyListeners();

      print('🔵 Waiting for auth state...');
      User? firebaseUser;
      try {
        firebaseUser = await Future.any([
          _authService.authStateChanges.first,
          Future.delayed(const Duration(seconds: 5), () {
            print('⚠️ Auth state timeout after 5 seconds');
            return null;
          }),
        ]);
        print('🔵 Auth state resolved: ${firebaseUser?.email ?? "no user"}');
      } catch (e) {
        print('❌ Auth state error: $e');
        firebaseUser = null;
      }

      if (firebaseUser != null) {
        print('✅ User found: ${firebaseUser.email}');
        try {
          UserModel? userProfile = await Future.any([
            _firestoreService.getUserProfile(firebaseUser.uid),
            Future.delayed(const Duration(seconds: 5), () {
              print('⚠️ Firestore profile timeout');
              return null;
            }),
          ]);

          if (userProfile != null) {
            print('✅ User profile found in Firestore');
            _appUser = userProfile;
            _status = AuthStatus.authenticated;
          } else {
            print('⚠️ No profile found - creating default profile');
            _appUser = UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
              age: 25,
              gender: 'not specified',
              createdAt: DateTime.now(),
              profileComplete: false,
            );
            try { await _firestoreService.createUserProfile(_appUser!); } catch (e) {}
            _status = AuthStatus.authenticated;
          }
        } catch (e) {
          print('❌ Error getting user profile: $e');
          _status = AuthStatus.unauthenticated;
        }
      } else {
        print('⚠️ No user logged in');
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('❌ Auth initialization error: $e');
      _status = AuthStatus.unauthenticated;
    }
    print('✅ Auth initialization complete. Status: $_status');
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    print('🔵🔵 LOGIN METHOD CALLED 🔵🔵🔵');
    print('🔵 Email: $email');

    try {
      print('🔵 Step 1: Authenticating with Firebase...');
      UserCredential cred = await _authService.signIn(email, password);
      print('✅ Firebase auth successful: ${cred.user?.uid}');

      print('🔵 Step 2: Loading user profile from Firestore...');
      UserModel? userProfile;

      try {
        userProfile = await _firestoreService.getUserProfile(cred.user!.uid);
      } catch (e) {
        print('⚠️ Could not load profile: $e');
      }

      if (userProfile == null) {
        print('⚠️ Profile not found - creating default profile...');
        userProfile = UserModel(
          uid: cred.user!.uid,
          name: cred.user!.displayName ?? email.split('@')[0],
          email: email,
          age: 25,
          gender: 'not specified',
          createdAt: DateTime.now(),
          profileComplete: false,
        );

        try {
          await _firestoreService.createUserProfile(userProfile);
          print('✅ Default profile created');
        } catch (e) {
          print('❌ Failed to create default profile: $e');
        }
      } else {
        print('✅ Profile loaded successfully');
      }

      _appUser = userProfile;
      _status = AuthStatus.authenticated;
      notifyListeners();

      print('✅✅✅ LOGIN COMPLETE ✅✅✅');
      return null;

    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuth error: ${e.code}');
      print('❌ Error message: ${e.message}');
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      if (e.code == 'invalid-credential') {
        return 'Invalid email or password. Please check your credentials.';
      }

      return _getErrorMessage(e.code);
    } catch (e) {
      print('❌ Login error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return 'Login failed: ${e.toString()}';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) async {
    print('🔵🔵 REGISTER METHOD CALLED 🔵🔵');
    print('🔵 Name: $name');
    print('🔵 Email: $email');
    print('🔵 Age: $age');
    print('🔵 Gender: $gender');

    try {
      _status = AuthStatus.registering;
      notifyListeners();

      print('🔵 Step 1: Creating auth user...');
      UserCredential cred = await _authService.signUp(email, password);
      print('✅ Auth user created: ${cred.user?.uid}');

      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        age: age,
        gender: gender.toLowerCase(),
        createdAt: DateTime.now(),
        profileComplete: true,
      );

      print('🔵 Step 2: Creating Firestore profile...');
      try {
        await _firestoreService.createUserProfile(newUser);
        print('✅ Firestore profile created');
      } catch (firestoreError) {
        print('⚠️ Firestore failed, but Auth succeeded: $firestoreError');
      }

      _appUser = newUser;
      _status = AuthStatus.authenticated;
      notifyListeners();

      print('✅✅✅ REGISTRATION COMPLETE ✅✅✅');
      return null;

    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuth error: ${e.code}');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return _getErrorMessage(e.code);
    } catch (e) {
      print('❌ Registration error: $e');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return 'Registration failed: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    print('🔵 Signing out...');
    await _authService.signOut();
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    print('✅ Sign out complete');
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> completeProfile({required double heightCm, required double weightKg}) async {
    if (_appUser == null) return;
    _appUser = UserModel(
      uid: _appUser!.uid, name: _appUser!.name, email: _appUser!.email,
      age: _appUser!.age, gender: _appUser!.gender, createdAt: _appUser!.createdAt,
      heightCm: heightCm, weightKg: weightKg, profileComplete: true,
    );
    try { await _firestoreService.updateUserProfile(_appUser!.uid, _appUser!.toMap()); } catch (e) {}
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? nickname,
    String? email,
    int? age,
    String? gender
  }) async {
    if (_appUser == null) return;

    _appUser = UserModel(
      uid: _appUser!.uid,
      name: name ?? _appUser!.name,
      nickname: nickname ?? _appUser!.nickname,
      email: email ?? _appUser!.email,
      age: age ?? _appUser!.age,
      gender: gender ?? _appUser!.gender,
      createdAt: _appUser!.createdAt,
      heightCm: _appUser!.heightCm,
      weightKg: _appUser!.weightKg,
      profileComplete: _appUser!.profileComplete,
    );

    try {
      await _firestoreService.updateUserProfile(_appUser!.uid, _appUser!.toMap());
      print('✅ Profile updated in Firestore');
    } catch (e) {
      print('❌ Failed to update profile: $e');
    }
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential': return 'Invalid email or password.';
      case 'user-not-found': return 'No account found.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'weak-password': return 'Password too weak (min 6 characters).';
      case 'invalid-email': return 'Invalid email format.';
      case 'operation-not-allowed': return 'Email/Password not enabled. Check Firebase Console.';
      case 'network-request-failed': return 'Network error. Check internet connection.';
      default: return 'Error: $code';
    }
  }
}