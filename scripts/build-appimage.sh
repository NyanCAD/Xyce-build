#!/bin/bash
set -e
set -o pipefail

echo "Building Xyce AppImage using appimage-builder..."

# Ensure we're in the correct directory
if [ -z "$ROOT" ]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

cd "$ROOT"

# Ensure INSTALL_PATH is set
if [ -z "$INSTALL_PATH" ]; then
  echo "ERROR: INSTALL_PATH must be set"
  exit 1
fi

# Check if Xyce is installed
if [ ! -f "$INSTALL_PATH/bin/Xyce" ]; then
  echo "ERROR: Xyce not found at $INSTALL_PATH/bin/Xyce"
  exit 1
fi

# Check if AppImageBuilder recipe exists
if [ ! -f "data/AppImageBuilder.yml" ]; then
  echo "ERROR: data/AppImageBuilder.yml not found"
  exit 1
fi

# Set version from Xyce binary if available
VERSION="unknown"
if [ -f "$INSTALL_PATH/bin/Xyce" ]; then
  VERSION=$("$INSTALL_PATH/bin/Xyce" --version 2>&1 | head -n1 | grep -oP '\d+\.\d+(\.\d+)?' || echo "unknown")
fi

echo "Building AppImage for Xyce version: $VERSION"

# Export version for AppImageBuilder
export VERSION="$VERSION"

# Clean any existing AppDir
rm -rf AppDir

# Create the AppImage using appimage-builder
echo "Running appimage-builder..."
wget -O appimage-builder-x86_64.AppImage https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage
chmod +x appimage-builder-x86_64.AppImage
./appimage-builder-x86_64.AppImage --appimage-extract-and-run --recipe data/AppImageBuilder.yml

# Find any Xyce AppImage file
echo "Looking for Xyce AppImage file..."
APPIMAGE_OUTPUT=""

# Look for Xyce AppImage files
for appimage_file in Xyce*.AppImage; do
  if [ -f "$appimage_file" ]; then
    APPIMAGE_OUTPUT="$appimage_file"
    break
  fi
done

if [ -n "$APPIMAGE_OUTPUT" ] && [ -f "$APPIMAGE_OUTPUT" ]; then
  echo "AppImage created successfully: $APPIMAGE_OUTPUT"
  ls -lh "$APPIMAGE_OUTPUT"

  # Move to build directory if it exists
  if [ -n "$BUILDDIR" ] && [ -d "$ROOT/$BUILDDIR" ]; then
    mv "$APPIMAGE_OUTPUT" "$ROOT/$BUILDDIR/"
    echo "AppImage moved to: $ROOT/$BUILDDIR/$(basename "$APPIMAGE_OUTPUT")"
  fi
else
  echo "ERROR: AppImage was not created"
  echo "Checking for any AppImage files in current directory:"
  ls -la *.AppImage 2>/dev/null || echo "No AppImage files found"
  exit 1
fi

echo "AppImage build completed successfully!"
