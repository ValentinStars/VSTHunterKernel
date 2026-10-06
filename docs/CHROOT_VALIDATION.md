# A51 chroot checks — 2026-10-06

Tested on the installed d810c755d Alpha5 kernel, EvolutionX Android 16.
The terminal helper was then updated separately; no additional kernel flash.

| Check | Kali / NetHunter | ANDRAX | Stryker |
| --- | --- | --- | --- |
| Root, hostname VST, proc, TUN, shared devpts | Pass | Pass | Pass |
| 16 MiB random file, fsync, reread SHA256 | Pass | Pass | Pass |
| Python, Perl, OpenSSL | Pass | Pass | Pass |
| Ruby, PHP | Pass | Pass | Not installed |
| Compile and run a C program | Pass | Pass | Compiler not installed |
| DNS, local TCP echo, Nmap TCP scan of localhost only | Pass | Pass | Pass |
| Interactive sleep interrupted with Ctrl+C; shell continues | Pass | Pass | Pass |

Kali export and unmount both refused while chroot processes were active.
The image remained mounted. Full export/restore was not attempted on the live
11 GiB rootfs with only about 2.6 GiB free on Android internal storage.
Existing user sessions were preserved.

## Terminal corrections

The launcher now checks whether the selected TERM exists in the rootfs terminfo.
The laptop supplied xterm-kitty, absent in Kali. The tested fallback is
xterm-256color; tput colors returns 256. Supported terminal types are preserved.
This does not change Android LiveBoot colors or log levels.

Explicit programs launched from a terminal, such as nh pwsh, now receive the
same Magisk controlling PTY as the default login shell. The internal marker is
placed before program arguments and consumed once. Noninteractive arguments,
including embedded quotes and spaces, retain their boundaries.

## Kali PowerShell

The pre-existing /opt/microsoft/powershell/pwsh failed at startup because its
old .NET runtime could not load the installed ICU78. Its original files remain.
A separate official ARM64 installation was added at
/opt/microsoft/powershell-7.6.6, with /usr/local/bin/pwsh pointing to it.
The existing user profile was preserved.

Official asset: https://github.com/PowerShell/PowerShell/releases/tag/v7.6.6
powershell-7.6.6-linux-arm64.tar.gz SHA256:
924829e54c983648f6f1419a2dc7f9433c861b2fb5bd57736ff096c24f133729

Version output, hostname VST, profile load, file write/read and Get-FileHash passed.
The ordinary interactive PSReadLine test through a headless PTY did not pass:
the automation did not implement terminal cursor-position replies. Command-mode
results do not certify every interactive editor feature. No global ICU invariant
mode or Android runtime replacement was applied.

To undo only this added command, remove the /usr/local/bin/pwsh symlink after
checking it still points at the recorded installation. Keep the original /opt
installation and the user's profile. Close running PowerShell sessions before
removing the added version directory.
