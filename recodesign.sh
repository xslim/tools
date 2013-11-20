#!/bin/sh

IP=`ipconfig getifaddr en0`
HOST="http://ipa.${IP}.xip.io"
CODESIGN_CERT="iPhone Distribution:"

SAVEDIR=`pwd`
WORKDIR=/tmp/ipa_$RANDOM$RANDOM
WORKIPA=/tmp/ipa_$RANDOM$RANDOM.ipa
IPA_FILE=$1

echo unpacking $1
mkdir -p $WORKDIR
unzip "$1" -d $WORKDIR  > /dev/null || exit
cd $WORKDIR
#cd Payload

SAVEIFS=$IFS
IFS=$'\n'

#pwd
#ls

#for f in $( ls Payload ); do
#find . -maxdepth 1 -type d | while read name ; do
for f in $(find Payload -mindepth 1 -maxdepth 2 -type d); do
	
	echo Processing "$f"
	rm -rf "$f"/_CodeSignature
	cat >"$f"/ResourceRules.plist <<XXX
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>rules</key>
	<dict>
		<key>.*</key>
		<true/>
		<key>Info.plist</key>
		<dict>
			<key>omit</key>
			<true/>
			<key>weight</key>
			<real>10</real>
		</dict>
		<key>ResourceRules.plist</key>
		<dict>
			<key>omit</key>
			<true/>
			<key>weight</key>
			<real>100</real>
		</dict>
	</dict>
</dict>
</plist>
XXX
	codesign -f -s "$CODESIGN_CERT" -vvv "$f"
done

IFS=$SAVEIFS

echo Generating OTA info
cd "$WORKDIR"
cd "$(find Payload -mindepth 1 -maxdepth 1 -type d)"

IPABundleIdentifier=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" Info.plist`
IPABundleExecutable=`/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" Info.plist`
IPABundleVersion=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Info.plist`

cd $SAVEDIR
MANIFEST_FILE="${IPABundleExecutable}.plist"
cat >"$MANIFEST_FILE" <<XXX
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>${HOST}/${IPA_FILE}</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>${IPABundleIdentifier}</string>
				<key>bundle-version</key>
				<string>${IPABundleVersion}</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>${IPABundleExecutable}</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
XXX

echo "<a href=\"itms-services://?action=download-manifest&url=${HOST}/${IPABundleExecutable}.plist\">Install OTA</a>" > "${IPABundleExecutable}.html"

echo repacking
cd $WORKDIR
zip -9yr $WORKIPA * > /dev/null
cd $SAVEDIR && mv "$1" "$1.$RANDOM$RANDOM.bak" && mv $WORKIPA "$1" && rm -rf $WORKIPA
