import 'package:flutter/material.dart';
import 'models/user_session.dart';

// Quick token update utility
class TokenUpdater {
  static const String WORKING_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmIyNmJlNjhlMzhhZTY3ZWY3ZWQwYyIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc1NzE0NDk5MSwiZXhwIjoxNzU3NDA0MTkxfQ.vJCFVxSABlddjrCEuposcoANGjhFMW6_E5cON7r-1X4';
  
  static Future<void> updateToWorkingToken() async {
    print('🚨🚨🚨 UPDATING TO WORKING TOKEN 🚨🚨🚨');
    print('📱 OLD TOKEN: ${UserSession.authToken?.substring(0, 20)}...');
    
    // Update the token in UserSession
    await UserSession.setAuthToken(WORKING_TOKEN);
    
    // Load session to verify
    await UserSession.loadSession();
    
    print('📱 NEW TOKEN: ${UserSession.authToken?.substring(0, 20)}...');
    print('✅ TOKEN UPDATED SUCCESSFULLY!');
  }
}

// Simple widget to test token update
class TokenUpdateWidget extends StatefulWidget {
  @override
  _TokenUpdateWidgetState createState() => _TokenUpdateWidgetState();
}

class _TokenUpdateWidgetState extends State<TokenUpdateWidget> {
  String status = 'Ready to update token';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Token Updater')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  status = 'Updating token...';
                });
                
                try {
                  await TokenUpdater.updateToWorkingToken();
                  setState(() {
                    status = 'Token updated successfully!';
                  });
                } catch (e) {
                  setState(() {
                    status = 'Error: $e';
                  });
                }
              },
              child: Text('Update Token'),
            ),
          ],
        ),
      ),
    );
  }
}
