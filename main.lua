--[[
    Modern Fishing Script
    A modular, modern UI-based fishing automation script
    
    Features:
    - Dark modern UI with floating button
    - Modular architecture
    - Advanced automation
    - Teleportation system
    - Visual enhancements
    - Game modifications
]]--

-- Load modules
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/ui/library.lua'))()
local Automation = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/modules/automation.lua'))()
local Teleports = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/modules/teleports.lua'))()
local Utils = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/utils/functions.lua'))()

-- For local development, use these instead:
--[[
local Library = require(script.Parent.src.ui.library)
local Automation = require(script.Parent.src.modules.automation)
local Teleports = require(script.Parent.src.modules.teleports)
local Utils = require(script.Parent.src.utils.functions)
--]]

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

-- Variables
local LocalPlayer = Players.LocalPlayer
local flags = {}

-- Initialize notification
Utils.CreateNotification("🎣 Modern Fishing Script Loaded!", 5)
Utils.CreateNotification("Press the floating button to open/close UI", 3)

-- Create main windows
local AutomationWindow = Library:CreateWindow('🤖 Automation', {
    Size = UDim2.new(0, 400, 0, 450),
    Position = UDim2.new(0, 50, 0, 50)
})

local TeleportsWindow = Library:CreateWindow('🌍 Teleports', {
    Size = UDim2.new(0, 400, 0, 500),
    Position = UDim2.new(0, 470, 0, 50)
})

local ModificationsWindow = Library:CreateWindow('⚙️ Modifications', {
    Size = UDim2.new(0, 400, 0, 400),
    Position = UDim2.new(0, 50, 0, 520)
})

local VisualsWindow = Library:CreateWindow('👁️ Visuals', {
    Size = UDim2.new(0, 400, 0, 350),
    Position = UDim2.new(0, 470, 0, 570)
})

-- Setup Automation Window
Automation.CreateAutomationSection(AutomationWindow, flags)
Automation.CreateAdvancedSection(AutomationWindow, flags)

-- Setup Teleports Window
Teleports.CreateTeleportSection(TeleportsWindow)

-- Setup Modifications Window
ModificationsWindow:Section('🔧 Game Modifications')

-- Hook-based modifications (if supported)
if Utils.CheckFunc(hookmetamethod) then
    ModificationsWindow:Toggle('No AFK Kick', {
        location = flags,
        flag = 'noafk',
        default = false,
        callback = function(value)
            flags.noafk = value
            if value then
                Utils.CreateNotification("AFK Protection enabled", 2)
            else
                Utils.CreateNotification("AFK Protection disabled", 2)
            end
        end
    })
    
    ModificationsWindow:Toggle('Perfect Cast', {
        location = flags,
        flag = 'perfectcast',
        default = false,
        callback = function(value)
            flags.perfectcast = value
            if value then
                Utils.CreateNotification("Perfect Cast enabled", 2)
            else
                Utils.CreateNotification("Perfect Cast disabled", 2)
            end
        end
    })
    
    ModificationsWindow:Toggle('Always Catch Fish', {
        location = flags,
        flag = 'alwayscatch',
        default = false,
        callback = function(value)
            flags.alwayscatch = value
            if value then
                Utils.CreateNotification("Always Catch enabled", 2)
            else
                Utils.CreateNotification("Always Catch disabled", 2)
            end
        end
    })
end

-- Client-side modifications
ModificationsWindow:Section('💨 Client Modifications')

ModificationsWindow:Toggle('Infinite Oxygen', {
    location = flags,
    flag = 'infoxygen',
    default = false,
    callback = function(value)
        flags.infoxygen = value
        if value then
            Utils.CreateNotification("Infinite Oxygen enabled", 2)
        else
            Utils.CreateNotification("Infinite Oxygen disabled", 2)
        end
    end
})

ModificationsWindow:Toggle('No Temperature/Oxygen Loss', {
    location = flags,
    flag = 'nopeakssystems',
    default = false,
    callback = function(value)
        flags.nopeakssystems = value
        if value then
            Utils.CreateNotification("Temperature/Oxygen protection enabled", 2)
        else
            Utils.CreateNotification("Temperature/Oxygen protection disabled", 2)
        end
    end
})

-- Setup Visuals Window
VisualsWindow:Section('🎨 Visual Enhancements')

VisualsWindow:Toggle('Rod Chams', {
    location = flags,
    flag = 'rodchams',
    default = false,
    callback = function(value)
        flags.rodchams = value
        if value then
            Utils.CreateNotification("Rod Chams enabled", 2)
        else
            Utils.CreateNotification("Rod Chams disabled", 2)
        end
    end
})

VisualsWindow:Toggle('Body Rod Chams', {
    location = flags,
    flag = 'bodyrodchams',
    default = false,
    callback = function(value)
        flags.bodyrodchams = value
        if value then
            Utils.CreateNotification("Body Rod Chams enabled", 2)
        else
            Utils.CreateNotification("Body Rod Chams disabled", 2)
        end
    end
})

VisualsWindow:Dropdown('Rod Material', {
    location = flags,
    flag = 'rodmaterial',
    list = {'ForceField', 'Neon'},
    callback = function(selected)
        flags.rodmaterial = selected
    end
})

VisualsWindow:Section('🐟 Fish Detection')

VisualsWindow:Toggle('Fish Abundance Zones', {
    location = flags,
    flag = 'fishabundance',
    default = false,
    callback = function(value)
        flags.fishabundance = value
        if value then
            Utils.CreateNotification("Fish Abundance Zones visible", 2)
        else
            Utils.CreateNotification("Fish Abundance Zones hidden", 2)
        end
    end
})

-- Game modification loops
local modificationConnections = {}

-- Start modification loops
local function startModificationLoops()
    -- Infinite Oxygen
    modificationConnections.oxygen = RunService.Heartbeat:Connect(function()
        if flags.infoxygen then
            local character = Utils.GetCharacter()
            if character then
                local divingTank = character:FindFirstChild('DivingTank')
                if not divingTank then
                    local tank = Instance.new('Decal')
                    tank.Name = 'DivingTank'
                    tank.Parent = character
                    tank:SetAttribute('Tier', math.huge)
                end
            end
        end
        
        if flags.nopeakssystems then
            local character = Utils.GetCharacter()
            if character then
                character:SetAttribute('WinterCloakEquipped', true)
                character:SetAttribute('Refill', true)
            end
        else
            local character = Utils.GetCharacter()
            if character then
                character:SetAttribute('WinterCloakEquipped', nil)
                character:SetAttribute('Refill', false)
            end
        end
    end)
    
    -- Visual modifications
    modificationConnections.visuals = RunService.Heartbeat:Connect(function()
        -- Fish Abundance
        if flags.fishabundance then
            for _, zone in workspace.zones.fishing:GetChildren() do
                if Utils.FindChildOfType(zone, 'Abundance', 'StringValue') and 
                   Utils.FindChildOfType(zone, 'radar1', 'BillboardGui') then
                    zone.radar1.Enabled = true
                    zone.radar2.Enabled = true
                end
            end
        else
            for _, zone in workspace.zones.fishing:GetChildren() do
                if Utils.FindChildOfType(zone, 'Abundance', 'StringValue') and 
                   Utils.FindChildOfType(zone, 'radar1', 'BillboardGui') then
                    zone.radar1.Enabled = false
                    zone.radar2.Enabled = false
                end
            end
        end
        
        -- Rod Chams (simplified version)
        if flags.rodchams or flags.bodyrodchams then
            local rod = Utils.FindRod()
            if rod and flags.rodchams then
                for _, part in rod:GetDescendants() do
                    if part:IsA('BasePart') then
                        part.Material = Enum.Material[flags.rodmaterial or 'ForceField']
                        part.Color = Color3.fromRGB(100, 100, 255)
                    end
                end
            end
            
            if flags.bodyrodchams then
                local character = Utils.GetCharacter()
                local bodyRod = character:FindFirstChild('RodBodyModel')
                if bodyRod then
                    for _, part in bodyRod:GetDescendants() do
                        if part:IsA('BasePart') then
                            part.Material = Enum.Material[flags.rodmaterial or 'ForceField']
                            part.Color = Color3.fromRGB(100, 100, 255)
                        end
                    end
                end
            end
        end
    end)
end

-- Setup hooks if available
if Utils.CheckFunc(hookmetamethod) then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = getnamecallmethod(), {...}
        
        if method == 'FireServer' and self.Name == 'afk' and flags.noafk then
            args[1] = false
            return oldNamecall(self, unpack(args))
        elseif method == 'FireServer' and self.Name == 'cast' and flags.perfectcast then
            args[1] = 100
            return oldNamecall(self, unpack(args))
        elseif method == 'FireServer' and self.Name == 'reelfinished' and flags.alwayscatch then
            args[1] = 100
            args[2] = true
            return oldNamecall(self, unpack(args))
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Initialize everything
startModificationLoops()

-- Add cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        -- Cleanup connections
        for _, connection in pairs(modificationConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        Automation.Cleanup()
        Library:DestroyAll()
    end
end)

-- Performance monitoring
task.spawn(function()
    while task.wait(60) do -- Check every minute
        local fps = Utils.GetFPS()
        if fps < 30 then
            Utils.DebugWarn("Low FPS detected: " .. fps)
        end
    end
end)

-- Success notification
task.wait(1)
Utils.CreateNotification("✅ All systems loaded successfully!", 3)

-- Save settings periodically
task.spawn(function()
    while task.wait(30) do -- Save every 30 seconds
        Utils.SaveData('settings.json', flags)
    end
end)

-- Load saved settings
local savedSettings = Utils.LoadData('settings.json')
if savedSettings then
    for key, value in pairs(savedSettings) do
        flags[key] = value
    end
    Utils.CreateNotification("⚙️ Settings loaded from previous session", 2)
end
