#!/usr/bin/env bash

USAGE="
$0 [iOS/OSX SDK Version] [Configuration]

Valid versions are
  7.0
  6.1
  6.0
 10.8
  all

Valid configurations are
  Release
  Debug [default]
"

function print_build_status
{
  status="$1"
  build_name="$2"

  [ "$status" == "0" ] && echo "$build_name SUCCEEDED" || echo "$build_name FAILED"
}

configuration="Debug"
[ "$2" == "release" ] && configuration="Release"
[ "$2" == "Release" ] && configuration="Release"

case "$1" in
  "10.8")
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxCocoaSDK -sdk macosx10.8 -configuration $configuration clean build test
    ;;
  "7.0")
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator7.0 -destination OS=7.0,name='iPhone Retina (4-inch)' -configuration $configuration clean build test
    ;;
  "6.0")
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator6.0 -destination OS=6.1,name=iPhone -configuration $configuration clean build test
    ;;
  "6.1")
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator6.1 -destination OS=6.1,name=iPhone -configuration $configuration clean build test
    ;;
  "all")
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator6.0 -destination OS=6.1,name=iPhone -configuration $configuration clean build test
    build_status_60=$?
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator6.1 -destination OS=6.1,name=iPhone -configuration $configuration clean build test
    build_status_61=$?
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxSDK -sdk iphonesimulator7.0 -destination OS=7.0,name='iPhone Retina (4-inch)' -configuration $configuration clean build test
    build_status_70=$?
    xcodebuild -project BoxSDK.xcodeproj/ -scheme BoxCocoaSDK -sdk macosx10.8 -configuration $configuration clean build test
    build_status_108=$?

    print_build_status "$build_status_60" "iOS 6.0"
    print_build_status "$build_status_61" "iOS 6.1"
    print_build_status "$build_status_70" "iOS 7.0"
    print_build_status "$build_status_108" "OSX 10.8"

    [ "$build_status_60" == "0" ] || exit 1
    [ "$build_status_61" == "0" ] || exit 1
    [ "$build_status_70" == "0" ] || exit 1
    [ "$build_status_108" == "0" ] || exit 1

    echo "ALL SYSTEMS GO! LAUNCH!! LAUNCH!! LAUNCH!!"

    ;;
  *)
    echo "${USAGE}"
    exit 255
esac

