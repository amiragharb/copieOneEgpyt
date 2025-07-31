plugins {
    id("com.android.application")
    id("kotlin-android")               // ok
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
   id("com.google.gms.google-services") // <-- AJOUTER

}

android {
    namespace = "com.egycopts.booking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"       // déjà présent : requis par tes plugins

    // ✅ Java 17 + Core Library Desugaring
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.egycopts.booking"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signature à adapter pour un vrai release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // ✅ Ajout pour la desugaring Java 8+/java.time, requis par flutter_local_notifications & co
}
