import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  bool _loading = false;
  bool _saving = false;
  String? _error;

  String username = "";
  String? photoUrl;
  bool darkMode = false;

  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;

  User? get user => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) {
    return _db.collection("users").doc(uid);
  }

  // SharedPreferences 
  String _kDark(String uid) => "profile_${uid}_darkMode";
  String _kName(String uid) => "profile_${uid}_username";
  String _kPhoto(String uid) => "profile_${uid}_photoUrl";

  String? _boundUid;

  void bindUser(String? uid) {
    if (uid == _boundUid) return;
    _boundUid = uid;

    // reset so UI never shows old user
    username = "";
    photoUrl = null;
    darkMode = false;
    _error = null;
    _loading = false;
    _saving = false;

    notifyListeners();

    if (uid != null) {
      loadProfile(); // load and sync firestore
    }
  }

  // Loads prefs first , then Firestore 
  Future<void> loadProfile() async {
    final id = uid;
    if (id == null) {
      _error = "Not logged in";
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    // Load from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDark = prefs.getBool(_kDark(id));
      final localName = prefs.getString(_kName(id));
      final localPhoto = prefs.getString(_kPhoto(id));

      if (localDark != null) darkMode = localDark;
      if (localName != null) username = localName;
      if (localPhoto != null) photoUrl = localPhoto;

      notifyListeners(); // update UI immediately
    } catch (_) {}

    // 2)Then sync from Firestore 
    try {
      final doc = await _profileDoc(id).get();
      final data = doc.data();

      final fsName = (data?["username"] ?? user?.displayName ?? "").toString();
      final fsPhoto = data?["photoUrl"]?.toString();
      final fsDark = (data?["darkMode"] ?? false) == true;

      username = fsName;
      photoUrl = fsPhoto;
      darkMode = fsDark;

      // Write Firestore values back into SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDark(id), darkMode);
      await prefs.setString(_kName(id), username);
      if (photoUrl != null) {
        await prefs.setString(_kPhoto(id), photoUrl!);
      } else {
        await prefs.remove(_kPhoto(id));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setUsername(String v) {
    username = v;
    notifyListeners();
  }

  void setDarkMode(bool v) {
    darkMode = v;
    notifyListeners();
  }

  Future<void> pickAndUploadProfileImage({required bool fromCamera}) async {
    final id = uid;
    if (id == null) return;

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      final picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) {
        _saving = false;
        notifyListeners();
        return;
      }

      final file = File(picked.path);
      final ref = _storage.ref().child("users/$id/profile.jpg");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      photoUrl = url;

      await _profileDoc(id).set({
        "username": username.trim(),
        "photoUrl": photoUrl,
        "darkMode": darkMode,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // cache locally too
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPhoto(id), photoUrl!);

    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  // Save commits to Firestore + SharedPreferences
  Future<void> saveChanges() async {
    final id = uid;
    if (id == null) return;

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      if (user != null && username.trim().isNotEmpty) {
        await user!.updateDisplayName(username.trim());
        await user!.reload();
      }

      await _profileDoc(id).set({
        "username": username.trim(),
        "photoUrl": photoUrl,
        "darkMode": darkMode,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDark(id), darkMode);
      await prefs.setString(_kName(id), username.trim());
      if (photoUrl != null) {
        await prefs.setString(_kPhoto(id), photoUrl!);
      } else {
        await prefs.remove(_kPhoto(id));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
