import 'package:flutter/material.dart';
import 'package:surveyor_app_planzaa/common/appBar.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Privacy Policy"),
      body: Center(child: Text('No Privacy Policy')),
      ); 
      
    
  }
}