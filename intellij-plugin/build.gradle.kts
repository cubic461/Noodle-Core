plugins {
    id("java")
    id("org.jetbrains.intellij") version "1.16.0"
}

group = "com.noodlecore"
version = "0.1.0"

// Kotlin support
plugins.withType<JavaPlugin>().configureEach {
    configure<JavaPluginConvention> {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

// Configure IntelliJ Platform
intellij {
    version.set("2023.2.5")  // Target IntelliJ version
    type.set("IU")           // IU = IntelliJ Ultimate
    
    plugins.set(
        listOf(
            "org.intellij.intelliLang",  // Language injection support
            "com.intellij.platform.lsp"  // LSP Platform support
        )
    )
    
    // Download sources for debugging
    downloadSources.set(true)
    instrumentCode.set(true)
}

tasks {
    // Patch plugin.xml for version compatibility
    patchPluginXml {
        version.set(project.version.toString())
        sinceBuild.set("232")      // Since 2023.2+
        untilBuild.set("242.*")    // Until 2024.2.x
        
        // Plugin description with HTML
        pluginDescription.set("""
            <h3>The Fastest Language Server for NoodleCore</h3>
            
            <p>Professional IDE support for the NoodleCore language featuring:</p>
            <ul>
                <li>⚡ Ultra-fast completions (&lt;10ms response)</li>
                <li>🧠 Intelligent code analysis</li>
                <li>🔍 Go-to-definition navigation</li>
                <li>💡 Inline documentation & hover help</li>
                <li>🔧 Refactoring & error detection</li>
                <li>🎨 Syntax highlighting</li>
                <li>🔄 Live error checking</li>
            </ul>
            
            <p><strong>REQUIREMENTS:</strong></p>
            <ul>
                <li>Python 3.8+ (for LSP server backend)</li>
                <li>Internet connection (for dependency download)</li>
            </ul>
            
            <p><strong>Quick Start:</strong></p>
            <ol>
                <li>Install this plugin</li>
                <li>Restart IntelliJ IDEA</li>
                <li>Open any .nc file</li>
                <li>Enjoy intelligent code assistance!</li>
            </ol>
            """)
        
        changeNotes.set("""
            Initial release of NoodleCore Language Server for IntelliJ
            <br/><br/>
            <strong>Features:</strong>
            <ul>
                <li>Complete LSP protocol implementation</li>
                <li>Syntax and semantic highlighting</li>
                <li>Code completion with autosuggest</li>
                <li>Go to Definition and References</li>
                <li>Live error detection and quick fixes</li>
                <li>Documentation hover tooltips</li>
                <li>Pattern matching support</li>
            </ul>
            """)
    }
    
    // Set JVM target for compilation
    withType<JavaCompile> {
        options.encoding = "UTF-8"
        options.compilerArgs.add("-parameters")
    }
    
    // Sign plugin (for publishing later)
    signPlugin {
        certificateChain.set(System.getenv("CERTIFICATE_CHAIN"))
        privateKey.set(System.getenv("PRIVATE_KEY"))
        password.set(System.getenv("PRIVATE_KEY_PASSWORD"))
    }
    
    // Publish plugin to JetBrains Marketplace
    publishPlugin {
        token.set(System.getenv("PUBLISH_TOKEN"))
        
        // Publishing channels
        channels.set(listOf(
            "stable",  // Official releases
            "beta",    // Beta testing releases  
            "alpha"    // Alpha/branch testing
        ))
    }
    
    // Build plugin task
    buildPlugin {
        archiveBaseName.set("noodlecore-lsp-intellij")
        archiveClassifier.set("")
        archiveVersion.set(project.version.toString())
        
        // Include bundled dependencies
        from(configurations.runtimeClasspath.map { config ->
            config.map { if (it.isDirectory) it else zipTree(it) }
        })
        
        doFirst {
            println("🛠️  Building NoodleCore IntelliJ Plugin...")
            println("📦 Version: ${project.version}")
            println("🎯 Target IntelliJ: 2023.2+")
        }
        
        doLast {
            println("✅ Plugin built successfully!")
            println("📁 Output: ${archiveFile.get()}")
        }
    }
    
    // Run Plugin in IntelliJ (for development)
    runIde {
        // Max heap size for IntelliJ
        maxHeapSize = "2g"
        
        // JVM arguments
        jvmArgs = listOf(
            "-Xmx2048m",
            "-XX:MaxMetaspaceSize=512m",
            "-XX:+UseG1GC",
            "-XX:SoftRefLRUPolicyMSPerMB=50",
            "-XX:+HeapDumpOnOutOfMemoryError"
        )
        
        // Enable auto-reload for development
        autoReloadPlugins.set(true)
    }
    
    // Custom run task for Python environment setup
    register<Exec>("checkPythonEnvironment") {
        group = "verification"
        description = "Check if Python and dependencies are available"
        
        commandLine = listOf("python", "--version")
        
        doLast {
            println("✅ Python environment check passed")
        }
    }
    
    // Custom task to install Python dependencies
    register<Exec>("installPythonDependencies") {
        group = "setup"
        description = "Install required Python dependencies"
        
        workingDir = projectDir
        commandLine = listOf(
            "python", "-m", "pip", "install",
            "lsprotocol>=2023.0.0",
            "noodlecore>=0.1.0",
            "-r", "requirements.txt"
        )
        
        doLast {
            println("✅ Python dependencies installed")
        }
    }
    
    // Custom task to run LSP server tests
    register<Test>("testLspServer") {
        group = "verification"
        description = "Test LSP server integration"
        
        // Include only LSP tests
        include("**/lsp/*Tests.class")
        
        testLogging {
            events("passed", "skipped", "failed")
            showExceptions = true
            showCauses = true
            showStackTraces = true
            showStandardStreams = true
        }
        
        doFirst {
            println("🧪 Running LSP server integration tests...")
        }
        
        doLast {
            println("✅ LSP server tests completed")
        }
    }
    
    // Performance benchmark task
    register<JavaExec>("benchmark") {
        group = "verification"
        description = "Run performance benchmarks"
        
        mainClass.set("com.noodlecore.lsp.intellij.benchmark.PerformanceBenchmark")
        classpath = sourceSets.test.get().runtimeClasspath
        
        args = listOf(
            "--target", "10ms",     // Completion target
            "--warmup", "1000",     // Warmup iterations
            "--iterations", "10000" // Actual test iterations
        )
        
        doLast {
            println("📊 Performance benchmark completed")
        }
    }
}

// Dependencies
dependencies {
    // IntelliJ Platform dependencies (provided by plugin runtime)
    compileOnly("org.jetbrains:annotations:24.1.0") {
        because("JetBrains annotations for null safety")
    }
    
    // Testing dependencies
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.3")
    testImplementation("org.mockito:mockito-core:5.5.0")
    testImplementation("org.assertj:assertj-core:3.24.2")
    
    // Logging
    testImplementation("ch.qos.logback:logback-classic:1.4.11")
    testImplementation("org.slf4j:slf4j-api:2.0.9")
    
    // JSON processing (for LSP message parsing)
    implementation("com.google.code.gson:gson:2.10.1") {
        because("JSON parsing for LSP messages")
    }
    
    // Apache Commons (utilities)
    implementation("org.apache.commons:commons-lang3:3.13.0")
    implementation("org.apache.commons:commons-collections4:4.4")
    
    // Guava (Google utilities)
    implementation("com.google.guava:guava:32.1.3-jre")
}

// Repository configuration
repositories {
    mavenCentral()
    maven("https://packages.jetbrains.team/maven/p/ij/intellij-dependencies")
    
    // Plugin dependencies repository
    maven("https://cache-redirector.jetbrains.com/intellij-dependencies") {
        because("Access JetBrains dependencies")
    }
}

// Java toolchain (use specific JDK for compilation)
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

// IntelliJ Plugin configuration
configure<org.jetbrains.intellij.IntelliJPluginExtension> {
    // Plugin sandbox location
    sandboxDir.set(project.buildDir.resolve("idea-sandbox").absolutePath)
    
    // Plugin configuration
    pluginName.set("noodlecore-lsp-intellij")
    
    // Update plugin in development instances
    updateSinceUntilBuild.set(true)
    
    // Configuration for Plugin Verifier
    pluginVerifier {
        // Configure verifier options
        ideVersions.set(listOf(
            "IC-2023.2.5",  // IntelliJ Community
            "IU-2023.2.5"   // IntelliJ Ultimate
        ))
    }
}

// Gradle wrapper task
tasks.wrapper {
    gradleVersion = "8.5"
    distributionType = Wrapper.DistributionType.ALL
}

// Performance monitoring
tasks.withType<JavaCompile>().configureEach {
    options.isFork = true
    options.forkOptions.memoryInitialSize = "1024m"
    options.forkOptions.memoryMaximumSize = "2048m"
}
