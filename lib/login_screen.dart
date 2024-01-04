import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;

  ///Define the instance
  final _otplessFlutterPlugin = Otpless();
  var extra = {
    "method": "get",
    "params": {
      "cid": "HRIRBIIKXMKEOTDDA8VV4HP2V24454X8",
      "crossButtonHidden": "true",
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
        } else {
          startOtpless();
        }
      },
    );
  }

  //************************************************* */
  //This function will run the login page in the app
  //************************************************* */

  Future<void> startOtpless() async {
    await _otplessFlutterPlugin.hideFabButton();
    _otplessFlutterPlugin.openLoginPage((result) {
      if (result['data'] != null) {
        // todo send this token to your backend service to validate otplessUser details received in the callback with OTPless backend service
        token = result['data']['token'];
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              "Token : $token",
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
