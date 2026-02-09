allprojects {
    repositories {
        // Google Maven (with fallback mirrors)
        maven { url = uri("https://maven.google.com") }
        maven { url = uri("https://dl.google.com/dl/android/maven2/") }
        // Maven Central (with fallback mirrors for reliability)
        maven { url = uri("https://repo.maven.apache.org/maven2") }
        maven { url = uri("https://central.maven.org/maven2") }
        maven { url = uri("https://mirrors.aliyun.com/maven/repository/central") }
        // Gradle Plugin Portal
        maven { url = uri("https://plugins.gradle.org/m2") }
        jcenter()
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
