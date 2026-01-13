rootProject.name = "noodlecore-lsp-intellij"

// Plugin modules (currently single module, can expand later)
include(":noodlecore-lsp-intellij")

// Future modules (for multi-module setup later):
// include(":lsp-client")
// include(":syntax-highlighter")
// include(":parser-engine")
// include(":ui-components")

// Enable Gradle configuration cache
enableFeaturePreview("STABLE_CONFIGURATION_CACHE")
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

// Kotlin DSL settings (for multi-platform support later)
pluginManagement {
    repositories {
        gradlePluginPortal()
        
        // IntelliJ plugin repository
        maven("https://packages.jetbrains.team/maven/p/ij/intellij-dependencies")
        
        // Kotlin language repository
        maven("https://cache-redirector.jetbrains.com/kotlin-nightly")
        
        // Google Maven for Android dependencies (future expansion)
        maven("https://dl.google.com/dl/android/maven2/")
    }
    
    plugins {
        val kotlinVersion = "1.9.10"
        val intellijVersion = "1.16.0"
        val kotlinxSerializationVersion = "1.6.0"
        
        // Kotlin plugins
        kotlin("jvm") version kotlinVersion
        kotlin("plugin.serialization") version kotlinVersion
        
        // IntelliJ Development plugins
        id("org.jetbrains.intellij") version intellijVersion
        
        // Database plugins (for future SQLite support)
        id("org.jetbrains.exposed.gradle") version "0.17.1"
        
        // Testing plugins
        id("org.jetbrains.testwatcher") version "0.2.3"
        id("com.adarshr.test-logger") version "4.0.0"
    }
}

// Resolution strategy for dependencies
dependencyResolutionManagement {
    repositories {
        mavenCentral()
        
        // JetBrains artifacts
        maven("https://packages.jetbrains.team/maven/p/ij/intellij-dependencies")
        
        // Google artifacts
        google()
        
        // JCenter (fallback for legacy deps)
        maven("https://maven.aliyun.com/repository/jcenter")
        
        // Eclipse artifacts (for LSP4J)
        maven("https://repo.eclipse.org/content/groups/releases/")
    }
    
    versionCatalogs {
        create("libs") {
            // Kotlin versions
            val kotlin = "1.9.10"
            val kotlinx = "1.6.0"
            
            // Kotlin libs
            library("kotlin-stdlib", "org.jetbrains.kotlin:kotlin-stdlib:${kotlin}")
            library("kotlin-stdlib-jdk8", "org.jetbrains.kotlin:kotlin-stdlib-jdk8:${kotlin}")
            library("kotlin-reflect", "org.jetbrains.kotlin:kotlin-reflect:${kotlin}")
            library("kotlinx-serialization-json", "org.jetbrains.kotlinx:kotlinx-serialization-json:${kotlinx}")
            
            // Testing
            val junit = "5.10.0"
            val mockito = "5.5.0"
            
            library("junit-jupiter-api", "org.junit.jupiter:junit-jupiter-api:${junit}")
            library("junit-jupiter-engine", "org.junit.jupiter:junit-jupiter-engine:${junit}")
            library("junit-jupiter-params", "org.junit.jupiter:junit-jupiter-params:${junit}")
            library("mockito-core", "org.mockito:mockito-core:${mockito}")
            library("mockito-junit-jupiter", "org.mockito:mockito-junit-jupiter:${mockito}")
            
            // Google libs
            val guava = "32.1.3-jre"
            val gson = "2.10.1"
            
            library("guava", "com.google.guava:guava:${guava}")
            library("gson", "com.google.code.gson:gson:${gson}")
            
            // Apache Commons
            val commons = "3.13.0"
            val commonsCollections = "4.4"
            
            library("commons-lang3", "org.apache.commons:commons-lang3:${commons}")
            library("commons-collections4", "org.apache.commons:commons-collections4:${commonsCollections}")
            
            // Logging
            val slf4j = "2.0.9"
            val logback = "1.4.11"
            
            library("slf4j-api", "org.slf4j:slf4j-api:${slf4j}")
            library("logback-classic", "ch.qos.logback:logback-classic:${logback}")
        }
    }
}
