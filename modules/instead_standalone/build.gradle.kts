plugins {
    id("com.android.library")
}

android {
    namespace = "com.nlbhub.instead"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        minSdk = 21
        ndk {
            // x86_64 — для эмулятора; на устройстве используется arm64-v8a.
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
        externalNativeBuild {
            ndkBuild {
                arguments += listOf("APP_PLATFORM=android-21")
            }
        }
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

    externalNativeBuild {
        ndkBuild {
            path = file("jni/Android.mk")
        }
    }

    lint {
        abortOnError = false
    }
}

// Заглушки res/raw: реальные архивы генерируются на этапе 3, но R.raw.* должен
// существовать уже сейчас, иначе Java-код не компилируется. Файлы в .gitignore,
// поэтому создаются задачей, а не коммитятся.
val rawDir = layout.projectDirectory.dir("res/raw")

val ensureRawPlaceholders = tasks.register("ensureRawPlaceholders") {
    doLast {
        val dir = rawDir.asFile
        dir.mkdirs()
        val names = listOf(
            "data.zip", "games.zip", "themes.zip",
            "libs_armeabi.zip", "libs_armeabi_v7a.zip", "libs_arm64_v8a.zip",
            "libs_x86.zip", "libs_x86_64.zip"
        )
        names.forEach { name ->
            val file = dir.resolve(name)
            if (!file.exists()) file.createNewFile()
        }
    }
}

tasks.named("preBuild") {
    dependsOn(ensureRawPlaceholders)
}

dependencies {
    api(project(":licensing"))
    api(project(":expansion"))
}
