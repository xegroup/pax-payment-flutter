package com.xepos.pax.payment

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "evo_payment_channel"
    private val deviceChannelName = "pax_device_channel"
    private val evoPackageName = "com.evopayments.payiso"
    private val evoClassName = "com.evopayments.payiso.MainActivity"
    private val evoActionPerformTransaction = "com.evopayments.payiso.PERFORM_TRANSACTION"
//    private val evoActionRefundTransaction = "com.evopayments.payiso.REFUND_TRANSACTION"

    private var pendingResult: MethodChannel.Result? = null
    private var pendingOperation: String = "sale"
    private var pendingAmountCents: Int = 0
    private var pendingOriginalTransactionId: String = ""

    private lateinit var evoActivityLauncher: ActivityResultLauncher<Intent>
    private lateinit var storagePermissionLauncher: ActivityResultLauncher<Array<String>>
    private lateinit var allFilesAccessLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        storagePermissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestMultiplePermissions(),
        ) { granted ->
            if (granted[Manifest.permission.WRITE_EXTERNAL_STORAGE] == true ||
                DeviceLogFile.canWriteSharedStorage(this)
            ) {
                createDeviceLog()
            }
        }
        allFilesAccessLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult(),
        ) {
            if (DeviceLogFile.canWriteSharedStorage(this)) {
                createDeviceLog()
            }
        }
        evoActivityLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            onEvoActivityResult(result.resultCode, result.data)
        }
        createDeviceLog()
        if (!DeviceLogFile.isInDownloads(this)) {
            requestStoragePermission()
        }
    }

    override fun onResume() {
        super.onResume()
        if (!logFileReady && DeviceLogFile.canWriteSharedStorage(this)) {
            createDeviceLog()
        }
    }

    private fun requestStoragePermission() {
        if (storagePromptShown) return
        storagePromptShown = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                allFilesAccessLauncher.launch(
                    Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
                        data = Uri.parse("package:$packageName")
                    },
                )
            } catch (e: Exception) {
                allFilesAccessLauncher.launch(
                    Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION),
                )
            }
            return
        }
        storagePermissionLauncher.launch(
            arrayOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            ),
        )
    }

    private fun createDeviceLog() {
        if (logFileReady && DeviceLogFile.isInDownloads(this)) return
        val note = if (!startupLogged) {
            startupLogged = true
            "Log file created.\nPath: ${DeviceLogFile.sharedLogPath()}"
        } else {
            "Storage permission granted.\nPath: ${DeviceLogFile.sharedLogPath()}"
        }
        DeviceLogFile.append(this, note)
        if (DeviceLogFile.isInDownloads(this)) {
            logFileReady = true
            Toast.makeText(
                this,
                "Payment log saved to Downloads/evo_payment_log.txt",
                Toast.LENGTH_LONG,
            ).show()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startPayment" -> {
                        val amount = call.argument<Int>("amount")
                        val title = call.argument<String>("title").orEmpty()

                        if (amount == null || amount <= 0) {
                            result.error(
                                "INVALID_AMOUNT",
                                "Amount must be greater than zero.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        if (pendingResult != null) {
                            result.error(
                                "PAYMENT_IN_PROGRESS",
                                "Another payment is already in progress.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        pendingResult = result
                        pendingOperation = "sale"
                        pendingAmountCents = amount
                        pendingOriginalTransactionId = ""
                        startEvoPayment(amount, title)
                    }

                    "startRefund" -> {
                        val amount = call.argument<Int>("amount")
                        val title = call.argument<String>("title").orEmpty()
                        val originalTransactionId =
                            call.argument<String>("originalTransactionId").orEmpty()

                        if (amount == null || amount <= 0) {
                            result.error(
                                "INVALID_AMOUNT",
                                "Amount must be greater than zero.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        if (originalTransactionId.isBlank()) {
                            result.error(
                                "INVALID_ORIGINAL_TRANSACTION",
                                "Original transaction ID is required for refund.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        if (pendingResult != null) {
                            result.error(
                                "PAYMENT_IN_PROGRESS",
                                "Another payment is already in progress.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        pendingResult = result
                        pendingOperation = "refund"
                        pendingAmountCents = amount
                        pendingOriginalTransactionId = originalTransactionId
                        val slipNumber = call.argument<Int>("slipNumber") ?: 0
                        startEvoRefund(
                            amount = amount,
                            title = title,
                            refId = originalTransactionId,
                            slipNumber = slipNumber,
                        )
                    }
                    "startSettlement" -> {
                        if (pendingResult != null) {
                            result.error(
                                "PAYMENT_IN_PROGRESS",
                                "Another payment is already in progress.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        pendingResult = result
                        pendingOperation = "settlement"
                        pendingAmountCents = 0
                        pendingOriginalTransactionId = ""
                        val refId = call.argument<String>("referenceId")
                        val reqReportFile = call.argument<Int>("reqReportFile") ?: 0
                        startEvoSettlement(refId, reqReportFile)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openWifiSettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
                            result.success(null)
                        } catch (e: Exception) {
                            result.error(
                                "WIFI_SETTINGS",
                                e.message ?: "Could not open Wi-Fi settings.",
                                null,
                            )
                        }
                    }

                    "printText" -> {
                        val text = call.argument<String>("text") ?: ""
                        if (BuildConfig.DEBUG) {
                            android.util.Log.d("PaxPayment", "Print stub: ${text.take(120)}")
                        }
                        result.success(null)
                    }

                    "appendDeviceLog" -> {
                        val text = call.argument<String>("text").orEmpty()
                        if (text.isNotBlank()) {
                            DeviceLogFile.append(this, text)
                        }
                        result.success(DeviceLogFile.appLogPath(this))
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun startEvoPayment(amount: Int, title: String) {
        val intent = Intent().apply {
            setClassName(evoPackageName, evoClassName)
            action = evoActionPerformTransaction
            putExtra("type", "1")
            putExtra("amount", amount.toString())
            putExtra("title", title)
        }

        launchEvoIntent(intent, "sale")
    }

    private fun startEvoRefund(
        amount: Int,
        title: String,
        refId: String,
        slipNumber: Int,
        blikCode: String = "",
        tipAmount: Long = 0L,
        cashbackAmount: Long = 0L,
    ) {
        val intent = Intent().apply {
            setClassName(evoPackageName, evoClassName)
            action = evoActionPerformTransaction
            putExtra("type", "6")
            putExtra("amount", amount.toString())
            putExtra("title", title)
            putExtra("blikCode", blikCode)
            putExtra("tipAmount", tipAmount)
            putExtra("cashbackAmount", cashbackAmount)
            putExtra("referenceId", refId)
            putExtra("slipNumber", slipNumber)
        }

        launchEvoIntent(intent, "refund")
    }
    private fun startEvoSettlement(
        refId: String?,
        reqReportFile: Int?
    ) {
        val intent = Intent().apply {
            setClassName(evoPackageName, evoClassName)
            action = evoActionPerformTransaction
            putExtra("type", "31")
            putExtra("referenceId", refId)
            putExtra("reqReportFile", reqReportFile)
        }

        launchEvoIntent(intent, "settlement")
    }

    private fun launchEvoIntent(intent: Intent, operation: String) {
        DeviceLogFile.logEvoIntent(
            context = this,
            phase = "REQUEST",
            operation = operation,
            intent = intent,
        )
        try {
            evoActivityLauncher.launch(intent)
        } catch (e: ActivityNotFoundException) {
            DeviceLogFile.logEvoIntent(
                context = this,
                phase = "ERROR",
                operation = operation,
                intent = intent,
                error = "EVO Payments app is not installed.",
            )
            pendingResult?.error(
                "EVO_APP_MISSING",
                "EVO Payments app is not installed.",
                null,
            )
            pendingResult = null
        } catch (e: Exception) {
            val message = e.message ?: "Failed to launch EVO Payments app."
            DeviceLogFile.logEvoIntent(
                context = this,
                phase = "ERROR",
                operation = operation,
                intent = intent,
                error = message,
            )
            pendingResult?.error(
                "EVO_LAUNCH_ERROR",
                message,
                null,
            )
            pendingResult = null
        }
    }

    private fun onEvoActivityResult(resultCode: Int, data: Intent?) {
        if (pendingResult == null) return

        val channelResult = pendingResult
        pendingResult = null
        val operation = pendingOperation
        val amountCents = pendingAmountCents
        val originalTransactionId = pendingOriginalTransactionId
        pendingOperation = "sale"
        pendingAmountCents = 0
        pendingOriginalTransactionId = ""

        DeviceLogFile.logEvoIntent(
            context = this,
            phase = "RESULT",
            operation = operation,
            intent = data,
            resultCode = resultCode,
        )

        val payload = if (data != null) {
            logEvoResultExtras(
                resultCode = resultCode,
                operation = operation,
                data = data,
                amountCents = amountCents,
                originalTransactionId = originalTransactionId,
            )
        } else {
            null
        }

        if (payload != null) {
            channelResult?.success(payload)
            return
        }

        // Rejected transactions may return RESULT_CANCELED but still include EVO extras.
        if (data != null && hasEvoTransactionData(data)) {
            val evoResultCode = readExtraValue(data, "result")
            if (evoResultCode != "7") {
                val rejectedPayload = buildEvoResultPayload(
                    data = data,
                    operation = operation,
                    evoResultCode = evoResultCode,
                    status = "failed",
                )
                rejectedPayload["amountCents"] = amountCents
                if (originalTransactionId.isNotBlank()) {
                    rejectedPayload["originalTransactionId"] = originalTransactionId
                }
                channelResult?.success(rejectedPayload)
                return
            }
        }

        val evoResultCode = readExtraValue(data, "result")
        val errorCode = if (resultCode == Activity.RESULT_CANCELED) {
            "PAYMENT_CANCELLED"
        } else {
            "PAYMENT_FAILED"
        }
        val errorMessage = readExtraValue(data, "serverMessage", "declineReason", "message")
            .ifBlank { parseDeclineReason(evoResultCode, data) }
            .ifBlank { "Payment was not successful (resultCode=$resultCode)." }

        channelResult?.error(
            errorCode,
            errorMessage,
            buildEvoResultPayload(
                data = data,
                operation = operation,
                evoResultCode = evoResultCode,
                status = if (errorCode == "PAYMENT_FAILED") "failed" else "cancelled",
            ).also { payload ->
                payload["amountCents"] = amountCents
                if (originalTransactionId.isNotBlank()) {
                    payload["originalTransactionId"] = originalTransactionId
                }
            },
        )
    }

    /**
     * Logs EVO extras and calls Flutter [saveTransactionFromEvoResult] via method channel.
     */
    private fun logEvoResultExtras(
        resultCode: Int,
        operation: String,
        data: Intent,
        amountCents: Int,
        originalTransactionId: String,
    ): MutableMap<String, Any?>? {
        val extras = data.extras ?: return null
        Log.w(
            TAG,
            "EVO result activityResult=$resultCode operation=$operation " +
                "result=${readExtraValue(data, "result")} extras=${extras.keySet().joinToString()}",
        )
        for (key in extras.keySet()) {
            Log.d(TAG, "EVO extra $key = ${extras.get(key)}")
        }

        val evoResultCode = readExtraValue(data, "result")
        val status = resolveEvoStatus(resultCode, evoResultCode, data)
        if (status == "cancelled") return null

        val payload = buildEvoResultPayload(
            data = data,
            operation = operation,
            evoResultCode = evoResultCode,
            status = status,
        )
        payload["amountCents"] = amountCents
        if (originalTransactionId.isNotBlank()) {
            payload["originalTransactionId"] = originalTransactionId
        }

        return payload
    }

    private fun buildEvoResultPayload(
        data: Intent?,
        operation: String,
        evoResultCode: String,
        status: String,
    ): MutableMap<String, Any?> {
        val maskedCardNumber = readExtraValue(
            data,
            "maskedCardNumber",
            "additional",
            "cardNumber",
        )
        val transactionAmount = readExtraNumber(data, "transactionAmount", "amount")
        val transactionId = extractTransactionIdFromIntent(data)
        val declineReason = if (status == "failed") {
            readExtraValue(data, "serverMessage", "declineReason", "message", "errorMessage")
                .ifBlank { parseDeclineReason(evoResultCode, data) }
        } else {
            ""
        }

        val payload = mutableMapOf<String, Any?>(
            "operation" to operation,
            "status" to status,
            "result" to evoResultCode,
            "amount" to (transactionAmount?.toString() ?: readExtraValue(data, "amount")),
            "transactionAmount" to transactionAmount,
            "cardNumber" to maskedCardNumber,
            "maskedCardNumber" to maskedCardNumber,
            "additional" to readExtraValue(data, "additional"),
            "date" to readExtraValue(data, "date"),
            "time" to readExtraValue(data, "time"),
            "type" to readExtraValue(data, "type"),
            "slipNumber" to readExtraNumber(data, "slipNumber"),
            "terminalId" to readExtraNumber(data, "terminalId"),
            "transactionCurrency" to readExtraValue(data, "transactionCurrency"),
            "authorizationMessage" to readExtraValue(data, "authorizationMessage"),
            "merchantId" to readExtraValue(data, "merchantId"),
            "AC" to readExtraValue(data, "AC"),
            "AID" to readExtraValue(data, "AID"),
            "ATC" to readExtraValue(data, "ATC"),
            "TSI" to readExtraValue(data, "TSI"),
            "TVR" to readExtraValue(data, "TVR"),
            "transactionTitle" to readExtraValue(data, "transactionTitle", "title"),
            "cardSource" to readExtraValue(data, "cardSource"),
            "cardBrandName" to readExtraValue(data, "cardBrandName", "cardType", "cardScheme"),
            "cardsetName" to readExtraValue(data, "cardsetName"),
            "serverMessage" to readExtraValue(data, "serverMessage", "message", "errorMessage"),
            "cardType" to readExtraValue(data, "cardBrandName", "cardsetName", "cardType"),
        )

        if (!transactionId.isNullOrBlank()) {
            payload["transactionId"] = transactionId
        }
        if (declineReason.isNotEmpty()) {
            payload["declineReason"] = declineReason
        }

        data?.extras?.keySet()?.forEach { key ->
            if (!payload.containsKey(key)) {
                payload[key] = data.extras?.get(key)
            }
        }

        return payload
    }

    private fun readExtraValue(data: Intent?, vararg keys: String): String {
        if (data?.extras == null) return ""
        val extras = data.extras!!
        for (key in keys) {
            if (!extras.containsKey(key)) continue
            val value = extras.get(key)?.toString()?.trim().orEmpty()
            if (value.isNotEmpty()) return value
        }
        return ""
    }

    private fun readExtraNumber(data: Intent?, vararg keys: String): Number? {
        if (data?.extras == null) return null
        val extras = data.extras!!
        for (key in keys) {
            if (!extras.containsKey(key)) continue
            when (val value = extras.get(key)) {
                is Number -> return value
                is String -> value.trim().toDoubleOrNull()?.let { return it }
            }
        }
        return null
    }

    private fun extractTransactionIdFromIntent(data: Intent?): String? {
        if (data == null) return null
        val candidateKeys = listOf(
            "TRANSACTION_ID", "transactionId", "transaction_id",
            "TXN_ID", "txnId", "APPROVAL_CODE", "approvalCode",
            "reference", "REFERENCE", "authCode", "AUTH_CODE",
            "stan", "STAN", "rrn", "RRN", "invoiceNumber", "INVOICE_NUMBER",
        )
        for (key in candidateKeys) {
            val v = readExtraValue(data, key)
            if (v.isNotEmpty()) return v
        }
        return null
    }

    private fun parseDeclineReason(evoResultCode: String, data: Intent?): String {
        val fromExtra = readExtraValue(
            data, "serverMessage", "declineReason", "message", "errorMessage",
        )
        if (fromExtra.isNotEmpty()) return fromExtra

        return when (evoResultCode.trim()) {
            "51" -> "Insufficient funds"
            "54" -> "Card expired"
            "57" -> "Transaction not permitted"
            "61" -> "Withdrawal limit exceeded"
            "91" -> "Bank unavailable, try again"
            "05" -> "Do not honour"
            else -> "Payment could not be processed"
        }
    }

    private fun hasEvoTransactionData(data: Intent?): Boolean {
        if (data?.extras == null) return false
        if (readExtraNumber(data, "transactionAmount", "amount") != null) return true
        if (readExtraValue(data, "slipNumber").isNotEmpty()) return true
        if (readExtraValue(data, "serverMessage").isNotEmpty()) return true
        if (readExtraValue(data, "maskedCardNumber", "additional").isNotEmpty()) return true
        val result = readExtraValue(data, "result")
        return result == "0" || result == "1" || result == "2"
    }

    private fun resolveEvoStatus(
        resultCode: Int,
        evoResultCode: String,
        data: Intent? = null,
    ): String {
        if (evoResultCode.isNotEmpty()) {
            return mapEvoResultToStatus(evoResultCode)
        }
        // Declined card with full EVO extras often uses RESULT_CANCELED without result extra.
        if (resultCode == Activity.RESULT_CANCELED && hasEvoTransactionData(data)) {
            return "failed"
        }
        return when (resultCode) {
            Activity.RESULT_OK -> "success"
            Activity.RESULT_CANCELED -> "cancelled"
            else -> "failed"
        }
    }

    private fun mapEvoResultToStatus(result: String): String {
        return when (result) {
            "0" -> "success"
            "7" -> "cancelled"
            "1", "2" -> "failed"
            else -> "failed"
        }
    }

    companion object {
        private const val TAG = "XePOS/MainActivity"
        private var logFileReady = false
        private var startupLogged = false
        private var storagePromptShown = false
    }
}
