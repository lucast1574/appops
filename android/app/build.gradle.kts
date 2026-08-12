plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase / Google Services plugin (reads google-services.json from this folder)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.leasy.ops.leasy_ops_mobile"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications to support older Android versions.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.leasy.ops.leasy_ops_mobile"
        
        // Es mejor poner 21 directamente para asegurar que el ZTE no se queje
        minSdk = flutter.minSdkVersion 
        targetSdk = 36
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Esto garantiza que el APK siempre lleve los "motores" para 32 y 64 bits
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    signingConfigs {
        create("release") {
            storeFile = file(System.getProperty("user.home") + "/.android/release-keystore.jks")
            storePassword = "157400"
            keyAlias = "release"
            keyPassword = "157400"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
