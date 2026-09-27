#!/bin/bash
# Build, Developer ID-sign, notarize and staple Magic Switch.
# Requires a notarytool keychain profile, created once with:
#   xcrun notarytool store-credentials magic-switch --apple-id <you@example.com> --team-id Q7AVY5688P
set -euo pipefail
cd "$(dirname "$0")"
rm -rf build
xcodebuild clean archive -project "Magic Switch.xcodeproj" -scheme "Magic Switch" \
  -configuration Release -archivePath build/MS.xcarchive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath build/MS.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export -allowProvisioningUpdates
APP="build/export/Magic Switch.app"
ditto -c -k --keepParent "$APP" build/submit.zip
xcrun notarytool submit build/submit.zip --keychain-profile magic-switch --wait
xcrun stapler staple "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"
spctl -a -vvv -t exec "$APP"
xcrun stapler validate "$APP"
ditto -c -k --keepParent "$APP" "build/Magic Switch.zip"
echo "Done: build/Magic Switch.zip"
