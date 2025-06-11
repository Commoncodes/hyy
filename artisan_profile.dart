import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../loading screen/loading_screen.dart';

class ViewArtisanScreen extends StatefulWidget {
  final String artisanId;
  const ViewArtisanScreen({super.key, required this.artisanId});

  @override
  State<ViewArtisanScreen> createState() => _ViewArtisanScreenState();
}

class _ViewArtisanScreenState extends State<ViewArtisanScreen> {
  String name = '';
  String profession = '';
  String area = '';
  String phoneNumber = '';
  String whatsappNumber = '';
  String profilePic = '';
  List<String?> workImages = [null, null, null];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtisanData();
  }

  Future<void> _fetchArtisanData() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', widget.artisanId)
        .single()
        .execute();

    if (response.status == 200 && response.data != null) {
      final data = response.data;
      setState(() {
        name = data['display_name'] ?? '';
        profession = data['profession'] ?? '';
        area = data['area'] ?? '';
        phoneNumber = data['phone'] ?? '';
        whatsappNumber = data['whatsapp_phone'] ?? '';
        profilePic = data['profile_pic'] ?? '';
        workImages =
            List<String?>.from(data['work_images'] ?? [null, null, null]);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openWhatsApp(String whatsappNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: BouncingDotsLoader()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back,
                          size: 22, color: theme.iconTheme.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 26,
                    fontFamily: 'AeonikTRIAL Bold',
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              profilePic.isNotEmpty
                  ? CircleAvatar(
                      radius: 80,
                      backgroundColor: theme.cardColor,
                      backgroundImage: NetworkImage(profilePic),
                    )
                  : CircleAvatar(
                      radius: 80,
                      backgroundColor: theme.cardColor,
                      child: Icon(Icons.person,
                          size: 60, color: theme.iconTheme.color),
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  final imageUrl = workImages[index];
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 30)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildProfileItem(context, 'Name', name),
              _buildProfileItem(context, 'Profession', profession),
              _buildProfileItem(context, 'Area', area),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(phoneNumber),
                      style: ElevatedButton.styleFrom(
                        primary: colorScheme.primary,
                        onPrimary: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call,
                              color: colorScheme.onPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Call',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontFamily: 'AeonikTRIAL Regular',
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openWhatsApp(whatsappNumber),
                      style: ElevatedButton.styleFrom(
                        primary: colorScheme.primary.withOpacity(0.08),
                        onPrimary: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.whatsapp,
                              color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Whatsapp',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontFamily: 'AeonikTRIAL Regular',
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontFamily: 'AeonikTRIAL Regular',
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontFamily: 'AeonikTRIAL Regular',
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
