import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../providers/profile_provider.dart'; 
import 'add_med_page.dart';
import 'clinic_page.dart';
import 'home_page.dart';
import 'show_health_log.dart';
import 'profile_page.dart';

class ShowMedPage extends StatefulWidget {
  const ShowMedPage({super.key});

  @override
  State<ShowMedPage> createState() => _ShowMedPageState();
}

class _ShowMedPageState extends State<ShowMedPage> {
  int currentIndex = 1;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<MedicationProvider>().loadOnce();
  }

  Future<void> _openAddMed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedPage()),
    );

    setState(() {
      _loadFuture = context.read<MedicationProvider>().refresh();
    });
  }

  Future<void> _openEditMed(Medication med) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMedPage(existingMed: med)),
    );

    setState(() {
      _loadFuture = context.read<MedicationProvider>().refresh();
    });
  }

  Future<void> _confirmDelete(Medication med) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete medication?"),
        content: Text("Delete ${med.name}? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await context.read<MedicationProvider>().deleteMedication(med.id);
      setState(() {
        _loadFuture = context.read<MedicationProvider>().refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicationProvider>();

    final isDark = context.watch<ProfileProvider>().darkMode; 
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);
    final emptyText = isDark ? Colors.white70 : Colors.black45;
    final emptyIcon = isDark ? Colors.white38 : Colors.black26;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3CFF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Medications",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _openAddMed,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<void>(
            future: _loadFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Text(
                    "Error: ${provider.error}",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                );
              }

              final meds = provider.meds;

              if (meds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medication_outlined, size: 60, color: emptyIcon),
                      const SizedBox(height: 12),
                      Text(
                        "No medications yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tap + to add your first reminder",
                        style: TextStyle(fontSize: 14, color: emptyText),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: meds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final m = meds[i];
                  return _MedicationCard(
                    name: m.name,
                    dose: m.dose,
                    frequency: m.frequency,
                    time: m.time,
                    onEdit: () => _openEditMed(m),
                    onDelete: () => _confirmDelete(m),
                  );
                },
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF0F0F10) : Colors.white, 
        currentIndex: 1,
        selectedItemColor: const Color(0xFF1F3CFF),
        unselectedItemColor: isDark ? Colors.white70 : Colors.black45, 
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 1) return;

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
            case 3:
              page = const ClinicPage();
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
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: "Meds"),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart_outlined), label: "Health"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Clinic"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String name;
  final String dose;
  final String frequency;
  final String time;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.time,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                frequency,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dose,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.black45),
              const SizedBox(width: 10),
              Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: "Edit",
                  bg: const Color(0xFFCFE3FF),
                  fg: const Color(0xFF1F3CFF),
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionButton(
                  text: "Delete",
                  bg: const Color(0xFFF6C7C7),
                  fg: const Color(0xFFE14B4B),
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
    );
  }
}
