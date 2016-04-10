#!/bin/bash

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Pretty ascii art
echo "._______.._______..__...._..___..._.._______................";
echo "|.._....||..._...||..|..|.||...|.|.||.......|...............";
echo "|.|_|...||..|_|..||...|_|.||...|_|.||.._____|...............";
echo "|.......||.......||.......||......_||.|_____................";
echo "|.._...|.|.......||.._....||.....|_.|_____..|...............";
echo "|.|_|...||..._...||.|.|...||...._..|._____|.|...............";
echo "|_______||__|.|__||_|..|__||___|.|_||_______|...............";
echo ".______...__...__..__...._.._______..__...__..___..._______.";
echo "|......|.|..|.|..||..|..|.||..._...||..|_|..||...|.|.......|";
echo "|.._....||..|_|..||...|_|.||..|_|..||.......||...|.|.......|";
echo "|.|.|...||.......||.......||.......||.......||...|.|.......|";
echo "|.|_|...||_....._||.._....||.......||.......||...|.|......_|";
echo "|.......|..|...|..|.|.|...||..._...||.||_||.||...|.|.....|_.";
echo "|______|...|___|..|_|..|__||__|.|__||_|...|_||___|.|_______|";
echo "._______.._______.._______.._______.._______................";
echo "|.......||..._...||.......||.......||.......|...............";
echo "|....___||..|_|..||...._..||...._..||.._____|...............";
echo "|...|.__.|.......||...|_|.||...|_|.||.|_____................";
echo "|...||..||.......||....___||....___||_____..|...............";
echo "|...|_|.||..._...||...|....|...|....._____|.|...............";
echo "|_______||__|.|__||___|....|___|....|_______|...............";

# Define paths && variables
APPDIRS="dynamic/FaceLock/arm/app/FaceLock
         dynamic/FaceLock/arm64/app/FaceLock
         dynamic/GoogleTTS/arm/app/GoogleTTS
         dynamic/GoogleTTS/x86/app/GoogleTTS
         dynamic/PrebuiltGmsCore/arm/priv-app/PrebuiltGmsCore
         dynamic/PrebuiltGmsCore/arm64/priv-app/PrebuiltGmsCore
         dynamic/PrebuiltGmsCore/x86/priv-app/PrebuiltGmsCore
         dynamic/PrebuiltGmsCore/x86_64/priv-app/PrebuiltGmsCore
         dynamic/SetupWizard/phone/priv-app/SetupWizard
         dynamic/SetupWizard/tablet/priv-app/SetupWizard
         dynamic/Velvet/arm/priv-app/Velvet
         dynamic/Velvet/arm64/priv-app/Velvet
         dynamic/Velvet/x86/priv-app/Velvet
         system/app/ChromeBookmarksSyncAdapter
         system/app/GoogleCalendarSyncAdapter
         system/app/GoogleContactsSyncAdapter
         system/priv-app/GoogleBackupTransport
         system/priv-app/GoogleFeedback
         system/priv-app/GoogleLoginService
         system/priv-app/GoogleOneTimeInitializer
         system/priv-app/GooglePartnerSetup
         system/priv-app/GoogleServicesFramework
         system/priv-app/HotwordEnrollment
         system/priv-app/Phonesky"
TOOLSDIR=$(realpath .)/tools
GAPPSDIR=$(realpath .)/files
FINALDIR=$(realpath .)/out
ZIPNAME1TITLE=BaNkS_Dynamic_GApps
ZIPNAME1VERSION=6.x.x
ZIPNAME1DATE=$(date +%-m-%-e-%-y)_$(date +%H:%M)
ZIPNAME2TITLE=BANKS_GAPPS
ZIPNAME2VERSION=6.XX
ZIPNAME1="$ZIPNAME1TITLE"_"$ZIPNAME1VERSION"_"$ZIPNAME1DATE".zip
ZIPNAME2="$ZIPNAME2TITLE"_"$ZIPNAME2VERSION".zip

dcapk() {
TARGETDIR=$(realpath .)
TARGETAPK=$TARGETDIR/$(basename "$TARGETDIR").apk
  unzip -q -o "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -q -d "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -q -r -D -Z store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -f -p 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -rf "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +%s)

# Begin the magic
export PATH=$TOOLSDIR:$PATH

for dirs in $APPDIRS; do
  cd "$GAPPSDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

cd "$GAPPSDIR"
7za a -tzip -r "$ZIPNAME1" ./* > /dev/null
mv -f "$ZIPNAME1" "$TOOLSDIR"
cd "$TOOLSDIR"
java -Xmx2048m -jar signapk.jar -w testkey.x509.pem testkey.pk8 "$ZIPNAME1" "$ZIPNAME1".signed
rm -f "$ZIPNAME1"
zipadjust "$ZIPNAME1".signed "$ZIPNAME1".fixed > /dev/null
rm -f "$ZIPNAME1".signed
java -Xmx2048m -jar minsignapk.jar testkey.x509.pem testkey.pk8 "$ZIPNAME1".fixed "$ZIPNAME1"
rm -f "$ZIPNAME1".fixed
mv -f "$ZIPNAME1" "$FINALDIR"
cp -f "$FINALDIR"/"$ZIPNAME1" "$FINALDIR"/"$ZIPNAME2"

# Define ending time
END=$(date +%s)

# All done
echo " "
echo "All done creating GApps!"
echo "Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}') ($(echo "$END - $BEGIN" | bc) seconds)"
echo "Completed GApp zips are located in the '$FINALDIR' directory"
cd
