-- Simple test script to verify loading works
print("🎣 Loading Lele Fishing Script...")

-- Test loading main script
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/main.lua'))()
end)

if success then
    print("✅ Script loaded successfully!")
else
    print("❌ Error loading script:")
    print(tostring(result))
end
