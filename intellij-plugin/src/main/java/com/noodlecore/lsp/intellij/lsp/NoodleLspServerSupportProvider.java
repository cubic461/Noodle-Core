package com.noodlecore.lsp.intellij.lsp;

import com.intellij.lang.Language;
import com.intellij.openapi.diagnostic.Logger;
import com.intellij.openapi.module.Module;
import com.intellij.openapi.project.Project;
import com.intellij.platform.lsp.api.LspServerSupportProvider;
import com.intellij.platform.lsp.api.ProjectWideLspServerDescriptor;
import com.intellij.psi.PsiFile;
import com.noodlecore.lsp.intellij.lang.NoodleLanguage;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.nio.file.Path;
import java.util.List;

/**
 * LSP Server support provider for NoodleCore language.
 * 
 * <p>This class bridges the IntelliJ Platform with the Python-based
 * NoodleCore Language Server using the Language Server Protocol (LSP).
 * It's responsible for starting the external Python LSP server,
 * managing its lifecycle, and handling communication between the
 * IDE and the language server.</p>
 *
 * <p><strong>Core Responsibilities:</strong></p>
 * <ul>
 *   <li>Detects when NoodleCore files are opened</li>
 *   <li>Launches Python-based LSP server executable</li>
 *   <li>Manages server lifecycle (start/stop/restart)</li>
 *   <li>Routes LSP protocol messages</li>
 *   <li>Handles error recovery and fallback mechanisms</li>
 *   <li>Provides server capabilities information</li>
 * </ul>
 *
 * <p><strong>Architecture:</strong></p>
 * <ul>
 *   <li><strong>Client Side:</strong> IntelliJ Platform (Java/Kotlin)</li>
 *   <li><strong>Communication:</strong> JSON-RPC over stdin/stdout</li>
 *   <li><strong>Server Side:</strong> Python process with NoodleCore runtime</li>
 *   <li><strong>Protocol:</strong> Language Server Protocol v3.17</li>
 * </ul>
 *
 * <p><strong>Performance Requirements:</strong></p>
 * <ul>
 *   <li>Server startup: &lt;2 seconds</li>
 *   <li>First response: &lt;500ms</li>
 *   <li>Completion response: &lt;10ms</li>
 *   <li>Memory usage: &lt;200MB above IDE baseline</li>
 *   <li>CPU usage: &lt;2% background processing</li>
 * </ul>
 *
 * @author Michael van Erp
 * @version 0.1.0
 * @since 2025-12-18
 */
public class NoodleLspServerSupportProvider implements LspServerSupportProvider {
    
    // Logger for diagnostics and debugging
    private static final Logger LOG = Logger.getInstance(NoodleLspServerSupportProvider.class);
    
    // LSP server detection metadata
    private static final String SERVER_NAME = "NoodleCore LSP Server";
    private static final double TARGET_COMPLETION_DELAY_MS = 10.0;
    private static final double TARGET_DEFINITION_DELAY_MS = 50.0;
    private static final double TARGET_MEMORY_MB = 200.0;
    
    /**
     * Called when a file is opened to determine if LSP support
     * should be provided and to start the LSP server if needed.
     *
     * @param project Current IntelliJ project
     * @param file The file that was opened
     * @param serverStarter Callback to initiate LSP server start
     */
    @Override
    public void fileOpened(@NotNull Project project, @NotNull PsiFile file, @NotNull LspServerStarter serverStarter) {
        
        // Only handle files that match NoodleCore language
        if (!file.getLanguage().isKindOf(NoodleLanguage.INSTANCE)) {
            LOG.debug("File " + file.getName() + " is not NoodleCore - LSP server not started");
            return;  // Skip non-NoodleCore files
        }
        
        try {
            // Log the file open event for debugging
            String filePath = file.getVirtualFile() != null 
                ? file.getVirtualFile().getPath() 
                : "unknown-path";
            
            LOG.info("NoodleCore file opened: " + filePath);
            LOG.info("Project base path: " + project.getBasePath());
            LOG.info("Module count: " + project.getModules().length);
            
            // Start or verify LSP server for this project
            serverStarter.ensureServerStarted(new NoodleLspServerDescriptor(project));
            
            LOG.info("✅ LSP server started/verified for project: " + project.getName());
            
        } catch (Exception e) {
            LOG.warn("⚠️ Failed to start LSP server: " + e.getMessage(), e);
            
            // Show user-friendly error notification
            String errorMessage = "Failed to start NoodleCore language server. " +
                                 "Basic syntax highlighting will still work, " +
                                 "but advanced features like autocomplete and " +
                                 "go-to-definition will be disabled.";
            
            // TODO: Show notification to user
            // ApplicationManager.getApplication().invokeLater(
            //     () -> Messages.showWarningDialog(errorMessage, "NoodleCore LSP Warning")
            // );
        }
    }
    
    /**
     * NoodleCore Language Server Descriptor.
     * 
     * Provides configuration for the LSP server instance including:
     * - Command to execute (Python + LSP server script)
     * - Versioning and capabilities
     * - Project-specific settings
     * - Error handling and recovery
     * - Performance optimization options
     */
    static class NoodleLspServerDescriptor extends ProjectWideLspServerDescriptor {
        
        // Reference to associated project
        private final Project project;
        
        // LSP Server capabilities (what the server can do)
        private static final List<String> SUPPORTED_FEATURES = List.of(
            "textDocument/completion",           // Auto-suggest
            "textDocument/definition",           // Go to definition  
            "textDocument/typeDefinition",       // Go to type definition
            "textDocument/references",           // Find references
            "textDocument/implementation",       // Go to implementation
            "textDocument/hover",                // Mouse hover tooltips
            "textDocument/signatureHelp",        // Function signature help
            "textDocument/documentHighlight",    // Symbol highlighting
            "textDocument/documentSymbol",       // File structure outline
            "textDocument/formatting",           // Code formatting
            "textDocument/rangeFormatting",      // Selected range formatting
            "textDocument/rename",               // Refactoring renames
            "textDocument/documentLink",         // Detect links in docs
            "textDocument/diagnostic",           // Error detection (experimental)
            "textDocument/foldingRange",         // Code folding
            "textDocument/codeAction",           // Quick fixes
            "workspace/symbol"                   // Workspace-wide symbol search
        );
        
        // Paths to check for LSP server script
        private static final List<String> SERVER_SCRIPT_CANDIDATES = List.of(
            // Development paths (relative/absolute)
            "C:/Users/micha/Noodle/noodle-core/src/noodlecore/lsp/noodle_lsp_server.py",
            "../noodle-core/src/noodlecore/lsp/noodle_lsp_server.py",
            "../../noodle-core/src/noodlecore/lsp/noodle_lsp_server.py",
            
            // AppData local user paths
            System.getenv("APPDATA") + "/NoodleCore/server/noodle_lsp_server.py",
            System.getenv("LOCALAPPDATA") + "/NoodleCore/server/noodle_lsp_server.py",
            
            // Virtual environment paths
            "../venv/Scripts/noodle_lsp_server.py",
            "../venv/bin/noodle_lsp_server.py",
            
            // Bundled with plugin (JAR resources)
            "server/noodle_lsp_server.py",
            
            // System PATH lookup (last resort)
            "noodle_lsp_server.py"
        );
        
        /**
         * Creates a new LSP server descriptor for given project.
         *
         * @param project Current project reference
         */
        public NoodleLspServerDescriptor(@NotNull Project project) {
            super(project, NoodleLanguage.INSTANCE);
            this.project = project;
            
            LOG.info("Initializing NoodleLspServerDescriptor for project: " + project.getName());
            LOG.info("Project modules: " + project.getModules().length);
            LOG.info("Base path: " + project.getBasePath());
        }
        
        /**
         * Returns the user-facing name of the LSP server.
         * Used in UI elements like status indicators.
         *
         * @return "NoodleCore LSP Server"
         */
        @NotNull
        @Override
        public String getPresentableName() {
            return SERVER_NAME;
        }
        
        /**
         * Returns the command to execute for LSP server process.
         *
         * <p>This builds the system command that launches the external
         * Python process hosting the NoodleCore language server.</p>
         *
         * @return Command line arguments as list
         */
        @NotNull
        @Override
        public List<String> getCommand() {
            // Python executable configuration
            String pythonPath = resolvePythonPath();
            String serverScript = resolveServerScriptPath();
            
            // Build command: python -u server_script.py
            List<String> command = List.of(
                pythonPath,
                "-u",  // unbuffered stdout/stderr for real-time log output
                serverScript
            );
            
            LOG.info("LSP Server Command: " + String.join(" ", command));
            
            return command;
        }
        
        /**
         * Determines if a given file is supported by this LSP server.
         *
         * @param file PsiFile to check
         * @return true if NoodleCore file
         */
        @Override
        public boolean isSupportedFile(@NotNull PsiFile file) {
            boolean isNoodleFile = file.getLanguage().isKindOf(NoodleLanguage.INSTANCE);
            
            LOG.debug("File: " + file.getName() + 
                     " | Supported: " + isNoodleFile + 
                     " | Language: " + file.getLanguage().getID());
            
            return isNoodleFile;
        }
        
        /**
         * Determines if a path should be included in server's workspace.
         *
         * @param path Directory path to check
         * @return true if path contains or should be scanned for .nc files
         */
        @Override
        public boolean matchesContentRoot(@NotNull Path path) {
            // Check if path or any contained files have .nc extension
            File pathFile = path.toFile();
            
            // Always include project base path
            if (project.getBasePath() != null && path.toString().contains(project.getBasePath())) {
                return true;
            }
            
            // Check for .nc files in this directory
            boolean hasNoodleFiles = containsNoodleFiles(pathFile);
            if (hasNoodleFiles) {
                LOG.debug("Content root match: " + path + " contains .nc files");
            }
            
            return hasNoodleFiles;
        }
        
        /**
         * Returns the initial working directory for LSP server process.
         *
         * @return Project base directory or null (use current directory)
         */
        @Override
        public String getWorkingDirectory() {
            String baseDir = project.getBasePath();
            LOG.info("LSP server working directory: " + baseDir);
            return baseDir;
        }
        
        /**
         * Returns LSP server initialization options (JSON object).
         *
         * @return Configuration options for server initialization
         */
        @Override
        public Object getLspInitializationOptions() {
            // Build JSON-like configuration data
            // These options are passed to the server during initialization
            var config = java.util.Map.of(
                "workspace", java.util.Map.of(
                    "name", project.getName(),
                    "path", project.getBasePath() != null ? project.getBasePath() : "",
                    "modules", java.util.Arrays.stream(project.getModules())
                        .map(Module::getName)
                        .collect(java.util.stream.Collectors.toList())
                ),
                
                "features", java.util.Map.of(
                    "errorChecking", true,
                    "typeChecking", true,
                    "formatting", true,
                    "autoComplete", true
                ),
                
                "performance", java.util.Map.of(
                    "cacheSizeMB", 256,
                    "completionDelayMS", 100,
                    "diagnosticDelayMS", 500
                ),
                
                "server", java.util.Map.of(
                    "name", SERVER_NAME,
                    "version", "0.1.0",
                    "supportsRestart", true
                ),
                
                "debug", java.util.Map.of(
                    "lspLoggingEnabled", false,
                    "performanceMonitoring", true,
                    "verboseLogging", false
                ),
                
                "noodlecore", java.util.Map.of(
                    "targetPythonWarnings", false,
                    "enableExperimentalFeatures", false
                )
            );
            
            LOG.info("LSP initialization options sent to server");
            return config;
        }
        
        /**
         * Resolves Python executable path with fallbacks.
         *
         * @return Path to Python executable
         */
        @NotNull
        private String resolvePythonPath() {
            List<String> candidates = List.of(
                // Common Windows paths
                "python3", "python", "py", "py -3",
                "python3.exe", "python.exe",
                System.getenv("PYTHON_HOME") + "/python.exe",
                System.getenv("PYTHON_DIR") + "/python",
                
                // Full paths to check
                "C:/Python39/python.exe",
                "C:/Python310/python.exe", 
                "C:/Python311/python.exe",
                "C:/Users/" + System.getProperty("user.name") + "/AppData/Local/Programs/Python/Python311/python.exe",
                "/usr/bin/python3",  // Linux/macOS fallback
                "/usr/local/bin/python3"
            );
            
            for (String candidate : candidates) {
                if (isExecutableAvailable(candidate)) {
                    LOG.info("Using Python executable: " + candidate);
                    return candidate;
                }
            }
            
            LOG.warn("⚠️ Python executable not found, will try 'python' anyway");
            return "python"; // Last resort
        }
        
        /**
         * Resolves server script path with fallback logic.
         *
         * Searches for noodle_lsp_server.py in multiple locations:
         * 1. Known development paths
         * 2. User home directories
         * 3. Plugin resources
         * 4. System PATH
         *
         * @return Path to server script
         */
        @NotNull
        private String resolveServerScriptPath() {
            for (String candidate : SERVER_SCRIPT_CANDIDATES) {
                
                // Try to resolve relative paths
                String resolvedPath = resolvePath(candidate);
                File scriptFile = new File(resolvedPath);
                
                if (scriptFile.exists() && scriptFile.isFile()) {
                    String absolutePath = scriptFile.getAbsolutePath();
                    LOG.info("✅ LSP server script found: " + absolutePath);
                    return absolutePath;
                }
                
                LOG.debug("LSP server script not found: " + resolvedPath);
            }
            
            // If all else fails, assume it's on system PATH
            String fallback = "noodle_lsp_server.py";
            LOG.warn("⚠️ Using fallback server path: " + fallback);
            return fallback;
        }
        
        /**
         * Helper: Resolves a file path with variable expansion.
         */
        private String resolvePath(@NotNull String path) {
            // Expand environment variables
            String resolved = path
                .replace("${USERPROFILE}", System.getProperty("user.home"))
                .replace("${APPDATA}", System.getenv("APPDATA"))
                .replace("${LOCALAPPDATA}", System.getenv("LOCALAPPDATA"));
            
            // Convert relative to absolute if needed  
            if (!new File(resolved).isAbsolute()) {
                String projectPath = project.getBasePath();
                if (projectPath != null && !projectPath.isBlank()) {
                    resolved = new File(projectPath, resolved).getAbsolutePath();
                }
            }
            
            return resolved;
        }
        
        /**
         * Helper: Checks if an executable exists and is available.
         */
        private boolean isExecutableAvailable(@NotNull String command) {
            try {
                String[] checkCommand = System.getProperty("os.name").toLowerCase().contains("win")
                    ? new String[] {"cmd", "/c", "where", command}
                    : new String[] {"which", command};
                
                Process process = new ProcessBuilder(checkCommand).start();
                int exitCode = process.waitFor();
                return exitCode == 0;
                
            } catch (Exception e) {
                return false;
            }
        }
        
        /**
         * Helper: Recursively checks if directory contains .nc files.
         */
        private boolean containsNoodleFiles(File directory) {
            if (!directory.isDirectory()) {
                return false;
            }
            
            File[] files = directory.listFiles();
            if (files == null) {
                return false;
            }
            
            // Quick check: any immediate .nc files?
            for (File file : files) {
                if (file.isFile() && file.getName().endsWith(".nc")) {
                    return true;
                }
            }
            
            // Deeper check: recurse into subdirectories
            for (File file : files) {
                if (file.isDirectory() && !file.getName().startsWith(".")) {
                    if (containsNoodleFiles(file)) {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        /**
         * Gets available LSP server features (capabilities).
         *
         * @return List of supported LSP method names
         */
        public List<String> getSupportedFeatures() {
            return SUPPORTED_FEATURES;
        }
        
        /**
         * Performance metrics for monitoring.
         */
        public double getTargetCompletionDelayMs() {
            return TARGET_COMPLETION_DELAY_MS;
        }
        
        public double getTargetDefinitionDelayMs() {
            return TARGET_DEFINITION_DELAY_MS;
        }
        
        public double getTargetMemoryMb() {
            return TARGET_MEMORY_MB;
        }
    }
}
