# Project Log

Running record of work on this project. Newest entries at the top.

## 2026-11-13

- Verified Kali VM backup (`qemu-img check` clean), pruned redundant undated copy
- Tuned XFCE: disabled display compositing via Window Manager Tweaks; confirmed
  existing 1.1 GB swap partition active
- Fixed empty APT sources list (post-install), ran full upgrade: 506 packages,
  kernel 7.1.5 -> 7.2.15
- Added SSH port forward to `run-kali.sh` (host:2222 -> guest:22); connected
  from ChromeOS terminal where clipboard paste works
- Added GitHub Actions CI: `bash -n` syntax check + `shellcheck -S warning`
- Fixed shellcheck failures: added shebang to `qemu_setup.sh`, disabled SC2054
  for QEMU comma-separated arguments
- Documented SSH access in README

## 2026-11-12

- Created repo, pushed initial commit
- Resolved GitHub PAT authentication (token scope, credential helper)
- Downloaded Kali 2026.3 installer ISO; verified size
- Wrote `run-kali.sh` (install / boot / live modes, KVM detection, env overrides)
- Installed Kali to `~/isos/kali.qcow2` (20 GB sparse, 1536 MB RAM, 2 vCPU, KVM)
- Wrote README: prerequisites, usage, overrides, RAM notes, troubleshooting
- Corrected `pgrep` flag in troubleshooting docs (`-af` for full command line)
