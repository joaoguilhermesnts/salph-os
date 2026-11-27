#!/bin/bash
# SALPH OS — inicia a ISO ou o disco instalado no QEMU/KVM nos três modos de firmware.
# SALPH OS — boots the ISO or the installed disk in QEMU/KVM in all three firmware modes.
#
# Uso / Usage:
#   tests/qemu-run.sh <uefi|uefi-sb|bios> [--iso FILE] [--disk FILE] [--new-disk SIZE] [--ram MB]
#
# Exemplos / Examples:
#   tests/qemu-run.sh uefi-sb --iso out/salph-os-0.1.0-amd64.hybrid.iso --new-disk 40G   # instalar
#   tests/qemu-run.sh uefi-sb --disk tests/vm/uefi-sb.qcow2                             # 1º boot instalado
#
# Requisitos / Requirements (Debian): qemu-system-x86 qemu-utils ovmf
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

MODE="${1:-}"; shift || true
ISO=""; DISK=""; NEW_DISK=""; RAM=4096
while [ $# -gt 0 ]; do
	case "$1" in
		--iso)      ISO="$2"; shift 2 ;;
		--disk)     DISK="$2"; shift 2 ;;
		--new-disk) NEW_DISK="$2"; shift 2 ;;
		--ram)      RAM="$2"; shift 2 ;;
		*) echo "unknown option: $1" >&2; exit 2 ;;
	esac
done
case "$MODE" in uefi|uefi-sb|bios) ;; *) sed -n '2,12p' "$0"; exit 2 ;; esac

cd "$(dirname "$(readlink -f "$0")")/.."
VM=tests/vm
mkdir -p "$VM"

if [ -n "$NEW_DISK" ]; then
	DISK="$VM/$MODE.qcow2"
	[ -e "$DISK" ] && { echo "$DISK already exists; remove it or use --disk" >&2; exit 1; }
	qemu-img create -f qcow2 "$DISK" "$NEW_DISK"
fi
[ -n "$ISO$DISK" ] || { echo "give --iso and/or --disk/--new-disk" >&2; exit 2; }

MACHINE=q35
CPU=max
ACCEL=tcg
if [ -w /dev/kvm ]; then ACCEL=kvm; CPU=host; else echo "WARNING: no KVM, the VM will be very slow" >&2; fi
[ "$MODE" = uefi-sb ] && MACHINE=q35,smm=on   # SMM é obrigatório para o Secure Boot do OVMF

ARGS=(
	-name "salph-$MODE"
	-machine "$MACHINE,accel=$ACCEL"
	-cpu "$CPU"
	-smp 4
	-m "$RAM"
	-device virtio-vga
	-display gtk
	-audiodev pipewire,id=snd0
	-device intel-hda -device hda-duplex,audiodev=snd0
	-nic user,model=virtio-net-pci
	-device qemu-xhci -device usb-tablet
)

OVMF=/usr/share/OVMF
case "$MODE" in
	uefi)
		[ -e "$VM/uefi-vars.fd" ] || cp "$OVMF/OVMF_VARS_4M.fd" "$VM/uefi-vars.fd"
		ARGS+=(-drive "if=pflash,format=raw,unit=0,readonly=on,file=$OVMF/OVMF_CODE_4M.fd"
		       -drive "if=pflash,format=raw,unit=1,file=$VM/uefi-vars.fd") ;;
	uefi-sb)
		# Variáveis com as chaves da Microsoft já registradas = PC comum com Secure Boot.
		[ -e "$VM/uefi-sb-vars.fd" ] || cp "$OVMF/OVMF_VARS_4M.ms.fd" "$VM/uefi-sb-vars.fd"
		ARGS+=(-global driver=cfi.pflash01,property=secure,value=on
		       -drive "if=pflash,format=raw,unit=0,readonly=on,file=$OVMF/OVMF_CODE_4M.secboot.fd"
		       -drive "if=pflash,format=raw,unit=1,file=$VM/uefi-sb-vars.fd") ;;
	bios) ;;
esac

[ -n "$DISK" ] && ARGS+=(-drive "file=$DISK,if=virtio,format=qcow2")
if [ -n "$ISO" ]; then
	ARGS+=(-drive "file=$ISO,media=cdrom,readonly=on")
	[ "$MODE" = bios ] && ARGS+=(-boot order=dc)
fi

echo "qemu-system-x86_64 ${ARGS[*]}"
exec qemu-system-x86_64 "${ARGS[@]}"
