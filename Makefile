THEOS_PACKAGE_SCHEME=rootless
TARGET := iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DoubaoAutoClose

DoubaoAutoClose_FILES = Tweak.x
DoubaoAutoClose_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
