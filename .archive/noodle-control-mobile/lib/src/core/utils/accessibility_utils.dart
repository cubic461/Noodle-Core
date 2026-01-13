import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../app.dart';

/// Accessibility utilities for ensuring the app is usable by everyone
class AccessibilityUtils {
  static final Logger _logger = App.logger;
  
  /// Check if accessibility features are enabled
  static bool get isAccessibilityEnabled {
    // In a real implementation, you would check if accessibility services are enabled
    // For now, we'll return a placeholder
    return false;
  }
  
  /// Check if high contrast mode is enabled
  static bool get isHighContrastEnabled {
    // In a real implementation, you would check if high contrast is enabled
    // For now, we'll return a placeholder
    return false;
  }
  
  /// Check if reduce motion is enabled
  static bool get isReduceMotionEnabled {
    // In a real implementation, you would check if reduce motion is enabled
    // For now, we'll return a placeholder
    return false;
  }
  
  /// Check if screen reader is enabled
  static bool get isScreenReaderEnabled {
    // In a real implementation, you would check if a screen reader is active
    // For now, we'll return a placeholder
    return false;
  }
  
  /// Get preferred font scale
  static double get preferredFontScale {
    // In a real implementation, you would get the system font scale
    // For now, we'll return a default value
    return 1.0;
  }
  
  /// Announce a message to screen readers
  static void announce(String message) {
    if (message.isEmpty) return;
    
    // In a real implementation, you would use a platform-specific method
    // to announce the message to screen readers
    _logger.d('Screen reader announcement: $message');
  }
  
  /// Play a sound for accessibility feedback
  static void playFeedbackSound(AccessibilityFeedbackType type) {
    // In a real implementation, you would play an appropriate sound
    // based on the feedback type
    _logger.d('Playing accessibility feedback sound: ${type.name}');
  }
  
  /// Vibrate for accessibility feedback
  static void vibrate(AccessibilityFeedbackType type) {
    // In a real implementation, you would vibrate with appropriate pattern
    // based on the feedback type
    _logger.d('Vibrating for accessibility feedback: ${type.name}');
  }
  
  /// Create a semantic label for an icon
  static String createSemanticLabel(
    IconData icon,
    String? customLabel, {
    bool isButton = false,
  }) {
    if (customLabel != null && customLabel.isNotEmpty) {
      return isButton ? 'Button: $customLabel' : customLabel;
    }
    
    // Generate default semantic labels based on common icons
    switch (icon.codePoint) {
      case 0xe5d3: // Icons.add
        return isButton ? 'Button: Add' : 'Add';
      case 0xe5c4: // Icons.remove
        return isButton ? 'Button: Remove' : 'Remove';
      case 0xe8b8: // Icons.search
        return isButton ? 'Button: Search' : 'Search';
      case 0xe5d4: // Icons.arrow_back
        return isButton ? 'Button: Back' : 'Back';
      case 0xe5dd: // Icons.arrow_forward
        return isButton ? 'Button: Forward' : 'Forward';
      case 0xe8cc: // Icons.settings
        return isButton ? 'Button: Settings' : 'Settings';
      case 0xe7fd: // Icons.home
        return isButton ? 'Button: Home' : 'Home';
      case 0xe0b7: // Icons.close
        return isButton ? 'Button: Close' : 'Close';
      case 0xe5ca: // Icons.delete
        return isButton ? 'Button: Delete' : 'Delete';
      case 0xe254: // Icons.edit
        return isButton ? 'Button: Edit' : 'Edit';
      case 0xe876: // Icons.check
        return isButton ? 'Button: Confirm' : 'Confirm';
      case 0xe888: // Icons.info
        return isButton ? 'Button: Information' : 'Information';
      case 0xe000: // Icons.error
        return isButton ? 'Button: Error' : 'Error';
      case 0xe88e: // Icons.warning
        return isButton ? 'Button: Warning' : 'Warning';
      default:
        return isButton ? 'Button' : 'Icon';
    }
  }
  
  /// Create a semantic description for a progress indicator
  static String createProgressDescription(int progress, int total) {
    final percentage = total > 0 ? (progress / total * 100).round() : 0;
    return 'Progress: $progress of $total ($percentage%)';
  }
  
  /// Create a semantic description for a list item
  static String createListItemDescription(int index, int total, String content) {
    return 'Item ${index + 1} of $total: $content';
  }
  
  /// Create a semantic description for a tab
  static String createTabDescription(String label, bool isSelected) {
    return 'Tab: $label, ${isSelected ? 'selected' : 'not selected'}';
  }
  
  /// Create a semantic description for a text field
  static String createTextFieldDescription(
    String label,
    String? value, {
    bool isRequired = false,
    bool isReadOnly = false,
    bool isDisabled = false,
  }) {
    final parts = <String>['Input field: $label'];
    
    if (value != null && value.isNotEmpty) {
      parts.add('Current value: $value');
    }
    
    if (isRequired) {
      parts.add('Required');
    }
    
    if (isReadOnly) {
      parts.add('Read only');
    }
    
    if (isDisabled) {
      parts.add('Disabled');
    }
    
    return parts.join(', ');
  }
  
  /// Create a semantic description for a switch
  static String createSwitchDescription(String label, bool value) {
    return 'Switch: $label, ${value ? 'on' : 'off'}';
  }
  
  /// Create a semantic description for a slider
  static String createSliderDescription(String label, double value, double min, double max) {
    return 'Slider: $label, value: ${value.toStringAsFixed(1)}, range: ${min.toStringAsFixed(1)} to ${max.toStringAsFixed(1)}';
  }
  
  /// Create a semantic description for a date picker
  static String createDateDescription(DateTime date) {
    return 'Selected date: ${date.day}/${date.month}/${date.year}';
  }
  
  /// Create a semantic description for a time picker
  static String createTimeDescription(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return 'Selected time: ${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }
  
  /// Check if a color combination has sufficient contrast
  static bool hasSufficientContrast(Color foreground, Color background) {
    // Calculate relative luminance
    double getLuminance(Color color) {
      final r = color.red / 255.0;
      final g = color.green / 255.0;
      final b = color.blue / 255.0;
      
      final rLum = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
      final gLum = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
      final bLum = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);
      
      return 0.2126 * rLum + 0.7152 * gLum + 0.0722 * bLum;
    }
    
    final fgLum = getLuminance(foreground);
    final bgLum = getLuminance(background);
    
    final lighter = fgLum > bgLum ? fgLum : bgLum;
    final darker = fgLum > bgLum ? bgLum : fgLum;
    
    final contrast = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA standard requires contrast ratio of at least 4.5:1 for normal text
    return contrast >= 4.5;
  }
  
  /// Get a color with sufficient contrast against a background
  static Color getContrastingColor(Color background, {Color? preferredColor}) {
    final colors = [
      preferredColor ?? Colors.black,
      Colors.white,
      Colors.grey[800]!,
      Colors.grey[200]!,
    ];
    
    for (final color in colors) {
      if (hasSufficientContrast(color, background)) {
        return color;
      }
    }
    
    // If none have sufficient contrast, return black or white based on background
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

/// Types of accessibility feedback
enum AccessibilityFeedbackType {
  selection,
  success,
  error,
  warning,
  navigation,
  completion,
}

/// Extension to add accessibility properties to widgets
extension AccessibilityWidgetExtension on Widget {
  /// Add semantic label to a widget
  Widget withSemanticsLabel(
    String label, {
    bool isButton = false,
    bool isLink = false,
    bool isTextField = false,
    bool isImage = false,
    bool isHeader = false,
    String? hint,
    bool? isEnabled,
    bool? isChecked,
    bool? isSelected,
    bool? isToggled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      link: isLink,
      textField: isTextField,
      image: isImage,
      header: isHeader,
      enabled: isEnabled,
      selected: isSelected,
      checked: isChecked,
      toggled: isToggled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: this,
    );
  }
  
  /// Add accessibility properties to an icon
  Widget withIconAccessibility(
    IconData icon, {
    String? label,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: AccessibilityUtils.createSemanticLabel(icon, label, isButton: isButton),
      button: isButton,
      image: true,
      onTap: onTap,
      child: this,
    );
  }
}

/// Extension to add accessibility to text fields
extension AccessibilityTextFieldExtension on TextField {
  /// Add accessibility properties to a text field
  TextField withAccessibility({
    String? label,
    String? hint,
    bool isRequired = false,
    bool isReadOnly = false,
    bool isDisabled = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      readOnly: isReadOnly || readOnly,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      enabled: !isDisabled && enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      onTap: onTap,
      mouseCursor: mouseCursor,
      buildCounter: buildCounter,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      restorationId: restorationId,
      semanticLabel: AccessibilityUtils.createTextFieldDescription(
        label ?? decoration?.labelText ?? '',
        controller?.text,
        isRequired: isRequired,
        isReadOnly: isReadOnly,
        isDisabled: isDisabled,
      ),
    );
  }
}

/// Extension to add accessibility to progress indicators
extension AccessibilityProgressExtension on ProgressIndicator {
  /// Add accessibility properties to a progress indicator
  Widget withAccessibility({
    required int progress,
    required int total,
    String? label,
  }) {
    return Semantics(
      label: label ?? 'Progress',
      value: AccessibilityUtils.createProgressDescription(progress, total),
      child: this,
    );
  }
}

/// Extension to add accessibility to lists
extension AccessibilityListExtension on ListView {
  /// Add accessibility properties to a list view
  ListView withAccessibility({
    String? label,
  }) {
    return ListView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      semanticLabel: label,
    );
  }
}

// Helper function for pow since dart:math is not imported
double pow(double x, double exponent) {
  if (exponent == 0) return 1.0;
  if (exponent == 1) return x;
  if (exponent == 2) return x * x;
  
  double result = 1.0;
  for (int i = 0; i < exponent.toInt(); i++) {
    result *= x;
  }
  return result;
}