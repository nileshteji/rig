#!/usr/bin/env bash
set -e

export LC_ALL=C

# Sample twice so CPU usage reflects the last second rather than boot time.
CPU=$(/usr/bin/top -l 2 -n 0 -s 1 | /usr/bin/awk '
    /CPU usage/ { usage = $3 + $5; found = 1 }
    END {
        if (found) printf "%.0f%%", usage
        else printf "N/A"
    }
')

# Count anonymous, wired, and compressed RAM, excluding file caches and swap.
TOTAL_MEMORY=$(/usr/sbin/sysctl -n hw.memsize)
MEMORY=$(/usr/bin/vm_stat | /usr/bin/awk -v total="$TOTAL_MEMORY" '
    /page size of/ { page_size = $8 }
    /Anonymous pages:/ { anonymous = $NF }
    /Pages wired down:/ { wired = $NF }
    /Pages occupied by compressor:/ { compressed = $NF }
    END {
        used = (anonymous + wired + compressed) * page_size
        printf "%.1f/%.0fG", used / 1073741824, total / 1073741824
    }
')

printf 'CPU %s | MEM %s' "$CPU" "$MEMORY"
