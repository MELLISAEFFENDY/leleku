--[[
    Automation Module
    Handles all fishing automation features
]]--

local Automation = {}

-- Dependencies
local Utils = require(script.Parent.Parent.utils.functions)

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local GuiService = game:GetService('GuiService')

-- Variables
local LocalPlayer = Players.LocalPlayer
local connections = {}
local automationState = {
    autocast = false,
    autoshake = false,
    autoreel = false,
    freezechar = false,
    freezecharmode = 'Rod Equipped',
    characterposition = nil
}

-- Create automation functions for UI
function Automation.CreateAutomationSection(window, flags)
    -- Automation Section
    window:Section('🎣 Fishing Automation')
    
    -- Freeze Character
    window:Toggle('Freeze Character', {
        location = flags,
        flag = 'freezechar',
        default = false,
        callback = function(value)
            automationState.freezechar = value
            if not value then
                automationState.characterposition = nil
            end
        end
    })
    
    window:Dropdown('Freeze Character Mode', {
        location = flags,
        flag = 'freezecharmode',
        list = {'Rod Equipped', 'Toggled'},
        callback = function(selected)
            automationState.freezecharmode = selected
        end
    })
    
    -- Auto Cast
    window:Toggle('Auto Cast', {
        location = flags,
        flag = 'autocast',
        default = false,
        callback = function(value)
            automationState.autocast = value
            if value then
                Utils.CreateNotification("Auto Cast enabled", 2)
            else
                Utils.CreateNotification("Auto Cast disabled", 2)
            end
        end
    })
    
    -- Auto Shake
    window:Toggle('Auto Shake', {
        location = flags,
        flag = 'autoshake',
        default = false,
        callback = function(value)
            automationState.autoshake = value
            if value then
                Utils.CreateNotification("Auto Shake enabled", 2)
            else
                Utils.CreateNotification("Auto Shake disabled", 2)
            end
        end
    })
    
    -- Auto Reel
    window:Toggle('Auto Reel', {
        location = flags,
        flag = 'autoreel',
        default = false,
        callback = function(value)
            automationState.autoreel = value
            if value then
                Utils.CreateNotification("Auto Reel enabled", 2)
            else
                Utils.CreateNotification("Auto Reel disabled", 2)
            end
        end
    })
    
    -- Start automation loop
    Automation.StartAutomationLoop()
end

-- Main automation loop (Enhanced)
function Automation.StartAutomationLoop()
    if connections.automationLoop then
        connections.automationLoop:Disconnect()
    end
    
    connections.automationLoop = RunService.Heartbeat:Connect(function()
        -- Freeze Character Logic
        if automationState.freezechar then
            if automationState.freezecharmode == 'Toggled' then
                if automationState.characterposition == nil then
                    local hrp = Utils.GetHumanoidRootPart()
                    if hrp then
                        automationState.characterposition = hrp.CFrame
                    end
                else
                    local hrp = Utils.GetHumanoidRootPart()
                    if hrp then
                        hrp.CFrame = automationState.characterposition
                    end
                end
            elseif automationState.freezecharmode == 'Rod Equipped' then
                local rod = Utils.FindRod()
                if rod and automationState.characterposition == nil then
                    local hrp = Utils.GetHumanoidRootPart()
                    if hrp then
                        automationState.characterposition = hrp.CFrame
                    end
                elseif rod and automationState.characterposition ~= nil then
                    local hrp = Utils.GetHumanoidRootPart()
                    if hrp then
                        hrp.CFrame = automationState.characterposition
                    end
                else
                    automationState.characterposition = nil
                end
            end
        else
            automationState.characterposition = nil
        end
        
        -- Enhanced Auto Shake Logic
        if automationState.autoshake then
            local playerGui = LocalPlayer.PlayerGui
            if Utils.FindChild(playerGui, 'shakeui') then
                local shakeui = playerGui.shakeui
                if Utils.FindChild(shakeui, 'safezone') and Utils.FindChild(shakeui.safezone, 'button') then
                    GuiService.SelectedObject = shakeui.safezone.button
                    if GuiService.SelectedObject == shakeui.safezone.button then
                        local VirtualInputManager = game:GetService('VirtualInputManager')
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                end
            end
        end
        
        -- Enhanced Auto Cast Logic with new remotes
        if automationState.autocast then
            Automation.EnhancedAutoFishing()
        end
        
        -- Traditional Auto Reel (backup method)
        if automationState.autoreel then
            local rod = Utils.FindRod()
            if rod ~= nil and rod.values.lure.Value == 100 then
                task.wait(0.5)
                if ReplicatedStorage.events:FindFirstChild("reelfinished") then
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                else
                    -- Fallback method
                    rod.events.catchfinish:FireServer(100, true)
                end
            end
        end
        
        -- Auto Equip Best Rod
        if automationState.autoequiprod then
            task.spawn(function()
                task.wait(5) -- Check every 5 seconds
                Automation.EquipBestRod()
            end)
        end
        
        -- Auto Equip Bait
        if automationState.autoequipbait then
            task.spawn(function()
                task.wait(10) -- Check every 10 seconds
                Automation.AutoEquipBait()
            end)
        end
        
        -- Auto Enchant Rod
        if automationState.autoenchantrod then
            task.spawn(function()
                task.wait(30) -- Check every 30 seconds
                local rod = Utils.FindRod()
                if rod then
                    pcall(function()
                        ReplicatedStorage.events.enchantrod:InvokeServer(rod.Name)
                    end)
                end
            end)
        end
        
        -- Auto Currency Management
        if automationState.autobuyupgrades then
            task.spawn(function()
                task.wait(60) -- Check every minute
                Automation.AutoCurrencyManagement()
            end)
        end
    end)
end

-- Advanced automation features
function Automation.CreateAdvancedSection(window, flags)
    window:Section('⚙️ Advanced Automation')
    
    -- Auto Sell Fish (Updated with new remotes)
    window:Toggle('Auto Sell Fish', {
        location = flags,
        flag = 'autosell',
        default = false,
        callback = function(value)
            automationState.autosell = value
            if value then
                Automation.StartAutoSell()
                Utils.CreateNotification("Auto Sell enabled", 2)
            else
                Automation.StopAutoSell()
                Utils.CreateNotification("Auto Sell disabled", 2)
            end
        end
    })
    
    window:Button('Sell Everything Now', function()
        pcall(function()
            ReplicatedStorage.events.selleverything:InvokeServer()
            Utils.CreateNotification("💰 Sold all items!", 2)
        end)
    end)
    
    -- Anti-AFK System
    window:Toggle('Anti-AFK', {
        location = flags,
        flag = 'antiafk',
        default = false,
        callback = function(value)
            automationState.antiafk = value
            if value then
                Automation.StartAntiAFK()
                Utils.CreateNotification("Anti-AFK enabled", 2)
            else
                Automation.StopAntiAFK()
                Utils.CreateNotification("Anti-AFK disabled", 2)
            end
        end
    })
    
    -- Auto Enchant System
    window:Toggle('Auto Enchant Rod', {
        location = flags,
        flag = 'autoenchantrod',
        default = false,
        callback = function(value)
            automationState.autoenchantrod = value
            if value then
                Utils.CreateNotification("Auto Enchant Rod enabled", 2)
            else
                Utils.CreateNotification("Auto Enchant Rod disabled", 2)
            end
        end
    })
    
    window:Button('Enchant Current Rod', function()
        pcall(function()
            local rod = Utils.FindRod()
            if rod then
                ReplicatedStorage.events.enchantrod:InvokeServer(rod.Name)
                Utils.CreateNotification("✨ Enhanced fishing rod!", 2)
            else
                Utils.CreateNotification("❌ No rod equipped!", 2)
            end
        end)
    end)
    
    -- Auto Buy/Equip Bait
    window:Toggle('Auto Equip Bait', {
        location = flags,
        flag = 'autoequipbait',
        default = false,
        callback = function(value)
            automationState.autoequipbait = value
            if value then
                Utils.CreateNotification("Auto Equip Bait enabled", 2)
            else
                Utils.CreateNotification("Auto Equip Bait disabled", 2)
            end
        end
    })
    
    -- Auto Equip Best Rod (Enhanced)
    window:Toggle('Auto Equip Best Rod', {
        location = flags,
        flag = 'autoequiprod',
        default = false,
        callback = function(value)
            automationState.autoequiprod = value
            if value then
                Automation.EquipBestRod()
                Utils.CreateNotification("Auto Equip Rod enabled", 2)
            else
                Utils.CreateNotification("Auto Equip Rod disabled", 2)
            end
        end
    })
    
    -- Fast Travel System
    window:Section('� Travel & Boats')
    
    window:Toggle('Auto Fast Travel', {
        location = flags,
        flag = 'autofasttravel',
        default = false,
        callback = function(value)
            automationState.autofasttravel = value
            if value then
                Utils.CreateNotification("Auto Fast Travel enabled", 2)
            else
                Utils.CreateNotification("Auto Fast Travel disabled", 2)
            end
        end
    })
    
    window:Button('Spawn Best Boat', function()
        pcall(function()
            ReplicatedStorage.packages.Net.RF["Boats/Spawn"]:InvokeServer("FastBoat") -- Adjust boat name as needed
            Utils.CreateNotification("🚢 Boat spawned!", 2)
        end)
    end)
    
    -- Auto Item Management
    window:Section('📦 Item Management')
    
    window:Toggle('Auto Organize Inventory', {
        location = flags,
        flag = 'autoorganize',
        default = false,
        callback = function(value)
            automationState.autoorganize = value
            if value then
                Utils.CreateNotification("Auto Organize enabled", 2)
            else
                Utils.CreateNotification("Auto Organize disabled", 2)
            end
        end
    })
    
    window:Slider('Auto Sell Interval (seconds)', {
        location = flags,
        flag = 'autosellinterval',
        min = 5,
        max = 120,
        default = 30,
        callback = function(value)
            automationState.autosellinterval = value
        end
    })
    
    -- Enhanced Currency System
    window:Section('💎 Currency & Economy')
    
    window:Button('Get Currency Info', function()
        pcall(function()
            ReplicatedStorage.events.getcurrency:FireServer()
            Utils.CreateNotification("💰 Currency info requested", 2)
        end)
    end)
    
    window:Toggle('Auto Buy Upgrades', {
        location = flags,
        flag = 'autobuyupgrades',
        default = false,
        callback = function(value)
            automationState.autobuyupgrades = value
            if value then
                Utils.CreateNotification("Auto Buy Upgrades enabled", 2)
            else
                Utils.CreateNotification("Auto Buy Upgrades disabled", 2)
            end
        end
    })
    
    -- Fishing Stats Enhanced
    window:Section('📊 Enhanced Statistics')
    
    local statsText = "Fish Caught: " .. (automationState.fishCaught or 0) .. 
                     "\nTime Fishing: " .. (automationState.timeFishing or 0) .. "m" ..
                     "\nCasts Made: " .. (automationState.castsMade or 0) ..
                     "\nSuccess Rate: " .. (automationState.successRate or 0) .. "%"
    
    window:Button('Reset Statistics', function()
        automationState.fishCaught = 0
        automationState.timeFishing = 0
        automationState.castsMade = 0
        automationState.successRate = 0
        Utils.CreateNotification("📊 Statistics reset!", 2)
    end)
end

-- Auto sell functionality (Enhanced)
function Automation.StartAutoSell()
    if connections.autoSell then
        connections.autoSell:Disconnect()
    end
    
    connections.autoSell = task.spawn(function()
        while automationState.autosell do
            task.wait(automationState.autosellinterval or 30)
            
            pcall(function()
                -- Try multiple sell methods for better compatibility
                if ReplicatedStorage.events:FindFirstChild("selleverything") then
                    ReplicatedStorage.events.selleverything:InvokeServer()
                elseif ReplicatedStorage.events:FindFirstChild("SellAll") then
                    ReplicatedStorage.events.SellAll:InvokeServer()
                end
                
                Utils.CreateNotification("💰 Auto-sold items", 1)
            end)
        end
    end)
end

function Automation.StopAutoSell()
    if connections.autoSell then
        task.cancel(connections.autoSell)
        connections.autoSell = nil
    end
end

-- Anti-AFK System
function Automation.StartAntiAFK()
    if connections.antiAFK then
        connections.antiAFK:Disconnect()
    end
    
    connections.antiAFK = RunService.Heartbeat:Connect(function()
        pcall(function()
            if ReplicatedStorage.events:FindFirstChild("afk") then
                ReplicatedStorage.events.afk:FireServer(false)
            end
        end)
    end)
end

function Automation.StopAntiAFK()
    if connections.antiAFK then
        connections.antiAFK:Disconnect()
        connections.antiAFK = nil
    end
end

-- Enhanced Auto Equipment System
function Automation.AutoEquipBait()
    pcall(function()
        local bestBait = Automation.FindBestBait()
        if bestBait then
            ReplicatedStorage.packages.Net.RE["Bait/Equip"]:FireServer(bestBait)
            Utils.CreateNotification("🪱 Equipped " .. bestBait, 2)
        end
    end)
end

function Automation.FindBestBait()
    local backpack = LocalPlayer.Backpack
    if not backpack then return nil end
    
    -- Define bait priorities (best to worst)
    local baitPriorities = {
        "Mythical Bait",
        "Legendary Bait", 
        "Epic Bait",
        "Rare Bait",
        "Uncommon Bait",
        "Common Bait",
        "Worm"
    }
    
    for _, baitName in ipairs(baitPriorities) do
        local bait = backpack:FindFirstChild(baitName)
        if bait then
            return baitName
        end
    end
    
    return nil
end

-- Enhanced Auto Fishing with new remotes
function Automation.EnhancedAutoFishing()
    local rod = Utils.FindRod()
    if not rod then return end
    
    -- Use the discovered remotes for better automation
    pcall(function()
        -- Toggle native auto fishing if available
        if ReplicatedStorage.packages.Net.RE:FindFirstChild("AutoFishing/Toggle") then
            ReplicatedStorage.packages.Net.RE["AutoFishing/Toggle"]:FireServer(true)
        end
        
        -- Enhanced casting with new remotes
        if rod.values.lure.Value <= 0.001 then
            if ReplicatedStorage.shared.modules.fishing.rodresources.events:FindFirstChild("cast") then
                ReplicatedStorage.shared.modules.fishing.rodresources.events.cast:FireServer(100, 1)
            else
                rod.events.cast:FireServer(100, 1)
            end
            
            -- Update statistics
            automationState.castsMade = (automationState.castsMade or 0) + 1
        end
        
        -- Enhanced reeling
        if rod.values.lure.Value == 100 then
            if ReplicatedStorage.events:FindFirstChild("reelfinished") then
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                automationState.fishCaught = (automationState.fishCaught or 0) + 1
            end
        end
    end)
end

-- Auto Currency Management
function Automation.AutoCurrencyManagement()
    if not automationState.autobuyupgrades then return end
    
    pcall(function()
        -- Get current currency
        ReplicatedStorage.events.getcurrency:FireServer()
        
        -- Auto buy useful upgrades (placeholder logic)
        -- This would need to be customized based on available upgrades
        -- Example: Auto buy rod upgrades, bait, etc.
    end)
end

-- Fast Travel Automation
function Automation.AutoFastTravel(destination)
    pcall(function()
        if ReplicatedStorage.packages.Net.RE:FindFirstChild("FastTravel/ToggleUI") then
            ReplicatedStorage.packages.Net.RE["FastTravel/ToggleUI"]:FireServer()
        end
        
        -- Use sea traveler for specific destinations
        if workspace:FindFirstChild("Sea Traveler") and 
           workspace["Sea Traveler"]:FindFirstChild("seatraveler") then
            workspace["Sea Traveler"].seatraveler.teleport:InvokeServer(destination)
        end
    end)
end

-- Rod management
function Automation.EquipBestRod()
    local character = Utils.GetCharacter()
    if not character then return end
    
    local backpack = LocalPlayer.Backpack
    if not backpack then return end
    
    -- Define rod priorities (best to worst)
    local rodPriorities = {
        "Mythical Rod",
        "Kings Rod", 
        "Trident Rod",
        "Midas Rod",
        "Heaven Rod",
        "Summit Rod",
        "Carbon Rod",
        "Lucky Rod",
        "Fast Rod",
        "Long Rod",
        "Nocturnal Rod",
        "Plastic Rod",
        "Training Rod",
        "Flimsy Rod"
    }
    
    -- Find the best available rod
    for _, rodName in ipairs(rodPriorities) do
        local rod = backpack:FindFirstChild(rodName)
        if rod then
            -- Unequip current rod if any
            local currentRod = Utils.FindRod()
            if currentRod then
                currentRod.Parent = backpack
            end
            
            -- Equip the new rod
            rod.Parent = character
            Utils.CreateNotification("Equipped " .. rodName, 2)
            break
        end
    end
end

-- Fishing zone optimization
function Automation.FindBestFishingZone()
    -- This would analyze current fish abundance and recommend the best zone
    -- Placeholder implementation
    local zones = {
        {name = "Roslit Bay", abundance = "High", rarity = "Common"},
        {name = "The Depths", abundance = "Medium", rarity = "Legendary"},
        {name = "Ancient Isle", abundance = "Low", rarity = "Mythical"}
    }
    
    -- Return the zone with highest value fish
    return zones[2] -- The Depths as placeholder
end

-- Performance monitoring
function Automation.GetAutomationStats()
    return {
        autocast = automationState.autocast,
        autoshake = automationState.autoshake,
        autoreel = automationState.autoreel,
        freezechar = automationState.freezechar,
        activeConnections = 0 -- Count of active connections
    }
end

-- Cleanup function
function Automation.Cleanup()
    for name, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    automationState.characterposition = nil
end

return Automation
