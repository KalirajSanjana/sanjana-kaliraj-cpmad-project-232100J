import 'package:cloud_firestore/cloud_firestore.dart';

class HealthLog {
  final String id;
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime createdAt;

  const HealthLog({
    required this.id,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.createdAt,
  });

  // Normal or Abnormal
  String get status {
    final bpNormal =
        (systolic >= 90 && systolic <= 120) &&
        (diastolic >= 60 && diastolic <= 80);

    final hrNormal = heartRate >= 60 && heartRate <= 100;

    return (bpNormal && hrNormal) ? "Normal" : "Abnormal";
  }

  factory HealthLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v?.toString() ?? "") ?? 0;
    }

    return HealthLog(
      id: doc.id,
      date: toDate(data["date"]),
      systolic: toInt(data["systolic"]),
      diastolic: toInt(data["diastolic"]),
      heartRate: toInt(data["heartRate"]),
      createdAt: toDate(data["createdAt"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "date": Timestamp.fromDate(date),
      "systolic": systolic,
      "diastolic": diastolic,
      "heartRate": heartRate,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}
