LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := mikmod

LOCAL_CFLAGS := -I$(LOCAL_PATH)

LOCAL_CPP_EXTENSION := .cpp

LOCAL_SRC_FILES := $(notdir $(wildcard $(LOCAL_PATH)/*.c))
#LOCAL_SRC_FILES += $(notdir/mikmod $(wildcard $(LOCAL_PATH)/mikmod/*.c))

LOCAL_SHARED_LIBRARIES := 
LOCAL_STATIC_LIBRARIES := 

include $(BUILD_STATIC_LIBRARY)

