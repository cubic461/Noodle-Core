package com.noodlecore.lsp.intellij.lang;

import com.intellij.lang.Language;
import org.jetbrains.annotations.NotNull;

/**
 * Root language definition for NoodleCore.
 * 
 * <p>This is the central language registration point that IntelliJ uses
 * to identify and handle NoodleCore files (*.nc). It serves as the
 * foundation for all language-specific features including syntax
 * highlighting, code completion, navigation, etc.</p>
 * 
 * <p><strong>Language ID:</strong> "NoodleCore" (must match plugin.xml)</p>
 * <p><strong>File Extensions:</strong> .nc, .noodle</p>
 * <p><strong>Case Sensitive:</strong> Yes</p>
 * 
 * @author Michael van Erp
 * @version 0.1.0
 * @since 2025-12-18
 */
public class NoodleLanguage extends Language {
    
    /**
     * Single instance of NoodleLanguage.
     * IntelliJ expects language instances to be singletons.
     */
    public static final NoodleLanguage INSTANCE = new NoodleLanguage();
    
    /**
     * Language identifier string.
     * Used for internal reference and plugin registration.
     */
    public static final String ID = "NoodleCore";
    
    /**
     * Default file extension for NoodleCore files.
     */
    public static final String DEFAULT_EXTENSION = "nc";
    
    /**
     * Private constructor ensures singleton pattern.
     * Initializes with language ID for registration.
     */
    private NoodleLanguage() {
        super(ID);
    }
    
    /**
     * Returns the human-readable display name for the language.
     * Used in UI elements like language selection dialogs.
     * 
     * @return Display name "NoodleCore"
     */
    @NotNull
    @Override
    public String getDisplayName() {
        return ID;
    }
    
    /**
     * Indicates whether the language is case-sensitive.
     * NoodleCore is case-sensitive for identifiers and keywords.
     * 
     * @return true (NoodleCore is case-sensitive)
     */
    @Override
    public boolean isCaseSensitive() {
        return true;
    }
    
    /**
     * Returns whether the language has context-dependent keywords.
     * 
     * For NoodleCore, this helps with parser performance and keyword
     * disambiguation in complex expressions.
     * 
     * @return true (supports context-dependent keywords)
     */
    @Override
    public boolean hasContextDependentKeywords() {
        return true;
    }
    
    /**
     * Returns whether the language supports type annotations and generics.
     * NoodleCore has a sophisticated type system with generics support.
     * 
     * @return true (full type system support)
     */
    @Override
    public boolean hasGenericTypes() {
        return true;
    }
    
    /**
     * Returns whether the language supports structured programming constructs.
     * 
     * @return true (functions, classes, modules)
     */
    @Override
    public boolean hasStructuredProgramming() {
        return true;
    }
    
    /**
     * Returns language version information.
     * 
     * @return Current version "0.1.0"
     */
    @NotNull
    public String getVersion() {
        return "0.1.0";
    }
    
    /**
     * Helper method to check if a language string matches NoodleCore.
     * 
     * @param languageId Language ID to check
     * @return true if it's the NoodleCore language identifier
     */
    public static boolean isNoodleLanguage(@NotNull String languageId) {
        return ID.equals(languageId);
    }
    
    /**
     * Helper method for safe language comparison.
     * 
     * @param language Language to compare
     * @return true if the given language is NoodleCore or a dialect
     */
    public static boolean isNoodleLanguage(@NotNull Language language) {
        return language.isKindOf(INSTANCE);
    }
}
