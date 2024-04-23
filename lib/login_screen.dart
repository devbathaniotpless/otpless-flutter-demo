import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? token;
  String? dataResponse = 'Unknown';

  ///Define the instance
  final _otplessFlutterPlugin = Otpless();

  //************************************************* */
  //This function will run the login page in the app
  //************************************************* */

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': "YOUR_APP_ID"};
    _otplessFlutterPlugin.openLoginPage((result) {
      String? message;
      if (result['data'] != null) {
        final token = result["response"]["token"];
        message = "token: $token";
      }
      setState(() {
        dataResponse = message ?? "Unknown";
      });
    }, arg);
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
                    openLoginPage();
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
