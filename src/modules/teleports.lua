--[[
    Teleportation Module
    Handles all teleportation functionality
]]--

local Teleports = {}

-- Dependencies - Load from GitHub when using loadstring
local Utils
local Locations

-- Load Utils
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
        TeleportTo = function(cframe)
            local character = game:GetService("Players").LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cframe
                return true
            end
            return false
        end,
        GetPlayerNames = function()
            local names = {}
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                table.insert(names, player.Name)
            end
            return names
        end
    }
end

-- Load Locations
local locSuccess, locResult = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/data/locations.lua'))()
end)

if locSuccess and locResult then
    Locations = locResult
else
    -- Basic fallback Locations
    Locations = {
        GetZoneNames = function()
            return {"Roslit Bay", "The Depths", "Ancient Isle", "Vertigo", "Snowcap Island"}
        end,
        GetRodNames = function()
            return {"Training Rod", "Plastic Rod", "Lucky Rod", "Carbon Rod", "Long Rod"}
        end,
        TeleportLocations = {
            Zones = {
                ["Roslit Bay"] = CFrame.new(379.875, 134.5, 233.5),
                ["The Depths"] = CFrame.new(-1805.02, -143.47, 1563.37),
                ["Ancient Isle"] = CFrame.new(5208.81, 155.28, 401.76),
                ["Vertigo"] = CFrame.new(-113.66, -511.86, 1061.31),
                ["Snowcap Island"] = CFrame.new(2648.83, 139.85, 2522.86)
            },
            Rods = {},
            NPCs = {},
            Items = {}
        }
    }
end

-- Services
local Players = game:GetService('Players')

-- Create teleport functions for UI
function Teleports.CreateTeleportSection(window)
    -- Teleports Section
    window:Section('🌍 Zone Teleportation')
    
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
    
    -- Enhanced Fast Travel System
    window:Section('🚢 Fast Travel & NPCs')
    
    window:Button('Use Sea Traveler', function()
        pcall(function()
            if workspace:FindFirstChild("Sea Traveler") and 
               workspace["Sea Traveler"]:FindFirstChild("seatraveler") then
                -- Open sea traveler menu
                workspace["Sea Traveler"].seatraveler.teleport:InvokeServer()
                Utils.CreateNotification("🚢 Sea Traveler opened", 2)
            else
                Utils.CreateNotification("❌ Sea Traveler not found", 2)
            end
        end)
    end)
    
    window:Button('Toggle Fast Travel UI', function()
        pcall(function()
            game:GetService("ReplicatedStorage").packages.Net.RE["FastTravel/ToggleUI"]:FireServer()
            Utils.CreateNotification("🌟 Fast Travel UI toggled", 2)
        end)
    end)
    
    -- NPC Teleports
    window:Section('👥 NPC Locations')
    
    local npcDropdown = window:Dropdown('Teleport to NPC', {
        list = {
            "Pierre (Quests)",
            "Phineas (Quests)", 
            "Moosewood Angler",
            "Moosewood Shipwright",
            "Lantern Keeper",
            "Mods Lantern Keeper",
            "Dr Glimmerfin",
            "Captain Ahab"
        },
        callback = function(selected)
            Teleports.selectedNPC = selected
        end
    })
    
    window:Button('Teleport to NPC', function()
        if Teleports.selectedNPC then
            Teleports.TeleportToNPC(Teleports.selectedNPC)
        else
            Utils.CreateNotification("Please select an NPC first", 3)
        end
    end)
    
    -- Rod Teleports
    window:Section('🎣 Rod Locations')
    
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
    -- NPC location mappings (you may need to adjust these coordinates)
    local npcLocations = {
        ["Pierre (Quests)"] = CFrame.new(379.875, 134.5, 233.5),
        ["Phineas (Quests)"] = CFrame.new(400.2, 134.5, 280.8),
        ["Moosewood Angler"] = CFrame.new(390.1, 134.5, 250.3),
        ["Moosewood Shipwright"] = CFrame.new(360.5, 134.5, 220.7),
        ["Lantern Keeper"] = CFrame.new(410.3, 134.5, 190.4),
        ["Mods Lantern Keeper"] = CFrame.new(420.8, 134.5, 200.1),
        ["Dr Glimmerfin"] = CFrame.new(-1805.02, -143.47, 1563.37),
        ["Captain Ahab"] = CFrame.new(-1550.23, -138.45, 1380.21)
    }
    
    local cframe = npcLocations[npcName]
    if cframe then
        if Utils.TeleportTo(cframe) then
            Utils.CreateNotification("Teleported to " .. npcName, 3)
            return true
        else
            Utils.CreateNotification("Failed to teleport to " .. npcName, 3)
            return false
        end
    else
        -- Try to find NPC in workspace
        pcall(function()
            local npcFound = false
            for _, npc in pairs(workspace:GetDescendants()) do
                if npc.Name:lower():find(npcName:lower():gsub(" .*", "")) then
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                        local npcCFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
                        if Utils.TeleportTo(npcCFrame) then
                            Utils.CreateNotification("Teleported to " .. npcName, 3)
                            npcFound = true
                            break
                        end
                    end
                end
            end
            
            if not npcFound then
                Utils.CreateNotification("NPC " .. npcName .. " not found", 3)
            end
        end)
        return false
    end
end

-- Enhanced teleportation with door interactions
function Teleports.TeleportWithDoor(location)
    pcall(function()
        -- Check for door interactions (from remote dump)
        if workspace.world.map:FindFirstChild("Executive Headquarters") then
            local door = workspace.world.map["Executive Headquarters"].Model.TopDoor
            if door and door:FindFirstChild("Interacted") then
                door.Interacted:FireServer()
            end
        end
        
        -- Use door remote if available
        if game:GetService("ReplicatedStorage").packages.Net.RE:FindFirstChild("DoorRemote") then
            game:GetService("ReplicatedStorage").packages.Net.RE.DoorRemote:FireServer()
        end
    end)
end

-- Auto travel to best fishing zones
function Teleports.AutoTravelToBestZone()
    local bestZones = {
        {name = "The Depths", abundance = "High", rarity = "Legendary"},
        {name = "Ancient Isle", abundance = "Medium", rarity = "Mythical"},
        {name = "Vertigo", abundance = "High", rarity = "Rare"},
        {name = "Roslit Bay", abundance = "High", rarity = "Common"}
    }
    
    -- Select based on current goals (this could be made configurable)
    local targetZone = bestZones[1] -- Default to The Depths
    
    if Teleports.TeleportToZone(targetZone.name) then
        Utils.CreateNotification("🎣 Traveled to " .. targetZone.name .. " for " .. targetZone.rarity .. " fish!", 3)
        return true
    end
    
    return false
end

-- Return to surface function
function Teleports.ReturnToSurface()
    pcall(function()
        game:GetService("ReplicatedStorage").packages.Net.RE.ReturnToSurface:FireServer()
        Utils.CreateNotification("🌊 Returning to surface...", 2)
    end)
end
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
