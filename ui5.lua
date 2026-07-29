local UILibrary = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

-- ──────────────────────────────────────────────────────────────────────────────
-- Safe task library (fallback for older exploits)
-- ──────────────────────────────────────────────────────────────────────────────
local task = task or {
    delay = function(t, f)
        local co = coroutine.create(function() wait(t) f() end)
        coroutine.resume(co)
        return co
    end,
    cancel = function(co)
        if coroutine.close then coroutine.close(co) end
    end,
    wait = function(t) return wait(t) end,
    spawn = function(f) return coroutine.wrap(f)() end
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Color helpers
-- ──────────────────────────────────────────────────────────────────────────────
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local imod = i % 6
    if     imod == 0 then r, g, b = v, t, p
    elseif imod == 1 then r, g, b = q, v, p
    elseif imod == 2 then r, g, b = p, v, t
    elseif imod == 3 then r, g, b = p, q, v
    elseif imod == 4 then r, g, b = t, p, v
    elseif imod == 5 then r, g, b = v, p, q
    end
    return r, g, b
end

local function RGBtoHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    s = max == 0 and 0 or d / max
    if max ~= min then
        if     max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

local fromHSV = Color3.fromHSV or function(h, s, v)
    local r, g, b = HSVtoRGB(h, s, v)
    return Color3.new(r, g, b)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Tween helper
-- ──────────────────────────────────────────────────────────────────────────────
local function smoothTween(instance, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Safe CoreGui parent (exploit environments)
-- ──────────────────────────────────────────────────────────────────────────────
local function safeParentGui(gui, player)
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not success or gui.Parent ~= game:GetService("CoreGui") then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Shared color picker factory
-- ──────────────────────────────────────────────────────────────────────────────
local function createColorPickerIcon(iconParent, iconOffset, defaultColor, callback, player, windowName)
    local ColorIcon = Instance.new("TextButton")
    ColorIcon.Name              = "ColorIcon_" .. windowName
    ColorIcon.Parent            = iconParent
    ColorIcon.BackgroundColor3  = defaultColor
    ColorIcon.AnchorPoint       = Vector2.new(1, 0.5)
    ColorIcon.Position          = UDim2.new(1, iconOffset, 0.5, 0)
    ColorIcon.Size              = UDim2.new(0, 18, 0, 18)
    ColorIcon.Text              = ""
    ColorIcon.AutoButtonColor   = false
    ColorIcon.ZIndex            = 3
    ColorIcon.BorderSizePixel   = 0

    local _cc = Instance.new("UICorner"); _cc.CornerRadius = UDim.new(0, 4); _cc.Parent = ColorIcon

    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color     = Color3.fromRGB(70, 70, 70)
    colorStroke.Thickness = 1.5
    colorStroke.Parent    = ColorIcon

    ColorIcon.MouseEnter:Connect(function()
        smoothTween(colorStroke, {Thickness = 2.5, Color = Color3.fromRGB(180, 180, 180)}, 0.12)
        smoothTween(ColorIcon,   {Size = UDim2.new(0, 20, 0, 20)}, 0.12)
    end)
    ColorIcon.MouseLeave:Connect(function()
        smoothTween(colorStroke, {Thickness = 1.5, Color = Color3.fromRGB(70, 70, 70)}, 0.12)
        smoothTween(ColorIcon,   {Size = UDim2.new(0, 18, 0, 18)}, 0.12)
    end)

    local colorPickerScreenGui = Instance.new("ScreenGui")
    colorPickerScreenGui.Name           = "ColorPickerGui_" .. windowName
    colorPickerScreenGui.ResetOnSpawn   = false
    colorPickerScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    colorPickerScreenGui.DisplayOrder   = 10001
    safeParentGui(colorPickerScreenGui, player)

    local colorPickerWindow = Instance.new("Frame")
    colorPickerWindow.Name             = "ColorPickerWindow"
    colorPickerWindow.Parent           = colorPickerScreenGui
    colorPickerWindow.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    colorPickerWindow.BorderSizePixel  = 0
    colorPickerWindow.Position         = UDim2.new(0.5, -130, 0.5, -110)
    colorPickerWindow.Size             = UDim2.new(0, 260, 0, 215)
    colorPickerWindow.Visible          = false
    colorPickerWindow.ZIndex           = 100
    colorPickerWindow.ClipsDescendants = false

    local _wc = Instance.new("UICorner"); _wc.CornerRadius = UDim.new(0, 8); _wc.Parent = colorPickerWindow

    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color        = Color3.fromRGB(45, 45, 45)
    windowStroke.LineJoinMode = Enum.LineJoinMode.Miter
    windowStroke.Thickness    = 1.5
    windowStroke.Parent       = colorPickerWindow

    local titleFrame = Instance.new("Frame")
    titleFrame.Size             = UDim2.new(1, 0, 0, 2)
    titleFrame.Parent           = colorPickerWindow
    titleFrame.BackgroundColor3 = Color3.fromRGB(165, 127, 159)
    titleFrame.BorderSizePixel  = 0
    local _tc = Instance.new("UICorner"); _tc.CornerRadius = UDim.new(0, 8); _tc.Parent = titleFrame

    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name                = "ColorPickerFrame"
    colorPickerFrame.Parent              = colorPickerWindow
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Position            = UDim2.new(0, 15, 0, 15)
    colorPickerFrame.Size                = UDim2.new(1, -30, 1, -25)
    colorPickerFrame.ZIndex              = 101

    local saturationValueBox = Instance.new("Frame")
    saturationValueBox.Name             = "SaturationValueBox"
    saturationValueBox.Parent           = colorPickerFrame
    saturationValueBox.BackgroundColor3 = Color3.new(1, 0, 0)
    saturationValueBox.BorderSizePixel  = 0
    saturationValueBox.Position         = UDim2.new(0, 0, 0, 0)
    saturationValueBox.Size             = UDim2.new(0, 185, 0, 155)
    saturationValueBox.ZIndex           = 101
    saturationValueBox.ClipsDescendants = true

    local _svc = Instance.new("UICorner"); _svc.CornerRadius = UDim.new(0, 4); _svc.Parent = saturationValueBox
    local svStroke = Instance.new("UIStroke"); svStroke.Color = Color3.fromRGB(55, 55, 55); svStroke.Thickness = 1; svStroke.Parent = saturationValueBox

    local svOverlay = Instance.new("Frame")
    svOverlay.Name                 = "SVOverlay"
    svOverlay.Parent               = saturationValueBox
    svOverlay.BackgroundTransparency = 0
    svOverlay.Size                 = UDim2.new(1, 0, 1, 0)
    svOverlay.ZIndex               = 102
    svOverlay.BorderSizePixel      = 0

    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
    }
    satGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }
    satGradient.Parent = svOverlay

    local svOverlay2 = Instance.new("Frame")
    svOverlay2.Name                 = "SVOverlay2"
    svOverlay2.Parent               = saturationValueBox
    svOverlay2.BackgroundColor3     = Color3.new(0, 0, 0)
    svOverlay2.BackgroundTransparency = 0
    svOverlay2.Size                 = UDim2.new(1, 0, 1, 0)
    svOverlay2.ZIndex               = 103
    svOverlay2.BorderSizePixel      = 0

    local valueGradient = Instance.new("UIGradient")
    valueGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    }
    valueGradient.Rotation = 90
    valueGradient.Parent   = svOverlay2

    local saturationValueButton = Instance.new("TextButton")
    saturationValueButton.Name             = "SaturationValueButton"
    saturationValueButton.Parent           = saturationValueBox
    saturationValueButton.BackgroundColor3 = Color3.new(1, 1, 1)
    saturationValueButton.BorderSizePixel  = 0
    saturationValueButton.Position         = UDim2.new(0.5, -5, 0.5, -5)
    saturationValueButton.Size             = UDim2.new(0, 10, 0, 10)
    saturationValueButton.Text             = ""
    saturationValueButton.ZIndex           = 104
    saturationValueButton.AutoButtonColor  = false

    local _svbc = Instance.new("UICorner"); _svbc.CornerRadius = UDim.new(1, 0); _svbc.Parent = saturationValueButton
    local svButtonStroke = Instance.new("UIStroke"); svButtonStroke.Color = Color3.new(1,1,1); svButtonStroke.Thickness = 2; svButtonStroke.Parent = saturationValueButton

    local hueSlider = Instance.new("Frame")
    hueSlider.Name             = "HueSlider"
    hueSlider.Parent           = colorPickerFrame
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel  = 0
    hueSlider.Position         = UDim2.new(0, 200, 0, 0)
    hueSlider.Size             = UDim2.new(0, 22, 0, 155)
    hueSlider.ZIndex           = 101

    local _hc = Instance.new("UICorner"); _hc.CornerRadius = UDim.new(0, 6); _hc.Parent = hueSlider
    local hueStroke = Instance.new("UIStroke"); hueStroke.Color = Color3.fromRGB(55, 55, 55); hueStroke.Thickness = 1; hueStroke.Parent = hueSlider

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   0)),
    }
    hueGradient.Rotation = 90
    hueGradient.Parent   = hueSlider

    local hueSliderButton = Instance.new("TextButton")
    hueSliderButton.Name             = "HueSliderButton"
    hueSliderButton.Parent           = hueSlider
    hueSliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSliderButton.BorderSizePixel  = 0
    hueSliderButton.Position         = UDim2.new(0, -3, 0, 0)
    hueSliderButton.Size             = UDim2.new(1, 6, 0, 6)
    hueSliderButton.Text             = ""
    hueSliderButton.ZIndex           = 102
    hueSliderButton.AutoButtonColor  = false

    local _hbc = Instance.new("UICorner"); _hbc.CornerRadius = UDim.new(0, 3); _hbc.Parent = hueSliderButton
    local hueButtonStroke = Instance.new("UIStroke"); hueButtonStroke.Color = Color3.new(1,1,1); hueButtonStroke.Thickness = 2; hueButtonStroke.Parent = hueSliderButton

    local previewSwatch = Instance.new("Frame")
    previewSwatch.Name             = "PreviewSwatch"
    previewSwatch.Parent           = colorPickerFrame
    previewSwatch.BackgroundColor3 = defaultColor
    previewSwatch.BorderSizePixel  = 0
    previewSwatch.Position         = UDim2.new(0, 0, 1, -22)
    previewSwatch.Size             = UDim2.new(0, 185, 0, 18)
    previewSwatch.ZIndex           = 101

    local _psc = Instance.new("UICorner"); _psc.CornerRadius = UDim.new(0, 4); _psc.Parent = previewSwatch
    local previewStroke = Instance.new("UIStroke"); previewStroke.Color = Color3.fromRGB(55,55,55); previewStroke.Thickness = 1; previewStroke.Parent = previewSwatch

    local hexLabel = Instance.new("TextLabel")
    hexLabel.Name                 = "HexLabel"
    hexLabel.Parent               = colorPickerFrame
    hexLabel.BackgroundTransparency = 1
    hexLabel.Position             = UDim2.new(0, 200, 1, -22)
    hexLabel.Size                 = UDim2.new(0, 22, 0, 18)
    hexLabel.Font                 = Enum.Font.GothamBold
    hexLabel.Text                 = ""
    hexLabel.TextColor3           = Color3.fromRGB(160, 160, 160)
    hexLabel.TextSize             = 8
    hexLabel.TextScaled           = true
    hexLabel.ZIndex               = 101

    local SV_WIDTH  = 175
    local SV_HEIGHT = 145
    local HUE_HEIGHT = 145

    local currentColor = defaultColor or Color3.new(1, 1, 1)
    local hue, saturation, value = RGBtoHSV(currentColor.R, currentColor.G, currentColor.B)
    local updating = false

    local function toHex(c)
        return string.format("#%02X%02X%02X",
            math.floor(c.R * 255 + 0.5),
            math.floor(c.G * 255 + 0.5),
            math.floor(c.B * 255 + 0.5))
    end

    local function updateColor()
        if updating then return end
        updating = true

        local r, g, b = HSVtoRGB(hue, saturation, value)
        currentColor = Color3.new(r, g, b)

        saturationValueBox.BackgroundColor3 = fromHSV(hue, 1, 1)
        previewSwatch.BackgroundColor3      = currentColor
        hexLabel.Text                       = toHex(currentColor)

        local hueY = math.clamp(hue * HUE_HEIGHT, 0, HUE_HEIGHT)
        local satX = math.clamp(saturation * SV_WIDTH,  0, SV_WIDTH)
        local valY = math.clamp((1 - value) * SV_HEIGHT, 0, SV_HEIGHT)

        smoothTween(hueSliderButton,       {Position = UDim2.new(0, -3, 0, hueY)}, 0.06)
        smoothTween(saturationValueButton, {Position = UDim2.new(0, satX - 5, 0, valY - 5)}, 0.06)
        smoothTween(ColorIcon,             {BackgroundColor3 = currentColor}, 0.1)

        updating = false

        if callback then
            callback(currentColor)
        end
    end

    local function updateFromColor(color)
        if updating then return end
        hue, saturation, value = RGBtoHSV(color.R, color.G, color.B)
        updateColor()
    end

    do
        local savedCallback = callback
        callback = nil
        updateFromColor(currentColor)
        callback = savedCallback
    end

    local hueDragging = false
    local svDragging  = false

    hueSliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
        end
    end)

    saturationValueButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
        end
    end)

    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, HUE_HEIGHT)
            hue = yPos / HUE_HEIGHT
            updateColor()
            hueDragging = true
        end
    end)

    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, SV_WIDTH)
            local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, SV_HEIGHT)
            saturation = xPos / SV_WIDTH
            value       = 1 - (yPos / SV_HEIGHT)
            updateColor()
            svDragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if hueDragging then
            local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, HUE_HEIGHT)
            hue = yPos / HUE_HEIGHT
            updateColor()
        elseif svDragging then
            local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, SV_WIDTH)
            local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, SV_HEIGHT)
            saturation = xPos / SV_WIDTH
            value       = 1 - (yPos / SV_HEIGHT)
            updateColor()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            svDragging  = false
        end
    end)

    ColorIcon.MouseButton1Click:Connect(function()
        colorPickerWindow.Visible = not colorPickerWindow.Visible
    end)

    local clickOutsideConnection
    clickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not colorPickerWindow.Visible then return end

        local guiInset = GuiService:GetGuiInset()
        local mousePos = UserInputService:GetMouseLocation()
        mousePos = Vector2.new(mousePos.X, mousePos.Y - guiInset.Y)

        local ip = ColorIcon.AbsolutePosition
        local is = ColorIcon.AbsoluteSize
        if mousePos.X >= ip.X and mousePos.X <= ip.X + is.X
        and mousePos.Y >= ip.Y and mousePos.Y <= ip.Y + is.Y then
            return
        end

        local wp = colorPickerWindow.AbsolutePosition
        local ws = colorPickerWindow.AbsoluteSize
        if mousePos.X >= wp.X and mousePos.X <= wp.X + ws.X
        and mousePos.Y >= wp.Y and mousePos.Y <= wp.Y + ws.Y then
            return
        end

        colorPickerWindow.Visible = false
    end)

    return {
        Icon      = ColorIcon,
        ScreenGui = colorPickerScreenGui,
        Window    = colorPickerWindow,
        SetColor  = function(_, color) updateFromColor(color) end,
        GetColor  = function() return currentColor end,
        Show      = function() colorPickerWindow.Visible = true end,
        Hide      = function() colorPickerWindow.Visible = false end,
        Destroy   = function()
            if clickOutsideConnection then clickOutsideConnection:Disconnect() end
            colorPickerScreenGui:Destroy()
            ColorIcon:Destroy()
        end,
    }
end

-- Backward compatibility for different API calls
function UILibrary:CreateWindow(options)
    return UILibrary.new(options)
end

function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer

    local defaults = {
        Name            = "UI Library",
        ToggleKey       = Enum.KeyCode.RightShift,
        DefaultColor    = Color3.fromRGB(138, 102, 204),
        TextColor       = Color3.fromRGB(220, 220, 220),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        TabHolderColor  = Color3.fromRGB(14, 14, 14),
        GroupboxColor   = Color3.fromRGB(22, 22, 22),
        Size            = UDim2.new(0, 570, 0, 469),
        Position        = UDim2.new(0.226, 0, 0.146, 0),
        Theme           = "Dark",
        Watermark       = true,
        WatermarkText   = "UI Library v1.0.0",
    }
    for k, v in pairs(defaults) do
        if options[k] == nil then options[k] = v end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name            = options.Name
    ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn    = false
    ScreenGui.IgnoreGuiInset  = false
    ScreenGui.DisplayOrder    = 10000
    safeParentGui(ScreenGui, player)

    local MainBackGround = Instance.new("Frame")
    MainBackGround.Name             = "MainBackGround"
    MainBackGround.Parent           = ScreenGui
    MainBackGround.BackgroundColor3 = options.BackgroundColor
    MainBackGround.BorderSizePixel  = 0
    MainBackGround.Position         = options.Position
    MainBackGround.Size             = options.Size
    MainBackGround.ClipsDescendants = false

    local _mc = Instance.new("UICorner"); _mc.CornerRadius = UDim.new(0, 8); _mc.Parent = MainBackGround

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color     = Color3.fromRGB(40, 40, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Parent    = MainBackGround

    local TabHolder = Instance.new("Frame")
    TabHolder.Name             = "TabHolder"
    TabHolder.Parent           = MainBackGround
    TabHolder.BackgroundColor3 = options.TabHolderColor
    TabHolder.BorderSizePixel  = 0
    TabHolder.Position         = UDim2.new(0, 0, 0, 0)
    TabHolder.Size             = UDim2.new(0, 130, 1, 0)
    TabHolder.ClipsDescendants = true
    TabHolder.ZIndex           = 1

    local _thc = Instance.new("UICorner"); _thc.CornerRadius = UDim.new(0, 8); _thc.Parent = TabHolder

    local tabDivider = Instance.new("Frame")
    tabDivider.Name             = "TabDivider"
    tabDivider.Parent           = MainBackGround
    tabDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabDivider.BorderSizePixel  = 0
    tabDivider.Position         = UDim2.new(0, 130, 0, 0)
    tabDivider.Size             = UDim2.new(0, 1, 1, 0)
    tabDivider.ZIndex           = 1

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent           = TabHolder
    TabListLayout.FillDirection    = Enum.FillDirection.Vertical
    TabListLayout.SortOrder        = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding          = UDim.new(0, 2)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent      = TabHolder
    TabPadding.PaddingTop  = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name             = "ContentFrame"
    ContentFrame.Parent           = MainBackGround
    ContentFrame.BackgroundColor3 = options.BackgroundColor
    ContentFrame.BorderSizePixel  = 0
    ContentFrame.Position         = UDim2.new(0, 138, 0, 8)
    ContentFrame.Size             = UDim2.new(0, options.Size.X.Offset - 148, 0, options.Size.Y.Offset - 16)
    ContentFrame.ClipsDescendants = false

    local _cfc = Instance.new("UICorner"); _cfc.CornerRadius = UDim.new(0, 6); _cfc.Parent = ContentFrame

    local DragHandle = Instance.new("Frame")
    DragHandle.Name                 = "DragHandle"
    DragHandle.Parent               = TabHolder
    DragHandle.BackgroundTransparency = 1
    DragHandle.Position             = UDim2.new(0, 0, 0, 0)
    DragHandle.Size                 = UDim2.new(1, 0, 1, 0)
    DragHandle.ZIndex               = 0
    DragHandle.Active               = true

    if options.Watermark then
        local Watermark = Instance.new("TextLabel")
        Watermark.Name                = "Watermark"
        Watermark.Parent              = ScreenGui
        Watermark.BackgroundTransparency = 1
        Watermark.Position            = UDim2.new(0, 10, 0, 10)
        Watermark.Size                = UDim2.new(0, 220, 0, 20)
        Watermark.Font                = Enum.Font.GothamBold
        Watermark.Text                = options.WatermarkText
        Watermark.TextColor3          = options.DefaultColor
        Watermark.TextSize            = 13
        Watermark.TextXAlignment      = Enum.TextXAlignment.Left
    end

    local tabs      = {}
    local currentTab = nil

    local Window = {}
    Window.ActiveTab    = nil
    Window.Theme        = options.Theme
    Window.DefaultColor = options.DefaultColor
    Window.TextColor    = options.TextColor

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == options.ToggleKey then
            Window:ToggleVisibility()
        end
    end)

    local dragActive = false
    local dragStart  = nil
    local startPos   = nil

    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragActive = true
            dragStart  = input.Position
            startPos   = MainBackGround.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragActive = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragActive then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,  startPos.X.Offset + delta.X,
            startPos.Y.Scale,  startPos.Y.Offset + delta.Y
        )
        smoothTween(MainBackGround, {Position = newPos}, 0.1)
    end)

    function Window:AddTab(name)
        local TabButton  = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabHighlight = Instance.new("Frame")
        local TabCorner  = Instance.new("UICorner")
        local LeftContainer  = Instance.new("Frame")
        local LeftLayout     = Instance.new("UIListLayout")
        local RightContainer = Instance.new("Frame")
        local RightLayout    = Instance.new("UIListLayout")

        TabButton.Name               = name .. "Tab"
        TabButton.Parent             = TabHolder
        TabButton.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel    = 0
        TabButton.Size               = UDim2.new(1, 0, 0, 36)
        TabButton.Font               = Enum.Font.GothamSemibold
        TabButton.Text               = name
        TabButton.TextColor3         = options.TextColor
        TabButton.TextTransparency   = 0.5
        TabButton.TextSize           = 13
        TabButton.TextXAlignment     = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor    = false
        TabButton.ZIndex             = 2

        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent       = TabButton

        local _tp = Instance.new("UIPadding")
        _tp.Parent      = TabButton
        _tp.PaddingLeft = UDim.new(0, 12)

        TabHighlight.Parent           = TabButton
        TabHighlight.BackgroundColor3 = options.DefaultColor
        TabHighlight.BorderSizePixel  = 0
        TabHighlight.Position         = UDim2.new(0, -10, 0.15, 0)
        TabHighlight.Size             = UDim2.new(0, 3, 0.7, 0)
        TabHighlight.ZIndex           = 3
        TabHighlight.Visible          = false

        local _hlc = Instance.new("UICorner"); _hlc.CornerRadius = UDim.new(1, 0); _hlc.Parent = TabHighlight

        TabContent.Name              = name .. "Content"
        TabContent.Parent            = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel   = 0
        TabContent.Size              = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize        = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        TabContent.Visible           = false
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        TabContent.ClipsDescendants  = false
        TabContent.ElasticBehavior   = Enum.ElasticBehavior.Never

        LeftContainer.Name                = "LeftContainer"
        LeftContainer.Parent              = TabContent
        LeftContainer.BackgroundTransparency = 1
        LeftContainer.Position            = UDim2.new(0, 10, 0, 10)
        LeftContainer.Size                = UDim2.new(0.5, -15, 0, 0)
        LeftContainer.AutomaticSize       = Enum.AutomaticSize.Y

        LeftLayout.Parent              = LeftContainer
        LeftLayout.SortOrder           = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding             = UDim.new(0, 12)
        LeftLayout.FillDirection       = Enum.FillDirection.Vertical
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        LeftLayout.VerticalAlignment   = Enum.VerticalAlignment.Top

        RightContainer.Name                = "RightContainer"
        RightContainer.Parent              = TabContent
        RightContainer.BackgroundTransparency = 1
        RightContainer.Position            = UDim2.new(0.5, 5, 0, 10)
        RightContainer.Size                = UDim2.new(0.5, -15, 0, 0)
        RightContainer.AutomaticSize       = Enum.AutomaticSize.Y

        RightLayout.Parent              = RightContainer
        RightLayout.SortOrder           = Enum.SortOrder.LayoutOrder
        RightLayout.Padding             = UDim.new(0, 12)
        RightLayout.FillDirection       = Enum.FillDirection.Vertical
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        RightLayout.VerticalAlignment   = Enum.VerticalAlignment.Top

        local function updateContentSize()
            local leftH  = LeftLayout.AbsoluteContentSize.Y + 30
            local rightH = RightLayout.AbsoluteContentSize.Y + 30
            TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftH, rightH))
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)

        TabButton.MouseButton1Click:Connect(function()
            for _, td in pairs(tabs) do
                td.Content.Visible    = false
                td.Highlight.Visible  = false
                smoothTween(td.Button, {TextTransparency = 0.5, BackgroundTransparency = 1})
            end
            TabContent.Visible   = true
            TabHighlight.Visible = true
            smoothTween(TabButton, {TextTransparency = 0, BackgroundTransparency = 0.92}, 0.2)
            currentTab       = tab
            Window.ActiveTab = tab
        end)

        TabButton.MouseEnter:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 0.96})
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 1})
            end
        end)

        local tab = {
            Button         = TabButton,
            Content        = TabContent,
            Highlight      = TabHighlight,
            LeftContainer  = LeftContainer,
            RightContainer = RightContainer,
            Groupboxes     = {},
        }

        function tab:AddLeftGroupbox(name)  return self:CreateGroupbox(name, "Left")  end
        function tab:AddRightGroupbox(name) return self:CreateGroupbox(name, "Right") end
        function tab:CreateLeftGroupbox(name) return self:AddLeftGroupbox(name) end
        function tab:CreateRightGroupbox(name) return self:AddRightGroupbox(name) end

        function tab:CreateGroupbox(gName, side)
            local GroupboxFrame   = Instance.new("Frame")
            local GroupboxCorner  = Instance.new("UICorner")
            local GroupboxStroke  = Instance.new("UIStroke")
            local GroupboxTitle   = Instance.new("TextLabel")
            local GroupboxDivider = Instance.new("Frame")
            local GroupboxContent = Instance.new("Frame")
            local GroupboxLayout  = Instance.new("UIListLayout")

            GroupboxFrame.Name             = gName .. "Groupbox"
            GroupboxFrame.BackgroundColor3 = options.GroupboxColor
            GroupboxFrame.BorderSizePixel  = 0
            GroupboxFrame.Size             = UDim2.new(1, 0, 0, 0)
            GroupboxFrame.AutomaticSize    = Enum.AutomaticSize.Y
            GroupboxFrame.LayoutOrder      = #self.Groupboxes + 1
            GroupboxFrame.ClipsDescendants = false
            GroupboxFrame.Parent           = side == "Left" and LeftContainer or RightContainer

            GroupboxCorner.CornerRadius = UDim.new(0, 6)
            GroupboxCorner.Parent       = GroupboxFrame

            GroupboxStroke.Color     = Color3.fromRGB(33, 33, 33)
            GroupboxStroke.Thickness = 1
            GroupboxStroke.Parent    = GroupboxFrame

            GroupboxTitle.Name                = "Title"
            GroupboxTitle.Parent              = GroupboxFrame
            GroupboxTitle.BackgroundTransparency = 1
            GroupboxTitle.Position            = UDim2.new(0, 12, 0, 7)
            GroupboxTitle.Size                = UDim2.new(1, -24, 0, 20)
            GroupboxTitle.Font                = Enum.Font.GothamBold
            GroupboxTitle.Text                = gName
            GroupboxTitle.TextColor3          = options.DefaultColor
            GroupboxTitle.TextSize            = 12
            GroupboxTitle.TextXAlignment      = Enum.TextXAlignment.Left

            GroupboxDivider.Name             = "TitleDivider"
            GroupboxDivider.Parent           = GroupboxFrame
            GroupboxDivider.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
            GroupboxDivider.BorderSizePixel  = 0
            GroupboxDivider.Position         = UDim2.new(0, 0, 0, 31)
            GroupboxDivider.Size             = UDim2.new(1, 0, 0, 1)

            GroupboxContent.Name                = "Content"
            GroupboxContent.Parent              = GroupboxFrame
            GroupboxContent.BackgroundTransparency = 1
            GroupboxContent.Position            = UDim2.new(0, 12, 0, 38)
            GroupboxContent.Size                = UDim2.new(1, -24, 0, 0)
            GroupboxContent.AutomaticSize       = Enum.AutomaticSize.Y
            GroupboxContent.ClipsDescendants    = false

            GroupboxLayout.Parent    = GroupboxContent
            GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupboxLayout.Padding   = UDim.new(0, 8)

            local _gbp = Instance.new("UIPadding")
            _gbp.PaddingBottom = UDim.new(0, 10)
            _gbp.Parent        = GroupboxContent

            local groupbox = {
                Frame   = GroupboxFrame,
                Content = GroupboxContent,
                Layout  = GroupboxLayout,
                Side    = side,
                Elements = {},
            }

            function groupbox:UpdateSize()
                local leftH  = LeftLayout.AbsoluteContentSize.Y  + 30
                local rightH = RightLayout.AbsoluteContentSize.Y + 30
                TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftH, rightH))
            end

            function groupbox:AddColorPicker(id, pickerOptions)
                pickerOptions = pickerOptions or {}
                pickerOptions.DefaultColor = pickerOptions.DefaultColor or Window.DefaultColor
                pickerOptions.TextColor    = pickerOptions.TextColor    or Window.TextColor
                local defaultCol = pickerOptions.Default or pickerOptions.DefaultColor

                local CPFrame = Instance.new("Frame")
                local CPText  = Instance.new("TextLabel")

                CPFrame.Name               = id .. "ColorPicker"
                CPFrame.Parent             = GroupboxContent
                CPFrame.BackgroundTransparency = 1
                CPFrame.Size               = UDim2.new(1, 0, 0, 22)
                CPFrame.LayoutOrder        = #self.Elements + 1
                CPFrame.ClipsDescendants   = false

                CPText.Name               = "Text"
                CPText.Parent             = CPFrame
                CPText.BackgroundTransparency = 1
                CPText.Position           = UDim2.new(0, 0, 0, 0)
                CPText.Size               = UDim2.new(1, -28, 1, 0)
                CPText.Font               = Enum.Font.Gotham
                CPText.Text               = pickerOptions.Text or id
                CPText.TextColor3         = pickerOptions.TextColor
                CPText.TextSize           = 12
                CPText.TextXAlignment     = Enum.TextXAlignment.Left
                CPText.TextTruncate       = Enum.TextTruncate.AtEnd

                local picker = createColorPickerIcon(CPFrame, -4, defaultCol, pickerOptions.Callback, player, id)

                local element = {
                    Type        = "ColorPicker",
                    Frame       = CPFrame,
                    ColorPicker = picker,
                    SetColor    = function(_, color) picker.SetColor(_, color) end,
                    GetColor    = function() return picker.GetColor() end,
                }

                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddToggle(id, toggleOptions)
                toggleOptions = toggleOptions or {}
                toggleOptions.DefaultColor = toggleOptions.DefaultColor or Window.DefaultColor
                toggleOptions.TextColor    = toggleOptions.TextColor    or Window.TextColor

                local hasCP = toggleOptions.HasColorPicker
                local extraRight = hasCP and 28 or 0

                local ToggleFrame     = Instance.new("Frame")
                local ToggleButton    = Instance.new("TextButton")
                local ToggleIndicator = Instance.new("Frame")
                local ToggleIndicCorner = Instance.new("UICorner")
                local ToggleCheckmark = Instance.new("TextLabel")
                local ToggleText      = Instance.new("TextLabel")

                ToggleFrame.Name               = id .. "Toggle"
                ToggleFrame.Parent             = GroupboxContent
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size               = UDim2.new(1, 0, 0, 22)
                ToggleFrame.LayoutOrder        = #self.Elements + 1
                ToggleFrame.ClipsDescendants   = false

                ToggleButton.Name               = "Button"
                ToggleButton.Parent             = ToggleFrame
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size               = UDim2.new(1, -extraRight, 1, 0)
                ToggleButton.Text               = ""
                ToggleButton.AutoButtonColor    = false

                ToggleIndicator.Name             = "Indicator"
                ToggleIndicator.Parent           = ToggleFrame
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                ToggleIndicator.BorderSizePixel  = 0
                ToggleIndicator.Position         = UDim2.new(0, 0, 0.5, -8)
                ToggleIndicator.Size             = UDim2.new(0, 16, 0, 16)

                ToggleIndicCorner.CornerRadius = UDim.new(0, 4)
                ToggleIndicCorner.Parent       = ToggleIndicator

                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color     = Color3.fromRGB(60, 60, 60)
                ToggleStroke.Thickness = 1.5
                ToggleStroke.Parent    = ToggleIndicator

                ToggleCheckmark.Name               = "Checkmark"
                ToggleCheckmark.Parent             = ToggleIndicator
                ToggleCheckmark.BackgroundTransparency = 1
                ToggleCheckmark.Size               = UDim2.new(1, 0, 1, 0)
                ToggleCheckmark.Font               = Enum.Font.GothamBold
                ToggleCheckmark.Text               = "✓"
                ToggleCheckmark.TextColor3         = Color3.new(1, 1, 1)
                ToggleCheckmark.TextSize           = 12
                ToggleCheckmark.TextTransparency   = 1

                ToggleText.Name               = "Text"
                ToggleText.Parent             = ToggleFrame
                ToggleText.BackgroundTransparency = 1
                ToggleText.Position           = UDim2.new(0, 24, 0, 0)
                ToggleText.Size               = UDim2.new(1, -(24 + extraRight), 1, 0)
                ToggleText.Font               = Enum.Font.Gotham
                ToggleText.Text               = toggleOptions.Text or id
                ToggleText.TextColor3         = toggleOptions.TextColor
                ToggleText.TextSize           = 12
                ToggleText.TextXAlignment     = Enum.TextXAlignment.Left
                ToggleText.TextTruncate       = Enum.TextTruncate.AtEnd

                local toggled = toggleOptions.Default or false

                local function updateToggle()
                    if toggled then
                        smoothTween(ToggleIndicator, {BackgroundColor3 = toggleOptions.DefaultColor})
                        smoothTween(ToggleStroke,    {Color = toggleOptions.DefaultColor})
                        smoothTween(ToggleCheckmark, {TextTransparency = 0})
                    else
                        smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                        smoothTween(ToggleStroke,    {Color = Color3.fromRGB(60, 60, 60)})
                        smoothTween(ToggleCheckmark, {TextTransparency = 1})
                    end
                    if toggleOptions.Callback then toggleOptions.Callback(toggled) end
                end

                ToggleButton.MouseEnter:Connect(function()
                    if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end
                end)
                ToggleButton.MouseLeave:Connect(function()
                    if not toggled then smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}) end
                end)
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle()
                end)

                local colorPicker    = nil
                local extraColorPickers = {}
                local nextIconOffset = -28

                if hasCP then
                    colorPicker = createColorPickerIcon(ToggleFrame, nextIconOffset, toggleOptions.DefaultColor, toggleOptions.ColorCallback, player, id)
                    nextIconOffset = nextIconOffset - 24
                end

                updateToggle()

                local element = {
                    Type             = "Toggle",
                    Frame            = ToggleFrame,
                    ColorPicker      = colorPicker,
                    ExtraColorPickers = extraColorPickers,
                    SetValue = function(_, v) toggled = v; updateToggle() end,
                    GetValue = function() return toggled end,
                    SetColor = function(_, color) if colorPicker then colorPicker.SetColor(_, color) end end,
                    AddColorPickerIcon = function(_, pickerId, pickerOpts)
                        pickerOpts = pickerOpts or {}
                        local picker = createColorPickerIcon(ToggleFrame, nextIconOffset, pickerOpts.Default or Window.DefaultColor, pickerOpts.Callback, player, id .. "_" .. (pickerId or tostring(#extraColorPickers + 1)))
                        nextIconOffset = nextIconOffset - 24
                        table.insert(extraColorPickers, picker)
                        return picker
                    end,
                }

                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddSlider(id, sliderOptions)
                sliderOptions = sliderOptions or {}
                sliderOptions.DefaultColor = sliderOptions.DefaultColor or Window.DefaultColor
                sliderOptions.TextColor    = sliderOptions.TextColor    or Window.TextColor

                local SliderFrame        = Instance.new("Frame")
                local SliderText         = Instance.new("TextLabel")
                local SliderBackground   = Instance.new("Frame")
                local SliderBgCorner     = Instance.new("UICorner")
                local SliderFill         = Instance.new("Frame")
                local SliderFillCorner   = Instance.new("UICorner")
                local SliderButton       = Instance.new("TextButton")
                local ValueLabel         = Instance.new("TextLabel")

                SliderFrame.Name               = id .. "Slider"
                SliderFrame.Parent             = GroupboxContent
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size               = UDim2.new(1, 0, 0, 40)
                SliderFrame.LayoutOrder        = #self.Elements + 1

                SliderText.Name               = "Text"
                SliderText.Parent             = SliderFrame
                SliderText.BackgroundTransparency = 1
                SliderText.Position           = UDim2.new(0, 0, 0, 0)
                SliderText.Size               = UDim2.new(1, -50, 0, 20)
                SliderText.Font               = Enum.Font.Gotham
                SliderText.Text               = sliderOptions.Text or id
                SliderText.TextColor3         = sliderOptions.TextColor
                SliderText.TextSize           = 12
                SliderText.TextXAlignment     = Enum.TextXAlignment.Left

                SliderBackground.Name             = "Background"
                SliderBackground.Parent           = SliderFrame
                SliderBackground.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                SliderBackground.BorderSizePixel  = 0
                SliderBackground.Position         = UDim2.new(0, 0, 0, 24)
                SliderBackground.Size             = UDim2.new(1, -50, 0, 8)

                SliderBgCorner.CornerRadius = UDim.new(1, 0)
                SliderBgCorner.Parent       = SliderBackground

                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color     = Color3.fromRGB(45, 45, 45)
                SliderStroke.Thickness = 1
                SliderStroke.Parent    = SliderBackground

                SliderFill.Name             = "Fill"
                SliderFill.Parent           = SliderBackground
                SliderFill.BackgroundColor3 = sliderOptions.DefaultColor
                SliderFill.BorderSizePixel  = 0
                SliderFill.Size             = UDim2.new(0, 0, 1, 0)

                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent       = SliderFill

                SliderButton.Name               = "Button"
                SliderButton.Parent             = SliderBackground
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size               = UDim2.new(1, 0, 1, 0)
                SliderButton.Text               = ""
                SliderButton.AutoButtonColor    = false

                ValueLabel.Name               = "Value"
                ValueLabel.Parent             = SliderFrame
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position           = UDim2.new(1, -46, 0, 0)
                ValueLabel.Size               = UDim2.new(0, 44, 0, 20)
                ValueLabel.Font               = Enum.Font.GothamBold
                ValueLabel.TextColor3         = sliderOptions.DefaultColor
                ValueLabel.TextSize           = 11
                ValueLabel.TextXAlignment     = Enum.TextXAlignment.Right

                local sMin      = sliderOptions.Min     or 0
                local sMax      = sliderOptions.Max     or 100
                local sRounding = sliderOptions.Rounding or 1
                local sValue    = math.clamp(sliderOptions.Default or sMin, sMin, sMax)
                local sDragging = false

                local function roundValue(v)
                    if sRounding == 1 then return math.floor(v + 0.5)
                    elseif sRounding == 2 then return math.floor(v * 10 + 0.5) / 10
                    elseif sRounding == 3 then return math.floor(v * 100 + 0.5) / 100 end
                    return v
                end

                local function applySlider(input)
                    local pct = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    sValue = roundValue(sMin + (sMax - sMin) * pct)
                    smoothTween(SliderFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.06)
                    ValueLabel.Text = tostring(sValue)
                    if sliderOptions.Callback then sliderOptions.Callback(sValue) end
                end

                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = true; applySlider(input) end
                end)
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sDragging and input.UserInputType == Enum.UserInputType.MouseMovement then applySlider(input) end
                end)

                local initPct = (sValue - sMin) / (sMax - sMin)
                SliderFill.Size = UDim2.new(initPct, 0, 1, 0)
                ValueLabel.Text = tostring(sValue)

                local element = {
                    Type  = "Slider", Frame = SliderFrame,
                    SetValue = function(_, v)
                        sValue = roundValue(math.clamp(v, sMin, sMax))
                        local pct = (sValue - sMin) / (sMax - sMin)
                        smoothTween(SliderFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.15)
                        ValueLabel.Text = tostring(sValue)
                    end,
                    GetValue = function() return sValue end,
                }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddDropdown(id, dropOptions)
                dropOptions = dropOptions or {}
                dropOptions.DefaultColor = dropOptions.DefaultColor or Window.DefaultColor
                dropOptions.TextColor    = dropOptions.TextColor    or Window.TextColor
                dropOptions.Values       = dropOptions.Values       or {}

                local MAX_ROWS, ROW_H, LIST_PAD = 6, 22, 8

                local DropdownFrame  = Instance.new("Frame")
                local DropdownText   = Instance.new("TextLabel")
                local DropdownButton = Instance.new("TextButton")
                local DropdownBtnCorner = Instance.new("UICorner")
                local DropdownArrow  = Instance.new("TextLabel")
                local DropdownList   = Instance.new("ScrollingFrame")
                local DropdownListLayout = Instance.new("UIListLayout")
                local DropdownListCorner = Instance.new("UICorner")

                DropdownFrame.Name               = id .. "Dropdown"
                DropdownFrame.Parent             = GroupboxContent
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size               = UDim2.new(1, 0, 0, 44)
                DropdownFrame.LayoutOrder        = #self.Elements + 1
                DropdownFrame.ZIndex             = 2
                DropdownFrame.ClipsDescendants   = false

                DropdownText.Name               = "Text"
                DropdownText.Parent             = DropdownFrame
                DropdownText.BackgroundTransparency = 1
                DropdownText.Position           = UDim2.new(0, 0, 0, 0)
                DropdownText.Size               = UDim2.new(1, 0, 0, 20)
                DropdownText.Font               = Enum.Font.Gotham
                DropdownText.Text               = dropOptions.Text or id
                DropdownText.TextColor3         = dropOptions.TextColor
                DropdownText.TextSize           = 12
                DropdownText.TextXAlignment     = Enum.TextXAlignment.Left

                DropdownButton.Name               = "Button"
                DropdownButton.Parent             = DropdownFrame
                DropdownButton.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
                DropdownButton.BorderSizePixel    = 0
                DropdownButton.Position           = UDim2.new(0, 0, 0, 24)
                DropdownButton.Size               = UDim2.new(1, 0, 0, 20)
                DropdownButton.Font               = Enum.Font.Gotham
                DropdownButton.Text               = "  " .. (dropOptions.Default or dropOptions.Values[1] or "Select...")
                DropdownButton.TextColor3         = dropOptions.TextColor
                DropdownButton.TextSize           = 11
                DropdownButton.TextXAlignment     = Enum.TextXAlignment.Left
                DropdownButton.TextTruncate       = Enum.TextTruncate.AtEnd
                DropdownButton.ZIndex             = 2
                DropdownButton.AutoButtonColor    = false

                DropdownBtnCorner.CornerRadius = UDim.new(0, 4)
                DropdownBtnCorner.Parent       = DropdownButton

                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color     = Color3.fromRGB(50, 50, 50)
                DropdownStroke.Thickness = 1
                DropdownStroke.Parent    = DropdownButton

                DropdownArrow.Name               = "Arrow"
                DropdownArrow.Parent             = DropdownButton
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position           = UDim2.new(1, -20, 0, 0)
                DropdownArrow.Size               = UDim2.new(0, 20, 1, 0)
                DropdownArrow.Font               = Enum.Font.GothamBold
                DropdownArrow.Text               = "▼"
                DropdownArrow.TextColor3         = dropOptions.DefaultColor
                DropdownArrow.TextSize           = 10

                DropdownList.Name                = "List"
                DropdownList.Parent              = DropdownFrame
                DropdownList.BackgroundColor3    = Color3.fromRGB(25, 25, 25)
                DropdownList.BorderSizePixel     = 0
                DropdownList.Position            = UDim2.new(0, 0, 0, 45)
                DropdownList.Size                = UDim2.new(1, 0, 0, 0)
                DropdownList.Visible             = false
                DropdownList.ZIndex              = 50
                DropdownList.ClipsDescendants    = true
                DropdownList.ScrollBarThickness  = 3
                DropdownList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
                DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                DropdownList.ScrollingDirection  = Enum.ScrollingDirection.Y
                DropdownList.ElasticBehavior     = Enum.ElasticBehavior.Never

                DropdownListCorner.CornerRadius = UDim.new(0, 4)
                DropdownListCorner.Parent       = DropdownList

                local DLStroke = Instance.new("UIStroke")
                DLStroke.Color     = Color3.fromRGB(50, 50, 50)
                DLStroke.Thickness = 1
                DLStroke.Parent    = DropdownList

                DropdownListLayout.Parent    = DropdownList
                DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownListLayout.Padding   = UDim.new(0, 2)

                local _dlp = Instance.new("UIPadding")
                _dlp.Parent        = DropdownList
                _dlp.PaddingTop    = UDim.new(0, 4)
                _dlp.PaddingBottom = UDim.new(0, 4)
                _dlp.PaddingLeft   = UDim.new(0, 4)
                _dlp.PaddingRight  = UDim.new(0, 4)

                local isOpen       = false
                local selectedValue = dropOptions.Default or dropOptions.Values[1] or ""

                local function getOpenHeight()
                    local full = (#dropOptions.Values * ROW_H) + LIST_PAD
                    local cap  = (MAX_ROWS * ROW_H) + LIST_PAD
                    return math.min(full, cap)
                end

                local closeTask = nil
                local function setOpen(open)
                    isOpen = open
                    if closeTask then task.cancel(closeTask) closeTask = nil end

                    if open then
                        local listH = getOpenHeight()
                        DropdownList.Visible = true
                        smoothTween(DropdownList,  {Size = UDim2.new(1, 0, 0, listH)}, 0.15)
                        smoothTween(DropdownArrow, {Rotation = 180}, 0.15)
                        smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 44 + listH + 4)}, 0.15)
                    else
                        smoothTween(DropdownList,  {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        smoothTween(DropdownArrow, {Rotation = 0}, 0.15)
                        smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 44)}, 0.15)
                        closeTask = task.delay(0.16, function() DropdownList.Visible = false; closeTask = nil end)
                    end
                    self:UpdateSize()
                end

                local function buildOptions()
                    for _, child in ipairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for i, option in ipairs(dropOptions.Values) do
                        local Opt = Instance.new("TextButton")
                        local OptCorner = Instance.new("UICorner")

                        Opt.Name             = "Option" .. i
                        Opt.Parent           = DropdownList
                        Opt.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        Opt.BorderSizePixel  = 0
                        Opt.Size             = UDim2.new(1, 0, 0, 20)
                        Opt.Font             = Enum.Font.Gotham
                        Opt.Text             = "  " .. option
                        Opt.TextColor3       = dropOptions.TextColor
                        Opt.TextSize         = 11
                        Opt.TextXAlignment   = Enum.TextXAlignment.Left
                        Opt.ZIndex           = 51
                        Opt.AutoButtonColor  = false

                        OptCorner.CornerRadius = UDim.new(0, 3)
                        OptCorner.Parent       = Opt

                        Opt.MouseEnter:Connect(function() smoothTween(Opt, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}) end)
                        Opt.MouseLeave:Connect(function() smoothTween(Opt, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}) end)
                        Opt.MouseButton1Click:Connect(function()
                            selectedValue    = option
                            DropdownButton.Text = "  " .. option
                            setOpen(false)
                            if dropOptions.Callback then dropOptions.Callback(option) end
                        end)
                    end
                end
                buildOptions()

                DropdownButton.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
                DropdownButton.MouseEnter:Connect(function() smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}) end)
                DropdownButton.MouseLeave:Connect(function() smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}) end)

                local element = {
                    Type  = "Dropdown",
                    Frame = DropdownFrame,
                    SetValue = function(_, v) selectedValue = v; DropdownButton.Text = "  " .. v end,
                    GetValue = function() return selectedValue end,
                    Close    = function() if isOpen then setOpen(false) end end,
                    Refresh  = function(_, newValues, keepSelected)
                        if newValues then dropOptions.Values = newValues end
                        if not keepSelected then
                            selectedValue = dropOptions.Values[1] or ""
                            DropdownButton.Text = "  " .. selectedValue
                        end
                        buildOptions()
                        self:UpdateSize()
                    end
                }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddButton(id, btnOptions)
                btnOptions = btnOptions or {}
                btnOptions.DefaultColor = btnOptions.DefaultColor or Window.DefaultColor
                btnOptions.TextColor    = btnOptions.TextColor    or Window.TextColor

                local ButtonFrame  = Instance.new("Frame")
                local Button       = Instance.new("TextButton")
                local ButtonCorner = Instance.new("UICorner")

                ButtonFrame.Name               = id .. "Button"
                ButtonFrame.Parent             = GroupboxContent
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size               = UDim2.new(1, 0, 0, 28)
                ButtonFrame.LayoutOrder        = #self.Elements + 1

                Button.Name             = "Button"
                Button.Parent           = ButtonFrame
                Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Button.BorderSizePixel  = 0
                Button.Position         = UDim2.new(0, 0, 0, 0)
                Button.Size             = UDim2.new(1, 0, 1, 0)
                Button.Font             = Enum.Font.GothamSemibold
                Button.Text             = btnOptions.Text or id
                Button.TextColor3       = btnOptions.TextColor
                Button.TextSize         = 12
                Button.AutoButtonColor  = false

                ButtonCorner.CornerRadius = UDim.new(0, 5)
                ButtonCorner.Parent       = Button

                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Color     = Color3.fromRGB(55, 55, 55)
                ButtonStroke.Thickness = 1
                ButtonStroke.Parent    = Button

                Button.MouseEnter:Connect(function()
                    smoothTween(Button,       {BackgroundColor3 = Color3.fromRGB(42, 42, 42)})
                    smoothTween(ButtonStroke, {Color = btnOptions.DefaultColor}, 0.2)
                end)
                Button.MouseLeave:Connect(function()
                    smoothTween(Button,       {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                    smoothTween(ButtonStroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.2)
                end)
                Button.MouseButton1Click:Connect(function()
                    smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}, 0.05)
                    task.delay(0.12, function() smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.12) end)
                    if btnOptions.Callback then btnOptions.Callback() end
                end)

                local element = { Type = "Button", Frame = ButtonFrame, Button = Button }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddLabel(text, labelOptions)
                labelOptions = labelOptions or {}
                labelOptions.DefaultColor = labelOptions.DefaultColor or Window.DefaultColor
                labelOptions.TextColor    = labelOptions.TextColor    or Window.TextColor

                local LabelFrame = Instance.new("Frame")
                local Label      = Instance.new("TextLabel")

                LabelFrame.Name               = (text or "Label") .. "Label"
                LabelFrame.Parent             = GroupboxContent
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size               = UDim2.new(1, 0, 0, 20)
                LabelFrame.LayoutOrder        = #self.Elements + 1
                LabelFrame.ClipsDescendants   = false

                Label.Name               = "Label"
                Label.Parent             = LabelFrame
                Label.BackgroundTransparency = 1
                Label.Size               = UDim2.new(1, 0, 1, 0)
                Label.Font               = Enum.Font.Gotham
                Label.Text               = text or "Label"
                Label.TextColor3         = labelOptions.TextColor
                Label.TextSize           = 12
                Label.TextXAlignment     = Enum.TextXAlignment.Left

                if labelOptions.Center then Label.TextXAlignment = Enum.TextXAlignment.Center end

                local element = {
                    Type  = "Label", Frame = LabelFrame, Label = Label,
                    SetText = function(_, newText) Label.Text = newText end,
                    SetColor = function(_, color) if element.ColorPicker then element.ColorPicker.SetColor(_, color) end end,
                    AddColorPicker = function(elementSelf, pickerId, pickerOpts)
                        pickerOpts = pickerOpts or {}
                        local default = pickerOpts.Default or pickerOpts.DefaultColor or Window.DefaultColor
                        Label.Size = UDim2.new(1, -28, 1, 0)
                        local picker = createColorPickerIcon(LabelFrame, -4, default, pickerOpts.Callback or pickerOpts.ColorCallback, player, pickerId or (text or "Label"))
                        element.ColorPicker = picker
                        return picker
                    end,
                }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddTextBox(id, tbOptions)
                tbOptions = tbOptions or {}
                tbOptions.DefaultColor = tbOptions.DefaultColor or Window.DefaultColor
                tbOptions.TextColor    = tbOptions.TextColor    or Window.TextColor

                local TextBoxFrame  = Instance.new("Frame")
                local TextBox       = Instance.new("TextBox")
                local TextBoxCorner = Instance.new("UICorner")

                TextBoxFrame.Name               = id .. "TextBox"
                TextBoxFrame.Parent             = GroupboxContent
                TextBoxFrame.BackgroundTransparency = 1
                TextBoxFrame.Size               = UDim2.new(1, 0, 0, 42)
                TextBoxFrame.LayoutOrder        = #self.Elements + 1

                local TBLabel = Instance.new("TextLabel")
                TBLabel.Name               = "Label"
                TBLabel.Parent             = TextBoxFrame
                TBLabel.BackgroundTransparency = 1
                TBLabel.Position           = UDim2.new(0, 0, 0, 0)
                TBLabel.Size               = UDim2.new(1, 0, 0, 16)
                TBLabel.Font               = Enum.Font.Gotham
                TBLabel.Text               = tbOptions.Text or id
                TBLabel.TextColor3         = tbOptions.TextColor
                TBLabel.TextSize           = 12
                TBLabel.TextXAlignment     = Enum.TextXAlignment.Left

                TextBox.Name               = "TextBox"
                TextBox.Parent             = TextBoxFrame
                TextBox.BackgroundColor3   = Color3.fromRGB(28, 28, 28)
                TextBox.BorderSizePixel    = 0
                TextBox.Position           = UDim2.new(0, 0, 0, 20)
                TextBox.Size               = UDim2.new(1, 0, 0, 22)
                TextBox.Font               = Enum.Font.Gotham
                TextBox.PlaceholderText    = tbOptions.Placeholder or "Enter text..."
                TextBox.PlaceholderColor3  = Color3.fromRGB(110, 110, 110)
                TextBox.Text               = tbOptions.Default or ""
                TextBox.TextColor3         = tbOptions.TextColor
                TextBox.TextSize           = 11
                TextBox.ClearTextOnFocus   = tbOptions.ClearOnFocus or false

                TextBoxCorner.CornerRadius = UDim.new(0, 5)
                TextBoxCorner.Parent       = TextBox

                local TBStroke = Instance.new("UIStroke")
                TBStroke.Color     = Color3.fromRGB(50, 50, 50)
                TBStroke.Thickness = 1
                TBStroke.Parent    = TextBox

                local _tbp = Instance.new("UIPadding")
                _tbp.Parent       = TextBox
                _tbp.PaddingLeft  = UDim.new(0, 8)
                _tbp.PaddingRight = UDim.new(0, 8)

                TextBox.Focused:Connect(function() smoothTween(TBStroke, {Color = tbOptions.DefaultColor, Thickness = 1.5}, 0.15) end)
                TextBox.FocusLost:Connect(function()
                    smoothTween(TBStroke, {Color = Color3.fromRGB(50, 50, 50), Thickness = 1}, 0.15)
                    if tbOptions.Callback then tbOptions.Callback(TextBox.Text) end
                end)

                local element = {
                    Type = "TextBox", Frame = TextBoxFrame,
                    SetText = function(_, t) TextBox.Text = t end,
                    GetText = function() return TextBox.Text end,
                }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            function groupbox:AddKeyPicker(id, kpOptions)
                kpOptions = kpOptions or {}
                kpOptions.DefaultColor = kpOptions.DefaultColor or Window.DefaultColor
                kpOptions.TextColor    = kpOptions.TextColor    or Window.TextColor

                local keyNames = {
                    [Enum.KeyCode.LeftAlt] = "L-Alt", [Enum.KeyCode.RightAlt] = "R-Alt",
                    [Enum.KeyCode.LeftControl] = "L-Ctrl", [Enum.KeyCode.RightControl] = "R-Ctrl",
                    [Enum.KeyCode.LeftShift] = "L-Shift", [Enum.KeyCode.RightShift] = "R-Shift",
                    [Enum.KeyCode.Tab] = "Tab", [Enum.KeyCode.CapsLock] = "Caps",
                    [Enum.KeyCode.Backspace] = "Bksp", [Enum.KeyCode.Return] = "Enter",
                    [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.Delete] = "Del",
                    [Enum.KeyCode.Insert] = "Ins", [Enum.KeyCode.Home] = "Home",
                    [Enum.KeyCode.End] = "End", [Enum.KeyCode.PageUp] = "PgUp",
                    [Enum.KeyCode.PageDown] = "PgDn",
                    [Enum.KeyCode.F1]="F1",[Enum.KeyCode.F2]="F2",[Enum.KeyCode.F3]="F3",
                    [Enum.KeyCode.F4]="F4",[Enum.KeyCode.F5]="F5",[Enum.KeyCode.F6]="F6",
                    [Enum.KeyCode.F7]="F7",[Enum.KeyCode.F8]="F8",[Enum.KeyCode.F9]="F9",
                    [Enum.KeyCode.F10]="F10",[Enum.KeyCode.F11]="F11",[Enum.KeyCode.F12]="F12",
                }
                local function getKeyName(kc) return keyNames[kc] or tostring(kc):match("KeyCode%.(.+)") or "?" end

                local currentKey = kpOptions.Default or Enum.KeyCode.RightShift
                local listening  = false
                local inputConn  = nil

                local KPFrame    = Instance.new("Frame")
                local KPText     = Instance.new("TextLabel")
                local KPBtn      = Instance.new("TextButton")
                local KPBtnCorner = Instance.new("UICorner")
                local KPBtnStroke = Instance.new("UIStroke")
                local KPKeyLabel = Instance.new("TextLabel")
                local KPModeLabel = Instance.new("TextLabel")

                KPFrame.Name               = id .. "KeyPicker"
                KPFrame.Parent             = GroupboxContent
                KPFrame.BackgroundTransparency = 1
                KPFrame.Size               = UDim2.new(1, 0, 0, 42)
                KPFrame.LayoutOrder        = #self.Elements + 1

                KPText.Name               = "Text"
                KPText.Parent             = KPFrame
                KPText.BackgroundTransparency = 1
                KPText.Position           = UDim2.new(0, 0, 0, 0)
                KPText.Size               = UDim2.new(1, -72, 0, 18)
                KPText.Font               = Enum.Font.Gotham
                KPText.Text               = kpOptions.Text or id
                KPText.TextColor3         = kpOptions.TextColor
                KPText.TextSize           = 12
                KPText.TextXAlignment     = Enum.TextXAlignment.Left

                KPBtn.Name               = "KeyBtn"
                KPBtn.Parent             = KPFrame
                KPBtn.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
                KPBtn.BorderSizePixel    = 0
                KPBtn.AnchorPoint        = Vector2.new(1, 0)
                KPBtn.Position           = UDim2.new(1, 0, 0, 0)
                KPBtn.Size               = UDim2.new(0, 66, 0, 18)
                KPBtn.Text               = ""
                KPBtn.AutoButtonColor    = false
                KPBtn.ClipsDescendants   = true

                KPBtnCorner.CornerRadius = UDim.new(0, 4)
                KPBtnCorner.Parent       = KPBtn

                KPBtnStroke.Color     = Color3.fromRGB(50, 50, 50)
                KPBtnStroke.Thickness = 1
                KPBtnStroke.Parent    = KPBtn

                KPKeyLabel.Name               = "KeyLabel"
                KPKeyLabel.Parent             = KPBtn
                KPKeyLabel.BackgroundTransparency = 1
                KPKeyLabel.Size               = UDim2.new(1, 0, 1, 0)
                KPKeyLabel.Font               = Enum.Font.GothamBold
                KPKeyLabel.Text               = "[" .. getKeyName(currentKey) .. "]"
                KPKeyLabel.TextColor3         = kpOptions.DefaultColor
                KPKeyLabel.TextSize           = 11

                KPModeLabel.Name               = "ModeLabel"
                KPModeLabel.Parent             = KPFrame
                KPModeLabel.BackgroundTransparency = 1
                KPModeLabel.Position           = UDim2.new(0, 0, 0, 22)
                KPModeLabel.Size               = UDim2.new(1, 0, 0, 14)
                KPModeLabel.Font               = Enum.Font.Gotham
                KPModeLabel.TextSize           = 10
                KPModeLabel.TextXAlignment     = Enum.TextXAlignment.Left

                local modes     = {"Hold", "Toggle", "Always"}
                local modeIdx   = 1
                for i, m in ipairs(modes) do if m == kpOptions.Mode then modeIdx = i break end end
                local currentMode = modes[modeIdx]

                local function updateModeLabel()
                    KPModeLabel.Text      = "Mode: " .. currentMode
                    KPModeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                end
                updateModeLabel()

                local isActive  = false
                local keyDownConn = nil
                local keyUpConn   = nil
                local bindKeyActions

                local function stopListening()
                    if inputConn then inputConn:Disconnect(); inputConn = nil end
                    listening = false
                    KPKeyLabel.Text      = "[" .. getKeyName(currentKey) .. "]"
                    KPKeyLabel.TextColor3 = kpOptions.DefaultColor
                    smoothTween(KPBtnStroke, {Color = Color3.fromRGB(50, 50, 50)}, 0.15)
                    smoothTween(KPBtn,       {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.15)
                end

                local function startListening()
                    listening = true
                    KPKeyLabel.Text      = "..."
                    KPKeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    smoothTween(KPBtnStroke, {Color = kpOptions.DefaultColor}, 0.15)
                    smoothTween(KPBtn,       {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}, 0.15)

                    inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then stopListening(); return end
                            currentKey = input.KeyCode
                            stopListening()
                            if keyDownConn then keyDownConn:Disconnect() end
                            if keyUpConn   then keyUpConn:Disconnect()   end
                            bindKeyActions()
                        end
                    end)
                end

                bindKeyActions = function()
                    if currentMode == "Always" then
                        isActive = true
                        if kpOptions.Callback then kpOptions.Callback(true) end
                        return
                    end
                    keyDownConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.KeyCode ~= currentKey then return end
                        if currentMode == "Hold" then
                            isActive = true
                            if kpOptions.Callback then kpOptions.Callback(true) end
                        elseif currentMode == "Toggle" then
                            isActive = not isActive
                            if kpOptions.Callback then kpOptions.Callback(isActive) end
                        end
                    end)
                    if currentMode == "Hold" then
                        keyUpConn = UserInputService.InputEnded:Connect(function(input)
                            if input.KeyCode == currentKey then
                                isActive = false
                                if kpOptions.Callback then kpOptions.Callback(false) end
                            end
                        end)
                    end
                end
                bindKeyActions()

                KPBtn.MouseButton1Click:Connect(function() if listening then stopListening() else startListening() end end)
                KPBtn.MouseButton2Click:Connect(function()
                    modeIdx     = (modeIdx % #modes) + 1
                    currentMode = modes[modeIdx]
                    updateModeLabel()
                    if keyDownConn then keyDownConn:Disconnect() end
                    if keyUpConn   then keyUpConn:Disconnect()   end
                    isActive = false
                    bindKeyActions()
                end)
                KPBtn.MouseEnter:Connect(function() if not listening then smoothTween(KPBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}, 0.12) end end)
                KPBtn.MouseLeave:Connect(function() if not listening then smoothTween(KPBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.12) end end)

                local element = {
                    Type = "KeyPicker", Frame = KPFrame,
                    GetValue = function() return currentKey end,
                    IsActive = function() return isActive end,
                    GetMode  = function() return currentMode end,
                    SetKey   = function(_, kc)
                        currentKey = kc
                        KPKeyLabel.Text = "[" .. getKeyName(kc) .. "]"
                        if keyDownConn then keyDownConn:Disconnect() end
                        if keyUpConn   then keyUpConn:Disconnect()   end
                        bindKeyActions()
                    end,
                    SetValue = function(_, kc) self.SetKey(_, kc) end, -- Backward compatibility
                    SetMode  = function(_, mode)
                        for i, m in ipairs(modes) do if m == mode then modeIdx = i break end end
                        currentMode = modes[modeIdx]
                        updateModeLabel()
                        if keyDownConn then keyDownConn:Disconnect() end
                        if keyUpConn   then keyUpConn:Disconnect()   end
                        isActive = false
                        bindKeyActions()
                    end,
                }
                table.insert(self.Elements, element)
                self:UpdateSize()
                return element
            end

            table.insert(self.Groupboxes, groupbox)
            return groupbox
        end -- CreateGroupbox

        tabs[name] = tab

        if not currentTab then
            TabContent.Visible   = true
            TabHighlight.Visible = true
            TabButton.TextTransparency   = 0
            TabButton.BackgroundTransparency = 0.92
            currentTab       = tab
            Window.ActiveTab = tab
        end

        return tab
    end
    
    -- Backward compatibility for creating tabs
    function Window:CreateTab(name) return self:AddTab(name) end

    function Window:Destroy() ScreenGui:Destroy() end
    function Window:ToggleVisibility() ScreenGui.Enabled = not ScreenGui.Enabled end
    function Window:SetPosition(position) smoothTween(MainBackGround, {Position = position}, 0.3) end
    function Window:GetPosition() return MainBackGround.Position end
    function Window:SetSize(size)
        smoothTween(MainBackGround, {Size = size}, 0.3)
        TabHolder.Size    = UDim2.new(0, 130, 1, 0)
        ContentFrame.Size = UDim2.new(0, size.X.Offset - 148, 0, size.Y.Offset - 16)
    end
    function Window:GetSize() return MainBackGround.Size end

    return Window
end

return UILibrary
