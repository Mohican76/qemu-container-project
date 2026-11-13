# QEMU Container Project

A small collection of QEMU launchers and container setup scripts, built for
ChromeOS / Crostini (Debian container) on modest hardware.

Currently included:

- `run-kali.sh` — launch Kali Linux in QEMU (installer, persistent, or live)

## Prerequisites

```bash
sudo apt update
sudo apt install -y qemu-system-x86 qemu-utils
```

You also need a Kali ISO in `~/isos/`, for example:

```bash
mkdir -p ~/isos
cd ~/isos
wget -c https://cdimage.kali.org/current/kali-linux-2026.3-installer-amd64.iso
```

The ISO is intentionally kept outside the repo — `.gitignore` excludes `*.iso`
and `*.qcow2` so VM artifacts never get committed.

## Usage

Run from the project directory:

```bash
cd ~/qemu-container-project
./run-kali.sh
```

### Modes

| Mode | Command | What it does |
|---|---|---|
| `install` | `MODE=install ./run-kali.sh` | Boots the ISO, installs Kali onto `~/isos/kali.qcow2` |
| `boot` | `./run-kali.sh` | Boots the installed disk (default) |
| `live` | `MODE=live ./run-kali.sh` | Live session, nothing persists |

The first time through:

1. `MODE=install ./run-kali.sh`
2. In the installer, choose **Graphical install**, and when asked for a disk
   pick **`/dev/vda`** (the virtio disk) — **not** `/dev/sr0` (the ISO).
3. Let GRUB install to **`/dev/vda`**.
4. When the installer finishes and the VM reboots, close the QEMU window.
5. `./run-kali.sh` to boot the installed system.

### Overrides

All settings are environment variables with sensible defaults:

| Variable | Default | Notes |
|---|---|---|
| `RAM_MB` | `1536` | Lower it if the host runs out of memory |
| `VCPUS` | `2` | Match to `nproc` on the host |
| `DISK_SIZE` | `20G` | Sparse qcow2 — grows only as used |
| `KALI_ISO` | `~/isos/kali-linux-2026.3-installer-amd64.iso` | |
| `KALI_DISK` | `~/isos/kali.qcow2` | |
| `DISPLAY_MODE` | `gtk` | One of `gtk`, `sdl`, `vnc`, `none` |

Examples:

```bash
RAM_MB=2048 ./run-kali.sh        # more RAM for the guest
VCPUS=1 ./run-kali.sh            # single vCPU on a busy host
DISPLAY_MODE=vnc ./run-kali.sh   # connect from another machine on :0
```

## RAM notes (ChromeOS / Crostini)

This project was built on a Chromebook with **2.7 GB total RAM and no swap**.
That is tight. Practical guidance:

- `RAM_MB=1536` leaves roughly 1.2 GB for ChromeOS — usable, but the host
  will feel sluggish while the VM runs.
- If ChromeOS itself starts swapping or tabs reload, drop the guest to
  `RAM_MB=1024`.
- Close Chrome tabs before launching — every tab is memory QEMU cannot use.
- If QEMU is killed silently (window disappears, no error), it is almost
  always the OOM killer. Check with:

  ```bash
  dmesg | tail -20 | grep -i -E 'oom|killed process'
  ```

## Troubleshooting

**The VM window disappeared — is it running?**

```bash
pgrep -af qemu-system-x86_64
```

- Output with a PID → still running, just hidden. Use Alt+Tab or the
  ChromeOS shelf.
- No output → it exited. Relaunch in the foreground to see the error:
  `./run-kali.sh`

**"Failed to get 'write' lock" / disk in use**

A stale QEMU still holds the qcow2:

```bash
pkill qemu-system-x86_64
./run-kali.sh
```

**Disk looks suspicious after an abrupt exit**

```bash
qemu-img check ~/isos/kali.qcow2
```

Should print `No errors were found on the image.`

**GUI won't start / display errors**

```bash
DISPLAY_MODE=sdl ./run-kali.sh
```

**Full-screen and mouse grab**

- `Ctrl+Alt+F` — toggle full-screen
- `Ctrl+Alt+G` — release the mouse back to ChromeOS

## SSH access

`run-kali.sh` forwards host port **2222** to the guest's port **22**, so you can
work inside Kali from a ChromeOS terminal where copy/paste works.

Inside the guest, first time only:

```bash
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

From the ChromeOS terminal:

```bash
ssh -p 2222 YOUR_KALI_USERNAME@localhost
```

Replace `YOUR_KALI_USERNAME` with the account you created during install.- `qemu_setup.sh` — older setup helper, kept for reference

