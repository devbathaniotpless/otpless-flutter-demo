package com.flutter.app

import io.flutter.embedding.android.FlutterActivity
import com.otpless.otplessflutter.OtplessFlutterPlugin;

class MainActivity: FlutterActivity(){
    
    override fun onBackPressed() {
        val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
        if (plugin is OtplessFlutterPlugin) {
        if (plugin.onBackPressed()) return
        }
        // handle other cases
        super.onBackPressed()
    }
}
