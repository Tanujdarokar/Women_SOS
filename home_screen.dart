import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:women_sos/main.dart';
import 'package:women_sos/screens/about_screen.dart';
import 'package:women_sos/screens/contact_screen.dart';
import 'package:women_sos/screens/dashborad_screen.dart';
import 'package:women_sos/screens/evidence_history_screen.dart';
import 'package:women_sos/screens/help_support_screen.dart';
import 'package:women_sos/screens/login_screen.dart';
import 'package:women_sos/screens/map_view.dart';
import 'package:women_sos/screens/profile_screen.dart';
import 'package:women_sos/screens/safety_tips_screen.dart';
import 'package:women_sos/screens/vedio_camera_screen.dart';
import 'package:women_sos/screens/notification_screen.dart';
import 'package:women_sos/screens/emergency_contact_screen.dart';
import 'package:women_sos/services/api_service.dart';
import 'package:women_sos/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MainDashboard(),
    const MapView(),
    const CameraVideoScreen(mode: "Camera"),
    const CameraVideoScreen(mode: "Video"),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Women SOS", style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildModernDrawer(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, "Home"),
                _buildNavItem(1, Icons.map_rounded, "Explore"),
                _buildNavItem(2, Icons.camera_alt_rounded, "Safety"),
                _buildNavItem(3, Icons.videocam_rounded, "Capture"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    String name = authState.name ?? "Safety User";
    String email = authState.email ?? "user@safetyapp.com";
    bool isGuest = authState.userId == null;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _createModernHeader(context, name, email, isGuest),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildAnimatedDrawerItem(
                  context,
                  Icons.home_max_rounded,
                  "Dashboard",
                  0,
                  () => Navigator.pop(context),
                  isSelected: _currentIndex == 0,
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.phone_in_talk_rounded,
                  "Emergency Hub",
                  1,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyContactScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.person_pin_rounded,
                  "My Profile",
                  2,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.contacts_rounded,
                  "Trusted Contacts",
                  3,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactsScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.health_and_safety_rounded,
                  "Safety Tips",
                  4,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SafetyTipsScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.folder_shared_rounded,
                  "Evidence Box",
                  5,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EvidenceHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(indent: 10, endIndent: 10),
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.support_agent_rounded,
                  "Help Center",
                  6,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedDrawerItem(
                  context,
                  Icons.info_rounded,
                  "About App",
                  7,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildLogoutSection(context, isGuest),
        ],
      ),
    );
  }

  Widget _createModernHeader(
    BuildContext context,
    String name,
    String email,
    bool isGuest,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isGuest
                          ? Icons.person_outline_rounded
                          : Icons.person_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  ref.watch(themeProvider) == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  final current = ref.read(themeProvider);
                  ref.read(themeProvider.notifier).state =
                      current == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.7);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, bool isGuest) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () async {
          if (!isGuest) await ref.read(authProvider.notifier).logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isGuest
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGuest ? Icons.login_rounded : Icons.logout_rounded,
                color: isGuest ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isGuest ? "Sign In / Register" : "Logout",
                style: TextStyle(
                  color: isGuest ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
