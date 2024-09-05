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
  final appLinks = AppLinks();
  // List of items
  final List<String> _items = [
    'WHATSAPP',
    'TWITTER',
    'GOOGLE',
    'APPLE',
    'LINKEDIN',
    'MICROSOFT',
    'FACEBOOK',
    'INSTAGRAM',
    'LINE',
    'SLACK',
    'TRUE_CALLER',
    'DROPBOX',
    'GITHUB',
    'BITBUCKET',
    'ATLASSIAN',
    'LINEAR',
    'GITLAB',
    'TIKTOK',
    'TWITCH',
    'TELEGRAM',
    'HUBSPOT',
    'NOTION',
    'BOX',
    'XERO'
  ];

  // Selected item
  String? _selectedItem;
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
              Container(
                width: double.infinity, // Full width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButton<String>(
                    value: _selectedItem,
                    isExpanded: true, // Make it fill the width
                    hint: const Text('Select a channel'),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: const SizedBox(), // Remove default underline
                    items: _items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedItem == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select channel'),
                          behavior: SnackBarBehavior
                              .floating, // Makes the SnackBar floating
                          backgroundColor:
                              Colors.red, // Customize background color
                          duration: const Duration(
                              seconds: 2), // How long the SnackBar will stay
                          shape: RoundedRectangleBorder(
                            // Rounded corners for SnackBar
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(
                              16), // Margin for floating effect
                        ),
                      );
                    } else {
                      oAuthAppLogin(_selectedItem!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Padding for the button
                    textStyle: const TextStyle(
                        fontSize: 18), // Font size of the button text
                  ),
                  child: const Text('Initiate'),
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
