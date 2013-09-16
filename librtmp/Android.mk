LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_C_INCLUDES += $(NDK_PROJECT_PATH)/librtmp \
	$(SSL)/include

LOCAL_SRC_FILES:= \
	amf.c \
	hashswf.c \
	log.c \
	parseurl.c \
	rtmp.c

LOCAL_CFLAGS += -I$(SSL)/include -DUSE_OPENSSL
LOCAL_LDLIBS += -L$(SSL)/libs/$(TARGET_ARCH_ABI)
LOCAL_LDLIBS += -lssl -lcrypto -lz

LOCAL_MODULE := librtmp

include $(BUILD_SHARED_LIBRARY)

