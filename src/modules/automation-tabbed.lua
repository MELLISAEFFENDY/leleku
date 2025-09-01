--[[
    Automation Module - Tabbed UI Compatible
    Handles all fishing automation features with tab support
]]--

local Automation = {}

-- Dependencies - Load Utils directly from GitHub when using loadstring
local Utils
local success, utilsResult = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/utils/functions.lua'))()
end)

if success and utilsResult then
    Utils = utilsResult
else
    -- Basic fallback Utils
    Utils = {
        CreateNotification = function(text, duration)
            print("[NOTIFICATION]", text)
        end,
        GetCharacter = function()
            return game:GetService("Players").LocalPlayer.Character
        end,
        GetHumanoidRootPart = function()
            local character = game:GetService("Players").LocalPlayer.Character
            return character and character:FindFirstChild("HumanoidRootPart")
        end,
        FindRod = function()
            local character = game:GetService("Players").LocalPlayer.Character
            if not character then return nil end
            
            for _, item in pairs(character:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("rod") then
                    return item
                end
            end
            return nil
        end,
        TeleportTo = function(cframe)
            local character = game:GetService("Players").LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cframe
                return true
            end
            return false
        end
    }
end

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

-- Variables
local LocalPlayer = Players.LocalPlayer
local connections = {}
local automationState = {
    autocast = false,
    autoshake = false,
    autoreel = false,
    freezechar = false,
    freezecharmode = 'Rod Equipped',
    characterposition = nil,
    timeFishing = 0,
    castsMade = 0,
    fishCaught = 0
}

-- Create automation functions for Tabbed UI
function Automation.CreateAutomationSection(tab, flags)
    -- Main Automation Section
    tab:Section('🎣 Core Fishing Automation')
    
    -- Freeze Character
    tab:Toggle('Freeze Character', {
        flag = 'freezechar',
        location = flags,
        default = false,
        callback = function(value)
            automationState.freezechar = value
            if not value then
                automationState.characterposition = nil
            end
            Utils.CreateNotification("Freeze Character: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    tab:Dropdown('Freeze Mode', {
        list = {'Rod Equipped', 'Toggled'},
        callback = function(selected)
            automationState.freezecharmode = selected
            Utils.CreateNotification("Freeze Mode: " .. selected, 2)
        end
    })
    
    -- Auto Cast
    tab:Toggle('Auto Cast', {
        flag = 'autocast',
        location = flags,
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
    tab:Toggle('Auto Shake', {
        flag = 'autoshake',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autoshake = value
            Utils.CreateNotification("Auto Shake: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    -- Auto Reel
    tab:Toggle('Auto Reel', {
        flag = 'autoreel',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autoreel = value
            Utils.CreateNotification("Auto Reel: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    tab:Section('🛠️ Equipment Management')
    
    -- Auto Equip Rod
    tab:Toggle('Auto Equip Best Rod', {
        flag = 'autoequiprod',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autoequiprod = value
            Utils.CreateNotification("Auto Equip Rod: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    -- Auto Equip Bait
    tab:Toggle('Auto Equip Bait', {
        flag = 'autoequipbait',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autoequipbait = value
            Utils.CreateNotification("Auto Equip Bait: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    tab:Section('💰 Economy Automation')
    
    -- Auto Sell
    tab:Button('Sell All Fish', function()
        pcall(function()
            if ReplicatedStorage.events:FindFirstChild("selleverything") then
                ReplicatedStorage.events.selleverything:FireServer()
                Utils.CreateNotification("Sold all fish!", 2)
            end
        end)
    end)
    
    -- Auto Enchant Rod
    tab:Toggle('Auto Enchant Rod', {
        flag = 'autoenchantrod',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autoenchantrod = value
            Utils.CreateNotification("Auto Enchant Rod: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    -- Start main automation loop
    if not connections.mainLoop then
        connections.mainLoop = RunService.Heartbeat:Connect(function()
            Automation.MainAutomationLoop(flags)
        end)
    end
end

function Automation.CreateAdvancedSection(tab, flags)
    tab:Section('🚀 Advanced Features')
    
    -- Auto Buy Upgrades
    tab:Toggle('Auto Buy Upgrades', {
        flag = 'autobuyupgrades',
        location = flags,
        default = false,
        callback = function(value)
            automationState.autobuyupgrades = value
            Utils.CreateNotification("Auto Buy Upgrades: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    -- Enhanced Automation
    tab:Toggle('Enhanced Auto Fishing', {
        flag = 'enhancedauto',
        location = flags,
        default = false,
        callback = function(value)
            automationState.enhancedauto = value
            Utils.CreateNotification("Enhanced Auto Fishing: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    tab:Section('🎯 Exploit Features')
    
    -- Duplicate Fish Sell
    tab:Button('Sell Duplicate Fish', function()
        pcall(function()
            local rod = Utils.FindRod()
            if rod then
                for i = 1, 10 do
                    ReplicatedStorage.events.sellfish:FireServer(rod.Name, 1)
                end
                Utils.CreateNotification("Attempted to sell duplicate fish", 2)
            end
        end)
    end)
    
    -- Anti-AFK
    tab:Toggle('Anti-AFK', {
        flag = 'antiafk',
        location = flags,
        default = false,
        callback = function(value)
            automationState.antiafk = value
            Utils.CreateNotification("Anti-AFK: " .. (value and "Enabled" or "Disabled"), 2)
        end
    })
    
    tab:Section('📊 Statistics')
    
    -- Stats display
    tab:Label('Fishing Statistics:')
    tab:Label('• Time Fishing: ' .. (automationState.timeFishing or 0) .. ' minutes')
    tab:Label('• Casts Made: ' .. (automationState.castsMade or 0))
    tab:Label('• Fish Caught: ' .. (automationState.fishCaught or 0))
    
    -- Reset stats button
    tab:Button('Reset Statistics', function()
        automationState.timeFishing = 0
        automationState.castsMade = 0
        automationState.fishCaught = 0
        Utils.CreateNotification("Statistics reset", 2)
    end)
end

-- Main automation loop
function Automation.MainAutomationLoop(flags)
    pcall(function()
        local character = Utils.GetCharacter()
        if not character then return end
        
        -- Freeze Character Logic
        if automationState.freezechar then
            local freezeMode = automationState.freezecharmode
            local shouldFreeze = false
            
            if freezeMode == 'Toggled' then
                shouldFreeze = true
            elseif freezeMode == 'Rod Equipped' then
                shouldFreeze = Utils.FindRod() ~= nil
            end
            
            if shouldFreeze then
                if not automationState.characterposition then
                    automationState.characterposition = Utils.GetHumanoidRootPart().CFrame
                end
                if automationState.characterposition then
                    Utils.GetHumanoidRootPart().CFrame = automationState.characterposition
                end
            end
        end
        
        -- Enhanced Auto Fishing Logic
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
                    automationState.fishCaught = (automationState.fishCaught or 0) + 1
                else
                    -- Fallback method
                    rod.events.catchfinish:FireServer(100, true)
                    automationState.fishCaught = (automationState.fishCaught or 0) + 1
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
        
        -- Anti-AFK
        if automationState.antiafk then
            task.spawn(function()
                task.wait(60) -- Every minute
                if ReplicatedStorage.events:FindFirstChild("afk") then
                    ReplicatedStorage.events.afk:FireServer(false)
                end
            end)
        end
    end)
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

-- Rod management
function Automation.EquipBestRod()
    local character = Utils.GetCharacter()
    if not character then return end
    
    local backpack = game:GetService("Players").LocalPlayer.Backpack
    if not backpack then return end
    
    -- Define rod priorities (best to worst)
    local rodPriorities = {
        "Mythical Rod", "Legendary Rod", "Epic Rod", 
        "Rare Rod", "Uncommon Rod", "Common Rod", "Basic Rod"
    }
    
    for _, rodName in ipairs(rodPriorities) do
        local rod = backpack:FindFirstChild(rodName)
        if rod then
            rod.Parent = character
            Utils.CreateNotification("Equipped: " .. rodName, 2)
            break
        end
    end
end

-- Auto Equip Bait
function Automation.AutoEquipBait()
    local character = Utils.GetCharacter()
    if not character then return end
    
    local backpack = game:GetService("Players").LocalPlayer.Backpack
    if not backpack then return end
    
    -- Define bait priorities (best to worst)
    local baitPriorities = {
        "Truffle Worm", "Scurvy Worm", "Shark Head", "Magnet", 
        "Fish Head", "Bagel", "Worm"
    }
    
    for _, baitName in ipairs(baitPriorities) do
        local bait = backpack:FindFirstChild(baitName)
        if bait then
            bait.Parent = character
            Utils.CreateNotification("Equipped: " .. baitName, 2)
            break
        end
    end
end

return Automation
