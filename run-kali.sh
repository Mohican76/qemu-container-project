#!/usr/bin/env bash
set -euo pipefail

KALI_ISO="${KALI_ISO:-$HOME/isos/kali-linux-2026.3-installer-amd64.iso}"
KALI_DISK="${KALI_DISK:-$HOME/isos/kali.qcow2}"
DISK_SIZE="${DISK_SIZE:-20G}"
RAM_MB="${RAM_MB:-1536}"
VCPUS="${VCPUS:-2}"
MODE="${MODE:-boot}"
DISPLAY_MODE="${DISPLAY_MODE:-gtk}"

die() { echo "ERROR: $*" >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || \
  die "Missing QEMU. Run: sudo apt install -y qemu-system-x86 qemu-utils"

case "$MODE" in install|boot|live) ;; *) die "MODE must be install, boot, or live" ;; esac

if [ "$MODE" != "live" ] && [ ! -f "$KALI_DISK" ]; then
  echo "Creating ${DISK_SIZE} disk at $KALI_DISK"
  qemu-img create -f qcow2 "$KALI_DISK" "$DISK_SIZE" >/dev/null
fi
[ -f "$KALI_ISO" ] || die "ISO not found: $KALI_ISO"

if [ -w /dev/kvm ]; then
  ACCEL=(-enable-kvm -cpu host)
else
  echo "WARNING: /dev/kvm not usable — slow TCG mode" >&2
  ACCEL=(-accel tcg,thread=multi -cpu max)
fi

case "$DISPLAY_MODE" in
  gtk)  DISP=(-display gtk -vga virtio) ;;
  sdl)  DISP=(-display sdl -vga virtio) ;;
  vnc)  DISP=(-display vnc=:0 -vga std) ;;
  none) DISP=(-nographic -serial mon:stdio) ;;
  *) die "DISPLAY_MODE must be gtk, sdl, vnc, or none" ;;
esac

DISK_ARGS=(); BOOT_ARGS=()
case "$MODE" in
  install) DISK_ARGS=(-drive file="$KALI_DISK",if=virtio,format=qcow2)
           BOOT_ARGS=(-cdrom "$KALI_ISO" -boot order=d) ;;
  boot)    DISK_ARGS=(-drive file="$KALI_DISK",if=virtio,format=qcow2)
           BOOT_ARGS=(-boot order=c) ;;
  live)    BOOT_ARGS=(-cdrom "$KALI_ISO" -boot order=d) ;;
esac

echo "Starting Kali (MODE=$MODE, RAM=${RAM_MB}M, VCPUs=$VCPUS, DISPLAY=$DISPLAY_MODE)"
exec qemu-system-x86_64 \
  "${ACCEL[@]}" -m "$RAM_MB" -smp "$VCPUS" \
  "${DISK_ARGS[@]}" "${BOOT_ARGS[@]}" "${DISP[@]}" \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -rtc base=localtime -name "Kali Linux"
