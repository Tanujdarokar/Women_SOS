import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SMSService {
  static Future<void> sendSOSAlert(List<Map<String, dynamic>> contacts) async {
    final String message = "Help me! I'm in danger. Track my location here: [Location Link]";
    
    debugPrint("Sending SOS alert to ${contacts.length} contacts...");
    
    for (var contact in contacts) {
      final String number = contact['number'] ?? "";
      if (number.isNotEmpty) {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: number,
          queryParameters: <String, String>{
            'body': message,
          },
        );

        try {
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
          } else {
            debugPrint("Could not launch SMS for $number");
          }
        } catch (e) {
          debugPrint("Error sending SMS to $number: $e");
        }
      }
    }
  }

  static Future<void> sendEvidenceAlert(String type, List<Map<String, dynamic>> contacts) async {
    debugPrint("Sending $type alert to ${contacts.length} contacts...");
    for (var contact in contacts) {
      debugPrint("Alerting ${contact['name']} at ${contact['number']}");
    }
  }
}
