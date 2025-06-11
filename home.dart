import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hyre/dashboard/profile.dart';
import '../hirers/hirers_dashboard.dart';
import 'package:hyre/components/dashed_line.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fullName;
  String? profession;
  String? area;
  String? profilePicUrl;
  bool isLoading = true;
  bool isAvailable = true;
  List<String?> workImages = [null, null, null];
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single()
          .execute();

      if (response.status == 200 && response.data != null) {
        final doc = response.data;
        setState(() {
          fullName = doc['display_name'] ?? '';
          profession = doc['profession'] ?? '';
          area = doc['area'] ?? '';
          profilePicUrl = doc['profile_pic'];
          isAvailable = (doc['is_available'] ?? true);
          workImages =
              List<String?>.from(doc['work_images'] ?? [null, null, null]);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAvailability() async {
    setState(() {
      isAvailable = !isAvailable;
    });
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_available': isAvailable})
          .eq('id', user.id)
          .execute();
    }
  }

  Future<void> _pickAndUploadImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => isUploading = true);

    try {
      final fileBytes = await pickedFile.readAsBytes();
      final fileName = '${user.id}_work_image_$index.jpg';

      // Upload image to Supabase Storage
      await Supabase.instance.client.storage.from('work-photos').uploadBinary(
            'public/$fileName',
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('work-photos')
          .getPublicUrl('public/$fileName');

      // Update the local state
      setState(() {
        workImages[index] = publicUrl;
      });

      // Save updated array to Supabase
      await Supabase.instance.client
          .from('profiles')
          .update({'work_images': workImages})
          .eq('id', user.id)
          .execute();
    } catch (e) {
      print('Image upload failed: $e');
      // Optionally show user feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontFamily: 'AeonikTRIAL Regular',
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.cardColor,
                      backgroundImage:
                          (profilePicUrl != null && profilePicUrl!.isNotEmpty)
                              ? NetworkImage(profilePicUrl!)
                              : null,
                      child: (profilePicUrl == null || profilePicUrl!.isEmpty)
                          ? Icon(Icons.person,
                              size: 40, color: theme.iconTheme.color)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _toggleAvailability,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? colorScheme.secondary.withOpacity(0.15)
                              : colorScheme.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Busy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isAvailable ? Colors.green : Colors.orange,
                            fontFamily: 'AeonikTRIAL Light',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontFamily: 'AeonikTRIAL Bold',
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profession ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontFamily: 'AeonikTRIAL Regular',
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      area ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontFamily: 'AeonikTRIAL Regular',
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCardButton(
                            context: context,
                            icon: Icons.person,
                            label: 'My Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()),
                              );
                            },
                          ),
                          _buildCardButton(
                            context: context,
                            icon: Icons.work,
                            label: 'Hire Someone',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HirersDashboard()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (index) {
                          return _buildAddPhotoContainer(index);
                        }),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.iconTheme.color),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontFamily: 'AeonikTRIAL Regular',
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoContainer(int index) {
    final theme = Theme.of(context);
    final imageUrl = workImages[index];

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _pickAndUploadImage(index),
          child: DashedRect(
            borderRadius: 12,
            color: Colors.grey,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'AeonikTRIAL Regular',
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
