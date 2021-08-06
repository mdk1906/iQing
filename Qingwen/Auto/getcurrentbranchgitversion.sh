#!/bin/bash

#branchName=`git rev-parse --abbrev-ref HEAD`
#appBuild=`"git rev-parse --short HEAD`

time=`date +%Y%m%d%H%M`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $time" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

#if [ "$CONFIGURATION" == "Debug" ] ; then
#/usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity:NSAllowsArbitraryLoads" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
#/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
#fi

