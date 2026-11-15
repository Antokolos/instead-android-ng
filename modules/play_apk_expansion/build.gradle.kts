plugins {
    id("com.android.library")
}

android {
    namespace = "com.android.vending.expansion.downloader"
    compileSdk = 36

    defaultConfig {
        minSdk = 21
    }

    sourceSets["main"].apply {
        java.srcDirs("src")
        res.srcDirs("res")
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

dependencies {
    // Вендоренный support-v4: код уведомлений использует NotificationCompat.
    implementation(files("libs/android-support-v4.jar"))
    // DownloaderService проверяет лицензию через LVL.
    api(project(":licensing"))
}
