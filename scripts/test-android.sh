#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
NDK="$SDK/ndk/28.0.13004108"
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/darwin-x86_64"
CC="$TOOLCHAIN/bin/aarch64-linux-android23-clang"
NM="$TOOLCHAIN/bin/llvm-nm"
READELF="$TOOLCHAIN/bin/llvm-readelf"
CXX_SHARED="$TOOLCHAIN/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so"
ADB="$SDK/platform-tools/adb"
ZIPALIGN="$SDK/build-tools/36.0.0/zipalign"
GRADLE="${GRADLE:-gradle}"
OUT="$ROOT/out/android"
DEBUG="$OUT/libyoga_probe_debug.so"
RELEASE="$OUT/libyoga_probe_release.so"
JNI_LIBS="$ROOT/test/android/app/src/main/jniLibs/arm64-v8a"
APK="$ROOT/test/android/app/build/outputs/apk/debug/app-debug.apk"

rm -rf "$ROOT/test/android/app/src/main/jniLibs"
mkdir -p "$OUT" "$JNI_LIBS"
msc build "$ROOT/test/android/layoutProbe.ms" --os=android --cpu=arm64 --app=lib --cc="$CC" --output="$DEBUG" --no-color
msc build "$ROOT/test/android/layoutProbe.ms" --os=android --cpu=arm64 --app=lib --cc="$CC" --release --strip --output="$RELEASE" --no-color

for library in "$DEBUG" "$RELEASE"; do
	if "$NM" -D --undefined-only "$library" | awk '$1 == "U" && $2 ~ /^YG/ { found = 1 } END { exit found ? 0 : 1 }'; then
		echo "unresolved Yoga symbol in $library" >&2
		exit 1
	fi
	for symbol in MsMain Java_dev_metascript_yoga_probe_Native_measure JNI_OnLoad; do
		if ! "$NM" -D --defined-only "$library" | awk -v wanted="$symbol" '$NF == wanted { found = 1 } END { exit found ? 0 : 1 }'; then
			echo "missing export $symbol in $library" >&2
			exit 1
		fi
	done
	if ! "$READELF" -lW "$library" | awk '$1 == "LOAD" { count += 1; if ($NF != "0x4000") bad = 1 } END { exit count > 0 && !bad ? 0 : 1 }'; then
		echo "non-16384-byte PT_LOAD alignment in $library" >&2
		exit 1
	fi
done

if "$READELF" -SW "$RELEASE" | awk '$2 == ".symtab" { found = 1 } END { exit found ? 0 : 1 }'; then
	echo "release library is not stripped" >&2
	exit 1
fi

cp "$DEBUG" "$JNI_LIBS/libyoga_probe.so"
cp "$CXX_SHARED" "$JNI_LIBS/libc++_shared.so"
"$GRADLE" -p "$ROOT/test/android" clean assembleDebug --no-daemon
"$ZIPALIGN" -c -P 16 -v 4 "$APK"
"$ADB" wait-for-device
"$ADB" logcat -c
"$ADB" install -r "$APK"
"$ADB" shell am force-stop dev.metascript.yoga.probe
"$ADB" shell am start -W -n dev.metascript.yoga.probe/.MainActivity
"$ADB" shell uiautomator dump /sdcard/yoga-probe.xml >/dev/null
UI="$($ADB exec-out cat /sdcard/yoga-probe.xml)"
case "$UI" in
	*"Yoga Android frame: 150,30,50,40"*) ;;
	*)
		echo "measured Yoga frame missing from Android UI" >&2
		exit 1
		;;
esac
CRASH="$($ADB logcat -d -b crash)"
case "$CRASH" in
	*dev.metascript.yoga.probe*)
		echo "Android probe crashed" >&2
		exit 1
		;;
esac

printf 'yoga-android PASS frame=150,30,50,40 debug=%s release=%s\n' "$(wc -c < "$DEBUG" | tr -d ' ')" "$(wc -c < "$RELEASE" | tr -d ' ')"
