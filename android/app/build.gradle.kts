import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // FCM(プッシュ通知)用。google-services.jsonの内容をビルドに反映する
    id("com.google.gms.google-services")
}

// android/key.properties(Git管理対象外)が無ければnull。ストア提出用の本番署名鍵を
// 用意したら、android/key.properties.example を参考にkey.propertiesを作成すること。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}
val hasReleaseKeystore = keystorePropertiesFile.exists()

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

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // key.properties未作成の間はデバッグ鍵で署名する(配布テスト用途等)。
                // ストアに提出するビルドを作る前に、必ずkey.propertiesを用意すること。
                signingConfig = signingConfigs.getByName("debug")
                logger.warn(
                    "WARNING: android/key.properties が無いため、release ビルドはデバッグ鍵で" +
                        "署名されています。ストア提出用のビルドには使えません。",
                )
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
