LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
 
LOCAL_MODULE    := luajit
LOCAL_SRC_FILES := out/$(TARGET_ARCH_ABI)/libluajit.a

include $(PREBUILT_STATIC_LIBRARY)