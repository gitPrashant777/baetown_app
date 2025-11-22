// lib/screens/consultation/call_screen.dart

import 'package:flutter/material.dart';

import '../../../services/agora_config.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final bool isVideoCall;
  final int uid; // doctor or patient UID (0,1 etc.)

  const CallScreen({
    super.key,
    required this.channelName,
    required this.isVideoCall,
    required this.uid,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
 
}
