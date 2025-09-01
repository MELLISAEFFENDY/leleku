-- Test script untuk Tabbed UI
print("🧪 Testing New Tabbed UI System...")
print("=" .. string.rep("=", 50))

-- Test loading new tabbed main script
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/main-tabbed.lua'))()
end)

if success then
    print("✅ Tabbed UI Script loaded successfully!")
    print("🎉 New UI system should be visible now")
    
    -- Wait a bit for UI to initialize
    wait(2)
    
    -- Try to verify UI is working
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local tabbedUI = playerGui:FindFirstChild("TabbedUILibrary")
    
    if tabbedUI then
        print("✅ Tabbed UI System created successfully!")
        print("🎮 Look for the new single window with tabs on the left")
    else
        print("⚠️ Tabbed UI System not found, but script loaded")
    end
    
    print("\n" .. string.rep("=", 50))
    print("🎮 NEW TABBED UI FEATURES:")
    print("• Single window design (800x600)")
    print("• Tab menu on the left side (200px width)")
    print("• Content area on the right side")
    print("• Modern dark theme")
    print("• Smooth animations and transitions")
    print("• 5 Main tabs:")
    print("  🤖 Automation - All fishing automation features")
    print("  🌍 Teleports - Zone and NPC teleportation")
    print("  ⚙️ Modifications - Game modifications")
    print("  👁️ Visuals - ESP and visual enhancements")
    print("  🔧 Settings - Script settings and info")
    print("• Floating button for show/hide")
    print("=" .. string.rep("=", 50))
else
    print("❌ Tabbed UI Script failed to load:")
    print("🔴 Error Details:", tostring(result))
    print("\n🔧 Troubleshooting:")
    print("• Make sure you're in the Fisch game")
    print("• Check your internet connection")
    print("• Try the old UI version if this fails:")
    print("  loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/main.lua'))()")
end
