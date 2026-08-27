### VSTHunterKernel Ramdisk Mod Script
## Author: Valentin Stars (vstbio.t.me)

### AnyKernel setup
# global properties
properties() { '
kernel.string=VSTHunterKernel (VSTnh) Alpha3 by Valentin Stars
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a51
device.name2=f41
device.name3=m31s
device.name4=m31
device.name5=m21
device.name6=gta4xl
device.name7=gta4xlwifi
device.name8=m21s
supported.versions=13 - 16
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/platform/13520000.ufs/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot;

# patch boot image cmdline for Framebuffer Console and Panic display
patch_cmdline "console=" "console=tty0";
patch_cmdline "panic=" "panic=0";

ui_print "- Installing VSTHunterKernel (VSTnh)...";
flash_boot;
## end boot install

ui_print "- VSTHunterKernel successfully installed!";
ui_print "- Author: Valentin Stars (vstbio.t.me)";
