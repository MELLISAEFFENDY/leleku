--[[
    Dark Modern Theme for UI Library
    Created for modern Roblox UI design
]]--

local Theme = {}

-- Color Palette
Theme.Colors = {
    -- Primary Colors
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(25, 25, 30),
    SurfaceLight = Color3.fromRGB(30, 30, 35),
    
    -- Accent Colors
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(98, 111, 252),
    PrimaryActive = Color3.fromRGB(78, 91, 232),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(185, 187, 190),
    TextMuted = Color3.fromRGB(115, 118, 123),
    
    -- Border Colors
    Border = Color3.fromRGB(40, 40, 45),
    BorderLight = Color3.fromRGB(50, 50, 55),
    
    -- Status Colors
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    
    -- Interactive States
    Hover = Color3.fromRGB(35, 35, 40),
    Active = Color3.fromRGB(45, 45, 50),
    Disabled = Color3.fromRGB(60, 60, 65),
    
    -- Transparency Values
    Transparent = Color3.fromRGB(0, 0, 0),
    SemiTransparent = Color3.fromRGB(0, 0, 0)
}

-- Transparency Values
Theme.Transparency = {
    Opaque = 0,
    SemiOpaque = 0.1,
    Translucent = 0.3,
    SemiTransparent = 0.5,
    Transparent = 0.8,
    FullTransparent = 1
}

-- Font Settings
Theme.Fonts = {
    Primary = Enum.Font.GothamMedium,
    Secondary = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
    Light = Enum.Font.Gotham
}

-- Size Settings
Theme.Sizes = {
    -- Window
    WindowMinWidth = 400,
    WindowMinHeight = 300,
    WindowTitleHeight = 35,
    
    -- Buttons
    ButtonHeight = 30,
    ButtonPadding = 8,
    
    -- Text
    TextSizeSmall = 12,
    TextSizeNormal = 14,
    TextSizeLarge = 16,
    TextSizeTitle = 18,
    
    -- Spacing
    PaddingSmall = 4,
    PaddingNormal = 8,
    PaddingLarge = 12,
    PaddingXLarge = 16,
    
    -- Borders
    BorderRadius = 6,
    BorderWidth = 1,
    
    -- Floating Button
    FloatingButtonSize = 50,
    FloatingButtonRadius = 25
}

-- Animation Settings
Theme.Animations = {
    Speed = 0.25,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out
}

-- Gradients
Theme.Gradients = {
    Primary = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Colors.Primary),
        ColorSequenceKeypoint.new(1, Theme.Colors.PrimaryActive)
    },
    Surface = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Colors.Surface),
        ColorSequenceKeypoint.new(1, Theme.Colors.SurfaceLight)
    }
}

return Theme
