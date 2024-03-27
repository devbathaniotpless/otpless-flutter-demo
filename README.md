# Flutter

Integrating One Tap OTPLESS Sign In into your Flutter Application using our SDK is a streamlined process. This guide offers a comprehensive walkthrough, detailing the steps to install the SDK and seamlessly retrieve user information.

1. Install **OTPless SDK** Dependency

```
flutter pub add otpless_flutter:2.1.0
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
	android:scheme= "${applicationId}.otpless"/>
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
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).otpless</string>
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
final _otplessFlutterPlugin = Otpless();
var extra = {
	"method": "get",
	"params": {
	"cid": "HRIRBIIKXMKEOTDDA8VV4HP2V24454X8",
  "appId":
          "ALP5OU9SMLB3NSPYGNSG" //Replace the appId value with your appId value which is provided in the docs
	}
};
 // This code will be used to detect the whatsapp installed status in users device
 // If you are using WHATSAPP login then its reqiured to add this code to hide the OTPless functionality
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
        }
      },
    );
  }

  //This function is used to trigger OTPless login page
  Future<void> startOtpless() async {
    await _otplessFlutterPlugin.hideFabButton();
    _otplessFlutterPlugin.openLoginPage((result) {
      if (result['data'] != null) {
        // todo send this token to your backend service to validate otplessUser details received in the callback with OTPless backend service
        token = result['data']['token'];
        setState(() {});
      }
    }, jsonObject: extra);
  }
```

[Check out startOtpless()](https://github.com/devbathaniotpless/otpless-flutter-demo/blob/main/lib/login_screen.dart#L53)

**Demo**
[Demo Video](demo_video.mp4)

# Thank You

# [Visit OTPless](https://otpless.com/platforms/flutter)
