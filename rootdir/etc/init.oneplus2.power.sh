#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

function get-set-forall() {
    for f in $1 ; do
        cat $f
        write $f $2
    done
}

################################################################################

# some files in /sys/devices/system/cpu are created after the restorecon of
# /sys/. These files receive the default label "sysfs".
restorecon -R /sys/devices/system/cpu

# ensure at most one A57 is online when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu4/online 1
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

# files in /sys/devices/system/cpu4 are created after enabling cpu4.
# These files receive the default label "sysfs".
# Restorecon again to give new files the correct label.
restorecon -R /sys/devices/system/cpu

# Limit first time boost frequency
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 960000

# configure governor settings for little cluster
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 384000
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1555200
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 85
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 40000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 960000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "80 384000:33 460800:25 600000:50 672000:65 768000:70 864000:85 960000:90 1248000:92 1555200:98"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 50000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis 166667
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration 0

# configure governor settings for big cluster
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 633600
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 1536000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 90
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 1440000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "74 768000:73 864000:64 960000:80 1248000:61 1344000:69 1440000:64 1536000:74 1632000:69 1728000:67 1824000:72 1958400:85"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 30000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/fast_ramp_down 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration 80000

# restore A57's max
copy /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

# plugin remaining A57s
write /sys/devices/system/cpu/cpu5/online 1
write /sys/devices/system/cpu/cpu6/online 1
write /sys/devices/system/cpu/cpu7/online 1

# input boost configuration
write /sys/kernel/cpu_input_boost/ib_freqs "1344000 1344000"
write /sys/kernel/cpu_input_boost/ib_duration_ms 1400
write /sys/kernel/cpu_input_boost/enabled 1

# Enable core control with custom config
write /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres 95
write /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres 80
write /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms 800
write /sys/devices/system/cpu/cpu4/core_ctl/online_delay_ms 10000
write /sys/devices/system/cpu/cpu4/core_ctl/task_thres 4
write /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster 1
write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 4
write /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 2
write /sys/devices/system/cpu/cpu0/core_ctl/not_preferred 1
write /sys/devices/system/cpu/cpu0/core_ctl/always_online_cpu "1 1 1 1"
write /sys/devices/system/cpu/cpu4/core_ctl/always_online_cpu "1 1 0 0"

# Setting B.L scheduler parameters
write /proc/sys/kernel/sched_migration_fixup 1
write /proc/sys/kernel/sched_small_task 25
write /proc/sys/kernel/sched_upmigrate 95
write /proc/sys/kernel/sched_downmigrate 85
write /proc/sys/kernel/sched_freq_inc_notify 400000
write /proc/sys/kernel/sched_freq_dec_notify 400000

# android background processes are set to nice 10. Never schedule these on the a57s.
write /proc/sys/kernel/sched_upmigrate_min_nice 9

# Enable rps static configuration
write /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus 8

# Devfreq
get-set-forall  /sys/class/devfreq/qcom,cpubw*/governor bw_hwmon
restorecon -R /sys/class/devfreq/qcom,cpubw*
get-set-forall  /sys/class/devfreq/qcom,mincpubw.*/governor cpufreq

# Disable sched_boost
write /proc/sys/kernel/sched_boost 0

# change GPU initial power level from 305MHz(level 4) to 27MHz(level 6) for power savings
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 6

# set GPU default governor to msm-adreno-tz
write /sys/class/devfreq/fdb00000.qcom,kgsl-3d0/governor msm-adreno-tz

# Set normal thermal restrictions
write /sys/kernel/msm_thermal/enabled 0
write /sys/kernel/msm_thermal/zone0 "1555200 1536000 40 38"
write /sys/kernel/msm_thermal/zone1 "1478400 1536000 41 40"
write /sys/kernel/msm_thermal/zone2 "1478400 1440000 42 41"
write /sys/kernel/msm_thermal/zone3 "1344000 1440000 43 42"
write /sys/kernel/msm_thermal/zone4 "1344000 1344000 44 43"
write /sys/kernel/msm_thermal/zone5 "1248000 1344000 46 44"
write /sys/kernel/msm_thermal/zone6 "960000 1248000 48 46"
write /sys/kernel/msm_thermal/zone7 "960000 960000 53 50"
write /sys/kernel/msm_thermal/zone8 "768000 768000 65 60"
write /sys/kernel/msm_thermal/sampling_ms 8000
write /sys/kernel/msm_thermal/enabled 1
