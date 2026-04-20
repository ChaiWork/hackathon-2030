import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_action_button.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_info_row.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_section_card.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
import 'package:vitalife_asistant/ui/responsive.dart';
// IMPORT SERVICE


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? user;

  // USER INFO
  String fullName = '';
  String email = '';

  // HEALTH DATA
  String age = '';
  String gender = '';
  String height = '';
  String weight = '';

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();
    _loadAuthUser();
    _loadFirestoreProfile();
  }

  void _loadAuthUser() {
    user = _auth.currentUser;

    setState(() {
      fullName = user?.displayName ?? 'No Name';
      email = user?.email ?? '';
    });
  }

  Future<void> _loadFirestoreProfile() async {
    final uid = _auth.currentUser!.uid;

    final data = await _firestoreService.getUserProfile(uid);

    if (data != null) {
      setState(() {
        age = data['age'] ?? '';
        gender = data['gender'] ?? '';
        height = data['height'] ?? '';
        weight = data['weight'] ?? '';
      });
    }
  }

  // =========================
  // DISPLAY HELPERS
  // =========================
  String get displayAge =>
      age.isEmpty ? 'Please insert the values' : age;

  String get displayGender =>
      gender.isEmpty ? 'Please insert the values' : gender;

  String get displayHeight =>
      height.isEmpty ? 'Please insert the values' : height;

  String get displayWeight =>
      weight.isEmpty ? 'Please insert the values' : weight;

  // =========================
  // EDIT + SAVE
  // =========================
  void _editBasicInfo() {
    final ageController = TextEditingController(text: age);
    final genderController = TextEditingController(text: gender);
    final heightController = TextEditingController(text: height);
    final weightController = TextEditingController(text: weight);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Basic Information"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: "Height"),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: "Weight"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = _auth.currentUser!.uid;

                setState(() {
                  age = ageController.text.trim();
                  gender = genderController.text.trim();
                  height = heightController.text.trim();
                  weight = weightController.text.trim();
                });

                await _firestoreService.saveUserProfile(
                  uid: uid,
                  age: age,
                  gender: gender,
                  height: height,
                  weight: weight,
                  email: email,
                  fullName: fullName,
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final titleFont = r.s(24, min: 20, max: 30);
    final sectionGap = r.gapV(0.03, min: 16, max: 25);

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontSize: titleFont,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeep,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: r.screenPadding,
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: sectionGap),

            SectionCard(
              title: 'Basic Information',
              icon: Icons.person,
              showEditButton: true,
              onEdit: _editBasicInfo,
              children: [
                InfoRow(label: 'Full Name', value: fullName),
                InfoRow(label: 'Email', value: email),
                InfoRow(label: 'Age', value: displayAge),
                InfoRow(label: 'Gender', value: displayGender),
                InfoRow(label: 'Height', value: displayHeight),
                InfoRow(label: 'Weight', value: displayWeight),
              ],
            ),

            SizedBox(height: r.gapV(0.025, min: 14, max: 20)),

            ActionButton(
              label: 'Logout',
              icon: Icons.logout,
              isDestructive: true,
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    final r = Responsive.of(context);
    final pad = r.gapH(0.05, min: 16, max: 24);
    final radius = r.s(20, min: 16, max: 22);
    final avatarRadius = r.s(28, min: 22, max: 32);
    final gap = r.gapH(0.04, min: 12, max: 16);
    final nameFont = r.s(18, min: 16, max: 20);
    final emailFont = r.s(14, min: 12, max: 15);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primaryDeep,
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: r.s(16, min: 14, max: 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: nameFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: emailFont,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}