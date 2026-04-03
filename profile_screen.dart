import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:women_sos/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    String name = authState.name ?? "Safety User";
    String email = authState.email ?? "user@safetyapp.com";
    String phone = authState.phone ?? "Not Provided";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Modern Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 3),
                      color: theme.colorScheme.primary.withOpacity(0.05),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 70,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Account Details Card
            _buildModernSection(
              context,
              "Account Details",
              [
                _buildInfoRow(context, Icons.person_outline_rounded, "Full Name", name),
                const Divider(height: 1, indent: 55),
                _buildInfoRow(context, Icons.email_outlined, "Email Address", email),
                const Divider(height: 1, indent: 55),
                _buildInfoRow(context, Icons.phone_android_rounded, "Phone Number", phone),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Settings/Safety Card
            _buildModernSection(
              context,
              "Safety Settings",
              [
                _buildInfoRow(context, Icons.notifications_none_rounded, "Emergency Alerts", "Enabled"),
                const Divider(height: 1, indent: 55),
                _buildInfoRow(context, Icons.location_on_outlined, "Real-time Tracking", "Active"),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Action Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile editing feature coming soon!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("EDIT PROFILE"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.pink.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}
