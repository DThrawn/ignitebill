buildscript {
    val kotlin_version = "2.1.10"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
