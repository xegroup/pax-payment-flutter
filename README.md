# XePOS PAX Payment (Flutter)

Flutter POS payment app for **PAX A-series** terminals with **EVO Pay ISO** (Teya) card processing. Supports sale, tip, cash, split bill, refunds, and local transaction history.

## Architecture

- **Flutter UI** — checkout, Teya-style tip/payment flow, transactions, settings
- **Android native** — `MainActivity` launches EVO via intent; parses result extras (transaction ID, decline codes)
- **Local storage** — `SharedPreferences` for settings; `flutter_secure_storage` for password and manager PIN
- **Transaction ledger** — persisted JSON in SharedPreferences (`DummyPaymentsData`)

```
Checkout → (optional) Tip → Payment method → EVO / Cash → Success or Decline
```

## Prerequisites

- PAX Android terminal (A-series)
- **EVO Pay ISO** installed (`com.evopayments.payiso`)
- Teya merchant account and terminal credentials (TID/MID as applicable)
- Flutter SDK 3.10+ and Android SDK for release builds

## First-time setup

1. Install and open the app.
2. On first launch you will see **First-time setup** (no default credentials).
3. Set **username**, **password**, and **manager PIN** (minimum 4 digits).
4. Log in on subsequent launches.

Manager PIN is required for refunds, resetting transactions, and changing payment settings.

## Release APK build

```bash
flutter pub get
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Release keystore

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` (path to your `.jks` or `.keystore`).
3. `key.properties` is gitignored — never commit secrets.

If `key.properties` is missing, release builds fall back to the debug keystore (development only).

## Sideload onto PAX terminal

1. Enable **Install unknown apps** / USB debugging as required on the device.
2. Copy `app-release.apk` to the terminal (USB, ADB, or PAX deployment tool).
3. Install: `adb install -r app-release.apk`
4. Ensure **EVO Pay ISO** is installed and configured for the merchant.

## QA checklist (before merchant handover)

- [ ] First-time setup completes; login works after restart
- [ ] Card sale: amount → tip (if enabled) → card → EVO → success
- [ ] Decline shows mapped reason (e.g. insufficient funds)
- [ ] Cash sale (if enabled) records and prints preview
- [ ] Split bill: equal/custom splits each complete EVO flow
- [ ] Refund void requires manager PIN; original txn shows **Refunded**
- [ ] Transaction search by ref, last 4, amount
- [ ] Payment settings: tips/cash/auto-print persist
- [ ] Device settings: Wi‑Fi opens; printer test shows preview
- [ ] Portrait lock; app works offline (no font CDN required once DM Sans bundled)
- [ ] Release APK signed with production keystore

## Known limitations & TODOs

- **PAX printing** — receipt preview / stub channel; integrate PAX PrinterManager SDK for hardware print
- **EVO transaction ID** — confirm exact extra key with Teya technical docs before production (`MainActivity.kt`)
- **EVO refund reference** — ensure `originalTransactionId` matches gateway expectation
- **DM Sans fonts** — add TTF files under `assets/fonts/` (see `assets/fonts/README.md`)
- **Backend** — transaction list is device-local; no cloud sync in this build
- **iOS** — card/EVO flow is Android-only

## Application ID

`com.xepos.pax.payment`

## License

Proprietary — XePOS / merchant deployment use.
