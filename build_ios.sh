#!/bin/sh

[[ ! -e $HOME/build_ios_local.sh ]] && {
	echo "File \"$HOME/build_ios_local.sh\" not found! Pls see 'build_ios_local.sh.sample'!!" 2>&1
	exit 1;
}
source $HOME/build_ios_local.sh

pwd | grep -q '[[:blank:]]' && {
	echo "Source path: $(pwd)"
	echo "Out of tree builds are impossible with whitespace in source path."
	exit 1;
}


DEST=`pwd`/build/ios
SOURCE=`pwd`
LIBRTMPDUMP=${SOURCE}/librtmp
SSL=${SOURCE}/../opensslmirror/build/ios
SSLINCLUDE=${SSL}/release/universal/include
SSLLIBS=${SSL}/release/universal/lib

export DEVRootReal="${DEVELOPER}/Platforms/iPhoneOS.platform/Developer"
export SDKRootReal="${DEVRootReal}/SDKs/iPhoneOS${SDKVERSION}.sdk"
export DEVRootSimulator="${DEVELOPER}/Platforms/iPhoneSimulator.platform/Developer"
export SDKRootSimulator="${DEVRootSimulator}/SDKs/iPhoneSimulator${SDKVERSION}.sdk"
export PATH=$HOME/bin:$PATH


#build_date=`date "+%Y%m%dT%H%M%S"`
build_date="built"
#build_versions="release debug"
build_versions="release"
build_archs="armv7 armv7s i386"
#build_archs="i386"
path_old=$PATH

for iver in $build_versions; do
	case $iver in
		release)	;;
		debug)		;;
	esac
	lipo_archs=
	for iarch in $build_archs; do
		case $iarch in
			arm*)
				export PATH=${DEVRootReal}/usr/bin:$path_old
				export CROSS_COMPILE=${DEVRootReal}/usr/bin/
				export XCFLAGS="-isysroot ${SDKRootReal} -I${SSLINCLUDE} -arch ${iarch}"
				export XLDFLAGS="-isysroot ${SDKRootReal} -L${SSLLIBS} -arch ${iarch} "
				;;
			i386)
				export PATH=${DEVRootSimulator}/usr/bin:$path_old
				export CROSS_COMPILE=${DEVRootSimulator}/usr/bin/
				export XCFLAGS="-isysroot ${SDKRootSimulator} -I${SSLINCLUDE} -arch ${iarch}"
				export XLDFLAGS="-isysroot ${SDKRootSimulator} -L${SSLLIBS} -arch ${iarch} "
				;;
		esac
		cd $LIBRTMPDUMP
		dist=${DEST}/$build_date/$iver/$iarch && mkdir -p ${dist}
		make SYS=darwin clean && make SYS=darwin librtmp.a && make SYS=darwin prefix=${dist} install_base
		lipo_archs="$lipo_archs $dist/lib/librtmp.a"
	done
	export PATH=${DEVRootReal}/usr/bin:$path_old
	src=${DEST}/$build_date/$iver/$iarch
	univs=${DEST}/$build_date/$iver/universal/ && mkdir -p $univs
	univslib=$univs/lib && mkdir -p $univslib
	univspkg=$univslib/pkgconfig && mkdir -p $univspkg
	cp -Rf ${src}/include $univs/
	sed -e "s|/$iarch|/universal|" ${src}/lib/pkgconfig/librtmp.pc > $univspkg/librtmp.pc
	lipo $lipo_archs -create -output $univslib/librtmp.a
	ranlib $univslib/librtmp.a
done


exit 0
