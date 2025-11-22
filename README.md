# DNS Ping Monitor — 2025

Самый честный и красивый живой пинг-мониторинг публичных DNS-серверов прямо в терминале.  
30+ серверов, цветовая индикация, сортировка по реальной задержке, обновление каждые N секунд.

<img src="2025-11-22_13-56.png " alt="Скриншот" width="750"/>

## Особенности

- Только одна зависимость — `fping`
- Работает в любой локали (ru_RU, en_US, etc.)
- Цвета: зелёный (<5 мс) → голубой → жёлтый → фиолетовый → красный
- ТОП-15 самых быстрых (настраивается)

## Установка (одна команда!)

```bash
# Debian / Ubuntu / Mint / WSL
sudo apt update && sudo apt install fping

# Arch / Manjaro
sudo pacman -S fping

# Fedora / CentOS / RHEL
sudo dnf install fping

# Alpine
sudo apk add fping

mkdir -p ~/scripts && cd ~/scripts
wget -O dns-ping.sh https://raw.githubusercontent.com/ТВОЙ-НИК/dns-ping-monitor/main/dns-ping.sh
chmod +x dns-ping.sh

# Добавить в PATH (один раз)
echo 'export PATH="$HOME/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc

Настройка

SLEEP=20        # пауза между обновлениями в секундах
MAX_RANK=15     # сколько лучших показывать в рейтинге
