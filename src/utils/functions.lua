--[[
    Utility Functions
    Contains common helper functions used throughout the script
]]--

local Utils = {}

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

-- Variables
local LocalPlayer = Players.LocalPlayer

-- Helper Functions
Utils.FindChildOfClass = function(parent, classname)
    return parent:FindFirstChildOfClass(classname)
end

Utils.FindChild = function(parent, child)
    return parent:FindFirstChild(child)
end

Utils.FindChildOfType = function(parent, childname, classname)
    local child = parent:FindFirstChild(childname)
    if child and child.ClassName == classname then
        return child
    end
    return nil
end

Utils.CheckFunc = function(func)
    return typeof(func) == 'function'
end

-- Character Functions
Utils.GetCharacter = function()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

Utils.GetHumanoidRootPart = function()
    return Utils.GetCharacter():WaitForChild('HumanoidRootPart')
end

Utils.GetHumanoid = function()
    return Utils.GetCharacter():WaitForChild('Humanoid')
end

Utils.FindRod = function()
    local character = Utils.GetCharacter()
    local tool = Utils.FindChildOfClass(character, 'Tool')
    if tool and Utils.FindChild(tool, 'values') then
        return tool
    end
    return nil
end

-- Player Functions
Utils.GetPlayerNames = function()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

Utils.GetPlayerByName = function(name)
    return Players:FindFirstChild(name)
end

Utils.TeleportToPlayer = function(playerName)
    local targetPlayer = Utils.GetPlayerByName(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild('HumanoidRootPart') then
        local targetPos = targetPlayer.Character.HumanoidRootPart.CFrame
        local myCharacter = Utils.GetCharacter()
        if myCharacter and myCharacter:FindFirstChild('HumanoidRootPart') then
            myCharacter.HumanoidRootPart.CFrame = targetPos
            return true
        end
    end
    return false
end

-- Teleport Functions
Utils.TeleportTo = function(cframe)
    local character = Utils.GetCharacter()
    if character and character:FindFirstChild('HumanoidRootPart') then
        character.HumanoidRootPart.CFrame = cframe
        return true
    end
    return false
end

-- Notification System
Utils.CreateNotification = function(text, duration)
    duration = duration or 3
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create notification GUI if it doesn't exist
    local notificationGui = PlayerGui:FindFirstChild("NotificationGui")
    if not notificationGui then
        notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "NotificationGui"
        notificationGui.Parent = PlayerGui
        notificationGui.ResetOnSpawn = false
    end
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Parent = notificationGui
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notification.BorderSizePixel = 0
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(88, 101, 242)
    stroke.Thickness = 1
    stroke.Parent = notification
    
    -- Add text
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = notification
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animate in
    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    notification.Position = UDim2.new(1, 20, 0, 20)
    local slideIn = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(1, -320, 0, 20)})
    slideIn:Play()
    
    -- Auto-remove after duration
    local function removeNotification()
        local slideOut = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(1, 20, 0, 20)})
        slideOut:Play()
        slideOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end
    
    game:GetService("Debris"):AddItem(notification, duration + 0.5)
    wait(duration)
    removeNotification()
end

-- File Management (if supported)
Utils.SaveData = function(filename, data)
    if Utils.CheckFunc(writefile) and Utils.CheckFunc(makefolder) then
        if not isfolder('FischModern') then
            makefolder('FischModern')
        end
        
        local success, result = pcall(function()
            writefile('FischModern/' .. filename, game:GetService("HttpService"):JSONEncode(data))
        end)
        
        return success
    end
    return false
end

Utils.LoadData = function(filename)
    if Utils.CheckFunc(readfile) and Utils.CheckFunc(isfile) then
        if isfile('FischModern/' .. filename) then
            local success, result = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile('FischModern/' .. filename))
            end)
            
            if success then
                return result
            end
        end
    end
    return nil
end

-- Game State Functions
Utils.IsInWater = function()
    local character = Utils.GetCharacter()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character.HumanoidRootPart
        local raycast = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -10, 0))
        
        if raycast and raycast.Instance then
            return raycast.Instance.Name == "Water" or raycast.Instance.Parent.Name == "Water"
        end
    end
    return false
end

Utils.GetCurrentZone = function()
    -- This would need to be implemented based on the game's zone detection system
    -- For now, return a placeholder
    return "Unknown Zone"
end

-- Performance Monitoring
Utils.GetFPS = function()
    local RunService = game:GetService("RunService")
    local fps = 0
    local lastTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        connection:Disconnect()
    end)
    
    return fps
end

-- Debug Functions
Utils.DebugLog = function(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s][%s] %s", timestamp, level, tostring(message)))
end

Utils.DebugWarn = function(message)
    Utils.DebugLog(message, "WARN")
end

Utils.DebugError = function(message)
    Utils.DebugLog(message, "ERROR")
end

return Utils
