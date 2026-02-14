plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Rust build configuration
val rustCoreDir = rootDir.parentFile.parentFile.resolve("rust_core")
val rustAndroidTargetDir = rustCoreDir.resolve("target/android")
val rustCargoTargetDir = rustCoreDir.resolve("target")
val jniLibsDir = projectDir.resolve("src/main/jniLibs")

android {
    namespace = "com.example.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Task to copy Rust libraries from rust_core build output
tasks.register("syncRustLibs") {
    group = "build"
    description = "Copy Rust Android libraries into jniLibs"

    doFirst {
        jniLibsDir.mkdirs()
    }

    doLast {
        val copyTargets = listOf(
            "armv7-linux-androideabi" to "armeabi-v7a",
            "aarch64-linux-android" to "arm64-v8a",
            "x86_64-linux-android" to "x86_64"
        )

        copyTargets.forEach { (cargoTarget, androidAbi) ->
            val sourceCandidates = listOf(
                rustAndroidTargetDir.resolve("$cargoTarget/release/librust_core.so"),
                rustCargoTargetDir.resolve("$cargoTarget/release/librust_core.so")
            )
            val source = sourceCandidates.firstOrNull { it.exists() }

            if (source != null) {
                copy {
                    from(source)
                    into(jniLibsDir.resolve(androidAbi))
                }
            } else {
                logger.info("Rust library not found for $androidAbi. Looked in: ${sourceCandidates.joinToString(", ")}")
            }
        }
    }
}

// Task to verify Rust libraries exist
tasks.register("verifyRustLibs") {
    group = "build"
    description = "Verify Rust libraries are present"
    
    doFirst {
        val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
        val archs = if (isReleaseBuild) {
            listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        } else {
            listOf("x86_64")
        }
        val missingLibs = mutableListOf<String>()
        
        archs.forEach { arch ->
            val libFile = jniLibsDir.resolve("$arch/librust_core.so")
            if (!libFile.exists()) {
                missingLibs.add(arch)
            }
        }
        
        if (missingLibs.isNotEmpty() && !isReleaseBuild) {
            logger.warn(
                "Rust libraries missing for debug: ${missingLibs.joinToString(", ")}. " +
                "App can run, but Rust-powered features may be unavailable until libs are built."
            )
            return@doFirst
        }

        if (missingLibs.isNotEmpty()) {
            throw GradleException(
                "Missing Rust libraries for architectures: ${missingLibs.joinToString(", ")}\n" +
                "\nPlease build the Rust libraries using one of these methods:\n" +
                "  1. From project root (Windows):\n" +
                "       scripts\\build-rust-android.bat\n" +
                "       scripts\\copy-rust-to-mobile.bat\n" +
                "\n" +
                "  2. From project root (PowerShell):\n" +
                "       pwsh ./scripts/build-rust-android-docker.ps1\n" +
                "       pwsh ./scripts/copy-rust-to-mobile.ps1\n" +
                "\n" +
                "  3. Local build with Android NDK:\n" +
                "       rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android\n" +
                "       cargo install cargo-ndk\n" +
                "       cd rust_core && cargo ndk -t armeabi-v7a -t arm64-v8a -t x86_64 build --release\n" +
                "       # Then copy from rust_core/target/ to mobile/android/app/src/main/jniLibs/\n" +
                "\n" +
                "Libraries should be at: ${jniLibsDir.absolutePath}"
            )
        }
        
        println("✓ Rust libraries verified for: ${archs.joinToString(", ")}")
    }
}

// Make preBuild depend on verification
tasks.named("preBuild") {
    dependsOn("syncRustLibs")
    dependsOn("verifyRustLibs")
}
