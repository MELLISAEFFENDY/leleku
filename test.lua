-- Enhanced test script untuk verifikasi loading
print("🧪 Enhanced Testing Lele Fishing Script v2...")
print("=" .. string.rep("=", 50))

-- Test loading main script with detailed error reporting
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/main.lua'))()
end)

if success then
    print("✅ Script loaded successfully!")
    print("🎉 All modules should be loaded now")
    print("📝 Check the output above for any warnings")
    
    -- Wait a bit for UI to initialize
    wait(2)
    
    -- Try to verify UI is working
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local modernUI = playerGui:FindFirstChild("ModernUILibrary")
    
    if modernUI then
        print("✅ UI System created successfully!")
        print("🎮 Look for windows or floating button in the UI")
    else
        print("⚠️ UI System not found, but script loaded")
    end
    
    -- Give some usage instructions
    print("\n" .. string.rep("=", 50))
    print("🎮 USAGE INSTRUCTIONS:")
    print("• Look for the floating button in the top-right corner")
    print("• Click it to open/close the GUI")
    print("• Enable Auto Cast for automatic fishing")
    print("• Use teleport features to move between zones")
    print("=" .. string.rep("=", 50))
else
    print("❌ Script failed to load:")
    print("🔴 Error Details:", tostring(result))
    print("\n🔧 Troubleshooting:")
    print("• Make sure you're in the Fisch game")
    print("• Check your internet connection")
    print("• Try running the script again")
    print("• Some errors (like animation IDs) are normal and don't affect functionality")
end
