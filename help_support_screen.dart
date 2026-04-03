import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "We're here to support you 24/7. Choose an option below to get assistance.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildSupportOption(
              context,
              Icons.contact_support_rounded,
              "Contact Us",
              "Get in touch with our team for any queries.",
              Colors.blue,
            ),
            _buildSupportOption(
              context,
              Icons.question_answer_rounded,
              "FAQs",
              "Find quick answers to common questions.",
              Colors.orange,
            ),
            _buildSupportOption(
              context,
              Icons.email_rounded,
              "Email Support",
              "Send us an email for detailed assistance.",
              Colors.green,
            ),
            _buildSupportOption(
              context,
              Icons.phone_rounded,
              "Emergency Helpline",
              "Direct call to our safety emergency desk.",
              Colors.red,
            ),
            const SizedBox(height: 30),
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildFAQTile("How does the SOS alert work?", "When you press the SOS button or shake your device, the app sends your live location to your trusted contacts via SMS and notifications."),
            _buildFAQTile("Is my data safe?", "Yes, we use industry-standard encryption to protect your personal data and location information."),
            _buildFAQTile("Can I add multiple guardians?", "Yes, you can add up to 5 trusted contacts in the 'Trusted Contacts' section."),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, IconData icon, String title, String desc, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        onTap: () {
          // Add logic to contact or open FAQ
        },
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ),
      ],
    );
  }
}
