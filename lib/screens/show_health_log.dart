import 'package:eldercare/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_log.dart';
import '../providers/auth_provider.dart';
import '../providers/health_log_provider.dart';
import '../providers/profile_provider.dart'; 
import 'add_health_log.dart';

import 'clinic_page.dart';
import 'home_page.dart';
import 'show_med_page.dart';

class ShowHealthLogPage extends StatefulWidget {
  const ShowHealthLogPage({super.key});

  @override
  State<ShowHealthLogPage> createState() => _ShowHealthLogPageState();
}

class _ShowHealthLogPageState extends State<ShowHealthLogPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<HealthLogProvider>().loadOnce();
  }

  String _formatDisplayDate(DateTime d) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHealthLogPage()),
    );

    setState(() {
      _loadFuture = context.read<HealthLogProvider>().refresh();
    });
  }

  Future<void> _openEdit(HealthLog log) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddHealthLogPage(existing: log)),
    );

    setState(() {
      _loadFuture = context.read<HealthLogProvider>().refresh();
    });
  }

  Future<void> _confirmDelete(HealthLog log) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete log?"),
        content: const Text("This will remove the health log permanently."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await context.read<HealthLogProvider>().deleteLog(log);
      setState(() {
        _loadFuture = context.read<HealthLogProvider>().refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final isDark = context.watch<ProfileProvider>().darkMode; 
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);
    final emptyText = isDark ? Colors.white70 : Colors.black45;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF00B26B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Health Log",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _openAdd,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
          ),
        ],
      ),

      body: SafeArea(
        child: user == null
            ? Center(
                child: Text(
                  "Please log in first.",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
              )
            : FutureBuilder<void>(
                future: _loadFuture,
                builder: (context, snap) {
                  final provider = context.watch<HealthLogProvider>();

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

                  final logs = provider.logs;

                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monitor_heart_outlined, size: 60, color: emptyText),
                          const SizedBox(height: 12),
                          Text(
                            "No health logs yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap + to add your first health log",
                            style: TextStyle(fontSize: 14, color: emptyText),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final log = logs[i];
                        return _HealthLogCard(
                          dateText: _formatDisplayDate(log.date),
                          status: log.status,
                          systolic: log.systolic,
                          diastolic: log.diastolic,
                          heartRate: log.heartRate,
                          onEdit: () => _openEdit(log),
                          onDelete: () => _confirmDelete(log),
                        );
                      },
                    ),
                  );
                },
              ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF0F0F10) : Colors.white, 
        currentIndex: 2,
        selectedItemColor: const Color(0xFF00B26B),
        unselectedItemColor: isDark ? Colors.white70 : Colors.black45, 
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 2) return;

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

class _HealthLogCard extends StatelessWidget {
  final String dateText;
  final String status;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HealthLogCard({
    required this.dateText,
    required this.status,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNormal = status == "Normal";

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
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNormal ? const Color(0xFFD7F6E6) : const Color(0xFFFFD6D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: isNormal ? const Color(0xFF0D7A48) : const Color(0xFFB00020),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blood Pressure",
                      style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$systolic/$diastolic",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      "mmHg",
                      style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Heart Rate",
                      style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$heartRate",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      "bpm",
                      style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
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
