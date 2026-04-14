import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Palette
const Color _color1 = Color(0xFFE7ECFF);
const Color _color2 = Color(0xFFD8E1FF);
const Color _color3 = Color(0xFFBBD0FF);
const Color _color4 = Color(0xFFA8BCFB);
const Color _color5 = Color(0xFF7EA0EA);

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
      backgroundColor: _color1,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _color5,
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
            _buildProfileHeader(),
            const SizedBox(height: 32),

            // Basic Information
            _buildSection(
              title: 'Basic Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Full Name', fullName),
                _buildInfoRow('Age', age),
                _buildInfoRow('Gender', gender),
                _buildInfoRow('Height', height),
                _buildInfoRow('Weight', weight),
                _buildEditButton('Edit'),
              ],
            ),
            const SizedBox(height: 20),

            // Health Profile
            _buildSection(
              title: 'Health Profile',
              icon: Icons.health_and_safety,
              children: [
                _buildInfoRow('Medical Conditions', medicalConditions),
                _buildInfoRow('Lifestyle', lifestyle),
                _buildEditButton('Edit'),
              ],
            ),
            const SizedBox(height: 20),

            // Emergency Contact
            _buildSection(
              title: 'Emergency Contacts',
              icon: Icons.emergency,
              children: [
                _buildToggleSetting('Auto Notify', autoNotify, (value) {
                  setState(() => autoNotify = value);
                }),
                const SizedBox(height: 12),
                ...emergencyContacts.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> contact = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _color3.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['name']!,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                contact['phone']!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                emergencyContacts.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                _buildEditButton('Add Contact'),
              ],
            ),
            const SizedBox(height: 20),

            // Device Connection
            _buildSection(
              title: 'Device Connection',
              icon: Icons.watch,
              children: [
                _buildInfoRow('Connected Device', connectedDevice),
                _buildConnectionStatus(isConnected),
                _buildEditButton('Connect Device'),
              ],
            ),
            const SizedBox(height: 20),

            // Alert Settings
            _buildSection(
              title: 'Alert Settings',
              icon: Icons.notifications,
              children: [
                _buildInfoRow('HR Threshold', '$heartRateThreshold BPM'),
                _buildToggleSetting('Notifications', notificationToggle, (value) {
                  setState(() => notificationToggle = value);
                }),
                _buildEditButton('Edit Alerts'),
              ],
            ),
            const SizedBox(height: 20),

            // AI Settings
            _buildSection(
              title: 'AI Settings',
              icon: Icons.smart_toy,
              children: [
                _buildInfoRow('AI Sensitivity', aiSensitivity),
                _buildEditButton('Additional AI Settings'),
              ],
            ),
            const SizedBox(height: 20),

            // Health Goals
            _buildSection(
              title: 'Health Goals',
              icon: Icons.flag,
              children: [
                _buildInfoRow('Target HR Range', targetHRRange),
                _buildInfoRow('Fitness Goal', fitnessGoal),
                _buildEditButton('Edit Goals'),
              ],
            ),
            const SizedBox(height: 20),

            // Data & Privacy
            _buildSection(
              title: 'Data & Privacy',
              icon: Icons.security,
              children: [
                _buildToggleSetting('Data Sharing', dataSharingToggle, (value) {
                  setState(() => dataSharingToggle = value);
                }),
                const SizedBox(height: 12),
                _buildActionButton('Download Health Report', Icons.download),
                const SizedBox(height: 8),
                _buildActionButton('Upload Medical Report', Icons.upload_file),
                const SizedBox(height: 8),
                _buildActionButton('Delete All Data', Icons.delete_forever,
                    isDestructive: true),
              ],
            ),
            const SizedBox(height: 20),

            // Logout
            _buildActionButton('Logout', Icons.logout,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/auth');
                }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color3.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _color5.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_color4, _color5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$age years • $lifestyle',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _color5.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Member since 2024',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: _color5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color3.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _color5.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _color3.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _color5.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: _color5,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _color5,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _color5,
            inactiveThumbColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label clicked - Feature coming soon'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _color5.withOpacity(0.15),
            foregroundColor: _color5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label - Feature coming soon'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : _color5,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
