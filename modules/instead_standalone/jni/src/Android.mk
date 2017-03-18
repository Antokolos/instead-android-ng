LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL_PATH := ../SDL2

ifndef SDL_JAVA_PACKAGE_PATH
$(error Please define SDL_JAVA_PACKAGE_PATH to the path of your Java package with dots replaced with underscores, for example "com_example_SanAngeles")
endif

#APP_SUBDIRS := $(patsubst $(LOCAL_PATH)/%, %, $(shell find $(LOCAL_PATH)/src -type d))
SUBDIR := instead/src
INSTEAD := instead/src/instead

LOCAL_SRC_FILES := instead_launcher.cpp $(SDL_PATH)/src/main/android/SDL_android_main.c \
	$(INSTEAD)/cache.c $(INSTEAD)/idf.c $(INSTEAD)/instead.c $(INSTEAD)/lfs.c $(INSTEAD)/list.c $(INSTEAD)/snprintf.c $(INSTEAD)/tinymt32.c $(INSTEAD)/util.c \
	$(SUBDIR)/instead_bits.c $(SUBDIR)/instead_paths.c $(SUBDIR)/instead_sound.c $(SUBDIR)/instead_sprites.c $(SUBDIR)/instead_timer.c \
	$(SUBDIR)/graphics.c $(SUBDIR)/input.c $(SUBDIR)/game.c $(SUBDIR)/main.c  $(SUBDIR)/sound.c $(SUBDIR)/config.c \
	$(SUBDIR)/themes.c $(SUBDIR)/menu.c $(SUBDIR)/utils.c  $(SUBDIR)/unzip.c $(SUBDIR)/ioapi.c $(SUBDIR)/unpack.c $(SUBDIR)/unix.c \
	$(SUBDIR)/SDL_rotozoom.c $(SUBDIR)/SDL_anigif.c $(SUBDIR)/SDL_gfxBlitFunc.c

LOCAL_H_FILES := $(INSTEAD)/cache.h $(INSTEAD)/instead.h $(INSTEAD)/list.h $(INSTEAD)/snprintf.h $(INSTEAD)/tinymt32.h $(INSTEAD)/idf.h $(INSTEAD)/system.h $(INSTEAD)/util.h \
	$(SUBDIR)/graphics.h $(SUBDIR)/input.h $(SUBDIR)/game.h $(SUBDIR)/sound.h $(SUBDIR)/config.h \
	$(SUBDIR)/themes.h $(SUBDIR)/menu.h $(SUBDIR)/utils.h $(SUBDIR)/unzip.h $(SUBDIR)/ioapi.h \
	$(SUBDIR)/internals.h $(SUBDIR)/externals.h \
	$(SUBDIR)/SDL_rotozoom.h $(SUBDIR)/SDL_anigif.h $(SUBDIR)/SDL_gfxBlitFunc.h \
	$(SUBDIR)/android.h

#	$(SUBDIR)/SDL2_rotozoom.c $(SUBDIR)/wince.c $(SUBDIR)/s60.c $(SUBDIR)/windows.c $(SUBDIR)/iowin32.c $(SUBDIR)/symbian.cpp \
#	$(SUBDIR)/SDL2_rotozoom.h $(SUBDIR)/iowin32.h $(SUBDIR)/ios.h $(SUBDIR)/s60.h $(SUBDIR)/wince.h \
#DATAPATH=/sdcard/Instead-NG
#DATAPATH=/data/data/com.nlbhub.instead.launcher/app_data
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

LOCAL_CFLAGS += -DVERSION=\"2.5.0\" -DANDROID -DNOMAIN -D_USE_SDL -D_LOCAL_APPDATA -D_HAVE_ICONV -DSDL_JAVA_PACKAGE_PATH=$(SDL_JAVA_PACKAGE_PATH) -D_CUR_DIR=$(DATAPATH)

LOCAL_CFLAGS += -DGAMES_PATH=\"${GAMESPATH}/\" -DTHEME_PATH=\"${THEMEPATH}/\" -D_SDL_MOD_BUG

LOCAL_CFLAGS +=  -DLANG_PATH=\"${LANGPATH}/\" -DSTEAD_PATH=\"${STEADPATH}/\" -DT $(EXTRA_CFLAGS)

LOCAL_SHARED_LIBRARIES := SDL2 SDL2_ttf SDL2_mixer SDL2_image

LOCAL_STATIC_LIBRARIES := luajit freetype libiconv

LOCAL_LDFLAGS := -Lobj/local/armeabi

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -landroid -llog

LOCAL_LDFLAGS += $(APPLICATION_ADDITIONAL_LDFLAGS)


include $(BUILD_SHARED_LIBRARY)
