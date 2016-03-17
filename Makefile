obj-m:= lkm_android.o
KERNEL_DIR := /home/invictus/goldfish/goldfish
CCPATH_EXT := /home/invictus/Documenti/android/toolchain/bin/arm-linux-androideabi-

EXTRA_CFLAGS=-fno-pic
ARCH=arm
SUBARCH=arm
 
all:
	make ARCH=arm CROSS_COMPILE=$(CCPATH_EXT) -C $(KERNEL_DIR) M=$(PWD) EXTRA_CFLAGS=$(EXTRA_CFLAGS) modules
clean:
	make -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf *.c~
	rm -rf *.o
	rm -f modules.order
