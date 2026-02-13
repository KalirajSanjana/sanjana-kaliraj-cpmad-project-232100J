// Please click save after the toggle 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import 'clinic_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'show_med_page.dart';
import 'show_health_log.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameCtrl = TextEditingController();

  bool? _tempDarkMode; // temp value won’t apply until Save

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<ProfileProvider>();
      await p.loadProfile();
      if (!mounted) return;

      setState(() {
        _usernameCtrl.text = p.username;
        _tempDarkMode = p.darkMode; 
      });
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageDialog() async {
    final p = context.read<ProfileProvider>();

    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take photo"),
              onTap: () async {
                Navigator.pop(ctx);
                await p.pickAndUploadProfileImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from gallery"),
              onTap: () async {
                Navigator.pop(ctx);
                await p.pickAndUploadProfileImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final user = p.user;

    // App theme follows saved value only.
    
    final isDark = p.darkMode;

    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F7FB);
    final nameColor = isDark ? Colors.white : Colors.black;
    final emailColor = isDark ? Colors.white70 : Colors.black45;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: SafeArea(
        child: p.loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            // Avatar
                            GestureDetector(
                              onTap: p.saving ? null : _pickImageDialog,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Colors.black12,
                                    backgroundImage: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
                                        ? NetworkImage(p.photoUrl!)
                                        : null,
                                    child: (p.photoUrl == null || p.photoUrl!.isEmpty)
                                        ? const Icon(Icons.person, size: 48, color: Colors.black45)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              (p.username.trim().isNotEmpty)
                                  ? p.username.trim()
                                  : (user?.displayName?.trim().isNotEmpty == true
                                      ? user!.displayName!.trim()
                                      : "User"),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: nameColor,
                              ),
                            ),

                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? "No email",
                              style: TextStyle(color: emailColor),
                            ),

                            const SizedBox(height: 18),

                            // Card stays white
                            Container(
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
                                  const Text(
                                    "Username",
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _usernameCtrl,
                                    
                                    onChanged: p.setUsername,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF1F3F6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Dark Mode",
                                          style: TextStyle(fontWeight: FontWeight.w900),
                                        ),
                                      ),

                                      // toggle
                                      Switch(
                                        value: _tempDarkMode ?? p.darkMode,
                                        activeColor: const Color(0xFF7C3AED),
                                        onChanged: (v) {
                                          setState(() => _tempDarkMode = v);
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),
                                  const Text(
                                    "Changes apply after you press Save Changes",
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            if (p.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  p.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Save Changes
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.65),
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: p.saving
                                    ? null
                                    : () async {
                                        // commit changes only on save
                                        p.setUsername(_usernameCtrl.text);
                                        p.setDarkMode(_tempDarkMode ?? p.darkMode);

                                        await p.saveChanges();
                                        if (!mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Saved!")),
                                        );
                                      },
                                child: Text(
                                  p.saving ? "Saving..." : "Save Changes",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Logout
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8B4FE),
                                  foregroundColor: Colors.black87,
                                  disabledBackgroundColor: const Color(0xFFD8B4FE).withOpacity(0.65),
                                  disabledForegroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: p.saving
                                    ? null
                                    : () async {
                                        await p.logout();
                                        if (!mounted) return;
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (_) => const LoginPage()),
                                          (_) => false,
                                        );
                                      },
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF0F0F10) : Colors.white,
        currentIndex: 4,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: isDark ? Colors.white70 : Colors.black45,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 4) return;

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
