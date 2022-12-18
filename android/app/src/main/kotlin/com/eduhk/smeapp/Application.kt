package com.eduhk.smeapp

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
        //registerActivityLifecycleCallbacks(LifecycleDetector.activityLifecycleCallbacks)
    }

    override fun registerWith(registry: PluginRegistry?) {
        //GeneratedPluginRegistrant.registerWith(registry)
        //registry?.registrarFor("com.eduhk.smeapp");
        io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));    }
}