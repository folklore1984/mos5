#!/usr/bin/env bash

function download_sanity_check() {
	files=( "src/downloads/stage3/stage3-amd64-nomultilib.tar.bz2" \
		"src/downloads/portage/portage-latest.tar.xz" \
	)

	for f in "${files[@]}"
	do
		if [ -f "$f" ]
		then
			echo -e " > \e[32m Found \e[0m     : $f"
		else
			echo -e " > \e[31m Not found \e[0m : $f"
			exit 1
		fi
	done
}

function mount_target() {
	mount -t proc none ./build/proc
	mount --rbind /sys ./build/sys
	mount --make-rslave ./build/sys
	mount --rbind /dev ./build/dev
	mount --make-rslave ./build/dev
}

function umount_target() {
	umount ./build/proc
	umount -R ./build/sys
	umount -R ./build/dev
}

function run_chroot_scripts() {
	cp -v ./chroot.sh ./build/
	# ensure copied files are flushed to disk
	sync ; sync ; sync
	chroot ./build /chroot.sh
}

# Run entire process
download_sanity_check
mount_target
run_chroot_scripts
umount_target
