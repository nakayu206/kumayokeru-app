allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// AGP 8.x はnamespaceを必須とするが、古いFlutterプラグイン(isar_flutter_libs等)は
// build.gradleにnamespaceを持たない。
// afterEvaluateではAGPのチェック後になり遅すぎるため、plugins.withIdでプラグイン適用直後にフックし、
// AndroidManifest.xmlのpackage属性からnamespaceを補完する。
subprojects {
    plugins.withId("com.android.library") {
        val android =
            extensions.findByType(
                com.android.build.gradle.LibraryExtension::class.java,
            )
        if (android != null && android.namespace == null) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val match =
                    Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifestFile.readText())
                if (match != null) {
                    android.namespace = match.groupValues[1]
                }
            }
        }
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
