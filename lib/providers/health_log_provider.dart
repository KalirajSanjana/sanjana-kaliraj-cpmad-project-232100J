import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/health_log.dart';
import '../services/health_log_service.dart';

class HealthLogProvider extends ChangeNotifier {
  final HealthLogService _service = HealthLogService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HealthLog> _logs = [];
  String? _error;
  bool _isSaving = false;

  Future<void>? _cachedFuture;

  List<HealthLog> get logs => _logs;
  String? get error => _error;
  bool get isSaving => _isSaving; 

  String? get _uid => _auth.currentUser?.uid; //get current user id

  String? _boundUid;

void bindUser(String? uid) {
  if (uid == _boundUid) return;
  _boundUid = uid;

  _logs = [];
  _error = null;
  _isSaving = false;
  _cachedFuture = null;

  notifyListeners();

  if (uid != null) {
    loadOnce();
  }
}



  Future<void> loadOnce() {
    _cachedFuture ??= _load();
    return _cachedFuture!;
  }

  Future<void> refresh() async {
    _cachedFuture = null;
    await loadOnce();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      _logs = [];
      _error = "Please log in first.";
      notifyListeners();
      return;
    }

    try {
      _error = null;
      final data = await _service.fetchLogs(uid);
      _logs = data;
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  // ADD LOG
  Future<void> addLog(String uid, HealthLog log) async {
    _setSaving(true);
    try {
      await _service.addLog(uid, log);
      await refresh();
    } finally {
      _setSaving(false);
    }
  }

  //  UPDATE LOG
  Future<void> updateLog(String uid, HealthLog log) async {
    _setSaving(true);
    try {
      await _service.updateLog(uid, log);
      await refresh();
    } finally {
      _setSaving(false);
    }
  }

  //  DELETE LOG
  Future<void> deleteLog(HealthLog log) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.deleteLog(uid, log.id);
    await refresh();
  }

  void _setSaving(bool v) {
    _isSaving = v;
    notifyListeners();
  }
}
