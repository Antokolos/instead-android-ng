import java.io.File

plugins {
    id("com.android.application")
}

android {
    namespace = "com.nlbhub.instead.redhood"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.nlbhub.instead.redhood"
        minSdk = 21
        targetSdk = 36
        versionCode = 105006
        versionName = "1.0.6"
    }

    signingConfigs {
        create("release") {
            val store = System.getenv("INSTEAD_KEYSTORE") ?: "keystore/test-release.jks"
            storeFile = rootProject.file(store)
            storePassword = System.getenv("INSTEAD_KEYSTORE_PASSWORD") ?: "instead"
            keyAlias = System.getenv("INSTEAD_KEY_ALIAS") ?: "instead"
            keyPassword = System.getenv("INSTEAD_KEY_PASSWORD") ?: "instead"
        }
    }

    sourceSets["main"].apply {
        java.srcDirs("src/main/java")
        res.srcDirs("src/main/res")
        assets.srcDirs(layout.buildDirectory.dir("generated/game-assets"))
        manifest.srcFile("src/main/AndroidManifest.xml")
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

// Контент игры лежит в INSTEAD-дереве (games/tutorial как заглушка для Red Hood).
// Реальный контент игры подкладывается сюда же и не коммитится в репозиторий.
val gameContent = rootProject.layout.projectDirectory
    .dir("modules/instead_standalone/jni/src/instead/games/tutorial")
val generatedAssets = layout.buildDirectory.dir("generated/game-assets")

val prepareGameContent = tasks.register("prepareGameContent") {
    dependsOn(":engine:fetchInsteadSource")
    inputs.files(gameContent).optional()
    outputs.dir(generatedAssets)
    doLast {
        val out = generatedAssets.get().asFile
        out.deleteRecursively()
        out.mkdirs()
        val target = File(out, "game")
        if (gameContent.asFile.isDirectory) {
            project.copy {
                from(gameContent)
                into(target)
            }
        } else {
            logger.warn("Game content not found at ${gameContent.asFile}; bundling empty assets")
            target.mkdirs()
        }
    }
}

tasks.named("preBuild") {
    dependsOn(prepareGameContent)
}

dependencies {
    implementation(project(":engine"))
}
