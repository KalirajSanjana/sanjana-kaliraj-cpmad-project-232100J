import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationService _service = MedicationService();

  List<Medication> _meds = [];
  List<Medication> get meds => _meds;

  String? _error;
  String? get error => _error;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<List<Medication>>? _cachedFuture;

  String? _boundUid;

void bindUser(String? uid) {
  if (uid == _boundUid) return;
  _boundUid = uid;

  // reset state immediately
  _meds = [];
  _error = null;
  _isSaving = false;
  _cachedFuture = null;

  notifyListeners();

  // auto-load meds for new user
  if (uid != null) {
    loadOnce();
  }
}


  Future<List<Medication>> loadOnce() {
    _cachedFuture ??= _load();
    return _cachedFuture!;
  }

  Future<void> refresh() async {
    _cachedFuture = null;
    await loadOnce();
  }

Future<List<Medication>> _load() async {
  try {
    _error = null;


    _meds = await _service.fetchMedications();
  } catch (e) {
    _error = e.toString();
    _meds = [];
  }
  notifyListeners();
  return _meds;
}


  void _setSaving(bool v) {
    _isSaving = v;
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    _setSaving(true);
    try {
      await _service.addMedication(med);
      await refresh();
    } finally {
      _setSaving(false);
    }
  }

  Future<void> updateMedication(Medication med) async {
    _setSaving(true);
    try {
      await _service.updateMedication(med);
      await refresh();
    } finally {
      _setSaving(false);
    }
  }

  Future<void> deleteMedication(String id) async {
    _setSaving(true);
    try {
      await _service.deleteMedication(id);
      await refresh();
    } finally {
      _setSaving(false);
    }
  }
}
