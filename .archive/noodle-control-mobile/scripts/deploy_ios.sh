#!/bin/bash

# NoodleControl iOS Deployment Script
# This script builds and deploys the iOS app to various environments

set -e

# Configuration
APP_NAME="NoodleControl"
BUNDLE_ID="com.noodlecontrol.app"
BUILD_DIR="build/ios/iphoneos"
WORKSPACE="ios/Runner.xcworkspace"
SCHEME="Runner"
EXPORT_OPTIONS_PLIST="ios/ExportOptions.plist"

# Environment variables
ENVIRONMENT=${1:-"development"}
FLAVOR=${2:-"development"}

echo "========================================"
echo "  NoodleControl iOS Deployment"
echo "========================================"
echo "Environment: $ENVIRONMENT"
echo "Flavor: $FLAVOR"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Xcode is not installed. Please install Xcode first."
    exit 1
fi

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "CocoaPods is not installed. Please install CocoaPods first."
    exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
rm -rf ios/build

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Install CocoaPods dependencies
echo "Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

# Build the app
echo "Building $FLAVOR flavor for $ENVIRONMENT environment..."
case $FLAVOR in
    "development")
        flutter build ios --debug --simulator --flavor development
        ;;
    "staging")
        flutter build ios --release --no-codesign --flavor staging
        ;;
    "production")
        flutter build ios --release --no-codesign --flavor production
        ;;
    *)
        echo "Unknown flavor: $FLAVOR"
        echo "Available flavors: development, staging, production"
        exit 1
        ;;
esac

# Deploy based on environment
echo "Deploying to $ENVIRONMENT environment..."
case $ENVIRONMENT in
    "development")
        # Install on connected simulator
        echo "Installing on connected simulator..."
        SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone" | grep "Booted" | head -1 | grep -oE "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}")
        if [ -z "$SIMULATOR_ID" ]; then
            echo "No booted iPhone simulator found. Please boot a simulator first."
            exit 1
        fi
        
        # Find the built app
        APP_PATH=$(find ios/build -name "$APP_NAME.app" | head -1)
        if [ -z "$APP_PATH" ]; then
            echo "Could not find built app. Please check the build process."
            exit 1
        fi
        
        xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
        echo "App installed successfully on simulator."
        ;;
    "staging")
        # Create IPA for TestFlight or other distribution
        echo "Creating IPA for staging distribution..."
        
        # Create export options plist if it doesn't exist
        if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
            echo "Creating ExportOptions.plist for staging..."
            cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF
        fi
        
        # Build and archive
        xcodebuild -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -configuration Release \
            -destination generic/platform=iOS \
            -archivePath "$BUILD_DIR/Runner.xcarchive" \
            archive
        
        # Export IPA
        xcodebuild -exportArchive \
            -archivePath "$BUILD_DIR/Runner.xcarchive" \
            -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
            -exportPath "$BUILD_DIR"
            
        echo "IPA created successfully at $BUILD_DIR"
        echo "Upload to TestFlight or other distribution platform manually."
        ;;
    "production")
        # Create IPA for App Store distribution
        echo "Creating IPA for App Store distribution..."
        
        # Create export options plist if it doesn't exist
        if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
            echo "Creating ExportOptions.plist for production..."
            cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF
        fi
        
        # Build and archive
        xcodebuild -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -configuration Release \
            -destination generic/platform=iOS \
            -archivePath "$BUILD_DIR/Runner.xcarchive" \
            archive
        
        # Export IPA
        xcodebuild -exportArchive \
            -archivePath "$BUILD_DIR/Runner.xcarchive" \
            -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
            -exportPath "$BUILD_DIR"
            
        echo "IPA created successfully at $BUILD_DIR"
        echo "Upload to App Store Connect manually or use fastlane."
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        echo "Available environments: development, staging, production"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "  Deployment completed successfully!"
echo "========================================"