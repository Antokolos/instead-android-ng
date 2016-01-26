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

/* Start up the SDL app */
extern "C" void Java_com_nlbhub_instead_SDLActivity_nativeInit(
    JNIEnv* env,
    jclass cls,
    jstring jnativelog,
    jstring jpath,
    jstring jappdata,
    jstring jgamespath,
    jstring jres,
    jstring jgame,
    jstring jidf,
    jstring jmusic,
    jstring jowntheme,
    jstring jtheme
) {

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
    char *argv[15];
    int n = 1;
    if (jpath != NULL) {
        const char *path = env->GetStringUTFChars(jpath, 0);
        printf("path = %s\n", path);
        chdir(SDL_strdup(path));
        env->ReleaseStringUTFChars(jpath, path);
    }

    argv[0] = SDL_strdup("sdl-instead");

    argv[n++] = SDL_strdup("-nostdgames");
    
    if (jres != NULL) {
        const char *res = env->GetStringUTFChars(jres, 0);
        printf("res = %s\n", res);
        argv[n++] = SDL_strdup("-mode");
        argv[n++] = SDL_strdup(res);
        env->ReleaseStringUTFChars(jres, res);
    }
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
    if (jmusic == NULL) {
        printf("Without music = YES\n");
        argv[n++] = SDL_strdup("-nosound");
    }
    if (jowntheme != NULL) {
        printf("Force own theme = YES\n");
        argv[n++] = SDL_strdup("-owntheme");
    }
    if (jtheme != NULL) {
        const char *theme = env->GetStringUTFChars(jtheme, 0);
        printf("theme = %s\n", theme);
        argv[n++] = SDL_strdup("-theme");
        argv[n++] = SDL_strdup(theme);
        env->ReleaseStringUTFChars(jtheme, theme);
    }
    argv[n] = NULL;

    printf("Before instead_main()\n");
    status = SDL_main(n, argv);
    printf("After instead_main()\n");
    fflush(NULL);
    // Stopping the logger thread, if needed. Closing the log file, if it was opened...
    if (jnativelog != NULL) {
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

/**
 * SDL_image test
 */
/*int img_test(int argc, char ** argv) {
    bool quit = false;
    SDL_Event event;

    SDL_Init(SDL_INIT_VIDEO);
    IMG_Init(IMG_INIT_PNG);

    SDL_Window* window = SDL_CreateWindow("SDL2 Displaying Image", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, 0);

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_Surface* image = IMG_Load("/data/data/com.nlbhub.instead.launcher/app_data/themes/default/bg.png");
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, image);

    while (!quit)
    {
        SDL_WaitEvent(&event);

        switch (event.type)
        {
            case SDL_QUIT:
                quit = true;
                break;
        }

        //SDL_Rect dstrect = { 5, 5, 320, 240 };
        //SDL_RenderCopy(renderer, texture, NULL, &dstrect);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyTexture(texture);
    SDL_FreeSurface(image);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

    IMG_Quit();
    SDL_Quit();

    return 0;
}

int draw_test(int argc, char* argv[]) {
  SDL_Window *window;
  SDL_Renderer *renderer;
  SDL_Rect rect={50,50,50,50};
  SDL_Event event;
  //The font that's going to be used
  //TTF_Font *font = NULL;
  //SDL_Surface *text = NULL;
  //SDL_Texture *message = NULL;

  if (SDL_Init(SDL_INIT_VIDEO) < 0) return 1;
  //if( TTF_Init() == -1 ) {
    //return 1;
  //}
  //Open the font
  //font = TTF_OpenFont( "/sdcard/STEINEMU.ttf", 28 );

  window = SDL_CreateWindow("Hallo", 100, 100, 200, 200, SDL_WINDOW_SHOWN);
  renderer = SDL_CreateRenderer(window, -1,0);
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255); // black
  SDL_RenderClear(renderer);

  SDL_SetRenderDrawColor(renderer,255,255,255,255); // white
  SDL_RenderFillRect(renderer,&rect);
  SDL_RenderPresent(renderer);

  //Render the text
  //text = TTF_RenderText_Solid( font, argv[0], textColor );
  //messageRect.x = 10;
  //messageRect.y = 10;
  //messageRect.w = 800;
  //messageRect.h = 25;
  //message = SDL_CreateTextureFromSurface(renderer, text);
  //draw_scene(renderer, message);
  while (1)
    while(SDL_PollEvent(&event))
      if (event.type==SDL_QUIT) goto quit;
  quit:
  //SDL_FreeSurface(text);
  //TTF_CloseFont(font);
  //SDL_DestroyTexture(message);
  SDL_Quit();
  return 0;
}*/

/**
 * Simple SDL2 test.
 * by Robert Stephens http://pastebin.com/TRb6Ph1V
 * Original code for SDL: http://41j.com/blog/2011/09/simple-sdl-example-in-c/
 */
/*int test_main(int argc, char ** argv) {

    size_t width = 800;
    size_t height = 600;
    bool quit = false;

    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window * window = SDL_CreateWindow("SDL2 Pixel Drawing",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, 0);

    SDL_Renderer * renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_Texture * texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, width, height);
    Uint32 * pixels = new Uint32[width * height];
    memset(pixels, 255, width * height * sizeof(Uint32));

    while(!quit) {
        SDL_UpdateTexture(texture, NULL, pixels, width * sizeof(Uint32));

        for(int n=0;n<1000;n++) {
            int x=rand()%width;
            int y=rand()%height;
            pixels[y * width + x] = rand()*100000;
        }

        SDL_Event event;
        while(SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    quit = true;
                    break;
            }
            if(event.key.keysym.sym == SDLK_q) {
                quit = true;
                break;
            }
            else if(event.key.keysym.sym == SDLK_c) {
                memset(pixels, 255, width * height * sizeof(Uint32));
            }

        }

        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}*/

/* vi: set ts=4 sw=4 expandtab: */
