#!/bin/sh
SAVEDIR=`pwd`
WORKDIR=/tmp/ipa_$RANDOM$RANDOM
WORKIPA=/tmp/ipa_$RANDOM$RANDOM.ipa

echo unpacking $1
mkdir -p $WORKDIR
unzip "$1" -d $WORKDIR  > /dev/null || exit
cd $WORKDIR
for f in $( ls Payload ); do
	echo Processing $f
	rm -rf Payload/$f/_CodeSignature
	cat >Payload/$f/ResourceRules.plist <<XXX
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
	codesign -f -s "iPhone Developer" -vvv Payload/$f
done
echo repacking
zip -9yr $WORKIPA * > /dev/null
cd $SAVEDIR && mv "$1" "$1.$RANDOM$RANDOM.bak" && mv $WORKIPA "$1" && rm -rf $WORKIPA