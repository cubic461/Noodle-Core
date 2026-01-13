# Use a Flutter base image
FROM ghcr.io/cirruslabs/flutter:3.16.0 as builder

# Set working directory
WORKDIR /app

# Copy pubspec file
COPY pubspec.yaml ./

# Download dependencies (this will generate pubspec.lock)
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Configure build arguments
ARG FLUTTER_BUILD_MODE=release
ARG FLUTTER_TARGET_PLATFORM=android-arm64

# Build the Flutter app
RUN flutter build apk --${FLUTTER_BUILD_MODE} --target-platform ${FLUTTER_TARGET_PLATFORM}

# Production stage
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the built APK from the builder stage
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk ./noodlecontrol.apk

# Expose port for potential web server (if needed)
EXPOSE 8080

# Add a simple script to serve the APK
RUN echo '#!/bin/bash\n\
echo "NoodleControl Mobile App"\n\
echo "APK location: /app/noodlecontrol.apk"\n\
echo "Download the APK and install it on your device"\n\
echo "Or use adb to install: adb install /app/noodlecontrol.apk"\n\
if [ "$1" = "serve" ]; then\n\
  python3 -m http.server 8080\n\
fi' > /app/serve.sh && chmod +x /app/serve.sh

# Default command
CMD ["/app/serve.sh"]