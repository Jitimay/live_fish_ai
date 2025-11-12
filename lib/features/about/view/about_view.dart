import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About LiveFish AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                height: 100,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'LiveFish AI',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Project Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'LiveFish AI is an offline, real-time mobile AI system designed to help fishermen and conservationists identify fish species and measure their size directly through a smartphone camera. By empowering local communities, LiveFish AI promotes sustainable fishing practices and generates valuable biodiversity data for global conservation efforts.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Josh (Project Lead, Gemini Agent)'),
            const SizedBox(height: 16),
            const Text(
              'AI Model Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Model: YOLOv8 Nano (INT8 Quantized)'),
            const Text('- Architecture: Arm'),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Built for the',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Assuming a logo exists at this path
                  // SvgPicture.asset('assets/images/arm_ai_developer_challenge_logo.svg', height: 50),
                  const Text(
                    'Arm AI Developer Challenge 2025',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
