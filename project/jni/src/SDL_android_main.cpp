/*
    SDL_android_main.c, placed in the public domain by Sam Lantinga  3/13/14
    Converted to cpp by Anton P. Kolosov because of compilation errors otherwise
*/
/* Include the SDL main definition header */
#include "SDL_main.h"

/*******************************************************************************
                 Functions called by JNI
*******************************************************************************/
#include <jni.h>
#include <unistd.h>
#include <android/log.h>

/* Called before SDL_main() to initialize JNI bindings in SDL library */
extern "C" void SDL_Android_Init(JNIEnv* env, jclass cls);

extern "C" void Java_com_nlbhub_instead_SDLActivity_nativePipeSTDOUTToLogcat(JNIEnv* env, jclass cls)
{
    int pipes[2];
    pipe(pipes);
    dup2(pipes[1], STDOUT_FILENO);
    FILE *inputFile = fdopen(pipes[0], "r");
    char readBuffer[256];
    while (1) {
        fgets(readBuffer, sizeof(readBuffer), inputFile);
        __android_log_write(ANDROID_LOG_INFO, "stdout", readBuffer);
    }
    /*
    Stuff to add in Java:
    class STDOUTLog implements Runnable {
    	public void run() {
    		SDLActivity.nativePipeSTDOUTToLogcat();
    	}
    }
    public static native void nativePipeSTDOUTToLogcat();

    int lWriteFD = dup(STDOUT_FILENO);

    if ( lWriteFD < 0 ) {
        // WE failed to get our file descriptor
        LOGE("Unable to get STDOUT file descriptor.");
        return;
    }

    int pipes[2];
    pipe(pipes);
    dup2(pipes[1], STDOUT_FILENO);
    FILE *inputFile = fdopen(pipes[0], "r");

    close(pipes[1]);

    int fd = fileno(inputFile);
    int flags = fcntl(fd, F_GETFL, 0);
    flags |= O_NONBLOCK;
    fcntl(fd, F_SETFL, flags);

    if ( nullptr == inputFile )
    {
        LOGE("Unable to get read pipe for STDOUT");
        return;
    }

    char readBuffer[256];

    while (true == mKeepRunning)
    {
        fgets(readBuffer, sizeof(readBuffer), inputFile);

        if ( strlen(readBuffer) == 0 )
        {
           sleep(1);
           continue;
        }

        __android_log_write(ANDROID_LOG_ERROR, "stdout", readBuffer);
    }

    close(pipes[0]);
    fclose(inputFile);*/
}

/* Start up the SDL app */
extern "C" void Java_com_nlbhub_instead_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jstring jpath, jstring jappdata, jstring jgamespath, jstring jres, jstring jgame, jstring jidf)
{
    /* This interface could expand with ABI negotiation, calbacks, etc. */
    SDL_Android_Init(env, cls);

    SDL_SetMainReady();

    /* Run the application code! */
    int status;
    char *argv[10];
    int n = 1;
    if (jpath != NULL) {
        const char *path = env->GetStringUTFChars(jpath, 0);
        chdir(SDL_strdup(path));
        env->ReleaseStringUTFChars(jpath, path);
    }

    argv[0] = SDL_strdup("sdl-instead");

    if (jres != NULL) {
        const char *res = env->GetStringUTFChars(jres, 0);
        n = 3;
        argv[1] = SDL_strdup("-mode");
        argv[2] = SDL_strdup(res);
        env->ReleaseStringUTFChars(jres, res);
        if (jappdata != NULL) {
            const char *appdata = env->GetStringUTFChars(jappdata, 0);
            argv[n++] = SDL_strdup("-appdata");
            argv[n++] = SDL_strdup(appdata);
            env->ReleaseStringUTFChars(jappdata, appdata);
        }
        if (jgamespath != NULL) {
            const char *gamespath = env->GetStringUTFChars(jgamespath, 0);
            argv[n++] = SDL_strdup("-gamespath");
            argv[n++] = SDL_strdup(gamespath);
            env->ReleaseStringUTFChars(jgamespath, gamespath);
        }
        if (jidf != NULL) {
            const char *idf = env->GetStringUTFChars(jidf, 0);
            argv[n++] = SDL_strdup(idf);
            env->ReleaseStringUTFChars(jidf, idf);
        } else if (jgame != NULL) {
            const char *game = env->GetStringUTFChars(jgame, 0);
            argv[n++] = SDL_strdup("-game");
            argv[n++] = SDL_strdup(game);
            env->ReleaseStringUTFChars(jgame, game);
        }
        argv[n] = NULL;
    } else {
        argv[1] = NULL;
    }

    status = SDL_main(n, argv);

/*
No freeing in initial SDL_android_main.c
    int i;
    for (i = 0; i < n; ++i) {
        free(argv[i]);
    }
*/

    /* Do not issue an exit or the whole application will terminate instead of just the SDL thread */
    /* exit(status); */
}

/* vi: set ts=4 sw=4 expandtab: */
