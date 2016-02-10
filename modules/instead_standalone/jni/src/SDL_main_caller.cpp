#ifdef __ANDROID__

#include "Rotator.h"
#include <SDL.h>
#include <jni.h>

Rotator* pRotator;

extern "C" void rotate_portrait() {
    if (pRotator) {
        pRotator->rotate_portrait();
    }
}

extern "C" void rotate_landscape() {
    if (pRotator) {
        pRotator->rotate_landscape();
    }
}

extern "C" JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jobject array);

/* Start up the SDL app */
extern "C" JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInitMain(JNIEnv* env, jclass cls, jobject obj, jobject array)
{
    int status;
    pRotator = new Rotator(env, cls, obj);
    
    status = Java_org_libsdl_app_SDLActivity_nativeInit(env, cls, array);
    
    delete pRotator;

    // Kill it with fire, or else we'll get the error when restarting the activity
    exit(status);

    return status;
}

#endif /* __ANDROID__ */

/* vi: set ts=4 sw=4 expandtab: */
