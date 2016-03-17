# Android syscall monitor

This is a simple Android rootkit, particularly by hooking the "__NR_openat" syscall, you can monitor the programs that access at the following files:</br>
```linux
/data/data/com.android.providers.contacts/databases/contacts2.db
/data/data/com.android.providers.telephony/databases/telephony.db
/data/data/com.android.providers.telephony/databases/mmssms.db
/data/data/com.facebook.katana/databases
/data/data/com.facebook.orca/databases
/data/data/com.skype.raider/files/shared.xml
/data/data/com.whatsapp/shared_prefs
/data/data/com.whatsapp/shared_prefs/RegisterPhone.xml
/data/data/com.viber.voip/files
```

Android does not support loadable kernel modules, these are the steps to perform, for the kernel recompiling and for the emulation of the Loadable Kernel Module
</br>
1- Add toolchain
```linux
$git clone https://android.googlesource.com/platform/prebuilt -b ics-plus-aosp
$export PATH=~/toolchain/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin:$PATH
```
2- Get kernel source
</br>
```linux
$git clone https://android.googlesource.com/kernel/goldfish.git
$git checkout -t origin/android-goldfish-3.4 -b goldfish3.4
```

3- Configure kernel source
```linux
$make ARCH=arm goldfish_armv7_defconfig
```

Now edit the .config file and enable the kernel module feature:</br>
```linux
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
```

4- Compile kernel source</br>
```linux
$make -j4 ARCH=arm SUBARCH=arm CROSS_COMPILE=arm-eabi-
```

5- Is the time of creation the LKM</br>
```linux
$mkdir ~/Documenti/androidLKM/
$cd ~/Documenti/androidLKM/
```
create files (lkm_android.c and the Makefile)
</br>
I used System.map for retrieve the address of the system_call_table</br>
```linux
$SYSCALL_TABLE=$(grep sys_call_table ~/goldfish/goldfish/boot/System.map | awk '{print $1}')
$sed -i s/SYSCALL_TABLE/$SYSCALL_TABLE/g lkm_android.c

$make
```

6- Create a new AVD </br>
```linux
AVD name: new_kernel_avd
Device: Nexus
Target: API level 22
CPU/ABI: armeabi-v7a
```

7- Launch emulator</br>
```linux
$emulator -debug init -kernel ~/goldfish/goldfish/arch/arm/boot/zImage -avd new_kernel_avd -wipe-data
```

8- Load module</br>
```linux
$adb push ~/Documenti/androidLKM/lkm_android.ko /data/lkm_android.ko

./adb shell
# cd /data
# insmod lkm_android.ko
# lsmod
lkm_android 450 - - Live 0x00000000 (PO)
```

9- View the results</br>
```linux
# dmesg
...
<6>Task sh [PID:1738] make use of this file: /data/data/com.android.providers.contacts/databases/contacts2.db
<6>Task sh [PID:1738] make use of this file: /data/data/com.facebook.katana/databases
...
```
