--[[
    Modern Tabbed UI Library
    Features:
    - Tab menu di kiri, content di kanan
    - Single window design
    - Dark modern theme
    - Floating button system
]]--

-- Safety wrapper for the entire library
local function safeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("TabbedLibrary Error:", result)
        return nil
    end
    return result
end

local TabbedLibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 10) -- Add timeout

-- Safety check for PlayerGui
if not PlayerGui then
    warn("PlayerGui not found, creating fallback")
    PlayerGui = Player:FindFirstChild("PlayerGui") or Instance.new("ScreenGui")
    if PlayerGui.ClassName ~= "PlayerGui" then
        local newPlayerGui = Instance.new("ScreenGui")
        newPlayerGui.Parent = Player
        PlayerGui = newPlayerGui
    end
end

-- Theme
local Theme = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        Surface = Color3.fromRGB(25, 25, 30),
        SurfaceLight = Color3.fromRGB(30, 30, 35),
        TabBackground = Color3.fromRGB(18, 18, 22),
        TabSelected = Color3.fromRGB(88, 101, 242),
        TabHover = Color3.fromRGB(35, 35, 40),
        Primary = Color3.fromRGB(88, 101, 242),
        PrimaryHover = Color3.fromRGB(98, 111, 252),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(185, 187, 190),
        TextMuted = Color3.fromRGB(115, 118, 123),
        Border = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Hover = Color3.fromRGB(35, 35, 40),
        Active = Color3.fromRGB(45, 45, 50)
    },
    Sizes = {
        WindowWidth = 800,
        WindowHeight = 600,
        TabWidth = 200,
        TabHeight = 40,
        TitleHeight = 35,
        ButtonHeight = 30,
        Padding = 8,
        BorderRadius = 6
    },
    Fonts = {
        Primary = Enum.Font.SourceSans,
        Secondary = Enum.Font.SourceSans,
        Bold = Enum.Font.SourceSansBold
    },
    Animations = {
        Speed = 0.25,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out
    }
}

-- Library state
local LibraryState = {
    MainWindow = nil,
    FloatingButton = nil,
    FloatingButtonGui = nil,
    IsVisible = true,
    CurrentTab = nil,
    Tabs = {},
    TabFrames = {}
}

-- Helper function to create tween
local function createTween(object, properties, duration)
    if not object or not properties then return nil end
    
    local success, result = pcall(function()
        duration = duration or Theme.Animations.Speed
        local tweenInfo = TweenInfo.new(
            duration,
            Theme.Animations.EasingStyle,
            Theme.Animations.EasingDirection
        )
        return TweenService:Create(object, tweenInfo, properties)
    end)
    
    if success then
        return result
    else
        warn("Failed to create tween:", result)
        return nil
    end
end

-- Safe tween play function
local function safeTweenPlay(object, properties, duration)
    local tween = createTween(object, properties, duration)
    if tween then
        pcall(function() tween:Play() end)
    end
end

-- Create floating button
local function createFloatingButton()
    if LibraryState.FloatingButton then
        LibraryState.FloatingButton:Destroy()
    end
    
    -- Create dedicated ScreenGui for floating button
    local floatingGui = Instance.new("ScreenGui")
    floatingGui.Name = "FloatingButtonGui"
    floatingGui.Parent = PlayerGui
    floatingGui.ResetOnSpawn = false
    floatingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    floatingGui.DisplayOrder = 999 -- Ensure it's on top
    
    local floatingFrame = Instance.new("Frame")
    floatingFrame.Name = "FloatingButton"
    floatingFrame.Size = UDim2.new(0, 60, 0, 60)
    floatingFrame.Position = UDim2.new(1, -80, 0, 20)
    floatingFrame.BackgroundColor3 = Theme.Colors.Primary
    floatingFrame.BorderSizePixel = 0
    floatingFrame.Visible = false -- Start hidden
    floatingFrame.Parent = floatingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = floatingFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = "🎣"
    button.TextColor3 = Theme.Colors.TextPrimary
    button.TextSize = 24
    button.Font = Theme.Fonts.Bold
    button.Parent = floatingFrame
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        createTween(floatingFrame, {BackgroundColor3 = Theme.Colors.PrimaryHover}):Play()
        createTween(floatingFrame, {Size = UDim2.new(0, 65, 0, 65)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(floatingFrame, {BackgroundColor3 = Theme.Colors.Primary}):Play()
        createTween(floatingFrame, {Size = UDim2.new(0, 60, 0, 60)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        TabbedLibrary:Show()
    end)
    
    LibraryState.FloatingButton = floatingFrame
    LibraryState.FloatingButtonGui = floatingGui
    return floatingFrame
end

-- Create main window
local function createMainWindow()
    if LibraryState.MainWindow then
        LibraryState.MainWindow:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TabbedUILibrary"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, Theme.Sizes.WindowWidth, 0, Theme.Sizes.WindowHeight)
    mainFrame.Position = UDim2.new(0.5, -Theme.Sizes.WindowWidth/2, 0.5, -Theme.Sizes.WindowHeight/2)
    mainFrame.BackgroundColor3 = Theme.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, Theme.Sizes.BorderRadius)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Colors.Border
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, Theme.Sizes.TitleHeight)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Theme.Colors.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, Theme.Sizes.BorderRadius)
    titleCorner.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, Theme.Sizes.Padding, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🎣 Modern Fishing Script"
    titleText.TextColor3 = Theme.Colors.TextPrimary
    titleText.TextSize = 16
    titleText.Font = Theme.Fonts.Bold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeButton.BackgroundColor3 = Theme.Colors.Error
    closeButton.Text = "✕"
    closeButton.TextColor3 = Theme.Colors.TextPrimary
    closeButton.TextSize = 12
    closeButton.Font = Theme.Fonts.Bold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        TabbedLibrary:Hide()
    end)
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    minimizeButton.BackgroundColor3 = Theme.Colors.Warning
    minimizeButton.Text = "─"
    minimizeButton.TextColor3 = Theme.Colors.TextPrimary
    minimizeButton.TextSize = 12
    minimizeButton.Font = Theme.Fonts.Bold
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Parent = titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimizeButton
    
    minimizeButton.MouseButton1Click:Connect(function()
        TabbedLibrary:Hide()
    end)
    
    -- Tab container (Left side)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, Theme.Sizes.TabWidth, 1, -Theme.Sizes.TitleHeight)
    tabContainer.Position = UDim2.new(0, 0, 0, Theme.Sizes.TitleHeight)
    tabContainer.BackgroundColor3 = Theme.Colors.TabBackground
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Tab layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, Theme.Sizes.Padding)
    tabPadding.PaddingLeft = UDim.new(0, Theme.Sizes.Padding)
    tabPadding.PaddingRight = UDim.new(0, Theme.Sizes.Padding)
    tabPadding.Parent = tabContainer
    
    -- Content container (Right side)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -Theme.Sizes.TabWidth, 1, -Theme.Sizes.TitleHeight)
    contentContainer.Position = UDim2.new(0, Theme.Sizes.TabWidth, 0, Theme.Sizes.TitleHeight)
    contentContainer.BackgroundColor3 = Theme.Colors.Surface
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, Theme.Sizes.BorderRadius)
    contentCorner.Parent = contentContainer
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    LibraryState.MainWindow = screenGui
    LibraryState.TabContainer = tabContainer
    LibraryState.ContentContainer = contentContainer
    
    return screenGui
end

-- Tab object
local Tab = {}
Tab.__index = Tab

function Tab:Section(name)
    -- Create section in current tab content
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. name
    sectionFrame.Size = UDim2.new(1, 0, 0, 25)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = self.ContentFrame
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = name
    sectionLabel.TextColor3 = Theme.Colors.Primary
    sectionLabel.TextSize = 14
    sectionLabel.Font = Theme.Fonts.Bold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = sectionFrame
    
    return self
end

function Tab:Toggle(name, options)
    options = options or {}
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. name
    toggleFrame.Size = UDim2.new(1, 0, 0, Theme.Sizes.ButtonHeight + 8)
    toggleFrame.BackgroundColor3 = Theme.Colors.SurfaceLight
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.ContentFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -80, 1, 0)
    toggleLabel.Position = UDim2.new(0, Theme.Sizes.Padding, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Theme.Colors.TextPrimary
    toggleLabel.TextSize = 12
    toggleLabel.Font = Theme.Fonts.Primary
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -60, 0.5, -12)
    toggleButton.BackgroundColor3 = options.default and Theme.Colors.Success or Theme.Colors.Border
    toggleButton.Text = options.default and "ON" or "OFF"
    toggleButton.TextColor3 = Theme.Colors.TextPrimary
    toggleButton.TextSize = 10
    toggleButton.Font = Theme.Fonts.Bold
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(0, 4)
    toggleButtonCorner.Parent = toggleButton
    
    local currentValue = options.default or false
    
    -- Store in flags if provided
    if options.location and options.flag then
        options.location[options.flag] = currentValue
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        
        -- Update UI
        toggleButton.Text = currentValue and "ON" or "OFF"
        createTween(toggleButton, {
            BackgroundColor3 = currentValue and Theme.Colors.Success or Theme.Colors.Border
        }):Play()
        
        -- Store in flags if provided
        if options.location and options.flag then
            options.location[options.flag] = currentValue
        end
        
        -- Execute callback
        if options.callback then
            options.callback(currentValue)
        end
    end)
    
    -- Hover effects
    toggleButton.MouseEnter:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = currentValue and 
                Color3.fromRGB(57, 151, 99) or 
                Color3.fromRGB(60, 60, 65)
        }):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = currentValue and Theme.Colors.Success or Theme.Colors.Border
        }):Play()
    end)
    
    return self
end
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    local isToggled = options.default or false
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        local newColor = isToggled and Theme.Colors.Success or Theme.Colors.Border
        local newText = isToggled and "ON" or "OFF"
        
        createTween(toggleButton, {BackgroundColor3 = newColor}):Play()
        toggleButton.Text = newText
        
        if options.callback then
            options.callback(isToggled)
        end
        
        if options.flag and options.location then
            options.location[options.flag] = isToggled
        end
    end)
    
    return self
end

function Tab:Button(name, callback)
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button_" .. name
    buttonFrame.Size = UDim2.new(1, 0, 0, Theme.Sizes.ButtonHeight)
    buttonFrame.BackgroundColor3 = Theme.Colors.Primary
    buttonFrame.Text = name
    buttonFrame.TextColor3 = Theme.Colors.TextPrimary
    buttonFrame.TextSize = 12
    buttonFrame.Font = Theme.Fonts.Primary
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = self.ContentFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = buttonFrame
    
    buttonFrame.MouseEnter:Connect(function()
        createTween(buttonFrame, {BackgroundColor3 = Theme.Colors.PrimaryHover}):Play()
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        createTween(buttonFrame, {BackgroundColor3 = Theme.Colors.Primary}):Play()
    end)
    
    buttonFrame.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return self
end

function Tab:Label(text)
    local labelFrame = Instance.new("TextLabel")
    labelFrame.Name = "Label"
    labelFrame.Size = UDim2.new(1, 0, 0, 20)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Text = text
    labelFrame.TextColor3 = Theme.Colors.TextSecondary
    labelFrame.TextSize = 11
    labelFrame.Font = Theme.Fonts.Secondary
    labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    labelFrame.TextWrapped = true
    labelFrame.Parent = self.ContentFrame
    
    return self
end

function Tab:Dropdown(name, options)
    options = options or {}
    local list = options.list or {"Option 1", "Option 2"}
    local currentSelection = list[1]
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown_" .. name
    dropdownFrame.Size = UDim2.new(1, 0, 0, Theme.Sizes.ButtonHeight + 8)
    dropdownFrame.BackgroundColor3 = Theme.Colors.SurfaceLight
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.ContentFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = name .. ": " .. currentSelection
    dropdownButton.TextColor3 = Theme.Colors.TextPrimary
    dropdownButton.TextSize = 12
    dropdownButton.Font = Theme.Fonts.Primary
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.Parent = dropdownFrame
    
    local dropdownPadding = Instance.new("UIPadding")
    dropdownPadding.PaddingLeft = UDim.new(0, Theme.Sizes.Padding)
    dropdownPadding.PaddingRight = UDim.new(0, Theme.Sizes.Padding)
    dropdownPadding.Parent = dropdownButton
    
    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -25, 0, 0)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = Theme.Colors.TextSecondary
    dropdownIcon.TextSize = 10
    dropdownIcon.Font = Theme.Fonts.Primary
    dropdownIcon.TextXAlignment = Enum.TextXAlignment.Center
    dropdownIcon.Parent = dropdownButton
    
    -- Simple click cycling through options
    dropdownButton.MouseButton1Click:Connect(function()
        local currentIndex = 1
        for i, item in ipairs(list) do
            if item == currentSelection then
                currentIndex = i
                break
            end
        end
        
        local nextIndex = currentIndex + 1
        if nextIndex > #list then
            nextIndex = 1
        end
        
        currentSelection = list[nextIndex]
        dropdownButton.Text = name .. ": " .. currentSelection
        
        if options.callback then
            options.callback(currentSelection)
        end
    end)
    
    -- Hover effects
    dropdownButton.MouseEnter:Connect(function()
        createTween(dropdownFrame, {BackgroundColor3 = Theme.Colors.Hover}):Play()
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        createTween(dropdownFrame, {BackgroundColor3 = Theme.Colors.SurfaceLight}):Play()
    end)
    
    return self
end
    
    if options.list then
        local currentIndex = 1
        dropdownButton.MouseButton1Click:Connect(function()
            currentIndex = currentIndex + 1
            if currentIndex > #options.list then
                currentIndex = 1
            end
            
            local selectedValue = options.list[currentIndex]
            dropdownButton.Text = name .. ": " .. selectedValue
            
            if options.callback then
                options.callback(selectedValue)
            end
        end)
    end
    
    return self
end

-- Main library functions
function TabbedLibrary:CreateWindow(title)
    if not LibraryState.MainWindow then
        createMainWindow()
        createFloatingButton()
    end
    
    return self
end

function TabbedLibrary:CreateTab(name, icon)
    icon = icon or "📁"
    
    -- Ensure window is created first
    if not LibraryState.TabContainer or not LibraryState.ContentContainer then
        warn("Window must be created before creating tabs")
        return nil
    end
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_" .. name
    tabButton.Size = UDim2.new(1, 0, 0, Theme.Sizes.TabHeight)
    tabButton.BackgroundColor3 = Theme.Colors.Surface
    tabButton.Text = icon .. " " .. name
    tabButton.TextColor3 = Theme.Colors.TextSecondary
    tabButton.TextSize = 12
    tabButton.Font = Theme.Fonts.Primary
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.BorderSizePixel = 0
    tabButton.Parent = LibraryState.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, Theme.Sizes.Padding)
    tabPadding.Parent = tabButton
    
    -- Create tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = "Content_" .. name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Theme.Colors.Primary
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    tabContent.Parent = LibraryState.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, Theme.Sizes.Padding)
    contentLayout.Parent = tabContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, Theme.Sizes.Padding)
    contentPadding.PaddingBottom = UDim.new(0, Theme.Sizes.Padding)
    contentPadding.PaddingLeft = UDim.new(0, Theme.Sizes.Padding)
    contentPadding.PaddingRight = UDim.new(0, Theme.Sizes.Padding)
    contentPadding.Parent = tabContent
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + Theme.Sizes.Padding * 2)
    end)
    
    -- Tab functionality
    tabButton.MouseButton1Click:Connect(function()
        TabbedLibrary:SelectTab(name)
    end)
    
    tabButton.MouseEnter:Connect(function()
        if LibraryState.CurrentTab ~= name then
            createTween(tabButton, {BackgroundColor3 = Theme.Colors.TabHover}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if LibraryState.CurrentTab ~= name then
            createTween(tabButton, {BackgroundColor3 = Theme.Colors.Surface}):Play()
        end
    end)
    
    -- Create tab object
    local tab = setmetatable({
        Name = name,
        Button = tabButton,
        ContentFrame = tabContent
    }, Tab)
    
    LibraryState.Tabs[name] = tab
    LibraryState.TabFrames[name] = tabContent
    
    -- Select first tab automatically
    if #LibraryState.TabContainer:GetChildren() == 2 then -- Layout + first tab
        TabbedLibrary:SelectTab(name)
    end
    
    return tab
end

function TabbedLibrary:SelectTab(name)
    if not LibraryState.Tabs[name] then return end
    
    -- Hide all tabs
    for tabName, tabFrame in pairs(LibraryState.TabFrames) do
        tabFrame.Visible = false
        local tabButton = LibraryState.Tabs[tabName] and LibraryState.Tabs[tabName].Button
        if tabButton then
            createTween(tabButton, {
                BackgroundColor3 = Theme.Colors.Surface,
                TextColor3 = Theme.Colors.TextSecondary
            }):Play()
        end
    end
    
    -- Show selected tab with proper sizing and positioning
    local selectedFrame = LibraryState.TabFrames[name]
    selectedFrame.Visible = true
    selectedFrame.Size = UDim2.new(1, 0, 1, 0)
    selectedFrame.Position = UDim2.new(0, 0, 0, 0)
    
    -- Update scroll canvas size
    wait(0.1) -- Wait for UI to update
    local contentLayout = selectedFrame:FindFirstChild("UIListLayout")
    if contentLayout then
        selectedFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + Theme.Sizes.Padding * 2)
    end
    
    local selectedButton = LibraryState.Tabs[name] and LibraryState.Tabs[name].Button
    if selectedButton then
        createTween(selectedButton, {
            BackgroundColor3 = Theme.Colors.TabSelected,
            TextColor3 = Theme.Colors.TextPrimary
        }):Play()
    end
    
    LibraryState.CurrentTab = name
end

function TabbedLibrary:Show()
    if LibraryState.MainWindow then
        LibraryState.MainWindow.Enabled = true
        LibraryState.IsVisible = true
        
        if LibraryState.FloatingButton then
            LibraryState.FloatingButton.Visible = false
        end
        
        local mainFrame = LibraryState.MainWindow.MainWindow
        mainFrame.Position = UDim2.new(0.5, -Theme.Sizes.WindowWidth/2, 0.5, -Theme.Sizes.WindowHeight/2)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        createTween(mainFrame, {
            Size = UDim2.new(0, Theme.Sizes.WindowWidth, 0, Theme.Sizes.WindowHeight)
        }):Play()
    end
end

function TabbedLibrary:Hide()
    if LibraryState.MainWindow then
        LibraryState.IsVisible = false
        
        if LibraryState.FloatingButton then
            LibraryState.FloatingButton.Visible = true
        end
        
        local mainFrame = LibraryState.MainWindow.MainWindow
        local tween = createTween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0)
        })
        
        tween:Play()
        tween.Completed:Connect(function()
            LibraryState.MainWindow.Enabled = false
        end)
    end
end

function TabbedLibrary:Toggle()
    if LibraryState.IsVisible then
        self:Hide()
    else
        self:Show()
    end
end

function TabbedLibrary:Destroy()
    if LibraryState.MainWindow then
        LibraryState.MainWindow:Destroy()
    end
    if LibraryState.FloatingButtonGui then
        LibraryState.FloatingButtonGui:Destroy()
    end
    
    LibraryState = {
        MainWindow = nil,
        FloatingButton = nil,
        FloatingButtonGui = nil,
        IsVisible = true,
        CurrentTab = nil,
        Tabs = {},
        TabFrames = {}
    }
end

return TabbedLibrary
