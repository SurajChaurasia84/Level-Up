import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  File? _imageFile;
  bool _isSaving = false;
  AnimationController? _iconAnimationController;

  final List<IconData> _habitIcons = [
    Icons.directions_run_rounded,
    Icons.local_drink_rounded,
    Icons.menu_book_rounded,
    Icons.self_improvement_rounded,
    Icons.book_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    Icons.water_drop_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    setState(() => _isSaving = true);

    String imagePath = "";
    if (_imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(_imageFile!.path);
      final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');
      imagePath = savedImage.path;
    }

    if (mounted) {
      await context.read<HabitProvider>().completeOnboarding(
            _nameController.text,
            imagePath,
          );
    }
  }

  Widget _buildIconMarquee() {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _iconAnimationController,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(-_iconAnimationController.value, 0),
            child: Row(
              children: List.generate(3, (index) => _buildIconRow()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconRow() {
    return Row(
      children: _habitIcons.map((icon) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.4), size: 30),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildIconMarquee(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      "Level Up Your Life",
                      style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your journey to greatness starts here.",
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 50),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                            child: _imageFile == null
                                ? const Icon(Icons.person_rounded, size: 70, color: AppTheme.primaryColor)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // Added space to avoid keyboard overlap
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 8,
              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
