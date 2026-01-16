local UILibrary = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Color conversion functions
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    local imod = i % 6
    if imod == 0 then
        r, g, b = v, t, p
    elseif imod == 1 then
        r, g, b = q, v, p
    elseif imod == 2 then
        r, g, b = p, v, t
    elseif imod == 3 then
        r, g, b = p, q, v
    elseif imod == 4 then
        r, g, b = t, p, v
    elseif imod == 5 then
        r, g, b = v, p, q
    end
    
    return r, g, b
end

local function RGBtoHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    
    local d = max - min
    s = max == 0 and 0 or d / max
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

-- Smooth tween function
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

-- Main UI creation function
function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    local Camera = workspace.CurrentCamera

    -- Default options
    local defaultOptions = {
        Name = "UI Library",
        ToggleKey = Enum.KeyCode.RightShift,
        DefaultColor = Color3.fromRGB(138, 102, 204),
        TextColor = Color3.fromRGB(220, 220, 220),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        TabHolderColor = Color3.fromRGB(15, 15, 15),
        GroupboxColor = Color3.fromRGB(22, 22, 22),
        Size = UDim2.new(0, 570, 0, 469),
        Position = UDim2.new(0.226, 0, 0.146, 0),
        Theme = "Dark",
        Watermark = true,
        WatermarkText = "UI Library v1.0.0"
    }
    
    for option, value in pairs(defaultOptions) do
        if options[option] == nil then
            options[option] = value
        end
    end

    -- Create main instances
    local ScreenGui = Instance.new("ScreenGui")
    local MainBackGround = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local MainStroke = Instance.new("UIStroke")
    local TabHolder = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    local ContentFrame = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")

    ScreenGui.Name = options.Name
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    MainBackGround.Name = "MainBackGround"
    MainBackGround.Parent = ScreenGui
    MainBackGround.BackgroundColor3 = options.BackgroundColor
    MainBackGround.BorderSizePixel = 0
    MainBackGround.Position = options.Position
    MainBackGround.Size = options.Size
    MainBackGround.ClipsDescendants = true
    
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainBackGround
    
    MainStroke.Color = Color3.fromRGB(45, 45, 45)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainBackGround

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = MainBackGround
    TabHolder.BackgroundColor3 = options.TabHolderColor
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 0, 0, 0)
    TabHolder.Size = UDim2.new(0, 130, 0, options.Size.Y.Offset)
    
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
    ContentFrame.Size = UDim2.new(0, options.Size.X.Offset - 148, 0, options.Size.Y.Offset - 20)
    
    UICorner_3.CornerRadius = UDim.new(0, 6)
    UICorner_3.Parent = ContentFrame

    -- Watermark
    if options.Watermark then
        local Watermark = Instance.new("TextLabel")
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
    end

    -- Tab Management
    local tabs = {}
    local currentTab = nil

    -- Window object
    local Window = {}
    Window.ActiveTab = nil
    Window.Theme = options.Theme
    Window.DefaultColor = options.DefaultColor
    Window.TextColor = options.TextColor

    -- Set up toggle key functionality
    local function handleInput(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == options.ToggleKey then
            Window:ToggleVisibility()
        end
    end

    UserInputService.InputBegan:Connect(handleInput)

    function Window:AddTab(name)
        local TabButton = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabHighlight = Instance.new("Frame")
        local TabCorner = Instance.new("UICorner")
        
        -- Create Left Container
        local LeftContainer = Instance.new("Frame")
        local LeftLayout = Instance.new("UIListLayout")
        
        -- Create Right Container
        local RightContainer = Instance.new("Frame")
        local RightLayout = Instance.new("UIListLayout")

        -- Tab Button
        TabButton.Name = name .. "Tab"
        TabButton.Parent = TabHolder
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
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
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.Parent = TabButton
        TabPadding.PaddingLeft = UDim.new(0, 12)

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

        -- Tab Content
        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = options.DefaultColor
        TabContent.Visible = false
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y

        -- Left Container Setup
        LeftContainer.Name = "LeftContainer"
        LeftContainer.Parent = TabContent
        LeftContainer.BackgroundTransparency = 1
        LeftContainer.Position = UDim2.new(0, 10, 0, 10)
        LeftContainer.Size = UDim2.new(0.5, -15, 1, -20)
        
        LeftLayout.Parent = LeftContainer
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 12)
        LeftLayout.FillDirection = Enum.FillDirection.Vertical
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Top

        -- Right Container Setup
        RightContainer.Name = "RightContainer"
        RightContainer.Parent = TabContent
        RightContainer.BackgroundTransparency = 1
        RightContainer.Position = UDim2.new(0.5, 5, 0, 10)
        RightContainer.Size = UDim2.new(0.5, -15, 1, -20)
        
        RightLayout.Parent = RightContainer
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 12)
        RightLayout.FillDirection = Enum.FillDirection.Vertical
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        RightLayout.VerticalAlignment = Enum.VerticalAlignment.Top

        -- Function to update content size
        local function updateContentSize()
            local leftHeight = LeftLayout.AbsoluteContentSize.Y + 30
            local rightHeight = RightLayout.AbsoluteContentSize.Y + 30
            local maxHeight = math.max(leftHeight, rightHeight)
            TabContent.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
        end

        -- Update content size when layouts change
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)

        -- Tab Object
        local tab = {
            Button = TabButton,
            Content = TabContent,
            Highlight = TabHighlight,
            LeftContainer = LeftContainer,
            RightContainer = RightContainer,
            Groupboxes = {},
            AddLeftGroupbox = function(self, name)
                return self:CreateGroupbox(name, "Left")
            end,
            AddRightGroupbox = function(self, name)
                return self:CreateGroupbox(name, "Right")
            end,
            CreateGroupbox = function(self, name, side)
                local GroupboxFrame = Instance.new("Frame")
                local GroupboxCorner = Instance.new("UICorner")
                local GroupboxStroke = Instance.new("UIStroke")
                local GroupboxTitle = Instance.new("TextLabel")
                local GroupboxContent = Instance.new("Frame")
                local GroupboxLayout = Instance.new("UIListLayout")

                GroupboxFrame.Name = name .. "Groupbox"
                GroupboxFrame.BackgroundColor3 = options.GroupboxColor
                GroupboxFrame.BorderSizePixel = 0
                GroupboxFrame.Size = UDim2.new(1, 0, 0, 40)
                GroupboxFrame.LayoutOrder = #self.Groupboxes + 1

                -- Parent to correct container
                if side == "Left" then
                    GroupboxFrame.Parent = LeftContainer
                else
                    GroupboxFrame.Parent = RightContainer
                end

                GroupboxCorner.CornerRadius = UDim.new(0, 6)
                GroupboxCorner.Parent = GroupboxFrame
                
                GroupboxStroke.Color = Color3.fromRGB(35, 35, 35)
                GroupboxStroke.Thickness = 1
                GroupboxStroke.Parent = GroupboxFrame

                GroupboxTitle.Name = "Title"
                GroupboxTitle.Parent = GroupboxFrame
                GroupboxTitle.BackgroundTransparency = 1
                GroupboxTitle.Position = UDim2.new(0, 12, 0, 8)
                GroupboxTitle.Size = UDim2.new(1, -24, 0, 20)
                GroupboxTitle.Font = Enum.Font.GothamBold
                GroupboxTitle.Text = name
                GroupboxTitle.TextColor3 = options.DefaultColor
                GroupboxTitle.TextSize = 13
                GroupboxTitle.TextXAlignment = Enum.TextXAlignment.Left

                GroupboxContent.Name = "Content"
                GroupboxContent.Parent = GroupboxFrame
                GroupboxContent.BackgroundTransparency = 1
                GroupboxContent.Position = UDim2.new(0, 12, 0, 35)
                GroupboxContent.Size = UDim2.new(1, -24, 1, -40)

                GroupboxLayout.Parent = GroupboxContent
                GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
                GroupboxLayout.Padding = UDim.new(0, 8)

                local groupbox = {
                    Frame = GroupboxFrame,
                    Content = GroupboxContent,
                    Layout = GroupboxLayout,
                    Side = side,
                    Elements = {},
                    AddToggle = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local ToggleFrame = Instance.new("Frame")
                        local ToggleButton = Instance.new("TextButton")
                        local ToggleIndicator = Instance.new("Frame")
                        local ToggleIndicatorCorner = Instance.new("UICorner")
                        local ToggleCheckmark = Instance.new("TextLabel")
                        local ToggleText = Instance.new("TextLabel")
                        
                        -- Add color picker icon if specified
                        local ColorIcon = nil
                        if options.HasColorPicker then
                            ColorIcon = Instance.new("TextButton")
                            ColorIcon.Name = "ColorIcon"
                            ColorIcon.Parent = ToggleFrame
                            ColorIcon.BackgroundColor3 = options.DefaultColor or Window.DefaultColor
                            ColorIcon.AnchorPoint = Vector2.new(1, 0.5)
                            ColorIcon.Position = UDim2.new(1, 0, 0.5, 0)
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
                            
                            -- Hover effect
                            ColorIcon.MouseEnter:Connect(function()
                                smoothTween(colorStroke, {Thickness = 2})
                                smoothTween(ColorIcon, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
                            end)
                            ColorIcon.MouseLeave:Connect(function()
                                smoothTween(colorStroke, {Thickness = 1.5})
                                smoothTween(ColorIcon, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
                            end)
                        end
                    
                        ToggleFrame.Name = id .. "Toggle"
                        ToggleFrame.Parent = GroupboxContent
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
                        ToggleFrame.LayoutOrder = #self.Elements + 1
                    
                        ToggleButton.Name = "Button"
                        ToggleButton.Parent = ToggleFrame
                        ToggleButton.BackgroundTransparency = 1
                        ToggleButton.Size = UDim2.new(1, options.HasColorPicker and -28 or 0, 1, 0)
                        ToggleButton.Text = ""
                        ToggleButton.AutoButtonColor = false
                    
                        ToggleIndicator.Name = "Indicator"
                        ToggleIndicator.Parent = ToggleFrame
                        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        ToggleIndicator.BorderSizePixel = 0
                        ToggleIndicator.Position = UDim2.new(0, 0, 0.5, -8)
                        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                    
                        ToggleIndicatorCorner.CornerRadius = UDim.new(0, 4)
                        ToggleIndicatorCorner.Parent = ToggleIndicator
                        
                        local ToggleStroke = Instance.new("UIStroke")
                        ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
                        ToggleStroke.Thickness = 1.5
                        ToggleStroke.Parent = ToggleIndicator
                        
                        ToggleCheckmark.Name = "Checkmark"
                        ToggleCheckmark.Parent = ToggleIndicator
                        ToggleCheckmark.BackgroundTransparency = 1
                        ToggleCheckmark.Size = UDim2.new(1, 0, 1, 0)
                        ToggleCheckmark.Font = Enum.Font.GothamBold
                        ToggleCheckmark.Text = "✓"
                        ToggleCheckmark.TextColor3 = Color3.new(1, 1, 1)
                        ToggleCheckmark.TextSize = 12
                        ToggleCheckmark.TextTransparency = 1
                    
                        ToggleText.Name = "Text"
                        ToggleText.Parent = ToggleFrame
                        ToggleText.BackgroundTransparency = 1
                        ToggleText.Position = UDim2.new(0, 24, 0, 0)
                        ToggleText.Size = UDim2.new(1, options.HasColorPicker and -52 or -24, 1, 0)
                        ToggleText.Font = Enum.Font.Gotham
                        ToggleText.Text = options.Text or id
                        ToggleText.TextColor3 = options.TextColor
                        ToggleText.TextSize = 12
                        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                        ToggleText.TextTruncate = Enum.TextTruncate.AtEnd
                    
                        local toggled = options.Default or false
                    
                        local function updateToggle()
                            if toggled then
                                smoothTween(ToggleIndicator, {BackgroundColor3 = options.DefaultColor})
                                smoothTween(ToggleStroke, {Color = options.DefaultColor})
                                smoothTween(ToggleCheckmark, {TextTransparency = 0})
                            else
                                smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                                smoothTween(ToggleStroke, {Color = Color3.fromRGB(60, 60, 60)})
                                smoothTween(ToggleCheckmark, {TextTransparency = 1})
                            end
                            
                            if options.Callback then
                                options.Callback(toggled)
                            end
                        end
                        
                        -- Hover effect
                        ToggleButton.MouseEnter:Connect(function()
                            if not toggled then
                                smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
                            end
                        end)
                        
                        ToggleButton.MouseLeave:Connect(function()
                            if not toggled then
                                smoothTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                            end
                        end)
                    
                        ToggleButton.MouseButton1Click:Connect(function()
                            toggled = not toggled
                            updateToggle()
                        end)
                    
                        -- Color picker implementation (fixed version)
-- This replaces the section starting from "local colorPicker = nil" in your AddToggle function

local colorPicker = nil
if options.HasColorPicker then
    -- Create dedicated ScreenGui for color picker
    local colorPickerScreenGui = Instance.new("ScreenGui")
    colorPickerScreenGui.Name = "ColorPickerGui_" .. id
    colorPickerScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    colorPickerScreenGui.ResetOnSpawn = false
    colorPickerScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    colorPickerScreenGui.DisplayOrder = 999
    
    -- Create main color picker window
    local colorPickerWindow = Instance.new("Frame")
    colorPickerWindow.Name = "ColorPickerWindow"
    colorPickerWindow.Parent = colorPickerScreenGui
    colorPickerWindow.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    colorPickerWindow.BorderSizePixel = 0
    colorPickerWindow.Position = UDim2.new(0.5, -125, 0.5, -100)
    colorPickerWindow.Size = UDim2.new(0, 250, 0, 200)
    colorPickerWindow.Visible = false
    colorPickerWindow.ZIndex = 100
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 8)
    windowCorner.Parent = colorPickerWindow
    
    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = Color3.fromRGB(0, 0, 0)
    windowStroke.LineJoinMode = Enum.LineJoinMode.Miter
    windowStroke.Thickness = 1.5
    windowStroke.Parent = colorPickerWindow
    
    -- Header bar (FIXED)
    local headerBar = Instance.new("Frame")
    headerBar.Name = "HeaderBar"
    headerBar.Size = UDim2.new(1, 0, 0, 8)
    headerBar.Position = UDim2.new(0, 0, 0, 0)
    headerBar.Parent = colorPickerWindow  -- FIXED: was "Parnet"
    headerBar.BackgroundColor3 = options.DefaultColor  -- FIXED: was "DefaultColor"
    headerBar.BorderSizePixel = 0
    headerBar.ZIndex = 101
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerBar
    
    -- Content frame for color picker
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = "ColorPickerFrame"
    colorPickerFrame.Parent = colorPickerWindow
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Position = UDim2.new(0, 15, 0, 15)
    colorPickerFrame.Size = UDim2.new(1, -30, 1, -30)
    colorPickerFrame.ZIndex = 101
    
    -- Saturation/Value box
    local saturationValueBox = Instance.new("Frame")
    saturationValueBox.Name = "SaturationValueBox"
    saturationValueBox.Parent = colorPickerFrame
    saturationValueBox.BackgroundColor3 = Color3.new(1, 0, 0)
    saturationValueBox.BorderSizePixel = 0
    saturationValueBox.Position = UDim2.new(0, 0, 0, 0)
    saturationValueBox.Size = UDim2.new(0, 180, 0, 150)
    saturationValueBox.ZIndex = 101
    
    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 6)
    svCorner.Parent = saturationValueBox
    
    local svStroke = Instance.new("UIStroke")
    svStroke.Color = Color3.fromRGB(60, 60, 60)
    svStroke.Thickness = 1
    svStroke.Parent = saturationValueBox
    
    -- Create overlay frame for saturation gradient
    local svOverlay = Instance.new("Frame")
    svOverlay.Name = "SVOverlay"
    svOverlay.Parent = saturationValueBox
    svOverlay.BackgroundTransparency = 0
    svOverlay.Size = UDim2.new(1, 0, 1, 0)
    svOverlay.ZIndex = 102
    
    local svOverlayCorner = Instance.new("UICorner")
    svOverlayCorner.CornerRadius = UDim.new(0, 6)
    svOverlayCorner.Parent = svOverlay
    
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
    
    -- Create second overlay for value gradient
    local svOverlay2 = Instance.new("Frame")
    svOverlay2.Name = "SVOverlay2"
    svOverlay2.Parent = saturationValueBox
    svOverlay2.BackgroundTransparency = 0
    svOverlay2.BackgroundColor3 = Color3.new(0, 0, 0)
    svOverlay2.Size = UDim2.new(1, 0, 1, 0)
    svOverlay2.ZIndex = 103
    
    local svOverlay2Corner = Instance.new("UICorner")
    svOverlay2Corner.CornerRadius = UDim.new(0, 6)
    svOverlay2Corner.Parent = svOverlay2
    
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

    -- Hue slider
    local hueSlider = Instance.new("Frame")
    hueSlider.Name = "HueSlider"
    hueSlider.Parent = colorPickerFrame
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel = 0
    hueSlider.Position = UDim2.new(0, 195, 0, 0)
    hueSlider.Size = UDim2.new(0, 25, 0, 150)
    hueSlider.ZIndex = 101
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueSlider
    
    local hueStroke = Instance.new("UIStroke")
    hueStroke.Color = Color3.fromRGB(60, 60, 60)
    hueStroke.Thickness = 1
    hueStroke.Parent = hueSlider
    
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
    
    -- Color picker logic
    local currentColor = options.DefaultColor or Color3.new(1, 1, 1)
    local hue = 0
    local saturation = 0
    local value = 1
    local updating = false
    
    -- Update all UI elements
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
        
        if ColorIcon then
            smoothTween(ColorIcon, {BackgroundColor3 = currentColor}, 0.15)
        end
        
        updating = false
        
        if options.ColorCallback then
            options.ColorCallback(currentColor)
        end
    end
    
    local function updateFromRGB(color)
        if updating then return end
        hue, saturation, value = RGBtoHSV(color.r, color.g, color.b)
        updateColor()
    end
    
    -- Dragging logic
    local hueDragging = false
    local svDragging = false
    
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
    
    UserInputService.InputChanged:Connect(function(input)
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
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            svDragging = false
        end
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
    
    -- Initialize with default color
    if options.DefaultColor then
        updateFromRGB(options.DefaultColor)
    else
        updateColor()
    end
    
    -- Color icon click handler
    if ColorIcon then
        ColorIcon.MouseButton1Click:Connect(function()
            colorPickerWindow.Visible = not colorPickerWindow.Visible
        end)
    end
    
    -- Close when clicking outside
    local clickOutsideConnection
    clickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorPickerWindow.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local windowPos = colorPickerWindow.AbsolutePosition
            local windowSize = colorPickerWindow.AbsoluteSize
            
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            mousePos = Vector2.new(mousePos.X, mousePos.Y - guiInset.Y)
            
            if mousePos.X < windowPos.X or mousePos.X > windowPos.X + windowSize.X or
               mousePos.Y < windowPos.Y or mousePos.Y > windowPos.Y + windowSize.Y then
                colorPickerWindow.Visible = false
            end
        end
    end)
    
    colorPicker = {
        ScreenGui = colorPickerScreenGui,
        Window = colorPickerWindow,
        SetColor = function(color)
            updateFromRGB(color)
        end,
        GetColor = function()
            return currentColor
        end,
        Show = function()
            colorPickerWindow.Visible = true
        end,
        Hide = function()
            colorPickerWindow.Visible = false
        end,
        Destroy = function()
            if clickOutsideConnection then
                clickOutsideConnection:Disconnect()
            end
            colorPickerScreenGui:Destroy()
        end
    }
end,
                    AddSlider = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local SliderFrame = Instance.new("Frame")
                        local SliderText = Instance.new("TextLabel")
                        local SliderBackground = Instance.new("Frame")
                        local SliderBackgroundCorner = Instance.new("UICorner")
                        local SliderFill = Instance.new("Frame")
                        local SliderFillCorner = Instance.new("UICorner")
                        local SliderButton = Instance.new("TextButton")
                        local ValueLabel = Instance.new("TextLabel")

                        SliderFrame.Name = id .. "Slider"
                        SliderFrame.Parent = GroupboxContent
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Size = UDim2.new(1.2, 0, 0, 40)
                        SliderFrame.LayoutOrder = #self.Elements + 1

                        SliderText.Name = "Text"
                        SliderText.Parent = SliderFrame
                        SliderText.BackgroundTransparency = 1
                        SliderText.Position = UDim2.new(0, 0, 0, 0)
                        SliderText.Size = UDim2.new(1, -35, 0, 20)
                        SliderText.Font = Enum.Font.Gotham
                        SliderText.Text = options.Text or id
                        SliderText.TextColor3 = options.TextColor
                        SliderText.TextSize = 12
                        SliderText.TextXAlignment = Enum.TextXAlignment.Left

                        SliderBackground.Name = "Background"
                        SliderBackground.Parent = SliderFrame
                        SliderBackground.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                        SliderBackground.BorderSizePixel = 0
                        SliderBackground.Position = UDim2.new(0, 0, 0, 24)
                        SliderBackground.Size = UDim2.new(1, -35, 0, 8)

                        SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
                        SliderBackgroundCorner.Parent = SliderBackground
                        
                        local SliderStroke = Instance.new("UIStroke")
                        SliderStroke.Color = Color3.fromRGB(50, 50, 50)
                        SliderStroke.Thickness = 1
                        SliderStroke.Parent = SliderBackground

                        SliderFill.Name = "Fill"
                        SliderFill.Parent = SliderBackground
                        SliderFill.BackgroundColor3 = options.DefaultColor
                        SliderFill.BorderSizePixel = 0
                        SliderFill.Size = UDim2.new(0, 0, 1, 0)

                        SliderFillCorner.CornerRadius = UDim.new(1, 0)
                        SliderFillCorner.Parent = SliderFill

                        SliderButton.Name = "Button"
                        SliderButton.Parent = SliderBackground
                        SliderButton.BackgroundTransparency = 1
                        SliderButton.Size = UDim2.new(1, 0, 1, 0)
                        SliderButton.Text = ""
                        SliderButton.AutoButtonColor = false

                        ValueLabel.Name = "Value"
                        ValueLabel.Parent = SliderFrame
                        ValueLabel.BackgroundTransparency = 1
                        ValueLabel.Position = UDim2.new(1, -60, 0, 0)
                        ValueLabel.Size = UDim2.new(0, 30, 0, 20)
                        ValueLabel.Font = Enum.Font.GothamBold
                        ValueLabel.Text = tostring(options.Default or options.Min or 0)
                        ValueLabel.TextColor3 = options.DefaultColor
                        ValueLabel.TextSize = 11
                        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

                        local min = options.Min or 0
                        local max = options.Max or 100
                        local rounding = options.Rounding or 1
                        local value = options.Default or min
                        local dragging = false

                        local function updateSlider(input)
                            local sizeX = math.max(0, math.min(1, (input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X))
                            value = min + (max - min) * sizeX

                            if rounding == 1 then
                                value = math.floor(value)
                            elseif rounding == 2 then
                                value = math.floor(value * 10) / 10
                            elseif rounding == 3 then
                                value = math.floor(value * 100) / 100
                            end

                            smoothTween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.1)
                            ValueLabel.Text = tostring(value)
                            
                            if options.Callback then
                                options.Callback(value)
                            end
                        end

                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true
                                updateSlider(input)
                            end
                        end)

                        SliderButton.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                            end
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                updateSlider(input)
                            end
                        end)

                        local initialPercent = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
                        ValueLabel.Text = tostring(value)

                        local element = {
                            Type = "Slider",
                            Frame = SliderFrame,
                            SetValue = function(newValue)
                                value = math.max(min, math.min(max, newValue))
                                local percent = (value - min) / (max - min)
                                smoothTween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15)
                                ValueLabel.Text = tostring(value)
                            end,
                            GetValue = function()
                                return value
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddDropdown = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local DropdownFrame = Instance.new("Frame")
                        local DropdownText = Instance.new("TextLabel")
                        local DropdownButton = Instance.new("TextButton")
                        local DropdownButtonCorner = Instance.new("UICorner")
                        local DropdownArrow = Instance.new("TextLabel")
                        local DropdownList = Instance.new("Frame")
                        local DropdownListLayout = Instance.new("UIListLayout")
                        local DropdownListCorner = Instance.new("UICorner")

                        DropdownFrame.Name = id .. "Dropdown"
                        DropdownFrame.Parent = GroupboxContent
                        DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 44)
                        DropdownFrame.LayoutOrder = #self.Elements + 1
                        DropdownFrame.ZIndex = 2

                        DropdownText.Name = "Text"
                        DropdownText.Parent = DropdownFrame
                        DropdownText.BackgroundTransparency = 1
                        DropdownText.Position = UDim2.new(0, 0, 0, 0)
                        DropdownText.Size = UDim2.new(1, 0, 0, 20)
                        DropdownText.Font = Enum.Font.Gotham
                        DropdownText.Text = options.Text or id
                        DropdownText.TextColor3 = options.TextColor
                        DropdownText.TextSize = 12
                        DropdownText.TextXAlignment = Enum.TextXAlignment.Left

                        DropdownButton.Name = "Button"
                        DropdownButton.Parent = DropdownFrame
                        DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        DropdownButton.BorderSizePixel = 0
                        DropdownButton.Position = UDim2.new(0, 0, 0, 24)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 20)
                        DropdownButton.Font = Enum.Font.Gotham
                        DropdownButton.Text = "  " .. (options.Values[1] or "Select...")
                        DropdownButton.TextColor3 = options.TextColor
                        DropdownButton.TextSize = 11
                        DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                        DropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
                        DropdownButton.ZIndex = 2
                        DropdownButton.AutoButtonColor = false

                        DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                        DropdownButtonCorner.Parent = DropdownButton
                        
                        local DropdownStroke = Instance.new("UIStroke")
                        DropdownStroke.Color = Color3.fromRGB(55, 55, 55)
                        DropdownStroke.Thickness = 1
                        DropdownStroke.Parent = DropdownButton

                        DropdownArrow.Name = "Arrow"
                        DropdownArrow.Parent = DropdownButton
                        DropdownArrow.BackgroundTransparency = 1
                        DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
                        DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                        DropdownArrow.Font = Enum.Font.GothamBold
                        DropdownArrow.Text = "▼"
                        DropdownArrow.TextColor3 = options.DefaultColor
                        DropdownArrow.TextSize = 10

                        DropdownList.Name = "List"
                        DropdownList.Parent = DropdownFrame
                        DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        DropdownList.BorderSizePixel = 0
                        DropdownList.Position = UDim2.new(0, 0, 0, 45)
                        DropdownList.Size = UDim2.new(1, 0, 0, 0)
                        DropdownList.Visible = false
                        DropdownList.ZIndex = 10
                        DropdownList.ClipsDescendants = true

                        DropdownListCorner.CornerRadius = UDim.new(0, 4)
                        DropdownListCorner.Parent = DropdownList
                        
                        local DropdownListStroke = Instance.new("UIStroke")
                        DropdownListStroke.Color = Color3.fromRGB(55, 55, 55)
                        DropdownListStroke.Thickness = 1
                        DropdownListStroke.Parent = DropdownList

                        DropdownListLayout.Parent = DropdownList
                        DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        DropdownListLayout.Padding = UDim.new(0, 2)
                        
                        local DropdownPadding = Instance.new("UIPadding")
                        DropdownPadding.Parent = DropdownList
                        DropdownPadding.PaddingTop = UDim.new(0, 4)
                        DropdownPadding.PaddingBottom = UDim.new(0, 4)
                        DropdownPadding.PaddingLeft = UDim.new(0, 4)
                        DropdownPadding.PaddingRight = UDim.new(0, 4)

                        local isOpen = false
                        local selectedValue = options.Values[1] or ""

                        for i, option in ipairs(options.Values) do
                            local OptionButton = Instance.new("TextButton")
                            local OptionButtonCorner = Instance.new("UICorner")

                            OptionButton.Name = "Option" .. i
                            OptionButton.Parent = DropdownList
                            OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            OptionButton.BorderSizePixel = 0
                            OptionButton.Size = UDim2.new(1, 0, 0, 20)
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.Text = "  " .. option
                            OptionButton.TextColor3 = options.TextColor
                            OptionButton.TextSize = 11
                            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                            OptionButton.ZIndex = 11
                            OptionButton.AutoButtonColor = false

                            OptionButtonCorner.CornerRadius = UDim.new(0, 3)
                            OptionButtonCorner.Parent = OptionButton

                            OptionButton.MouseEnter:Connect(function()
                                smoothTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
                            end)

                            OptionButton.MouseLeave:Connect(function()
                                smoothTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                            end)

                            OptionButton.MouseButton1Click:Connect(function()
                                selectedValue = option
                                DropdownButton.Text = "  " .. option
                                
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                                task.wait(0.15)
                                DropdownList.Visible = false
                                isOpen = false
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.15)
                                
                                if options.Callback then
                                    options.Callback(option)
                                end
                            end)
                        end

                        DropdownButton.MouseButton1Click:Connect(function()
                            isOpen = not isOpen
                            if isOpen then
                                DropdownList.Visible = true
                                local targetHeight = (#options.Values * 22) + 8
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.15)
                                smoothTween(DropdownArrow, {Rotation = 180}, 0.15)
                            else
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.15)
                                task.wait(0.15)
                                DropdownList.Visible = false
                            end
                        end)
                        
                        -- Hover effect
                        DropdownButton.MouseEnter:Connect(function()
                            smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                        end)
                        
                        DropdownButton.MouseLeave:Connect(function()
                            smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                        end)

                        if options.Default then
                            selectedValue = options.Default
                            DropdownButton.Text = "  " .. options.Default
                        end

                        local element = {
                            Type = "Dropdown",
                            Frame = DropdownFrame,
                            SetValue = function(value)
                                selectedValue = value
                                DropdownButton.Text = "  " .. value
                            end,
                            GetValue = function()
                                return selectedValue
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddButton = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local ButtonFrame = Instance.new("Frame")
                        local Button = Instance.new("TextButton")
                        local ButtonCorner = Instance.new("UICorner")

                        ButtonFrame.Name = id .. "Button"
                        ButtonFrame.Parent = GroupboxContent
                        ButtonFrame.BackgroundTransparency = 1
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                        ButtonFrame.LayoutOrder = #self.Elements + 1

                        Button.Name = "Button"
                        Button.Parent = ButtonFrame
                        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        Button.BorderSizePixel = 0
                        Button.Position = UDim2.new(0, 0, 0, 0)
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.Font = Enum.Font.GothamSemibold
                        Button.Text = options.Text or id
                        Button.TextColor3 = options.TextColor
                        Button.TextSize = 12
                        Button.AutoButtonColor = false

                        ButtonCorner.CornerRadius = UDim.new(0, 5)
                        ButtonCorner.Parent = Button
                        
                        local ButtonStroke = Instance.new("UIStroke")
                        ButtonStroke.Color = Color3.fromRGB(60, 60, 60)
                        ButtonStroke.Thickness = 1
                        ButtonStroke.Parent = Button

                        Button.MouseEnter:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
                            smoothTween(ButtonStroke, {Color = options.DefaultColor}, 0.2)
                        end)

                        Button.MouseLeave:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                            smoothTween(ButtonStroke, {Color = Color3.fromRGB(60, 60, 60)}, 0.2)
                        end)

                        Button.MouseButton1Click:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}, 0.05)
                            task.wait(0.05)
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.1)
                            
                            if options.Callback then
                                options.Callback()
                            end
                        end)

                        local element = {
                            Type = "Button",
                            Frame = ButtonFrame,
                            Button = Button
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddLabel = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local LabelFrame = Instance.new("Frame")
                        local Label = Instance.new("TextLabel")

                        LabelFrame.Name = id .. "Label"
                        LabelFrame.Parent = GroupboxContent
                        LabelFrame.BackgroundTransparency = 1
                        LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                        LabelFrame.LayoutOrder = #self.Elements + 1

                        Label.Name = "Label"
                        Label.Parent = LabelFrame
                        Label.BackgroundTransparency = 1
                        Label.Size = UDim2.new(1, 0, 1, 0)
                        Label.Font = Enum.Font.Gotham
                        Label.Text = options.Text or id
                        Label.TextColor3 = options.TextColor
                        Label.TextSize = 12
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        if options.Center then
                            Label.TextXAlignment = Enum.TextXAlignment.Center
                        end

                        local element = {
                            Type = "Label",
                            Frame = LabelFrame,
                            SetText = function(text)
                                Label.Text = text
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddTextBox = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local TextBoxFrame = Instance.new("Frame")
                        local TextBox = Instance.new("TextBox")
                        local TextBoxCorner = Instance.new("UICorner")

                        TextBoxFrame.Name = id .. "TextBox"
                        TextBoxFrame.Parent = GroupboxContent
                        TextBoxFrame.BackgroundTransparency = 1
                        TextBoxFrame.Size = UDim2.new(1, 0, 0, 28)
                        TextBoxFrame.LayoutOrder = #self.Elements + 1

                        TextBox.Name = "TextBox"
                        TextBox.Parent = TextBoxFrame
                        TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        TextBox.BorderSizePixel = 0
                        TextBox.Position = UDim2.new(0, 0, 0, 0)
                        TextBox.Size = UDim2.new(1, 0, 1, 0)
                        TextBox.Font = Enum.Font.Gotham
                        TextBox.PlaceholderText = options.Placeholder or "Enter text..."
                        TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                        TextBox.Text = options.Default or ""
                        TextBox.TextColor3 = options.TextColor
                        TextBox.TextSize = 11
                        TextBox.ClearTextOnFocus = options.ClearOnFocus or false

                        TextBoxCorner.CornerRadius = UDim.new(0, 5)
                        TextBoxCorner.Parent = TextBox
                        
                        local TextBoxStroke = Instance.new("UIStroke")
                        TextBoxStroke.Color = Color3.fromRGB(55, 55, 55)
                        TextBoxStroke.Thickness = 1
                        TextBoxStroke.Parent = TextBox
                        
                        local TextBoxPadding = Instance.new("UIPadding")
                        TextBoxPadding.Parent = TextBox
                        TextBoxPadding.PaddingLeft = UDim.new(0, 8)
                        TextBoxPadding.PaddingRight = UDim.new(0, 8)
                        
                        -- Focus effects
                        TextBox.Focused:Connect(function()
                            smoothTween(TextBoxStroke, {Color = options.DefaultColor, Thickness = 1.5}, 0.15)
                        end)
                        
                        TextBox.FocusLost:Connect(function()
                            smoothTween(TextBoxStroke, {Color = Color3.fromRGB(55, 55, 55), Thickness = 1}, 0.15)
                            if options.Callback then
                                options.Callback(TextBox.Text)
                            end
                        end)

                        local element = {
                            Type = "TextBox",
                            Frame = TextBoxFrame,
                            SetText = function(text)
                                TextBox.Text = text
                            end,
                            GetText = function()
                                return TextBox.Text
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    UpdateSize = function(self)
                        local totalHeight = 40
                        for _, element in ipairs(self.Elements) do
                            totalHeight = totalHeight + element.Frame.Size.Y.Offset + 8
                        end
                        self.Frame.Size = UDim2.new(1, 0, 0, totalHeight)
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
        
        -- Hover effect for tabs
        TabButton.MouseEnter:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 0.95})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 1})
            end
        end)

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

    function Window:Destroy()
        smoothTween(MainBackGround, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end

    function Window:ToggleVisibility()
        if ScreenGui.Enabled then
            smoothTween(MainBackGround, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            ScreenGui.Enabled = false
        else
            ScreenGui.Enabled = true
            MainBackGround.Size = UDim2.new(0, 0, 0, 0)
            smoothTween(MainBackGround, {Size = options.Size}, 0.3)
        end
    end

    function Window:SetPosition(position)
        smoothTween(MainBackGround, {Position = position}, 0.3)
    end

    function Window:GetPosition()
        return MainBackGround.Position
    end

    function Window:SetSize(size)
        smoothTween(MainBackGround, {Size = size}, 0.3)
        TabHolder.Size = UDim2.new(0, 130, 0, size.Y.Offset)
        ContentFrame.Size = UDim2.new(0, size.X.Offset - 148, 0, size.Y.Offset - 20)
    end

    function Window:GetSize()
        return MainBackGround.Size
    end

    -- Smooth dragging
    local dragToggle = nil
    local dragSpeed = 0.15
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        smoothTween(MainBackGround, {Position = position}, dragSpeed)
    end

    MainBackGround.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = MainBackGround.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)

    return Window
end

return UILibrary
