import java.io.File
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

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

val insteadRoot = layout.projectDirectory.dir("jni/src/instead")
val luaRoot = layout.projectDirectory.dir("jni/src/lua")
val rawDir = layout.projectDirectory.dir("res/raw")
val stageDir = layout.buildDirectory.dir("instead-data")

fun zipDirectory(src: File, dest: File) {
    dest.parentFile.mkdirs()
    ZipOutputStream(dest.outputStream().buffered()).use { zip ->
        src.walkTopDown().sortedBy { it.path }.forEach { file ->
            val name = file.relativeTo(src).invariantSeparatorsPath
            if (file.isDirectory) {
                if (name.isNotEmpty()) {
                    zip.putNextEntry(ZipEntry("$name/"))
                    zip.closeEntry()
                }
            } else {
                zip.putNextEntry(ZipEntry(name))
                file.inputStream().use { it.copyTo(zip) }
                zip.closeEntry()
            }
        }
    }
}

// Собирает data.zip (stead/themes/lang), themes.zip и games.zip из исходников
// INSTEAD. Сами архивы gitignore-ятся: их содержимое зависит от скачанного
// движка, а не от кода оболочки.
val prepareInsteadData = tasks.register("prepareInsteadData") {
    inputs.files(insteadRoot, luaRoot).optional()
    outputs.files(rawDir.file("data.zip"), rawDir.file("themes.zip"), rawDir.file("games.zip"))

    doLast {
        val instead = insteadRoot.asFile
        val lua = luaRoot.asFile
        val stage = stageDir.get().asFile
        stage.deleteRecursively()
        stage.mkdirs()
        rawDir.asFile.mkdirs()

        fun copyDir(from: File, into: File) {
            if (!from.isDirectory) return
            project.copy {
                from(from)
                into(into)
                exclude("CMakeLists.txt", "Makefile", "Makefile.windows")
            }
        }

        if (instead.isDirectory) {
            val data = File(stage, "data")
            copyDir(File(instead, "stead"), File(data, "stead"))
            copyDir(File(instead, "themes"), File(data, "themes"))
            copyDir(File(instead, "lang"), File(data, "lang"))
            if (lua.isDirectory) {
                copyDir(File(lua, "stead2"), File(data, "stead/stead2"))
                copyDir(File(lua, "stead3"), File(data, "stead/stead3"))
            }
            File(data, ".nomedia").createNewFile()
            File(data, "themes/.nomedia").createNewFile()
            zipDirectory(data, rawDir.file("data.zip").asFile)

            val themesStage = File(stage, "themes")
            copyDir(File(instead, "themes"), File(themesStage, "themes"))
            File(themesStage, "themes/.nomedia").createNewFile()
            zipDirectory(themesStage, rawDir.file("themes.zip").asFile)

            val gamesStage = File(stage, "games")
            copyDir(File(instead, "games/tutorial"), File(gamesStage, "games/bundled"))
            File(gamesStage, "games/.nomedia").createNewFile()
            zipDirectory(gamesStage, rawDir.file("games.zip").asFile)
        } else {
            logger.warn("INSTEAD sources not found at ${instead.path}; data archives will be empty placeholders")
            listOf("data.zip", "themes.zip", "games.zip").forEach { name ->
                val file = rawDir.file(name).asFile
                if (!file.exists()) file.createNewFile()
            }
        }
    }
}

tasks.named("preBuild") {
    dependsOn(prepareInsteadData)
}

