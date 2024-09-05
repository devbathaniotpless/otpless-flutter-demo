# Flutter

Integrating One Tap OTPLESS Sign In into your Flutter Application using our SDK is a streamlined process. This guide offers a comprehensive walkthrough, detailing the steps to install the SDK and seamlessly retrieve user information.

1. Install the Following Dependency in **pubspec.yaml**

```
  http: ^1.2.2
  app_links: ^6.3.1
  url_launcher: ^6.3.0
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
	android:host="your_host"
	android:scheme= "your_scheme"/>
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
    <string>your_scheme</string>
    </array>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>your_domain</string>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
    <string>googlegmail</string>
</array>
```

1. **Configure Sign up/Sign in**


```dart
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
    final sub = appLinks.uriLinkStream.listen((uri) {
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

```

# Thank You

# [Visit OTPless](https://otpless.com/platforms/flutter)
