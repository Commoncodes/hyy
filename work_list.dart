import 'package:flutter/material.dart';

class PaintersScreen extends StatefulWidget {
  const PaintersScreen({super.key});

  @override
  State<PaintersScreen> createState() => _PaintersScreenState();
}

class _PaintersScreenState extends State<PaintersScreen> {
  // List of painters data
  final List<Map<String, String>> painters = [
    {'name': 'Olusola Adeniran', 'area': 'Gaa-akanbi Area'},
    {'name': 'Olusola Adeniran', 'area': 'Gaa-akanbi Area'},
    {'name': 'Olusola Adeniran', 'area': 'Gaa-akanbi Area'},
    {'name': 'Esther Philips', 'area': 'Gaa-akanbi Area'},
    {'name': 'John Fayemi', 'area': 'Gaa-akanbi Area'},
    {'name': 'Olusola Adeniran', 'area': 'Gaa-akanbi Area'},
    {'name': 'Olusola Adeniran', 'area': 'Gaa-akanbi Area'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Artisans',
          style: TextStyle(
            fontFamily: 'AeonikTRIAL Regular',
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: painters.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey, // Placeholder for avatar
              ),
              title: Text(
                painters[index]['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AeonikTRIAL Bold',
                ),
              ),
              subtitle: Text(
                painters[index]['area']!,
                style: const TextStyle(
                  fontFamily: 'AeonikTRIAL Regular',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
