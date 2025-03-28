plugins {
    kotlin("jvm") version "1.9.20" // Ensure a proper Kotlin version is specified
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define new build directory path correctly
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.buildDir = newBuildDir.get().asFile

subprojects {
    afterEvaluate {
        buildDir = rootProject.buildDir.resolve(name)
    }
}

// Ensure the clean task correctly deletes the build directory
tasks.named<Delete>("clean") {
    delete(rootProject.buildDir)
}
