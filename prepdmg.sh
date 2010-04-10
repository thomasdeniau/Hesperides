#!/bin/sh
rm -rf dmg Hesperides*.dmg
mkdir dmg
mkdir dmg/Fonts
cp dmg-source/DMG_DS_Store dmg/.DS_Store
cp dmg-source/back.jpg dmg/
cp TengwarQuenya.ttf TengwarSindarin.ttf dmg/Fonts
/Developer/Tools/SetFile -a V dmg/back.jpg
xcodebuild -configuration Release
cp -R build/Release/Hesperides.app dmg/
hdiutil create -srcfolder dmg -fs HFS+ -volname "Hesperides $1" -format UDBZ Hesperides-$1.dmg
hdiutil attach Hesperides-$1.dmg
