#include <SDL.h>
#include <jni.h>
#include <unistd.h>
#include <pthread.h>
#include <android/log.h>

/*
 * https://codelab.wordpress.com/2014/11/03/how-to-use-standard-output-streams-for-logging-in-android-apps/
 */

static int pfd[2];
static pthread_t thr;
static const char *tag = "Instead-NG";
static FILE *logFile;
int stopIssued = 0;
pthread_mutex_t stopMutex;

static int getStopIssued(void) {
  int ret = 0;
  pthread_mutex_lock(&stopMutex);
  ret = stopIssued;
  pthread_mutex_unlock(&stopMutex);
  return ret;
}

static void setStopIssued(int val) {
  pthread_mutex_lock(&stopMutex);
  stopIssued = val;
  pthread_mutex_unlock(&stopMutex);
}

static void write_buffer_to_log() {
    ssize_t rdsz;
    char buf[4096];
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
}

static void *thread_func(void*) {
    while(getStopIssued() == 0) {
        write_buffer_to_log();
    }
    if (logFile != NULL) {
        fprintf(logFile, "Logger thread is terminating...\n");
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
    // pthread_detach(thr); -- I'll use pthread_join() instead
    return 0;
}

extern "C" int instead_main(int argc, char** argv);

/* Start up the SDL app */
extern "C" int SDL_main(int argc, char** argv) {
    __android_log_write(ANDROID_LOG_DEBUG, tag, "Entering INSTEAD launcher...");
    char* nativelog = argc >= 2 ? argv[1] : NULL;
    char* path = argc >= 3 ? argv[2] : NULL;
    char* appdata = argc >= 4 ? argv[3] : NULL;
    char* gamespath = argc >= 5 ? argv[4] : NULL;
    char* res = argc >= 6 ? argv[5] : NULL;
    char* game = argc >= 7 ? argv[6] : NULL;
    char* idf = argc >= 8 ? argv[7] : NULL;
    char* music = argc >= 9 ? argv[8] : NULL;
    char* owntheme = argc >= 10 ? argv[9] : NULL;
    char* theme = argc >= 11 ? argv[10] : NULL;
    
    if (nativelog != NULL) {
        logFile = fopen(nativelog, "w");
        start_logger("INSTEAD-Native");
    }
    
    /* Run the application code! */
    int status;
    char* _argv[15];
    int n = 1;
    if (path != NULL) {
        printf("path = %s\n", path);
        chdir(path);
    }

    _argv[0] = argv[0];

    _argv[n++] = SDL_strdup("-nostdgames");
    
    if (res != NULL) {
        printf("res = %s\n", res);
        _argv[n++] = SDL_strdup("-mode");
        _argv[n++] = res;
    }
    if (appdata != NULL) {
        printf("appdata = %s\n", appdata);
        _argv[n++] = SDL_strdup("-appdata");
        _argv[n++] = appdata;
    }
    if (gamespath != NULL) {
        printf("gamespath = %s\n", gamespath);
        _argv[n++] = SDL_strdup("-gamespath");
        _argv[n++] = gamespath;
    }
    if (idf != NULL) {
        printf("idf = %s\n", idf);
        _argv[n++] = idf;
    } else if (game != NULL) {
        printf("game = %s\n", game);
        _argv[n++] = SDL_strdup("-game");
        _argv[n++] = game;
    }
    if (music == NULL) {
        printf("Without music = YES\n");
        _argv[n++] = SDL_strdup("-nosound");
    }
    if (owntheme != NULL) {
        printf("Force own theme = YES\n");
        _argv[n++] = SDL_strdup("-owntheme");
    }
    if (theme != NULL) {
        printf("theme = %s\n", theme);
        _argv[n++] = SDL_strdup("-theme");
        _argv[n++] = theme;
    }
    _argv[n] = NULL;

    printf("Before instead_main()\n");
    status = instead_main(n, _argv);
    printf("After instead_main()\n");
    fflush(NULL);
    // Stopping the logger thread, if needed. Closing the log file, if it was opened...
    if (nativelog != NULL) {
        // Wait for potentially not logged data
        usleep(1000000);
        setStopIssued(1);
        void* thr_res;
        pthread_join(thr, &thr_res);
        // Write to the log anything that can be missed by the thread
        write_buffer_to_log();
    }
    if (logFile != NULL) {
        fclose(logFile);
    }
    
    return status;
}

extern "C" void Java_com_nlbhub_instead_STEADActivity_toggleMenu(JNIEnv* env, jclass cls) {
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
