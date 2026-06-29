plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read version from pubspec.yaml so Android Studio builds stay in sync.
// flutter.versionCode in local.properties is only refreshed by `flutter run` / `flutter build`.
val pubspecVersion =
    run {
        val pubspec = rootProject.layout.projectDirectory.file("../pubspec.yaml").asFile
        val match =
            Regex("""^version:\s*(\S+)""", RegexOption.MULTILINE)
                .find(pubspec.readText())
                ?: throw GradleException("Could not find version in ${pubspec.path}")
        val parts = match.groupValues[1].split("+")
        parts[0] to (parts.getOrNull(1)?.toIntOrNull() ?: 1)
    }

android {
    namespace = "cz.shadowHub.partnerCheck"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "cz.shadowHub.partnerCheck"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = pubspecVersion.second
        versionName = pubspecVersion.first
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
