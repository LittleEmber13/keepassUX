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

    if (project.name == "argon2_ffi") {
        project.afterEvaluate {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                externalNativeBuild.cmake.version = "3.22.1"
                defaultConfig {
                    externalNativeBuild {
                        cmake {
                            arguments += "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
