import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'artisan_profile.dart';

class FeaturedProvidersScreen extends StatelessWidget {
  const FeaturedProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Featured',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontFamily: 'AeonikTRIAL Bold',
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Here are some of our top rated service providers',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    fontFamily: 'AeonikTRIAL Regular',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<PostgrestResponse>(
                  future: Supabase.instance.client
                      .from('profiles')
                      .select()
                      .eq('featured', true)
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
                          'No featured artisans found.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontFamily: 'AeonikTRIAL Regular',
                          ),
                        ),
                      );
                    }
                    final providers = snapshot.data!.data as List<dynamic>;
                    return ListView.builder(
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final data = providers[index] as Map<String, dynamic>;
                        final artisanId = data['id'];
                        return _buildProviderCard(context, data, artisanId);
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

  Widget _buildProviderCard(
      BuildContext context, Map<String, dynamic> data, String artisanId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hyreColors = Theme.of(context).extension<HyreColors>();

    return Card(
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.cardColor,
                    backgroundImage: (data['profile_pic'] != null &&
                            data['profile_pic'].toString().isNotEmpty)
                        ? NetworkImage(data['profile_pic'])
                        : null,
                    child: (data['profile_pic'] == null ||
                            data['profile_pic'].toString().isEmpty)
                        ? Icon(Icons.person, color: theme.iconTheme.color)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Name, profession, area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['display_name'] ?? 'No Name',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AeonikTRIAL Bold',
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['profession'] ?? 'No Profession',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: theme.textTheme.bodyLarge?.color,
                          fontFamily: 'AeonikTRIAL Regular',
                        ),
                      ),
                      Text(
                        data['area'] ?? 'No Area',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                          fontFamily: 'AeonikTRIAL Regular',
                        ),
                      ),
                    ],
                  ),
                ),
                // Availability badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      fontSize: 13,
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
          // Action Row with theme-based background
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Call
                _ActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  onTap: () async {
                    final phone = data['phone'] ?? '';
                    if (phone.isNotEmpty) {
                      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    }
                  },
                ),
                // WhatsApp
                _ActionButton(
                  icon: Icons.whatsapp,
                  label: 'Whatsapp',
                  onTap: () async {
                    final whatsapp = data['whatsapp_phone'] ?? '';
                    if (whatsapp.isNotEmpty) {
                      final Uri whatsappUri =
                          Uri.parse('https://wa.me/$whatsapp');
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(whatsappUri);
                      }
                    }
                  },
                ),
                // Profile
                _ActionButton(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewArtisanScreen(artisanId: artisanId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontFamily: 'AeonikTRIAL Regular',
            ),
          ),
        ],
      ),
    );
  }
}
