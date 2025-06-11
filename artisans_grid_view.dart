import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dilaogs/artisan_preview_dialog.dart';
import '../theme.dart';
import 'artisan_profile.dart';

class ArtisansGridView extends StatelessWidget {
  final List<Map<String, dynamic>> artisans;

  const ArtisansGridView({super.key, required this.artisans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (artisans.isEmpty) {
      return Center(
        child: Text(
          'No artisans found.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontFamily: 'AeonikTRIAL Regular',
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: artisans.length,
      itemBuilder: (context, index) {
        final data = artisans[index];

        final hyreColors = Theme.of(context).extension<HyreColors>();
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
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    radius: 32,
                    backgroundColor: theme.cardColor,
                    backgroundImage: (data['profile_pic'] != null &&
                            data['profile_pic'].toString().isNotEmpty)
                        ? NetworkImage(data['profile_pic'])
                        : null,
                    child: (data['profile_pic'] == null ||
                            data['profile_pic'].toString().isEmpty)
                        ? Icon(Icons.person,
                            color: theme.iconTheme.color, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['display_name'] ?? 'No Name',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontFamily: 'AeonikTRIAL Regular',
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  data['profession'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontFamily: 'AeonikTRIAL Regular',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (data['is_available'] ?? true)
                        ? (hyreColors?.availableBg ??
                            Colors.green.withOpacity(0.15))
                        : colorScheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (data['is_available'] ?? true) ? 'Available' : 'Busy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontFamily: 'AeonikTRIAL Light',
                      color: (data['is_available'] ?? true)
                          ? const Color.fromARGB(255, 15, 189, 20)
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
