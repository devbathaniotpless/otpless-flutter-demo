import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:phone_number_hint/phone_number_hint.dart';

class PhoneNumberAuthScreen extends StatefulWidget {
  const PhoneNumberAuthScreen({super.key});

  @override
  State<PhoneNumberAuthScreen> createState() => _PhoneNumberAuthScreenState();
}

class _PhoneNumberAuthScreenState extends State<PhoneNumberAuthScreen> {
  final _otplessFlutterPlugin = Otpless();
  final TextEditingController phoneNumberContoller = TextEditingController();
  final TextEditingController otpContoller = TextEditingController();
  final phoneNumberHintPlugin = PhoneNumberHint();
  String responseData = "null";
  bool isLoading = false;
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

  Future<void> sendPhoneNumberRequest() async {
    Map<String, dynamic> arg = {};
    if (otpContoller.text.isNotEmpty) {
      arg["phone"] = phoneNumberContoller.text;
      arg["countryCode"] = "+91";
      arg["otp"] = otpContoller.text;
    } else {
      if (phoneNumberContoller.text.isNotEmpty) {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "+91";
        arg["deliveryChannel"] = "SMS";
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

  void onHeadlessResult(result) {
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
      case "FALLBACK_TRIGGERED":
        {
          print("FALLBACK_TRIGGERED  ${result["response"]}");

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
            sendPhoneNumberRequest();
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
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumberContoller.dispose();
    otpContoller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Phone Number Auth"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                controller: otpContoller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "OTP",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 450,
                width: MediaQuery.sizeOf(context).width,
                child: SingleChildScrollView(
                  child: Center(child: Wrap(children: [Text(responseData)])),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  sendPhoneNumberRequest();
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
                        : const Text("Send Request"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
