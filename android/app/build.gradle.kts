import java.util.Properties
import com.android.build.gradle.internal.api.ApkVariantOutputImpl

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dthrawn.ignitebill"
    compileSdk = 35
    ndkVersion = "28.2.13676358"

    lint {
        abortOnError = false
        checkDependencies = false
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    val targetAbi = project.findProperty("target-abi") as String?

    defaultConfig {
        applicationId = "com.dthrawn.ignitebill"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.clear()
            if (targetAbi != null) {
                abiFilters.add(targetAbi)
            }
        }
    }

    signingConfigs {
        create("release") {
            val keyProperties = Properties()
            val keyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                keyProperties.load(keyPropertiesFile.inputStream())
                val storeFileStr = keyProperties.getProperty("storeFile")
                if (storeFileStr != null) {
                    storeFile = rootProject.file(storeFileStr)
                    storePassword = keyProperties.getProperty("storePassword")
                    keyAlias = keyProperties.getProperty("keyAlias")
                    keyPassword = keyProperties.getProperty("keyPassword")
                }
            }
        }
    }

    flavorDimensions += "type"
    productFlavors {
        create("foss") {
            dimension = "type"
            // No suffix to maintain compatibility with existing installs
            versionNameSuffix = "-foss"
        }
        create("play") {
            dimension = "type"
        }
    }

    buildTypes {
        release {
            // F-Droid compatibility: only sign if keystore is present, otherwise build unsigned
            val releaseConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseConfig.storeFile != null) releaseConfig else null
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    splits {
        abi {
            isEnable = targetAbi == null
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }

    val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86" to 3, "x86_64" to 4)
    applicationVariants.configureEach {
        val variant = this
        variant.outputs.forEach { output ->
            val abi = output.filters.find { it.filterType == "ABI" }?.identifier ?: targetAbi
            val abiVersionCode = abiCodes[abi]
            if (abiVersionCode != null) {
                (output as ApkVariantOutputImpl).versionCodeOverride = (variant.versionCode * 10) + abiVersionCode
            }
        }
    }
}

kotlin {
    jvmToolchain(17)
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
