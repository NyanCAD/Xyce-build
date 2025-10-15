#!/bin/bash
set -e

echo "Building Xyce AppImage using Docker..."
echo "This will build all stages and extract the AppImage to the current directory."
echo

# Determine output directory
OUTPUT_DIR="${1:-.}"
mkdir -p "$OUTPUT_DIR"

echo "Building Docker image (this may take a while)..."
docker build --target export --output "$OUTPUT_DIR" .

echo
echo "Build complete! AppImage extracted to:"
ls -lh "$OUTPUT_DIR"/Xyce-*.AppImage

echo
echo "To run the AppImage:"
echo "  chmod +x $OUTPUT_DIR/Xyce-*.AppImage"
echo "  $OUTPUT_DIR/Xyce-*.AppImage --version"
