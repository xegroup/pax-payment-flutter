import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

fun releaseKeystoreFile(): java.io.File? {
    if (!keystorePropertiesFile.exists()) return null

    val storeFilePath = keystoreProperties.getProperty("storeFile") ?: return null
    val storeFile = rootProject.file(storeFilePath)
    return storeFile.takeIf { it.exists() }
}

val releaseKeystore = releaseKeystoreFile()
val hasReleaseSigning = releaseKeystore != null

android {
    namespace = "com.xepos.pax.payment"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = "xewaiter"
            keyPassword = "xewaiter"
            storePassword = "xewaiter"
            storeFile = file("D:/progress/XEWaiter.keystore")
        }
    }


    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.xepos.pax.payment"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }



    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
