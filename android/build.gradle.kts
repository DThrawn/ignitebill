allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

extra.set("kotlin_version", "2.4.10")

// Remove custom build directory logic that causes issues in CI
// The Flutter Gradle Plugin handles this correctly.

tasks.register<Delete>("clean") {
    description = "Supprime le dossier de build du projet racine."
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
                lintOptions {
                    isAbortOnError = false
                    isCheckDependencies = false
                    isCheckReleaseBuilds = false
                }
            }
        }

        // Force common versions for all subprojects to avoid conflicts
        configurations.all {
            resolutionStrategy {
                force("androidx.browser:browser:1.8.0")
                force("androidx.core:core:1.15.0")
                force("androidx.core:core-ktx:1.15.0")
                force("androidx.annotation:annotation:1.9.1")
                force("androidx.lifecycle:lifecycle-runtime:2.8.7")
                force("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
                
                // Force newer Robolectric and ASM to support newer Java versions
                force("org.robolectric:robolectric:4.13")
                force("org.ow2.asm:asm:9.7")
                force("org.ow2.asm:asm-commons:9.7")
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
