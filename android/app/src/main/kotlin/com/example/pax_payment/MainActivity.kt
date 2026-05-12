package com.example.pax_payment

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
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

            // TODO(EVO): Confirm the exact Intent extra key(s) for transaction / STAN / RRN with EVO Pay ISO docs.
            val transactionId = extractTransactionIdFromIntent(data)

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

            channelResult?.success(payload)
            return
        }

        val errorCode = if (resultCode == Activity.RESULT_CANCELED) {
            "PAYMENT_CANCELLED"
        } else {
            "PAYMENT_FAILED"
        }
        val errorMessage = data?.getStringExtra("result")
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
     * Best-effort extraction of a gateway / terminal transaction reference from EVO result extras.
     * TODO(EVO): Replace guessed keys with the official extra names from EVO integration documentation.
     */
    private fun extractTransactionIdFromIntent(data: Intent?): String? {
        if (data == null) return null
        val candidateKeys = listOf(
            "transactionId",
            "transaction_id",
            "TRANSACTION_ID",
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
            if (v.isNotEmpty()) return v
        }
        return null
    }

    private fun mapEvoResultToStatus(result: String): String {
        return when (result) {
            "0" -> "success"
            "7" -> "cancelled"
            "1", "2" -> "failed"
            else -> "failed"
        }
    }
}
