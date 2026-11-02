package com.xepos.pax.payment

import android.app.ActivityManager
import android.app.AlarmManager
import android.app.PendingIntent
import android.app.role.RoleManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager

/**
 * Opens Xe Pay after the terminal finishes booting.
 *
 * PayDroid often sends its own boot broadcast in addition to the standard one,
 * and Android 10+ blocks a background receiver from opening an activity unless
 * the app holds a background-start permission or is showing an overlay.
 */
class Autostart : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != ACTION_RETRY && action !in BOOT_ACTIONS) return

        val appContext = context.applicationContext
        val state = "${permissionState(appContext)} home=${isDefaultHome(appContext)}"
        Log.i(TAG, "received $action $state")
        DeviceLogFile.append(
            appContext,
            "[AUTOSTART] action=$action\n$state",
        )

        val pending = goAsync()
        if (action == ACTION_RETRY) {
            try {
                if (!isInForeground(appContext)) {
                    launch(appContext)
                }
            } finally {
                pending.finish()
            }
            return
        }

        launch(appContext)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                if (!isInForeground(appContext)) {
                    launch(appContext)
                }
                scheduleRetry(appContext)
            } finally {
                pending.finish()
            }
        }, HOME_READY_DELAY_MS)
    }

    companion object {
        private const val TAG = "XePOS/Autostart"
        const val ACTION_RETRY = "com.xepos.pax.payment.action.AUTOSTART_RETRY"
        private const val HOME_READY_DELAY_MS = 4_000L
        private const val ALARM_RETRY_DELAY_MS = 15_000L

        private val BOOT_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "paydroid.intent.action.BOOT_COMPLETED",
            "com.paxdroid.intent.action.BOOT_COMPLETED",
        )

        fun launch(context: Context) {
            val appContext = context.applicationContext
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                Settings.canDrawOverlays(appContext)
            ) {
                launchBehindOverlay(appContext)
            } else {
                startMain(appContext)
            }
        }

        private fun startMain(context: Context) {
            try {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(launchIntent)
                Log.i(TAG, "startActivity issued")
                DeviceLogFile.append(context, "[AUTOSTART] startActivity issued")
            } catch (e: Exception) {
                Log.e(TAG, "startActivity failed", e)
                DeviceLogFile.append(context, "[AUTOSTART] startActivity failed: ${e.message}")
            }
        }

        /**
         * Android 15 only allows a background activity start while this app has a
         * visible overlay. The window is removed once the activity has been opened.
         */
        private fun launchBehindOverlay(context: Context) {
            val wm = context.getSystemService(WindowManager::class.java)
            if (wm == null) {
                startMain(context)
                return
            }
            val view = View(context)
            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }
            val params = WindowManager.LayoutParams(
                1,
                1,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
            }
            try {
                wm.addView(view, params)
            } catch (e: Exception) {
                Log.w(TAG, "overlay unavailable", e)
                startMain(context)
                return
            }
            view.post {
                startMain(context)
                view.postDelayed({
                    try {
                        wm.removeView(view)
                    } catch (_: Exception) {
                    }
                }, 1_500L)
            }
        }

        private fun scheduleRetry(context: Context) {
            try {
                val alarm = context.getSystemService(AlarmManager::class.java) ?: return
                val retry = Intent(context, Autostart::class.java).setAction(ACTION_RETRY)
                val pending = PendingIntent.getBroadcast(
                    context,
                    0,
                    retry,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                alarm.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    SystemClock.elapsedRealtime() + ALARM_RETRY_DELAY_MS,
                    pending,
                )
            } catch (e: Exception) {
                Log.w(TAG, "retry alarm failed", e)
            }
        }

        private fun isInForeground(context: Context): Boolean {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val mine = am.runningAppProcesses?.firstOrNull {
                it.processName == context.packageName
            }
            return mine?.importance ==
                ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
        }

        private fun isDefaultHome(context: Context): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val roles = context.getSystemService(RoleManager::class.java)
                if (roles != null &&
                    roles.isRoleAvailable(RoleManager.ROLE_HOME) &&
                    roles.isRoleHeld(RoleManager.ROLE_HOME)
                ) {
                    return true
                }
            }
            val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val resolved = context.packageManager.resolveActivity(
                home,
                PackageManager.MATCH_DEFAULT_ONLY,
            )
            return resolved?.activityInfo?.packageName == context.packageName
        }

        private fun permissionState(context: Context): String {
            val pax = context.checkSelfPermission(
                "com.pax.permission.PAX_START_ACTIVITIES_FROM_BACKGROUND",
            ) == PackageManager.PERMISSION_GRANTED
            val platform = context.checkSelfPermission(
                "android.permission.START_ACTIVITIES_FROM_BACKGROUND",
            ) == PackageManager.PERMISSION_GRANTED
            val overlay = Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                Settings.canDrawOverlays(context)
            return "paxBackgroundStart=$pax platformBackgroundStart=$platform overlay=$overlay"
        }
    }
}
