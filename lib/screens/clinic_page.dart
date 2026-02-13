import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/clinic_provider.dart';
import '../providers/profile_provider.dart';
import '../models/clinic.dart';

import 'home_page.dart';
import 'show_med_page.dart';
import 'show_health_log.dart';
import 'profile_page.dart';

class ClinicPage extends StatefulWidget {
  const ClinicPage({super.key});

  @override
  State<ClinicPage> createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Clinic? _selected;

  
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<ClinicProvider>();

      //  RESET when ClinicPage opens
      _searchCtrl.clear();
      p.setQuery("");
      setState(() {
        _markers = {};
        _selected = null;
      });

      await p.loadClinics();
      if (!mounted) return;
      _syncMapAndSelection(p.filtered);
    });
  }

  @override
  void dispose() {
    
    _searchCtrl.dispose();
    super.dispose();
  }

  void _syncMapAndSelection(List<Clinic> clinics) {
    if (clinics.isEmpty) {
      setState(() {
        _markers = {};
        _selected = null;
      });
      return;
    }

    final markers = clinics.take(80).map((c) {
      return Marker(
        markerId: MarkerId(c.id),
        position: LatLng(c.lat, c.lng),
        infoWindow: InfoWindow(title: c.name, snippet: c.address),
        onTap: () => _selectClinic(c),
      );
    }).toSet();

    setState(() {
      _markers = markers;
      _selected ??= clinics.first;
    });

    final first = clinics.first;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(first.lat, first.lng), 12.5),
    );
  }

  void _selectClinic(Clinic c) {
    setState(() => _selected = c);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(c.lat, c.lng), 15),
    );
  }

  Future<void> _openDirections(Clinic c) async {
    final url =
        "https://www.google.com/maps/search/?api=1&query=${c.lat},${c.lng}";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _callClinic(Clinic c) async {
    final tel = c.phone.trim();
    if (tel.isEmpty) return;
    await launchUrl(Uri.parse("tel:$tel"));
  }

  Widget _clinicTile(Clinic c) {
    return InkWell(
      onTap: () => _selectClinic(c),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                c.address,
                style: const TextStyle(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                "Singapore ${c.postal}",
                style: const TextStyle(color: Colors.black45),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _openDirections(c),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7E8FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Directions",
                          style: TextStyle(
                            color: Color(0xFF1557FF),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _callClinic(c),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD6D6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Call",
                          style: TextStyle(
                            color: Color(0xFFB00020),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ClinicProvider>();

    final isDark = context.watch<ProfileProvider>().darkMode;
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          "CHAS Clinics",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (q) {
                          p.setQuery(q);
                          _syncMapAndSelection(p.filtered);
                        },
                      ),
                      const SizedBox(height: 12),

                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(1.3521, 103.8198),
                              zoom: 11,
                            ),
                            markers: _markers,
                            onMapCreated: (c) {
                              _mapController = c;
                              _syncMapAndSelection(p.filtered);
                            },
                            myLocationEnabled: false,
                            myLocationButtonEnabled: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (p.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Error: ${p.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Results (${p.filtered.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (p.filtered.isEmpty)
                        Text(
                          "No clinics found.",
                          style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              p.filtered.length > 20 ? 20 : p.filtered.length,
                          itemBuilder: (_, i) => _clinicTile(p.filtered[i]),
                        ),

                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF0F0F10) : Colors.white,
        currentIndex: 3,
        selectedItemColor: Colors.red,
        unselectedItemColor: isDark ? Colors.white70 : Colors.black45,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 3) return;

          Widget page;
          switch (i) {
            case 0:
              page = const HomePage();
              break;
            case 1:
              page = const ShowMedPage();
              break;
            case 2:
              page = const ShowHealthLogPage();
              break;
            case 4:
              page = const ProfilePage();
              break;
            default:
              page = const HomePage();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined), label: "Meds"),
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined), label: "Health"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Clinic"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
