import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/saerch_bar.dart';
import '../dilaogs/artisan_preview_dialog.dart';
import '../loading screen/loading_screen.dart';
import '../modals/area_modal.dart';
import '../modals/filter_modal.dart';
import '../modals/professions_modal.dart';
import '../theme.dart';
import 'artisan_profile.dart';
import 'artisans_grid_view.dart';

class AvailableArtisansScreen extends StatefulWidget {
  const AvailableArtisansScreen({super.key});

  @override
  State<AvailableArtisansScreen> createState() =>
      _AvailableArtisansScreenState();
}

class _AvailableArtisansScreenState extends State<AvailableArtisansScreen> {
  String? selectedProfession;
  String? selectedArea;
  String searchQuery = '';
  bool showSearchBar = false;
  bool showGrid = true;

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterModal(
          selectedProfession: selectedProfession,
          selectedArea: selectedArea,
          onProfessionSelected: (value) {
            setState(() => selectedProfession = value);
          },
          onAreaSelected: (value) {
            setState(() => selectedArea = value);
          },
          onApply: () {},
          onClear: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Available Artisans',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontFamily: 'AeonikTRIAL Bold',
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showSearchBar ? Icons.close : Icons.search,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                if (showSearchBar) searchQuery = '';
                showSearchBar = !showSearchBar;
              });
            },
            tooltip: showSearchBar ? 'Close Search' : 'Search',
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
            onPressed: _openFilterModal,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(showGrid ? Icons.list : Icons.grid_view,
                color: theme.iconTheme.color),
            onPressed: () {
              setState(() {
                showGrid = !showGrid;
              });
            },
            tooltip: showGrid ? 'Show List' : 'Show Grid',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showSearchBar)
              SearchBar(
                value: searchQuery,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            if (showSearchBar) const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<PostgrestResponse>(
                future: Supabase.instance.client
                    .from('profiles')
                    .select()
                    .execute(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: BouncingDotsLoader());
                  }

                  if (!snapshot.hasData || snapshot.data!.data == null) {
                    return Center(
                      child: Text(
                        'No artisans found.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  // Convert to list of maps
                  final List<dynamic> allArtisans =
                      snapshot.data!.data as List<dynamic>;

                  // Filter the list
                  var filtered = allArtisans.where((data) {
                    final name =
                        (data['display_name'] ?? '').toString().toLowerCase();
                    final matchesSearch =
                        name.contains(searchQuery.toLowerCase());
                    final matchesProfession = selectedProfession == null ||
                        data['profession'] == selectedProfession;
                    final matchesArea =
                        selectedArea == null || data['area'] == selectedArea;
                    return matchesSearch && matchesProfession && matchesArea;
                  }).toList();

                  // Show "No artisans found" if filtered is empty
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No artisans found.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedProfession = null;
                                selectedArea = null;
                                searchQuery = '';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: theme.cardColor,
                              onPrimary: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Clear',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.primary,
                                fontFamily: 'AeonikTRIAL Regular',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show grid or list view
                  if (showGrid) {
                    return ArtisansGridView(
                      artisans: filtered.cast<Map<String, dynamic>>(),
                    );
                  }

                  // Show the filtered list (ListView)
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final data = filtered[index];
                      final hyreColors =
                          Theme.of(context).extension<HyreColors>();
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewArtisanScreen(
                                artisanId: data['id'],
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => ArtisanPreviewDialog(
                              profilePicBase64: data['profile_pic'],
                              name: data['display_name'] ?? 'No Name',
                              profession: data['profession'] ?? 'No Profession',
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
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: (data['featured'] == true)
                                      ? Border.all(
                                          color: colorScheme.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                padding: (data['featured'] == true)
                                    ? const EdgeInsets.all(4)
                                    : EdgeInsets.zero,
                                child: CircleAvatar(
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['display_name'] ?? 'No Name',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 16,
                                        fontFamily: 'AeonikTRIAL Regular',
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['area'] ?? 'No Area',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontFamily: 'AeonikTRIAL Regular',
                                        color:
                                            theme.textTheme.bodyMedium?.color,
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontFamily: 'AeonikTRIAL Regular',
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (data['is_available'] ?? true)
                                          ? (hyreColors?.availableBg ??
                                              Colors.green.withOpacity(0.15))
                                          : colorScheme.error.withOpacity(0.12),
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
                                            ? const Color.fromARGB(
                                                255, 15, 189, 20)
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
    );
  }
}
