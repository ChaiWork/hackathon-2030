import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_action_button.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_edit_button.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_info_row.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_profile_header.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_section_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_toggle_setting.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/connection_status.dart'
    show ConnectionStatus;
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/emergency_contact_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Basic Information
  String fullName = 'John Doe';
  String age = '28';
  String gender = 'Male';
  String height = '5\'10"';
  String weight = '75 kg';

  // Health Profile
  String medicalConditions = 'None';
  String lifestyle = 'Active';

  // Emergency Contact
  List<Map<String, String>> emergencyContacts = [
    {'name': 'Mom', 'phone': '+1-234-567-8900'},
  ];
  bool autoNotify = true;

  // Device Connection
  String connectedDevice = 'Smartwatch';
  bool isConnected = true;

  // Alert Settings
  String heartRateThreshold = '120';
  bool notificationToggle = true;

  // AI Settings
  String aiSensitivity = 'Medium';

  // Health Goals
  String targetHRRange = '60-100';
  String fitnessGoal = 'Improve stamina';

  // Data & Privacy
  bool dataSharingToggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeep,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            ProfileHeader(fullName: fullName, age: age, lifestyle: lifestyle),
            const SizedBox(height: 32),

            // Basic Information
            SectionCard(
              title: 'Basic Information',
              icon: Icons.person,
              children: [
                InfoRow(label: 'Full Name', value: fullName),
                InfoRow(label: 'Age', value: age),
                InfoRow(label: 'Gender', value: gender),
                InfoRow(label: 'Height', value: height),
                InfoRow(label: 'Weight', value: weight),
                EditButton(label: 'Edit'),
              ],
            ),
            const SizedBox(height: 20),

            // Health Profile
            SectionCard(
              title: 'Health Profile',
              icon: Icons.health_and_safety,
              children: [
                InfoRow(label: 'Medical Conditions', value: medicalConditions),
                InfoRow(label: 'Lifestyle', value: lifestyle),
                EditButton(label: 'Edit'),
              ],
            ),
            const SizedBox(height: 20),

            // Emergency Contact
            SectionCard(
              title: 'Emergency Contacts',
              icon: Icons.emergency,
              children: [
                ToggleSetting(
                  label: 'Auto Notify',
                  value: autoNotify,
                  onChanged: (value) {
                    setState(() => autoNotify = value);
                  },
                ),
                const SizedBox(height: 12),
                ...emergencyContacts.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> contact = entry.value;
                  return EmergencyContactItem(
                    name: contact['name']!,
                    phone: contact['phone']!,
                    onDelete: () {
                      setState(() {
                        emergencyContacts.removeAt(index);
                      });
                    },
                  );
                }),
                EditButton(label: 'Add Contact'),
              ],
            ),
            const SizedBox(height: 20),

            // Device Connection
            SectionCard(
              title: 'Device Connection',
              icon: Icons.watch,
              children: [
                InfoRow(label: 'Connected Device', value: connectedDevice),
                ConnectionStatus(isConnected: isConnected),
                EditButton(label: 'Connect Device'),
              ],
            ),
            const SizedBox(height: 20),

            // Alert Settings
            SectionCard(
              title: 'Alert Settings',
              icon: Icons.notifications,
              children: [
                InfoRow(
                  label: 'HR Threshold',
                  value: '$heartRateThreshold BPM',
                ),
                ToggleSetting(
                  label: 'Notifications',
                  value: notificationToggle,
                  onChanged: (value) {
                    setState(() => notificationToggle = value);
                  },
                ),
                EditButton(label: 'Edit Alerts'),
              ],
            ),
            const SizedBox(height: 20),

            // AI Settings
            SectionCard(
              title: 'AI Settings',
              icon: Icons.smart_toy,
              children: [
                InfoRow(label: 'AI Sensitivity', value: aiSensitivity),
                EditButton(label: 'Additional AI Settings'),
              ],
            ),
            const SizedBox(height: 20),

            // Health Goals
            SectionCard(
              title: 'Health Goals',
              icon: Icons.flag,
              children: [
                InfoRow(label: 'Target HR Range', value: targetHRRange),
                InfoRow(label: 'Fitness Goal', value: fitnessGoal),
                EditButton(label: 'Edit Goals'),
              ],
            ),
            const SizedBox(height: 20),

            // Data & Privacy
            SectionCard(
              title: 'Data & Privacy',
              icon: Icons.security,
              children: [
                ToggleSetting(
                  label: 'Data Sharing',
                  value: dataSharingToggle,
                  onChanged: (value) {
                    setState(() => dataSharingToggle = value);
                  },
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'Download Health Report',
                  icon: Icons.download,
                ),
                const SizedBox(height: 8),
                ActionButton(
                  label: 'Upload Medical Report',
                  icon: Icons.upload_file,
                ),
                const SizedBox(height: 8),
                ActionButton(
                  label: 'Delete All Data',
                  icon: Icons.delete_forever,
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Logout
            ActionButton(
              label: 'Logout',
              icon: Icons.logout,
              isDestructive: true,
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
