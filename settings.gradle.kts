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

include(":engine", ":launcher", ":games:redhood")

project(":engine").projectDir = file("modules/instead_standalone")
project(":games:redhood").projectDir = file("games/redhood")
