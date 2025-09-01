--[[
    Teleportation Module
    Handles all teleportation functionality
]]--

local Teleports = {}

-- Dependencies
local Utils = require(script.Parent.Parent.utils.functions)
local Locations = require(script.Parent.Parent.data.locations)

-- Services
local Players = game:GetService('Players')

-- Create teleport functions for UI
function Teleports.CreateTeleportSection(window)
    -- Teleports Section
    window:Section('🌍 Teleportation')
    
    -- Zone Teleports
    local zoneDropdown = window:Dropdown('Zone Teleports', {
        list = Locations.GetZoneNames(),
        callback = function(selected)
            -- Store selected zone
            Teleports.selectedZone = selected
        end
    })
    
    window:Button('Teleport to Zone', function()
        if Teleports.selectedZone then
            local cframe = Locations.TeleportLocations.Zones[Teleports.selectedZone]
            if cframe then
                if Utils.TeleportTo(cframe) then
                    Utils.CreateNotification("Teleported to " .. Teleports.selectedZone, 3)
                else
                    Utils.CreateNotification("Failed to teleport to " .. Teleports.selectedZone, 3)
                end
            end
        else
            Utils.CreateNotification("Please select a zone first", 3)
        end
    end)
    
    -- Rod Teleports
    local rodDropdown = window:Dropdown('Rod Locations', {
        list = Locations.GetRodNames(),
        callback = function(selected)
            Teleports.selectedRod = selected
        end
    })
    
    window:Button('Teleport to Rod', function()
        if Teleports.selectedRod then
            local cframe = Locations.TeleportLocations.Rods[Teleports.selectedRod]
            if cframe then
                if Utils.TeleportTo(cframe) then
                    Utils.CreateNotification("Teleported to " .. Teleports.selectedRod, 3)
                else
                    Utils.CreateNotification("Failed to teleport to " .. Teleports.selectedRod, 3)
                end
            end
        else
            Utils.CreateNotification("Please select a rod location first", 3)
        end
    end)
    
    -- NPC Teleports
    local npcDropdown = window:Dropdown('NPC Locations', {
        list = Locations.GetNPCNames(),
        callback = function(selected)
            Teleports.selectedNPC = selected
        end
    })
    
    window:Button('Teleport to NPC', function()
        if Teleports.selectedNPC then
            local cframe = Locations.TeleportLocations.NPCs[Teleports.selectedNPC]
            if cframe then
                if Utils.TeleportTo(cframe) then
                    Utils.CreateNotification("Teleported to " .. Teleports.selectedNPC, 3)
                else
                    Utils.CreateNotification("Failed to teleport to " .. Teleports.selectedNPC, 3)
                end
            end
        else
            Utils.CreateNotification("Please select an NPC first", 3)
        end
    end)
    
    -- Player Teleports
    window:Section('👥 Player Teleportation')
    
    local playerDropdown = window:Dropdown('Players', {
        list = Utils.GetPlayerNames(),
        callback = function(selected)
            Teleports.selectedPlayer = selected
        end
    })
    
    window:Button('Teleport to Player', function()
        if Teleports.selectedPlayer then
            if Utils.TeleportToPlayer(Teleports.selectedPlayer) then
                Utils.CreateNotification("Teleported to " .. Teleports.selectedPlayer, 3)
            else
                Utils.CreateNotification("Failed to teleport to " .. Teleports.selectedPlayer, 3)
            end
        else
            Utils.CreateNotification("Please select a player first", 3)
        end
    end)
    
    -- Update player list when players join/leave
    Players.PlayerAdded:Connect(function()
        -- Update dropdown list
        playerDropdown.Frame:Destroy()
        playerDropdown = window:Dropdown('Players', {
            list = Utils.GetPlayerNames(),
            callback = function(selected)
                Teleports.selectedPlayer = selected
            end
        })
    end)
    
    Players.PlayerRemoving:Connect(function()
        -- Update dropdown list
        playerDropdown.Frame:Destroy()
        playerDropdown = window:Dropdown('Players', {
            list = Utils.GetPlayerNames(),
            callback = function(selected)
                Teleports.selectedPlayer = selected
            end
        })
    end)
    
    -- Quick Teleports
    window:Section('⚡ Quick Teleports')
    
    window:Button('Teleport to Spawn', function()
        local spawnCFrame = CFrame.new(379.875458, 134.500519, 233.5495)
        if Utils.TeleportTo(spawnCFrame) then
            Utils.CreateNotification("Teleported to spawn", 3)
        end
    end)
    
    window:Button('Teleport to Depths', function()
        local depthsCFrame = Locations.TeleportLocations.Zones['Depths']
        if Utils.TeleportTo(depthsCFrame) then
            Utils.CreateNotification("Teleported to The Depths", 3)
        end
    end)
    
    window:Button('Teleport to Altar', function()
        local altarCFrame = Locations.TeleportLocations.Items['Enchated Altar']
        if Utils.TeleportTo(altarCFrame) then
            Utils.CreateNotification("Teleported to Enchanted Altar", 3)
        end
    end)
end

-- Utility functions for other modules
function Teleports.TeleportToZone(zoneName)
    local cframe = Locations.TeleportLocations.Zones[zoneName]
    if cframe then
        return Utils.TeleportTo(cframe)
    end
    return false
end

function Teleports.TeleportToRod(rodName)
    local cframe = Locations.TeleportLocations.Rods[rodName]
    if cframe then
        return Utils.TeleportTo(cframe)
    end
    return false
end

function Teleports.TeleportToNPC(npcName)
    local cframe = Locations.TeleportLocations.NPCs[npcName]
    if cframe then
        return Utils.TeleportTo(cframe)
    end
    return false
end

function Teleports.TeleportToItem(itemName)
    local cframe = Locations.TeleportLocations.Items[itemName]
    if cframe then
        return Utils.TeleportTo(cframe)
    end
    return false
end

-- Save and load favorite locations
function Teleports.SaveFavoriteLocation(name, cframe)
    local favorites = Utils.LoadData('favorites.json') or {}
    favorites[name] = {
        X = cframe.X, Y = cframe.Y, Z = cframe.Z,
        RX = cframe.RightVector.X, RY = cframe.RightVector.Y, RZ = cframe.RightVector.Z,
        UX = cframe.UpVector.X, UY = cframe.UpVector.Y, UZ = cframe.UpVector.Z,
        LX = cframe.LookVector.X, LY = cframe.LookVector.Y, LZ = cframe.LookVector.Z
    }
    Utils.SaveData('favorites.json', favorites)
end

function Teleports.LoadFavoriteLocations()
    local favorites = Utils.LoadData('favorites.json') or {}
    local favoritesList = {}
    
    for name, data in pairs(favorites) do
        favoritesList[name] = CFrame.new(
            data.X, data.Y, data.Z,
            data.RX, data.UX, data.LX,
            data.RY, data.UY, data.LY,
            data.RZ, data.UZ, data.LZ
        )
    end
    
    return favoritesList
end

function Teleports.GetCurrentPosition()
    local character = Utils.GetCharacter()
    if character and character:FindFirstChild('HumanoidRootPart') then
        return character.HumanoidRootPart.CFrame
    end
    return nil
end

return Teleports
