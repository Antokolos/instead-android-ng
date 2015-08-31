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
#include <pthread.h>
#include <android/log.h>

/* Called before SDL_main() to initialize JNI bindings in SDL library */
extern "C" void SDL_Android_Init(JNIEnv* env, jclass cls);

/*
 * https://codelab.wordpress.com/2014/11/03/how-to-use-standard-output-streams-for-logging-in-android-apps/
 */

static int pfd[2];
static pthread_t thr;
static const char *tag = "Instead-NG";
static FILE *logFile;

static void *thread_func(void*) {
    ssize_t rdsz;
    char buf[128];
    while((rdsz = read(pfd[0], buf, sizeof buf - 1)) > 0) {
        if(buf[rdsz - 1] == '\n') --rdsz;
        buf[rdsz - 1] = 0;  /* add null-terminator */
        __android_log_write(ANDROID_LOG_DEBUG, tag, buf);
        if (logFile != NULL) {
            fprintf(logFile, "%s\n", buf);
        }
        fflush(logFile);
        usleep(50000);
    }
    return 0;
}

int start_logger(const char *app_name) {
    tag = app_name;

    /* make stdout line-buffered and stderr unbuffered */
    setvbuf(stdout, 0, _IOLBF, 0);
    setvbuf(stderr, 0, _IONBF, 0);

    /* create the pipe and redirect stdout and stderr */
    pipe(pfd);
    dup2(pfd[1], 1);
    dup2(pfd[1], 2);

    /* spawn the logging thread */
    if(pthread_create(&thr, 0, thread_func, 0) == -1)
        return -1;
    pthread_detach(thr);
    return 0;
}

/* Start up the SDL app */
extern "C" void Java_com_nlbhub_instead_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jstring jpath, jstring jappdata, jstring jgamespath, jstring jres, jstring jgame, jstring jidf) {

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
        logFile = fopen("native.log", "a");
        start_logger("INSTEAD-Native");
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
    if (logFile != NULL) {
        fclose(logFile);
    }

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
