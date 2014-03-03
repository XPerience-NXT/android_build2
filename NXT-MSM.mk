#!/bin/bash

# Import from paranoid
# Edit By klozz jesus

# get current path
reldir=`dirname $0`
cd $reldir
DIR=`pwd`

# Colorize and add text parameters
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
cya=$(tput setaf 6) # cyan
txtbld=$(tput bold) # Bold
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldblu=${txtbld}$(tput setaf 4) # blue
bldcya=${txtbld}$(tput setaf 6) # cyan
txtrst=$(tput sgr0) # Reset

THREADS="16"
DEVICE="$1"
SYNC="$2"
EXTRAS="$3"

VLINE=67
ADDON=packages/apps/HALO

if [ "xpe$DEVICE" == "xpe" ]
then
clear
   echo " "
   echo "==================================================="
   echo " "
   echo " XPerience Build Script for MSM devices"
   echo " --------------------------------------"
   echo " "
   echo " Please set the output path before use"
   echo " Use 'gedit anim' or 'vim anim' editing scripts"
   echo " The first $VLINE line, remove and set the path to the #!"
   echo " "
   echo " Usage: './xpe [Device] {Variable}'"
   echo " Device - The device name"
   echo " Variable - Parameter"
   echo " Parameters are as follows："
   echo " fix :If the last compilation error is encountered, then use this parameter to quickly compile"
   echo " clean :Execute the command 'make installclean' Before starting "
   echo " sync :Before starting the synchronization command to compile 'repo sync' "
   echo " "
   echo " For example './xpe grouper sync clean'"
   echo " It means' to compile grouper, and clean up before the start of the synchronization'"
   echo " "
   echo " Usage: './xpe [Device] {Variable}'"
   echo " Device - your device name"
   echo " Variable - functions"
   echo " fix :start build without any cleanning for fix build"
   echo " clean :run 'make installclean' before build"
   echo " sync :run 'repo sync' before build"
   echo " "
   echo " e.g './xpe grouper sync clean'"
   echo " "
   exit 0
fi

# if you set another OUT_DIR,set this before use.
OUT_DIR=/out/target/product/$DEVICE
if [ "xpe$OUT_DIR" == "xpe" ]
then
echo -e "请设置编译输出路径在该脚本的$VLINE行！"
   echo -e "please specify correct OUT_DIR in THIS SCRIPT at line $VLINE !"
   echo -e "especifique OUT_DIR correcto en este script en la línea $VLINE !"
   exit 0
elif [ ! -d "$OUT_DIR" ]
then
mkdir -p $OUT_DIR
fi

# we don't allow scrollback buffer
echo -e '\0033\0143'
clear

echo -e "${cya}Building ${bldcya}XPerience Project \n Script by Klozz Jesús\nFor MSM Devices\n${txtrst}";

# setup environment
echo -e "${bldblu}Setting up environment ${txtrst}"
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
# set ccache due to your disk space,set it at your own risk
prebuilts/misc/linux-x86/ccache/ccache -M 16G
. build/envsetup2.sh

# lunch device
echo -e ""
echo -e "${bldblu}Lunching device ${txtrst}"
lunch xpe_$DEVICE-userdebug

fix_count=0
# excute with vars
echo -e ""
for var in $* ; do
if [ "$var" == "sync" ]
then
echo -e "${bldblu}Fetching latest sources ${txtrst}"
   if [ -d "$ADDON" ]
   then
echo -e "fetching add-on repo"
      echo -e "change this at script line 28"
      cd $ADDON
      git pull
      cd $DIR
      echo -e "=============================================="
   fi
repo sync
   echo -e ""
elif [ "$var" == "clean" ]
then
echo -e "${bldblu}Clearing previous build info ${txtrst}"
   mka installclean
elif [ "$var" == "fix" ]
then
echo -e "skip for remove build.prop"
   fix_count=1
fi
done
if [ "$fix_count" == "0" ]
then
echo -e "removing build.prop"
   rm -f $OUT_DIR/system/build.prop
fi

echo -e ""
echo -e "${bldblu}Starting compilation ${txtrst}"

# get time of startup
res1=$(date +%s.%N)

# start compilation
mka bacon
echo -e ""

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

# make a alarm
echo $'\a'
