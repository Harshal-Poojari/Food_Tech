allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(newBuildDir)
subprojects {
    afterEvaluate {
        // Directly set the build directory without mapping to prevent circular dependency
        project.buildDir = newBuildDir.get().asFile.resolve(healthy_scan)
    }
}

// Ensure the clean task deletes the correct directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory.get().asFile)
}
