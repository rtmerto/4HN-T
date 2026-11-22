ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = TikTok

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 4HnStoryGlass
4HnStoryGlass_FILES = Tweak.xm
4HnStoryGlass_FRAMEWORKS = UIKit
4HnStoryGlass_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
