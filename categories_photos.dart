import 'package:flutter/material.dart';
import 'artisans_category_list.dart';

class JobCategoriesScreen extends StatefulWidget {
  @override
  _JobCategoriesScreenState createState() => _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends State<JobCategoriesScreen> {
  final List<Map<String, String>> categories = [
    {'title': 'Tailor', 'image': 'lib/images/tailor.webp'},
    {'title': 'Carpenter', 'image': 'lib/images/carpenters.webp'},
    {'title': 'Cleaner', 'image': 'lib/images/cleaner2.webp'},
    {'title': 'Chef', 'image': 'lib/images/cooker.webp'},
    {'title': 'Make up artist', 'image': 'lib/images/makeup.webp'},
    {'title': 'Bricklayer', 'image': 'lib/images/bricklayer.webp'},
    {'title': 'Photographer', 'image': 'lib/images/photographer.webp'},
    {'title': 'Nail tech', 'image': 'lib/images/nailtech2.webp'},
    {'title': 'Tiler', 'image': 'lib/images/tiler2.webp'},
    {'title': 'Painter', 'image': 'lib/images/painters.webp'},
    {'title': 'Welder', 'image': 'lib/images/welder2.webp'},
    {'title': 'Cobbler', 'image': 'lib/images/cobbler2.webp'},
    {'title': 'Gardener', 'image': 'lib/images/gardener.webp'},
    {'title': 'Electrician', 'image': 'lib/images/electrician2.webp'},
    {'title': 'Plumber', 'image': 'lib/images/plumber2.webp'},
    {'title': 'Mechanic', 'image': 'lib/images/mechanic2.webp'},
    {'title': 'Vulcanizer', 'image': 'lib/images/vulcanizer.webp'},
    {'title': 'Rider', 'image': 'lib/images/rider.webp'},
    {'title': 'Panel Beater', 'image': 'lib/images/panel2.webp'},
    {'title': 'Laundry', 'image': 'lib/images/laundry.webp'},
    {'title': 'Driver', 'image': 'lib/images/driver2.webp'},
    {'title': 'Barber', 'image': 'lib/images/barber3.webp'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Categories',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'AeonikTRIAL Bold',
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesListScreen(
                      title: categories[index]['title']!,
                    ),
                  ),
                );
              },
              child: CategoryCard(
                title: categories[index]['title']!,
                image: categories[index]['image']!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;

  const CategoryCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'AeonikTRIAL Regular',
                  shadows: const [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
