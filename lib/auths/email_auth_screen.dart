import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _otplessFlutterPlugin = Otpless();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpContoller = TextEditingController();
  String responseData = "null";
  bool isLoading = false;

  Future<void> sendEmailRequest() async {
    Map<String, dynamic> arg = {};
    if (otpContoller.text.isNotEmpty) {
      arg["email"] = emailController.text;
      arg["otp"] = otpContoller.text;
    } else {
      if (emailController.text.isNotEmpty) {
        arg["email"] = emailController.text;
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    otpContoller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Email Auth"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
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
                  sendEmailRequest();
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
