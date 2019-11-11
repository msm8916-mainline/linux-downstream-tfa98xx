# make sure that the environment variables ARCH and CROSS_COMPILE
# are set for your architecture and cross compiler.
# And that KDIR points to the kernel to build against.
#
# e.g.:
# export ARCH=arm
# export CROSS_COMPILE=arm-linux-gnueabihf-
# export KDIR=../linux

# In case of out of tree build, build as a module
# (when build inside kernel we will not enter this directory and this will have no effect)
ifeq ($(CONFIG_SND_SOC_TFA9XXX),)
CONFIG_SND_SOC_TFA9XXX := m
endif

ifneq ($(KERNELRELEASE),)

# add version number derived from Git
ifeq ($(KDIR),)
PLMA_TFA_HAPTIC_DRV_DIR=$(realpath -f $(srctree)/$(src))
else
PLMA_TFA_HAPTIC_DRV_DIR=$(realpath -f $(src))
endif
GIT_VERSION=$(shell cd $(PLMA_TFA_HAPTIC_DRV_DIR); git describe --tags --dirty --match "v[0-9]*.[0-9]*.[0-9]*")
EXTRA_CFLAGS += -DTFA9XXX_GIT_VERSION=\"$(GIT_VERSION)\"

# debugging support
EXTRA_CFLAGS += -DDEBUG

# if enabled, then measure start timing and print it
#EXTRA_CFLAGS += -DMEASURE_START_TIMING

EXTRA_CFLAGS += -I$(src)/inc
EXTRA_CFLAGS += -Werror

obj-$(CONFIG_SND_SOC_TFA9XXX) := snd-soc-tfa9xxx.o

snd-soc-tfa9xxx-objs += src/tfa9xxx.o
snd-soc-tfa9xxx-objs += src/tfa9xxx_haptic.o
snd-soc-tfa9xxx-objs += src/tfa2_init.o
snd-soc-tfa9xxx-objs += src/tfa2_dev.o
snd-soc-tfa9xxx-objs += src/tfa2_container.o
snd-soc-tfa9xxx-objs += src/tfa2_haptic.o

else

MAKEARCH := $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

all:
	$(MAKEARCH) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKEARCH) -C $(KDIR) M=$(PWD) clean
	rm -f $(snd-soc-tfa9xxx-objs)

endif
