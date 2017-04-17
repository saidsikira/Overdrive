#!/bin/sh

set -o errexit
set -o errtrace
set -o pipefail

PROJECT="Overdrive.xcodeproj"
SCHEME="Overdrive"

IOS_SDK="iphonesimulator10.3"
OSX_SDK="macosx10.12"
TVOS_SDK="appletvsimulator10.2"
WATCHOS_SDK="watchsimulator3.1"

IOS_DESTINATION="OS=10.3,name=iPhone 7"
MACOS_DESTINATION="arch=x86_64"
TVOS_DESTINATION="OS=10.2,name=Apple TV 1080p"
WATCHOS_DESTINATION="OS=10.1,name=iPhone SE"

usage() {
cat << EOF
Usage: sh $0 command

  [Building]

  iOS           Build iOS framework
  watchOS       Build watchOS framework
  macOS         Build macOS framework
  tvOS          Build tvOS framework
  build         Builds all iOS/macOS/tvOS/watchOS targets
  clean         Clean up all un-neccesary files

  [Testing]

  test-iOS      Run tests on iOS host
  test-macOS    Run tests on macOS host
  test-tvOS     Run tests on tvOS target
  test-native   Run Swift tests without Xcode
  test          Runs full test suite on all supported hosts

  [Docs]

  docs          Build documentation using jazzy
EOF
}

COMMAND="$1"

case "$COMMAND" in
  "clean")
    find . -type d -name build -exec rm -r "{}" +\;
    exit 0;
  ;;

  "docs")
    jazzy \
    --author "Swiftable" \
    --author_url "swiftable.io" \
    --theme fullwidth \
    --github_url "https://github.com/arikis/Overdrive" \
    --readme "./README.md"
    exit 0;
  ;;

  "iOS" | "ios")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${IOS_SDK}" \
    -destination "${IOS_DESTINATION}" \
    -configuration Debug ONLY_ACTIVE_ARCH=YES \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
    build | xcpretty -c
    exit 0;
  ;;

  "watchOS" | "watchos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -destination "${IOS_DESTINATION}" \
    -configuration Debug ONLY_ACTIVE_ARCH=YES \
    build | xcpretty -c
    exit 0;
  ;;

  "macOS" | "macos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${MACOS_SDK}" \
    -destination "${MACOS_DESTINATION}" \
    -configuration Debug ONLY_ACTIVE_ARCH=YES \
    build | xcpretty -c
    exit 0;
  ;;

  "tvOS" | "tvos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${TVOS_SDK}" \
    -destination "${TVOS_DESTINATION}" \
    -configuration Debug ONLY_ACTIVE_ARCH=YES \
    build | xcpretty -c
    exit 0;
  ;;

  "build")
    sh $0 iOS
    sh $0 macOS
    sh $0 tvOS
    exit 0;
  ;;

  "test-iOS" | "test-ios")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${IOS_SDK}" \
    -destination "${IOS_DESTINATION}" \
    -configuration Release \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    ENABLE_TESTABILITY=YES \
    build test | xcpretty -c
    exit 0;
  ;;

  "--test-macOS" | "test-macos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${MACOS_SDK}" \
    -destination "${MACOS_DESTINATION}" \
    -configuration Release \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    ENABLE_TESTABILITY=YES \
    build test | xcpretty -c
    exit 0;
  ;;

  "--test-tvOS" | "test-tvos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -sdk "${TVOS_SDK}" \
    -destination "${TVOS_DESTINATION}" \
    -configuration Release \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    ENABLE_TESTABILITY=YES \
    build test | xcpretty -c
    exit 0;
  ;;

  "--test-watchOS" | "test-watchos")
    xcodebuild clean \
    -project $PROJECT \
    -scheme "${SCHEME}" \
    -destination "${WATCHOS_DESTINATION}" \
    -configuration Release \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    ENABLE_TESTABILITY=YES \
    build test | xcpretty -c
    exit 0;
  ;;

  "--test-native" | "test-native")
    swift package clean
    swift build
    swift test
    exit 0;
  ;;

  "test")
    sh $0 test-iOS
    sh $0 test-macOS
    sh $0 test-tvOS
    sh $0 test-native
    exit 0;
  ;;
esac

usage
