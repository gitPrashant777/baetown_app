import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/user_session.dart';
import 'package:shop/services/user_api_service.dart';
import 'package:shop/route/route_constants.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserApiService _userApiService = UserApiService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // First try to load from local storage as fallback
      await _loadLocalUserData();

      // Then try to fetch from API
      final response = await _userApiService.getProfile();
      
      if (response.success && response.data != null) {
        // Try different response structures
        final profileData = response.data!['user'] ?? 
                           response.data!['data'] ?? 
                           response.data;
        
        setState(() {
          _userProfile = profileData;
          _nameController.text = profileData['name'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        // Show more specific error message
        String errorMessage = response.error ?? 'Failed to load profile';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _loadUserProfile(); // Retry loading
              },
            ),
          ),
        );
        
        // If it's an authentication error, offer to logout and re-login
        if (errorMessage.toLowerCase().contains('session') || 
            errorMessage.toLowerCase().contains('login') ||
            errorMessage.toLowerCase().contains('unauthorized')) {
          _showLoginSuggestion();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Better error handling for different types of errors
      String errorMessage = 'Error loading profile';
      if (e.toString().contains('FormatException') && e.toString().contains('<!DOCTYPE html>')) {
        errorMessage = 'Profile service is currently unavailable. Please try again later.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Error loading profile: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _loadUserProfile(); // Retry loading
            },
          ),
        ),
      );
    }
  }

  Future<void> _loadLocalUserData() async {
    try {
      final userSession = await UserSession.getUserSession();
      
      if (userSession != null && userSession['userData'] != null) {
        final userData = userSession['userData'];
        
        setState(() {
          _userProfile = userData;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
        print('✅ Loaded user data from local session');
      } else if (userSession != null && userSession['email'] != null) {
        // At least we have email from session
        setState(() {
          _emailController.text = userSession['email'];
        });
        print('✅ Loaded email from local session');
      }
    } catch (e) {
      print('⚠️ Could not load local user data: $e');
    }
  }

  void _showLoginSuggestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Expired'),
          content: Text('Your session has expired. Would you like to login again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', 
                  (route) => false,
                );
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final response = await _userApiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Better error handling for HTML responses
      String errorMessage = 'Error updating profile';
      if (e.toString().contains('FormatException') && e.toString().contains('<!DOCTYPE html>')) {
        errorMessage = 'Profile update service is currently unavailable. Please try again later.';
      } else {
        errorMessage = 'Error updating profile: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Logout'),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // Clear local session data
        await UserSession.clearSession();
        
        // Try to call logout API (optional, as it might fail)
        try {
          await _userApiService.logout();
        } catch (e) {
          print('Logout API call failed: $e (continuing with local logout)');
        }

        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          logInScreenRoute,
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      
      // Even if there's an error, clear local session and navigate to login
      await UserSession.clearSession();
      Navigator.of(context).pushNamedAndRemoveUntil(
        logInScreenRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // Logout button in AppBar
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Profile Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              _userProfile?['avatar'] ?? 'https://i.imgur.com/IXnwbLk.png',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: defaultPadding * 2),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: defaultPadding),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: defaultPadding * 2),
                    
                    // Additional Info Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: defaultPadding),
                            _buildInfoRow('User ID', _userProfile?['_id'] ?? 'N/A'),
                            _buildInfoRow('Role', _userProfile?['role'] ?? 'user'),
                            _buildInfoRow('Member Since', _userProfile?['createdAt'] != null 
                              ? DateTime.parse(_userProfile!['createdAt']).toLocal().toString().split(' ')[0]
                              : 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: defaultPadding * 2),
                    
                    // Logout Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: defaultPadding),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
