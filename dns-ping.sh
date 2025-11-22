#!/usr/bin/env bash
# =============================================================================
# dns-ping.sh — Мощный живой мониторинг публичных DNS (30+ серверов)
# Автор: ты + Grok
# Лицензия: MIT
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ────────────────────── Настройки ────────────────────────────────────────
SLEEP=20                                          # сколько секунд между обновлениями
MAX_RANK=15                                       # сколько лучших показывать в рейтинге (чтобы не лезло за экран)

# ────────────────────── Список DNS ───────────────────────────────────────
declare -A DNS=(
    ["Cloudflare"]="1.1.1.1"              ["Cloudflare-Sec"]="1.1.1.3"
    ["Cloudflare-Zero"]="1.0.0.1"         ["Google"]="8.8.8.8"
    ["Google-Sec"]="8.8.4.4"              ["Yandex"]="77.88.8.8"
    ["Yandex-Basic"]="77.88.8.1"           ["Yandex-Safe"]="77.88.8.88"
    ["AdGuard"]="94.140.14.14"            ["AdGuard-Sec"]="94.140.15.15"
    ["AdGuard-Family"]="94.140.14.140"    ["Quad9"]="9.9.9.9"
    ["Quad9-Sec"]="9.9.9.11"              ["OpenDNS"]="208.67.222.222"
    ["OpenDNS-Sec"]="208.67.220.220"      ["OpenDNS-Family"]="208.67.222.123"
    ["Comodo"]="8.26.56.26"               ["Comodo-Sec"]="8.20.247.20"
    ["Norton"]="199.85.126.10"            ["Norton-Sec"]="199.85.126.20"
    ["CleanBrowsing"]="185.228.168.9"     ["CleanBrowsing-Sec"]="185.228.169.9"
    ["CleanBrowsing-Family"]="185.228.168.168"
)

# ────────────────────── Цвета ─────────────────────────────────────────────
RED='\033[38;5;196m';  GREEN='\033[38;5;82m'
CYAN='\033[38;5;51m';  YELLOW='\033[38;5;226m'
MAGENTA='\033[38;5;201m'; RESET='\033[0m'

trap 'tput cnorm; echo -e "${RESET}Пока!\n"; exit 0' INT TERM
tput civis

while :; do
    clear
    echo -e "   DNS живой пинг-мониторинг  •  $(date '+%H:%M:%S')   (обновление каждые ${SLEEP}с)\n"

    results=()
    total=${#DNS[@]}

    for name in "${!DNS[@]}"; do
        ip="${DNS[$name]}"
        raw=$(fping -c1 -t900 "$ip" 2>/dev/null | awk -F'[=/]' '{print $NF}' | tr -d ' ' || echo "-")

        if [[ "$raw" == "-" || -z "$raw" ]]; then
            num=9999; display="×××"; color="$RED"
        else
            num=$(echo "$raw" | tr ',' '.' | LC_ALL=C awk '{printf "%.3f", $1}')
            display="$raw"

            if   (( $(echo "$num < 5"   | bc -l) )); then color="$GREEN"
            elif (( $(echo "$num < 15"  | bc -l) )); then color="$CYAN"
            elif (( $(echo "$num < 50"  | bc -l) )); then color="$YELLOW"
            else color="$MAGENTA"; fi
        fi

        printf "%-22s ${color}%10s мс${RESET}\n" "$name" "$display"
        results+=("$num|$name|$color|$display")
    done

    echo -e "\n   ТОП-$MAX_RANK самых быстрых (из $total):"
    printf '%s\n' "${results[@]}" | sort -t'|' -k1,1n | head -n "$MAX_RANK" | while IFS='|' read -r num name color display; do
        if [[ "$display" == "×××" ]]; then
            echo -e "   ${RED}   ×××   ${RESET}→ $name"
        else
            formatted=$(LC_ALL=C printf "%7.3f" "$num")
            echo -e "   ${color}${formatted} мс${RESET} → $name"
        fi
    done

    sleep "$SLEEP"
done
