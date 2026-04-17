import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:vitalife_asistant/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _profileService = ProfileService();

  bool _loadingProfile = true;
  String? _profileError;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loadingProfile = false;
        _profileError = 'Not signed in.';
      });
      return;
    }

    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      _applyProfile(profile);
      setState(() => _loadingProfile = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
        _profileError = e.toString();
      });
    }
  }

  void _applyProfile(Map<String, dynamic> p) {
    String s(String key, String fallback) {
      final v = p[key];
      return v is String && v.isNotEmpty ? v : fallback;
    }

    bool b(String key, bool fallback) {
      final v = p[key];
      return v is bool ? v : fallback;
    }

    List<Map<String, String>> contacts(List<Map<String, String>> fallback) {
      final v = p['emergencyContacts'];
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => Map<String, String>.from(m))
            .where(
              (m) =>
                  (m['name'] ?? '').trim().isNotEmpty &&
                  (m['phone'] ?? '').trim().isNotEmpty,
            )
            .toList();
      }
      return fallback;
    }

    setState(() {
      fullName = s('fullName', fullName);
      age = s('age', age);
      gender = s('gender', gender);
      height = s('height', height);
      weight = s('weight', weight);

      medicalConditions = s('medicalConditions', medicalConditions);
      lifestyle = s('lifestyle', lifestyle);

      emergencyContacts = contacts(emergencyContacts);
      autoNotify = b('autoNotify', autoNotify);

      connectedDevice = s('connectedDevice', connectedDevice);
      isConnected = b('isConnected', isConnected);

      heartRateThreshold = s('heartRateThreshold', heartRateThreshold);
      notificationToggle = b('notificationToggle', notificationToggle);

      aiSensitivity = s('aiSensitivity', aiSensitivity);

      targetHRRange = s('targetHRRange', targetHRRange);
      fitnessGoal = s('fitnessGoal', fitnessGoal);

      dataSharingToggle = b('dataSharingToggle', dataSharingToggle);
    });
  }

  Future<void> _saveProfilePatch(Map<String, dynamic> patch) async {
    try {
      final profile = await _profileService.updateProfile(patch);
      if (!mounted) return;
      _applyProfile(profile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _editBasicInfo() async {
    final fullNameCtrl = TextEditingController(text: fullName);
    final ageCtrl = TextEditingController(text: age);
    final genderCtrl = TextEditingController(text: gender);
    final heightCtrl = TextEditingController(text: height);
    final weightCtrl = TextEditingController(text: weight);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Basic Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: ageCtrl,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: genderCtrl,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: heightCtrl,
                decoration: const InputDecoration(labelText: 'Height'),
              ),
              TextField(
                controller: weightCtrl,
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      if (fullNameCtrl.text.trim().isNotEmpty)
        fullName = fullNameCtrl.text.trim();
      if (ageCtrl.text.trim().isNotEmpty) age = ageCtrl.text.trim();
      if (genderCtrl.text.trim().isNotEmpty) gender = genderCtrl.text.trim();
      if (heightCtrl.text.trim().isNotEmpty) height = heightCtrl.text.trim();
      if (weightCtrl.text.trim().isNotEmpty) weight = weightCtrl.text.trim();
    });

    await _saveProfilePatch({
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    });
  }

  Future<void> _editHealthProfile() async {
    final medicalCtrl = TextEditingController(text: medicalConditions);
    final lifestyleCtrl = TextEditingController(text: lifestyle);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Health Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: medicalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions',
                ),
              ),
              TextField(
                controller: lifestyleCtrl,
                decoration: const InputDecoration(labelText: 'Lifestyle'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      if (medicalCtrl.text.trim().isNotEmpty)
        medicalConditions = medicalCtrl.text.trim();
      if (lifestyleCtrl.text.trim().isNotEmpty)
        lifestyle = lifestyleCtrl.text.trim();
    });

    await _saveProfilePatch({
      'medicalConditions': medicalConditions,
      'lifestyle': lifestyle,
    });
  }

  Future<void> _addEmergencyContact() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    setState(() {
      emergencyContacts = [
        ...emergencyContacts,
        {'name': name, 'phone': phone},
      ];
    });

    await _saveProfilePatch({'emergencyContacts': emergencyContacts});
  }

  Future<void> _editDeviceConnection() async {
    final deviceCtrl = TextEditingController(text: connectedDevice);
    bool connected = isConnected;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Device Connection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Connected Device',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Connected'),
                  Switch(
                    value: connected,
                    onChanged: (v) => setLocal(() => connected = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    setState(() {
      if (deviceCtrl.text.trim().isNotEmpty)
        connectedDevice = deviceCtrl.text.trim();
      isConnected = connected;
    });

    await _saveProfilePatch({
      'connectedDevice': connectedDevice,
      'isConnected': isConnected,
    });
  }

  Future<void> _editAlerts() async {
    final hrCtrl = TextEditingController(text: heartRateThreshold);
    bool notifications = notificationToggle;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Alert Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hrCtrl,
                decoration: const InputDecoration(
                  labelText: 'HR Threshold (BPM)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications'),
                  Switch(
                    value: notifications,
                    onChanged: (v) => setLocal(() => notifications = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    setState(() {
      if (hrCtrl.text.trim().isNotEmpty)
        heartRateThreshold = hrCtrl.text.trim();
      notificationToggle = notifications;
    });

    await _saveProfilePatch({
      'heartRateThreshold': heartRateThreshold,
      'notificationToggle': notificationToggle,
    });
  }

  Future<void> _editAiSettings() async {
    final sensCtrl = TextEditingController(text: aiSensitivity);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Settings'),
        content: TextField(
          controller: sensCtrl,
          decoration: const InputDecoration(labelText: 'AI Sensitivity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      if (sensCtrl.text.trim().isNotEmpty) aiSensitivity = sensCtrl.text.trim();
    });

    await _saveProfilePatch({'aiSensitivity': aiSensitivity});
  }

  Future<void> _editGoals() async {
    final rangeCtrl = TextEditingController(text: targetHRRange);
    final goalCtrl = TextEditingController(text: fitnessGoal);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Goals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rangeCtrl,
              decoration: const InputDecoration(labelText: 'Target HR Range'),
            ),
            TextField(
              controller: goalCtrl,
              decoration: const InputDecoration(labelText: 'Fitness Goal'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      if (rangeCtrl.text.trim().isNotEmpty)
        targetHRRange = rangeCtrl.text.trim();
      if (goalCtrl.text.trim().isNotEmpty) fitnessGoal = goalCtrl.text.trim();
    });

    await _saveProfilePatch({
      'targetHRRange': targetHRRange,
      'fitnessGoal': fitnessGoal,
    });
  }

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
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : _profileError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load profile.\n$_profileError',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  ProfileHeader(
                    fullName: fullName,
                    age: age,
                    lifestyle: lifestyle,
                  ),
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
                      EditButton(label: 'Edit', onPressed: _editBasicInfo),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Health Profile
                  SectionCard(
                    title: 'Health Profile',
                    icon: Icons.health_and_safety,
                    children: [
                      InfoRow(
                        label: 'Medical Conditions',
                        value: medicalConditions,
                      ),
                      InfoRow(label: 'Lifestyle', value: lifestyle),
                      EditButton(label: 'Edit', onPressed: _editHealthProfile),
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
                          _saveProfilePatch({'autoNotify': autoNotify});
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
                            _saveProfilePatch({
                              'emergencyContacts': emergencyContacts,
                            });
                          },
                        );
                      }),
                      EditButton(
                        label: 'Add Contact',
                        onPressed: _addEmergencyContact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Device Connection
                  SectionCard(
                    title: 'Device Connection',
                    icon: Icons.watch,
                    children: [
                      InfoRow(
                        label: 'Connected Device',
                        value: connectedDevice,
                      ),
                      ConnectionStatus(isConnected: isConnected),
                      EditButton(
                        label: 'Connect Device',
                        onPressed: _editDeviceConnection,
                      ),
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
                          _saveProfilePatch({
                            'notificationToggle': notificationToggle,
                          });
                        },
                      ),
                      EditButton(label: 'Edit Alerts', onPressed: _editAlerts),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // AI Settings
                  SectionCard(
                    title: 'AI Settings',
                    icon: Icons.smart_toy,
                    children: [
                      InfoRow(label: 'AI Sensitivity', value: aiSensitivity),
                      EditButton(
                        label: 'Additional AI Settings',
                        onPressed: _editAiSettings,
                      ),
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
                      EditButton(label: 'Edit Goals', onPressed: _editGoals),
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
                          _saveProfilePatch({
                            'dataSharingToggle': dataSharingToggle,
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const ActionButton(
                        label: 'Download Health Report',
                        icon: Icons.download,
                      ),
                      const SizedBox(height: 8),
                      const ActionButton(
                        label: 'Upload Medical Report',
                        icon: Icons.upload_file,
                      ),
                      const SizedBox(height: 8),
                      const ActionButton(
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
                      _auth.signOut();
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
