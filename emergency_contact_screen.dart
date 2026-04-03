import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  final List<Map<String, String>> emergencyContacts = const [
    {"name": "Police", "number": "100", "desc": "National Police Emergency"},
    {"name": "Ambulance", "number": "102", "desc": "Medical Emergency"},
    {"name": "Fire Brigade", "number": "101", "desc": "Fire Emergency"},
    {"name": "Women Helpline", "number": "1091", "desc": "Domestic Violence/Safety"},
    {"name": "Child Helpline", "number": "1098", "desc": "Child Protection"},
    {"name": "Pink Police", "number": "1515", "desc": "Specific safety for women"},
    {"name": "National Emergency", "number": "112", "desc": "Single emergency number"},
    {"name": "Senior Citizen", "number": "14567", "desc": "Elderly Care & Help"},
    {"name": "Railway Security", "number": "182", "desc": "RPF Security Help"},
    {"name": "Anti-Ragging", "number": "1800-180-5522", "desc": "Student Security Hub"},
    {"name": "Disaster Management", "number": "108", "desc": "Natural Calamities"},
    {"name": "Cyber Crime", "number": "1930", "desc": "Financial & Online Security"},
    {"name": "Tourist Helpline", "number": "1363", "desc": "Foreign & Local Travel"},
    {"name": "Mental Health", "number": "080-46110007", "desc": "NIMHANS Psychosocial Support"},
  ];

  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Hub"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              "Global Help Lines",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              "Quick access to official emergency services.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = emergencyContacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_rounded, color: Colors.red),
                    ),
                    title: Text(
                      contact["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact["desc"]!, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          contact["number"]!,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _makeCall(contact["number"]!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.call),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
