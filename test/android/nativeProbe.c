#include <jni.h>
#include <stdio.h>
#include "nativeProbe.h"

extern void MsMain(void);

static float frameLeft;
static float frameTop;
static float frameWidth;
static float frameHeight;

void yogaProbeReportFrame(float left, float top, float width, float height) {
	frameLeft = left;
	frameTop = top;
	frameWidth = width;
	frameHeight = height;
}

JNIEXPORT jstring JNICALL Java_dev_metascript_yoga_probe_Native_measure(JNIEnv *env, jclass cls) {
	(void)cls;
	MsMain();
	char result[64];
	snprintf(result, sizeof(result), "%.0f,%.0f,%.0f,%.0f", frameLeft, frameTop, frameWidth, frameHeight);
	return (*env)->NewStringUTF(env, result);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
	(void)vm;
	(void)reserved;
	return JNI_VERSION_1_6;
}
