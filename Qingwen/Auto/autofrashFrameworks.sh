#!/bin/bash

function helpFunc()
{
  echo ""
  echo "  -h 显示这个帮助信息"
  # echo "  -c Debug或者Release,默认是0是all, 1是Debug, 2是Release"
  echo "  -r clean工程再编译写1，不clean写0，默认为clean"
  echo "  -s 设置sdk  如：8.0,   8.1, 默认为latest sdk"
  # echo "  -b 是否build，0不编译，默认为1（全平台编译），2编译模拟器，3编译真机"
  echo "  -j 设置编译线程数，默认为8"
  echo "  -w 设置workspace,不设置默认取当前目录中的Wodogs.xcworkspace"
  echo "  "
}

scheme="Qingwen"
job=8
clean_project=1  #默认clean 
configuration="Debug"
sdk=""
build_project=1 #是否build

#处理参数  
while getopts :b:s:c:r:j:h opt
do
  case $opt in
    s)
      sdk=$OPTARG
      ;;
    b)
      build_project=$OPTARG
      ;;
    c)
      configuration=$OPTARG
      ;; 
    r)
      clean_project=$OPTARG
      ;;
    j)
      job=$OPTARG
      ;;
    h)
      helpFunc;
      exit 1
      ;;
    ?)
      helpFunc;
      exit 1
      ;;
    :)
    
#echo $LINE
  helpFunc;
      exit 1
      ;;
  esac
done

iphonesdk=`echo iphoneos"$sdk"`
iphonesimulatorsdk=`echo iphonesimulator"$sdk"`

DIR=`pwd`

WORKSPACE_DIR=$DIR/../Qingwen.xcworkspace

PRODUCTS_DIR_TEMP=`xcodebuild -workspace $WORKSPACE_DIR -scheme $scheme -sdk $iphonesimulatorsdk -showBuildSettings | grep -w BUILD_DIR | head -n 1`

PRODUCTS_DIR=${PRODUCTS_DIR_TEMP:15}

FRAMEWORK_DIR=$DIR/../Qingwen/Build

#clean
if [[ $clean_project = "1" ]];then

#开始clean
xcodebuild clean -workspace $WORKSPACE_DIR -scheme $scheme -sdk $iphonesimulatorsdk

xcodebuild clean -workspace $WORKSPACE_DIR -scheme $scheme -sdk $iphonesdk

fi

#build

#iphonesimulator debug
xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesimulatorsdk\
                 -configuration "Debug" -jobs $job

#iphonesimulator release
# xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesimulatorsdk\
#                  -configuration "Release" -jobs $job

#iphoneos debug
xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesdk\
                 -configuration "Debug" -jobs $job

#iphoneos release
xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesdk\
                 -configuration "Release" -jobs $job

# if [[ $build_project = "1" ]];then

# #armv7,iphoneos
# xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesdk\
#                  -configuration $configuration -jobs $job

# #i386,iphonesimulator
# xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesimulatorsdk\
#                  -configuration $configuration -jobs $job

# elif [[ $build_project = "2" ]]; then

# #i386,iphonesimulator
# xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesimulatorsdk\
#                  -configuration $configuration -jobs $job

# elif [[ $build_project = "3" ]]; then

# #armv7,iphoneos
# xcodebuild build -workspace $WORKSPACE_DIR ONLY_ACTIVE_ARCH=NO -scheme $scheme -sdk $iphonesdk\
#                  -configuration $configuration -jobs $job

# fi

function mkdirWhenNotFound()
{
  folder_path=$1
  if [ ! -d $folder_path ]; then
    mkdir $folder_path
  fi
}

#copy frameworks
rm -rf $FRAMEWORK_DIR
mkdirWhenNotFound $FRAMEWORK_DIR
cp -RLp $PRODUCTS_DIR $FRAMEWORK_DIR
