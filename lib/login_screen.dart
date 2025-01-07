import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _otplessFlutterPlugin = Otpless();
  var arg = {
    'appId': 'SUDJU2N3M8Q5XB3H6HN5',
  };
  String data = '';

  @override
  void initState() {
    super.initState();
    // Add your app id 'https://otpless.com/dashboard/customer/dev-settings'
    openLoginPage();
  }

  void openLoginPage() async {
    await _otplessFlutterPlugin.openLoginPage((result) {
      print("Result : $result");
      setState(() {
        if (result['data'] != null) {
          data = result;
        } else {
          data = result['errorMessage'];
        }
      });
    }, arg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prebuilt UI"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
