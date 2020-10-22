
THEOS_DEVICE_IP = 192.168.211.158

include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e
TWEAK_NAME = FlexInjected
FlexInjected_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
