/*
    SDL_android_main.c, placed in the public domain by Sam Lantinga  3/13/14
    Converted to cpp by Anton P. Kolosov because of compilation errors otherwise
*/
/* Include the SDL main definition header */
#include <SDL.h>
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
    char buf[512];
    while((rdsz = read(pfd[0], buf, sizeof buf - 1)) > 0) {
        if(buf[rdsz - 1] == '\n') --rdsz;
        buf[rdsz] = 0;  /* add null-terminator */
        __android_log_write(ANDROID_LOG_DEBUG, tag, buf);
        if (logFile != NULL) {
            fprintf(logFile, "%s\n", buf);
        }
        fflush(logFile);
        usleep(500000);
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
extern "C" void Java_com_nlbhub_instead_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jstring jnativelog, jstring jpath, jstring jappdata, jstring jgamespath, jstring jres, jstring jgame, jstring jidf) {

    if (jnativelog != NULL) {
        const char *nativelog = env->GetStringUTFChars(jnativelog, 0);
        logFile = fopen(nativelog, "w");
        start_logger("INSTEAD-Native");
        env->ReleaseStringUTFChars(jnativelog, nativelog);
    }
    
    /* This interface could expand with ABI negotiation, calbacks, etc. */
    SDL_Android_Init(env, cls);

    SDL_SetMainReady();

    /* Run the application code! */
    int status;
    char *argv[10];
    int n = 1;
    if (jpath != NULL) {
        const char *path = env->GetStringUTFChars(jpath, 0);
        printf("path = %s\n", path);
        chdir(SDL_strdup(path));
        env->ReleaseStringUTFChars(jpath, path);
    }

    argv[0] = SDL_strdup("sdl-instead");

    if (jres != NULL) {
        const char *res = env->GetStringUTFChars(jres, 0);
        printf("res = %s\n", res);
        n = 3;
        argv[1] = SDL_strdup("-mode");
        argv[2] = SDL_strdup(res);
        env->ReleaseStringUTFChars(jres, res);
        if (jappdata != NULL) {
            const char *appdata = env->GetStringUTFChars(jappdata, 0);
            printf("appdata = %s\n", appdata);
            argv[n++] = SDL_strdup("-appdata");
            argv[n++] = SDL_strdup(appdata);
            env->ReleaseStringUTFChars(jappdata, appdata);
        }
        if (jgamespath != NULL) {
            const char *gamespath = env->GetStringUTFChars(jgamespath, 0);
            printf("gamespath = %s\n", gamespath);
            argv[n++] = SDL_strdup("-gamespath");
            argv[n++] = SDL_strdup(gamespath);
            env->ReleaseStringUTFChars(jgamespath, gamespath);
        }
        if (jidf != NULL) {
            const char *idf = env->GetStringUTFChars(jidf, 0);
            printf("idf = %s\n", idf);
            argv[n++] = SDL_strdup(idf);
            env->ReleaseStringUTFChars(jidf, idf);
        } else if (jgame != NULL) {
            const char *game = env->GetStringUTFChars(jgame, 0);
            printf("game = %s\n", game);
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

extern "C" void Java_com_nlbhub_instead_SDLActivity_toggleMenu(JNIEnv* env, jclass cls) {
    printf("Menu toggle command issued\n");
    SDL_Event event;

    memset(&event, 0, sizeof(event));
    event.key.type = SDL_KEYDOWN;
    //event.timestamp = lastEvent.timestamp + 1; -- don't know what to set here, but works fine as is
    //event.windowID = lastEvent.windowID; -- don't know what to set here, but works fine as is
    event.key.state = SDL_PRESSED;

    event.key.keysym.scancode = SDL_SCANCODE_ESCAPE; // from SDL_Keysym
    event.key.keysym.sym = SDLK_ESCAPE;
    event.key.keysym.mod = 0; // from SDL_Keymod

    SDL_PushEvent(&event); // Inject key press of the Escape Key
}

/* vi: set ts=4 sw=4 expandtab: */
