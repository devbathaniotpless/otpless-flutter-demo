import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otpless_flutter_web/otpless_flutter_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otpless Flutter Web Testing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  String? data;
  String dataResponse = 'Unknown';
  final TextEditingController phoneNumberContoller = TextEditingController();
  final TextEditingController otpContoller = TextEditingController();
  final TextEditingController emailContoller = TextEditingController();
  //Define the instance
  final _otplessFlutterPlugin = Otpless();
  final completer = Completer<String>();

  void onHeadlessResult(dynamic result) {
    setState(() {
      print(result);
      dataResponse = result;
      if (jsonDecode(dataResponse)['responseType'] != 'INITIATE') {
        data = jsonDecode(dataResponse)['response']['identities'][0]
            ['identityValue'];
        name = jsonDecode(dataResponse)['response']['identities'][0]['name'];
      }
      setState(() {});
    });
  }

  void initiateOAuth(String channelType) async {
    _otplessFlutterPlugin.initiateOAuth(onHeadlessResult, channelType);
  }

  void initiatePhoneEmailAuth() async {
    Map<String, dynamic> arg = {};
    if (otpContoller.text.isNotEmpty) {
      if (phoneNumberContoller.text.isNotEmpty) {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "91";
      } else {
        arg["email"] = emailContoller.text;
      }

      arg["otp"] = otpContoller.text;

      _otplessFlutterPlugin.verifyAuth(onHeadlessResult, arg);
    } else {
      if (phoneNumberContoller.text.isNotEmpty) {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "91";

        _otplessFlutterPlugin.initiatePhoneAuth(onHeadlessResult, arg);
      } else if (emailContoller.text.isNotEmpty) {
        arg["email"] = emailContoller.text;

        _otplessFlutterPlugin.initiateEmailAuth(onHeadlessResult, arg);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter phone number or email"),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _otplessFlutterPlugin.headlessResponse(onHeadlessResult);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              Text(
                "Name : $name",
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Data : $data",
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              TextField(
                controller: phoneNumberContoller,
                keyboardType: TextInputType.number,
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
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      initiatePhoneEmailAuth();
                    },
                    child: const Text(
                      "PHONE/EMAIL",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      initiateOAuth("GOOGLE");
                    },
                    child: const Text(
                      "OAUTH",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
