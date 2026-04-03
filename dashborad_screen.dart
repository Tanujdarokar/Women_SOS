import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_sos/screens/map_view.dart';
import 'package:women_sos/screens/contact_screen.dart';
import 'package:women_sos/services/api_service.dart';
import 'package:women_sos/services/sms_services.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildSOSSection(context),
          const SizedBox(height: 40),
          _buildSectionTitle("Emergency Contacts"),
          const SizedBox(height: 15),
          _buildEmergencyGrid(context),
          const SizedBox(height: 30),
          _buildSectionTitle("Quick Services"),
          const SizedBox(height: 15),
          _buildServicesRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Women SOS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                Text(
                  "Your Safety, Our Priority",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, color: Colors.pink),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSOSSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            "Emergency SOS",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Hold for 3 seconds to send alert",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onLongPress: () => _showSOSAlert(context),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF4081), Color(0xFFC2185B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.touch_app, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEmergencyGrid(BuildContext context) {
    return Row(
      children: [
        _buildContactCard("Police", "100", Colors.blue, Icons.local_police, () => _makePhoneCall("100")),
        const SizedBox(width: 15),
        _buildContactCard("Ambulance", "102", Colors.green, Icons.medical_services, () => _makePhoneCall("102")),
      ],
    );
  }

  Widget _buildContactCard(String title, String number, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(number, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildServiceItem(Icons.fire_truck, "Fire", Colors.orange, () => _makePhoneCall("101")),
        _buildServiceItem(Icons.family_restroom, "Guardian", Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen()));
        }),
        _buildServiceItem(Icons.location_on, "Tracking", Colors.red, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MapView()));
        }),
        _buildServiceItem(Icons.more_horiz, "More", Colors.grey, () {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("More services coming soon!")),
          );
        }),
      ],
    );
  }

  Widget _buildServiceItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showSOSAlert(BuildContext context) async {
    // 1. Fetch Trusted Contacts
    final contacts = await ApiService.getContacts();
    
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No trusted contacts found! Please add some first."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 2. Send SMS Alert to all contacts
    await SMSService.sendSOSAlert(contacts);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Help message sent to trusted contacts!"),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
