import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/models/user_session.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _logoGlowAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // Scale animation for subtle zoom effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Main fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Slide from bottom with bounce
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Subtle scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    // Delayed tagline animation
    _taglineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Shimmer effect for premium feel
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    // Logo glow pulse animation
    _logoGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start splash sequence
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Start all animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _shimmerController.repeat(reverse: true);
    _particleController.repeat();

    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 3000));

    // Check login status
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await UserSession.loadSession();
      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        if (UserSession.isLoggedIn) {
          if (UserSession.isAdmin) {
            Navigator.of(context).pushReplacementNamed(adminPanelScreenRoute);
          } else {
            Navigator.of(context).pushReplacementNamed(entryPointScreenRoute);
          }
        } else {
          Navigator.of(context).pushReplacementNamed(logInScreenRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(logInScreenRoute);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF0A0A0A),
              const Color(0xFF1A1A2E),
              const Color(0xFF020953).withOpacity(0.3),
            ]
                : [
              const Color(0xFFFFFFFE),
              const Color(0xFFFAF9F6),
              const Color(0xFFF5F3F0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    animation: _particleController.value,
                    isDark: isDark,
                  ),
                  size: size,
                );
              },
            ),

            // Subtle radial gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: isDark
                      ? [
                    const Color(0xFF020953).withOpacity(0.1),
                    Colors.transparent,
                  ]
                      : [
                    const Color(0xFF020953).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeController,
                  _slideController,
                  _scaleController,
                  _shimmerController,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Decorative top line
                            FadeTransition(
                              opacity: _taglineAnimation,
                              child: Container(
                                width: 60,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.5),
                                      Colors.transparent,
                                    ]
                                        : [
                                      Colors.transparent,
                                      const Color(0xFF020953).withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Premium brand name with glow effect
                            Stack(
                              children: [
                                // Glow effect
                                AnimatedBuilder(
                                  animation: _logoGlowAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _logoGlowAnimation.value * 0.3,
                                      child: Text(
                                        'BAETOWN',
                                        style: TextStyle(
                                          fontSize: 52,
                                          fontWeight: FontWeight.w200,
                                          letterSpacing: 12.0,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 2
                                            ..color = isDark
                                                ? Colors.white.withOpacity(0.3)
                                                : const Color(0xFF020953).withOpacity(0.2)
                                            ..maskFilter = const MaskFilter.blur(
                                                BlurStyle.normal, 10),
                                          fontFamily: 'Serif',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Main text with shimmer
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [
                                        Colors.white,
                                        Colors.white.withOpacity(0.9),
                                        Colors.white,
                                      ]
                                          : [
                                        const Color(0xFF020953),
                                        const Color(0xFF020953).withOpacity(0.8),
                                        const Color(0xFF020953),
                                      ],
                                      stops: [
                                        _shimmerAnimation.value - 0.3,
                                        _shimmerAnimation.value,
                                        _shimmerAnimation.value + 0.3,
                                      ].map((e) => e.clamp(0.0, 1.0)).toList(),
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    'BAETOWN',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: 12.0,
                                      height: 1.2,
                                      color: Colors.white,
                                      fontFamily: 'Serif',
                                      shadows: isDark
                                          ? [
                                        Shadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 20,
                                        ),
                                      ]
                                          : [
                                        Shadow(
                                          color: const Color(0xFF020953).withOpacity(0.2),
                                          offset: const Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Elegant divider with animation
                            FadeTransition(
                              opacity: _taglineAnimation,
                              child: Container(
                                width: 80,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.4),
                                      Colors.transparent,
                                    ]
                                        : [
                                      Colors.transparent,
                                      const Color(0xFF020953).withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Animated tagline
                            FadeTransition(
                              opacity: _taglineAnimation,
                              child: Text(
                                'Timeless Beauty, Modern Science',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2.0,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : const Color(0xFF020953).withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 70),

                            // Premium loading indicator with pulse
                            FadeTransition(
                              opacity: _taglineAnimation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer pulse ring
                                  AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 60 + (math.sin(_particleController.value * 2 * math.pi) * 5),
                                        height: 60 + (math.sin(_particleController.value * 2 * math.pi) * 5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.1)
                                                : const Color(0xFF020953).withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Main indicator
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : const Color(0xFF020953).withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom brand accent with fade
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineAnimation,
                child: Column(
                  children: [
                    Text(
                      'EST. 2024',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.0,
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : const Color(0xFF020953).withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ]
                              : [
                            Colors.transparent,
                            const Color(0xFF020953).withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for floating particles
class ParticlePainter extends CustomPainter {
  final double animation;
  final bool isDark;

  ParticlePainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : const Color(0xFF020953).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Create floating particles
    final particleCount = 30;
    for (int i = 0; i < particleCount; i++) {
      final random = math.Random(i);
      final x = size.width * random.nextDouble();
      final yOffset = (animation * size.height + (i * 50)) % size.height;
      final y = yOffset;
      final radius = 1.0 + (random.nextDouble() * 2);

      // Pulsating effect
      final pulseScale = 1.0 + (math.sin(animation * 2 * math.pi + i) * 0.3);

      canvas.drawCircle(
        Offset(x, y),
        radius * pulseScale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
