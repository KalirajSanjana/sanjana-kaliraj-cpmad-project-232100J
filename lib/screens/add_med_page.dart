import 'package:eldercare/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../providers/profile_provider.dart'; 

import 'clinic_page.dart';
import 'home_page.dart';
//import 'show_med_page.dart';
import 'show_health_log.dart';

class AddMedPage extends StatefulWidget {
  final Medication? existingMed;

  const AddMedPage({super.key, this.existingMed});

  @override
  State<AddMedPage> createState() => _AddMedPageState();
}

class _AddMedPageState extends State<AddMedPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();

  String _frequency = "Daily";
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  bool get isEdit => widget.existingMed != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final m = widget.existingMed!;
      _nameCtrl.text = m.name;
      _doseCtrl.text = m.dose;
      _frequency = m.frequency;
      _time = _parseTime(m.time) ?? _time;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return null;

      final hm = parts[0].split(':');
      if (hm.length != 2) return null;

      int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      final suffix = parts[1].toUpperCase();

      if (suffix == "PM" && hour != 12) hour += 12;
      if (suffix == "AM" && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $suffix";
  }

  InputDecoration _fieldDeco({Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final medsProvider = context.read<MedicationProvider>();

    final med = Medication(
      id: widget.existingMed?.id ?? "",
      name: _nameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      frequency: _frequency,
      time: _formatTime(_time),
    );

    try {
      if (isEdit) {
        await medsProvider.updateMedication(med);
      } else {
        await medsProvider.addMedication(med);
      }

      if (!mounted) return;
      Navigator.pop(context, med);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medsProvider = context.watch<MedicationProvider>();

 
    final isDark = context.watch<ProfileProvider>().darkMode;


    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3CFF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? "Edit Medication" : "Add Medication",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label("Medication Name"),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _nameCtrl,
                                style: const TextStyle(fontSize: 16),
                                decoration: _fieldDeco(),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? "Enter medication name"
                                    : null,
                              ),
                              const SizedBox(height: 18),

                              const _Label("Dosage"),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _doseCtrl,
                                style: const TextStyle(fontSize: 16),
                                decoration: _fieldDeco(),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? "Enter dosage"
                                    : null,
                              ),
                              const SizedBox(height: 18),

                              const _Label("Frequency"),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _frequency,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                decoration: _fieldDeco(suffixIcon: null),
                                items: const [
                                  DropdownMenuItem(value: "Daily", child: Text("Daily")),
                                  DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
                                  DropdownMenuItem(value: "As Needed", child: Text("As Needed")),
                                ],
                                onChanged: (v) => setState(() => _frequency = v ?? "Daily"),
                              ),

                              const SizedBox(height: 18),

                              const _Label("Reminder Time"),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: _fieldDeco(
                                    suffixIcon: const Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _formatTime(_time),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F3CFF),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF1F3CFF).withOpacity(0.65),
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: medsProvider.isSaving ? null : _save,
                                  child: Text(
                                    medsProvider.isSaving
                                        ? "Saving..."
                                        : (isEdit ? "Update Medication" : "Save Medication"),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                       
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
        color: Colors.black87, 
      ),
    );
  }
}
