import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("Loaded key.properties: ${keystoreProperties.stringPropertyNames()}")
    println("storeFile path: ${keystoreProperties["storeFile"]}")
} else {
    throw GradleException("key.properties file not found at ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.vibrantmind.myapp"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.vibrantmind.myapp"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]?.toString()
        keyPassword = keystoreProperties["keyPassword"]?.toString()
        storePassword = keystoreProperties["storePassword"]?.toString()
        val storeFilePath = keystoreProperties["storeFile"]?.toString()
        if (!storeFilePath.isNullOrBlank()) {
            val keystoreFile = file(storeFilePath) // Store in a local variable
            if (!keystoreFile.exists()) {
                throw GradleException("Keystore file not found at: $storeFilePath")
            }
            storeFile = keystoreFile // Assign to the property after validation
        } else {
            throw GradleException("storeFile path is missing in key.properties")
        }
    }
}



    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
