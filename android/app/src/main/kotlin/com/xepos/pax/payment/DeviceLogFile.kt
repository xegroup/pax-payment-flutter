package com.xepos.pax.payment

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.media.MediaScannerConnection
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Appends diagnostic lines to `evo_payment_log.txt`.
 *
 * Public copy: Download/evo_payment_log.txt
 */
object DeviceLogFile {
    private const val TAG = "XePOS/DeviceLog"
    private const val FILE_NAME = "evo_payment_log.txt"
    private const val MAX_BYTES = 5L * 1024L * 1024L
    private val lock = Any()
    private val timeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US)
    private val panPattern = Regex("\\b\\d{13,19}\\b")

    fun append(context: Context, body: String) {
        val entry = buildString {
            append('\n')
            append("========== ")
            append(timeFormat.format(Date()))
            append(" ==========\n")
            append(body.trimEnd())
            append('\n')
        }
        val appContext = context.applicationContext
        synchronized(lock) {
            val source = writeAppFile(appContext, entry)
            if (source != null) {
                publishToDownloads(appContext, source)
            }
        }
    }

    fun canWriteSharedStorage(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            context.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                PackageManager.PERMISSION_GRANTED
        }
    }

    /** Public path: Internal storage / Download / evo_payment_log.txt */
    fun sharedLogPath(): String = downloadLogFile().absolutePath

    fun isInDownloads(context: Context): Boolean {
        val file = downloadLogFile()
        if (file.exists() && file.length() > 0L) return true
        return findPublicLog(context) != null
    }

    fun logEvoIntent(
        context: Context,
        phase: String,
        operation: String,
        intent: Intent?,
        resultCode: Int? = null,
        error: String? = null,
    ) {
        val text = buildString {
            append("[EVO INTENT ").append(phase).append("] operation=").append(operation).append('\n')
            if (resultCode != null) {
                append("activityResult=").append(resultCodeName(resultCode))
                append(" (").append(resultCode).append(")\n")
            }
            if (!error.isNullOrBlank()) {
                append("error=").append(error).append('\n')
            }
            if (intent != null) {
                append("action=").append(intent.action ?: "").append('\n')
                append("component=").append(intent.component?.flattenToString() ?: "").append('\n')
                append("extras:\n")
                append(formatExtras(intent.extras))
            } else {
                append("extras:\n  (none)")
            }
        }
        append(context, text)
    }

    fun appLogPath(context: Context): String {
        return appLogFile(context).absolutePath
    }

    private fun writeAppFile(context: Context, entry: String): File? {
        return try {
            val file = appLogFile(context)
            file.parentFile?.mkdirs()
            if (!file.exists()) {
                file.writeText(
                    "Xe Pay device log\n" +
                        "Contains API request/response and EVO payment intents.\n" +
                        "Downloads: ${downloadLogFile().absolutePath}\n",
                )
            }
            rotateIfNeeded(file)
            file.appendText(entry)
            file
        } catch (e: Exception) {
            Log.w(TAG, "App log write failed: ${e.message}")
            null
        }
    }

    private fun appLogFile(context: Context): File {
        val dir = context.getExternalFilesDir("logs") ?: File(context.filesDir, "logs")
        return File(dir, FILE_NAME)
    }

    @Suppress("DEPRECATION")
    private fun downloadLogFile(): File {
        return File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            FILE_NAME,
        )
    }

    private fun publishToDownloads(context: Context, source: File) {
        val viaMediaStore = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            publishWithMediaStore(context, source)
        } else {
            false
        }
        val viaFile = publishWithPublicFile(context, source)
        if (viaMediaStore || viaFile) {
            Log.i(TAG, "Saved log to Downloads/$FILE_NAME")
        }
    }

    private fun publishWithMediaStore(context: Context, source: File): Boolean {
        return try {
            val resolver = context.contentResolver
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/"
            var uri = findPublicLog(context)
            if (uri == null) {
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, FILE_NAME)
                    put(MediaStore.Downloads.MIME_TYPE, "text/plain")
                    put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
                uri = resolver.insert(collection, values)
            } else {
                val pending = ContentValues().apply {
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
                resolver.update(uri, pending, null, null)
            }
            val target = uri ?: return false
            val wrote = resolver.openOutputStream(target, "wt")?.use { output ->
                source.inputStream().use { input -> input.copyTo(output) }
                true
            } ?: false
            val done = ContentValues().apply {
                put(MediaStore.Downloads.IS_PENDING, 0)
            }
            resolver.update(target, done, null, null)
            wrote
        } catch (e: Exception) {
            Log.w(TAG, "Downloads MediaStore write failed: ${e.message}")
            false
        }
    }

    private fun publishWithPublicFile(context: Context, source: File): Boolean {
        return try {
            val file = downloadLogFile()
            val dir = file.parentFile
            if (dir != null && !dir.exists() && !dir.mkdirs()) {
                return false
            }
            source.copyTo(file, overwrite = true)
            MediaScannerConnection.scanFile(
                context,
                arrayOf(file.absolutePath),
                arrayOf("text/plain"),
                null,
            )
            true
        } catch (e: Exception) {
            Log.w(TAG, "Downloads file write failed: ${e.message}")
            false
        }
    }

    private fun rotateIfNeeded(file: File) {
        if (!file.exists() || file.length() < MAX_BYTES) return
        val backup = File(file.parentFile, "evo_payment_log_old.txt")
        if (backup.exists()) backup.delete()
        file.renameTo(backup)
    }

    private fun findPublicLog(context: Context): android.net.Uri? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Downloads._ID,
            MediaStore.Downloads.RELATIVE_PATH,
        )
        val selection = "${MediaStore.Downloads.DISPLAY_NAME}=?"
        context.contentResolver.query(
            collection,
            projection,
            selection,
            arrayOf(FILE_NAME),
            null,
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(MediaStore.Downloads._ID)
            val pathIndex = cursor.getColumnIndexOrThrow(MediaStore.Downloads.RELATIVE_PATH)
            val downloads = Environment.DIRECTORY_DOWNLOADS
            while (cursor.moveToNext()) {
                val path = cursor.getString(pathIndex).orEmpty().trimEnd('/')
                if (path == downloads || path.isEmpty()) {
                    return ContentUris.withAppendedId(collection, cursor.getLong(idIndex))
                }
            }
        }
        return null
    }

    private fun formatExtras(extras: Bundle?): String {
        if (extras == null || extras.isEmpty) return "  (none)"
        return extras.keySet().sorted().joinToString("\n") { key ->
            "  $key = ${redact(key, extras.get(key))}"
        }
    }

    private fun redact(key: String, value: Any?): String {
        val normalized = key.lowercase(Locale.US)
        if (
            normalized.contains("password") ||
            normalized.contains("pin") ||
            normalized.contains("token") ||
            normalized.contains("secret") ||
            normalized.contains("authorization") ||
            normalized.contains("cvv") ||
            normalized.contains("cvc") ||
            normalized.contains("track")
        ) {
            return "***"
        }
        return maskPan(value?.toString() ?: "null")
    }

    private fun maskPan(raw: String): String {
        return panPattern.replace(raw) { match ->
            val digits = match.value
            "*".repeat(digits.length - 4) + digits.takeLast(4)
        }
    }

    private fun resultCodeName(code: Int): String {
        return when (code) {
            android.app.Activity.RESULT_OK -> "RESULT_OK"
            android.app.Activity.RESULT_CANCELED -> "RESULT_CANCELED"
            else -> "RESULT_$code"
        }
    }
}
