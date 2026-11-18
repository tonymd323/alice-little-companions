import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val familySigningFile = rootProject.file("key.properties")
val familySigning = Properties().apply {
    if (familySigningFile.isFile) familySigningFile.inputStream().use { stream -> load(stream) }
}

android {
    namespace = "local.family.alice_companions"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "local.family.alice_companions"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (familySigningFile.isFile) {
        signingConfigs.create("family") {
            storeFile = rootProject.file(familySigning.getProperty("storeFile"))
            storePassword = familySigning.getProperty("storePassword")
            keyAlias = familySigning.getProperty("keyAlias")
            keyPassword = familySigning.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            // A local family key is used when configured. Cloud builds use the development key.
            signingConfig = signingConfigs.getByName(if (familySigningFile.isFile) "family" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
