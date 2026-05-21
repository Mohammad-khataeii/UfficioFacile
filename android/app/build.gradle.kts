import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use(keyProperties::load)
}

fun loadDartDefines(): Map<String, String> {
    val encoded = project.findProperty("dart-defines") as String? ?: return emptyMap()
    return encoded
        .split(",")
        .mapNotNull { chunk ->
            runCatching {
                val decoded = String(Base64.getDecoder().decode(chunk))
                val separator = decoded.indexOf('=')
                if (separator <= 0) {
                    null
                } else {
                    decoded.substring(0, separator) to decoded.substring(separator + 1)
                }
            }.getOrNull()
        }
        .toMap()
}

val dartDefines = loadDartDefines()

fun requiredReleaseValue(key: String, envKey: String): String? {
    val fromProperties = keyProperties.getProperty(key)?.trim().orEmpty()
    if (fromProperties.isNotEmpty()) {
        return fromProperties
    }
    val fromEnv = System.getenv(envKey)?.trim().orEmpty()
    if (fromEnv.isNotEmpty()) {
        return fromEnv
    }
    return null
}

fun optionalAdmobAppIdForRelease(): String {
    val candidates = listOf(
        dartDefines["UFFICIOFACILE_ADMOB_APP_ID_ANDROID"],
        dartDefines["UFFICCIOFACILE_ADMOB_APP_ID_ANDROID"],
        project.findProperty("UFFICIOFACILE_ADMOB_APP_ID_ANDROID") as String?,
        project.findProperty("UFFICCIOFACILE_ADMOB_APP_ID_ANDROID") as String?,
        System.getenv("UFFICIOFACILE_ADMOB_APP_ID_ANDROID"),
        System.getenv("UFFICCIOFACILE_ADMOB_APP_ID_ANDROID"),
    )
    return candidates.firstOrNull { !it.isNullOrBlank() }?.trim().orEmpty()
}

val releaseKeystorePath = requiredReleaseValue("storeFile", "ANDROID_KEYSTORE_PATH")
val releaseKeystorePassword =
    requiredReleaseValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = requiredReleaseValue("keyAlias", "ANDROID_KEY_ALIAS")
val releaseKeyPassword = requiredReleaseValue("keyPassword", "ANDROID_KEY_PASSWORD")

val hasReleaseSigning =
    !releaseKeystorePath.isNullOrBlank() &&
        !releaseKeystorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

val isReleaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
    val normalized = taskName.lowercase()
    normalized.contains("bundlerelease") ||
        normalized.contains("assemblerelease") ||
        normalized.contains("packagerelease") ||
        normalized.contains("publishrelease")
}

android {
    namespace = "it.ufficiofacile.app"
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = file(releaseKeystorePath!!)
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    defaultConfig {
        applicationId = "it.ufficiofacile.app"
        minSdk = flutter.minSdkVersion
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobApplicationId"] = optionalAdmobAppIdForRelease()
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobApplicationId"] =
                "ca-app-pub-3940256099942544~3347511713"
        }
        maybeCreate("profile").apply {
            initWith(getByName("debug"))
            manifestPlaceholders["admobApplicationId"] =
                "ca-app-pub-3940256099942544~3347511713"
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            manifestPlaceholders["admobApplicationId"] = optionalAdmobAppIdForRelease()
        }
    }
}

if (isReleaseTaskRequested && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is not configured. Provide android/key.properties or set " +
            "ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, and " +
            "ANDROID_KEY_PASSWORD before building a release bundle.",
    )
}

tasks.register("printAndroidReleaseInfo") {
    group = "verification"
    description = "Print the Android release identity and SDK configuration."
    doLast {
        println("applicationId=it.ufficiofacile.app")
        println("namespace=it.ufficiofacile.app")
        println("compileSdk=${maxOf(flutter.compileSdkVersion, 35)}")
        println("minSdk=${flutter.minSdkVersion}")
        println("targetSdk=${maxOf(flutter.targetSdkVersion, 35)}")
        println("versionCode=${flutter.versionCode}")
        println("versionName=${flutter.versionName}")
        println("releaseSigningConfigured=$hasReleaseSigning")
        println(
            "releaseAdmobAppIdConfigured=${optionalAdmobAppIdForRelease().isNotBlank()}",
        )
    }
}

flutter {
    source = "../.."
}
