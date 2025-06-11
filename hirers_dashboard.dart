import 'package:flutter/material.dart';
import 'package:hyre/hirers/featured_artisan.dart';
import 'package:hyre/hirers/hirers_categories.dart';
import 'package:hyre/hirers/categories_photos.dart';
import 'package:hyre/hirers/hirers_home.dart';
import 'package:hyre/screens/work_categories.dart';

class HirersDashboard extends StatefulWidget {
  const HirersDashboard({Key? key}) : super(key: key);

  @override
  State<HirersDashboard> createState() => _HirersDashboardState();
}

class _HirersDashboardState extends State<HirersDashboard> {
  int myIndex = 0;
  final List<Widget> widgetList = [
    AvailableArtisansScreen(),
    JobCategoriesScreen(),
    FeaturedProvidersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: myIndex,
            onTap: (index) {
              setState(() {
                myIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Artisans',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_rounded),
                label: 'Featured',
              ),
            ],
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: theme.unselectedWidgetColor,
            elevation: 0,
            backgroundColor: theme.cardColor,
            selectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'AeonikTRIAL Regular',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'AeonikTRIAL Regular',
            ),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
