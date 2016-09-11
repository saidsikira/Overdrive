#!/bin/sh

set -o errexit
set -o errtrace
set -o pipefail

PROJECT="Overdrive.xcodeproj"
SCHEME="Overdrive"

IOS_SDK="iphonesimulator10.0"
OSX_SDK="macosx10.11"
TVOS_SDK="appletvsimulator10.0"

IOS_DESTINATION="OS=10.0,name=iPhone 6S"
MACOS_DESTINATION="arch=x86_64"
TVOS_DESTINATION="OS=10.0,name=Apple TV 1080p"

usage() {
cat << EOF
Usage: sh $0 command

	--docs		Build documentation using jazzy
	--clean		Clean up all un-neccesary files
	--all		Builds all iOS/macOS/tvOS/watchOS targets
	--test		Runs full tests
	--iOS		Build iOS target
	--macOS		Build macOS target
	--tvOS		Build tvOS target
	--test-iOS	Test iOS target
	--test-macOS	Test macOS target
	--test-tvOS	Test tvOS target
EOF
}

COMMAND="$1"

case "$COMMAND" in
	"--clean")
		find . -type d -name build -exec rm -r "{}" +\;
		exit 0;
	;;

	"--docs")
		jazzy \
		--clean \
		--author "Swiftable" \
		--author_url "swiftable.io" \
		--theme fullwidth \
		--swift-version 2.2 \
		--github_url "https://github.com/swiftable/Overdrive" \
		--readme "./README.md"
		exit 0;
	;;

	"--iOS")
		xcodebuild clean -project $PROJECT -scheme "${SCHEME}" -sdk "${IOS_SDK}" -destination "${IOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES build | xcpretty -c
		exit 0;
	;;
	
	"--macOS")
		xcodebuild clean -project $PROJECT -scheme "${SCHEME}" -sdk "${MACOS_SDK}" -destination "${MACOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES build | xcpretty -c
		exit 0;
	;;

	"--tvOS")
		xcodebuild clean -project $PROJECT -scheme "${SCHEME}" -sdk "${TVOS_SDK}" -destination "${TVOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES build | xcpretty -c
		exit 0;
	;;

	"--all")
		sh $0 --iOS
		sh $0 --macOS
		sh $0 --tvOS
		exit 0;
	;;

	"--test-iOS")
		xcodebuild clean -project $PROJECT -scheme "${IOS_SCHEME}" -sdk "${IOS_SDK}" -destination "${IOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES test | xcpretty -c
		exit 0;
	;;

    "--test-macOS")
    xcodebuild clean -project $PROJECT -scheme "${MACOS_SCHEME}" -sdk "${MACOS_SDK}" -destination "${MACOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES test | xcpretty -c
    exit 0;
    ;;

    "--test-tvOS")
    xcodebuild clean -project $PROJECT -scheme "${TVOS_SCHEME}" -sdk "${TVOS_SDK}" -destination "${TVOS_DESTINATION}" -configuration Debug ONLY_ACTIVE_ARCH=YES test | xcpretty -c
    exit 0;
    ;;

    "--test")
        sh $0 --test-iOS
        sh $0 --test-macOS
        sh $0 --test-tvOS
        exit 0;
    ;;
esac
usage
