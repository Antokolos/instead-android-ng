LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

ifndef SDL_JAVA_PACKAGE_PATH
$(error Please define SDL_JAVA_PACKAGE_PATH to the path of your Java package with dots replaced with underscores, for example "com_example_SanAngeles")
endif

#APP_SUBDIRS := $(patsubst $(LOCAL_PATH)/%, %, $(shell find $(LOCAL_PATH)/src -type d))
SUBDIR := instead/src/sdl-instead

LOCAL_SRC_FILES := SDL_android_main.cpp $(SUBDIR)/graphics.c $(SUBDIR)/idf.c $(SUBDIR)/input.c $(SUBDIR)/game.c $(SUBDIR)/list.c $(SUBDIR)/tinymt32.c $(SUBDIR)/main.c $(SUBDIR)/lfs.c $(SUBDIR)/instead.c $(SUBDIR)/sound.c $(SUBDIR)/SDL_rotozoom.c $(SUBDIR)/SDL_anigif.c $(SUBDIR)/SDL_gfxBlitFunc.c $(SUBDIR)/config.c $(SUBDIR)/themes.c $(SUBDIR)/menu.c $(SUBDIR)/util.c $(SUBDIR)/cache.c $(SUBDIR)/unzip.c $(SUBDIR)/ioapi.c $(SUBDIR)/unpack.c $(SUBDIR)/unix.c
LOCAL_H_FILES := $(SUBDIR)/cache.h $(SUBDIR)/config.h $(SUBDIR)/externals.h $(SUBDIR)/game.h $(SUBDIR)/tinymt32.h $(SUBDIR)/graphics.h $(SUBDIR)/input.h $(SUBDIR)/instead.h $(SUBDIR)/internals.h $(SUBDIR)/ioapi.h $(SUBDIR)/iowin32.h $(SUBDIR)/list.h \
	$(SUBDIR)/menu.h $(SUBDIR)/SDL_anigif.h $(SUBDIR)/SDL_gfxBlitFunc.h $(SUBDIR)/SDL_rotozoom.h $(SUBDIR)/sound.h $(SUBDIR)/themes.h $(SUBDIR)/unzip.h $(SUBDIR)/util.h $(SUBDIR)/android.h 


#DATAPATH=/sdcard/Instead-NG
DATAPATH=.

STEADPATH=$(DATAPATH)/stead
THEMESPATH=$(DATAPATH)/themes
GAMESPATH=$(DATAPATH)/appdata/games
ICONPATH=$(DATAPATH)/icon
LANGPATH=$(DATAPATH)/lang

LOCAL_CFLAGS := \
				$(foreach D, $(APP_SUBDIRS), -I$(LOCAL_PATH)/$(D)) \
				-I$(LOCAL_PATH)/../SDL2/include \
				-I$(LOCAL_PATH)/../SDL2_mixer \
				-I$(LOCAL_PATH)/../SDL2_image \
				-I$(LOCAL_PATH)/../SDL2_ttf \
				-I$(LOCAL_PATH)/../png \
				-I$(LOCAL_PATH)/../jpeg-9 \
				-I$(LOCAL_PATH)/../lua/lua/src \
				-I$(LOCAL_PATH)/../freetype/include \
				-I$(LOCAL_PATH)/../libiconv/libiconv/include \
				-I$(LOCAL_PATH)/..

LOCAL_CFLAGS += -DVERSION=\"2.2.3\" -DANDROID -D_LOCAL_APPDATA -D_HAVE_ICONV -DSDL_JAVA_PACKAGE_PATH=$(SDL_JAVA_PACKAGE_PATH) -D_CUR_DIR=$(DATAPATH)

LOCAL_CFLAGS += -DGAMES_PATH=\"${GAMESPATH}/\" -DTHEME_PATH=\"${THEMEPATH}/\" -D_SDL_MOD_BUG

LOCAL_CFLAGS +=  -DLANG_PATH=\"${LANGPATH}/\" -DSTEAD_PATH=\"${STEADPATH}/\" -DT $(EXTRA_CFLAGS)



LOCAL_SHARED_LIBRARIES := SDL2 SDL2_ttf SDL2_mixer SDL2_image 

LOCAL_STATIC_LIBRARIES := lua freetype libiconv

LOCAL_LDFLAGS := -Lobj/local/armeabi

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -landroid -llog

LOCAL_LDFLAGS += $(APPLICATION_ADDITIONAL_LDFLAGS)


include $(BUILD_SHARED_LIBRARY)
