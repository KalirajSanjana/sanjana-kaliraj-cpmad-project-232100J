import 'package:eldercare/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_log.dart';
import '../providers/auth_provider.dart';
import '../providers/health_log_provider.dart';
import '../providers/profile_provider.dart'; // 

import 'clinic_page.dart';
import 'home_page.dart';
import 'show_med_page.dart';
//import 'show_health_log.dart';

class AddHealthLogPage extends StatefulWidget {
  final HealthLog? existing;

  const AddHealthLogPage({super.key, this.existing});

  @override
  State<AddHealthLogPage> createState() => _AddHealthLogPageState();
}

class _AddHealthLogPageState extends State<AddHealthLogPage> {
  final _formKey = GlobalKey<FormState>();

  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();

  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();

    final ex = widget.existing;
    if (ex != null) {
      _date = ex.date;
      _sysCtrl.text = ex.systolic.toString();
      _diaCtrl.text = ex.diastolic.toString();
      _hrCtrl.text = ex.heartRate.toString();
    }
  }

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _hrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatDisplayDate(DateTime d) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }

  InputDecoration _fieldDeco({Widget? suffixIcon, String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid;
    if (uid == null) return;

    final ok = _formKey.currentState!.validate();
    if (!ok) return;

    final healthProvider = context.read<HealthLogProvider>();

    final systolic = int.parse(_sysCtrl.text.trim());
    final diastolic = int.parse(_diaCtrl.text.trim());
    final heartRate = int.parse(_hrCtrl.text.trim());

    final isEdit = widget.existing != null;

    final log = HealthLog(
      id: widget.existing?.id ?? "",
      date: _date,
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    try {
      if (isEdit) {
        await healthProvider.updateLog(uid, log);
      } else {
        await healthProvider.addLog(uid, log);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final healthProvider = context.watch<HealthLogProvider>();

    //  dark mode flag from ProfileProvider
    final isDark = context.watch<ProfileProvider>().darkMode;

    //  only background changes
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF00B26B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? "Edit Health Log" : "Add Health Log",
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, //  keep card white
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label("Date"),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: _fieldDeco(
                        hint: "dd/mm/yyyy",
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                      child: Text(
                        _formatDisplayDate(_date),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label("Systolic"),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _sysCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _fieldDeco(hint: ""),
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? "");
                                if (n == null || n <= 0) return "Enter systolic";
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label("Diastolic"),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _diaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _fieldDeco(hint: ""),
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? "");
                                if (n == null || n <= 0) return "Enter diastolic";
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const _Label("Heart Rate"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _hrCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDeco(hint: ""),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? "");
                      if (n == null || n <= 0) return "Enter heart rate";
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B26B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: healthProvider.isSaving ? null : _save,
                      child: Text(
                        healthProvider.isSaving
                            ? "Saving..."
                            : (isEdit ? "Update Health Log" : "Save Health Log"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // bottom nav dark bg + white icons in dark mode
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
            case 3:
              page = const ClinicPage();
              break;
            case 4:
              page = const ProfilePage();
              break;
            default:
              page = const HomePage();
          }

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => page),
  (_) => false,
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Colors.black87, // stays readable because card is white
      ),
    );
  }
}
