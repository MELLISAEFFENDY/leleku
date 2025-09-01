--[[
    Modern Dark UI Library with Floating Button System
    Features:
    - Dark modern theme
    - Floating button for minimize/restore
    - Close and minimize functionality
    - Draggable windows
    - Smooth animations
]]--

local Library = {}

-- Load theme directly from GitHub when script is loaded via loadstring
local Theme
local Components

-- Try to load theme, fallback to inline theme if fails
local success, themeResult = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/ui/themes/dark.lua'))()
end)

if success and themeResult then
    Theme = themeResult
else
    -- Fallback inline theme
    Theme = {
        Colors = {
            Background = Color3.fromRGB(20, 20, 25),
            Surface = Color3.fromRGB(25, 25, 30),
            SurfaceLight = Color3.fromRGB(30, 30, 35),
            Primary = Color3.fromRGB(88, 101, 242),
            PrimaryHover = Color3.fromRGB(98, 111, 252),
            PrimaryActive = Color3.fromRGB(78, 91, 232),
            TextPrimary = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(185, 187, 190),
            TextMuted = Color3.fromRGB(115, 118, 123),
            Border = Color3.fromRGB(40, 40, 45),
            BorderLight = Color3.fromRGB(50, 50, 55),
            Success = Color3.fromRGB(67, 181, 129),
            Warning = Color3.fromRGB(250, 166, 26),
            Error = Color3.fromRGB(237, 66, 69),
            Hover = Color3.fromRGB(35, 35, 40),
            Active = Color3.fromRGB(45, 45, 50),
            Disabled = Color3.fromRGB(60, 60, 65)
        },
        Sizes = {
            WindowMinWidth = 400,
            WindowMinHeight = 300,
            WindowTitleHeight = 35,
            ButtonHeight = 30,
            ButtonPadding = 8,
            TextSizeSmall = 12,
            TextSizeNormal = 14,
            TextSizeLarge = 16,
            TextSizeTitle = 18,
            PaddingSmall = 4,
            PaddingNormal = 8,
            PaddingLarge = 12,
            PaddingXLarge = 16,
            BorderRadius = 6,
            BorderWidth = 1,
            FloatingButtonSize = 50,
            FloatingButtonRadius = 25
        },
        Animations = {
            Speed = 0.25,
            EasingStyle = Enum.EasingStyle.Quad,
            EasingDirection = Enum.EasingDirection.Out
        },
        Fonts = {
            Primary = Enum.Font.GothamMedium,
            Secondary = Enum.Font.Gotham,
            Bold = Enum.Font.GothamBold,
            Light = Enum.Font.Gotham
        }
    }
end

-- Try to load components, fallback if fails
local componentsSuccess, componentsResult = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/leleku/master/src/ui/components/modern.lua'))()
end)

if componentsSuccess and componentsResult then
    Components = componentsResult
else
    -- Basic fallback components
    Components = {}
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Library state
local LibraryState = {
    Windows = {},
    FloatingButton = nil,
    IsMinimized = false,
    MainContainer = nil
}

-- Helper function to create tween
local function createTween(object, properties, duration)
    duration = duration or Theme.Animations.Speed
    local tweenInfo = TweenInfo.new(
        duration,
        Theme.Animations.EasingStyle,
        Theme.Animations.EasingDirection
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Create floating button
local function createFloatingButton()
    if LibraryState.FloatingButton then
        LibraryState.FloatingButton:Destroy()
    end
    
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Parent = PlayerGui
    floatingButton.Size = UDim2.new(0, Theme.Sizes.FloatingButtonSize, 0, Theme.Sizes.FloatingButtonSize)
    floatingButton.Position = UDim2.new(1, -Theme.Sizes.FloatingButtonSize - 20, 0, 100)
    floatingButton.BackgroundColor3 = Theme.Colors.Primary
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = "📋"
    floatingButton.TextColor3 = Theme.Colors.TextPrimary
    floatingButton.TextSize = 20
    floatingButton.Font = Theme.Fonts.Primary
    floatingButton.ZIndex = 1000
    floatingButton.AutoButtonColor = false
    
    -- Make it circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Theme.Sizes.FloatingButtonRadius)
    corner.Parent = floatingButton
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = floatingButton
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(12, 12, 12, 12)
    shadow.ZIndex = floatingButton.ZIndex - 1
    
    -- Hover effects
    floatingButton.MouseEnter:Connect(function()
        createTween(floatingButton, {
            Size = UDim2.new(0, Theme.Sizes.FloatingButtonSize + 5, 0, Theme.Sizes.FloatingButtonSize + 5),
            BackgroundColor3 = Theme.Colors.PrimaryHover
        }):Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        createTween(floatingButton, {
            Size = UDim2.new(0, Theme.Sizes.FloatingButtonSize, 0, Theme.Sizes.FloatingButtonSize),
            BackgroundColor3 = Theme.Colors.Primary
        }):Play()
    end)
    
    -- Click to restore
    floatingButton.MouseButton1Click:Connect(function()
        Library:RestoreWindows()
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = floatingButton.Position
        end
    end)
    
    floatingButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            floatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    floatingButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    LibraryState.FloatingButton = floatingButton
    return floatingButton
end

-- Create main container
local function createMainContainer()
    if LibraryState.MainContainer then
        LibraryState.MainContainer:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernUILibrary"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    LibraryState.MainContainer = screenGui
    return screenGui
end

-- Window object
local Window = {}
Window.__index = Window

function Window:Section(name)
    local section = {}
    
    -- Create section frame
    local sectionFrame = Components.CreateRoundedFrame(self.ContentFrame, {
        Name = "Section_" .. name,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1
    })
    
    -- Section label
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "SectionLabel"
    sectionLabel.Parent = sectionFrame
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = name
    sectionLabel.TextColor3 = Theme.Colors.Primary
    sectionLabel.TextSize = Theme.Sizes.TextSizeLarge
    sectionLabel.Font = Theme.Fonts.Bold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, Theme.Sizes.PaddingNormal)
    padding.PaddingTop = UDim.new(0, Theme.Sizes.PaddingSmall)
    padding.Parent = sectionFrame
    
    -- Update layout
    self:UpdateLayout()
    
    return section
end

function Window:Toggle(name, options)
    options = options or {}
    
    local toggle = Components.CreateToggle(self.ContentFrame, {
        Name = "Toggle_" .. name,
        Text = name,
        Default = options.default,
        Callback = function(value)
            if options.location and options.flag then
                options.location[options.flag] = value
            end
            if options.callback then
                options.callback(value)
            end
        end
    })
    
    self:UpdateLayout()
    return toggle
end

function Window:Button(name, callback)
    local button = Components.CreateButton(self.ContentFrame, {
        Name = "Button_" .. name,
        Text = name,
        Size = UDim2.new(1, 0, 0, Theme.Sizes.ButtonHeight),
        Callback = callback
    })
    
    self:UpdateLayout()
    return button
end

function Window:Dropdown(name, options)
    options = options or {}
    
    local dropdown = Components.CreateDropdown(self.ContentFrame, {
        Name = "Dropdown_" .. name,
        Text = name,
        Options = options.list or {},
        Callback = function(value)
            if options.location and options.flag then
                options.location[options.flag] = value
            end
            if options.callback then
                options.callback(value)
            end
        end
    })
    
    self:UpdateLayout()
    return dropdown
end

function Window:UpdateLayout()
    local contentSize = self.ContentLayout.AbsoluteContentSize.Y
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize + Theme.Sizes.PaddingLarge)
end

function Window:Close()
    self.WindowFrame.Visible = false
    LibraryState.Windows[self.Name] = nil
    
    -- Check if all windows are closed
    local hasVisibleWindows = false
    for _, window in pairs(LibraryState.Windows) do
        if window.WindowFrame.Visible then
            hasVisibleWindows = true
            break
        end
    end
    
    if not hasVisibleWindows then
        Library:MinimizeAll()
    end
end

function Window:Minimize()
    self.WindowFrame.Visible = false
end

function Window:Restore()
    self.WindowFrame.Visible = true
end

-- Library functions
function Library:CreateWindow(name, options)
    options = options or {}
    
    if not LibraryState.MainContainer then
        createMainContainer()
    end
    
    local windowFrame = Components.CreateRoundedFrame(LibraryState.MainContainer, {
        Name = "Window_" .. name,
        Size = options.Size or UDim2.new(0, 450, 0, 400),
        Position = options.Position or UDim2.new(0, 50, 0, 50),
        BackgroundColor3 = Theme.Colors.Background,
        Stroke = true,
        Shadow = true
    })
    
    -- Title bar
    local titleBar = Components.CreateRoundedFrame(windowFrame, {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, Theme.Sizes.WindowTitleHeight),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.Surface,
        CornerRadius = Theme.Sizes.BorderRadius
    })
    
    -- Window title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = titleBar
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, Theme.Sizes.PaddingNormal, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Theme.Colors.TextPrimary
    titleLabel.TextSize = Theme.Sizes.TextSizeTitle
    titleLabel.Font = Theme.Fonts.Bold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local closeButton = Components.CreateButton(titleBar, {
        Name = "CloseButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0.5, -12.5),
        Text = "✕",
        BackgroundColor3 = Theme.Colors.Error,
        HoverColor = Color3.fromRGB(255, 100, 100),
        TextSize = 12,
        Callback = function()
            LibraryState.Windows[name]:Close()
        end
    })
    
    -- Minimize button
    local minimizeButton = Components.CreateButton(titleBar, {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -60, 0.5, -12.5),
        Text = "─",
        BackgroundColor3 = Theme.Colors.Warning,
        HoverColor = Color3.fromRGB(255, 200, 100),
        TextSize = 12,
        Callback = function()
            Library:MinimizeAll()
        end
    })
    
    -- Content area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Parent = windowFrame
    contentFrame.Size = UDim2.new(1, 0, 1, -Theme.Sizes.WindowTitleHeight)
    contentFrame.Position = UDim2.new(0, 0, 0, Theme.Sizes.WindowTitleHeight)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Theme.Colors.Primary
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Content layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Name = "ContentLayout"
    contentLayout.Parent = contentFrame
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, Theme.Sizes.PaddingSmall)
    
    -- Content padding
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, Theme.Sizes.PaddingNormal)
    contentPadding.PaddingRight = UDim.new(0, Theme.Sizes.PaddingNormal)
    contentPadding.PaddingTop = UDim.new(0, Theme.Sizes.PaddingNormal)
    contentPadding.PaddingBottom = UDim.new(0, Theme.Sizes.PaddingNormal)
    contentPadding.Parent = contentFrame
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Create window object
    local window = setmetatable({
        Name = name,
        WindowFrame = windowFrame,
        TitleBar = titleBar,
        ContentFrame = contentFrame,
        ContentLayout = contentLayout,
        Options = options
    }, Window)
    
    LibraryState.Windows[name] = window
    
    return window
end

function Library:MinimizeAll()
    for _, window in pairs(LibraryState.Windows) do
        window:Minimize()
    end
    
    LibraryState.IsMinimized = true
    
    -- Show floating button
    if not LibraryState.FloatingButton then
        createFloatingButton()
    else
        LibraryState.FloatingButton.Visible = true
    end
end

function Library:RestoreWindows()
    for _, window in pairs(LibraryState.Windows) do
        window:Restore()
    end
    
    LibraryState.IsMinimized = false
    
    -- Hide floating button
    if LibraryState.FloatingButton then
        LibraryState.FloatingButton.Visible = false
    end
end

function Library:DestroyAll()
    if LibraryState.MainContainer then
        LibraryState.MainContainer:Destroy()
    end
    
    if LibraryState.FloatingButton then
        LibraryState.FloatingButton:Destroy()
    end
    
    LibraryState.Windows = {}
    LibraryState.MainContainer = nil
    LibraryState.FloatingButton = nil
    LibraryState.IsMinimized = false
end

-- Initialize
createMainContainer()

return Library
