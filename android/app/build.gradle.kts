plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // Plugin de Google Services para Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.aplicacion_skillwask"
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
        applicationId = "com.example.aplicacion_skillwask"
        minSdk = flutter.minSdkVersion // Recomendado para Firebase y algunas funciones de Flutter
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// AQUÍ AGREGAMOS LAS DEPENDENCIAS DE FIREBASE
dependencies {
    // Importa el BoM de Firebase (gestiona las versiones de todas las librerías)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Librerías de Firebase que quieres usar
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")     // Para los correos
    implementation("com.google.firebase:firebase-firestore") // Para guardar información
}
