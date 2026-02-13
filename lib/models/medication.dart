import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dose;
  final String frequency;
  final String time;
  final Timestamp? createdAt; 

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.time,
    this.createdAt,
  });

  factory Medication.fromMap(String id, Map<String, dynamic> data) {
    return Medication(
      id: id,
      name: data['name'] ?? '',
      dose: data['dose'] ?? '',
      frequency: data['frequency'] ?? '',
      time: data['time'] ?? '',
      createdAt: data['createdAt'], 
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = false}) {
    return {
      'name': name,
      'dose': dose,
      'frequency': frequency,
      'time': time,
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(), 
    };
  }
}
