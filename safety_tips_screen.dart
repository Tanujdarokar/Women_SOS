import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Map<String, dynamic>> tips = [
      {
        "title": "Stay Aware",
        "desc": "Always be aware of your surroundings. Avoid using your phone or headphones in isolated areas.",
        "icon": Icons.visibility_rounded,
        "color": Colors.blue
      },
      {
        "title": "Trust Your Instincts",
        "desc": "If a situation feels wrong, it probably is. Don't hesitate to leave or seek help immediately.",
        "icon": Icons.psychology_rounded,
        "color": Colors.purple
      },
      {
        "title": "Share Your Route",
        "desc": "Before traveling, share your route and estimated arrival time with a trusted contact.",
        "icon": Icons.share_location_rounded,
        "color": Colors.green
      },
      {
        "title": "Emergency SOS",
        "desc": "Keep your phone accessible and know how to trigger the SOS alert quickly.",
        "icon": Icons.sos_rounded,
        "color": Colors.red
      },
      {
        "title": "Carry Self-Defense",
        "desc": "Consider carrying pepper spray or a safety whistle and know how to use them effectively.",
        "icon": Icons.security_rounded,
        "color": Colors.orange
      },
      {
        "title": "Stay in Light",
        "desc": "Wait for public transport in well-lit, populated areas. Avoid walking in dark alleys.",
        "icon": Icons.lightbulb_rounded,
        "color": Colors.amber
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Insights"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              "Essential Safety Tips",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              "Simple habits that can keep you safe in any situation.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            color: tip['color'],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: tip['color'].withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(tip['icon'], color: tip['color'], size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tip['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          tip['desc'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
