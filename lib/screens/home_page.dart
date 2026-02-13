import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

import 'about_page.dart';
import 'clinic_page.dart';
import 'profile_page.dart';
import 'show_med_page.dart';
import 'show_health_log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late Future<List<Medication>> _loadMedsFuture;

  @override
  void initState() {
    super.initState();
    _loadMedsFuture = context.read<MedicationProvider>().loadOnce();
  }

  void _goTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();

    final isDark = profile.darkMode;
    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);

    final name = profile.username.trim().isNotEmpty
        ? profile.username.trim()
        : (auth.user?.displayName?.trim().isNotEmpty == true
            ? auth.user!.displayName!.trim()
            : "User");

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, 
        statusBarIconBrightness: Brightness.light, 
        statusBarBrightness: Brightness.dark, 
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true, 
        backgroundColor: bg,

        body: SafeArea(
          top: false, 
          child: Column(
            children: [
              _BlueHeader(
                userName: name,
                onAboutTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.medication_outlined,
                            iconColor: const Color(0xFF1F3CFF),
                            title: "Medications",
                            subtitle: "Manage Reminders",
                            onTap: () => _goTo(context, const ShowMedPage()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.monitor_heart_outlined,
                            iconColor: const Color(0xFF00A66A),
                            title: "Health Log",
                            subtitle: "Track Vitals",
                            onTap: () => _goTo(context, const ShowHealthLogPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFFF4D4D),
                            title: "Find Clinics",
                            subtitle: "CHAS Locations",
                            onTap: () => _goTo(context, const ClinicPage()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF7C3AED),
                            title: "Profile",
                            subtitle: "Your Settings",
                            onTap: () => _goTo(context, const ProfilePage()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today’s Reminders",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: FutureBuilder<List<Medication>>(
                            future: _loadMedsFuture,
                            builder: (context, snap) {
                              final provider = context.watch<MedicationProvider>();

                              if (snap.connectionState == ConnectionState.waiting &&
                                  provider.meds.isEmpty) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (provider.error != null) {
                                return Center(child: Text("Error: ${provider.error}"));
                              }

                              final meds = provider.meds;

                              if (meds.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No reminders yet.\nAdd one in Medications.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              }

                              final sorted = [...meds]..sort((a, b) {
                                return _parseTimeToMinutes(a.time)
                                    .compareTo(_parseTimeToMinutes(b.time));
                              });

                              final top = sorted.take(3).toList();

                              return ListView.separated(
                                itemCount: top.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final m = top[i];

                                  return _ReminderTile(
                                    bg: i % 2 == 0
                                        ? const Color(0xFFFFF5CC)
                                        : const Color(0xFFEAF3FF),
                                    title: m.name,
                                    time: m.time,
                                    subtitle: "${m.dose} • ${m.frequency}",
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: isDark ? const Color(0xFF0F0F10) : Colors.white,
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFF1F3CFF),
          unselectedItemColor: isDark ? Colors.white70 : Colors.black45,
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            if (i == currentIndex) return;

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

            _goTo(context, page);
          },
          selectedFontSize: 13,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: "Meds"),
            BottomNavigationBarItem(icon: Icon(Icons.monitor_heart_outlined), label: "Health"),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Clinic"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }

  static int _parseTimeToMinutes(String time) {
    try {
      final t = time.trim().toUpperCase();
      final parts = t.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      final ampm = parts.length > 1 ? parts[1] : "AM";

      if (ampm == "PM" && h != 12) h += 12;
      if (ampm == "AM" && h == 12) h = 0;

      return h * 60 + m;
    } catch (_) {
      return 99999;
    }
  }
}

class _BlueHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onAboutTap;

  const _BlueHeader({
    required this.userName,
    required this.onAboutTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          
          ClipPath(
            clipper: _CurveClipper(),
            child: Container(
              height: 170,
              color: const Color(0xFF1F3CFF),
            ),
          ),

          
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: onAboutTap,
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  tooltip: "About",
                ),
              ),
            ),
          ),

          
          Positioned(
            left: 18,
            top: 32,
            right: 60, 
            child: Text(
              "Welcome $userName !",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Positioned(
            left: 18,
            top: 76,
            child: Text(
              "How are you feeling today?",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.62,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Color bg;
  final String title;
  final String time;
  final String subtitle;

  const _ReminderTile({
    required this.bg,
    required this.title,
    required this.time,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.black54, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(time, style: const TextStyle(color: Colors.black54, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
