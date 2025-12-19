# Chia & NoSSD Farming Log Monitor

A lightweight Bash monitoring tool for Chia farming systems, compatible with both:

- Official Chia Blockchain client
- NoSSD farmer

This project monitors farming logs in real time, sends statistics and alerts to Telegram, and performs disk health checks on system startup.

---

## Supported Platforms

✔ Chia Blockchain (official farmer)  
✔ NoSSD  
✔ Ubuntu / Debian-based Linux servers  
✔ Headless / remote systems  

---

## Features

### 📊 Hourly Farming Statistics
- Counts Share generated events (Chia / NoSSD)
- Sends hourly reports at fixed :30 intervals  
  (12:30 → 13:30 → 14:30 → ...)
- Correctly handles cross-midnight windows (23:30 → 00:30)
- Works with both offline logs and live-updating logs

### 🚨 Real-Time Alerts
Automatically forwards critical farming issues to Telegram:
- Too slow read
- Failed to read quality string
- WARNING: Missed signage point

### 📅 Daily (24h) Summary
Once every 24 hours:
- Total shares generated
- Total detected warnings / errors

### 💽 Disk Health Check
- Optional disk health check script
- Designed to run automatically at system boot
- Helps detect failing drives early in large farming setups

---

## How It Works

- Automatically detects the latest `.log` file
- Parses timestamps safely, including logs without full dates
- Uses only standard Linux tools (`bash`, awk, date, `curl`)
- No Python, no Node.js, no heavy dependencies

---

## Requirements

- Bash
- curl
- awk
- coreutils
- Telegram Bot Token

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/chia-log-monitor.git
cd chia-log-monitor
chmod +x m.sh check_disks_auto.sh
# chia-nossd-monitor
