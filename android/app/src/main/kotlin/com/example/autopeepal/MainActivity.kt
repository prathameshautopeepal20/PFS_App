package com.example.atpl_flashing_app

import android.content.Context
import android.net.wifi.WifiManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.InetAddress

class MainActivity: FlutterActivity() {

    private var multicastLock: WifiManager.MulticastLock? = null

    override fun onResume() {
        super.onResume()

        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("mdns_lock")
        multicastLock?.setReferenceCounted(true)
        multicastLock?.acquire()
    }

    override fun onPause() {
        multicastLock?.release()
        super.onPause()
    }
}