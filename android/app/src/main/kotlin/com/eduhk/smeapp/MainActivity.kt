package com.eduhk.smeapp

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugins.GeneratedPluginRegistrant;
class MainActivity : FlutterActivity() { //  @Override
    //  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    //    GeneratedPluginRegistrant.registerWith(flutterEngine);
    //  }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Notifications.createNotificationChannels(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(binaryMessenger, "com.eduhk.smeapp/background_service").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "startService") {
                    val callbackRawHandle = method.arguments as Long
                    //BackgroundService.startService(this@MainActivity, callbackRawHandle)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }
    }
}