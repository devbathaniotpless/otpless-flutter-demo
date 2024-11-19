import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class SocialLoginAuthScreen extends StatefulWidget {
  const SocialLoginAuthScreen({super.key});

  @override
  State<SocialLoginAuthScreen> createState() => _SocialLoginAuthScreenState();
}

enum SocialPlatforms {
  WHATSAPP,
  GMAIL,
  APPLE,
  LINKEDIN,
  MICROSOFT,
  FACEBOOK,
  SLACK,
  TWITTER,
  DISCORD,
  LINE,
  LINEAR,
  NOTION,
  TWITCH,
  GITHUB,
  BITBUCKET,
  ATLASSIAN,
  GITLAB,
  TRUE_CALLER,
}

class _SocialLoginAuthScreenState extends State<SocialLoginAuthScreen> {
  SocialPlatforms? _selectedPlatform;
  final _otplessFlutterPlugin = Otpless();
  String responseData = "null";
  bool isWhatsAppInstalled = true;

  Future<void> startHeadlessWithSocialLogin(String loginType) async {
    Map<String, dynamic> arg = {'channelType': loginType};
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  @override
  void initState() {
    _otplessFlutterPlugin.isWhatsAppInstalled().then((value) {
      setState(() {
        isWhatsAppInstalled = value;
        print(isWhatsAppInstalled);
      });
    });
    super.initState();
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

        case 'ONETAP':
          {
            print("ONETAP  ${result["response"]}");
            responseData = result.toString();
            setState(() {});
          }
      }
    } else {
      //todo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Social Login Auth"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              DropdownButton<SocialPlatforms>(
                hint: const Text("Select a platform"),
                value: _selectedPlatform,
                onChanged: (SocialPlatforms? newValue) {
                  setState(() {
                    if (newValue!.name == "WHATSAPP") {
                      if (isWhatsAppInstalled) {
                        _selectedPlatform = newValue;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please install WhatsApp"),
                          ),
                        );
                      }
                    } else {
                      _selectedPlatform = newValue;
                    }
                  });
                },
                items: SocialPlatforms.values.map((SocialPlatforms platform) {
                  return DropdownMenuItem<SocialPlatforms>(
                    value: platform,
                    child: Text(platform.toString().split('.').last),
                  );
                }).toList(),
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
              _selectedPlatform == null
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: () {
                        startHeadlessWithSocialLogin(_selectedPlatform!.name);
                      },
                      child: Container(
                        height: 45,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: const Center(
                          child: Text("Send Request"),
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
