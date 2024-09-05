import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String responseData = "null";
  final appLinks = AppLinks(); // AppLinks is singleton
  var headers = {
    'Content-Type': 'application/json',
    'clientId': 'YOUR_CLIENT_ID',
    'clientSecret': 'YOUR_CLIENT_SECRET'
  };

  @override
  void initState() {
    listenForCode();
    super.initState();
  }

  void listenForCode() {
    // Subscribe to all events (initial link and further)
    appLinks.uriLinkStream.listen((uri) {
      final queryParameters = uri.queryParameters;
      final code = queryParameters["code"];
      if (code != null) {
        verifyCode(code);
      }
    });
  }

  Future<void> oAuthAppLogin(String channel) async {
    var request = http.Request(
        'POST', Uri.parse('https://auth.otpless.app/auth/v1/initiate/oauth'));
    request.body =
        json.encode({"channel": channel, "redirectURI": "oauth://otpless"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      responseData = await response.stream.bytesToString();
      launchUrlString(jsonDecode(responseData)["link"]);
      setState(() {});
    } else {
      print(response.reasonPhrase);
      responseData = response.reasonPhrase!;
      setState(() {});
    }
  }

  Future<void> verifyCode(String code) async {
    var request = http.Request(
        'POST', Uri.parse('https://auth.otpless.app/auth/v1/verify/code'));
    request.body = json.encode({"code": code});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      responseData = await response.stream.bytesToString();
      setState(() {});
    } else {
      print(response.reasonPhrase);
      responseData = response.reasonPhrase!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Headless"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Text(
                "Social Logins",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 22 / 6,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        oAuthAppLogin(
                          index == 0
                              ? "WHATSAPP"
                              : index == 1
                                  ? "FACEBOOK"
                                  : "GOOGLE",
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black54),
                          ),
                          child: Center(
                            child: Text(
                              index == 0
                                  ? "WhatsApp"
                                  : index == 1
                                      ? "Facebook"
                                      : "Google",
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              Wrap(
                children: [Text(responseData)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
