
# setup_windows.ps1
# Run this in PowerShell from the directory where you've unzipped this package.
# It will create platform folders (flutter create .), copy project files into place,
# install dependencies and place launcher icons into android resource folders.
#
# Requirements: Flutter SDK must be on PATH.
# Usage: Open PowerShell as Administrator (if needed) and run: .\setup_windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "Running flutter create . (may overwrite files) ..."
flutter create .

# copy lib, assets, pubspec.yaml, README.md into generated project
Write-Host "Copying project files..."
Copy-Item -Recurse -Force .\lib .\lib
Copy-Item -Force .\pubspec.yaml .\pubspec.yaml
Copy-Item -Recurse -Force .\assets .\assets
Copy-Item -Force .\README.md .\README.md

# Create mipmap folders and copy icons
$iconSourceDir = ".\generated_icons"
$androidRes = ".\android\app\src\main\res"

$mapping = @{
    "mipmap-mdpi" = "mipmap-mdpi";
    "mipmap-hdpi" = "mipmap-hdpi";
    "mipmap-xhdpi" = "mipmap-xhdpi";
    "mipmap-xxhdpi" = "mipmap-xxhdpi";
    "mipmap-xxxhdpi" = "mipmap-xxxhdpi";
}

foreach ($k in $mapping.Keys) {
    $dest = Join-Path $androidRes $mapping[$k]
    if (-Not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }
    $srcIcon = Join-Path $iconSourceDir ("$k.png")
    if (Test-Path $srcIcon) {
        Copy-Item -Force $srcIcon (Join-Path $dest "ic_launcher.png")
    }
}

Write-Host "Running flutter pub get ..."
flutter pub get

Write-Host "Done. You can now run: flutter run -d emulator-5554"
