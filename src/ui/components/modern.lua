--[[
    Modern UI Components Library
    Provides reusable UI components with dark theme
]]--

local Components = {}
local Theme = require(script.Parent.Parent.themes.dark)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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

-- Create rounded frame with shadow
function Components.CreateRoundedFrame(parent, properties)
    properties = properties or {}
    
    local frame = Instance.new("Frame")
    frame.Name = properties.Name or "RoundedFrame"
    frame.Parent = parent
    frame.Size = properties.Size or UDim2.new(0, 200, 0, 100)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = properties.BackgroundColor3 or Theme.Colors.Surface
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, properties.CornerRadius or Theme.Sizes.BorderRadius)
    corner.Parent = frame
    
    -- Add stroke if specified
    if properties.Stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = properties.StrokeColor or Theme.Colors.Border
        stroke.Thickness = properties.StrokeThickness or Theme.Sizes.BorderWidth
        stroke.Parent = frame
    end
    
    -- Add shadow effect
    if properties.Shadow then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Parent = frame
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, -5, 0, -5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(12, 12, 12, 12)
        shadow.ZIndex = frame.ZIndex - 1
    end
    
    return frame
end

-- Create modern button
function Components.CreateButton(parent, properties)
    properties = properties or {}
    
    local button = Instance.new("TextButton")
    button.Name = properties.Name or "ModernButton"
    button.Parent = parent
    button.Size = properties.Size or UDim2.new(0, 120, 0, Theme.Sizes.ButtonHeight)
    button.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = properties.BackgroundColor3 or Theme.Colors.Primary
    button.BorderSizePixel = 0
    button.Text = properties.Text or "Button"
    button.TextColor3 = properties.TextColor3 or Theme.Colors.TextPrimary
    button.TextSize = properties.TextSize or Theme.Sizes.TextSizeNormal
    button.Font = properties.Font or Theme.Fonts.Primary
    button.AutoButtonColor = false
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, properties.CornerRadius or Theme.Sizes.BorderRadius)
    corner.Parent = button
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, Theme.Sizes.PaddingNormal)
    padding.PaddingRight = UDim.new(0, Theme.Sizes.PaddingNormal)
    padding.Parent = button
    
    -- Add hover effects
    local originalColor = button.BackgroundColor3
    local hoverColor = properties.HoverColor or Theme.Colors.PrimaryHover
    local activeColor = properties.ActiveColor or Theme.Colors.PrimaryActive
    
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = originalColor}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        createTween(button, {BackgroundColor3 = activeColor}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}):Play()
    end)
    
    -- Connect callback
    if properties.Callback then
        button.MouseButton1Click:Connect(properties.Callback)
    end
    
    return button
end

-- Create toggle switch
function Components.CreateToggle(parent, properties)
    properties = properties or {}
    
    local toggleFrame = Components.CreateRoundedFrame(parent, {
        Name = properties.Name or "Toggle",
        Size = properties.Size or UDim2.new(0, 200, 0, 30),
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.SurfaceLight,
        Stroke = true
    })
    
    -- Toggle label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = toggleFrame
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, Theme.Sizes.PaddingNormal, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = properties.Text or "Toggle"
    label.TextColor3 = Theme.Colors.TextPrimary
    label.TextSize = Theme.Sizes.TextSizeNormal
    label.Font = Theme.Fonts.Primary
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle switch
    local switchFrame = Instance.new("Frame")
    switchFrame.Name = "Switch"
    switchFrame.Parent = toggleFrame
    switchFrame.Size = UDim2.new(0, 40, 0, 20)
    switchFrame.Position = UDim2.new(1, -45, 0.5, -10)
    switchFrame.BackgroundColor3 = Theme.Colors.Background
    switchFrame.BorderSizePixel = 0
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 10)
    switchCorner.Parent = switchFrame
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = switchFrame
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Theme.Colors.TextSecondary
    knob.BorderSizePixel = 0
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 8)
    knobCorner.Parent = knob
    
    -- Toggle state
    local toggled = properties.Default or false
    
    local function updateToggle()
        if toggled then
            createTween(knob, {
                Position = UDim2.new(0, 22, 0, 2),
                BackgroundColor3 = Theme.Colors.TextPrimary
            }):Play()
            createTween(switchFrame, {BackgroundColor3 = Theme.Colors.Primary}):Play()
        else
            createTween(knob, {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Theme.Colors.TextSecondary
            }):Play()
            createTween(switchFrame, {BackgroundColor3 = Theme.Colors.Background}):Play()
        end
        
        if properties.Callback then
            properties.Callback(toggled)
        end
    end
    
    -- Initial state
    updateToggle()
    
    -- Click event
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = toggleFrame
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    clickArea.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)
    
    -- Return toggle object with methods
    local toggleObject = {
        Frame = toggleFrame,
        SetValue = function(value)
            toggled = value
            updateToggle()
        end,
        GetValue = function()
            return toggled
        end
    }
    
    return toggleObject
end

-- Create dropdown
function Components.CreateDropdown(parent, properties)
    properties = properties or {}
    
    local dropdownFrame = Components.CreateRoundedFrame(parent, {
        Name = properties.Name or "Dropdown",
        Size = properties.Size or UDim2.new(0, 200, 0, 30),
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.SurfaceLight,
        Stroke = true
    })
    
    -- Dropdown label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = dropdownFrame
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, Theme.Sizes.PaddingNormal, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = properties.Text or "Select Option"
    label.TextColor3 = Theme.Colors.TextPrimary
    label.TextSize = Theme.Sizes.TextSizeNormal
    label.Font = Theme.Fonts.Primary
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Dropdown arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Parent = dropdownFrame
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.Colors.TextSecondary
    arrow.TextSize = Theme.Sizes.TextSizeNormal
    arrow.Font = Theme.Fonts.Primary
    
    -- Options list
    local optionsList = Components.CreateRoundedFrame(parent, {
        Name = "OptionsList",
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Theme.Colors.Surface,
        Stroke = true,
        Shadow = true
    })
    optionsList.Visible = false
    optionsList.ZIndex = 10
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsList
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 2)
    
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, Theme.Sizes.PaddingSmall)
    optionsPadding.PaddingBottom = UDim.new(0, Theme.Sizes.PaddingSmall)
    optionsPadding.Parent = optionsList
    
    local isOpen = false
    local selectedValue = nil
    local options = properties.Options or {}
    
    local function createOption(text, value)
        local option = Instance.new("TextButton")
        option.Name = "Option_" .. text
        option.Parent = optionsList
        option.Size = UDim2.new(1, 0, 0, 25)
        option.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        option.BackgroundTransparency = 1
        option.BorderSizePixel = 0
        option.Text = text
        option.TextColor3 = Theme.Colors.TextPrimary
        option.TextSize = Theme.Sizes.TextSizeNormal
        option.Font = Theme.Fonts.Primary
        option.TextXAlignment = Enum.TextXAlignment.Left
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, Theme.Sizes.PaddingNormal)
        optionPadding.Parent = option
        
        option.MouseEnter:Connect(function()
            createTween(option, {BackgroundTransparency = 0.8}):Play()
        end)
        
        option.MouseLeave:Connect(function()
            createTween(option, {BackgroundTransparency = 1}):Play()
        end)
        
        option.MouseButton1Click:Connect(function()
            selectedValue = value or text
            label.Text = text
            isOpen = false
            optionsList.Visible = false
            createTween(arrow, {Rotation = 0}):Play()
            
            if properties.Callback then
                properties.Callback(selectedValue)
            end
        end)
        
        return option
    end
    
    -- Add options
    for _, option in ipairs(options) do
        if type(option) == "table" then
            createOption(option.Text or option.Name, option.Value)
        else
            createOption(option, option)
        end
    end
    
    -- Update list size
    local function updateListSize()
        local contentSize = optionsLayout.AbsoluteContentSize.Y
        optionsList.Size = UDim2.new(0, 200, 0, contentSize + Theme.Sizes.PaddingSmall * 2)
    end
    
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)
    updateListSize()
    
    -- Click event
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = dropdownFrame
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    clickArea.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsList.Visible = isOpen
        
        if isOpen then
            createTween(arrow, {Rotation = 180}):Play()
        else
            createTween(arrow, {Rotation = 0}):Play()
        end
    end)
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            local mouse = UserInputService:GetMouseLocation()
            local dropdownPos = dropdownFrame.AbsolutePosition
            local dropdownSize = dropdownFrame.AbsoluteSize
            local listPos = optionsList.AbsolutePosition
            local listSize = optionsList.AbsoluteSize
            
            if not ((mouse.X >= dropdownPos.X and mouse.X <= dropdownPos.X + dropdownSize.X and
                     mouse.Y >= dropdownPos.Y and mouse.Y <= dropdownPos.Y + dropdownSize.Y) or
                    (mouse.X >= listPos.X and mouse.X <= listPos.X + listSize.X and
                     mouse.Y >= listPos.Y and mouse.Y <= listPos.Y + listSize.Y)) then
                isOpen = false
                optionsList.Visible = false
                createTween(arrow, {Rotation = 0}):Play()
            end
        end
    end)
    
    -- Return dropdown object
    local dropdownObject = {
        Frame = dropdownFrame,
        AddOption = function(text, value)
            createOption(text, value)
            updateListSize()
        end,
        SetValue = function(value)
            selectedValue = value
            label.Text = value
        end,
        GetValue = function()
            return selectedValue
        end
    }
    
    return dropdownObject
end

return Components
