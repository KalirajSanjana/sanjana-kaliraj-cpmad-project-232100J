import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';

class MedicationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference get _medsRef =>
      _firestore.collection('users').doc(uid).collection('medications');

  Future<void> addMedication(Medication med) async {
    await _medsRef.add(
      med.toMap(includeCreatedAt: true),
    );
  }

  Future<void> updateMedication(Medication med) async {
    await _medsRef.doc(med.id).update(
      med.toMap(),
    );
  }

  Future<void> deleteMedication(String id) async {
    await _medsRef.doc(id).delete();
  }

  
  Stream<List<Medication>> getMedications() {
    return _medsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Medication.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  
  Future<List<Medication>> fetchMedications() async {
    final snapshot =
        await _medsRef.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) =>
            Medication.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
}
