import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? token;

  ///Define the instance
  final _otplessFlutterPlugin = Otpless();
  Map<String, dynamic> extra = {
    'appId': "ALP5OU9SMLB3NSPYGNSG"
  }; //Replace the appId value with your appId value which is provided in the docs

  //************************************************* */
  //This function will run the login page in the app
  //************************************************* */

  Future<void> startOtpless() async {
    _otplessFlutterPlugin.openLoginPage((result) {
      if (result['data'] != null) {
        // todo send this token to your backend service to validate otplessUser details received in the callback with OTPless backend service
        token = result['data']['token'];
        setState(() {});
      }
    }, extra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Token : ",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "$token",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startOtpless();
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
