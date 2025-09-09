#!/bin/bash

if [ ! -f /etc/udev/rules.d/99-battery.rules ]; then
  cat <<EOF | sudo tee /etc/udev/rules.d/99-battery.rules
SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/local/bin/on_battery.sh"
SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/local/bin/on_ac.sh"
EOF
fi

if [ ! -f /usr/local/bin/on_battery.sh ]; then
  cat <<EOF | sudo tee /usr/local/bin/on_battery.sh
#!/usr/bin/bash

# Change Dirty Writeback Centisecs according to TLP / Powertop
echo '5000' > '/proc/sys/vm/dirty_writeback_centisecs';

# Change AMD Paste EPP energy preference
# Available profiles: performance, balance_performance, balance_power, power
echo 'balance_power' | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference;

# If required, change cpu scaling governor
# Possible options are: conservative ondemand userspace powersave performance schedutil
#cpupower frequency-set -g powersave;

# Platform Profiles Daemon will do this automatically, based on your settings in KDE / GNOME
# You can how ever, set this manually as well
# Possible profile options are: performance, powersave, low-power
#echo 'powersave' > '/sys/firmware/acpi/platform_profile';

# Radeon AMDGPU DPM switching doesn't seem to be supported.
# Possible options should be: battery, balanced, performance, auto
#echo 'battery' > '/sys/class/drm/card0/device/power_dpm_state'; 

# Should always be auto (TLP default = auto)
# Possible options are: auto, high, low
#echo 'auto' > '/sys/class/drm/card0/device/power_dpm_force_performance_level';

# Runtime PM for PCI Device to auto
find /sys/bus/pci/devices/*/power -name control -exec sh -c 'echo "auto" > "$1"' _ {} \;
for i in \$(find /sys/devices/pci0000\:00/0* -maxdepth 3 -name control); do
    echo auto > \$i;
done
EOF
  sudo chmod +x /usr/local/bin/on_battery.sh
fi

if [ ! -f /usr/local/bin/on_ac.sh ]; then
  cat <<EOF | sudo tee /usr/local/bin/on_ac.sh
#!/usr/bin/bash

# Change Dirty Writeback Centisecs according to TLP / Powertop
echo '500' > '/proc/sys/vm/dirty_writeback_centisecs';

# Change AMD Paste EPP energy preference
# Available profiles: performance, balance_performance, balance_power, power
echo 'balance_performance' | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference;

# If required, change cpu scaling governor
# Possible options are: conservative ondemand userspace powersave performance schedutil
#cpupower frequency-set -g performance;

# Platform Profiles Daemon will do this automatically, based on your settings in KDE / GNOME
# You can how ever, set this manually as well
# Possible profile options are: performance, powersave, low-power
#echo 'performance' > '/sys/firmware/acpi/platform_profile';

# Radeon AMDGPU DPM switching doesn't seem to be supported.
# Possible options should be: battery, balanced, performance, auto
#echo 'performance' > '/sys/class/drm/card0/device/power_dpm_state';

# Should always be auto (TLP default = auto)
# Possible options are: auto, high, low
#echo 'auto' > '/sys/class/drm/card0/device/power_dpm_force_performance_level';

# Runtime PM for PCI Device to on
find /sys/bus/pci/devices/*/power -name control -exec sh -c 'echo "on" > "$1"' _ {} \;
for i in \$(find /sys/devices/pci0000\:00/0* -maxdepth 3 -name control); do
    echo on > \$i;
done
EOF
  sudo chmod +x /usr/local/bin/on_ac.sh
fi

# Enable power-profiles-daemon only if not already disabled
if ! systemctl is-enabled power-profiles-daemon | grep -q enabled; then
  sudo systemctl enable power-profiles-daemon
fi
