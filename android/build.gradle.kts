allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")

    if (project.name == "app") {
        val flutterProjectRoot = rootProject.projectDir.parentFile
        project.layout.buildDirectory.set(flutterProjectRoot.resolve("build/app"))
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
