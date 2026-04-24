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
  String selectedGender = '';
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
  }

  void _loadAuthUser() {
    user = _auth.currentUser;

    setState(() {
      fullName = user?.displayName ?? 'No Name';
      email = user?.email ?? '';
    });
  }

  // ✅ REAL-TIME PROFILE LISTENER
  Stream<Map<String, dynamic>?> _getUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }
    return _firestoreService.getUserProfileStream(uid);
  }

  // =========================
  // DISPLAY HELPERS
  // =========================
  // ✅ Now computed dynamically in StreamBuilder

  // =========================
  // EDIT + SAVE
  // =========================
  void _editBasicInfo() {
    final ageController = TextEditingController(text: age);
    selectedGender = gender;
    final heightController = TextEditingController(text: height);
    final weightController = TextEditingController(text: weight);

    final r = Responsive.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // INPUT FIELDS
                  _buildInputField("Age", ageController, Icons.cake),
                  _buildGenderDropdown(),
                  _buildInputField(
                    "Height (cm)",
                    heightController,
                    Icons.height,
                  ),
                  _buildInputField(
                    "Weight (kg)",
                    weightController,
                    Icons.monitor_weight,
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final uid = _auth.currentUser!.uid;

                            setState(() {
                              age = ageController.text.trim();
                              gender = selectedGender;
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

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile updated successfully ✅"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDeep,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
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

            // ✅ REAL-TIME PROFILE STREAM
            StreamBuilder<Map<String, dynamic>?>(
              stream: _getUserProfileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SectionCard(
                    title: 'Basic Information',
                    icon: Icons.person,
                    showEditButton: true,
                    onEdit: _editBasicInfo,
                    children: const [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return SectionCard(
                    title: 'Basic Information',
                    icon: Icons.person,
                    showEditButton: true,
                    onEdit: _editBasicInfo,
                    children: [
                      Text('Error loading profile: ${snapshot.error}'),
                    ],
                  );
                }

                final profileData = snapshot.data;
                final displayAge = (profileData?['age'] ?? '') as String;
                final displayGender = (profileData?['gender'] ?? '') as String;
                final displayHeight = (profileData?['height'] ?? '') as String;
                final displayWeight = (profileData?['weight'] ?? '') as String;

                final finalAge = displayAge.isEmpty
                    ? 'Please insert the values'
                    : displayAge;
                final finalGender = displayGender.isEmpty
                    ? 'Please insert the values'
                    : displayGender;
                final finalHeight = displayHeight.isEmpty
                    ? 'Please insert the values'
                    : displayHeight;
                final finalWeight = displayWeight.isEmpty
                    ? 'Please insert the values'
                    : displayWeight;

                return SectionCard(
                  title: 'Basic Information',
                  icon: Icons.person,
                  showEditButton: true,
                  onEdit: _editBasicInfo,
                  children: [
                    InfoRow(label: 'Full Name', value: fullName),
                    InfoRow(label: 'Email', value: email),
                    InfoRow(label: 'Age', value: finalAge),
                    InfoRow(label: 'Gender', value: finalGender),
                    InfoRow(label: 'Height', value: finalHeight),
                    InfoRow(label: 'Weight', value: finalWeight),
                  ],
                );
              },
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
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedGender.isNotEmpty ? selectedGender : null,
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
          DropdownMenuItem(
            value: "Rather not say",
            child: Text("Rather not say"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedGender = value!;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person, color: Colors.grey),
          labelText: "Gender",
          filled: true,
          fillColor: const Color(0xFFF5F7FB),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField(
  String label,
  TextEditingController controller,
  IconData icon,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
