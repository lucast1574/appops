package com.leasy.ops.leasy_ops_mobile

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.leasy.ops/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "openLocationPermission") {
                    openLocationPermissionPage()
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Opens the app's **location permission** settings page as directly as
     * possible. Tries several strategies in order of specificity:
     *
     * 1. MANAGE_APP_PERMISSION with PERMISSION_GROUP_NAME = LOCATION
     *    → opens the exact "Permitir todo el tiempo" radio-button page.
     * 2. MANAGE_APP_PERMISSIONS (plural) with PACKAGE_NAME
     *    → opens the app's permission list (user taps "Ubicación").
     * 3. ACTION_APPLICATION_DETAILS_SETTINGS
     *    → opens the app-info page (user taps "Permisos" → "Ubicación").
     */
    private fun openLocationPermissionPage() {
        // ------- Attempt 1: direct location-permission radio page -------
        if (tryStart {
                Intent("android.intent.action.MANAGE_APP_PERMISSION").apply {
                    putExtra("android.intent.extra.PACKAGE_NAME", packageName)
                    putExtra(
                        "android.intent.extra.PERMISSION_GROUP_NAME",
                        "android.permission-group.LOCATION"
                    )
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        putExtra(
                            "android.intent.extra.PERMISSION_NAME",
                            "android.permission.ACCESS_FINE_LOCATION"
                        )
                    }
                }
            }) return

        // ------- Attempt 2: app permissions list -------
        if (tryStart {
                Intent("android.intent.action.MANAGE_APP_PERMISSIONS").apply {
                    putExtra("android.intent.extra.PACKAGE_NAME", packageName)
                }
            }) return

        // ------- Attempt 3: general app-info page (always works) -------
        tryStart {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
            }
        }
    }

    /** Attempts to start an activity; returns true on success, false on failure. */
    private fun tryStart(intentBuilder: () -> Intent): Boolean {
        return try {
            val intent = intentBuilder()
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
