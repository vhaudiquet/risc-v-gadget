RISC-V gadget
=============

Install dependencies
--------------------

.. code-block:: bash

    sudo apt-get update
    sudo apt-get install git snapd qemu-user-static ubuntu-dev-tools
    sudo snap install --classic ubuntu-image


Build image
-----------

.. code-block:: bash

    sudo ubuntu-image --debug classic image-definition.yaml

For debugging add --workdir /tmp/workdir.

First boot
----------

The image contains U-Boot to boot on:

* Microchip Icicle Kit
* SiFive HiFive Unmatched
* StarFive VisionFive 2 1.3b

To boot on QEMU use the following commands:

.. code-block:: bash

    sudo apt-get update
    sudo apt-get install opensbi qemu-system-misc u-boot-qemu
    qemu-system-riscv64 \
    -machine virt -nographic -m 2048 -smp 4 \
    -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
    -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \
    -device virtio-net-device,netdev=eth0 -netdev user,id=eth0 \
    -device virtio-rng-pci \
    -drive file=ubuntu-24.04-preinstalled-server-riscv64.img,format=raw,if=virtio

Login with user ubuntu, password ubuntu.
