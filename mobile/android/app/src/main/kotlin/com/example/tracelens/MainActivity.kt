package com.example.tracelens

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var initialSharedText: String? = null
    private var shareEvents: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tracelens/share")
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialText") {
                    result.success(initialSharedText)
                    initialSharedText = null
                } else {
                    result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "tracelens/share_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    shareEvents = events
                }

                override fun onCancel(arguments: Any?) {
                    shareEvents = null
                }
            })
        acceptShare(intent, deliverImmediately = false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        acceptShare(intent, deliverImmediately = true)
    }

    private fun acceptShare(intent: Intent?, deliverImmediately: Boolean) {
        if (intent?.action != Intent.ACTION_SEND) return
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
            ?: intent.getStringExtra(Intent.EXTRA_SUBJECT)?.trim()
            ?: return
        if (text.isEmpty()) return
        if (deliverImmediately && shareEvents != null) {
            shareEvents?.success(text)
        } else {
            initialSharedText = text
        }
    }
}
