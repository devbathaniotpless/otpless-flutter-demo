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
  var extra = {
    "method": "get",
    "params": {
      "cid":
          "HRIRBIIKXMKEOTDDA8VV4HP2V24454X8", //Replace the cid value with your CID value which is provided in the docs
      "uxmode": "anf", // Add this code to enable autoclick mode
    },
  };

  @override
  void initState() {
    super.initState();

    //******************************************************** */
    //This function will tell if WhatsApp is Installed or not
    //******************************************************** */

    _otplessFlutterPlugin.isWhatsAppInstalled().then(
      (value) {
        if (!value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please install the whatsapp"),
              backgroundColor: Theme.of(context).hoverColor,
            ),
          );
        }
      },
    );
  }

  //************************************************* */
  //This function will run the login page in the app
  //************************************************* */

  Future<void> startOtpless() async {
    await _otplessFlutterPlugin.hideFabButton();
    _otplessFlutterPlugin.start((result) {
      if (result['data'] != null) {
        // todo send this token to your backend service to validate otplessUser details received in the callback with OTPless backend service
        token = result['data']['token'];
        setState(() {});
      }
    }, jsonObject: extra);
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
                      fontSize: 15,
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
