import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/models/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Start animation and navigate after delay
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Start the animation
    _animationController.forward();

    // Wait for 2 seconds for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is already logged in
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Load saved user session
      await UserSession.loadSession();

      // Wait a bit more for smooth transition
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        if (UserSession.isLoggedIn) {
          // User is logged in, check if admin or regular user
          if (UserSession.isAdmin) {
            // Admin user - navigate to admin panel
            Navigator.of(context).pushReplacementNamed(adminPanelScreenRoute);
          } else {
            // Regular user - navigate to home screen
            Navigator.of(context).pushReplacementNamed(entryPointScreenRoute);
          }
        } else {
          // User is not logged in, navigate to login screen
          Navigator.of(context).pushReplacementNamed(logInScreenRoute);
        }
      }
    } catch (e) {
      // If there's an error loading session, go to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(logInScreenRoute);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Title (moved up, logo removed)
                    Text(
                      'BAETOWN',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Changed to black color
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Loading indicator
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
