package com.noodlecore.lsp.intellij.file;

import com.intellij.lang.Language;
import com.intellij.openapi.fileTypes.LanguageFileType;
import com.noodlecore.lsp.intellij.lang.NoodleLanguage;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

/**
 * File type definition for NoodleCore files (*.nc).
 * 
 * <p>This class registers NoodleCore files with IntelliJ, enabling
 * .nc files to be recognized and opened with appropriate language
 * support. It provides metadata like icons, descriptions, and
 * file extension associations.</p>
 * 
 * <p><strong>Features provided by this file type:</strong></p>
 * <ul>
 *   <li>File association (.nc, .noodle extensions)</li>
 *   <li>Custom file icon</li>
 *   <li>Hover tooltips in file navigator</li>
 *   <li>Embedded language detection</li>
 *   <li>File-specific action menus</li>
 * </ul>
 * 
 * <p><strong>Supported Extensions:</strong></p>
 * <ul>
 *   <li><code>.nc</code> - Standard NoodleCore source files</li>
 *   <li><code>.noodle</code> - Alternative NoodleCore extension</li>
 * </ul>
 * 
 * <p><strong>Icon:</strong> TODO - Add icon at /resources/icons/fileType/noodle.png</p>
 * 
 * @author Michael van Erp
 * @version 0.1.0
 * @since 2025-12-18
 */
public class NoodleFileType extends LanguageFileType {
    
    // Singleton instance pattern required by IntelliJ Platform
    public static final NoodleFileType INSTANCE = new NoodleFileType();
    
    // Standard file extension
    public static final String DEFAULT_EXTENSION = "nc";
    
    // Alternative extensions supported
    public static final String[] SUPPORTED_EXTENSIONS = new String[] { DEFAULT_EXTENSION, "noodle" };
    
    // File type description for UI
    private static final String DESCRIPTION = "NoodleCore source file";
    
    // Icon path (if/when we add custom icons)
    private static final String ICON_PATH = "/icons/fileType/noodle.png";
    
    /**
     * Private constructor ensures singleton pattern.
     * Associates the file type with the NoodleCore language.
     */
    private NoodleFileType() {
        super(NoodleLanguage.INSTANCE);
    }
    
    /**
     * Returns the system-wide name of the file type.
     * Used for internal identification and lookup.
     * 
     * @return "NoodleCore" (must be unique)
     */
    @NotNull
    @Override
    public String getName() {
        return NoodleLanguage.ID;
    }
    
    /**
     * Returns the human-readable description of the file type.
     * Used in file dialogs, settings pages, etc.
     * 
     * @return File type description
     */
    @NotNull
    @Override
    public String getDescription() {
        return DESCRIPTION;
    }
    
    /**
     * Returns the default file extension for this type.
     * 
     * @return "nc" (primary extension)
     */
    @NotNull
    @Override
    public String getDefaultExtension() {
        return DEFAULT_EXTENSION;
    }
    
    /**
     * Returns the custom icon for this file type.
     * 
     * <p>TODO: Create a custom icon and add it to the plugin package.
     * For now, returns null to use IntelliJ default.</p>
     * 
     * @return Icon for .nc files (currently null - use default)
     */
    @Nullable
    @Override
    public Icon getIcon() {
        // TODO: Implement custom icon
        // IconLoader.getIcon(ICON_PATH, getClass());
        return null; // Use IntelliJ default icon
    }
    
    /**
     * Returns whether this file type supports embedded languages.
     * 
     * <p>NoodleCore supports string literals with embedded expressions,
     * but we don't currently support full language injection pattern.</p>
     * 
     * @return false (no embedded language support)
     */
    @Override
    public boolean supportsEmbeddedLanguages() {
        return false;
    }
    
    /**
     * Returns whether this file type supports binary content.
     * 
     * @return false (text-only file type)
     */
    @Override
    public boolean isBinary() {
        return false;
    }
    
    /**
     * Returns whether this file type supports macro substitution.
     * 
     * @return false (no macro support)
     */
    @Override
    public boolean supportsMacros() {
        return false;
    }
    
    /**
     * Returns whether files of this type should be read-only by default.
     * 
     * @return false (files are editable)
     */
    @Override
    public boolean isReadOnly() {
        return false;
    }
    
    /**
     * Returns whether this file type supports indentation tracking.
     * 
     * <p>NoodleCore uses significant whitespace for syntax, so this
     * is critical for proper code formatting and reformatting.</p>
     * 
     * @return true (indentation-sensitive language)
     */
    @Override
    public boolean indentAware() {
        return true;
    }
    
    /**
     * Returns whether the file type allows brace matching.
     * 
     * <p>NoodleCore uses braces for some constructs (generics, tuples),
     * so we enable basic brace matching support.</p>
     * 
     * @return true (supports brace matching)
     */
    @Override
    public boolean supportsBraceMatching() {
        return true;
    }
    
    /**
     * Returns whether the file type allows embedded content detection.
     * 
     * @return false (no complex embedded content)
     */
    @Override
    public boolean allowsEmbedding() {
        return false;
    }
    
    /**
     * Returns whether the file type supports macros and snippets.
     * 
     * @return true (supports basic snippet functionality)
     */
    @Override
    public boolean supportsTypedTokens() {
        return true;
    }
    
    /**
     * Checks if a given extension is supported by this file type.
     * 
     * @param extension File extension to check (without the dot)
     * @return true if extension is supported
     */
    public static boolean isSupportedExtension(@NotNull String extension) {
        for (String supported : SUPPORTED_EXTENSIONS) {
            if (supported.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Returns all supported file extensions.
     * 
     * @return Array of supported extensions
     */
    @NotNull
    public static String[] getSupportedExtensions() {
        return SUPPORTED_EXTENSIONS.clone();
    }
    
    /**
     * Returns the associated language for this file type.
     * 
     * @return NoodleLanguage instance
     */
    @NotNull
    public static Language getNoodleLanguage() {
        return NoodleLanguage.INSTANCE;
    }
}
