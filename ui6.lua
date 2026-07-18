
local UILibrary = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Smooth tween function with modern easing
local function smoothTween(instance, properties, duration, easingStyle)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Safe GUI parenting fallback
local function safeParentGui(gui, player)
    local ok = pcall(function()
        local cg = game:GetService("CoreGui")
        gui.Parent = cg
    end)
    if not ok or not gui.Parent then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end

-- Floating HSV Color Picker Factory (Using Native Roblox HSV for 1:1 accuracy)
local function createColorPickerIcon(iconParent, iconOffset, defaultColor, callback, player, windowName)
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
    colorCorner.CornerRadius = UDim.new(1, 0)
    colorCorner.Parent = ColorIcon

    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = Color3.fromRGB(60, 60, 60)
    colorStroke.Thickness = 1.5
    colorStroke.Parent = ColorIcon

    ColorIcon.MouseEnter:Connect(function()
        smoothTween(colorStroke, {Thickness = 2}, 0.15)
        smoothTween(ColorIcon, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
    end)
    ColorIcon.MouseLeave:Connect(function()
        smoothTween(colorStroke, {Thickness = 1.5}, 0.15)
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
    colorPickerWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    colorPickerWindow.BorderSizePixel = 0
    colorPickerWindow.Position = UDim2.new(0.5, -125, 0.5, -100)
    colorPickerWindow.Size = UDim2.new(0, 250, 0, 200)
    colorPickerWindow.Visible = false
    colorPickerWindow.ZIndex = 100
    colorPickerWindow.ClipsDescendants = true

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 6)
    windowCorner.Parent = colorPickerWindow

    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = Color3.fromRGB(15, 15, 15)
    windowStroke.Thickness = 1.5
    windowStroke.Parent = colorPickerWindow

    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 2)
    titleFrame.Parent = colorPickerWindow
    titleFrame.BackgroundColor3 = defaultColor
    titleFrame.BorderSizePixel = 0

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
    saturationValueBox.Position = UDim2.new(0, 0, 0, 0)
    saturationValueBox.Size = UDim2.new(0, 180, 0, 150)
    saturationValueBox.ZIndex = 101

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = saturationValueBox

    local svOverlay = Instance.new("Frame")
    svOverlay.Name = "SVOverlay"
    svOverlay.Parent = saturationValueBox
    svOverlay.BackgroundTransparency = 0
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
    svOverlay2.Name = "SVOverlay2"
    svOverlay2.Parent = saturationValueBox
    svOverlay2.BackgroundTransparency = 0
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
    saturationValueButton.Name = "SaturationValueButton"
    saturationValueButton.Parent = saturationValueBox
    saturationValueButton.BackgroundColor3 = Color3.new(1, 1, 1)
    saturationValueButton.BorderSizePixel = 0
    saturationValueButton.Position = UDim2.new(0.5, -5, 0.5, -5)
    saturationValueButton.Size = UDim2.new(0, 10, 0, 10)
    saturationValueButton.Text = ""
    saturationValueButton.ZIndex = 104
    saturationValueButton.AutoButtonColor = false

    local svButtonCorner = Instance.new("UICorner")
    svButtonCorner.CornerRadius = UDim.new(1, 0)
    svButtonCorner.Parent = saturationValueButton

    local svButtonStroke = Instance.new("UIStroke")
    svButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    svButtonStroke.Thickness = 2
    svButtonStroke.Parent = saturationValueButton

    local hueSlider = Instance.new("Frame")
    hueSlider.Name = "HueSlider"
    hueSlider.Parent = colorPickerFrame
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel = 0
    hueSlider.Position = UDim2.new(0, 195, 0, 0)
    hueSlider.Size = UDim2.new(0, 25, 0, 150)
    hueSlider.ZIndex = 101

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
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
    hueSliderButton.Name = "HueSliderButton"
    hueSliderButton.Parent = hueSlider
    hueSliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSliderButton.BorderSizePixel = 0
    hueSliderButton.Position = UDim2.new(0, -3, 0, 0)
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
    local hue, saturation, value = Color3.toHSV(currentColor)
    local updating = false

    local function updateColor()
        if updating then return end
        updating = true

        currentColor = Color3.fromHSV(hue, saturation, value)
        saturationValueBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

        local hueY = math.clamp(hue * 144, 0, 144)
        local satX = math.clamp(saturation * 170, 0, 170)
        local valY = math.clamp((1 - value) * 140, 0, 140)

        smoothTween(hueSliderButton, {Position = UDim2.new(0, -3, 0, hueY)}, 0.1)
        smoothTween(saturationValueButton, {Position = UDim2.new(0, satX - 5, 0, valY - 5)}, 0.1)
        smoothTween(ColorIcon, {BackgroundColor3 = currentColor}, 0.15)
        smoothTween(titleFrame, {BackgroundColor3 = currentColor}, 0.15)

        updating = false

        if callback then callback(currentColor) end
    end

    local function updateFromRGB(color)
        if updating then return end
        hue, saturation, value = Color3.toHSV(color)
        updateColor()
    end

    local hueDragging = false
    local svDragging = false
    local dragConn, releaseConn

    local function endDrag()
        if dragConn then dragConn:Disconnect() dragConn = nil end
        if releaseConn then releaseConn:Disconnect() releaseConn = nil end
        hueDragging = false; svDragging = false
    end

    local function startDrag(mode)
        endDrag()
        if mode == "hue" then hueDragging = true else svDragging = true end

        dragConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if hueDragging then
                    local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 144)
                    hue = yPos / 144; updateColor()
                elseif svDragging then
                    local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 170)
                    local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 140)
                    saturation = xPos / 170; value = 1 - (yPos / 140); updateColor()
                end
            end
        end)

        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then endDrag() end
        end)
    end

    hueSliderButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag("hue") end end)
    saturationValueButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag("sv") end end)
    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 170)
            local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 140)
            saturation = xPos / 170; value = 1 - (yPos / 140); updateColor(); startDrag("sv")
        end
    end)
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 144)
            hue = yPos / 144; updateColor(); startDrag("hue")
        end
    end)

    if defaultColor then updateFromRGB(defaultColor) else updateColor() end

    ColorIcon.MouseButton1Click:Connect(function() colorPickerWindow.Visible = not colorPickerWindow.Visible end)

    local clickOutsideConnection
    clickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorPickerWindow.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local windowPos = colorPickerWindow.AbsolutePosition
            local windowSize = colorPickerWindow.AbsoluteSize
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            mousePos = Vector2.new(mousePos.X, mousePos.Y - guiInset.Y)
            local ip = ColorIcon.AbsolutePosition; local is = ColorIcon.AbsoluteSize
            local onIcon = mousePos.X >= ip.X and mousePos.X <= ip.X + is.X and mousePos.Y >= ip.Y and mousePos.Y <= ip.Y + is.Y

            if not onIcon and (mousePos.X < windowPos.X or mousePos.X > windowPos.X + windowSize.X or
               mousePos.Y < windowPos.Y or mousePos.Y > windowPos.Y + windowSize.Y) then
                colorPickerWindow.Visible = false
            end
        end
    end)

    return {
        Icon = ColorIcon, ScreenGui = colorPickerScreenGui, Window = colorPickerWindow,
        SetColor = function(color) updateFromRGB(color) end,
        GetColor = function() return currentColor end,
        Show = function() colorPickerWindow.Visible = true end,
        Hide = function() colorPickerWindow.Visible = false end,
        Destroy = function()
            endDrag()
            if clickOutsideConnection then clickOutsideConnection:Disconnect(); clickOutsideConnection = nil end
            colorPickerScreenGui:Destroy(); ColorIcon:Destroy()
        end
    }
end

-- Main UI creation function
function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer

    local libraryConnections = {}
    local function trackConnection(conn) table.insert(libraryConnections, conn); return conn end

    local defaultOptions = {
        Name = "UI Library", ToggleKey = Enum.KeyCode.RightShift, CloseKey = Enum.KeyCode.X,
        DefaultColor = Color3.fromRGB(140, 90, 255), -- Sleek purple accent
        TextColor = Color3.fromRGB(210, 210, 215),
        BackgroundColor = Color3.fromRGB(20, 20, 22),
        TabHolderColor = Color3.fromRGB(15, 15, 18),
        GroupboxColor = Color3.fromRGB(25, 25, 30),
        Size = UDim2.new(0, 580, 0, 480),
        Position = UDim2.new(0.226, 0, 0.146, 0),
        Theme = "Dark", Watermark = true, WatermarkText = ""
    }
    
    for option, value in pairs(defaultOptions) do if options[option] == nil then options[option] = value end end

    local ScreenGui = Instance.new("ScreenGui")
    local MainBackGround = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local MainStroke = Instance.new("UIStroke")
    local TabHolder = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    local ContentFrame = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")

    ScreenGui.Name = options.Name; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = false; ScreenGui.DisplayOrder = 10000
    safeParentGui(ScreenGui, player)

    MainBackGround.Name = "MainBackGround"; MainBackGround.Parent = ScreenGui
    MainBackGround.BackgroundColor3 = options.BackgroundColor; MainBackGround.BorderSizePixel = 0
    MainBackGround.Position = options.Position; MainBackGround.Size = options.Size
    MainBackGround.ClipsDescendants = true
    
    UICorner.CornerRadius = UDim.new(0, 8); UICorner.Parent = MainBackGround
    MainStroke.Color = Color3.fromRGB(40, 40, 45); MainStroke.Thickness = 1; MainStroke.Parent = MainBackGround

    TabHolder.Name = "TabHolder"; TabHolder.Parent = MainBackGround; TabHolder.BackgroundColor3 = options.TabHolderColor
    TabHolder.BorderSizePixel = 0; TabHolder.Position = UDim2.new(0, 0, 0, 0); TabHolder.Size = UDim2.new(0, 130, 0, options.Size.Y.Offset)
    UICorner_2.CornerRadius = UDim.new(0, 8); UICorner_2.Parent = TabHolder

    local TabListLayout = Instance.new("UIListLayout"); TabListLayout.Parent = TabHolder; TabListLayout.FillDirection = Enum.FillDirection.Vertical; TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabListLayout.Padding = UDim.new(0, 4)
    local TabPadding = Instance.new("UIPadding"); TabPadding.Parent = TabHolder; TabPadding.PaddingTop = UDim.new(0, 8); TabPadding.PaddingLeft = UDim.new(0, 8); TabPadding.PaddingRight = UDim.new(0, 8)

    ContentFrame.Name = "ContentFrame"; ContentFrame.Parent = MainBackGround; ContentFrame.BackgroundColor3 = options.BackgroundColor
    ContentFrame.BorderSizePixel = 0; ContentFrame.Position = UDim2.new(0, 138, 0, 10); ContentFrame.Size = UDim2.new(0, options.Size.X.Offset - 148, 0, options.Size.Y.Offset - 20)
    ContentFrame.ClipsDescendants = true; UICorner_3.CornerRadius = UDim.new(0, 6); UICorner_3.Parent = ContentFrame

    if options.Watermark then
        local Watermark = Instance.new("TextLabel"); Watermark.Name = "Watermark"; Watermark.Parent = ScreenGui; Watermark.BackgroundTransparency = 1
        Watermark.Position = UDim2.new(0, 10, 0, 10); Watermark.Size = UDim2.new(0, 200, 0, 20); Watermark.Font = Enum.Font.GothamBold
        Watermark.Text = options.WatermarkText; Watermark.TextColor3 = options.DefaultColor; Watermark.TextSize = 13; Watermark.TextXAlignment = Enum.TextXAlignment.Left
    end

    local tabs = {}; local currentTab = nil

    local NotifyHolder = Instance.new("Frame"); NotifyHolder.Name = "NotifyHolder"; NotifyHolder.Parent = ScreenGui
    NotifyHolder.BackgroundTransparency = 1; NotifyHolder.Position = UDim2.new(1, -220, 0, 20); NotifyHolder.Size = UDim2.new(0, 200, 1, -40); NotifyHolder.ZIndex = 100
    local NotifyLayout = Instance.new("UIListLayout"); NotifyLayout.Parent = NotifyHolder; NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder; NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; NotifyLayout.Padding = UDim.new(0, 10)

    local Window = {}; Window.ActiveTab = nil; Window.Theme = options.Theme; Window.DefaultColor = options.DefaultColor; Window.TextColor = options.TextColor

    local function handleInput(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == options.ToggleKey then Window:ToggleVisibility() end
    end
    trackConnection(UserInputService.InputBegan:Connect(handleInput))

    function Window:Notify(text, style, duration)
        if typeof(style) == "number" and duration == nil then if style > 4 then duration = style; style = 1 end end
        style = style or 1; duration = duration or 3
        local notifyColor = Window.DefaultColor
        if style == 1 then notifyColor = Window.DefaultColor elseif style == 2 then notifyColor = Color3.fromRGB(235, 175, 75) elseif style == 3 then notifyColor = Color3.fromRGB(235, 85, 85) elseif style == 4 then notifyColor = Color3.fromRGB(85, 185, 235) elseif typeof(style) == "Color3" then notifyColor = style end

        local NotifyFrame = Instance.new("Frame"); NotifyFrame.Name = "NotifyFrame"; NotifyFrame.Parent = NotifyHolder; NotifyFrame.BackgroundTransparency = 1; NotifyFrame.Size = UDim2.new(1, 0, 0, 35)
        local NotifyText = Instance.new("TextLabel"); NotifyText.Parent = NotifyFrame; NotifyText.BackgroundTransparency = 1; NotifyText.Size = UDim2.new(1, 0, 1, -5); NotifyText.Font = Enum.Font.GothamBold; NotifyText.Text = text; NotifyText.TextColor3 = notifyColor; NotifyText.TextSize = 13; NotifyText.TextXAlignment = Enum.TextXAlignment.Center; NotifyText.TextTransparency = 1
        local NotifyLine = Instance.new("Frame"); NotifyLine.Parent = NotifyText; NotifyLine.BackgroundColor3 = notifyColor; NotifyLine.BorderSizePixel = 0; NotifyLine.Position = UDim2.new(0.25, 0, 1, 2); NotifyLine.Size = UDim2.new(0.5, 0, 0, 2); NotifyLine.BackgroundTransparency = 1
        local LineCorner = Instance.new("UICorner"); LineCorner.CornerRadius = UDim.new(1, 0); LineCorner.Parent = NotifyLine

        smoothTween(NotifyText, {TextTransparency = 0}, 0.3); smoothTween(NotifyLine, {BackgroundTransparency = 0}, 0.3)
        task.spawn(function()
            task.wait(duration)
            smoothTween(NotifyText, {TextTransparency = 1}, 0.3)
            local fadeOut = smoothTween(NotifyLine, {BackgroundTransparency = 1}, 0.3)
            fadeOut.Completed:Wait(); NotifyFrame:Destroy()
        end)
    end

    function Window:AddTab(name)
        local TabButton = Instance.new("TextButton"); local TabContent = Instance.new("ScrollingFrame")
        local TabHighlight = Instance.new("Frame"); local TabCorner = Instance.new("UICorner")
        local LeftContainer = Instance.new("Frame"); local LeftLayout = Instance.new("UIListLayout")
        local RightContainer = Instance.new("Frame"); local RightLayout = Instance.new("UIListLayout")

        TabButton.Name = name .. "Tab"; TabButton.Parent = TabHolder; TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        TabButton.BackgroundTransparency = 1; TabButton.BorderSizePixel = 0; TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.Font = Enum.Font.GothamSemibold; TabButton.Text = name; TabButton.TextColor3 = options.TextColor
        TabButton.TextTransparency = 0.6; TabButton.TextSize = 13; TabButton.TextXAlignment = Enum.TextXAlignment.Left; TabButton.AutoButtonColor = false
        TabCorner.CornerRadius = UDim.new(0, 6); TabCorner.Parent = TabButton
        local TabPad = Instance.new("UIPadding"); TabPad.Parent = TabButton; TabPad.PaddingLeft = UDim.new(0, 12)

        TabHighlight.Parent = TabButton; TabHighlight.BackgroundColor3 = options.DefaultColor; TabHighlight.BorderSizePixel = 0
        TabHighlight.Position = UDim2.new(0, -17, 0, 0); TabHighlight.Size = UDim2.new(0, 3, 1, 0); TabHighlight.ZIndex = 2; TabHighlight.Visible = false
        local HighlightCorner = Instance.new("UICorner"); HighlightCorner.CornerRadius = UDim.new(0, 6); HighlightCorner.Parent = TabHighlight

        TabContent.Name = name .. "Content"; TabContent.Parent = ContentFrame; TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0; TabContent.Size = UDim2.new(1, 0, 1, 0); TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4; TabContent.ScrollBarImageColor3 = options.DefaultColor; TabContent.Visible = false
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y; TabContent.ClipsDescendants = true
        TabContent.GroupTransparency = 1 -- For fade effect

        LeftContainer.Name = "LeftContainer"; LeftContainer.Parent = TabContent; LeftContainer.BackgroundTransparency = 1
        LeftContainer.Position = UDim2.new(0, 10, 0, 10); LeftContainer.Size = UDim2.new(0.5, -15, 0, 0); LeftContainer.AutomaticSize = Enum.AutomaticSize.Y
        LeftLayout.Parent = LeftContainer; LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder; LeftLayout.Padding = UDim.new(0, 12)

        RightContainer.Name = "RightContainer"; RightContainer.Parent = TabContent; RightContainer.BackgroundTransparency = 1
        RightContainer.Position = UDim2.new(0.5, 5, 0, 10); RightContainer.Size = UDim2.new(0.5, -15, 0, 0); RightContainer.AutomaticSize = Enum.AutomaticSize.Y
        RightLayout.Parent = RightContainer; RightLayout.SortOrder = Enum.SortOrder.LayoutOrder; RightLayout.Padding = UDim.new(0, 12)

        local function updateContentSize()
            local leftHeight = LeftLayout.AbsoluteContentSize.Y + 30; local rightHeight = RightLayout.AbsoluteContentSize.Y + 30
            TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftHeight, rightHeight))
        end
        trackConnection(LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize))
        trackConnection(RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize))

        local tab = {
            Button = TabButton, Content = TabContent, Highlight = TabHighlight,
            LeftContainer = LeftContainer, RightContainer = RightContainer, Groupboxes = {},
            AddLeftGroupbox = function(self, name) return self:CreateGroupbox(name, "Left") end,
            AddRightGroupbox = function(self, name) return self:CreateGroupbox(name, "Right") end,
            CreateGroupbox = function(self, name, side)
                local GroupboxFrame = Instance.new("Frame"); local GroupboxCorner = Instance.new("UICorner")
                local GroupboxStroke = Instance.new("UIStroke"); local GroupboxTitle = Instance.new("TextLabel")
                local GroupboxContent = Instance.new("Frame"); local GroupboxLayout = Instance.new("UIListLayout")

                GroupboxFrame.Name = name .. "Groupbox"; GroupboxFrame.BackgroundColor3 = options.GroupboxColor; GroupboxFrame.BorderSizePixel = 0
                GroupboxFrame.Size = UDim2.new(1, 0, 0, 0); GroupboxFrame.AutomaticSize = Enum.AutomaticSize.Y; GroupboxFrame.LayoutOrder = #self.Groupboxes + 1
                GroupboxFrame.Parent = side == "Left" and LeftContainer or RightContainer
                GroupboxCorner.CornerRadius = UDim.new(0, 6); GroupboxCorner.Parent = GroupboxFrame
                GroupboxStroke.Color = Color3.fromRGB(40, 40, 48); GroupboxStroke.Thickness = 1; GroupboxStroke.Parent = GroupboxFrame

                GroupboxTitle.Name = "Title"; GroupboxTitle.Parent = GroupboxFrame; GroupboxTitle.BackgroundTransparency = 1
                GroupboxTitle.Position = UDim2.new(0, 12, 0, 8); GroupboxTitle.Size = UDim2.new(1, -24, 0, 20)
                GroupboxTitle.Font = Enum.Font.GothamBold; GroupboxTitle.Text = name; GroupboxTitle.TextColor3 = options.DefaultColor; GroupboxTitle.TextSize = 13
                GroupboxTitle.TextXAlignment = Enum.TextXAlignment.Left

                GroupboxContent.Name = "Content"; GroupboxContent.Parent = GroupboxFrame; GroupboxContent.BackgroundTransparency = 1
                GroupboxContent.Position = UDim2.new(0, 12, 0, 35); GroupboxContent.Size = UDim2.new(1, -24, 0, 0); GroupboxContent.AutomaticSize = Enum.AutomaticSize.Y
                GroupboxLayout.Parent = GroupboxContent; GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder; GroupboxLayout.Padding = UDim.new(0, 8)
                local GroupboxPadding = Instance.new("UIPadding"); GroupboxPadding.PaddingBottom = UDim.new(0, 10); GroupboxPadding.Parent = GroupboxContent

                local groupbox = {
                    Frame = GroupboxFrame, Content = GroupboxContent, Layout = GroupboxLayout, Side = side, Elements = {},
                    UpdateSize = function(self) updateContentSize() end,
                    
                    AddToggle = function(self, id, opts)
                        opts = opts or {}; opts.DefaultColor = opts.DefaultColor or Window.DefaultColor; opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local ToggleFrame = Instance.new("Frame"); local ToggleButton = Instance.new("TextButton")
                        local ToggleIndicator = Instance.new("Frame"); local ToggleIndicatorCorner = Instance.new("UICorner")
                        local ToggleCircle = Instance.new("Frame"); local ToggleCircleCorner = Instance.new("UICorner")
                        local ToggleText = Instance.new("TextLabel")
                        
                        ToggleFrame.Name = id .. "Toggle"; ToggleFrame.Parent = GroupboxContent; ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 24); ToggleFrame.LayoutOrder = #self.Elements + 1
                    
                        ToggleButton.Name = "Button"; ToggleButton.Parent = ToggleFrame; ToggleButton.BackgroundTransparency = 1
                        ToggleButton.Size = UDim2.new(1, opts.HasColorPicker and -28 or 0, 1, 0); ToggleButton.Text = ""; ToggleButton.AutoButtonColor = false
                    
                        -- Modern iOS Style Toggle
                        ToggleIndicator.Name = "Indicator"; ToggleIndicator.Parent = ToggleFrame; ToggleIndicator.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
                        ToggleIndicator.BorderSizePixel = 0; ToggleIndicator.Position = UDim2.new(0, 0, 0.5, -8); ToggleIndicator.Size = UDim2.new(0, 36, 0, 16)
                        ToggleIndicatorCorner.CornerRadius = UDim.new(1, 0); ToggleIndicatorCorner.Parent = ToggleIndicator
                        
                        local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Color = Color3.fromRGB(60, 60, 70); ToggleStroke.Thickness = 1; ToggleStroke.Parent = ToggleIndicator
                        
                        ToggleCircle.Name = "Circle"; ToggleCircle.Parent = ToggleIndicator; ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                        ToggleCircle.BorderSizePixel = 0; ToggleCircle.Position = UDim2.new(0, 2, 0.5, -6); ToggleCircle.Size = UDim2.new(0, 12, 0, 12)
                        ToggleCircleCorner.CornerRadius = UDim.new(1, 0); ToggleCircleCorner.Parent = ToggleCircle
                    
                        ToggleText.Name = "Text"; ToggleText.Parent = ToggleFrame; ToggleText.BackgroundTransparency = 1
                        ToggleText.Position = UDim2.new(0, 44, 0, 0); ToggleText.Size = UDim2.new(1, opts.HasColorPicker and -72 or -44, 1, 0)
                        ToggleText.Font = Enum.Font.Gotham; ToggleText.Text = opts.Text or id; ToggleText.TextColor3 = opts.TextColor
                        ToggleText.TextSize = 12; ToggleText.TextXAlignment = Enum.TextXAlignment.Left; ToggleText.TextTruncate = Enum.TextTruncate.AtEnd
                    
                        local toggled = opts.Default or false
                    
                        local function updateToggle()
                            if toggled then
                                smoothTween(ToggleIndicator, {BackgroundColor3 = opts.DefaultColor}, 0.25)
                                smoothTween(ToggleStroke, {Color = opts.DefaultColor}, 0.25)
                                smoothTween(ToggleCircle, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.25, Enum.EasingStyle.Back)
                            else
                                smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}, 0.25)
                                smoothTween(ToggleStroke, {Color = Color3.fromRGB(60, 60, 70)}, 0.25)
                                smoothTween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.25, Enum.EasingStyle.Back)
                            end
                            if opts.Callback then opts.Callback(toggled) end
                        end
                        
                        ToggleButton.MouseEnter:Connect(function() if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(50, 50, 58)}) end end)
                        ToggleButton.MouseLeave:Connect(function() if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}) end end)
                        ToggleButton.MouseButton1Click:Connect(function() toggled = not toggled; updateToggle() end)
                    
                        local colorPicker = nil; local extraColorPickers = {}; local nextIconOffset = -28
                        if opts.HasColorPicker then
                            colorPicker = createColorPickerIcon(ToggleFrame, nextIconOffset, opts.DefaultColor or Window.DefaultColor, opts.ColorCallback, player, id)
                            nextIconOffset = nextIconOffset - 24
                        end
                        updateToggle()
                        
                        local element = {
                            Type = "Toggle", Frame = ToggleFrame,
                            SetValue = function(value) toggled = value; updateToggle() end,
                            GetValue = function() return toggled end,
                            ColorPicker = colorPicker, ExtraColorPickers = extraColorPickers,
                            AddColorPickerIcon = function(_, pickerId, pickerOpts)
                                pickerOpts = pickerOpts or {}
                                local picker = createColorPickerIcon(ToggleFrame, nextIconOffset, pickerOpts.Default or Window.DefaultColor, pickerOpts.Callback, player, id .. "_" .. (pickerId or tostring(#extraColorPickers + 1)))
                                nextIconOffset = nextIconOffset - 24; table.insert(extraColorPickers, picker); return picker
                            end,
                            Destroy = function(self) if self.ColorPicker then self.ColorPicker:Destroy() end; for _, p in ipairs(self.ExtraColorPickers) do p:Destroy() end; ToggleFrame:Destroy() end
                        }
                        table.insert(self.Elements, element); self:UpdateSize(); return element
                    end,
                    
                    AddSlider = function(self, id, opts)
                        opts = opts or {}; opts.DefaultColor = opts.DefaultColor or Window.DefaultColor; opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local SliderFrame = Instance.new("Frame"); local SliderText = Instance.new("TextLabel")
                        local SliderBackground = Instance.new("Frame"); local SliderBackgroundCorner = Instance.new("UICorner")
                        local SliderFill = Instance.new("Frame"); local SliderFillCorner = Instance.new("UICorner")
                        local SliderButton = Instance.new("TextButton"); local ValueLabel = Instance.new("TextLabel")

                        SliderFrame.Name = id .. "Slider"; SliderFrame.Parent = GroupboxContent; SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Size = UDim2.new(1, 0, 0, 40); SliderFrame.LayoutOrder = #self.Elements + 1

                        SliderText.Name = "Text"; SliderText.Parent = SliderFrame; SliderText.BackgroundTransparency = 1
                        SliderText.Position = UDim2.new(0, 0, 0, 0); SliderText.Size = UDim2.new(1, -50, 0, 20)
                        SliderText.Font = Enum.Font.Gotham; SliderText.Text = opts.Text or id; SliderText.TextColor3 = opts.TextColor
                        SliderText.TextSize = 12; SliderText.TextXAlignment = Enum.TextXAlignment.Left

                        SliderBackground.Name = "Background"; SliderBackground.Parent = SliderFrame; SliderBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                        SliderBackground.BorderSizePixel = 0; SliderBackground.Position = UDim2.new(0, 0, 0, 24); SliderBackground.Size = UDim2.new(1, -50, 0, 6)
                        SliderBackgroundCorner.CornerRadius = UDim.new(1, 0); SliderBackgroundCorner.Parent = SliderBackground
                        
                        local SliderStroke = Instance.new("UIStroke"); SliderStroke.Color = Color3.fromRGB(50, 50, 58); SliderStroke.Thickness = 1; SliderStroke.Parent = SliderBackground

                        SliderFill.Name = "Fill"; SliderFill.Parent = SliderBackground; SliderFill.BackgroundColor3 = opts.DefaultColor
                        SliderFill.BorderSizePixel = 0; SliderFill.Size = UDim2.new(0, 0, 1, 0); SliderFillCorner.CornerRadius = UDim.new(1, 0); SliderFillCorner.Parent = SliderFill

                        SliderButton.Name = "Button"; SliderButton.Parent = SliderBackground; SliderButton.BackgroundTransparency = 1
                        SliderButton.Size = UDim2.new(1, 0, 1, 0); SliderButton.Text = ""; SliderButton.AutoButtonColor = false

                        ValueLabel.Name = "Value"; ValueLabel.Parent = SliderFrame; ValueLabel.BackgroundTransparency = 1
                        ValueLabel.Position = UDim2.new(1, -46, 0, 0); ValueLabel.Size = UDim2.new(0, 44, 0, 20)
                        ValueLabel.Font = Enum.Font.GothamBold; ValueLabel.Text = tostring(opts.Default or opts.Min or 0)
                        ValueLabel.TextColor3 = opts.DefaultColor; ValueLabel.TextSize = 11; ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

                        local min = opts.Min or 0; local max = opts.Max or 100; local rounding = opts.Rounding or 1
                        local value = opts.Default or min; local dragging = false

                        local function updateSlider(input)
                            local sizeX = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                            value = min + (max - min) * sizeX
                            if rounding == 1 then value = math.floor(value) elseif rounding == 2 then value = math.floor(value * 10) / 10 elseif rounding == 3 then value = math.floor(value * 100) / 100 end
                            smoothTween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.1); ValueLabel.Text = tostring(value)
                            if opts.Callback then opts.Callback(value) end
                        end

                        local dragConn, releaseConn
                        local function endSliderDrag() if dragConn then dragConn:Disconnect() end; if releaseConn then releaseConn:Disconnect() end; dragging = false end

                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true; updateSlider(input)
                                dragConn = UserInputService.InputChanged:Connect(function(moveInput) if dragging and moveInput.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(moveInput) end end)
                                releaseConn = UserInputService.InputEnded:Connect(function(endInput) if endInput.UserInputType == Enum.UserInputType.MouseButton1 then endSliderDrag() end end)
                            end
                        end)

                        local initialPercent = math.clamp((value - min) / (max - min), 0, 1)
                        SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0); ValueLabel.Text = tostring(value)

                        local element = {
                            Type = "Slider", Frame = SliderFrame,
                            SetValue = function(newValue) value = math.clamp(newValue, min, max); local p = (value - min) / (max - min); smoothTween(SliderFill, {Size = UDim2.new(p, 0, 1, 0)}, 0.15); ValueLabel.Text = tostring(value) end,
                            GetValue = function() return value end,
                            Destroy = function() endSliderDrag(); SliderFrame:Destroy() end
                        }
                        table.insert(self.Elements, element); self:UpdateSize(); return element
                    end,
                    
                    AddDropdown = function(self, id, opts)
                        opts = opts or {}; opts.DefaultColor = opts.DefaultColor or Window.DefaultColor; opts.TextColor = opts.TextColor or Window.TextColor
                        opts.Values = opts.Values or {}

                        local DropdownFrame = Instance.new("Frame"); local DropdownTitle = Instance.new("TextLabel")
                        local DropdownButton = Instance.new("TextButton"); local DropdownCorner = Instance.new("UICorner")
                        local DropdownArrow = Instance.new("TextLabel"); local DropdownListFrame = Instance.new("Frame")
                        local DropdownListCorner = Instance.new("UICorner"); local DropdownListLayout = Instance.new("UIListLayout")
                        local DropdownListPadding = Instance.new("UIPadding")

                        DropdownFrame.Name = id .. "Dropdown"; DropdownFrame.Parent = GroupboxContent; DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 40); DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y; DropdownFrame.LayoutOrder = #self.Elements + 1
                        DropdownFrame.ClipsDescendants = true

                        DropdownTitle.Name = "Title"; DropdownTitle.Parent = DropdownFrame; DropdownTitle.BackgroundTransparency = 1
                        DropdownTitle.Size = UDim2.new(1, 0, 0, 18); DropdownTitle.Font = Enum.Font.Gotham
                        DropdownTitle.Text = opts.Text or id; DropdownTitle.TextColor3 = opts.TextColor; DropdownTitle.TextSize = 12; DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left

                        DropdownButton.Name = "Button"; DropdownButton.Parent = DropdownFrame; DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                        DropdownButton.BorderSizePixel = 0; DropdownButton.Position = UDim2.new(0, 0, 0, 20); DropdownButton.Size = UDim2.new(1, 0, 0, 24)
                        DropdownButton.Text = opts.Default or "Select..."; DropdownButton.TextColor3 = opts.TextColor; DropdownButton.TextSize = 11
                        DropdownButton.Font = Enum.Font.Gotham; DropdownButton.TextXAlignment = Enum.TextXAlignment.Left; DropdownButton.AutoButtonColor = false
                        DropdownCorner.CornerRadius = UDim.new(0, 4); DropdownCorner.Parent = DropdownButton
                        local ButtonPad = Instance.new("UIPadding"); ButtonPad.Parent = DropdownButton; ButtonPad.PaddingLeft = UDim.new(0, 8)
                        
                        local DDStroke = Instance.new("UIStroke"); DDStroke.Color = Color3.fromRGB(50, 50, 58); DDStroke.Thickness = 1; DDStroke.Parent = DropdownButton

                        DropdownArrow.Parent = DropdownButton; DropdownArrow.BackgroundTransparency = 1; DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                        DropdownArrow.Position = UDim2.new(1, -25, 0, 0); DropdownArrow.Font = Enum.Font.GothamBold; DropdownArrow.Text = "v"
                        DropdownArrow.TextColor3 = opts.TextColor; DropdownArrow.TextSize = 10

                        DropdownListFrame.Name = "List"; DropdownListFrame.Parent = DropdownFrame; DropdownListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                        DropdownListFrame.BorderSizePixel = 0; DropdownListFrame.Position = UDim2.new(0, 0, 0, 46); DropdownListFrame.Size = UDim2.new(1, 0, 0, 0)
                        DropdownListFrame.ClipsDescendants = true; DropdownListCorner.CornerRadius = UDim.new(0, 4); DropdownListCorner.Parent = DropdownListFrame
                        DropdownListLayout.Parent = DropdownListFrame; DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder; DropdownListLayout.Padding = UDim.new(0, 2)
                        DropdownListPadding.Parent = DropdownListFrame; DropdownListPadding.PaddingTop = UDim.new(0, 4); DropdownListPadding.PaddingBottom = UDim.new(0, 4)

                        local isOpen = false; local selectedValue = opts.Default
                        local itemButtons = {}

                        for _, val in ipairs(opts.Values) do
                            local ItemButton = Instance.new("TextButton"); ItemButton.Parent = DropdownListFrame; ItemButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
                            ItemButton.BorderSizePixel = 0; ItemButton.Size = UDim2.new(1, 0, 0, 22); ItemButton.Text = val; ItemButton.TextColor3 = opts.TextColor
                            ItemButton.Font = Enum.Font.Gotham; ItemButton.TextSize = 11; ItemButton.TextXAlignment = Enum.TextXAlignment.Left; ItemButton.AutoButtonColor = false
                            local ItemPad = Instance.new("UIPadding"); ItemPad.Parent = ItemButton; ItemPad.PaddingLeft = UDim.new(0, 8)
                            local ItemCorner = Instance.new("UICorner"); ItemCorner.CornerRadius = UDim.new(0, 4); ItemCorner.Parent = ItemButton
                            
                            ItemButton.MouseEnter:Connect(function() smoothTween(ItemButton, {BackgroundColor3 = opts.DefaultColor}) end)
                            ItemButton.MouseLeave:Connect(function() smoothTween(ItemButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 42)}) end)
                            ItemButton.MouseButton1Click:Connect(function()
                                selectedValue = val; DropdownButton.Text = val
                                if opts.Callback then opts.Callback(val) end
                                -- Close dropdown smoothly
                                isOpen = not isOpen
                                smoothTween(DropdownListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.2)
                                smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                            end)
                            table.insert(itemButtons, ItemButton)
                        end

                        DropdownButton.MouseButton1Click:Connect(function()
                            isOpen = not isOpen
                            if isOpen then
                                local targetSize = UDim2.new(1, 0, 0, DropdownListLayout.AbsoluteContentSize.Y + 8)
                                smoothTween(DropdownListFrame, {Size = targetSize}, 0.25, Enum.EasingStyle.Back)
                                smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + DropdownListLayout.AbsoluteContentSize.Y + 8)}, 0.25, Enum.EasingStyle.Back)
                                smoothTween(DropdownArrow, {Rotation = 180}, 0.25)
                            else
                                smoothTween(DropdownListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.2)
                            end
                        end)

                        local element = {
                            Type = "Dropdown", Frame = DropdownFrame,
                            SetValue = function(val) selectedValue = val; DropdownButton.Text = val end,
                            GetValue = function() return selectedValue end,
                            Destroy = function() DropdownFrame:Destroy() end
                        }
                        table.insert(self.Elements, element); self:UpdateSize(); return element
                    end,

                    AddKeybind = function(self, id, opts)
                        opts = opts or {}; opts.DefaultColor = opts.DefaultColor or Window.DefaultColor; opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local KeybindFrame = Instance.new("Frame"); local KeybindText = Instance.new("TextLabel")
                        local KeybindButton = Instance.new("TextButton"); local KeybindCorner = Instance.new("UICorner")

                        KeybindFrame.Name = id .. "Keybind"; KeybindFrame.Parent = GroupboxContent; KeybindFrame.BackgroundTransparency = 1
                        KeybindFrame.Size = UDim2.new(1, 0, 0, 24); KeybindFrame.LayoutOrder = #self.Elements + 1

                        KeybindText.Name = "Text"; KeybindText.Parent = KeybindFrame; KeybindText.BackgroundTransparency = 1
                        KeybindText.Size = UDim2.new(1, -80, 1, 0); KeybindText.Font = Enum.Font.Gotham; KeybindText.Text = opts.Text or id
                        KeybindText.TextColor3 = opts.TextColor; KeybindText.TextSize = 12; KeybindText.TextXAlignment = Enum.TextXAlignment.Left

                        KeybindButton.Name = "Button"; KeybindButton.Parent = KeybindFrame; KeybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                        KeybindButton.BorderSizePixel = 0; KeybindButton.Position = UDim2.new(1, -75, 0.5, -10); KeybindButton.Size = UDim2.new(0, 75, 0, 20)
                        KeybindButton.Font = Enum.Font.GothamBold; KeybindButton.Text = opts.Default and opts.Default.Name or "None"
                        KeybindButton.TextColor3 = opts.TextColor; KeybindButton.TextSize = 10; KeybindButton.AutoButtonColor = false
                        KeybindCorner.CornerRadius = UDim.new(0, 4); KeybindCorner.Parent = KeybindButton
                        local KBStroke = Instance.new("UIStroke"); KBStroke.Color = Color3.fromRGB(50, 50, 58); KBStroke.Thickness = 1; KBStroke.Parent = KeybindButton

                        local listening = false; local currentKey = opts.Default

                        KeybindButton.MouseButton1Click:Connect(function()
                            if listening then return end
                            listening = true; KeybindButton.Text = "..."
                            smoothTween(KeybindButton, {BackgroundColor3 = opts.DefaultColor}, 0.2)

                            local conn; conn = UserInputService.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    currentKey = input.KeyCode; KeybindButton.Text = currentKey.Name
                                    listening = false; conn:Disconnect()
                                    smoothTween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 36)}, 0.2)
                                    if opts.Callback then opts.Callback(currentKey) end
                                end
                            end)
                        end)

                        local element = {
                            Type = "Keybind", Frame = KeybindFrame,
                            SetValue = function(key) currentKey = key; KeybindButton.Text = key.Name end,
                            GetValue = function() return currentKey end,
                            Destroy = function() KeybindFrame:Destroy() end
                        }
                        table.insert(self.Elements, element); self:UpdateSize(); return element
                    end
                }

                table.insert(self.Groupboxes, groupbox)
                return groupbox
            end
        }

        TabButton.MouseButton1Click:Connect(function()
            if Window.ActiveTab == tab then return end
            if Window.ActiveTab then
                smoothTween(Window.ActiveTab.Button, {BackgroundTransparency = 1})
                smoothTween(Window.ActiveTab.Button, {TextTransparency = 0.6})
                Window.ActiveTab.Highlight.Visible = false
                smoothTween(Window.ActiveTab.Content, {GroupTransparency = 1})
                Window.ActiveTab.Content.Visible = false
            end
            
            Window.ActiveTab = tab
            smoothTween(TabButton, {BackgroundTransparency = 0.5})
            smoothTween(TabButton, {TextTransparency = 0})
            TabHighlight.Visible = true
            
            tab.Content.Visible = true
            smoothTween(tab.Content, {GroupTransparency = 0})
        end)

        table.insert(tabs, tab)
        if #tabs == 1 then TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42); TabButton.BackgroundTransparency = 0.5; TabButton.TextTransparency = 0; TabHighlight.Visible = true; tab.Content.Visible = true; tab.Content.GroupTransparency = 0; Window.ActiveTab = tab end

        return tab
    end

    function Window:ToggleVisibility()
        if MainBackGround.Visible then
            smoothTween(MainBackGround, {Size = UDim2.new(MainBackGround.Size.X.Offset, 0)}, 0.2)
            task.delay(0.2, function() MainBackGround.Visible = false end)
        else
            MainBackGround.Visible = true
            MainBackGround.Size = UDim2.new(options.Size.X.Offset, 0, options.Size.Y.Offset, 0)
            smoothTween(MainBackGround, {Size = options.Size}, 0.25, Enum.EasingStyle.Back)
        end
    end

    return Window
end

return UILibrary
