#include "Rotator.h"
#include <SDL.h>
#include <jni.h>

extern "C" JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jobject array);

/* Start up the SDL app */
extern "C" JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInitMain(JNIEnv* env, jclass cls, jobject array)
{
    int status;
    Rotator* pRotator = new Rotator(env, cls);
    
    status = Java_org_libsdl_app_SDLActivity_nativeInit(env, cls, array);
    
    delete pRotator;

    // Kill it with fire, or else we'll get the error when restarting the activity
    exit(status);

    return status;
}