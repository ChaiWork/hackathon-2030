import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_action_button.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_info_row.dart';
import 'package:vitalife_asistant/screens/widgets_screen/profile_screen_widget/_section_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
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
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeep,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 25),

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

            const SizedBox(height: 20),

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryDeep,
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(email,
                  style: TextStyle(color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}