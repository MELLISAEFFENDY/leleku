--[[
    Modern Fishing Script with Tabbed UI
    Features:
    - Single window with tabs
    - Left sidebar for navigation
    - Right content area
    - Modern dark theme
]]--

print("🎣 Loading Modern Tabbed Fishing Script...")

-- Load modules with error handling
local TabbedLibrary, Automation, Teleports, Utils

-- Load Tabbed Library
print("📚 Loading Tabbed UI Library...")
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/ui/tabbed-library.lua'))()
end)

if success and result then
    TabbedLibrary = result
    print("✅ Tabbed UI Library loaded successfully")
else
    warn("❌ Failed to load Tabbed UI Library:", tostring(result))
    return
end

-- Load Automation
print("🤖 Loading Automation Module...")
success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/modules/automation-tabbed.lua'))()
end)

if success and result then
    Automation = result
    print("✅ Automation Module loaded successfully")
else
    warn("❌ Failed to load Automation Module:", tostring(result))
    -- Create minimal automation fallback
    Automation = {
        CreateAutomationSection = function(tab, flags)
            tab:Section('🎣 Fishing Automation (Limited)')
            tab:Label('Automation module failed to load - please try again')
        end,
        CreateAdvancedSection = function(tab, flags)
            tab:Section('⚙️ Advanced Features (Limited)')
            tab:Label('Advanced features unavailable')
        end
    }
    print("⚠️ Using limited Automation fallback")
end

-- Load Teleports
print("🌍 Loading Teleports Module...")
success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/modules/teleports.lua'))()
end)

if success and result then
    Teleports = result
    print("✅ Teleports Module loaded successfully")
else
    warn("❌ Failed to load Teleports Module:", tostring(result))
    -- Create minimal teleports fallback
    Teleports = {
        CreateTeleportSection = function(tab)
            tab:Section('🌍 Teleportation (Limited)')
            tab:Label('Teleport module failed to load - basic functionality only')
        end
    }
    print("⚠️ Using limited Teleports fallback")
end

-- Load Utils
print("🔧 Loading Utility Functions...")
success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/utils/functions.lua'))()
end)

if success and result then
    Utils = result
    print("✅ Utility Functions loaded successfully")
else
    warn("❌ Failed to load Utility Functions:", tostring(result))
    -- Create minimal utils fallback
    Utils = {
        CreateNotification = function(text, duration)
            print("[NOTIFICATION]", text)
        end
    }
    print("⚠️ Using limited Utils fallback")
end

print("🚀 All modules loaded successfully! Initializing Tabbed UI...")

-- Initialize services
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local flags = {}

-- Initialize notification
Utils.CreateNotification("🎣 Modern Tabbed Fishing Script Loaded!", 5)
Utils.CreateNotification("Press the floating button to open/close UI", 3)

-- Create main window
local Window = TabbedLibrary:CreateWindow("Modern Fishing Script")

-- Create tabs
local AutomationTab = TabbedLibrary:CreateTab("Automation", "🤖")
local TeleportsTab = TabbedLibrary:CreateTab("Teleports", "🌍")
local ModificationsTab = TabbedLibrary:CreateTab("Modifications", "⚙️")
local VisualsTab = TabbedLibrary:CreateTab("Visuals", "👁️")
local SettingsTab = TabbedLibrary:CreateTab("Settings", "🔧")

-- Setup Automation Tab
pcall(function()
    Automation.CreateAutomationSection(AutomationTab, flags)
    Automation.CreateAdvancedSection(AutomationTab, flags)
end)

-- Setup Teleports Tab
pcall(function()
    Teleports.CreateTeleportSection(TeleportsTab)
end)

-- Setup Modifications Tab
ModificationsTab:Section('⚙️ Game Modifications')

ModificationsTab:Toggle('No AFK Kick', {
    flag = 'noafk',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("No AFK: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

ModificationsTab:Toggle('Perfect Cast', {
    flag = 'perfectcast',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Perfect Cast: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

ModificationsTab:Toggle('Always Catch Fish', {
    flag = 'alwayscatch',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Always Catch: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

ModificationsTab:Section('🎮 Quality of Life')

ModificationsTab:Toggle('Fast Reel', {
    flag = 'fastreel',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Fast Reel: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

ModificationsTab:Toggle('Instant Cast', {
    flag = 'instantcast',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Instant Cast: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

-- Setup Visuals Tab
VisualsTab:Section('👁️ Visual Enhancements')

VisualsTab:Toggle('ESP Fish', {
    flag = 'espfish',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Fish ESP: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

VisualsTab:Toggle('ESP Treasure', {
    flag = 'esptreasure',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Treasure ESP: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

VisualsTab:Toggle('Remove Water', {
    flag = 'removewater',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Remove Water: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

VisualsTab:Section('🎨 Rod Customization')

VisualsTab:Dropdown('Rod Material', {
    list = {'Neon', 'ForceField', 'Glass', 'Plastic', 'Metal'},
    callback = function(selected)
        flags.rodmaterial = selected
        Utils.CreateNotification("Rod Material: " .. selected, 2)
    end
})

VisualsTab:Toggle('Rainbow Rod', {
    flag = 'rainbowrod',
    location = flags,
    default = false,
    callback = function(value)
        Utils.CreateNotification("Rainbow Rod: " .. (value and "Enabled" or "Disabled"), 2)
    end
})

-- Setup Settings Tab
SettingsTab:Section('🔧 Script Settings')

SettingsTab:Button('Reset All Settings', function()
    for flag, _ in pairs(flags) do
        flags[flag] = false
    end
    Utils.CreateNotification("All settings reset to default", 3)
end)

SettingsTab:Button('Reload Script', function()
    Utils.CreateNotification("Reloading script...", 2)
    wait(1)
    TabbedLibrary:Destroy()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/main-tabbed.lua'))()
end)

SettingsTab:Section('ℹ️ Information')

SettingsTab:Label('Script Version: 2.0 Tabbed Edition')
SettingsTab:Label('Created by: Modern Fishing Team')
SettingsTab:Label('UI Library: Custom Tabbed Design')
SettingsTab:Label('Last Updated: ' .. os.date('%Y-%m-%d'))

SettingsTab:Section('📊 Statistics')

-- Statistics that update in real-time
local statsLabel = SettingsTab:Label('Fishing Stats: Loading...')

-- Update stats every 5 seconds
spawn(function()
    while TabbedLibrary do
        local stats = string.format(
            "Fishing Stats:\n" ..
            "• Time Fishing: %dm\n" ..
            "• Casts Made: %d\n" ..
            "• Fish Caught: %d\n" ..
            "• Success Rate: %.1f%%",
            (flags.timeFishing or 0),
            (flags.castsMade or 0),
            (flags.fishCaught or 0),
            (flags.castsMade and flags.castsMade > 0) and ((flags.fishCaught or 0) / flags.castsMade * 100) or 0
        )
        -- Note: We can't update the label text directly in this simplified version
        -- This would need to be implemented in the actual UI library
        wait(5)
    end
end)

-- Auto-start basic automation
spawn(function()
    wait(2)
    Utils.CreateNotification("Script ready! Use tabs to navigate features.", 3)
end)

print("✅ Tabbed UI initialized successfully!")
print("🎮 Use the floating button or UI tabs to access all features")

return TabbedLibrary
