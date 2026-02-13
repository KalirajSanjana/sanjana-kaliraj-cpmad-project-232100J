import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/clinic.dart';

class ClinicProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  final List<Clinic> _all = [];
  List<Clinic> filtered = [];
  String query = "";

  String? _boundUid;

void bindUser(String? uid) {
  if (uid == _boundUid) return;
  _boundUid = uid;

  // reset user-specific UI state
  query = "";
  error = null;

  
  filtered = List<Clinic>.from(_all);

  notifyListeners();
}


  // Extracts table rows like: <th>HCI_NAME</th> <td>Acumed Medical Group</td>
  Map<String, String> _parseDescriptionTable(String html) {
    final Map<String, String> out = {};

    final rowRegex = RegExp(
      r"<th>\s*([^<]+?)\s*<\/th>\s*<td>\s*([^<]*?)\s*<\/td>",
      caseSensitive: false,
    );

    for (final m in rowRegex.allMatches(html)) {
      final key = m.group(1)?.trim() ?? "";
      final value = (m.group(2) ?? "").trim();
      if (key.isNotEmpty) out[key] = value;
    }

    return out;
  }

  String _buildAddress(Map<String, String> f) {
    // Combine: BLK_HSE_NO, FLOOR_NO, UNIT_NO, STREET_NAME, BUILDING_NAME
    final blk = f["BLK_HSE_NO"] ?? "";
    final floor = f["FLOOR_NO"] ?? "";
    final unit = f["UNIT_NO"] ?? "";
    final street = f["STREET_NAME"] ?? "";
    final building = f["BUILDING_NAME"] ?? "";

    final unitText = (floor.isNotEmpty || unit.isNotEmpty)
        ? "#$floor-$unit"
        : "";

    final parts = <String>[
      if (blk.isNotEmpty) blk,
      if (street.isNotEmpty) street,
      if (unitText.isNotEmpty) unitText,
      if (building.isNotEmpty) building,
    ];

    return parts.join(", ");
  }

  Future<void> loadClinics() async {
    if (_all.isNotEmpty) {
      _applyFilter();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final raw = await rootBundle.loadString("assets/chas_clinics.geojson");//load raw json
      final jsonData = json.decode(raw) as Map<String, dynamic>; //convert to raw map
      final features = (jsonData["features"] as List);

      for (final f in features) {
        final props = (f["properties"] as Map<String, dynamic>);
        final desc = (props["Description"] ?? "").toString();
        final fields = _parseDescriptionTable(desc);

        final coords = (f["geometry"]["coordinates"] as List);
        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();

        final id = (fields["HCI_CODE"] ?? props["Name"] ?? "$lat,$lng").toString();// storage
        final name = (fields["HCI_NAME"] ?? "").toString();
        final phone = (fields["HCI_TEL"] ?? "").toString();
        final postal = (fields["POSTAL_CD"] ?? "").toString();
        final address = _buildAddress(fields);//combine

        if (name.trim().isEmpty) continue;

        _all.add(Clinic(
          id: id,
          name: name,
          phone: phone,
          postal: postal,
          address: address,
          lat: lat,
          lng: lng,
        ));
      }

      _applyFilter();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    query = q;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered = List<Clinic>.from(_all);
      return;
    }

    filtered = _all.where((c) { //filter
      return c.name.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q) ||
          c.postal.toLowerCase().contains(q);
    }).toList();
  }
}
