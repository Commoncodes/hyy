import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'artisan_profile.dart';
import '../theme.dart';

class CategoriesListScreen extends StatefulWidget {
  final String title;
  const CategoriesListScreen({super.key, required this.title});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hyreColors = theme.extension<HyreColors>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        iconTheme: theme.iconTheme,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                    fontFamily: 'AeonikTRIAL Regular',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List of users from Supabase
              Expanded(
                child: FutureBuilder<PostgrestResponse>(
                  future: Supabase.instance.client
                      .from('profiles')
                      .select()
                      .eq('profession', widget.title)
                      .execute(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.data == null ||
                        (snapshot.data!.data as List).isEmpty) {
                      return Center(
                        child: Text(
                          'No artisans found.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }
                    final users =
                        (snapshot.data!.data as List<dynamic>).where((data) {
                      final name =
                          (data['display_name'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final data = users[index] as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewArtisanScreen(artisanId: data['id']),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: theme.cardColor,
                                  backgroundImage:
                                      (data['profile_pic'] != null &&
                                              data['profile_pic']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? NetworkImage(data['profile_pic'])
                                          : null,
                                  child: (data['profile_pic'] == null ||
                                          data['profile_pic']
                                              .toString()
                                              .isEmpty)
                                      ? Icon(Icons.person,
                                          color: theme.iconTheme.color)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['display_name'] ?? 'No Name',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['area'] ?? 'No Area',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .textTheme.bodyMedium?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      data['profession'] ?? 'No Profession',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (data['is_available'] ?? true)
                                            ? (hyreColors?.availableBg ??
                                                Colors.green.withOpacity(0.15))
                                            : theme.colorScheme.error
                                                .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        (data['is_available'] ?? true)
                                            ? 'Available'
                                            : 'Busy',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          fontFamily: 'AeonikTRIAL Light',
                                          color: (data['is_available'] ?? true)
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
