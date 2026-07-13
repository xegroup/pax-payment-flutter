package com.xepos.pax.payment

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.util.Log
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
    private val evoActionRefundTransaction = "com.evopayments.payiso.REFUND_TRANSACTION"

    private var pendingResult: MethodChannel.Result? = null
    private var pendingOperation: String = "sale"

    private lateinit var evoActivityLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        evoActivityLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            onEvoActivityResult(result.resultCode, result.data)
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
                                null
                            )
                            return@setMethodCallHandler
                        }

                        if (pendingResult != null) {
                            result.error(
                                "PAYMENT_IN_PROGRESS",
                                "Another payment is already in progress.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        pendingResult = result
                        pendingOperation = "sale"
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
                                null
                            )
                            return@setMethodCallHandler
                        }

                        if (originalTransactionId.isBlank()) {
                            result.error(
                                "INVALID_ORIGINAL_TRANSACTION",
                                "Original transaction ID is required for refund.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        if (pendingResult != null) {
                            result.error(
                                "PAYMENT_IN_PROGRESS",
                                "Another payment is already in progress.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        pendingResult = result
                        pendingOperation = "refund"
                        startEvoRefund(amount, title, originalTransactionId)
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
                                null
                            )
                        }
                    }

                    "printText" -> {
                        // TODO: Replace with PAX PrinterManager SDK call — see PAX PAXSTORE SDK docs
                        val text = call.argument<String>("text") ?: ""
                        if (BuildConfig.DEBUG) {
                            android.util.Log.d("PaxPayment", "Print stub: ${text.take(120)}")
                        }
                        result.success(null)
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

        try {
            evoActivityLauncher.launch(intent)
        } catch (e: ActivityNotFoundException) {
            pendingResult?.error(
                "EVO_APP_MISSING",
                "EVO Payments app is not installed.",
                null
            )
            pendingResult = null
        } catch (e: Exception) {
            pendingResult?.error(
                "EVO_LAUNCH_ERROR",
                e.message ?: "Failed to launch EVO Payments app.",
                null
            )
            pendingResult = null
        }
    }

    private fun startEvoRefund(amount: Int, title: String, originalTransactionId: String) {
        val intent = Intent().apply {
            setClassName(evoPackageName, evoClassName)
            action = evoActionRefundTransaction
            putExtra("type", "2")
            putExtra("amount", amount.toString())
            putExtra("title", title)
            putExtra("originalTransactionId", originalTransactionId)
        }

        try {
            evoActivityLauncher.launch(intent)
        } catch (e: ActivityNotFoundException) {
            pendingResult?.error(
                "EVO_APP_MISSING",
                "EVO Payments app is not installed.",
                null
            )
            pendingResult = null
        } catch (e: Exception) {
            pendingResult?.error(
                "EVO_LAUNCH_ERROR",
                e.message ?: "Failed to launch EVO Payments app.",
                null
            )
            pendingResult = null
        }
    }

    private fun onEvoActivityResult(resultCode: Int, data: Intent?) {
        if (pendingResult == null) {
            return
        }

        val channelResult = pendingResult
        pendingResult = null
        val operation = pendingOperation
        pendingOperation = "sale"

        if (BuildConfig.DEBUG && data != null) {
            logEvoResultExtras(resultCode, operation, data)
        }

        if (resultCode == Activity.RESULT_OK) {
            val evoResultCode = data?.getStringExtra("result").orEmpty()
            val status = mapEvoResultToStatus(evoResultCode)
            val transactionAmount = data?.getStringExtra("transactionAmount")
                ?: data?.getStringExtra("amount")
                ?: ""
            val maskedCardNumber = data?.getStringExtra("maskedCardNumber")
                ?: data?.getStringExtra("cardNumber")
                ?: ""
            val date = data?.getStringExtra("date").orEmpty()

            // TODO: Confirm exact EVO extra key with Teya technical docs before production.
            val transactionId = extractTransactionIdFromIntent(data)
            val declineReason = if (status == "failed") {
                parseDeclineReason(evoResultCode, data)
            } else {
                ""
            }

            val payload = mutableMapOf<String, Any?>(
                "operation" to operation,
                "status" to status,
                "amount" to transactionAmount,
                "cardNumber" to maskedCardNumber,
                "date" to date
            )
            if (!transactionId.isNullOrBlank()) {
                payload["transactionId"] = transactionId
            }
            if (declineReason.isNotEmpty()) {
                payload["declineReason"] = declineReason
            }

            channelResult?.success(payload)
            return
        }

        val errorCode = if (resultCode == Activity.RESULT_CANCELED) {
            "PAYMENT_CANCELLED"
        } else {
            "PAYMENT_FAILED"
        }
        val errorMessage = data?.getStringExtra("result")
            ?: parseDeclineReason(data?.getStringExtra("result").orEmpty(), data)
            ?: "Payment was not successful (resultCode=$resultCode)."

        channelResult?.error(
            errorCode,
            errorMessage,
            mapOf(
                "resultCode" to resultCode,
                "operation" to operation
            )
        )
    }

    /**
     * Best-effort extraction of gateway / terminal transaction reference from EVO result extras.
     * TODO: Confirm exact EVO extra key with Teya technical docs before production.
     */
    private fun extractTransactionIdFromIntent(data: Intent?): String? {
        if (data == null) return null
        val candidateKeys = listOf(
            "TRANSACTION_ID",
            "transactionId",
            "transaction_id",
            "TXN_ID",
            "txnId",
            "APPROVAL_CODE",
            "approvalCode",
            "reference",
            "REFERENCE",
            "authCode",
            "AUTH_CODE",
            "stan",
            "STAN",
            "rrn",
            "RRN",
            "invoiceNumber",
            "INVOICE_NUMBER"
        )
        for (key in candidateKeys) {
            val v = data.getStringExtra(key)?.trim().orEmpty()
            if (v.isNotEmpty()) {
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "EVO transaction id found in extra key: $key")
                }
                return v
            }
        }
        return null
    }

    private fun parseDeclineReason(evoResultCode: String, data: Intent?): String {
        val fromExtra = data?.getStringExtra("declineReason")
            ?: data?.getStringExtra("message")
            ?: data?.getStringExtra("errorMessage")
        if (!fromExtra.isNullOrBlank()) {
            return fromExtra.trim()
        }

        return when (evoResultCode.trim()) {
            "51" -> "Insufficient funds"
            "54" -> "Card expired"
            "57" -> "Transaction not permitted"
            "61" -> "Withdrawal limit exceeded"
            "91" -> "Bank unavailable, try again"
            "05" -> "Do not honour"
            "1", "2" -> "Payment could not be processed"
            else -> "Payment could not be processed"
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

    /** Logs all EVO result extras — filter Logcat with `XePOS/MainActivity`. */
    private fun logEvoResultExtras(resultCode: Int, operation: String, data: Intent) {
        val extras = data.extras ?: return
        Log.w(
            TAG,
            "EVO result activityResult=$resultCode operation=$operation " +
                "result=${data.getStringExtra("result")} extras=${extras.keySet().joinToString()}"
        )
        for (key in extras.keySet()) {
            Log.d(TAG, "EVO extra $key = ${extras.get(key)}")
        }
    }

    companion object {
        private const val TAG = "XePOS/MainActivity"
    }
}
