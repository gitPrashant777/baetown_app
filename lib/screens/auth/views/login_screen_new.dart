import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/services/auth_api_service.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthApiService _authApi = AuthApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String userEmail = '';
  String userPassword = '';
  bool _isLoading = false;

  void _handleEmailChanged(String email) {
    setState(() {
      userEmail = email.trim();
    });
  }

  void _handlePasswordChanged(String password) {
    setState(() {
      userPassword = password;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get email and password from form controllers
        String email = _emailController.text.trim();
        String password = _passwordController.text;
        
        print('🔐 Attempting login for: $email');
        
        final response = await _authApi.login(
          email: email,
          password: password,
        );

        if (response.success && response.data != null) {
          // Login successful
          final userData = response.data!;
          print('🔐 Login successful! Response: $userData');
          
          // Extract auth token from response
          String? authToken = userData['token'] ?? 
                             userData['accessToken'] ?? 
                             userData['data']?['token'];
          
          // Handle different user data structures
          Map<String, dynamic>? user = userData['user'] ?? 
                                      userData['data']?['user'] ?? 
                                      (userData['email'] != null ? userData : null);
          
          if (user != null) {
            // Save user session with complete user data
            await UserSession.setUserSession(
              user['email'], 
              token: authToken,
              userData: user,
            );
            
            // Check user role from backend response
            String? userRole = user['role']?.toString().toLowerCase();
            bool isAdmin = userRole == 'admin';
            
            print('🔐 Backend role check: email=${user['email']}, role=$userRole, isAdmin=$isAdmin');
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAdmin ? 'Admin login successful!' : 'Login successful!'),
                  backgroundColor: Colors.green,
                ),
              );
                            
              if (isAdmin) {
                // Navigate to admin panel
                print('📱 Navigating to admin panel...');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  adminPanelScreenRoute,
                  (route) => false,
                );
              } else {
                // Navigate to regular user home screen
                print('🚀 Navigating to regular home screen...');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  entryPointScreenRoute,
                  (route) => false,
                );
              }
            }
          } else {
            // No user data found - fallback navigation
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful but user data not found'),
                  backgroundColor: Colors.orange,
                ),
              );
              
              Navigator.pushNamedAndRemoveUntil(
                context,
                entryPointScreenRoute,
                (route) => false,
              );
            }
          }
        } else {
          // Check if this is a user not found error
          if (response.error != null && 
              response.error!.toLowerCase().contains('user not found')) {
            if (mounted) {
              // Show user not found message and auto-redirect to registration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account not found. Redirecting to registration...'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              
              // Wait 2 seconds then navigate to signup
              await Future.delayed(const Duration(seconds: 2));
              
              if (mounted) {
                Navigator.pushReplacementNamed(context, signUpScreenRoute);
                
                // Show welcome message on signup screen
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Welcome! Please create your account to continue.'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                });
              }
            }
          } else {
            // Regular error handling
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.error ?? 'Login failed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        print('❌ Login error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/Illustration/Illustration.png",
              height: size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Sign in with your email and password  or continue with social media",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onEmailChanged: _handleEmailChanged,
                    onPasswordChanged: _handlePasswordChanged,
                  ),
                  
                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height > 700
                        ? size.height * 0.1
                        : defaultPadding,
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            UserSession.isAdminEmail(userEmail)
                                ? "Login as Admin" 
                                : "Log in"
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
