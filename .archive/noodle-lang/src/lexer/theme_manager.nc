# Theme Manager for Noodle IDE
# Manages IDE themes and styling
# Provides language-independent theme system

import json
import logging
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum

@dataclass
class ColorScheme
    """Color scheme definition"""
    name: str
    description: str
    primary: str
    secondary: str
    background: str
    surface: str
    error: str
    warning: str
    success: str
    info: str
    text_primary: str
    text_secondary: str
    text_disabled: str
    border: str
    accent: str

@dataclass
class ThemeTokens
    """Theme token values"""
    colors: Dict[str, str]
    fonts: Dict[str, str]
    spacing: Dict[str, str]
    borders: Dict[str, str]
    shadows: Dict[str, str]
    animations: Dict[str, str]

class ThemeMode(Enum)
    """Theme modes"""
    LIGHT = "light"
    DARK = "dark"
    HIGH_CONTRAST = "high_contrast"

class NOODLE_THEME_MANAGER
    """Noodle IDE Theme Manager
    
    Manages IDE themes, color schemes, and styling.
    Provides consistent theming across all IDE components.
    """

    def __init__(self):
        """Initialize the theme manager"""
        self.logger = logging.getLogger(__name__)
        
        # Theme state
        self.current_theme = ThemeMode.DARK
        self.current_theme_data = {}
        self.custom_themes = {}
        
        # Predefined color schemes
        self.color_schemes = self._initialize_color_schemes()
        self.theme_definitions = self._initialize_theme_definitions()
        
        # Theme configuration
        self.auto_detect_system_theme = True
        self.enable_custom_themes = True
        self.transition_duration = "0.2s"

    def _initialize_color_schemes(self) -> Dict[str, ColorScheme]:
        """Initialize predefined color schemes"""
        return {
            "dark": ColorScheme(
                name="Dark",
                description="Dark theme with modern aesthetics",
                primary="#007ACC",
                secondary="#FF6B6B",
                background="#1E1E1E",
                surface="#2D2D2D",
                error="#FF4757",
                warning="#FFA502",
                success="#2ED573",
                info="#3742FA",
                text_primary="#FFFFFF",
                textSecondary="#CCCCCC",
                text_disabled="#666666",
                border="#444444",
                accent="#FF6B6B"
            ),
            "light": ColorScheme(
                name="Light",
                description="Clean light theme",
                primary="#007ACC",
                secondary="#FF6B6B",
                background="#FFFFFF",
                surface="#F5F5F5",
                error="#D32F2F",
                warning="#F57C00",
                success="#388E3C",
                info="#1976D2",
                text_primary="#212121",
                textSecondary="#757575",
                text_disabled="#9E9E9E",
                border="#E0E0E0",
                accent="#FF6B6B"
            ),
            "high_contrast": ColorScheme(
                name="High Contrast",
                description="High contrast theme for accessibility",
                primary="#000000",
                secondary="#FFFFFF",
                background="#FFFFFF",
                surface="#F0F0F0",
                error="#CC0000",
                warning="#FF8800",
                success="#008800",
                info="#0000CC",
                text_primary="#000000",
                textSecondary="#333333",
                text_disabled="#999999",
                border="#000000",
                accent="#FF00FF"
            ),
            "solarized_dark": ColorScheme(
                name="Solarized Dark",
                description="Solarized dark theme",
                primary="#268BD2",
                secondary="#D33682",
                background="#002B36",
                surface="#073642",
                error="#DC322F",
                warning="#B58900",
                success="#859900",
                info="#268BD2",
                text_primary="#839496",
                textSecondary="#93A1A1",
                text_disabled="#586E75",
                border="#586E75",
                accent="#D33682"
            ),
            "monokai": ColorScheme(
                name="Monokai",
                description="Monokai color scheme",
                primary="#A6E22E",
                secondary="#F92672",
                background="#272822",
                surface="#3E3D32",
                error="#F92672",
                warning="#FD971F",
                success="#A6E22E",
                info="#66D9EF",
                text_primary="#F8F8F2",
                textSecondary="#75715E",
                text_disabled="#75715E",
                border="#49483E",
                accent="#FD971F"
            )
        }

    def _initialize_theme_definitions(self) -> Dict[str, ThemeTokens]:
        """Initialize theme token definitions"""
        base_tokens = ThemeTokens(
            colors={
                # Base colors - will be populated from color schemes
                "primary": "#007ACC",
                "secondary": "#FF6B6B",
                "background": "#1E1E1E",
                "surface": "#2D2D2D",
                "textPrimary": "#FFFFFF",
                "textSecondary": "#CCCCCC",
                "textDisabled": "#666666",
                "border": "#444444",
                "error": "#FF4757",
                "warning": "#FFA502",
                "success": "#2ED573",
                "info": "#3742FA",
                "accent": "#FF6B6B"
            },
            fonts={
                "family": "'Fira Code', 'Consolas', 'Monaco', monospace",
                "size": "14px",
                "size_small": "12px",
                "size_large": "16px",
                "weight_normal": "400",
                "weight_bold": "600",
                "weight_light": "300"
            },
            spacing={
                "xs": "4px",
                "sm": "8px",
                "md": "12px",
                "lg": "16px",
                "xl": "24px",
                "xxl": "32px"
            },
            borders={
                "radius": "4px",
                "radius_small": "2px",
                "radius_large": "8px",
                "width": "1px",
                "width_thick": "2px"
            },
            shadows={
                "sm": "0 1px 2px rgba(0, 0, 0, 0.1)",
                "md": "0 4px 6px rgba(0, 0, 0, 0.1)",
                "lg": "0 10px 15px rgba(0, 0, 0, 0.1)",
                "xl": "0 20px 25px rgba(0, 0, 0, 0.1)"
            },
            animations={
                "duration": "0.2s",
                "easing": "ease-in-out",
                "duration_fast": "0.1s",
                "duration_slow": "0.3s"
            }
        )

        return {
            "default": base_tokens
        }

    def get_available_themes(self) -> List[Dict[str, Any]]:
        """Get list of available themes"""
        themes = []
        
        # Add predefined themes
        for scheme_name, scheme in self.color_schemes.items():
            themes.append({
                "name": scheme.name,
                "id": scheme_name,
                "type": "predefined",
                "description": scheme.description,
                "is_dark": scheme_name in ["dark", "high_contrast", "solarized_dark", "monokai"]
            })
        
        # Add custom themes
        for theme_name, theme_data in self.custom_themes.items():
            themes.append({
                "name": theme_data.get("name", theme_name),
                "id": theme_name,
                "type": "custom",
                "description": theme_data.get("description", "Custom theme"),
                "is_dark": theme_data.get("is_dark", False)
            })
        
        return themes

    def set_theme(self, theme_id: str) -> bool:
        """Set the current theme"""
        try:
            # Check if theme exists in color schemes
            if theme_id in self.color_schemes:
                self.current_theme = ThemeMode.DARK if theme_id != "light" else ThemeMode.LIGHT
                self.current_theme_data = self._generate_theme_data(self.color_schemes[theme_id])
                
                # Apply theme to DOM
                self._apply_theme_to_dom(self.current_theme_data)
                
                self.logger.info(f"Theme set to: {theme_id}")
                return True
            
            # Check if theme exists in custom themes
            elif theme_id in self.custom_themes:
                theme_data = self.custom_themes[theme_id]
                self.current_theme_data = theme_data
                self._apply_theme_to_dom(theme_data)
                
                self.logger.info(f"Custom theme set to: {theme_id}")
                return True
            
            else:
                self.logger.error(f"Theme not found: {theme_id}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error setting theme {theme_id}: {e}")
            return False

    def get_current_theme(self) -> Dict[str, Any]:
        """Get current theme data"""
        return self.current_theme_data.copy()

    def get_theme_css(self, theme_id: str = None) -> str:
        """Generate CSS for a theme"""
        if theme_id:
            # Get specific theme
            if theme_id in self.color_schemes:
                theme_data = self._generate_theme_data(self.color_schemes[theme_id])
            elif theme_id in self.custom_themes:
                theme_data = self.custom_themes[theme_id]
            else:
                return ""
        else:
            # Get current theme
            theme_data = self.current_theme_data
        
        if not theme_data:
            return ""
        
        css_rules = []
        
        # Generate CSS variables
        css_rules.append(":root {")
        for key, value in theme_data.get("colors", {}).items():
            css_rules.append(f"  --color-{key.replace('_', '-')}: {value};")
        for key, value in theme_data.get("fonts", {}).items():
            if key == "family":
                css_rules.append(f"  --font-{key}: {value};")
            else:
                css_rules.append(f"  --font-{key}: {value};")
        for key, value in theme_data.get("spacing", {}).items():
            css_rules.append(f"  --spacing-{key}: {value};")
        for key, value in theme_data.get("borders", {}).items():
            css_rules.append(f"  --border-{key}: {value};")
        for key, value in theme_data.get("shadows", {}).items():
            css_rules.append(f"  --shadow-{key}: {value};")
        for key, value in theme_data.get("animations", {}).items():
            css_rules.append(f"  --animation-{key}: {value};")
        css_rules.append("}")
        
        # Generate component styles
        css_rules.extend(self._generate_component_styles(theme_data))
        
        return "\n".join(css_rules)

    def _generate_theme_data(self, color_scheme: ColorScheme) -> ThemeTokens:
        """Generate theme data from color scheme"""
        # Create theme tokens with color scheme colors
        theme_tokens = ThemeTokens(
            colors={
                "primary": color_scheme.primary,
                "secondary": color_scheme.secondary,
                "background": color_scheme.background,
                "surface": color_scheme.surface,
                "textPrimary": color_scheme.text_primary,
                "textSecondary": color_scheme.text_secondary,
                "textDisabled": color_scheme.text_disabled,
                "border": color_scheme.border,
                "error": color_scheme.error,
                "warning": color_scheme.warning,
                "success": color_scheme.success,
                "info": color_scheme.info,
                "accent": color_scheme.accent
            },
            fonts=self.theme_definitions["default"].fonts,
            spacing=self.theme_definitions["default"].spacing,
            borders=self.theme_definitions["default"].borders,
            shadows=self.theme_definitions["default"].shadows,
            animations=self.theme_definitions["default"].animations
        )
        
        return theme_tokens

    def _generate_component_styles(self, theme_data: ThemeTokens) -> List[str]:
        """Generate CSS for IDE components"""
        colors = theme_data.colors
        fonts = theme_data.fonts
        spacing = theme_data.spacing
        borders = theme_data.borders
        
        styles = []
        
        # IDE Layout
        styles.append("""
        .ide-container {
            height: 100vh;
            background-color: """ + colors["background"] + """;
            color: """ + colors["textPrimary"] + """;
            font-family: """ + fonts["family"] + """;
        }
        """)
        
        # Menu Bar
        styles.append("""
        .ide-menu-bar {
            background-color: """ + colors["surface"] + """;
            border-bottom: """ + borders["width"] + """ solid """ + colors["border"] + """;
            padding: """ + spacing["sm"] + """;
            display: flex;
        }
        """)
        
        # Toolbar
        styles.append("""
        .ide-toolbar {
            background-color: """ + colors["surface"] + """;
            border-bottom: """ + borders["width"] + """ solid """ + colors["border"] + """;
            padding: """ + spacing["sm"] + """;
            display: flex;
            gap: """ + spacing["sm"] + """;
        }
        """)
        
        # File Explorer
        styles.append("""
        .ide-file-explorer {
            background-color: """ + colors["surface"] + """;
            border-right: """ + borders["width"] + """ solid """ + colors["border"] + """;
            padding: """ + spacing["sm"] + """;
            overflow-y: auto;
        }
        """)
        
        # Code Editor
        styles.append("""
        .ide-code-editor {
            background-color: """ + colors["background"] + """;
            display: flex;
            height: 100%;
        }
        
        .code-textarea {
            background-color: transparent;
            border: none;
            color: """ + colors["textPrimary"] + """;
            font-family: """ + fonts["family"] + """;
            font-size: """ + fonts["size"] + """;
            padding: """ + spacing["md"] + """;
            resize: none;
            outline: none;
            flex: 1;
            line-height: 1.5;
        }
        """)
        
        # Status Bar
        styles.append("""
        .ide-status-bar {
            background-color: """ + colors["surface"] + """;
            border-top: """ + borders["width"] + """ solid """ + colors["border"] + """;
            padding: """ + spacing["xs"] + """ """ + spacing["md"] + """;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: """ + fonts["size_small"] + """;
        }
        """)
        
        # Output Panel
        styles.append("""
        .ide-output-panel {
            background-color: """ + colors["surface"] + """;
            border-top: """ + borders["width"] + """ solid """ + colors["border"] + """;
            padding: """ + spacing["md"] + """;
            overflow-y: auto;
        }
        """)
        
        # Buttons and Interactive Elements
        styles.append("""
        .toolbar-button {
            background-color: transparent;
            border: """ + borders["width"] + """ solid transparent;
            color: """ + colors["textPrimary"] + """;
            padding: """ + spacing["xs"] + """ """ + spacing["sm"] + """;
            border-radius: """ + borders["radius"] + """;
            cursor: pointer;
            transition: background-color """ + theme_data.animations["duration"] + """;
        }
        
        .toolbar-button:hover {
            background-color: """ + colors["surface"] + """;
        }
        
        .toolbar-button:active {
            background-color: """ + colors["accent"] + """;
        }
        """)
        
        return styles

    def _apply_theme_to_dom(self, theme_data: Dict[str, Any]):
        """Apply theme to DOM elements"""
        try:
            # Inject CSS into document
            css_content = self.get_theme_css()
            
            # Remove existing theme style
            existing_style = document.getElementById("noodle-ide-theme")
            if existing_style:
                existing_style.remove()
            
            # Add new theme style
            style_element = document.createElement("style")
            style_element.id = "noodle-ide-theme"
            style_element.textContent = css_content
            document.head.appendChild(style_element)
            
            # Apply theme class to body
            document.body.className = f"noodle-ide theme-{self.current_theme.value}"
            
            self.logger.debug("Theme applied to DOM")
            
        except Exception as e:
            self.logger.error(f"Error applying theme to DOM: {e}")

    def add_custom_theme(self, theme_id: str, theme_data: Dict[str, Any]) -> bool:
        """Add a custom theme"""
        try:
            if not self.enable_custom_themes:
                self.logger.warning("Custom themes are disabled")
                return False
            
            # Validate theme data
            if not isinstance(theme_data, dict):
                raise ValueError("Theme data must be a dictionary")
            
            if "colors" not in theme_data:
                raise ValueError("Theme data must contain colors")
            
            # Store custom theme
            self.custom_themes[theme_id] = theme_data
            
            self.logger.info(f"Custom theme added: {theme_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error adding custom theme {theme_id}: {e}")
            return False

    def remove_custom_theme(self, theme_id: str) -> bool:
        """Remove a custom theme"""
        try:
            if theme_id in self.custom_themes:
                del self.custom_themes[theme_id]
                self.logger.info(f"Custom theme removed: {theme_id}")
                return True
            else:
                self.logger.warning(f"Custom theme not found: {theme_id}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error removing custom theme {theme_id}: {e}")
            return False

    def export_theme(self, theme_id: str) -> Optional[Dict[str, Any]]:
        """Export theme data"""
        try:
            if theme_id in self.color_schemes:
                # Export predefined theme
                scheme = self.color_schemes[theme_id]
                return asdict(scheme)
            elif theme_id in self.custom_themes:
                # Export custom theme
                return self.custom_themes[theme_id].copy()
            else:
                self.logger.warning(f"Theme not found for export: {theme_id}")
                return None
                
        except Exception as e:
            self.logger.error(f"Error exporting theme {theme_id}: {e}")
            return None

    def import_theme(self, theme_data: Dict[str, Any], theme_id: str = None) -> str:
        """Import theme data"""
        try:
            if not theme_id:
                # Generate theme ID from name
                theme_id = theme_data.get("name", f"imported_{len(self.custom_themes)}")
            
            # Normalize theme ID
            theme_id = theme_id.lower().replace(" ", "_")
            
            # Add as custom theme
            if self.add_custom_theme(theme_id, theme_data):
                self.logger.info(f"Theme imported: {theme_id}")
                return theme_id
            else:
                raise ValueError("Failed to add imported theme")
                
        except Exception as e:
            self.logger.error(f"Error importing theme: {e}")
            raise

    def detect_system_theme(self) -> str:
        """Detect system theme preference"""
        try:
            if not self.auto_detect_system_theme:
                return "dark"
            
            # This would implement actual system theme detection
            # For now, return default
            return "dark"
            
        except Exception as e:
            self.logger.error(f"Error detecting system theme: {e}")
            return "dark"

    def set_auto_detect_system_theme(self, enabled: bool):
        """Enable or disable automatic system theme detection"""
        self.auto_detect_system_theme = enabled
        self.logger.info(f"Auto-detect system theme: {enabled}")

    def get_theme_statistics(self) -> Dict[str, Any]:
        """Get theme manager statistics"""
        return {
            "current_theme": self.current_theme.value,
            "available_themes": len(self.color_schemes),
            "custom_themes": len(self.custom_themes),
            "auto_detect_enabled": self.auto_detect_system_theme,
            "transition_duration": self.transition_duration
        }

    def cleanup(self):
        """Clean up theme manager resources"""
        # Remove theme style from DOM
        try:
            existing_style = document.getElementById("noodle-ide-theme")
            if existing_style:
                existing_style.remove()
        except Exception:
            pass  # DOM not available
        
        # Clear custom themes
        self.custom_themes.clear()
        
        self.logger.info("Theme manager cleaned up")

    def __str__(self):
        return f"ThemeManager(current={self.current_theme.value}, available={len(self.color_schemes)})"

    def __repr__(self):
        return f"ThemeManager(custom_themes={len(self.custom_themes)})"