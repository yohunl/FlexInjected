
THEOS_DEVICE_IP = 10.0.44.136

include $(THEOS)/makefiles/common.mk
ARCHS = armv7 armv7s arm64
TWEAK_NAME = FlexInjected
FlexInjected_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
