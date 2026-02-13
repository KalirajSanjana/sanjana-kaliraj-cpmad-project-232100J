import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/profile_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});


  static const String appName = "ElderCare+";
  static const String tagline = "Your smart health companion";
  static const String description =
      "ElderCare+ is a smart health companion that helps users manage medications, track health vitals, and find CHAS clinics easily.";

  static const String companyName = "ElderCare Team";
  static const String companyPhone = "+65 6123 4567";
  static const String companyEmail = "eldercare.feedback@gmail.com";

  static const String developerName = "Kaliraj Sanjana";

  Future<void> callCompany(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+6561234567'); 

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open dialer: $e")),
      );
    }
  }

  Future<void> emailFeedback(BuildContext context) async {
    final email = Uri(
      scheme: 'mailto',
      path: 'eldercare.feedback@gmail.com',
      queryParameters: {
        'subject': 'ElderCare Feedback',
        'body': 'Hi ElderCare Team,\n\n',
      },
    );

    try {
      final ok = await canLaunchUrl(email);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No email app found on this device.")),
        );
        return;
      }
      await launchUrl(email, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //reads the SAVED mode (p.darkMode)
    final isDark = context.watch<ProfileProvider>().darkMode;

    // page bg changes only after Save 
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);
    final subColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("About",
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: const Color(0xFF1F3CFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // keep cards white 
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F3CFF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        size: 30,
                        color: Color(0xFF1F3CFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            appName,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            tagline,
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Text(
                            description,
                            style: TextStyle(color: Colors.black87, height: 1.35),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _InfoCard(
                title: "Company",
                rows: const [
                  _InfoRow(label: "Name", value: companyName),
                  _InfoRow(label: "Phone", value: companyPhone),
                  _InfoRow(label: "Email", value: companyEmail),
                ],
              ),

              const SizedBox(height: 12),

              _InfoCard(
                title: "Developer",
                rows: const [
                  _InfoRow(label: "Name", value: developerName),
                ],
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => callCompany(context),
                      icon: const Icon(Icons.call),
                      label: const Text("Call Company"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => emailFeedback(context),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text("Email Feedback"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1F3CFF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFF1F3CFF)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              
              Text(
                isDark ? "" : "",
                style: TextStyle(color: subColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}
