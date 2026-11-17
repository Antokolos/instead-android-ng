import java.util.Properties

plugins {
    id("com.android.application")
}

val appVersion = Properties().apply {
    rootProject.file("version.properties").inputStream().use { load(it) }
}

android {
    namespace = "com.nlbhub.instead.launcher"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.nlbhub.instead.launcher"
        minSdk = 21
        targetSdk = 36
        versionCode = appVersion.getProperty("launcher.versionCode").toInt()
        versionName = appVersion.getProperty("launcher.versionName")
    }

    signingConfigs {
        create("release") {
            // Для CI/релиза: INSTEAD_KEYSTORE + пароли в переменных окружения.
            // Локальный тестовый ключ лежит в keystore/ (gitignore).
            val store = System.getenv("INSTEAD_KEYSTORE") ?: "keystore/test-release.jks"
            storeFile = rootProject.file(store)
            storePassword = System.getenv("INSTEAD_KEYSTORE_PASSWORD") ?: "instead"
            keyAlias = System.getenv("INSTEAD_KEY_ALIAS") ?: "instead"
            keyPassword = System.getenv("INSTEAD_KEY_PASSWORD") ?: "instead"
        }
    }

    sourceSets["main"].apply {
        java.srcDirs("src")
        res.srcDirs("res")
        assets.srcDirs("assets")
        manifest.srcFile("AndroidManifest.xml")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        // minSdk 21: библиотеки сжимаются в APK и распаковываются установщиком.
        jniLibs.useLegacyPackaging = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        abortOnError = false
    }
}

dependencies {
    implementation(project(":engine"))
}
