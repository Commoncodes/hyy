import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:hyre/modals/professions_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../modals/area_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String selectedOccupation = 'Painter';
  String selectedArea = 'Gambari';

  String? profilePicBase64;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _updateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'display_name': fullNameController.text.trim(),
            'phone': phoneController.text.trim(),
            'whatsapp_phone': whatsappController.text.trim(),
            'address': addressController.text.trim(),
            'profession': selectedOccupation,
            'area': selectedArea,
          })
          .eq('id', user.id)
          .execute();

      if (response.status == 200 || response.status == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
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
          fullNameController.text = doc['display_name'] ?? '';
          phoneController.text = doc['phone'] ?? '';
          whatsappController.text = doc['whatsapp_phone'] ?? '';
          addressController.text = doc['address'] ?? '';
          selectedOccupation = doc['profession'] ?? 'Painter';
          selectedArea = doc['area'] ?? 'Gambari';
          profilePicBase64 = doc['profile_pic'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontFamily: 'AeonikTRIAL Bold',
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.cardColor,
                        backgroundImage: (profilePicBase64 != null &&
                                profilePicBase64!.isNotEmpty)
                            ? NetworkImage(profilePicBase64!)
                            : null,
                        child: (profilePicBase64 == null ||
                                profilePicBase64!.isEmpty)
                            ? Icon(Icons.person,
                                size: 40, color: theme.iconTheme.color)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Full Name
                    Text('Full Name',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    _buildTextField(context, fullNameController),

                    const SizedBox(height: 20),

                    // Occupation Modal Trigger
                    Text('Occupation',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: theme.cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: ProfessionsModal(
                              onSelected: (profession) {
                                setState(() {
                                  selectedOccupation = profession;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedOccupation,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'AeonikTRIAL Regular',
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                color: theme.iconTheme.color),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone Number
                    Text('Phone Number',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    _buildTextField(context, phoneController,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 20),

                    // WhatsApp Number
                    Text('WhatsApp Number',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    _buildTextField(context, whatsappController,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 20),

                    // Area Modal Trigger
                    Text('Area',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: theme.cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: AreaModal(
                              onSelected: (area) {
                                setState(() {
                                  selectedArea = area;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedArea,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'AeonikTRIAL Regular',
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                color: theme.iconTheme.color),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Address
                    Text('Address',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontFamily: 'AeonikTRIAL Regular',
                          color: theme.textTheme.bodyMedium?.color,
                        )),
                    const SizedBox(height: 6),
                    _buildTextField(context, addressController),

                    const SizedBox(height: 40),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          primary: colorScheme.primary,
                          onPrimary: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            color: colorScheme.onPrimary,
                            fontFamily: 'AeonikTRIAL Regular',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller,
      {TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 14,
          fontFamily: 'AeonikTRIAL Regular',
        ),
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.hintColor,
          fontSize: 14,
          fontFamily: 'AeonikTRIAL Regular',
        ),
        fillColor: theme.cardColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
