allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Remove custom build directory logic that causes issues in CI
// The Flutter Gradle Plugin handles this correctly.

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34)
                defaultConfig {
                    targetSdkVersion(34)
                }
            }
        }
    }
}
