TARGET := iphone:clang:16.2
INSTALL_TARGET_PROCESSES = SoundCloud
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PSSoundcloud

$(TWEAK_NAME)_FILES = $(shell find src -type f \( -iname \*.x -o -iname \*.xm -o -iname \*.m \)) modules/fishhook/fishhook.c
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security StoreKit AppTrackingTransparency
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-unsupported-availability-guard -Wno-unused-value -Wno-deprecated-declarations -Wno-nullability-completeness -Wno-unused-function -Wno-incompatible-pointer-types
$(TWEAK_NAME)_LOGOSFLAGS = --c warnings=none

include $(THEOS_MAKE_PATH)/tweak.mk

# Build FLEXing for sideloading
ifdef SIDELOAD
	$(TWEAK_NAME)_SUBPROJECTS += modules/flexing
endif
