pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "instead-android-ng"

include(":licensing", ":expansion", ":engine", ":launcher")

project(":licensing").projectDir = file("modules/play_licensing")
project(":expansion").projectDir = file("modules/play_apk_expansion")
project(":engine").projectDir = file("modules/instead_standalone")
