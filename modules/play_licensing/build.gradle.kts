plugins {
    id("com.android.library")
}

android {
    namespace = "com.google.android.vending.licensing"
    compileSdk = 36

    defaultConfig {
        minSdk = 21
    }

    buildFeatures {
        aidl = true
    }

    sourceSets["main"].apply {
        java.srcDirs("src")
        aidl.srcDirs("aidl")
        manifest.srcFile("AndroidManifest.xml")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        abortOnError = false
    }
}
