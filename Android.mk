LOCAL_PATH := $(call my-dir)

subdirs := $(addprefix $(LOCAL_PATH)/,$(addsuffix /Android.mk, \
		librtmp \
	))

#SSL := ~/SSL
ifndef SSL
$(error "You must define SSL before starting")
endif

include $(subdirs)
