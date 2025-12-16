# meta-st-ota
This layer is not a reference design for a product but it has the unique goal to show how the secure firmware update is working in OpenSTLinux.<br>
To have deeper information about RAUC or to have support to design a product with, you can contact [Pengutronix]( https://www.st.com/content/st_com_cx/en/partner/partner-program/partnerpage/Pengutronix.html), member of ST partner Program and maintainer of RAUC.

## Overview
- This layer is used to demonstrate SW update OTA use case on STM32MPU boards.
- It uses A/B mechanism concept : all updatable partitions are duplicated : for example, rootfs becomes rootfs-a and rootfs-b. When a software running on rootfs-a is notified to be upgraded, the new version is installed on rootfs-b, and then system reboots on rootfs-b which becomes the new active version.
- The embedded client is [rauc](https://rauc.readthedocs.io/en/latest/) which can get software updates from:
  - A back-end framework (ex:[Hawkbit](https://www.eclipse.org/hawkbit/)) with a glue layer called [rauc-hawkbit](https://github.com/rauc/rauc-hawkbit) polls the Hawkbit server to transmit new bundle to rauc. Nevertheless, the latest Hawkbit versions don't include UI because Vaadin 8 hawkBit UI was shut down (more details [here](https://eclipse.dev/hawkbit/blog/2023-11-22-vaadin8_ui_discontinuation/)), that's why event if [rauc-hawkbit](https://github.com/rauc/rauc-hawkbit) is still included in this layer, [Hawkbit](https://www.eclipse.org/hawkbit/) won't be demonstrated in this layer.
  - Any deployment method listed [here](https://rauc.readthedocs.io/en/latest/advanced.html#software-deployment).
- This layer is based on official DV-6.1 [openstlinux-25-06-11](https://wiki.st.com/stm32mpu/wiki/STM32_MPU_OpenSTLinux_release_note_-_v6.1.0) which also needs [rauc layer](https://github.com/rauc/meta-rauc).


## What's new in that release ?
This release is mostly an update to be able to run on top of ecosystem-v6.1.0, with :
- Support of stm32mp215f-dk board
- Several patches have been upstreamed into STM32MPU-ecosystem, so they have been removed from this layer:
  - u-boot: propagate boot index
  - u-boot: stm32prog: add support rootfs-a for OTA
  - u-boot: mkfwumdata: manage bank accepted entry
- Hawkbit not demonstrated anymore (since Vaadin 8 hawkBit UI was shut down)

## Table of Contents
1. Documentation
2. HW requirements
3. SW requirements
4. How to add the meta-st-ota layer to your build ?
5. How to use the demo ?
6. Extra explanations
7. Limitations - issues


## 1. Documentation
- [STM32MPU-ecosystem-v6.1.0 Release note](https://wiki.st.com/stm32mpu/wiki/STM32_MPU_OpenSTLinux_release_note_-_v6.1.0)
- [STM32MP13 ressources](https://wiki.st.com/stm32mpu/wiki/STM32MP13_resources)
- [MP13 Disco schematic](https://wiki.st.com/stm32mpu/wiki/STM32MP13_resources#MB1635_schematics)
- [STM32MP15 ressources](https://wiki.st.com/stm32mpu/wiki/STM32MP15_resources)
- [MP15 Disco schematic](https://wiki.st.com/stm32mpu/wiki/STM32MP15_resources#MB1272_schematics)
- [STM32MP25 ressources](https://wiki.st.com/stm32mpu/wiki/STM32MP25_resources)
- [MP25 Eval schematic](https://wiki.st.com/stm32mpu/wiki/STM32MP25_resources#MB1936_schematics)
- [Rauc documentation](https://rauc.readthedocs.io/en/latest/)
- [Secure Firmware Update wiki](https://wiki.st.com/stm32mpu/wiki/Secure_Firmware_Update)
- [How to handle secure firmware update wiki](https://wiki.st.com/stm32mpu/wiki/How_to_handle_secure_firmware_update)


## 2. HW requirements
A STM32MP135F-DK or STM32MP157F-DK2 or STM32MP157F-EV1 or STM32MP215F-DK or STM32MP257F-EV1 is requested.


## 3. SW requirements
- This layer depends on [meta-rauc](https://github.com/rauc/meta-rauc).

## 4. How to add meta-st-ota layer to your build ?
### Install the [OpenSTLinux distribution](https://wiki.st.com/stm32mpu/wiki/STM32MPU_Distribution_Package#Installing_the_OpenSTLinux_distribution)

### Replace [Initializing the OpenEmbedded build environment chapter](https://wiki.st.com/stm32mpu/wiki/STM32MPU_Distribution_Package#Initializing_the_OpenEmbedded_build_environment) content by the hereafter explanations:

### Fetch the two following layers :
```
cd <Yocto source tree>/layers
git clone --branch scarthgap https://github.com/rauc/meta-rauc.git

cd <Yocto source tree>/layers/meta-st
git clone --branch scarthgap https://github.com/PRG-MPU-CUST/meta-st-ota.git
```
- The meta-rauc layer provides support for integrating the RAUC update tool into the device.
- The meta-st-ota layer which provides all STM32MP specifities is automatically added when sourcing envsetup.sh with MACHINE option.

### Initializing the OpenEmbedded build environment
The layer meta-st-ota contains a machine named "stm32mp1-ota" or "stm32mp2-ota" that needs to be used when sourcing the environment:
```
DISTRO=openstlinux-weston MACHINE=stm32mp2-ota source layers/meta-st/scripts/envsetup.sh
```
### Add the rauc related layer
Execute the following commands to configure environement with the new machine for OTA for STM32MPU boards:
```
bitbake-layers add-layer ../layers/meta-rauc/
```

Then you can [source your environment and build the baseline](https://wiki.st.com/stm32mpu/wiki/STM32MPU_Distribution_Package#Building_the_OpenSTLinux_distribution).
After that, you can [flash the built image](https://wiki.st.com/stm32mpu/wiki/STM32MPU_Distribution_Package#Flashing_the_built_image).


## 5. How to use the demo ?
Before executing an OTA update, you need to:
- create a bundle which is a signed set of partitions to be flashed on the board.
- Start the FrontEnd server to deploy this new bundle.

### How to generate a bundle ?
The content of the bundle is a script in the bundle recipe `layers/meta-st/meta-st-ota/recipes-core/bundles/update-st-bundle-<board name>.bb`
Where `<board name>` can be `stm32mp157f-ev1`, `stm32mp157f-dk2`, `stm32mp135f-dk`, `stm32mp215f-dk` or `stm32mp257f-ev1`.

The layer contains prebuilt certificates that need to be updated for production.

Execute the following command to build the bundle (example for MP13 disco board):
```
bitbake update-st-bundle-stm32mp257f-ev1
```
More information in [RAUC documentation](https://rauc.readthedocs.io/en/latest/integration.html#bundle-generation)

### How to deploy the bundle into the target ?
The latest Hawkbit versions don't include UI because Vaadin 8 hawkBit UI was shut down : more details [here](https://eclipse.dev/hawkbit/blog/2023-11-22-vaadin8_ui_discontinuation/), .

More information in [Hawkbit documentation](https://www.eclipse.org/hawkbit/) and [rauc-hawkbit documentation](https://github.com/rauc/rauc-hawkbit/blob/master/README.rst)

After having built the bundle, copy it into the target:
```
wget http://<your server IP addr>/<bundle file> && sync
rauc install /usr/local/<bundle file>
```
More information in [RAUC documentation](https://rauc.readthedocs.io/en/latest/examples.html#update-installation)

## 6. Extra explanations

### Post install
At the end of the install, the script /usr/lib/rauc/post-install.sh is called by rauc in order to update some part in the new flashed images:
- update kernel cmdline : root mount point and rauc.slot paramters
- update vendor and boot mount points
- update boot partition to boot on the new flashed software
- bootcount doesn't need to be reset here anymore as it is done by tf-a when it performs a normal boot (not trial)

On reboot, if new image succeeds to boot, the service rauc-mark-good.service will be called which will reset bootcount.

### About metadata partition version
Since ecosystem-v6.0.0, metadata format as been moved from v1 to v2.
- A new device will use metadata v2
- A device already in production with metadata v1 stays with metadata v1 (tf-a BL2 and metadadata partition and not updatable). That's why update agent starting from ecosystem-v6.0.0 needs to support both versions:
  - metadata v2 : enabled by default
  - metadata v1 : disabled by default. To enable it, rename fwu-gen-metadata-v2 into fwu-gen-metadata-v1 in st-image-weston.bbappend recipe.


### About partuuid
The boot partition is selected by the kernel through its UUID which is defined in create_sdcard_from_flashlayout.sh:
```
DEFAULT_SDCARD_PARTUUID=e91c4e10-16e6-4c0e-bd0e-77becf4a3582
SECOND_SDCARD_PARTUUID=087c3ebe-60ca-4517-a55d-c1d7237ead55
```
Where `DEFAULT_SDCARD_PARTUUID` is the UUID of `bootfs-a` and `SECOND_SDCARD_PARTUUID` is the UUID of `bootfs-b`

### How to know on which boot partition type we are ?
- tf-a : the following log is displayed  'INFO:    Selecting to boot from bank 0' if "A" partition is used (1 in case of "B" partition)
- u-boot : "Boot A" or "Boot B" is displayed depending on selected boot partition
- kernel : in the kernel cmdline, rauc.slot=A if we are in "Boot A" or rauc.slot=B if we are in "Boot B"

## 7. Limitations - issues
- If the OTA process is stopped (ex: press on reset button) during its execution, the OTA procedure will restart from the beginning.
The reason is that tf-a is not capable to write into metadata partition (only linux does)
- For test purpose, if you perform several OTA updates without doing a normal reboot between (in trial mode), the bootcount won't be reset and after 3 "trial" reboots, and tf-a will display the message "WARNING: Trial FWU fails to many times" because counter has not been reset, and it won't be possible to switch partitions (A to B or B to A)
- You can sometimes notice an exception during bundle download:`Exception in callback ReadTransport._loop_reading`, but it has no impact on the use case.

