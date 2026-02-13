import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_log.dart';

class HealthLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) {
    return _db.collection("users").doc(uid).collection("healthLogs");
  }

  Stream<List<HealthLog>> streamLogs(String uid) {
    return _ref(uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => HealthLog.fromDoc(d)).toList());
  }

  Future<List<HealthLog>> fetchLogs(String uid) async {
    final snap = await _ref(uid).orderBy("createdAt", descending: true).get();
    return snap.docs.map((d) => HealthLog.fromDoc(d)).toList();
  }

  Future<void> addLog(String uid, HealthLog log) {
    return _ref(uid).add(log.toMap());
  }

  Future<void> updateLog(String uid, HealthLog log) {
    return _ref(uid).doc(log.id).update(log.toMap());
  }

  Future<void> deleteLog(String uid, String docId) {
    return _ref(uid).doc(docId).delete();
  }
}
