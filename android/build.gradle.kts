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
                compileSdkVersion(35)
                defaultConfig {
                    targetSdk = 35
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        // Force JVM target 17 for all Kotlin compilation tasks
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                // Add freeCompilerArgs to handle some metadata issues if needed
                freeCompilerArgs.add("-Xskip-metadata-version-check")
                freeCompilerArgs.add("-Xallow-unstable-dependencies")
            }
        }
    }
}
