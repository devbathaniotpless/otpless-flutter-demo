# Flutter

Integrating One Tap OTPLESS Sign In into your Flutter Application using our SDK is a streamlined process. This guide offers a comprehensive walkthrough, detailing the steps to install the SDK and seamlessly retrieve user information.

1. Install **OTPless SDK** Dependency

```
flutter pub add otpless_flutter:2.1.3
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
	android:scheme= "otpless.{{"YOUR_APP_ID"}}"/>
</intent-filter>
```

- Change your activity launchMode to singleTop and exported true for your Main Activity.

```xml
android:launchMode="singleTop"
android:exported="true"
```

`iOS`

- Copy-paste the following code into your info.plist file.

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
    <key>CFBundleURLSchemes</key>
    <array>
    <string>otpless.{{"YOUR_APP_ID"}}</string>
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

3. **Handle Callback**

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

  @override
  void initState() {
    super.initState();
    _otplessFlutterPlugin.initHeadless("YOUR_APP_ID");
    _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
  }

  void onHeadlessResult(dynamic result) {
    setState(() {
      token = result["response"]["token"];
    });
  }

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': "YOUR_APP_ID"};
    _otplessFlutterPlugin.openLoginPage((result) {
      String? message;
      if (result['data'] != null) {
        final token = result['data']['token'];
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
      arg["phone"] = phoneNumberContoller.text;
      arg["countryCode"] = "91";
      arg["otp"] = otpContoller.text;
    } else {
      if (phoneNumberContoller.text.isNotEmpty) {
        arg["phone"] = phoneNumberContoller.text;
        arg["countryCode"] = "91";
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

[Check out startOtpless()](https://github.com/devbathaniotpless/otpless-flutter-demo/blob/main/lib/login_screen.dart#L53)

**Demo**
[Demo Video](demo_video.mp4)

# Thank You

# [Visit OTPless](https://otpless.com/platforms/flutter)
