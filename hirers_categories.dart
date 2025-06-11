import 'package:flutter/material.dart';
import 'artisans_category_list.dart';

class HirersCategoriesScreen extends StatefulWidget {
  const HirersCategoriesScreen({super.key});

  @override
  State<HirersCategoriesScreen> createState() => _HirersCategoriesScreenState();
}

class _HirersCategoriesScreenState extends State<HirersCategoriesScreen> {
  // List of categories with their respective icons
  final List<Map<String, dynamic>> categories = [
    {'name': 'Electrician', 'icon': Icons.electrical_services},
    {'name': 'Plumber', 'icon': Icons.plumbing},
    {'name': 'Carpenter', 'icon': Icons.build},
    {'name': 'Cleaner', 'icon': Icons.cleaning_services},
    {'name': 'Welder', 'icon': Icons.build_circle},
    {'name': 'Mechanic', 'icon': Icons.engineering},
    {'name': 'Tailor', 'icon': Icons.checkroom},
    {'name': 'Painter', 'icon': Icons.brush},
    {'name': 'Vulcanizer', 'icon': Icons.local_car_wash},
    {'name': 'Rider', 'icon': Icons.directions_bike},
    {'name': 'Security', 'icon': Icons.security},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'AeonikTRIAL Bold',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesListScreen(
                    title: categories[index]['name'],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE0E0E0),
                    child: Icon(
                      categories[index]['icon'],
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      categories[index]['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'AeonikTRIAL Regular',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
