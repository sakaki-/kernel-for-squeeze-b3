# kernel-for-squeeze-b3

Updated kernel (3.16.1) for Excito B3 miniserver running Debian squeeze

## Description

<img src="https://wiki.gentoo.org/images/0/03/Excito_b3.jpg" alt="Excito B3" width="250px" align="right"/>
This project contains a compiled **3.16.1** kernel and module set for the Excito B3 miniserver. You can use it as a replacement for the 2.6.39.4-11 kernel on your B3, running the standard Excito Debian squeeze system (no Gentoo involved!). <br>The supplied kernel has the necessary code to switch off the L2 cache (per [this link](https://lists.debian.org/debian-boot/2012/08/msg00804.html)) prepended, and the kirkwood-b3 device tree blob appended. Accordingly, no [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) flashing or Excito patch set is required. <br>Note that this kernel has **not** been extensively tested, and is provided as a convenience only. When using it, the 'stock' Excito software installation on the B3 still seems broadly to work (e.g., the admin web interface is accessible via the LAN port), but some features are broken (a fuller description is provided below).

Download a 'deploy_root' tarball [here](https://github.com/sakaki-/kernel-for-squeeze-b3/releases/download/3.16.1-b3/deploy_root.tar.xz) (its digital signature is [here](https://github.com/sakaki-/kernel-for-squeeze-b3/releases/download/3.16.1-b3/deploy_root.tar.xz.asc)), or use `wget` (as per the instructions below).

> The kernel was built on a Gentoo PC using [crossdev](https://www.gentoo.org/proj/en/base/embedded/handbook/?part=1&chap=2#doc_chap2), based on `sys-kernel/vanilla-sources-3.16.1`. If you have a PC running Gentoo, instructions for cross-compiling your own kernel are provided at the end of this document ^-^

## Is this the Right Kernel for You?

If you are interested in upgrading the kernel on your B3, there are a number of choices open to you:
* If you want all your existing Excito software to work fully, without any modifications, (or possibly if you are looking to upgrade to Debian Wheezy) you should consider using the 3.2.62 version in the [community-b3-kernel](https://github.com/Excito/community-b3-kernel) GitHub project, and maintained by MouettE (see also [this thread](http://forum.mybubba.org/viewtopic.php?f=7&t=5364) on the Excito forum). It contains all the relevant Excito and Debian patches.
* If you just want to quickly try out running your B3 under an up-to-date kernel, have a look at my [Gentoo on B3 live-USB image](https://github.com/sakaki-/gentoo-on-b3). This is a complete, bootable Gentoo Linux system (with kernel 3.16.1). You can write the image to a USB key, then boot your B3 from that, *without* affecting any installed system on your main hard drive.
* If you'd like to use a 'vanilla' 3.16.1 kernel on your (Debian squeeze) B3, then try the version included in this project. As the Excito patches are unapplied, some Excito userland software (which e.g. controls the LED on the front panel) will not work, unless modified (see Known Limitations, below). On the other hand, because this is a 'vanilla' kernel, if you are content with the remaining functionality, it will be easier to keep your kernel upgraded in future.

## Downloading, Verifying and Unpacking

> Warning: the supplied kernel and modules are provided 'as is' and without warranty. Proceed at your own risk, and make sure you have a rescue system to hand (and have tested it *before* you attempt the install). Read the instructions provided below, and don't proceed if you are at all unsure.

Get root on your B3, then issue:
```
~ # wget -c https://github.com/sakaki-/kernel-for-squeeze-b3/releases/download/3.16.1-b3/deploy_root.tar.xz
~ # wget -c https://github.com/sakaki-/kernel-for-squeeze-b3/releases/download/3.16.1-b3/deploy_root.tar.xz.asc
```
to fetch the tarball and its signature.

Next, if you like, verify the tarball using `gpg` (this step is optional):
```
~ # gpg --keyserver pool.sks-keyservers.net --recv-key DDE76CEA
~ # gpg --verify deploy_root.tar.xz.asc deploy_root.tar.xz
```

Assuming that reports 'Good signature', you can proceed. Untar the package:
```
~ # tar xJf deploy_root.tar.xz
```

## Installation and Boot

You will now have a new directory, `deploy_root`. This contains the kernel, modules and firmware. Begin by backing up your old kernel and firmware (we'll can leave the old modules in place, as they live in a version-distinguished directory (`/lib/modules/2.6.39.4-11`)):
```
~ # cp /boot/uImage /boot/uImage.orig
~ # cp -a /lib/firmware /lib/firmware.orig
```
Next, copy across the 3.16.1 kernel, firmware and modules:
```
~ # cp -a deploy_root/boot/uImage /boot/uImage
~ # cp -a deploy_root/boot/config /boot/config-3.16.1-b3
~ # cp -a deploy_root/boot/System.map /boot/System.map-3.16.1-b3
~ # cp -a deploy_root/lib/firmware /lib/
~ # cp -a deploy_root/lib/modules/3.16.1-b3 /lib/modules/
~ # sync
```

Backup any vital data, make sure you have a rescue system to hand (such as my [Gentoo live-USB image for B3](https://github.com/sakaki-/gentoo-on-b3)), and restart to try it out!
```
~ # reboot
```

Note that the blue LED will **not** come on (see "Known Limitations", below), so your B3 may look like it has shut down again - however, the system *should* boot, and after a minute or so, the standard Excito web interface will be available (via Ethernet). WiFi access *will* come up, *providing* you have already configured it prior to switching kernels - there seems to be some problem configuring it via the web interface under 3.16.1.

## Reverting to the Previous Version

If the system has booted successfully under 3.16.1, then you can simply log into your B3 via `ssh`, get root, and do:
```
~ # mv /boot/uImage /boot/uImage.new
~ # mv /boot/uImage.orig /boot/uImage
~ # mv /lib/firmware /lib/firmware.new
~ # mv /lib/firmware.orig /lib/firmware
~ # sync
~ # reboot
```
and the system should boot back into your original B3 kernel, with all features available.

If you cannot `ssh` in directly, then you'll have to reboot your B3 using your rescue system via USB. Do so, log in as root, then do:
```
rescue ~ # mkdir /tmp/b3root
rescue ~ # mount /dev/sda1 /tmp/b3root
rescue ~ # mv /tmp/b3root/boot/uImage /tmp/b3root/boot/uImage.new
rescue ~ # mv /tmp/b3root/boot/uImage.orig /tmp/b3root/boot/uImage
rescue ~ # mv /tmp/b3root/lib/firmware /tmp/b3root/lib/firmware.new
rescue ~ # mv /tmp/b3root/lib/firmware.orig /tmp/b3root/lib/firmware
rescue ~ # sync
rescue ~ # umount /tmp/b3root
rescue ~ # reboot
```
and you should be back to normal!


## Known Limitations

As of version 3.15 of the kernel, the B3's device-tree information (file `arch/arm/boot/dts/kirkwood-b3.dts` in the kernel source directory) has been integrated into the mainline. This obviates the need for Excito patches to access the B3's idiosyncratic hardware (such as LEDs, rear button etc.; standard items such as disk drives are unaffected of course), but also means that the existing Excito software that uses these devices will not work correctly under the 3.16.1 kernel supplied here. For example, the blue LED on the front of the B3 will **not** come on after boot, the rear button will not shut the system down (you'l have to do this from the command line) etc.

As a concrete example of how things have changed, consider the front LED. On a 'stock' B3, to change the LED to green, per [these instructions](http://wiki.excito.org/wiki/index.php/Let_your_B3_beep_and_change_the_LED_color) you would execute:
```
stock_b3 # echo lit > /sys/bus/platform/devices/bubbatwo/ledmode && \
  echo 2 > /sys/bus/platform/devices/bubbatwo/color
```
Whereas in the 3.16.1 kernel, you would need instead to use:
```
3.16.1_b3 # echo -n 1 > /sys/class/leds/bubba3\:green\:programming/brightness
```
Or, more properly:
```
3.16.1_b3 # cat /sys/class/leds/bubba3\:green\:programming/max_brightness > \
  /sys/class/leds/bubba3\:green\:programming/brightness
```
You can see the kirkwood-b3 device tree file [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kirkwood-b3.dts), from which the new paths can easily be inferred.

Of course, it's not all bad: because the LED is now a standard kernel device, all the normal fun stuff like [triggers](http://elinux.org/EBC_Exercise_10_Flashing_an_LED#Flashing_the_user_LEDs) becomes available. For example, you could write:
```
3.16.1_b3 #  echo -n "heartbeat" > /sys/class/leds/bubba3\:green\:programming/trigger
```
There are other issues which I am unqualified to debug... For example, WiFi access works provided you have configured it prior to upgrading your kernel, but you can't configure WiFi using the Excito web interface post-upgrade (other web admin functions seem to work, however).

> The compiled-in kernel command line used is:
```
root=/dev/sda1 console=ttyS0,115200n8 earlyprintk
```
so the [serial console](http://wiki.excito.org/wiki/index.php/Serial_Console_Access_on_B3) (if you have one attached) can be used to monitor early boot.

There may be many other issues lurking under the surface... so take care ><

## Kernel Headers etc.

To save space (and as they aren't necessary unless you're going to be compiling software), I have omitted the kernel headers in the supplied package. If you need them, since I have used a vanilla tree you can just pull the [3.16.1 tarball](https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.16.1.tar.xz) from kernel.org (and then, if you like, ["make headers_install"](https://www.kernel.org/doc/Documentation/kbuild/headers_install.txt) to sanitize them).

Also, the modules in this package have been supplied unstripped. Feel free to [strip them](http://unix.stackexchange.com/questions/25421/how-much-strip1-ing-is-okay-for-kernel-modules) yourself if desired.

## Cross-Compiling Your Own Kernel (Optional!)

If you have a PC running Gentoo Linux, you can easily compile your own kernel for a B3, using the [crossdev](https://www.gentoo.org/proj/en/base/embedded/handbook/?part=1&chap=2#doc_chap2) tool. Here's how.

First, since `crossdev` uses the first overlay it finds as home, if you use [layman](https://wiki.gentoo.org/wiki/Layman), then you should do the following:
```
gentoo_pc ~ # mdkir /usr/local/portage
gentoo_pc ~ # echo 'PORTDIR_OVERLAY="/usr/local/portage $PORTDIR_OVERLAY"' >> \
  /etc/portage/make.conf
```

Next, if you haven't already done so, convert the relevant /etc/portage files (package.accept_keywords etc.) to directories. You can run the following script to do this automatically (credit: [MobileAPES](http://www.mobileapes.com/gentoo/crossdev)):
```
#!/bin/bash
PROFILE_DIR="/etc/portage"

if [ ! -e ${PROFILE_DIR} ]; then
    mkdir ${PROFILE_DIR};
fi;

MYCHOST=$(gcc-config -c | sed -e 's/\-[0-9]*\.[0-9\.]*.*$//g')

for PACK_DIR in package.keywords package.use package.unmask package.mask \
    package.license package.accept_keywords; do
    CUR_DIR="${PROFILE_DIR}/${PACK_DIR}"
    if [ ! -e ${CUR_DIR} ]; then
        mkdir ${CUR_DIR}
    fi

    if [ -e ${CUR_DIR} -a ! -d ${CUR_DIR} ]; then
        mv ${CUR_DIR} ${CUR_DIR}.moving
        mkdir ${CUR_DIR}
        mv ${CUR_DIR}.moving ${CUR_DIR}/${MYCHOST}
    fi
done

echo "Completed!"

```
Install `crossdev` and `u-boot-tools` (for `mkimage`) if you don't already have them:
```
gentoo_pc ~ # emerge -av sys-devel/crossdev dev-embedded/u-boot-tools sys-fs/dosfstools
```
Next, let `crossdev` build a cross-toolchain for our target architecture, using 'stable branch' tools (`gcc` etc.):
```
gentoo_pc ~ # crossdev --stable --target armv5tel-softfloat-linux-gnueabi
```
(It may complain about `/usr/local/portage/metadata/layout.conf` not existing, but `crossdev` *will* create and populate the file for you, so don't worry.)

Now grab some kernel sources. Let's say you wanted 3.16.1, in 'vanilla' form (i.e, without Gentoo's patchset, exactly as you'd get it from [kernel.org](https://www.kernel.org/)). As of the time of writing, this is not stabilized for the `arm` architecture on Gentoo, so we'd need to issue:
```
gentoo_pc ~ # echo "sys-kernel/vanilla-sources ~arm" >> \
  /etc/portage/package.accept_keywords/cross-armv5tel-softfloat-linux-gnueabi
```
to enable access. Furthermore, you need to permit the 'freedist' license for this package:
```
gentoo_pc ~ # echo "sys-kernel/vanilla-sources freedist" >> \
  /etc/portage/package.license/cross-armv5tel-softfloat-linux-gnueabi
```
Now we can grab the sources (note we use `--nodeps` here; we don't actually want to cross-emerge the `perl` etc. tools that'll be used to patch the sources, as you already have them in your native architecture (`amd64` or whatever) and they'll be called from there):
```
gentoo_pc ~ # ARCH="arm" armv5tel-softfloat-linux-gnueabi-emerge \
  -av --nodeps =sys-kernel/vanill-sources-3.16.1
```
That's all the one-off steps out of the way. Now, go into the source directory (`crossdev` automatically keeps things separate from your normal sysroot, to avoid pollution):
```
gentoo_pc ~ #  cd /usr/armv5tel-softfloat-linux-gnueabi/usr/src/linux-3.16.1-gentoo
```
Grab a suitable starter config from somewhere, such as [the one used in this project](https://github.com/sakaki-/kernel-for-squeeze-b3/blob/master/config) ^-^, save it to `.config`, and sanitize it:
```
gentoo_pc linux-3.16.1-gentoo # cp <your config file> .config
gentoo_pc linux-3.16.1-gentoo # make ARCH="arm" \
  CROSS_COMPILE="armv5tel-softfloat-linux-gnueabi-" olddefconfig
```
(Don't forget the hyphen at the end of `armv5tel-softfloat-linux-gnueabi-`!) Now the fun bit - set any configuration options you like in there (such as built-in command line etc):
```
gentoo_pc linux-3.16.1-gentoo # make ARCH="arm" \
  CROSS_COMPILE="armv5tel-softfloat-linux-gnueabi-" menuconfig
```
Next, download the [provided build script](https://github.com/sakaki-/kernel-for-squeeze-b3/blob/master/build_image.sh) into `/root/build_image.sh`, and make it executable:
```
gentoo_pc linux-3.16.1-gentoo # wget -c --no-check-certificate -O /root/build_image.sh \
  https://github.com/sakaki-/kernel-for-squeeze-b3/raw/master/build_image.sh
gentoo_pc linux-3.16.1-gentoo # chmod +x /root/build_image.sh
```

This script deals with all the unpleasant L2-caches-off code, device tree blob etc. Now run it! This does a parallel `make`, so on a modern PC, it shoudn't take long (5-10 mins):
```
gentoo_pc linux-3.16.1-gentoo # /root/build_image.sh
```
When done, you'll have your very own `deploy_root` directory and tar file, which will contain a directory `boot` (with the `uImage`, `System.map` and `config` in it), and `lib` (with the modules and firmware).

Deploy these to your (Gentoo) B3 (per the instructions earlier), and off you go! (Obviously, you can repeat the `make menuconfig` / `build_image.sh` steps as often as you need, to refine the kernel).

## Feedback Welcome!
If you have any problems, questions or comments regarding this project, feel free to drop me a line! (sakaki@deciban.com)
> However, please note, I'm not a Debian hacker, so I'll can't help you with trying to adapt the B3's existing software to work with this kernel. Sorry! ><
