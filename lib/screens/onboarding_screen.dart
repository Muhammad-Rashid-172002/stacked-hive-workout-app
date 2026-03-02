import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:fitness_tracker_app/components/custom_gradient_button.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  final slides = [
    [
      "🏋️",
      "Gym Tracker",
      "Create custom workouts with personalized exercises, sets, and reps to match your fitness goals."
    ],
    [
      "📊",
      "Track History Offline",
      "All your workout data is stored locally. Track your progress anytime, anywhere without internet."
    ],
    [
      "🔒",
      "100% Privacy",
      "Your data stays on your device. Complete privacy and full control over your fitness journey."
    ],
    [
      "⚡",
      "Fast & Lightweight",
      "Smooth performance with a clean, lightweight design for daily gym tracking."
    ],
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (index < slides.length - 1) {
      _controller.reverse().then((_) {
        setState(() => index++);
        _controller.forward();
      });
    } else {
      _goToMain();
    }
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = slides[index];

    return Scaffold(
      backgroundColor: AppTheme.jetBlack,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              /// ---------------- Skip ----------------
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToMain,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// ---------------- Animated Content ----------------
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [

                      /// Emoji Zoom Animation
                      ScaleTransition(
                        scale: _scale,
                        child: Text(
                          s[0],
                          style: const TextStyle(fontSize: 90),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Title
                      Text(
                        s[1],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Description
                      Text(
                        s[2],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// ---------------- Indicator ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: index == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == i
                          ? AppTheme.primaryRed
                          : AppTheme.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// ---------------- Button ----------------
              CustomGradientButton(
                text:
                    index < slides.length - 1 ? "Continue" : "Start Training",
                // gradientColors: [
                //   AppTheme.primaryRed,
                //   AppTheme.accentRed,
                // ],
                onPressed: _nextSlide,
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
