#!/bin/bash

# Main build script

# Predefined things
GIT_BINARY='git'

#http://github.com/baz/ios-build-scripts/raw/master/generate_manifest.py
MANIFEST_SCRIPT='/usr/local/bin/generate_manifest.py'

PP_USER_PATH="/Users/$USER/Library/MobileDevice/Provisioning Profiles"
CERTIFICATES_FILE="Certificates.p12"

function failed() {
    echo "Failed: $@" >&2
    exit 1
}

PROJECT_DIR=`dirname "$0"`
cd "$PROJECT_DIR"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="`basename -s .xcodeproj "${PROJECT_DIR}"`"

# Load Project config
. "${PROJECT_DIR}/build.config"


# Unlock keychain
if [ -f "${KEYCHAIN_LOCATION}" ]; then
	security list-keychains -s "${KEYCHAIN_LOCATION}" 
	security -v unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_LOCATION}"
	security -v default-keychain -s "${KEYCHAIN_LOCATION}"
fi

# Check if we have certificates
if [ ! -n `security find-identity -p codesigning -v | grep "${BUILD_IDENTITY}"` ]; then
	[ ! -f "${CERTIFICATES_FILE}" ] || failed "No Certificate found & p12 file to import not found"
	security import "${CERTIFICATES_FILE}" -k "${KEYCHAIN_LOCATION}" -A -P "${CERTIFICATES_PASSWORD}" || failed "Failed importing certificates"
fi



# For Hudson
if [ -n "${BUILD_NUMBER}" ]; then
	VERSION_BUILD="${BUILD_NUMBER}"
	if [ -n "${SVN_REVISION}" ]; then
		VERSION_BUILD="${VERSION_BUILD}-${SVN_REVISION}"
	fi
# For Git
elif [ -d ".git" ]; then
	VERSION_BUILD="$($GIT_BINARY log --pretty=format:'' | wc -l)-$($GIT_BINARY rev-parse --short HEAD)"
	VERSION_BUILD=${VERSION_BUILD//[[:space:]]}
else
	VERSION_BUILD=1
fi

#CFBundleVersion
agvtool new-version -all "${VERSION_BUILD}"

#CFBundleShortVersionString
if [ -n "${VERSION_SHORT}" ]; then
	agvtool new-marketing-version "${VERSION_SHORT}"
else
	# Assume we set manualy Short version as CFBuildNumber, so get it 
	BUILD_PLIST="${PROJECT_NAME}-Info.plist"
	VERSION_SHORT=$(/usr/libexec/PlistBuddy -c "Print CFBuildNumber" $BUILD_PLIST)
fi

VERSION_FULL="${VERSION_SHORT}-${VERSION_BUILD}"

[ "${APPEND_FILE_SUFFIX}" == "YES" ] || FILE_SUFFIX="-${VERSION_FULL}"

PP_FILE=`ls *.mobileprovision |tail -1` || failed "No provision found"

# Install the mobileprovision certificate
PP_PATH="${PROJECT_DIR}/${PP_FILE}"
PP_UDID=`grep "<key>UUID</key>" "${PP_PATH}" -A 1 --binary-files=text | sed -E -e "/<key>/ d" -e "s/(^.*<string>)//" -e "s/(< .*)//"` || failed "No UUID in provision profile found"
cp -Rfp "${PP_PATH}" "${PP_USER_PATH}/$PP_UUID.mobileprovision" || failed "Can't copy provision";


# Build project
#DSTROOT="${RELEASE_BUILD_ROOT}" SYMROOT="${RELEASE_BUILD_ROOT}" OBJROOT="${RELEASE_BUILD_ROOT}"
xcodebuild -sdk "${BUILD_SDK}" -configuration "${BUILD_CONFIGURATION}" clean || failed "Build clean failed"
xcodebuild -sdk "${BUILD_SDK}" -configuration "${BUILD_CONFIGURATION}" CODE_SIGN_IDENTITY="${BUILD_IDENTITY}" RUN_CLANG_STATIC_ANALYZER="${RUN_STATIC_ANALYZER}" GCC_TREAT_WARNINGS_AS_ERRORS=YES || failed "Build failed";

BUILD_DIRECTORY="$(pwd)/build/${BUILD_CONFIGURATION}-iphoneos"
cd "${BUILD_DIRECTORY}" || failed "Build directory does not exist."

MANIFEST_OUTPUT_HTML_FILENAME='index.html'
MANIFEST_OUTPUT_MANIFEST_FILENAME='manifest.plist'

if [ -n "${APPEND_VERSION}"]; then
	ROOT_DEPLOYMENT_ADDRESS="${ROOT_DEPLOYMENT_ADDRESS}/${VERSION_FULL}"
fi
echo "Will deploy to: $ROOT_DEPLOYMENT_ADDRESS"

for APP_FILENAME in *.app; do
	APP_NAME=$(echo "${APP_FILENAME}" | sed -e 's/.app//')
	IPA_FILENAME="${APP_NAME}${FILE_SUFFIX}.ipa"
	DSYM_FILEPATH="${APP_FILENAME}.dSYM"

	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP_FILENAME}" -o "${BUILD_DIRECTORY}/${IPA_FILENAME}" --sign "${BUILD_IDENTITY}" --embed "${PP_PATH}" || failed "Cannot Archive";

	
	# Output of this is index.html and manifest.plist
	"$MANIFEST_SCRIPT" -f "$APP_FILENAME" -o "$IPA_FILENAME" -d "$ROOT_DEPLOYMENT_ADDRESS/$MANIFEST_OUTPUT_MANIFEST_FILENAME" -c "$ROOT_DEPLOYMENT_ADDRESS"

	# Zip dSYM directory
	DSYM_ARCHIVE_FILENAME="${APP_NAME}_dsym${FILE_SUFFIX}.zip"
	zip -r "$DSYM_ARCHIVE_FILENAME" "$DSYM_FILEPATH" || failed "Failed zipping dsym"

	#QUOTE='"'
	#ssh $REMOTE_HOST "cd $REMOTE_PARENT_PATH; rm -rf ${QUOTE}$APP_NAME${QUOTE}/$GIT_HASH; mkdir -p ${QUOTE}$APP_NAME${QUOTE}/$GIT_HASH;"
	#scp "$PAYLOAD_FILENAME" "$REMOTE_HOST:$REMOTE_PARENT_PATH/${QUOTE}$APP_NAME${QUOTE}/$GIT_HASH"
	#ssh $REMOTE_HOST "cd $REMOTE_PARENT_PATH/${QUOTE}$APP_NAME${QUOTE}/$GIT_HASH; tar -xf $PAYLOAD_FILENAME; rm $PAYLOAD_FILENAME"

	# Copy to web server
	if [ -d "$WEB_DIR" ]; then
		APP_DEPLOY_DIR="$WEB_DIR/$WEB_BUILD_DIR/$APP_NAME/$VERSION_FULL"
		rm -rf "$APP_DEPLOY_DIR"
		mkdir -p "$APP_DEPLOY_DIR"
		cp "$IPA_FILENAME" "$DSYM_ARCHIVE_FILENAME" "$MANIFEST_OUTPUT_HTML_FILENAME" "$MANIFEST_OUTPUT_MANIFEST_FILENAME" "$APP_DEPLOY_DIR"

		# Clean up
		rm "$IPA_FILENAME"
		rm "$MANIFEST_OUTPUT_HTML_FILENAME"
		rm "$MANIFEST_OUTPUT_MANIFEST_FILENAME"
		rm "$DSYM_ARCHIVE_FILENAME"
	else
		APP_DEPLOY_DIR="$PROJECT_DIR/release"
		rm -rf "$APP_DEPLOY_DIR"
		mkdir -p "$APP_DEPLOY_DIR"
		mv "$IPA_FILENAME" "$DSYM_ARCHIVE_FILENAME" "$MANIFEST_OUTPUT_HTML_FILENAME" "$MANIFEST_OUTPUT_MANIFEST_FILENAME" "$APP_DEPLOY_DIR"
	fi


done

exit 0;