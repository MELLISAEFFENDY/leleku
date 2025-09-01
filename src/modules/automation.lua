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

-- Main automation loop
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
        
        -- Auto Shake Logic
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
        
        -- Auto Cast Logic
        if automationState.autocast then
            local rod = Utils.FindRod()
            if rod ~= nil and rod.values.lure.Value <= 0.001 then
                task.wait(0.5)
                rod.events.cast:FireServer(100, 1)
            end
        end
        
        -- Auto Reel Logic
        if automationState.autoreel then
            local rod = Utils.FindRod()
            if rod ~= nil and rod.values.lure.Value == 100 then
                task.wait(0.5)
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
            end
        end
    end)
end

-- Advanced automation features
function Automation.CreateAdvancedSection(window, flags)
    window:Section('⚙️ Advanced Automation')
    
    -- Auto Sell Fish
    window:Toggle('Auto Sell Fish', {
        location = flags,
        flag = 'autosell',
        default = false,
        callback = function(value)
            automationState.autosell = value
            if value then
                Automation.StartAutoSell()
            else
                Automation.StopAutoSell()
            end
        end
    })
    
    -- Auto Buy Bait
    window:Toggle('Auto Buy Bait', {
        location = flags,
        flag = 'autobuybait',
        default = false,
        callback = function(value)
            automationState.autobuybait = value
        end
    })
    
    -- Auto Equip Best Rod
    window:Toggle('Auto Equip Best Rod', {
        location = flags,
        flag = 'autoequiprod',
        default = false,
        callback = function(value)
            automationState.autoequiprod = value
            if value then
                Automation.EquipBestRod()
            end
        end
    })
    
    -- Fishing Stats
    window:Section('📊 Fishing Statistics')
    
    -- Create stats display (would need to track these)
    local statsText = "Fish Caught: 0\nTime Fishing: 0m\nAverage Cast Time: 0s"
    
    -- Add a text label for stats (this would be updated in real-time)
    -- This is a placeholder - you'd need to implement actual stat tracking
end

-- Auto sell functionality
function Automation.StartAutoSell()
    if connections.autoSell then
        connections.autoSell:Disconnect()
    end
    
    connections.autoSell = RunService.Heartbeat:Connect(function()
        -- Check if inventory is full or has fish to sell
        -- This would need to be implemented based on the game's inventory system
        -- Placeholder logic
        local shouldSell = false -- Replace with actual inventory check
        
        if shouldSell then
            -- Teleport to merchant and sell
            -- This would need to be implemented based on the game's selling system
        end
    end)
end

function Automation.StopAutoSell()
    if connections.autoSell then
        connections.autoSell:Disconnect()
        connections.autoSell = nil
    end
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
