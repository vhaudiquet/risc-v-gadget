#!/usr/bin/python3
""" Test an image """

import pexpect
import sys

def main():
    image = sys.argv[1]
    print(f"Testing image '{image}'. Starting qemu...")
    p = pexpect.spawn(f'qemu-system-riscv64 \
        -machine virt -nographic -m 2048 -smp 4 \
        -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
        -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \
        -device virtio-net-device,netdev=eth0 -netdev user,id=eth0 \
        -device virtio-rng-pci \
        -drive file={image},format=raw,if=virtio'
    )
        
    print("Waiting for the virtual machine to boot in qemu...")
    p.expect("ubuntu login:", timeout=120)
    print("Found ubuntu login prompt, trying to log in...")
    p.sendline("ubuntu")
    p.expect("Password:")
    p.sendline("ubuntu")
    print("Login information sent ! Waiting for 'change password' prompt...")

    # Change password
    p.expect("Current password:")
    print("Changing password...")
    p.sendline("ubuntu")
    p.expect("New password:")
    p.sendline("again-ubuntu")
    p.expect("Retype new password:")
    p.sendline("again-ubuntu")

    # Shell access
    p.expect("ubuntu@ubuntu:~")
    print("Shell access obtained, image ok.")


if __name__ == '__main__':
    main()
