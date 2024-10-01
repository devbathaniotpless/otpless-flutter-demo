# Flutter

Integrating One Tap OTPLESS Sign In into your Flutter Application using our SDK is a streamlined process. This guide offers a comprehensive walkthrough, detailing the steps to install the SDK and seamlessly retrieve user information.

1. Install **OTPless SDK** Dependency

```
flutter pub add otpless_flutter:2.1.9
```

2. Configure **AndroidManifest.xml**

`Android`

- Add an intent filter inside your Main Activity code block.

```xml
<intent-filter>
<action android:name="android.intent.action.VIEW" />
<category android:name="android.intent.category.DEFAULT" />
<category android:name="android.intent.category.BROWSABLE" />
<data
	android:host="otpless"
	android:scheme= "otpless.YOUR_APP_ID_IN_LOWERCASE"/>
</intent-filter>
```

- Change your activity launchMode to singleTop and exported true for your Main Activity.

```xml
android:launchMode="singleTop"
android:exported="true"
```

- Add this networkSecurityConfig in `application` tag to use SNA

```xml
android:networkSecurityConfig="@xml/otpless_network_security_config"
```

`iOS`

- Copy-paste the following code into your info.plist file.

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
    <key>CFBundleURLSchemes</key>
    <array>
    <string>otpless.YOUR_APP_ID_IN_LOWERCASE</string>
    </array>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>otpless</string>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
    <string>otpless</string>
    <string>gootpless</string>
    <string>com.otpless.ios.app.otpless</string>
    <string>googlegmail</string>
</array>
```

- Add the following code into your respective AppDelegate files..

```swift
import OtplessSDK

//add this inside of class
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if Otpless.sharedInstance.isOtplessDeeplink(url: url){ Otpless.sharedInstance.processOtplessDeeplink(url: url)
     return true
    }
    super.application(app, open: url, options: options)
    return true
  }
```

1. **Handle Callback**

- Import the following classes.

```xml
import com.otpless.otplessflutter.OtplessFlutterPlugin;
import android.content.Intent;
```

- Add this code to your onNewIntent() method in your main activity.

```kotlin
override fun onNewIntent(intent: Intent) {
super.onNewIntent(intent)
val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
if (plugin is OtplessFlutterPlugin) {
	plugin.onNewIntent(intent)
	}
}
```

4. **Handle Backpress**

- Add this code to your onBackPressed() method in your main activity.

```kotlin
override fun onBackPressed() {
val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
if (plugin is OtplessFlutterPlugin) {
if (plugin.onBackPressed()) return
}
// handle other cases
super.onBackPressed()
}
```

5. **Configure Sign up/Sign in**

- Import the OTPLESS package on your page.

```dart
import 'package:otpless_flutter/otpless_flutter.dart';
```

- Add this code to handle callback from OTPLESS SDK.

```dart
   String? dataResponse = 'Unknown';
  final _otplessFlutterPlugin = Otpless();
  var loaderVisibility = true;
  final TextEditingController phoneNumberContoller = TextEditingController();
  final TextEditingController otpContoller = TextEditingController();
  final TextEditingController emailContoller = TextEditingController();
  String? token;
  String phoneOrEmail = '';
  String otp = '';
  bool isWhatsAppInstalled = true;
  bool? isTrueCallerInstalled = true;
  final String result = 'Unknown';
  String signature = "";
  final phoneNumberHintPlugin = PhoneNumberHint();

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
  }

  void onHeadlessResult(dynamic result) {
    if (result['statusCode'] == 200) {
      switch (result['responseType'] as String) {
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
            setState(() {
              token = result["response"]["token"];
            });
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
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      result = await phoneNumberHintPlugin.requestHint() ?? '';
      phoneNumberContoller.text = result;
    } on PlatformException {
      result = 'Failed to get hint.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      result = result ?? '';
    });
  }

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': "ALP5OU9SMLB3NSPYGNSG"};
    _otplessFlutterPlugin.openLoginPage((result) {
      String? message;
      if (result['data'] != null) {
        setState(() {
          token = result["response"]["token"];
        });

        message = "token: $token";
      }
      setState(() {
        dataResponse = message ?? "Unknown";
      });
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

    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> changeLoaderVisibility() async {
    loaderVisibility = !loaderVisibility;
    _otplessFlutterPlugin.setLoaderVisibility(loaderVisibility);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumberContoller.dispose();
    otpContoller.dispose();
    emailContoller.dispose();
    super.dispose();
  }

```

# Thank You

# [Visit OTPless](https://otpless.com/platforms/flutter)
