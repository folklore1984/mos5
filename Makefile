BUILDDIR   = ./build/
PORTAGEDIR = ./src/downloads/portage/
STAGE3DIR  = ./src/downloads/stage3/
STAGE3URL  = "http://ftp.swin.edu.au/gentoo/releases/amd64/autobuilds/"
PORTAGEURL = "http://ftp.swin.edu.au/gentoo/snapshots/portage-latest.tar.xz"

OUTPUT = "mos5-system-0.0.1.iso"

.PHONY: all stage0 stage1 stage2 stage3

all: stage0 stage1 stage2 stage3

stage0:
	@echo -e "\e[35m >> stage0 running.. << \e[0m"
	@echo -e "\e[34m fetching tarballs.. \e[0m"
	$(eval STAGE3_REAL_PATH := $(shell curl -s $(STAGE3URL)/latest-stage3-amd64-nomultilib.txt | awk '/stage3/ { print $$1 }'))
	$(eval STAGE3_REAL_NAME := $(shell echo -n "${STAGE3_REAL_PATH}" | awk -F/ '{ print $$2}'))
	@curl --progress-bar $(STAGE3URL)/current-stage3-amd64-nomultilib/${STAGE3_REAL_NAME} -o $(STAGE3DIR)/stage3-amd64-nomultilib.tar.bz2
	@curl --progress-bar $(PORTAGEURL) -o $(PORTAGEDIR)/portage-latest.tar.xz
	@curl -s $(STAGE3URL)/current-stage3-amd64-nomultilib/${STAGE3_REAL_NAME}.DIGESTS.asc -o $(STAGE3DIR)/stage3-amd64-nomultilib.tar.bz2.DIGESTS.asc
	@echo -e "\e[34m flushing tarballs to disk.. \e[0m"
	@sync ; sync ; sync
	$(eval STAGE3_DIGEST := $(shell grep -A 1 SHA512 $(STAGE3DIR)/stage3-amd64-nomultilib.tar.bz2.DIGESTS.asc | grep stage3 | grep -v CONTENTS | awk '{ print $$1 }'))
	$(eval STAGE3_SHA512 := $(shell sha512sum $(STAGE3DIR)/stage3-amd64-nomultilib.tar.bz2 | awk '{ print $$1 }'))
	@if [[ "${STAGE3_DIGEST}" != "${STAGE3_SHA512}" ]]; then \
		echo -e "\e[31m << FAIL! >> \e[0m"; \
		exit 1;\
	else \
		echo -e "\e[32m << PASS >> \e[0m"; \
	fi;
	@echo -e "\n"

stage1:
	@echo -e "\e[35m >> stage1 running.. << \e[0m"
	@echo -e "\e[34m untaring stage3 rootfs.. \e[0m"
	tar xjpf $(STAGE3DIR)/stage3-amd64-nomultilib.tar.bz2 -C $(BUILDDIR)
	@echo -e "\e[34m untaring portage snapshot.. \e[0m"
	tar xJf $(PORTAGEDIR)/portage-latest.tar.xz -C $(BUILDDIR)/usr
	@echo -e "\n"

stage2:
	@echo -e "\e[35m >> stage2 running.. << \e[0m"
	@echo -e "\e[34m emerge world.. \e[0m"
	@echo -e "\e[34m tail -f build.log \e[0m"
	./emergeworld.sh 2>&1 > build.log
	@echo -e "\n"

stage3:
	@echo -e "\e[35m >> stage3 running.. << \e[0m"
	@echo -e "\e[34m squashing system image filesystem.. \e[0m"
	mksquashfs $(BUILDDIR) ./minidistro/image.squashfs -ef ./src/exclude_paths
	@echo -e "\e[34m making system ISO image.. \e[0m"
	mkisofs -r -R -J -T -v -no-emul-boot -boot-load-size 4 -boot-info-table \
		-input-charset utf-8 \
		-V 'mos5-system' -publisher '1984' -p '1984' \
	       	-A 'Mos5-System' -b isolinux/isolinux.bin -c isolinux/boot.cat \
		-o ./$(OUTPUT) ./minidistro
	@echo -e "\e[34m Fix iso to be USB bootable.. \e[0m"
	isohybrid ./$(OUTPUT)
