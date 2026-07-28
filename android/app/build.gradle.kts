plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kumayokeru.kumayokeru_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notificationsがcore library desugaringを要求するため有効化
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.kumayokeru.app"
        // 仕様書の非機能要件: Android 10 (API 29) 以降を対象とする
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "クマヨケール(dev)")
        }
        create("stg") {
            dimension = "environment"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "クマヨケール(stg)")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "クマヨケール")
        }
    }

    buildTypes {
        release {
            // TODO: リリース用の署名設定を追加する(セクション19 Androidリリースチェックリスト参照)。
            // 現状はデバッグ鍵で署名しているため `flutter build --flavor prod --release` は通るが、ストア提出前に必ず差し替える。
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
