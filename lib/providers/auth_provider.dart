import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/firebaseauth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuthService _service = FirebaseAuthService();

  User? _user;
  bool _loading = false;

  AuthProvider() {
  
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _loading;

  String get displayName {
    final name = _user?.displayName?.trim();
    if (name == null || name.isEmpty) return "User";
    return name;
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();

    final u = await _service.signIn(email: email, password: password);

    _loading = false;

    if (u != null) {
      _user = u;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    _loading = true;
    notifyListeners();

    final u = await _service.signUp(email: email, password: password);

    if (u != null) {
      await u.updateDisplayName(name);
      await u.reload();
      _user = _auth.currentUser;
      _loading = false;
      notifyListeners();
      return true;
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
