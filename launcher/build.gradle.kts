plugins {
    id("com.android.application")
}

android {
    namespace = "com.nlbhub.instead.launcher"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.nlbhub.instead.launcher"
        minSdk = 21
        targetSdk = 36
        versionCode = 170001
        versionName = "1.7.0"
    }

    sourceSets["main"].apply {
        java.srcDirs("src")
        res.srcDirs("res")
        assets.srcDirs("assets")
        manifest.srcFile("AndroidManifest.xml")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
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
