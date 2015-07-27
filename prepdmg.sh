#!/bin/sh
rm -rf ${DSTROOT}/dmg ${DSTROOT}/Hesperides*.dmg
mkdir ${DSTROOT}
mkdir ${DSTROOT}/dmg
mkdir ${DSTROOT}/dmg/Fonts
cp dmg-source/DMG_DS_Store ${DSTROOT}/dmg/.DS_Store
cp dmg-source/back.jpg ${DSTROOT}/dmg/
cp TengwarQuenya.ttf TengwarSindarin.ttf ${DSTROOT}/dmg/Fonts
xcrun SetFile -a V ${DSTROOT}/dmg/back.jpg
cp -R "${ARCHIVE_PRODUCTS_PATH}/${INSTALL_PATH}/Hesperides.app" ${DSTROOT}/dmg/
hdiutil create -srcfolder ${DSTROOT}/dmg -fs HFS+ -volname "Hesperides $1" -format UDBZ ${DSTROOT}/Hesperides-$1.dmg
hdiutil attach ${DSTROOT}/Hesperides-$1.dmg
