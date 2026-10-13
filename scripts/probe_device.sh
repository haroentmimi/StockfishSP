#!/bin/sh
# Collects device facts for NOTES.md. Run from the host:
#   ssh root@<device-ip> 'sh -s' < scripts/probe_device.sh | tee probe.txt
echo "== os";        cat /etc/os-release 2>/dev/null; cat /usr/share/batocera/batocera.version 2>/dev/null
echo "== kernel";    uname -a
echo "== glibc";     ldd --version 2>&1 | head -1; ls -l /lib/libc.so.6 /lib64/libc.so.6 /usr/lib/libc.so.6 2>/dev/null
echo "== libstdc++"; ls -l /usr/lib/libstdc++.so* 2>/dev/null
echo "== sdl libs";  ls -l /usr/lib/libSDL2* /usr/lib/libSDL3* 2>/dev/null
echo "== gfx libs";  ls -l /usr/lib/libdrm.so* /usr/lib/libgbm.so* /usr/lib/libEGL.so* /usr/lib/libGLESv2.so* /usr/lib/libmali* 2>/dev/null
echo "== font libs"; ls -l /usr/lib/libfreetype.so* /usr/lib/libpng*.so* 2>/dev/null
echo "== drm/fb";    ls /dev/dri /dev/fb* 2>/dev/null; cat /sys/class/graphics/fb0/virtual_size 2>/dev/null
echo "== cpu";       grep -m1 -i 'features' /proc/cpuinfo; grep -c ^processor /proc/cpuinfo
echo "== cpufreq";   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
echo "== mem";       free -m
echo "== disk";      df -h /userdata 2>/dev/null
echo "== sdl env";   env | grep -i -E 'sdl|gamecontroller' ; ls /usr/share/sdl* /userdata/system/configs/*controller* 2>/dev/null
echo "== inputs";    grep -E '^(N|H):' /proc/bus/input/devices
echo "== ports";     ls -la /userdata/roms/ports 2>/dev/null | head -20
echo "== tools";     for t in rsync scp gdb strace; do printf '%s: ' $t; command -v $t || echo missing; done
