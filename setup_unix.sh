
#!/usr/bin/env bash
# setup_unix.sh
# Run this in terminal from the directory where you've unzipped this package.
# It will create platform folders (flutter create .), copy project files into place,
# install dependencies and place launcher icons into android resource folders.
#
# Requirements: Flutter SDK must be on PATH.
# Usage: bash setup_unix.sh

set -e

echo "Running flutter create . (may overwrite files) ..."
flutter create .

echo "Copying project files..."
cp -r lib ./lib
cp pubspec.yaml ./pubspec.yaml
cp -r assets ./assets
cp README.md ./README.md

ICON_SOURCE_DIR="./generated_icons"
ANDROID_RES="./android/app/src/main/res"

declare -A mapping=( ["mipmap-mdpi"]="mipmap-mdpi" ["mipmap-hdpi"]="mipmap-hdpi" ["mipmap-xhdpi"]="mipmap-xhdpi" ["mipmap-xxhdpi"]="mipmap-xxhdpi" ["mipmap-xxxhdpi"]="mipmap-xxxhdpi" )

for key in "${!mapping[@]}"; do
  dest="${ANDROID_RES}/${mapping[$key]}"
  mkdir -p "$dest"
  src="$ICON_SOURCE_DIR/${key}.png"
  if [ -f "$src" ]; then
    cp "$src" "$dest/ic_launcher.png"
  fi
done

echo "Running flutter pub get ..."
flutter pub get

echo "Done. You can now run: flutter run -d emulator-5554"
