import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:phone_number_hint/phone_number_hint.dart';
import 'package:sms_retriever_api_plus/sms_retriever_api_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? dataResponse = 'Unknown';
  final _otplessFlutterPlugin = Otpless();
  var loaderVisibility = true;
  final TextEditingController phoneNumberContoller = TextEditingController();
  final TextEditingController otpContoller = TextEditingController();
  final TextEditingController emailContoller = TextEditingController();
  String responseData = "null";
  String phoneOrEmail = '';
  String otp = '';
  bool isWhatsAppInstalled = true;
  bool? isTrueCallerInstalled = true;
  final String result = 'Unknown';
  final phoneNumberHintPlugin = PhoneNumberHint();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add your app id 'https://otpless.com/dashboard/customer/dev-settings'
    _otplessFlutterPlugin.initHeadless("ALP5OU9SMLB3NSPYGNSG");
    _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
    //Add this code to check if whatsapp is installed on device our not
    _otplessFlutterPlugin.isWhatsAppInstalled().then((value) {
      isWhatsAppInstalled = value;
    });
    isTruecallerInstalled();
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

  void onHeadlessResult(result) {
    if (result['statusCode'] == 200) {
      switch (result['responseType'] as String) {
        case "INITIATE":
          {
            print("INITIATE  ${result["response"]}");

            responseData = result.toString();
            setState(() {});
            break;
          }

        case "VERIFY":
          {
            print("VERIFY  ${result["response"]}");

            responseData = result.toString();
            setState(() {});
            break;
          }

        case 'OTP_AUTO_READ':
          {
            if (Platform.isAndroid) {
              var otp = result['response']['otp'] as String;
              print(otp);
              setState(() {
                otpContoller.text = otp;
              });
              startHeadlessForPhoneOrEmail();
            }
          }
          break;
        case 'ONETAP':
          {
            print("ONETAP  ${result["response"]}");
            setState(() {
              isLoading = false;
            });
            responseData = result.toString();
            setState(() {});
          }
      }
    } else {
      //todo
    }
  }

  void isTruecallerInstalled() async {
    isTrueCallerInstalled =
        await InstalledApps.isAppInstalled("com.truecaller");
    if (isTrueCallerInstalled!) {
      startHeadlessWithSocialLogin("TRUE_CALLER");
    } else {
      getPhoneNumber();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPhoneNumber() async {
    String? result;

    try {
      result = await phoneNumberHintPlugin.requestHint() ?? '';

      // Clean and normalize the phone number to 10 digits
      result = _normalizePhoneNumber(result);

      phoneNumberContoller.text = result;
    } on PlatformException {
      result = 'Failed to get hint.';
    }

    // Ensure widget is still mounted
    if (!mounted) return;

    setState(() {
      result = result ?? '';
    });
  }

  String _normalizePhoneNumber(String phoneNumber) {
    // Remove non-numeric characters (like spaces, dashes, and parentheses)
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If the cleaned number has more than 10 digits, trim it to the last 10 digits
    if (cleanedNumber.length > 10) {
      cleanedNumber = cleanedNumber.substring(cleanedNumber.length - 10);
    }

    // Ensure that only a 10-digit number is returned
    if (cleanedNumber.length == 10) {
      return cleanedNumber;
    } else {
      // Return an empty string or an error message if the number isn't valid
      return 'Invalid phone number';
    }
  }

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

  Future<void> openLoginPage() async {
    _otplessFlutterPlugin.setLoaderVisibility(false);
    Map<String, dynamic> arg = {'appId': "ALP5OU9SMLB3NSPYGNSG"};
    _otplessFlutterPlugin.openLoginPage((result) {
      if (result['data'] != null) {
        setState(() {
          responseData = result.toString();
        });
      }
    }, arg);
  }

  Future<void> startHeadlessWithSocialLogin(String loginType) async {
    Map<String, dynamic> arg = {'channelType': loginType};
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> startHeadlessForPhoneOrEmail() async {
    Map<String, dynamic> arg = {};
    if (otpContoller.text.isNotEmpty) {
      if (emailContoller.text.isNotEmpty) {
        arg["email"] = emailContoller.text;
      } else {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "+91";
      }

      arg["otp"] = otpContoller.text;
    } else {
      if (phoneNumberContoller.text.isNotEmpty) {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "+91";
      } else if (emailContoller.text.isNotEmpty) {
        arg["email"] = emailContoller.text;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter phone number or email"),
          ),
        );
      }
    }
    setState(() {
      isLoading = true;
    });
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumberContoller.dispose();
    otpContoller.dispose();
    emailContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Headless"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              TextField(
                controller: phoneNumberContoller,
                keyboardType: TextInputType.number,
                onTap: () {
                  if (phoneNumberContoller.text.isEmpty) {
                    getPhoneNumber();
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Phone number",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailContoller,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: otpContoller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "OTP",
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  startHeadlessForPhoneOrEmail();
                },
                child: Container(
                  height: 45,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54),
                  ),
                  child:
                      const Center(child: Text("Start with Phone and Email")),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Socail Logins",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: GridView.builder(
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 22 / 5,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        startHeadlessWithSocialLogin(
                          index == 0 ? "WHATSAPP" : "GOOGLE",
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Center(
                          child: Text(index == 0 ? "WhatsApp" : "Google"),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Login Page",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  openLoginPage();
                },
                child: Container(
                  height: 45,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Start Login Page"),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(responseData),
            ],
          ),
        ),
      ),
    );
  }
}
