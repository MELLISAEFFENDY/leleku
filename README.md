# 🎣 Modern Fishing Script

A modern, modular Roblox fishing automation script with dark UI theme and floating button system.

## ✨ Features

### 🎨 Modern Dark UI
- **Dark Theme**: Beautiful dark modern interface with smooth animations
- **Floating Button**: Minimize UI to a draggable floating button
- **Responsive Design**: Clean, organized layout with rounded corners and shadows
- **Multi-Window**: Separate windows for different categories

### 🤖 Advanced Automation
- **Auto Cast**: Automatically cast fishing rod
- **Auto Shake**: Automated shake responses for perfect timing
- **Auto Reel**: Automatic reeling when fish is caught
- **Character Freeze**: Keep character in position while fishing
- **Smart Rod Management**: Auto-equip best available rod

### 🌍 Teleportation System
- **Zone Teleports**: Quick travel to all fishing zones
- **Rod Locations**: Teleport to specific rod spawn locations
- **NPC Locations**: Fast travel to merchants and quest givers
- **Player Teleports**: Teleport to other players
- **Favorite Locations**: Save and load custom teleport spots

### ⚙️ Game Modifications
- **Perfect Cast**: Always get 100% cast power
- **Always Catch**: Never lose fish during reeling
- **Infinite Oxygen**: Unlimited underwater breathing
- **No AFK Kick**: Bypass AFK detection
- **Temperature Protection**: Ignore cold/heat effects

### 👁️ Visual Enhancements
- **Rod Chams**: Highlight fishing rods with custom materials
- **Fish Abundance**: Show fish abundance zones
- **Custom Materials**: ForceField and Neon rod materials
- **Real-time Updates**: Live visual feedback

## 📁 Project Structure

```
/workspaces/lele/
├── src/
│   ├── ui/
│   │   ├── library.lua           # Main UI library with floating button
│   │   ├── components/
│   │   │   └── modern.lua        # Modern UI components
│   │   └── themes/
│   │       └── dark.lua          # Dark theme configuration
│   ├── modules/
│   │   ├── automation.lua        # Fishing automation logic
│   │   └── teleports.lua         # Teleportation functionality
│   ├── data/
│   │   └── locations.lua         # All teleport location data
│   └── utils/
│       └── functions.lua         # Utility functions
├── main.lua                      # Main entry point
├── config.lua                    # Global configuration
├── old.lua                       # Original script (legacy)
├── remote.txt                    # Remote events dump
└── README.md                     # This file
```

## 🚀 Quick Start

### Option 1: Direct Load (Recommended)
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/DESIWULANRETNASIH/lele/main/main.lua'))()
```

### Option 2: Local Development
1. Clone this repository
2. Load `main.lua` in your script executor
3. Modify modules as needed

## 🎛️ Usage

### Basic Controls
- **Floating Button**: Click to show/hide all windows
- **Window Controls**: Each window has minimize (─) and close (✕) buttons
- **Dragging**: Drag windows by their title bars
- **Settings**: All settings are automatically saved

### Automation Setup
1. Open the **Automation** window
2. Enable desired automation features:
   - Toggle "Auto Cast" for automatic rod casting
   - Toggle "Auto Shake" for automatic shake responses  
   - Toggle "Auto Reel" for automatic fish reeling
3. Configure "Freeze Character" to stay in position

### Teleportation
1. Open the **Teleports** window
2. Select destination from dropdowns:
   - **Zones**: All fishing areas
   - **Rods**: Rod spawn locations
   - **NPCs**: Merchant and quest locations
   - **Players**: Other players in the server
3. Click corresponding teleport button

### Visual Enhancements
1. Open the **Visuals** window
2. Enable visual features:
   - "Rod Chams" for rod highlighting
   - "Fish Abundance Zones" to see fishing hotspots
3. Choose material type (ForceField/Neon)

## ⚙️ Configuration

Edit `config.lua` to customize:
- UI theme and colors
- Animation speeds
- Feature toggles
- Performance settings
- Default values

## 🔧 Advanced Features

### Custom Locations
```lua
-- Save current position as favorite
Teleports.SaveFavoriteLocation("My Spot", Utils.GetCurrentPosition())

-- Teleport to saved location
Teleports.TeleportToFavoriteLocation("My Spot")
```

### Automation Control
```lua
-- Get automation status
local stats = Automation.GetAutomationStats()

-- Manually trigger rod selection
Automation.EquipBestRod()
```

### Notifications
```lua
-- Create custom notification
Utils.CreateNotification("Custom message", 5) -- 5 second duration
```

## 🛠️ Development

### Adding New Features
1. Create module in appropriate folder (`src/modules/`, `src/ui/components/`)
2. Export functions from module
3. Import and use in `main.lua`
4. Update configuration if needed

### Creating UI Components
```lua
local Components = require(script.Parent.ui.components.modern)

-- Create custom button
local myButton = Components.CreateButton(parent, {
    Text = "My Button",
    Size = UDim2.new(0, 120, 0, 30),
    Callback = function()
        print("Button clicked!")
    end
})
```

### Theme Customization
Edit `src/ui/themes/dark.lua` to modify:
- Colors and transparency
- Fonts and sizes
- Animation settings
- Gradients

## 📊 Performance

- **Modular Design**: Only load needed components
- **Efficient Loops**: Optimized automation loops
- **Memory Management**: Automatic cleanup
- **FPS Monitoring**: Built-in performance tracking

## 🔒 Security

- **Anti-Detection**: Randomized timing and human-like delays
- **Safe Teleports**: Validation before teleportation
- **Error Handling**: Graceful fallbacks for failed operations
- **No Malicious Code**: Open source and transparent

## 🐛 Troubleshooting

### Common Issues
1. **UI Not Loading**: Check if script executor supports required functions
2. **Teleports Failing**: Ensure character is loaded and valid
3. **Automation Not Working**: Verify game remotes are accessible
4. **Performance Issues**: Disable unused features in config

### Debug Mode
Enable debug mode in `config.lua`:
```lua
Config.Debug.EnableDebugMode = true
```

## 📝 Changelog

### Version 2.0.0 (2025-09-01)
- ✨ Complete rewrite with modular architecture
- 🎨 New dark modern UI with floating button
- 🚀 Improved performance and memory usage
- 📱 Better mobile compatibility
- 🔧 Advanced configuration system
- 💾 Automatic settings save/load

### Version 1.0.0 (Legacy)
- Basic fishing automation
- Simple teleportation
- Original UI design

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## ⚠️ Disclaimer

This script is for educational purposes only. Use at your own risk. The developers are not responsible for any consequences of using this script, including but not limited to account bans or data loss.

## 🙏 Credits

- **UI Design**: Inspired by modern dark themes
- **Architecture**: Modular design patterns
- **Community**: Thanks to all contributors and testers

---

*Made with ❤️ for the Roblox fishing community*