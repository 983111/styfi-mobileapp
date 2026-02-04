allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    project.layout.buildDirectory.value(newBuildDir.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

// --- FIX: Force Java 17 and Auto-Assign Namespace for all plugins ---
subprojects {
    val project = this
    
    val configureAndroid = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                // 1. FORCE JAVA 17 COMPATIBILITY
                // This fixes: "Inconsistent JVM-target compatibility detected"
                val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                
                compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
                
                compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)

                // 2. AUTO-ASSIGN NAMESPACE
                // This fixes: "Namespace not specified"
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespace.invoke(android) as? String

                if (currentNamespace == null || currentNamespace.isEmpty()) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    
                    val defaultNamespace = if (project.group.toString().isNotEmpty() && project.group.toString() != "null") {
                        project.group.toString()
                    } else {
                        "com.example.${project.name.replace("-", "_")}"
                    }
                    
                    setNamespace.invoke(android, defaultNamespace)
                }
            } catch (e: Exception) {
                // Ignore errors if properties don't exist (e.g. non-Android modules)
            }
        }
    }

    // Apply the fix safely (whether the project is already evaluated or not)
    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate {
            configureAndroid()
        }
    }
}
// --- FIX END ---

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
