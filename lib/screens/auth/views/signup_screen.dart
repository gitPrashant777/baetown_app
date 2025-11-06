import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/services/auth_api_service.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthApiService _authApi = AuthApiService();
  
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  @override
  void initState() {
    super.initState();
    
    // Show welcome message for users redirected from login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route?.settings.arguments == 'from_login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Welcome! Please create your account to continue.'),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _handleNameChanged(String name) {
    setState(() {
      userName = name.trim();
    });
  }

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

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call your MERN backend API
        final response = await _authApi.register(
          name: userName,
          email: userEmail,
          password: userPassword,
        );

        if (response.success && response.data != null) {
          // Registration successful
          final userData = response.data!;
          
          // Extract auth token from response
          String? authToken;
          if (userData['token'] != null) {
            authToken = userData['token'];
          } else if (userData['data'] != null && userData['data']['token'] != null) {
            authToken = userData['data']['token'];
          } else if (userData['accessToken'] != null) {
            authToken = userData['accessToken'];
          }
          
          // Set user session if user data is available
          Map<String, dynamic>? user;
          if (userData['user'] != null) {
            user = userData['user'];
          } else if (userData['data'] != null && userData['data']['user'] != null) {
            user = userData['data']['user'];
          } else if (userData['email'] != null) {
            user = userData;
          }
          
          if (user != null && user['email'] != null) {
            await UserSession.setUserSession(
              user['email'], 
              token: authToken,
              userData: user, // Pass the complete user data
            );
            print('✅ Registration: User session set with complete data');
          } else {
            // Fallback if no user object is available
            await UserSession.setUserSession(
              userEmail, 
              token: authToken,
            );
            print('⚠️ Registration: User session set with limited data');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Welcome!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushNamedAndRemoveUntil(
            context, 
            onboarding,
            (route) => false,
          );
        } else {
          // Registration failed - handle specific errors
          String errorMessage = response.error ?? 'Registration failed. Please try again.';
          
          if (errorMessage.toLowerCase().contains('already exists') || 
              errorMessage.toLowerCase().contains('duplicate')) {
            errorMessage = 'An account with this email already exists. Please login instead.';
          } else if (errorMessage.toLowerCase().contains('invalid email')) {
            errorMessage = 'Please enter a valid email address.';
          } else if (errorMessage.toLowerCase().contains('password')) {
            errorMessage = 'Password must be at least 6 characters long.';
          } else if (errorMessage.toLowerCase().contains('required')) {
            errorMessage = 'Please fill in all required fields.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Network or API error
        String errorMessage = 'Registration failed. Please try again.';
        
        if (e.toString().toLowerCase().contains('network') || 
            e.toString().toLowerCase().contains('connection') ||
            e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().toLowerCase().contains('server')) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: NetworkImageWithLoader(
                "https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let’s get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    onNameChanged: _handleNameChanged,
                    onEmailChanged: _handleEmailChanged,
                    onPasswordChanged: _handlePasswordChanged,
                  ),
                  const SizedBox(height: defaultPadding),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTermsAccepted = !_isTermsAccepted;
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          onChanged: (value) {
                            setState(() {
                              _isTermsAccepted = value ?? false;
                            });
                          },
                          value: _isTermsAccepted,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "I agree with the",
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, termsOfServicesScreenRoute);
                                    },
                                  text: " Terms of service ",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: "& privacy policy.",
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: (_isTermsAccepted && !_isLoading) ? _handleSignUp : null,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Continue"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
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
