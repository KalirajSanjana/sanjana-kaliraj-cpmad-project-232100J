class Clinic {
  final String id;
  final String name;     // HCI_NAME
  final String address;  // build from blk + street + building + unit
  final String postal;   // POSTAL_CD
  final String phone;    // HCI_TEL
  final double lat;
  final double lng;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.postal,
    required this.phone,
    required this.lat,
    required this.lng,
  });
}
