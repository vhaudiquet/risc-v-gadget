
SERIES ?= noble
DESTDIR ?= install

all:
	mkdir -p $(DESTDIR)
	make install/cidata
	make install/dtb
	make install/grub
	make meta
	make install/u-boot

meta:
	mkdir -p $(DESTDIR)/meta
	cp gadget.yaml $(DESTDIR)/meta/

install/cidata:
	mkdir -p $(DESTDIR)/cidata
	cp user-data $(DESTDIR)/cidata/
	cp meta-data $(DESTDIR)/cidata/
	touch $(DESTDIR)/cidata/vendor-data

install/dtb:
	rm -rf build
	mkdir build
	cd build && pull-lp-debs -a riscv64 linux-riscv '' $(SERIES)
	cd build && dpkg -x linux-modules*.deb linux-modules/
	mkdir -p $(DESTDIR)/dtb
	cp -r ./build/linux-modules/lib/firmware/*-generic/device-tree/* \
	$(DESTDIR)/dtb
	rm -rf build

install/grub:
	rm -rf build
	mkdir build
	# Monolithic images are not yet backported to Ubuntu 22.04.
	cd build && pull-lp-debs -a riscv64 grub2 '' oracular
	cd build && dpkg -x grub-efi-riscv64-unsigned*.deb grub/
	mkdir -p $(DESTDIR)/grub
	cp ./build/grub/usr/lib/grub/riscv64-efi/monolithic/grubriscv64.efi $(DESTDIR)/grub/
	cp grub.cfg $(DESTDIR)/grub/
	rm -rf build

install/u-boot:
	rm -rf build
	mkdir build
	rm -rf build/u-boot-sifive*
	cd build && pull-lp-debs -a riscv64 u-boot '' $(SERIES)
	# SiFive HiFive Unmatched
	cd build && dpkg -x u-boot-sifive*.deb u-boot-sifive/
	mkdir -p $(DESTDIR)/u-boot-sifive-unmatched
	cp ./build/u-boot-sifive/usr/lib/u-boot/sifive_unmatched/u-boot-spl.bin \
	$(DESTDIR)/u-boot-sifive-unmatched/
	cp ./build/u-boot-sifive/usr/lib/u-boot/sifive_unmatched/u-boot.itb \
	$(DESTDIR)/u-boot-sifive-unmatched/
	# JH7110 based boards
	cd build && dpkg -x u-boot-starfive*.deb u-boot-starfive/
	mkdir -p $(DESTDIR)/u-boot-starfive
	cp build/u-boot-starfive/usr/lib/u-boot/starfive_visionfive2/u-boot.itb \
	$(DESTDIR)/u-boot-starfive/
	cp build/u-boot-starfive/usr/lib/u-boot/starfive_visionfive2/u-boot-spl.bin.normal.out \
	$(DESTDIR)/u-boot-starfive/
	# PolarFire Icicle Kit
	cd build && dpkg -x u-boot-microchip*.deb u-boot-microchip/
	mkdir -p $(DESTDIR)/u-boot-microchip
	cp build/u-boot-microchip/usr/lib/u-boot/microchip_icicle/u-boot.payload \
	$(DESTDIR)/u-boot-microchip/
	rm -rf build

image:
	sudo rm -rf workdir
	sudo ubuntu-image --workdir workdir classic image-definition.yaml

image-debug:
	sudo rm -rf workdir
	sudo ubuntu-image --workdir workdir --debug classic image-definition.yaml
