import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About card
                      _buildCard(
                        title: 'About Food Scanner',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Food Scanner is an app designed to help you make healthier food choices by analyzing ingredients in packaged foods. Simply scan the barcode of any food product to get detailed information about its ingredients.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // How it works card
                      _buildCard(
                        title: 'How It Works',
                        content: Column(
                          children: [
                            _buildListItem(
                              icon: Icons.qr_code_scanner,
                              title: 'Scan Barcode',
                              description: 'Use your phone\'s camera to scan the barcode on any food product',
                            ),
                            const Divider(),
                            _buildListItem(
                              icon: Icons.science,
                              title: 'Analyze Ingredients',
                              description: 'Our system analyzes the ingredients and identifies potentially harmful components',
                            ),
                            const Divider(),
                            _buildListItem(
                              icon: Icons.assignment,
                              title: 'Get Results',
                              description: 'View a detailed breakdown of ingredients, categorized as safe or harmful',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Ingredient Analysis card
                      _buildCard(
                        title: 'Ingredient Analysis',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Our app categorizes ingredients based on scientific research and nutritional guidelines. We identify ingredients that may be:',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildListItem(
                              icon: Icons.warning,
                              iconColor: const Color(0xFFC62828),
                              title: 'Harmful',
                              description: 'Ingredients linked to health issues like artificial colors, certain preservatives, and high-fructose corn syrup',
                            ),
                            const Divider(),
                            _buildListItem(
                              icon: Icons.check_circle,
                              iconColor: const Color(0xFF2E7D32),
                              title: 'Safe',
                              description: 'Natural ingredients and nutrients that are generally recognized as beneficial or neutral',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Disclaimer: This app provides general information and should not replace professional medical advice. Always consult with a healthcare provider for specific dietary concerns.',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Data Sources card
                      _buildCard(
                        title: 'Data Sources',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Our ingredient database is compiled from various sources including:',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildListItem(
                              icon: Icons.storage,
                              title: 'Food Databases',
                              description: 'Open Food Facts, USDA FoodData Central',
                            ),
                            const Divider(),
                            _buildListItem(
                              icon: Icons.menu_book,
                              title: 'Research Studies',
                              description: 'Peer-reviewed nutritional and food safety research',
                            ),
                            const Divider(),
                            _buildListItem(
                              icon: Icons.local_hospital,
                              title: 'Health Organizations',
                              description: 'Guidelines from WHO, FDA, and other health authorities',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Back to home button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor ?? const Color(0xFF2E7D32),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 