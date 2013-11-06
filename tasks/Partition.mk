DEFAULT_PARTITION := $(TOP)/device/intel/common/storage/default_partition.json
DEFAULT_MOUNT := $(TOP)/device/intel/common/storage/default_mount.json
PART_MOUNT_OVERRIDE_FILE := $(call get-specific-config-file ,storage/part_mount_override.json)
ifeq ($(BIGCORE_USB_INSTALLER),true)
PART_MOUNT_OVERRIDE_FILE := $(call get-specific-config-file ,storage/part_mount_override_usbboot.json)
endif
PART_MOUNT_OVERRIDE_FILES := $(call get-all-config-files ,storage/part_mount_override.json)
PART_MOUNT_OUT := $(PRODUCT_OUT)

MKPARTITIONFILE:= \
	$(TOP)/vendor/intel/support/partition.py \
	$(DEFAULT_PARTITION) \
	$(DEFAULT_MOUNT) \
	$(PART_MOUNT_OVERRIDE_FILE) \
	"$(PART_MOUNT_OUT)" \
	"$(TARGET_DEVICE)"

# partition table for fastboot os
$(PRODUCT_OUT)/partition.tbl: $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

# android main fstab
$(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE): $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

# android charger fstab
$(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE): $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

ifeq ($(TARGET_USE_GUMMIBOOT),true)
$(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE):
	$(hide)mkdir -p $(dir $@)
	$(hide) rm -f $(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE)
	$(hide) cp $(TOP)/device/intel/baytrail/byt_m_crb/fstab.byt_m_crb $(PRODUCT_OUT)/root/

# android charger fstab
$(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE):
	$(hide) rm -f $(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE)
	$(hide) cp $(TOP)/device/intel/baytrail/byt_m_crb/fstab.charger.byt_m_crb $(PRODUCT_OUT)/root/
endif

# android ramconsole fstab
$(PRODUCT_OUT)/root/fstab.ramconsole.$(TARGET_DEVICE): $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

$(BUILT_RAMDISK_TARGET): \
	$(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE) \
	$(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE) \
	$(PRODUCT_OUT)/root/fstab.ramconsole.$(TARGET_DEVICE)

blank_flashfiles: $(PRODUCT_OUT)/partition.tbl
