# Chia & NoSSD Farming Log Monitor
NoSsd_Monitor/
├── m.sh                 # Main log monitoring script
├── check_disks_auto.sh  # Known-disk check on system boot
├── README.md
├── .gitignore





2️⃣ Make Scripts Executable
chmod +x m.sh ch 2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
# Chia & NoSSD Farming Log Monitor
## ⚙️ Requirements

- Linux (Ubuntu recommended)
- Bash
- curl
- awk
- date
- Telegram Bot Token

Optional:
- smartmontools (for advanced disk checks)

---

eck_disks_auto.sh

🤖 Telegram Bot Setup
 1. Create a bot using @BotFather
 2. Copy the BOT_TOKEN
 3. Add the bot to your Telegram group/channel
 4. Get the chat ID

Edit m.sh:
BOT_TOKEN="PUT BOT TOKEN HERE"
CHAT_HOURLY="HOURLY REPORT CHAT ID"
CHAT_ALERTS="ALERT CHAT ID"


▶️ Usage

Start Log Monitoring

Run from the directory containing your NoSSD / Chia log files:
./m.sh

What it does:
 • Sends hourly share reports every :30 (12:30, 13:30, 14:30, …)
 • Sends daily 24h summary
 • Sends instant alerts on slow or missed signage points

The script automatically tracks the latest .log file, even if the filename changes.

⸻

🖥️ Disk Check on Boot (Optional)

To run disk checks on system startup:
sudo cp check_disks_auto.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/check_disks_auto.sh

Add to crontab:

sudo crontab -e

@reboot /usr/local/bin/check_disks_auto.sh


🧠 Design Notes
 • Pure Bash (no Python, no Node)
 • Low CPU & RAM usage
 • Suitable for headless farming rigs
 • Safe for long-running execution
 • Separate channels for stats and alerts

⸻

🔒 Security Notes
 • Never commit your real bot token
 • Use .gitignore if needed
 • Telegram bots should have minimal permissions

⸻

📌 Use Cases
 • NoSSD farming monitoring
 • Chia plot/farm health tracking
 • Linux server log monitoring
 • Telegram-based alerting system
 • DevOps lightweight observability

⸻

📄 License

MIT License

⸻

🤝 Contributions

Pull requests are welcome.
Issues and improvements are appreciated.
