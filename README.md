# 🏠 Sinric Pro Light Controller

A beautiful and interactive terminal-based controller for managing your Sinric Pro smart lights directly from Linux!

<img width="814" alt="main-menu" src="https://github.com/user-attachments/assets/1ee5ddc9-3d98-4ff3-98db-98bf21112231" />

## ✨ Features

- 🎨 **Beautiful Terminal UI** - Colorful and intuitive interface
- 💡 **Real-time Status** - See which lights are ON/OFF at a glance
- ⚡ **Quick Controls** - Single keypress to control your lights
- 🔄 **Auto Refresh** - Status updates after each action
- 🌈 **Visual Indicators** - Progress bars and color-coded status
- 🚀 **Fast & Lightweight** - Pure bash script, no heavy dependencies

## 📸 Screenshots

<img width="814" alt="main-menu" src="https://github.com/user-attachments/assets/1ee5ddc9-3d98-4ff3-98db-98bf21112231" />

*Interactive menu with real-time status display*

## 🔧 Prerequisites

- Linux system (tested on Debian/Ubuntu)
- `curl` installed
- Sinric Pro account with configured devices
- Active internet connection

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/sinric-pro-controller.git
cd sinric-pro-controller
```

### 2. Configure Your Credentials

Open `novara_controller.sh` and update the following lines with your Sinric Pro credentials:

```bash
API_KEY="your-api-key-here"
LAMP_SHED_ID="your-lamp-shed-device-id"
TABLE_LAMP_ID="your-table-lamp-device-id"
```

**How to get your credentials:**

1. Go to [Sinric Pro Dashboard](https://sinric.pro)
2. **API Key**: Navigate to **Credentials** → Click **"Create API Key"**
3. **Device IDs**: Go to **Devices** → Click on each device to see its ID

### 3. Make it Executable

```bash
chmod +x novara_controller.sh
```

### 4. Run the Controller

```bash
./novara_controller.sh
```

## 🎮 Usage

Once you run the script, you'll see an interactive menu with the following options:

| Key | Action |
|-----|--------|
| `1` | Turn Lamp Shed ON |
| `2` | Turn Lamp Shed OFF |
| `3` | Turn Table Lamp ON |
| `4` | Turn Table Lamp OFF |
| `5` | Turn ALL Lights ON |
| `6` | Turn ALL Lights OFF |
| `r` | Refresh Status |
| `0` | Exit |

Just press the corresponding key - no need to press Enter!

## 🔌 Hardware Setup

This controller works with:

- **ESP32** (38-pin or any variant)
- **Relay modules** connected to GPIO pins
- **Sinric Pro integration** in your ESP32 firmware

### Example ESP32 Setup:
```
ESP32 → Relay 1 → Lamp Shed
ESP32 → Relay 2 → Table Lamp
```

Your ESP32 should be running Sinric Pro compatible firmware with your App Key and App Secret configured.

## 📝 Adding More Devices

Want to control more lights? Easy!

1. Add device in Sinric Pro dashboard
2. Update your ESP32 code to include the new device
3. Edit the script and add:

```bash
NEW_DEVICE_ID="your-new-device-id"
```

4. Add new menu options in the `show_menu()` function

## 🛠️ Troubleshooting

### Script says "Failed to get access token"
- Check if your API Key is correct
- Ensure you have internet connection
- Verify your Sinric Pro account is active

### Commands don't control the lights
- Make sure your ESP32 is powered on and connected to WiFi
- Verify device IDs are correct (no extra spaces)
- Check if devices are online in Sinric Pro dashboard

### Status shows "Unknown"
- Device might be offline
- Check ESP32 connection
- Restart your ESP32 device

## 🌟 Optional Enhancements

### Create System Alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias lights='~/sinric-pro-controller/novara_controller.sh'
```

Then just type `lights` from anywhere!

### Run on System Startup

Create a desktop shortcut or add to startup applications for quick access.

## 📦 Dependencies

- `bash` (pre-installed on most Linux systems)
- `curl` - Install with: `sudo apt install curl`

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Sinric Pro](https://sinric.pro) for the awesome IoT platform
- ESP32 community for hardware inspiration

## 💬 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/sinric-pro-controller/issues) page
2. Create a new issue with details about your problem
3. Visit [Sinric Pro Documentation](https://help.sinric.pro)

## 🌐 Links

- [Sinric Pro Website](https://sinric.pro)
- [Sinric Pro API Documentation](https://apidocs.sinric.pro/)
- [ESP32 Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/)

---

Made with ❤️ for the smart home community

⭐ If you find this project useful, please consider giving it a star!
