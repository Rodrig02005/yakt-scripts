#!/system/bin/sh
# YAKT_VERSION=2.0.0

INFO_LOG="/data/data/com.notzeetaa.yakt/files/yakt.log"
ERROR_LOG="/data/data/com.notzeetaa.yakt/files/error.log"

log_info()  { echo "$1" >> "$INFO_LOG"; }
log_error() { echo "$1" >> "$ERROR_LOG"; }

write_value() {
    local file_path="$1"
    local new_value="$2"
    local file_name=$(basename "$file_path")
    if [ ! -f "$file_path" ]; then
        log_error "File $file_name does not exist."
        return 1
    fi
    chmod +w "$file_path" 2>/dev/null
    local old_value
    old_value=$(cat "$file_path")
    if echo "$new_value" > "$file_path" 2>/dev/null; then
        log_info " ○ $file_name: $old_value -> $new_value ✔"
    else
        log_info " ○ $file_name: $old_value -> $new_value ✖"
    fi
}

get_cores() { grep -c ^processor /proc/cpuinfo; }
get_min_granularity() { echo $(( $1 / $(get_cores) )); }
get_wakeup_granularity() { get_min_granularity $1; }

MODULE_PATH="/sys/module"
KERNEL_PATH="/proc/sys/kernel"
MEMORY_PATH="/proc/sys/vm"
KGSL_PATH="/sys/class/kgsl/kgsl-3d0/"

apply_common() {
    write_value "$KERNEL_PATH/sched_schedstats" 0
    write_value "$KERNEL_PATH/printk_devkmsg" off
}

profile_battery() {
    cores=$(get_cores)
    write_value "$KERNEL_PATH/sched_autogroup_enabled" 0
    write_value "$KERNEL_PATH/sched_child_runs_first" 0
    write_value "$KERNEL_PATH/sched_nr_migrate" 32
    write_value "$KERNEL_PATH/sched_migration_cost_ns" 5000000
    write_value "$KERNEL_PATH/sched_min_granularity_ns" $(get_min_granularity 3000000)
    write_value "$KERNEL_PATH/sched_wakeup_granularity_ns" $(get_wakeup_granularity 4000000)
    write_value "$KERNEL_PATH/sched_tunable_scaling" 0
    write_value "$KERNEL_PATH/perf_cpu_time_max_percent" $((20 + cores*2))
    write_value "$MEMORY_PATH/vfs_cache_pressure" 100
    write_value "$MEMORY_PATH/stat_interval" 10
    write_value "$MEMORY_PATH/compaction_proactiveness" 0
    write_value "$MEMORY_PATH/page-cluster" 0
    write_value "$MEMORY_PATH/swappiness" 10
    write_value "$MEMORY_PATH/dirty_ratio" 40
    write_value "$MODULE_PATH/workqueue/parameters/power_efficient" Y
    write_value "$KGSL_PATH/throttling" 2
    write_value "$KGSL_PATH/force_no_nap" 0
    write_value "$KGSL_PATH/bus_split" 0
}

profile_balanced() {
    cores=$(get_cores)
    write_value "$KERNEL_PATH/sched_autogroup_enabled" 0
    write_value "$KERNEL_PATH/sched_child_runs_first" 1
    write_value "$KERNEL_PATH/sched_nr_migrate" 32
    write_value "$KERNEL_PATH/sched_migration_cost_ns" 5000000
    write_value "$KERNEL_PATH/sched_min_granularity_ns" $(get_min_granularity 1500000)
    write_value "$KERNEL_PATH/sched_wakeup_granularity_ns" $(get_wakeup_granularity 2000000)
    write_value "$KERNEL_PATH/sched_tunable_scaling" 0
    write_value "$KERNEL_PATH/perf_cpu_time_max_percent" $((10 + cores))
    write_value "$MEMORY_PATH/vfs_cache_pressure" 80
    write_value "$MEMORY_PATH/stat_interval" 10
    write_value "$MEMORY_PATH/compaction_proactiveness" 0
    write_value "$MEMORY_PATH/page-cluster" 0
    write_value "$MEMORY_PATH/swappiness" 60
    write_value "$MEMORY_PATH/dirty_ratio" 60
    write_value "$MODULE_PATH/workqueue/parameters/power_efficient" Y
    write_value "$KGSL_PATH/throttling" 1
    write_value "$KGSL_PATH/force_no_nap" 0
    write_value "$KGSL_PATH/bus_split" 0
}

profile_gaming() {
    cores=$(get_cores)
    write_value "$KERNEL_PATH/sched_autogroup_enabled" 0
    write_value "$KERNEL_PATH/sched_child_runs_first" 1
    write_value "$KERNEL_PATH/sched_nr_migrate" 128
    write_value "$KERNEL_PATH/sched_migration_cost_ns" 5000000
    write_value "$KERNEL_PATH/sched_min_granularity_ns" $(get_min_granularity 750000)
    write_value "$KERNEL_PATH/sched_wakeup_granularity_ns" $(get_wakeup_granularity 1000000)
    write_value "$KERNEL_PATH/sched_tunable_scaling" 0
    write_value "$KERNEL_PATH/perf_cpu_time_max_percent" $((5 + cores/2))
    write_value "$MEMORY_PATH/vfs_cache_pressure" 80
    write_value "$MEMORY_PATH/stat_interval" 10
    write_value "$MEMORY_PATH/compaction_proactiveness" 0
    write_value "$MEMORY_PATH/page-cluster" 0
    write_value "$MEMORY_PATH/swappiness" 100
    write_value "$MEMORY_PATH/dirty_ratio" 80
    write_value "$MODULE_PATH/workqueue/parameters/power_efficient" N
    write_value "$KGSL_PATH/throttling" 1
    write_value "$KGSL_PATH/force_no_nap" 1
    write_value "$KGSL_PATH/bus_split" 1
}

profile_latency() {
    cores=$(get_cores)
    write_value "$KERNEL_PATH/sched_autogroup_enabled" 1
    write_value "$KERNEL_PATH/sched_child_runs_first" 1
    write_value "$KERNEL_PATH/sched_nr_migrate" 4
    write_value "$KERNEL_PATH/sched_migration_cost_ns" 5000000
    write_value "$KERNEL_PATH/sched_min_granularity_ns" $(get_min_granularity 1000000)
    write_value "$KERNEL_PATH/sched_wakeup_granularity_ns" $(get_wakeup_granularity 1500000)
    write_value "$KERNEL_PATH/sched_tunable_scaling" 0
    write_value "$KERNEL_PATH/perf_cpu_time_max_percent" $((2 + cores/4))
    write_value "$MEMORY_PATH/vfs_cache_pressure" 80
    write_value "$MEMORY_PATH/stat_interval" 10
    write_value "$MEMORY_PATH/compaction_proactiveness" 0
    write_value "$MEMORY_PATH/page-cluster" 0
    write_value "$MEMORY_PATH/swappiness" 60
    write_value "$MEMORY_PATH/dirty_ratio" 15
    write_value "$MODULE_PATH/workqueue/parameters/power_efficient" Y
    write_value "$KGSL_PATH/throttling" 1
    write_value "$KGSL_PATH/force_no_nap" 0
    write_value "$KGSL_PATH/bus_split" 1
}

MODE="$1"
PROFILE="$2"

case "$MODE" in
    battery|balanced|gaming|latency)
        :> "$INFO_LOG"; :> "$ERROR_LOG"
        echo -e "[$(date "+%H:%M:%S")] Executing $MODE profile...\n" > "$INFO_LOG"
        apply_common
        "profile_$MODE"
        echo -e "\n[$(date "+%H:%M:%S")] $MODE profile executed" >> "$INFO_LOG"
        ;;
    DNS)
        case "$PROFILE" in
            google)     settings put global private_dns_mode hostname; settings put global private_dns_specifier dns.google ;;
            cloudflare) settings put global private_dns_mode hostname; settings put global private_dns_specifier 1dot1dot1dot1.cloudflare-dns.com ;;
            adguard)    settings put global private_dns_mode hostname; settings put global private_dns_specifier dns.adguard.com ;;
            automatic)  settings put global private_dns_mode opportunistic ;;
        esac
        log_info "[$(date "+%H:%M:%S")] Switched to $PROFILE DNS"
        ;;
    DEX)
        if [ "$PROFILE" = "Speed" ]; then
            log_info "[$(date "+%H:%M:%S")] Dex optimization started (speed)"
            su -c 'pm compile -m speed -a' 2>> "$INFO_LOG"
        elif [ "$PROFILE" = "Extreme" ]; then
            log_info "[$(date "+%H:%M:%S")] Dex optimization started (extreme)"
            su -c 'pm compile -m everything -a' 2>> "$INFO_LOG"
        fi
        log_info "[$(date "+%H:%M:%S")] Dex optimization finished"
        ;;
    oneplus)
        if [ "$PROFILE" = "true" ]; then
            pm disable-user --user 0 com.oplus.battery
            log_info "[$(date "+%H:%M:%S")] Disabled OnePlus FPS cap"
        else
            pm enable com.oplus.battery
            log_info "[$(date "+%H:%M:%S")] Enabled OnePlus FPS cap"
        fi
        ;;
    framerate)
        if [ "$PROFILE" = "true" ]; then
            su -c 'setprop debug.graphics.game_default_frame_rate.disabled 1'
            log_info "[$(date "+%H:%M:%S")] Disabled default framerate for games"
        else
            su -c 'setprop debug.graphics.game_default_frame_rate.disabled 0'
            log_info "[$(date "+%H:%M:%S")] Enabled default framerate for games"
        fi
        ;;
    version)
        echo "2.0.0"
        ;;
    *)
        echo "Usage: yakt.sh <battery|balanced|gaming|latency|DNS|DEX|oneplus|framerate|version> [arg]"
        exit 1
        ;;
esac