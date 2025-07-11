#!/bin/bash

INPUT_ICON="AppIcon1024.png"
OUTPUT_DIR="AppIcon.appiconset"

# Check for input
if [ ! -f "$INPUT_ICON" ]; then
  echo "❌ Error: $INPUT_ICON not found."
  exit 1
fi

# Create output folder
mkdir -p "$OUTPUT_DIR"

# Define icon specs: "filename size scale idiom"
icons=(
  "Icon-20@2x 40 2x iphone"
  "Icon-20@3x 60 3x iphone"
  "Icon-29@2x 58 2x iphone"
  "Icon-29@3x 87 3x iphone"
  "Icon-40@2x 80 2x iphone"
  "Icon-40@3x 120 3x iphone"
  "Icon-60@2x 120 2x iphone"
  "Icon-60@3x 180 3x iphone"
  "Icon-1024 1024 1x ios-marketing"
)

# Flatten image to avoid transparency
sips -s format png --padColor FFFFFF $INPUT_ICON

# Generate images
for entry in "${icons[@]}"; do
  name=$(echo "$entry" | awk '{print $1}')
  size=$(echo "$entry" | awk '{print $2}')
  sips -Z "$size" "$INPUT_ICON" --out "$OUTPUT_DIR/$name.png" >/dev/null
  echo "✅ Created $name.png ($size x $size)"
done

# Create Contents.json
cat > "$OUTPUT_DIR/Contents.json" <<EOF
{
  "images": [
EOF

# Add image entries
for entry in "${icons[@]}"; do
  name=$(echo "$entry" | awk '{print $1}')
  size=$(echo "$entry" | awk '{print $2}')
  scale=$(echo "$entry" | awk '{print $3}')
  idiom=$(echo "$entry" | awk '{print $4}')
  width=$(echo "scale=2; $size / (${scale:0:1})" | bc)

  echo "    {" >> "$OUTPUT_DIR/Contents.json"
  echo "      \"size\": \"${width}x${width}\"," >> "$OUTPUT_DIR/Contents.json"
  echo "      \"idiom\": \"$idiom\"," >> "$OUTPUT_DIR/Contents.json"
  echo "      \"filename\": \"$name.png\"," >> "$OUTPUT_DIR/Contents.json"
  echo "      \"scale\": \"$scale\"" >> "$OUTPUT_DIR/Contents.json"
  echo "    }," >> "$OUTPUT_DIR/Contents.json"
done

# Trim last comma and close JSON
sed -i '' '$ s/},/}/' "$OUTPUT_DIR/Contents.json"
cat >> "$OUTPUT_DIR/Contents.json" <<EOF
  ],
  "info": {
    "version": 1,
    "author": "xcode"
  }
}
EOF

echo "🎉 All icons and Contents.json created in $OUTPUT_DIR/"