LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libiconv

#APP_SUBDIRS := $(LOCAL_PATH)/libiconv/src
#APP_SUBDIRS += $(LOCAL_PATH)/libiconv/srclib
#APP_SUBDIRS := $(LOCAL_PATH)/libiconv/lib

#APP_SUBDIRS := $(patsubst $(LOCAL_PATH)/libiconv%, %, $(shell find $(LOCAL_PATH)/libiconv/ -type d))

LOCAL_H_FILES := $(addprefix $(F)libiconv/lib/,$(notdir $(wildcard $(LOCAL_PATH)/libiconv/lib/*.h)))
LOCAL_SRC_FILES := $(addprefix $(F)libiconv/lib/,$(notdir $(wildcard $(LOCAL_PATH)/libiconv/lib/*.c)))

#LOCAL_H_FILES += $(addprefix $(F)libiconv/libcharset/lib/,$(notdir $(wildcard $(LOCAL_PATH)/libiconv/libcharset/lib/*.h)))
#LOCAL_SRC_FILES += $(addprefix $(F)libiconv/libcharset/lib/,$(notdir $(wildcard $(LOCAL_PATH)/libiconv/libcharset/lib/*.c)))

LOCAL_CFLAGS := -I$(LOCAL_PATH)/libiconv/include -I$(LOCAL_PATH)/libiconv/libcharset/include -I$(LOCAL_PATH)/libiconv/lib #-I$(LOCAL_PATH)/libiconv/srclib

LOCAL_SHARED_LIBRARIES := 

LOCAL_STATIC_LIBRARIES := 

LOCAL_LDLIBS :=

include $(BUILD_STATIC_LIBRARY)
