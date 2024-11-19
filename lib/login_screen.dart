import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:otpless_flutter_demo/auths/email_auth_screen.dart';
import 'package:otpless_flutter_demo/auths/phone_number_auth_screen.dart';
import 'package:otpless_flutter_demo/auths/social_login_auth_screen.dart';
import 'package:sms_retriever_api_plus/sms_retriever_api_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _otplessFlutterPlugin = Otpless();

  @override
  void initState() {
    super.initState();
    // Add your app id 'https://otpless.com/dashboard/customer/dev-settings'
    _otplessFlutterPlugin.initHeadless("SUDJU2N3M8Q5XB3H6HN5");
    _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
    getSignature();
  }

  Future<void> getSignature() async {
    String signature = "";
    try {
      signature = await SmsRetrieverApiPlus.getSignature() ??
          'Unknown platform version';

      print("signature$signature");
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
  }

  void onHeadlessResult(result) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Headless"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PhoneNumberAuthScreen(),
                  ),
                );
              },
              child: const Text("Phone number Auth"),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmailAuthScreen(),
                  ),
                );
              },
              child: const Text("Email Auth"),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SocialLoginAuthScreen(),
                  ),
                );
              },
              child: const Text("Social Login Auth"),
            ),
          ],
        ),
      ),
    );
  }
}
