local UILibrary = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

print("Nig")
-- Color conversion functions
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    local imod = i % 6
    if imod == 0 then r, g, b = v, t, p
    elseif imod == 1 then r, g, b = q, v, p
    elseif imod == 2 then r, g, b = p, v, t
    elseif imod == 3 then r, g, b = p, q, v
    elseif imod == 4 then r, g, b = t, p, v
    elseif imod == 5 then r, g, b = v, p, q end
    
    return r, g, b
end

local function RGBtoHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    s = max == 0 and 0 or d / max
    if max == min then h = 0
    else
        if max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

local function smoothTween(instance, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function safeParentGui(gui, player)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not ok or not gui.Parent then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end

-- Shared factory: creates a small color-icon button + a floating HSV color picker
local function createColorPickerIcon(iconParent, iconOffset, defaultColor, callback, player, windowName, themeCallbacks)
    local ColorIcon = Instance.new("TextButton")
    ColorIcon.Name = "ColorIcon"
    ColorIcon.Parent = iconParent
    ColorIcon.BackgroundColor3 = defaultColor
    ColorIcon.AnchorPoint = Vector2.new(1, 0.5)
    ColorIcon.Position = UDim2.new(1, iconOffset, 0.5, 0)
    ColorIcon.Size = UDim2.new(0, 18, 0, 18)
    ColorIcon.Text = ""
    ColorIcon.AutoButtonColor = false
    ColorIcon.ZIndex = 2
    ColorIcon.BorderSizePixel = 0

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = ColorIcon

    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = Color3.fromRGB(60, 60, 60)
    colorStroke.Thickness = 1.5
    colorStroke.Parent = ColorIcon

    ColorIcon.MouseEnter:Connect(function()
        smoothTween(colorStroke, {Thickness = 2})
        smoothTween(ColorIcon, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
    end)
    ColorIcon.MouseLeave:Connect(function()
        smoothTween(colorStroke, {Thickness = 1.5})
        smoothTween(ColorIcon, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
    end)

    local colorPickerScreenGui = Instance.new("ScreenGui")
    colorPickerScreenGui.Name = "ColorPickerGui_" .. windowName
    colorPickerScreenGui.ResetOnSpawn = false
    colorPickerScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    colorPickerScreenGui.DisplayOrder = 10001
    safeParentGui(colorPickerScreenGui, player)

    local colorPickerWindow = Instance.new("Frame")
    colorPickerWindow.Name = "ColorPickerWindow"
    colorPickerWindow.Parent = colorPickerScreenGui
    colorPickerWindow.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    colorPickerWindow.BorderSizePixel = 0
    colorPickerWindow.Position = UDim2.new(0.5, -125, 0.5, -100)
    colorPickerWindow.Size = UDim2.new(0, 250, 0, 200)
    colorPickerWindow.Visible = false
    colorPickerWindow.ZIndex = 100
    colorPickerWindow.AnchorPoint = Vector2.new(0, 0)

    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = Color3.fromRGB(0, 0, 0)
    windowStroke.LineJoinMode = Enum.LineJoinMode.Miter
    windowStroke.Thickness = 1.5
    windowStroke.Parent = colorPickerWindow

    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 2)
    titleFrame.Parent = colorPickerWindow
    titleFrame.BackgroundColor3 = defaultColor
    titleFrame.BorderSizePixel = 0
    table.insert(themeCallbacks, function(c) if titleFrame.Parent then titleFrame.BackgroundColor3 = c end end)

    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = "ColorPickerFrame"
    colorPickerFrame.Parent = colorPickerWindow
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Position = UDim2.new(0, 15, 0, 15)
    colorPickerFrame.Size = UDim2.new(1, -30, 1, -30)
    colorPickerFrame.ZIndex = 101

    local saturationValueBox = Instance.new("Frame")
    saturationValueBox.Name = "SaturationValueBox"
    saturationValueBox.Parent = colorPickerFrame
    saturationValueBox.BackgroundColor3 = Color3.new(1, 0, 0)
    saturationValueBox.BorderSizePixel = 0
    saturationValueBox.Size = UDim2.new(0, 180, 0, 150)
    saturationValueBox.ZIndex = 101

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 0)
    svCorner.Parent = saturationValueBox

    local svOverlay = Instance.new("Frame")
    svOverlay.Parent = saturationValueBox
    svOverlay.Size = UDim2.new(1, 0, 1, 0)
    svOverlay.ZIndex = 102
    svOverlay.BorderSizePixel = 0

    local saturationGradient = Instance.new("UIGradient")
    saturationGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    saturationGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    saturationGradient.Parent = svOverlay

    local svOverlay2 = Instance.new("Frame")
    svOverlay2.Parent = saturationValueBox
    svOverlay2.BackgroundColor3 = Color3.new(0, 0, 0)
    svOverlay2.Size = UDim2.new(1, 0, 1, 0)
    svOverlay2.ZIndex = 103
    svOverlay2.BorderSizePixel = 0

    local valueGradient = Instance.new("UIGradient")
    valueGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    valueGradient.Rotation = 90
    valueGradient.Parent = svOverlay2

    local saturationValueButton = Instance.new("TextButton")
    saturationValueButton.Parent = saturationValueBox
    saturationValueButton.BackgroundColor3 = Color3.new(1, 1, 1)
    saturationValueButton.BorderSizePixel = 0
    saturationValueButton.Position = UDim2.new(0.5, -5, 0.5, -5)
    saturationValueButton.Size = UDim2.new(0, 10, 0, 10)
    saturationValueButton.Text = ""
    saturationValueButton.ZIndex = 104
    saturationValueButton.AutoButtonColor = false

    local svButtonCorner = Instance.new("UICorner")
    svButtonCorner.CornerRadius = UDim.new(1,0)
    svButtonCorner.Parent = saturationValueButton

    local svButtonStroke = Instance.new("UIStroke")
    svButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    svButtonStroke.Thickness = 2
    svButtonStroke.Parent = saturationValueButton

    local hueSlider = Instance.new("Frame")
    hueSlider.Parent = colorPickerFrame
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel = 0
    hueSlider.Position = UDim2.new(0, 195, 0, 0)
    hueSlider.Size = UDim2.new(0, 25, 0, 150)
    hueSlider.ZIndex = 101

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueSlider

    local hueSliderGradient = Instance.new("UIGradient")
    hueSliderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueSliderGradient.Rotation = 90
    hueSliderGradient.Parent = hueSlider

    local hueSliderButton = Instance.new("TextButton")
    hueSliderButton.Parent = hueSlider
    hueSliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSliderButton.BorderSizePixel = 0
    hueSliderButton.Size = UDim2.new(1, 6, 0, 6)
    hueSliderButton.Text = ""
    hueSliderButton.ZIndex = 102
    hueSliderButton.AutoButtonColor = false

    local hueButtonCorner = Instance.new("UICorner")
    hueButtonCorner.CornerRadius = UDim.new(0, 3)
    hueButtonCorner.Parent = hueSliderButton

    local hueButtonStroke = Instance.new("UIStroke")
    hueButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    hueButtonStroke.Thickness = 2
    hueButtonStroke.Parent = hueSliderButton

    local currentColor = defaultColor or Color3.new(1, 1, 1)
    local hue, saturation, value = 0, 0, 1
    local updating = false

    local function updateColor()
        if updating then return end
        updating = true
        local r, g, b = HSVtoRGB(hue, saturation, value)
        currentColor = Color3.new(r, g, b)
        saturationValueBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

        local hueY = math.clamp(hue * 144, 0, 144)
        local satX = math.clamp(saturation * 170, 0, 170)
        local valY = math.clamp((1 - value) * 140, 0, 140)

        smoothTween(hueSliderButton, {Position = UDim2.new(0, -3, 0, hueY)}, 0.1)
        smoothTween(saturationValueButton, {Position = UDim2.new(0, satX, 0, valY)}, 0.1)
        smoothTween(ColorIcon, {BackgroundColor3 = currentColor}, 0.15)
        updating = false

        if callback then callback(currentColor) end
    end

    local function updateFromRGB(color)
        if updating then return end
        hue, saturation, value = RGBtoHSV(color.R, color.G, color.B)
        updateColor()
    end

    local hueDragging = false
    local svDragging = false
    local pickerConnections = {}

    table.insert(pickerConnections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if hueDragging then
                local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 144)
                hue = yPos / 144
                updateColor()
            elseif svDragging then
                local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 170)
                local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 140)
                saturation = xPos / 170
                value = 1 - (yPos / 140)
                updateColor()
            end
        end
    end))

    table.insert(pickerConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            svDragging = false
        end
    end))

    hueSliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
    end)
    saturationValueButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
    end)
    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 170)
            local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 140)
            saturation = xPos / 170
            value = 1 - (yPos / 140)
            updateColor()
            svDragging = true
        end
    end)
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 144)
            hue = yPos / 144
            updateColor()
            hueDragging = true
        end
    end)

    if defaultColor then updateFromRGB(defaultColor) else updateColor() end

    ColorIcon.MouseButton1Click:Connect(function()
        if colorPickerWindow.Visible then 
            colorPickerWindow.Visible = false 
            return 
        end
        -- Spawn next to icon instead of center screen
        local ip = ColorIcon.AbsolutePosition
        local vp = workspace.CurrentCamera.ViewportSize
        local pw, ph = 250, 200
        local x = ip.X + 24
        local y = ip.Y
        if x + pw > vp.X then x = ip.X - pw - 6 end
        if y + ph > vp.Y then y = vp.Y - ph - 10 end
        colorPickerWindow.Position = UDim2.new(0, x, 0, y)
        colorPickerWindow.Visible = true
    end)

    local clickOutsideConnection
    clickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorPickerWindow.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local windowPos = colorPickerWindow.AbsolutePosition
            local windowSize = colorPickerWindow.AbsoluteSize
            local ip = ColorIcon.AbsolutePosition
            local is = ColorIcon.AbsoluteSize
            local onIcon = mousePos.X >= ip.X and mousePos.X <= ip.X + is.X and mousePos.Y >= ip.Y and mousePos.Y <= ip.Y + is.Y

            if not onIcon and (mousePos.X < windowPos.X or mousePos.X > windowPos.X + windowSize.X or
               mousePos.Y < windowPos.Y or mousePos.Y > windowPos.Y + windowSize.Y) then
                colorPickerWindow.Visible = false
            end
        end
    end)

    return {
        Icon = ColorIcon,
        SetColor = function(color) updateFromRGB(color) end,
        GetColor = function() return currentColor end,
        Show = function() colorPickerWindow.Visible = true end,
        Hide = function() colorPickerWindow.Visible = false end,
        Destroy = function()
            for _, conn in ipairs(pickerConnections) do pcall(function() conn:Disconnect() end) end
            if clickOutsideConnection then clickOutsideConnection:Disconnect() end
            colorPickerScreenGui:Destroy()
            ColorIcon:Destroy()
        end
    }
end

-- Main UI creation function
function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    
    local defaultOptions = {
        Name = "UI Library", ToggleKey = Enum.KeyCode.RightShift,
        DefaultColor = Color3.fromRGB(138, 102, 204), TextColor = Color3.fromRGB(220, 220, 220),
        BackgroundColor = Color3.fromRGB(18, 18, 18), TabHolderColor = Color3.fromRGB(15, 15, 15),
        GroupboxColor = Color3.fromRGB(22, 22, 22), Size = UDim2.new(0, 570, 0, 469),
        Position = UDim2.new(0.226, 0, 0.146, 0), Theme = "Dark",
        Watermark = true, WatermarkText = "UI Library v1.0.0"
    }
    for option, value in pairs(defaultOptions) do
        if options[option] == nil then options[option] = value end
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MainBackGround = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local MainStroke = Instance.new("UIStroke")
    local TabHolder = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    local ContentFrame = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")
    
    local connections = {} -- Track all UIS connections to prevent memory leaks
    local themeCallbacks = {} -- Track elements for dynamic theme changing

    ScreenGui.Name = options.Name
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 10000
    safeParentGui(ScreenGui, player)

    MainBackGround.Name = "MainBackGround"
    MainBackGround.Parent = ScreenGui
    MainBackGround.BackgroundColor3 = options.BackgroundColor
    MainBackGround.BorderSizePixel = 0
    MainBackGround.Position = options.Position
    MainBackGround.Size = options.Size
    MainBackGround.ClipsDescendants = true -- Fixed: Prevents UI bleeding out of the main frame
    
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainBackGround
    MainStroke.Color = Color3.fromRGB(45, 45, 45)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainBackGround

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = MainBackGround
    TabHolder.BackgroundColor3 = options.TabHolderColor
    TabHolder.BorderSizePixel = 0
    TabHolder.Size = UDim2.new(0, 130, 1, 0)
    
    UICorner_2.CornerRadius = UDim.new(0, 8)
    UICorner_2.Parent = TabHolder

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabHolder
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabHolder
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)

    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainBackGround
    ContentFrame.BackgroundColor3 = options.BackgroundColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 138, 0, 10)
    ContentFrame.Size = UDim2.new(1, -148, 1, -20)
    
    UICorner_3.CornerRadius = UDim.new(0, 6)
    UICorner_3.Parent = ContentFrame

    local Watermark
    if options.Watermark then
        Watermark = Instance.new("TextLabel")
        Watermark.Name = "Watermark"
        Watermark.Parent = ScreenGui
        Watermark.BackgroundTransparency = 1
        Watermark.Position = UDim2.new(0, 10, 0, 10)
        Watermark.Size = UDim2.new(0, 200, 0, 20)
        Watermark.Font = Enum.Font.GothamBold
        Watermark.Text = options.WatermarkText
        Watermark.TextColor3 = options.DefaultColor
        Watermark.TextSize = 13
        Watermark.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(themeCallbacks, function(c) if Watermark.Parent then Watermark.TextColor3 = c end end)
    end

    local tabs = {}
    local currentTab = nil
    local Window = {}
    Window.ActiveTab = nil
    Window.Theme = options.Theme
    Window.DefaultColor = options.DefaultColor
    Window.TextColor = options.TextColor

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == options.ToggleKey then
            Window:ToggleVisibility()
        end
    end))

    function Window:AddTab(name)
        local TabButton = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabHighlight = Instance.new("Frame")
        local TabCorner = Instance.new("UICorner")
        local LeftContainer = Instance.new("Frame")
        local LeftLayout = Instance.new("UIListLayout")
        local RightContainer = Instance.new("Frame")
        local RightLayout = Instance.new("UIListLayout")

        TabButton.Name = name .. "Tab"
        TabButton.Parent = TabHolder
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.BackGroundColor = Color3.fromRGB(27, 42, 53)
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = name
        TabButton.TextColor3 = options.TextColor
        TabButton.TextTransparency = 0.5
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        local TabPad = Instance.new("UIPadding")
        TabPad.Parent = TabButton
        TabPad.PaddingLeft = UDim.new(0, 12)

        TabHighlight.Parent = TabButton
        TabHighlight.BackgroundColor3 = options.DefaultColor
        TabHighlight.BorderSizePixel = 0
        TabHighlight.Position = UDim2.new(0, -17, 0, 0)
        TabHighlight.Size = UDim2.new(0, 2, 1, 0)
        TabHighlight.ZIndex = 2
        TabHighlight.Visible = false
        
        local HighlightCorner = Instance.new("UICorner")
        HighlightCorner.CornerRadius = UDim.new(0, 6)
        HighlightCorner.Parent = TabHighlight
        table.insert(themeCallbacks, function(c) if TabHighlight.Parent then TabHighlight.BackgroundColor3 = c end end)

        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = options.DefaultColor
        TabContent.Visible = false
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        TabContent.ClipsDescendants = true -- Fixed: Prevent elements drawing outside the scroll area
        table.insert(themeCallbacks, function(c) if TabContent.Parent then TabContent.ScrollBarImageColor3 = c end end)

        LeftContainer.Parent = TabContent
        LeftContainer.BackgroundTransparency = 1
        LeftContainer.Position = UDim2.new(0, 10, 0, 10)
        LeftContainer.Size = UDim2.new(0.5, -15, 0, 0)
        LeftContainer.AutomaticSize = Enum.AutomaticSize.Y
        
        LeftLayout.Parent = LeftContainer
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 12)

        RightContainer.Parent = TabContent
        RightContainer.BackgroundTransparency = 1
        RightContainer.Position = UDim2.new(0.5, 5, 0, 10)
        RightContainer.Size = UDim2.new(0.5, -15, 0, 0)
        RightContainer.AutomaticSize = Enum.AutomaticSize.Y
        
        RightLayout.Parent = RightContainer
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 12)

        local function updateContentSize()
            local leftHeight = LeftLayout.AbsoluteContentSize.Y + 30
            local rightHeight = RightLayout.AbsoluteContentSize.Y + 30
            TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftHeight, rightHeight))
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)

        local tab = {
            Button = TabButton, Content = TabContent, Highlight = TabHighlight,
            LeftContainer = LeftContainer, RightContainer = RightContainer,
            Groupboxes = {},
            AddLeftGroupbox = function(self, name) return self:CreateGroupbox(name, "Left") end,
            AddRightGroupbox = function(self, name) return self:CreateGroupbox(name, "Right") end,
            CreateGroupbox = function(self, name, side)
                local GroupboxFrame = Instance.new("Frame")
                local GroupboxTitle = Instance.new("TextLabel")
                local GroupboxContent = Instance.new("Frame")
                local GroupboxLayout = Instance.new("UIListLayout")

                GroupboxFrame.Name = name .. "Groupbox"
                GroupboxFrame.BackgroundColor3 = options.GroupboxColor
                GroupboxFrame.BorderSizePixel = 0
                GroupboxFrame.Size = UDim2.new(1, 0, 0, 0)
                GroupboxFrame.AutomaticSize = Enum.AutomaticSize.Y
                GroupboxFrame.LayoutOrder = #self.Groupboxes + 1
                GroupboxFrame.Parent = side == "Left" and LeftContainer or RightContainer

                local GBCorner = Instance.new("UICorner")
                GBCorner.CornerRadius = UDim.new(0, 6)
                GBCorner.Parent = GroupboxFrame
                local GBStroke = Instance.new("UIStroke")
                GBStroke.Color = Color3.fromRGB(35, 35, 35)
                GBStroke.Parent = GroupboxFrame

                GroupboxTitle.Parent = GroupboxFrame
                GroupboxTitle.BackgroundTransparency = 1
                GroupboxTitle.Position = UDim2.new(0, 12, 0, 8)
                GroupboxTitle.Size = UDim2.new(1, -24, 0, 20)
                GroupboxTitle.Font = Enum.Font.GothamBold
                GroupboxTitle.Text = name
                GroupboxTitle.TextColor3 = options.DefaultColor
                GroupboxTitle.TextSize = 13
                GroupboxTitle.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(themeCallbacks, function(c) if GroupboxTitle.Parent then GroupboxTitle.TextColor3 = c end end)

                GroupboxContent.Parent = GroupboxFrame
                GroupboxContent.BackgroundTransparency = 1
                GroupboxContent.Position = UDim2.new(0, 12, 0, 35)
                GroupboxContent.Size = UDim2.new(1, -24, 0, 0)
                GroupboxContent.AutomaticSize = Enum.AutomaticSize.Y

                GroupboxLayout.Parent = GroupboxContent
                GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
                GroupboxLayout.Padding = UDim.new(0, 8)
                local GBPadding = Instance.new("UIPadding")
                GBPadding.PaddingBottom = UDim.new(0, 10)
                GBPadding.Parent = GroupboxContent

                local groupbox = {
                    Frame = GroupboxFrame, Content = GroupboxContent, Elements = {},
                    AddToggle = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local ToggleFrame = Instance.new("Frame")
                        local ToggleButton = Instance.new("TextButton")
                        local ToggleIndicator = Instance.new("Frame")
                        local ToggleCheckmark = Instance.new("TextLabel")
                        local ToggleText = Instance.new("TextLabel")

                        ToggleFrame.Name = id .. "Toggle"
                        ToggleFrame.Parent = GroupboxContent
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
                        ToggleFrame.LayoutOrder = #self.Elements + 1
                    
                        ToggleButton.Parent = ToggleFrame
                        ToggleButton.BackgroundTransparency = 1
                        ToggleButton.Size = UDim2.new(1, opts.HasColorPicker and -28 or 0, 1, 0)
                        ToggleButton.Text = ""
                        ToggleButton.AutoButtonColor = false
                    
                        ToggleIndicator.Parent = ToggleFrame
                        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        ToggleIndicator.BorderSizePixel = 0
                        ToggleIndicator.Position = UDim2.new(0, 0, 0.5, -8)
                        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                        local TICorner = Instance.new("UICorner")
                        TICorner.CornerRadius = UDim.new(0, 4)
                        TICorner.Parent = ToggleIndicator
                        local TIStroke = Instance.new("UIStroke")
                        TIStroke.Color = Color3.fromRGB(60, 60, 60)
                        TIStroke.Thickness = 1.5
                        TIStroke.Parent = ToggleIndicator
                        
                        ToggleCheckmark.Parent = ToggleIndicator
                        ToggleCheckmark.BackgroundTransparency = 1
                        ToggleCheckmark.Size = UDim2.new(1, 0, 1, 0)
                        ToggleCheckmark.Font = Enum.Font.GothamBold
                        ToggleCheckmark.Text = "✓"
                        ToggleCheckmark.TextColor3 = Color3.new(1, 1, 1)
                        ToggleCheckmark.TextSize = 12
                        ToggleCheckmark.TextTransparency = 1
                    
                        ToggleText.Parent = ToggleFrame
                        ToggleText.BackgroundTransparency = 1
                        ToggleText.Position = UDim2.new(0, 24, 0, 0)
                        ToggleText.Size = UDim2.new(1, opts.HasColorPicker and -52 or -24, 1, 0)
                        ToggleText.Font = Enum.Font.Gotham
                        ToggleText.Text = opts.Text or id
                        ToggleText.TextColor3 = opts.TextColor
                        ToggleText.TextSize = 12
                        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                    
                        local toggled = opts.Default or false
                        local function updateToggle()
                            if toggled then
                                smoothTween(ToggleIndicator, {BackgroundColor3 = opts.DefaultColor})
                                smoothTween(TIStroke, {Color = opts.DefaultColor})
                                smoothTween(ToggleCheckmark, {TextTransparency = 0})
                            else
                                smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                                smoothTween(TIStroke, {Color = Color3.fromRGB(60, 60, 60)})
                                smoothTween(ToggleCheckmark, {TextTransparency = 1})
                            end
                            if opts.Callback then opts.Callback(toggled) end
                        end
                        
                        ToggleButton.MouseEnter:Connect(function()
                            if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end
                        end)
                        ToggleButton.MouseLeave:Connect(function()
                            if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}) end
                        end)
                        ToggleButton.MouseButton1Click:Connect(function() toggled = not toggled; updateToggle() end)
                    
                        local colorPicker = nil
                        local extraColorPickers = {}
                        local nextIconOffset = -28

                        if opts.HasColorPicker then
                            colorPicker = createColorPickerIcon(ToggleFrame, nextIconOffset, opts.DefaultColor or Window.DefaultColor, opts.ColorCallback, player, id, themeCallbacks)
                            nextIconOffset = nextIconOffset - 24
                        end
                        updateToggle()

                        if not opts.DefaultColor then
                            table.insert(themeCallbacks, function(c)
                                if not ToggleFrame.Parent then return end
                                opts.DefaultColor = c
                                if toggled then
                                    ToggleIndicator.BackgroundColor3 = c
                                    TIStroke.Color = c
                                end
                            end)
                        end
                        
                        local element = {
                            Type = "Toggle", Frame = ToggleFrame,
                            SetValue = function(value) toggled = value; updateToggle() end,
                            GetValue = function() return toggled end,
                            ColorPicker = colorPicker, ExtraColorPickers = extraColorPickers,
                            AddColorPickerIcon = function(_, pickerId, pickerOptions)
                                pickerOptions = pickerOptions or {}
                                local picker = createColorPickerIcon(ToggleFrame, nextIconOffset, pickerOptions.Default or Window.DefaultColor, pickerOptions.Callback, player, id .. "_" .. (pickerId or tostring(#extraColorPickers + 1)), themeCallbacks)
                                nextIconOffset = nextIconOffset - 34
                                table.insert(extraColorPickers, picker)
                                return picker
                            end,
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddSlider = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local SliderFrame = Instance.new("Frame")
                        local SliderText = Instance.new("TextLabel")
                        local SliderBackground = Instance.new("Frame")
                        local SliderFill = Instance.new("Frame")
                        local SliderButton = Instance.new("TextButton")
                        local ValueLabel = Instance.new("TextLabel")

                        SliderFrame.Name = id .. "Slider"
                        SliderFrame.Parent = GroupboxContent
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Size = UDim2.new(1.3, 0, 0, 40)
                        SliderFrame.LayoutOrder = #self.Elements + 1

                        SliderText.Parent = SliderFrame
                        SliderText.BackgroundTransparency = 1
                        SliderText.Size = UDim2.new(1, -50, 0, 20)
                        SliderText.Font = Enum.Font.Gotham
                        SliderText.Text = opts.Text or id
                        SliderText.TextColor3 = opts.TextColor
                        SliderText.TextSize = 12
                        SliderText.TextXAlignment = Enum.TextXAlignment.Left

                        SliderBackground.Parent = SliderFrame
                        SliderBackground.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                        SliderBackground.BorderSizePixel = 0
                        SliderBackground.Position = UDim2.new(0, 0, 0, 24)
                        SliderBackground.Size = UDim2.new(1, -50, 0, 8)
                        local SBCorner = Instance.new("UICorner")
                        SBCorner.CornerRadius = UDim.new(1, 0)
                        SBCorner.Parent = SliderBackground

                        SliderFill.Parent = SliderBackground
                        SliderFill.BackgroundColor3 = opts.DefaultColor
                        SliderFill.BorderSizePixel = 0
                        local SFCorner = Instance.new("UICorner")
                        SFCorner.CornerRadius = UDim.new(1, 0)
                        SFCorner.Parent = SliderFill

                        SliderButton.Parent = SliderBackground
                        SliderButton.BackgroundTransparency = 1
                        SliderButton.Size = UDim2.new(1, 0, 1, 0)
                        SliderButton.Text = ""
                        SliderButton.AutoButtonColor = false

                        ValueLabel.Parent = SliderFrame
                        ValueLabel.BackgroundTransparency = 1
                        ValueLabel.Position = UDim2.new(1, -55, 0, 0)
                        ValueLabel.Size = UDim2.new(0, 44, 0, 20)
                        ValueLabel.Font = Enum.Font.GothamBold
                        ValueLabel.Text = tostring(opts.Default or opts.Min or 0)
                        ValueLabel.TextColor3 = opts.DefaultColor
                        ValueLabel.TextSize = 11
                        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

                        local min = opts.Min or 0
                        local max = opts.Max or 100
                        local rounding = opts.Rounding or 1
                        local value = opts.Default or min
                        local dragging = false

                        local function updateSlider(input)
                            local sizeX = math.max(0, math.min(1, (input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X))
                            value = min + (max - min) * sizeX
                            if rounding == 1 then value = math.floor(value)
                            elseif rounding == 2 then value = math.floor(value * 10) / 10
                            elseif rounding == 3 then value = math.floor(value * 100) / 100 end

                            smoothTween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.1)
                            ValueLabel.Text = tostring(value)
                            if opts.Callback then opts.Callback(value) end
                        end

                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateSlider(input) end
                        end)
                        SliderButton.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                        end)

                        -- FIX: Store slider connection to prevent memory leaks
                        local sliderConn = UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
                        end)
                        table.insert(connections, sliderConn)

                        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        
                        if not opts.DefaultColor then
                            table.insert(themeCallbacks, function(c)
                                if not SliderFrame.Parent then return end
                                opts.DefaultColor = c
                                SliderFill.BackgroundColor3 = c
                                ValueLabel.TextColor3 = c
                            end)
                        end

                        local element = {
                            Type = "Slider", Frame = SliderFrame,
                            SetValue = function(newValue)
                                value = math.max(min, math.min(max, newValue))
                                smoothTween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.15)
                                ValueLabel.Text = tostring(value)
                            end,
                            GetValue = function() return value end
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddDropdown = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        opts.Values = opts.Values or {}

                        local DropdownFrame = Instance.new("Frame")
                        local DropdownText = Instance.new("TextLabel")
                        local DropdownButton = Instance.new("TextButton")
                        local DropdownArrow = Instance.new("TextLabel")
                        local DropdownList = Instance.new("ScrollingFrame")

                        DropdownFrame.Name = id .. "Dropdown"
                        DropdownFrame.Parent = GroupboxContent
                        DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 44)
                        DropdownFrame.LayoutOrder = #self.Elements + 1
                        DropdownFrame.ZIndex = 2

                        DropdownText.Parent = DropdownFrame
                        DropdownText.BackgroundTransparency = 1
                        DropdownText.Size = UDim2.new(1, 0, 0, 20)
                        DropdownText.Font = Enum.Font.Gotham
                        DropdownText.Text = opts.Text or id
                        DropdownText.TextColor3 = opts.TextColor
                        DropdownText.TextSize = 12
                        DropdownText.TextXAlignment = Enum.TextXAlignment.Left

                        DropdownButton.Parent = DropdownFrame
                        DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        DropdownButton.BorderSizePixel = 0
                        DropdownButton.Position = UDim2.new(0, 0, 0, 24)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 20)
                        DropdownButton.Font = Enum.Font.Gotham
                        DropdownButton.Text = "  " .. (opts.Default or opts.Values[1] or "Select...")
                        DropdownButton.TextColor3 = opts.TextColor
                        DropdownButton.TextSize = 11
                        DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                        DropdownButton.ZIndex = 2
                        DropdownButton.AutoButtonColor = false
                        local DBCorner = Instance.new("UICorner")
                        DBCorner.CornerRadius = UDim.new(0, 4)
                        DBCorner.Parent = DropdownButton

                        DropdownArrow.Parent = DropdownButton
                        DropdownArrow.BackgroundTransparency = 1
                        DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
                        DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                        DropdownArrow.Font = Enum.Font.GothamBold
                        DropdownArrow.Text = "▼"
                        DropdownArrow.TextColor3 = opts.DefaultColor
                        DropdownArrow.TextSize = 10
                        table.insert(themeCallbacks, function(c) if DropdownArrow.Parent then DropdownArrow.TextColor3 = c end end)

                        DropdownList.Parent = DropdownFrame
                        DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        DropdownList.BorderSizePixel = 0
                        DropdownList.Position = UDim2.new(0, 0, 0, 45)
                        DropdownList.Size = UDim2.new(1, 0, 0, 0)
                        DropdownList.Visible = false
                        DropdownList.ZIndex = 50
                        DropdownList.ClipsDescendants = true
                        DropdownList.ScrollBarThickness = 4
                        DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        DropdownList.ScrollingDirection = Enum.ScrollingDirection.Y
                        local DLCorner = Instance.new("UICorner")
                        DLCorner.CornerRadius = UDim.new(0, 4)
                        DLCorner.Parent = DropdownList
                        local DLLayout = Instance.new("UIListLayout")
                        DLLayout.Parent = DropdownList
                        DLLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        DLLayout.Padding = UDim.new(0, 2)
                        local DLPad = Instance.new("UIPadding")
                        DLPad.Parent = DropdownList
                        DLPad.PaddingTop = UDim.new(0, 4)
                        DLPad.PaddingBottom = UDim.new(0, 4)

                        local isOpen = false
                        local selectedValue = opts.Default or opts.Values[1] or ""
                        local function getOpenHeight() return math.min((#opts.Values * 22) + 8, (6 * 22) + 8) end

                        local function setOpen(open)
                            isOpen = open
                            if open then
                                local listH = getOpenHeight()
                                DropdownList.Visible = true
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, listH)}, 0.15)
                                smoothTween(DropdownArrow, {Rotation = 180}, 0.15)
                                smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 44 + listH + 2)}, 0.15)
                            else
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.15)
                                smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 44)}, 0.15)
                                task.wait(0.15)
                                DropdownList.Visible = false
                            end
                            self:UpdateSize()
                        end

                        for i, option in ipairs(opts.Values) do
                            local OptionButton = Instance.new("TextButton")
                            OptionButton.Parent = DropdownList
                            OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            OptionButton.BorderSizePixel = 0
                            OptionButton.Size = UDim2.new(1, 0, 0, 20)
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.Text = "  " .. option
                            OptionButton.TextColor3 = opts.TextColor
                            OptionButton.TextSize = 11
                            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                            OptionButton.ZIndex = 51
                            OptionButton.AutoButtonColor = false
                            local OBCorner = Instance.new("UICorner")
                            OBCorner.CornerRadius = UDim.new(0, 3)
                            OBCorner.Parent = OptionButton

                            OptionButton.MouseEnter:Connect(function() smoothTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end)
                            OptionButton.MouseLeave:Connect(function() smoothTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}) end)
                            OptionButton.MouseButton1Click:Connect(function()
                                selectedValue = option
                                DropdownButton.Text = "  " .. option
                                setOpen(false)
                                if opts.Callback then opts.Callback(option) end
                            end)
                        end

                        DropdownButton.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
                        DropdownButton.MouseEnter:Connect(function() smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}) end)
                        DropdownButton.MouseLeave:Connect(function() smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}) end)

                        local element = {
                            Type = "Dropdown", Frame = DropdownFrame,
                            SetValue = function(value) selectedValue = value; DropdownButton.Text = "  " .. value end,
                            GetValue = function() return selectedValue end,
                            Close = function() if isOpen then setOpen(false) end end,
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddButton = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local ButtonFrame = Instance.new("Frame")
                        local Button = Instance.new("TextButton")

                        ButtonFrame.Name = id .. "Button"
                        ButtonFrame.Parent = GroupboxContent
                        ButtonFrame.BackgroundTransparency = 1
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                        ButtonFrame.LayoutOrder = #self.Elements + 1

                        Button.Parent = ButtonFrame
                        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        Button.BorderSizePixel = 0
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.Font = Enum.Font.GothamSemibold
                        Button.Text = opts.Text or id
                        Button.TextColor3 = opts.TextColor
                        Button.TextSize = 12
                        Button.AutoButtonColor = false
                        local BCorner = Instance.new("UICorner")
                        BCorner.CornerRadius = UDim.new(0, 5)
                        BCorner.Parent = Button
                        local BStroke = Instance.new("UIStroke")
                        BStroke.Color = Color3.fromRGB(60, 60, 60)
                        BStroke.Parent = Button

                        Button.MouseEnter:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
                            smoothTween(BStroke, {Color = opts.DefaultColor}, 0.2)
                        end)
                        Button.MouseLeave:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                            smoothTween(BStroke, {Color = Color3.fromRGB(60, 60, 60)}, 0.2)
                        end)
                        Button.MouseButton1Click:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}, 0.05)
                            task.wait(0.05)
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.1)
                            if opts.Callback then opts.Callback() end
                        end)

                        local element = { Type = "Button", Frame = ButtonFrame, Button = Button }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddLabel = function(self, text, opts)
                        opts = opts or {}
                        opts.TextColor = opts.TextColor or Window.TextColor
                        local LabelFrame = Instance.new("Frame")
                        local Label = Instance.new("TextLabel")

                        LabelFrame.Name = (text or "Label") .. "Label"
                        LabelFrame.Parent = GroupboxContent
                        LabelFrame.BackgroundTransparency = 1
                        LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                        LabelFrame.LayoutOrder = #self.Elements + 1

                        Label.Parent = LabelFrame
                        Label.BackgroundTransparency = 1
                        Label.Size = UDim2.new(1, 0, 1, 0)
                        Label.Font = Enum.Font.Gotham
                        Label.Text = text or "Label"
                        Label.TextColor3 = opts.TextColor
                        Label.TextSize = 12
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local element = {
                            Type = "Label", Frame = LabelFrame, Label = Label,
                            SetText = function(newText) Label.Text = newText end,
                            AddColorPicker = function(elementSelf, id, pickerOptions)
                                pickerOptions = pickerOptions or {}
                                local default = pickerOptions.Default or pickerOptions.DefaultColor or Window.DefaultColor
                                Label.Size = UDim2.new(1, -28, 1, 0)
                                local picker = createColorPickerIcon(LabelFrame, 0, default, pickerOptions.Callback or pickerOptions.ColorCallback, player, id or "Label", themeCallbacks)
                                element.ColorPicker = picker
                                return picker
                            end
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    -- Added missing Standalone ColorPicker method
                    AddColorPicker = function(self, id, opts)
                        opts = opts or {}
                        local default = opts.Default or opts.DefaultColor or Window.DefaultColor
                        local CPF = Instance.new("Frame")
                        CPF.Name = id.."CP"
                        CPF.Parent = GroupboxContent
                        CPF.BackgroundTransparency = 1
                        CPF.Size = UDim2.new(1, 0, 0, 20)
                        CPF.LayoutOrder = #self.Elements + 1

                        local Label = Instance.new("TextLabel")
                        Label.Parent = CPF
                        Label.BackgroundTransparency = 1
                        Label.Size = UDim2.new(1, -28, 1, 0)
                        Label.Font = Enum.Font.Gotham
                        Label.Text = opts.Text or id
                        Label.TextColor3 = opts.TextColor or Window.TextColor
                        Label.TextSize = 12
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local picker = createColorPickerIcon(CPF, 0, default, opts.Callback, player, id, themeCallbacks)
                        
                        local element = {
                            Type = "ColorPicker", Frame = CPF,
                            SetColor = picker.SetColor, GetColor = picker.GetColor,
                            ColorPicker = picker
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddTextBox = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local TextBoxFrame = Instance.new("Frame")
                        local TextBox = Instance.new("TextBox")

                        TextBoxFrame.Name = id .. "TextBox"
                        TextBoxFrame.Parent = GroupboxContent
                        TextBoxFrame.BackgroundTransparency = 1
                        TextBoxFrame.Size = UDim2.new(1, 0, 0, 28)
                        TextBoxFrame.LayoutOrder = #self.Elements + 1

                        TextBox.Parent = TextBoxFrame
                        TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        TextBox.BorderSizePixel = 0
                        TextBox.Size = UDim2.new(1, 0, 1, 0)
                        TextBox.Font = Enum.Font.Gotham
                        TextBox.PlaceholderText = opts.Placeholder or "Enter text..."
                        TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                        TextBox.Text = opts.Default or ""
                        TextBox.TextColor3 = opts.TextColor
                        TextBox.TextSize = 11
                        TextBox.ClearTextOnFocus = opts.ClearOnFocus or false
                        local TBCorner = Instance.new("UICorner")
                        TBCorner.CornerRadius = UDim.new(0, 5)
                        TBCorner.Parent = TextBox
                        local TBStroke = Instance.new("UIStroke")
                        TBStroke.Color = Color3.fromRGB(55, 55, 55)
                        TBStroke.Parent = TextBox
                        local TBPad = Instance.new("UIPadding")
                        TBPad.Parent = TextBox
                        TBPad.PaddingLeft = UDim.new(0, 8)
                        TBPad.PaddingRight = UDim.new(0, 8)
                        
                        TextBox.Focused:Connect(function() smoothTween(TBStroke, {Color = opts.DefaultColor, Thickness = 1.5}, 0.15) end)
                        TextBox.FocusLost:Connect(function()
                            smoothTween(TBStroke, {Color = Color3.fromRGB(55, 55, 55), Thickness = 1}, 0.15)
                            if opts.Callback then opts.Callback(TextBox.Text) end
                        end)

                        local element = {
                            Type = "TextBox", Frame = TextBoxFrame,
                            SetText = function(text) TextBox.Text = text end,
                            GetText = function() return TextBox.Text end
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddKeyPicker = function(self, id, opts)
                        opts = opts or {}
                        opts.DefaultColor = opts.DefaultColor or Window.DefaultColor
                        opts.TextColor = opts.TextColor or Window.TextColor

                        local keyNames = {
                            [Enum.KeyCode.LeftAlt]="L-Alt", [Enum.KeyCode.RightAlt]="R-Alt",
                            [Enum.KeyCode.LeftControl]="L-Ctrl", [Enum.KeyCode.RightControl]="R-Ctrl",
                            [Enum.KeyCode.LeftShift]="L-Shift", [Enum.KeyCode.RightShift]="R-Shift",
                            [Enum.KeyCode.Tab]="Tab", [Enum.KeyCode.CapsLock]="Caps",
                            [Enum.KeyCode.Backspace]="Bksp", [Enum.KeyCode.Return]="Enter",
                            [Enum.KeyCode.Space]="Space", [Enum.KeyCode.Delete]="Del",
                            [Enum.KeyCode.Insert]="Ins", [Enum.KeyCode.Home]="Home", [Enum.KeyCode.End]="End",
                            [Enum.KeyCode.PageUp]="PgUp", [Enum.KeyCode.PageDown]="PgDn",
                            [Enum.KeyCode.F1]="F1",[Enum.KeyCode.F2]="F2",[Enum.KeyCode.F3]="F3",
                            [Enum.KeyCode.F4]="F4",[Enum.KeyCode.F5]="F5",[Enum.KeyCode.F6]="F6",
                            [Enum.KeyCode.F7]="F7",[Enum.KeyCode.F8]="F8",[Enum.KeyCode.F9]="F9",
                            [Enum.KeyCode.F10]="F10",[Enum.KeyCode.F11]="F11",[Enum.KeyCode.F12]="F12",
                        }
                        local function getKeyName(keyCode) return keyNames[keyCode] or tostring(keyCode):match("KeyCode%.(.+)") or "?" end

                        local currentKey = opts.Default or Enum.KeyCode.RightShift
                        local listening = false
                        local inputConn = nil
                        local keyDownConn = nil
                        local keyUpConn = nil

                        local KeyPickerFrame = Instance.new("Frame")
                        local KeyPickerText = Instance.new("TextLabel")
                        local KeyPickerBtn = Instance.new("TextButton")
                        local KeyLabel = Instance.new("TextLabel")

                        KeyPickerFrame.Name = id .. "KeyPicker"
                        KeyPickerFrame.Parent = GroupboxContent
                        KeyPickerFrame.BackgroundTransparency = 1
                        KeyPickerFrame.Size = UDim2.new(1, 0, 0, 38)
                        KeyPickerFrame.LayoutOrder = #self.Elements + 1

                        KeyPickerText.Parent = KeyPickerFrame
                        KeyPickerText.BackgroundTransparency = 1
                        KeyPickerText.Size = UDim2.new(1, -70, 0, 18)
                        KeyPickerText.Font = Enum.Font.Gotham
                        KeyPickerText.Text = opts.Text or id
                        KeyPickerText.TextColor3 = opts.TextColor
                        KeyPickerText.TextSize = 12
                        KeyPickerText.TextXAlignment = Enum.TextXAlignment.Left

                        KeyPickerBtn.Parent = KeyPickerFrame
                        KeyPickerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        KeyPickerBtn.BorderSizePixel = 0
                        KeyPickerBtn.AnchorPoint = Vector2.new(1, 0)
                        KeyPickerBtn.Position = UDim2.new(1, 0, 0, 0)
                        KeyPickerBtn.Size = UDim2.new(0, 64, 0, 18)
                        KeyPickerBtn.Text = ""
                        KeyPickerBtn.AutoButtonColor = false
                        local KBCorner = Instance.new("UICorner")
                        KBCorner.CornerRadius = UDim.new(0, 4)
                        KBCorner.Parent = KeyPickerBtn
                        local KBStroke = Instance.new("UIStroke")
                        KBStroke.Color = Color3.fromRGB(55, 55, 55)
                        KBStroke.Parent = KeyPickerBtn

                        KeyLabel.Parent = KeyPickerBtn
                        KeyLabel.BackgroundTransparency = 1
                        KeyLabel.Size = UDim2.new(1, 0, 1, 0)
                        KeyLabel.Font = Enum.Font.GothamBold
                        KeyLabel.Text = "[" .. getKeyName(currentKey) .. "]"
                        KeyLabel.TextColor3 = opts.DefaultColor
                        KeyLabel.TextSize = 11
                        table.insert(themeCallbacks, function(c) if KeyLabel.Parent then KeyLabel.TextColor3 = c end end)

                        local ModeLabel = Instance.new("TextLabel")
                        ModeLabel.Parent = KeyPickerFrame
                        ModeLabel.BackgroundTransparency = 1
                        ModeLabel.Position = UDim2.new(0, 0, 0, 20)
                        ModeLabel.Size = UDim2.new(1, 0, 0, 14)
                        ModeLabel.Font = Enum.Font.Gotham
                        ModeLabel.TextSize = 10
                        ModeLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local modes = {"Hold", "Toggle", "Always"}
                        local modeIndex = 1
                        for i, m in ipairs(modes) do if m == opts.Mode then modeIndex = i break end end
                        local currentMode = modes[modeIndex]
                        local isActive = false

                        local function updateModeLabel()
                            ModeLabel.Text = "Mode: " .. currentMode
                            ModeLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
                        end
                        updateModeLabel()

                        local bindKeyActions
                        local function stopListening()
                            if inputConn then inputConn:Disconnect() inputConn = nil end
                            listening = false
                            KeyLabel.Text = "[" .. getKeyName(currentKey) .. "]"
                            KeyLabel.TextColor3 = opts.DefaultColor
                            smoothTween(KBStroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.15)
                        end
                        local function startListening()
                            listening = true
                            KeyLabel.Text = "..."
                            KeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                            smoothTween(KBStroke, {Color = opts.DefaultColor}, 0.15)
                            inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                                if gameProcessed then return end
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    if input.KeyCode == Enum.KeyCode.Escape then stopListening(); return end
                                    currentKey = input.KeyCode
                                    stopListening()
                                    if keyDownConn then keyDownConn:Disconnect() end
                                    if keyUpConn then keyUpConn:Disconnect() end
                                    bindKeyActions()
                                end
                            end)
                        end

                        bindKeyActions = function()
                            if currentMode == "Always" then isActive = true; if opts.Callback then opts.Callback(true) end return end
                            keyDownConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                                if gameProcessed then return end
                                if input.KeyCode == currentKey then
                                    if currentMode == "Hold" then isActive = true; if opts.Callback then opts.Callback(true) end
                                    elseif currentMode == "Toggle" then isActive = not isActive; if opts.Callback then opts.Callback(isActive) end end
                                end
                            end)
                            if currentMode == "Hold" then
                                keyUpConn = UserInputService.InputEnded:Connect(function(input)
                                    if input.KeyCode == currentKey then isActive = false; if opts.Callback then opts.Callback(false) end end
                                end)
                            end
                        end
                        bindKeyActions()

                        KeyPickerBtn.MouseButton1Click:Connect(function() if listening then stopListening() else startListening() end end)
                        KeyPickerBtn.MouseButton2Click:Connect(function()
                            modeIndex = (modeIndex % #modes) + 1
                            currentMode = modes[modeIndex]
                            updateModeLabel()
                            if keyDownConn then keyDownConn:Disconnect() end
                            if keyUpConn then keyUpConn:Disconnect() end
                            isActive = false
                            bindKeyActions()
                        end)

                        local element = {
                            Type = "KeyPicker", Frame = KeyPickerFrame,
                            GetValue = function() return currentKey end, IsActive = function() return isActive end,
                            GetMode = function() return currentMode end,
                            SetKey = function(keyCode)
                                currentKey = keyCode
                                KeyLabel.Text = "[" .. getKeyName(keyCode) .. "]"
                                if keyDownConn then keyDownConn:Disconnect() end
                                if keyUpConn then keyUpConn:Disconnect() end
                                bindKeyActions()
                            end,
                            SetMode = function(mode)
                                for i, m in ipairs(modes) do if m == mode then modeIndex = i break end end
                                currentMode = modes[modeIndex]
                                updateModeLabel()
                                if keyDownConn then keyDownConn:Disconnect() end
                                if keyUpConn then keyUpConn:Disconnect() end
                                isActive = false
                                bindKeyActions()
                            end,
                        }
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    UpdateSize = function(self)
                        local leftHeight = LeftLayout.AbsoluteContentSize.Y + 30
                        local rightHeight = RightLayout.AbsoluteContentSize.Y + 30
                        TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftHeight, rightHeight))
                    end
                }
                table.insert(self.Groupboxes, groupbox)
                return groupbox
            end
        }

        TabButton.MouseButton1Click:Connect(function()
            for _, tabData in pairs(tabs) do
                tabData.Content.Visible = false
                tabData.Highlight.Visible = false
                smoothTween(tabData.Button, {TextTransparency = 0.5, BackgroundTransparency = 1})
            end
            TabContent.Visible = true
            TabHighlight.Visible = true
            smoothTween(TabButton, {TextTransparency = 0, BackgroundTransparency = 0}, 0.2)
            currentTab = tab
            Window.ActiveTab = tab
        end)
        
        TabButton.MouseEnter:Connect(function() if currentTab ~= tab then smoothTween(TabButton, {BackgroundTransparency = 0.95}) end end)
        TabButton.MouseLeave:Connect(function() if currentTab ~= tab then smoothTween(TabButton, {BackgroundTransparency = 1}) end end)

        tabs[name] = tab
        if not currentTab then
            TabContent.Visible = true
            TabHighlight.Visible = true
            TabButton.TextTransparency = 0
            TabButton.BackgroundTransparency = 0
            currentTab = tab
            Window.ActiveTab = tab
        end
        return tab
    end

    -- Cleanup ALL memory leaks on destroy
    function Window:Destroy()
        for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
        ScreenGui:Destroy()
    end

    function Window:ToggleVisibility() ScreenGui.Enabled = not ScreenGui.Enabled end
    function Window:SetPosition(position) smoothTween(MainBackGround, {Position = position}, 0.3) end
    function Window:GetPosition() return MainBackGround.Position end
    function Window:SetSize(size)
        smoothTween(MainBackGround, {Size = size}, 0.3)
        TabHolder.Size = UDim2.new(0, 130, 1, 0)
        ContentFrame.Size = UDim2.new(1, -148, 1, -20)
    end
    function Window:GetSize() return MainBackGround.Size end

    -- NEW: Dynamic Theme Color Changing System
    function Window:SetThemeColor(color)
        Window.DefaultColor = color
        for _, cb in ipairs(themeCallbacks) do
            task.spawn(cb, color)
        end
    end

    local dragToggle = false
    local dragSpeed = 0.15
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        smoothTween(MainBackGround, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, dragSpeed)
    end

    local DragHandle = Instance.new("Frame")
    DragHandle.Name = "DragHandle"
    DragHandle.Parent = MainBackGround
    DragHandle.BackgroundTransparency = 1
    DragHandle.Size = UDim2.new(0, 130, 1, 0)
    DragHandle.ZIndex = 0

    DragHandle.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = MainBackGround.Position
        end
    end)

    -- FIX: Only use ONE InputEnded connection for dragging instead of creating a new one per click
    local dragEndConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
    table.insert(connections, dragEndConn)

    local dragMoveConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then updateInput(input) end
        end
    end)
    table.insert(connections, dragMoveConn)

    return Window
end

return UILibrary
