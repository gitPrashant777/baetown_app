import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/components/network_image_with_loader.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userEmail = '';

  void _handleEmailChanged(String email) {
    setState(() {
      userEmail = email.trim();
    });
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Set user session
      UserSession.setUserSession(userEmail);
      
      // Check if user is admin
      if (UserSession.isAdmin) {
        // Navigate to admin panel for admin user
        Navigator.pushNamedAndRemoveUntil(
          context,
          adminPanelScreenRoute,
          (route) => false, // Remove all previous routes
        );
      } else {
        // Navigate to regular user home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          ModalRoute.withName(logInScreenRoute),
        );
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
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: NetworkImageWithLoader(
                "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80",
                fit: BoxFit.cover,
              ),
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
                    "Log in with your data that you intered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    onEmailChanged: _handleEmailChanged,
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
                    onPressed: _handleLogin,
                    child: Text(
                      UserSession.isAdmin || userEmail.toLowerCase() == 'admin@gmail.com'
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
                          Navigator.pushNamed(context, signUpScreenRoute);
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
