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

local function RGBtoHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

local function HexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber("0x" .. hex:sub(1, 2)) / 255
        local g = tonumber("0x" .. hex:sub(3, 4)) / 255
        local b = tonumber("0x" .. hex:sub(5, 6)) / 255
        return Color3.new(r, g, b)
    end
    return nil
end

-- Smooth tween function with multiple easing styles
local function smoothTween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle, easingDirection),
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

    -- Default options with more customization
    local defaultOptions = {
        Name = "UI Library Enhanced",
        ToggleKey = Enum.KeyCode.RightShift,
        DefaultColor = Color3.fromRGB(138, 102, 204),
        SecondaryColor = Color3.fromRGB(108, 72, 174),
        TextColor = Color3.fromRGB(220, 220, 220),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        TabHolderColor = Color3.fromRGB(15, 15, 15),
        GroupboxColor = Color3.fromRGB(22, 22, 22),
        Size = UDim2.new(0, 600, 0, 500),
        Position = UDim2.new(0.5, -300, 0.5, -250),
        Theme = "Dark",
        Watermark = true,
        WatermarkText = "UI Library Enhanced v2.0",
        ShowFPS = true,
        ShowPing = false,
        Acrylic = false -- Blur effect (expensive)
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
    
    -- Top bar for better aesthetics
    local TopBar = Instance.new("Frame")
    local TopBarCorner = Instance.new("UICorner")
    local TitleLabel = Instance.new("TextLabel")

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
    
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainBackGround
    
    MainStroke.Color = Color3.fromRGB(45, 45, 45)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainBackGround
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Top bar with gradient
    TopBar.Name = "TopBar"
    TopBar.Parent = MainBackGround
    TopBar.BackgroundColor3 = options.DefaultColor
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.ZIndex = 2
    
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar
    
    local TopBarGradient = Instance.new("UIGradient")
    TopBarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, options.DefaultColor),
        ColorSequenceKeypoint.new(1, options.SecondaryColor)
    }
    TopBarGradient.Rotation = 45
    TopBarGradient.Parent = TopBar
    
    -- Create a frame to cover bottom corners of top bar
    local TopBarCover = Instance.new("Frame")
    TopBarCover.Name = "TopBarCover"
    TopBarCover.Parent = TopBar
    TopBarCover.BackgroundColor3 = options.DefaultColor
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Position = UDim2.new(0, 0, 1, -10)
    TopBarCover.Size = UDim2.new(1, 0, 0, 10)
    TopBarCover.ZIndex = 1
    
    local TopBarCoverGradient = Instance.new("UIGradient")
    TopBarCoverGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, options.DefaultColor),
        ColorSequenceKeypoint.new(1, options.SecondaryColor)
    }
    TopBarCoverGradient.Rotation = 45
    TopBarCoverGradient.Parent = TopBarCover
    
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = options.Name
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = MainBackGround
    TabHolder.BackgroundColor3 = options.TabHolderColor
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.Size = UDim2.new(0, 140, 1, -35)
    
    UICorner_2.CornerRadius = UDim.new(0, 10)
    UICorner_2.Parent = TabHolder
    
    -- Cover for top right corner
    local TabHolderCover = Instance.new("Frame")
    TabHolderCover.Parent = TabHolder
    TabHolderCover.BackgroundColor3 = options.TabHolderColor
    TabHolderCover.BorderSizePixel = 0
    TabHolderCover.Position = UDim2.new(0, 0, 0, 0)
    TabHolderCover.Size = UDim2.new(1, 0, 0, 10)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabHolder
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabHolder
    TabPadding.PaddingTop = UDim.new(0, 12)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 10)

    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainBackGround
    ContentFrame.BackgroundColor3 = options.BackgroundColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 150, 0, 45)
    ContentFrame.Size = UDim2.new(1, -160, 1, -55)
    
    UICorner_3.CornerRadius = UDim.new(0, 8)
    UICorner_3.Parent = ContentFrame

    -- Enhanced Watermark with FPS counter
    if options.Watermark then
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Name = "WatermarkFrame"
        WatermarkFrame.Parent = ScreenGui
        WatermarkFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
        WatermarkFrame.Size = UDim2.new(0, 200, 0, 30)
        WatermarkFrame.BackgroundTransparency = 0.1
        
        local WatermarkCorner = Instance.new("UICorner")
        WatermarkCorner.CornerRadius = UDim.new(0, 6)
        WatermarkCorner.Parent = WatermarkFrame
        
        local WatermarkStroke = Instance.new("UIStroke")
        WatermarkStroke.Color = options.DefaultColor
        WatermarkStroke.Thickness = 1.5
        WatermarkStroke.Parent = WatermarkFrame
        
        local Watermark = Instance.new("TextLabel")
        Watermark.Name = "Watermark"
        Watermark.Parent = WatermarkFrame
        Watermark.BackgroundTransparency = 1
        Watermark.Position = UDim2.new(0, 10, 0, 0)
        Watermark.Size = UDim2.new(1, -20, 1, 0)
        Watermark.Font = Enum.Font.GothamBold
        Watermark.Text = options.WatermarkText
        Watermark.TextColor3 = Color3.new(1, 1, 1)
        Watermark.TextSize = 12
        Watermark.TextXAlignment = Enum.TextXAlignment.Left
        
        if options.ShowFPS then
            local FPSLabel = Instance.new("TextLabel")
            FPSLabel.Name = "FPSLabel"
            FPSLabel.Parent = WatermarkFrame
            FPSLabel.BackgroundTransparency = 1
            FPSLabel.Position = UDim2.new(1, -60, 0, 0)
            FPSLabel.Size = UDim2.new(0, 50, 1, 0)
            FPSLabel.Font = Enum.Font.GothamBold
            FPSLabel.Text = "60 FPS"
            FPSLabel.TextColor3 = options.DefaultColor
            FPSLabel.TextSize = 11
            FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local lastUpdate = tick()
            local frameCount = 0
            
            RunService.RenderStepped:Connect(function()
                frameCount = frameCount + 1
                if tick() - lastUpdate >= 1 then
                    FPSLabel.Text = frameCount .. " FPS"
                    frameCount = 0
                    lastUpdate = tick()
                end
            end)
        end
    end

    -- Tab Management
    local tabs = {}
    local currentTab = nil

    -- Window object
    local Window = {}
    Window.ActiveTab = nil
    Window.Theme = options.Theme
    Window.DefaultColor = options.DefaultColor
    Window.SecondaryColor = options.SecondaryColor
    Window.TextColor = options.TextColor

    -- Set up toggle key functionality
    local function handleInput(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == options.ToggleKey then
            Window:ToggleVisibility()
        end
    end

    UserInputService.InputBegan:Connect(handleInput)

    function Window:AddTab(name, icon)
        local TabButton = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabHighlight = Instance.new("Frame")
        local TabCorner = Instance.new("UICorner")
        local TabIcon = Instance.new("TextLabel")
        
        -- Create Left Container
        local LeftContainer = Instance.new("Frame")
        local LeftLayout = Instance.new("UIListLayout")
        
        -- Create Right Container
        local RightContainer = Instance.new("Frame")
        local RightLayout = Instance.new("UIListLayout")

        -- Tab Button with icon support
        TabButton.Name = name .. "Tab"
        TabButton.Parent = TabHolder
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = ""
        TabButton.TextColor3 = options.TextColor
        TabButton.TextTransparency = 0.5
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        
        -- Icon
        if icon then
            TabIcon.Name = "Icon"
            TabIcon.Parent = TabButton
            TabIcon.BackgroundTransparency = 1
            TabIcon.Position = UDim2.new(0, 12, 0, 0)
            TabIcon.Size = UDim2.new(0, 20, 1, 0)
            TabIcon.Font = Enum.Font.GothamBold
            TabIcon.Text = icon
            TabIcon.TextColor3 = options.TextColor
            TabIcon.TextTransparency = 0.5
            TabIcon.TextSize = 16
        end
        
        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabButton
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0, icon and 40 or 12, 0, 0)
        TabText.Size = UDim2.new(1, -(icon and 40 or 12), 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = options.TextColor
        TabText.TextTransparency = 0.5
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left

        TabHighlight.Parent = TabButton
        TabHighlight.BackgroundColor3 = options.DefaultColor
        TabHighlight.BorderSizePixel = 0
        TabHighlight.Position = UDim2.new(0, 0, 0, 0)
        TabHighlight.Size = UDim2.new(0, 3, 1, 0)
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
        TabContent.ScrollBarThickness = 5
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
        LeftLayout.Padding = UDim.new(0, 14)
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
        RightLayout.Padding = UDim.new(0, 14)
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
                local TitleBar = Instance.new("Frame")

                GroupboxFrame.Name = name .. "Groupbox"
                GroupboxFrame.BackgroundColor3 = options.GroupboxColor
                GroupboxFrame.BorderSizePixel = 0
                GroupboxFrame.Size = UDim2.new(1, 0, 0, 45)
                GroupboxFrame.LayoutOrder = #self.Groupboxes + 1

                -- Parent to correct container
                if side == "Left" then
                    GroupboxFrame.Parent = LeftContainer
                else
                    GroupboxFrame.Parent = RightContainer
                end

                GroupboxCorner.CornerRadius = UDim.new(0, 8)
                GroupboxCorner.Parent = GroupboxFrame
                
                GroupboxStroke.Color = Color3.fromRGB(40, 40, 40)
                GroupboxStroke.Thickness = 1.5
                GroupboxStroke.Parent = GroupboxFrame
                
                -- Title bar with subtle gradient
                TitleBar.Name = "TitleBar"
                TitleBar.Parent = GroupboxFrame
                TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                TitleBar.BorderSizePixel = 0
                TitleBar.Position = UDim2.new(0, 0, 0, 0)
                TitleBar.Size = UDim2.new(1, 0, 0, 32)
                
                local TitleBarCorner = Instance.new("UICorner")
                TitleBarCorner.CornerRadius = UDim.new(0, 8)
                TitleBarCorner.Parent = TitleBar
                
                -- Cover for bottom corners
                local TitleBarCover = Instance.new("Frame")
                TitleBarCover.Parent = TitleBar
                TitleBarCover.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                TitleBarCover.BorderSizePixel = 0
                TitleBarCover.Position = UDim2.new(0, 0, 1, -8)
                TitleBarCover.Size = UDim2.new(1, 0, 0, 8)

                GroupboxTitle.Name = "Title"
                GroupboxTitle.Parent = TitleBar
                GroupboxTitle.BackgroundTransparency = 1
                GroupboxTitle.Position = UDim2.new(0, 12, 0, 0)
                GroupboxTitle.Size = UDim2.new(1, -24, 1, 0)
                GroupboxTitle.Font = Enum.Font.GothamBold
                GroupboxTitle.Text = name
                GroupboxTitle.TextColor3 = options.DefaultColor
                GroupboxTitle.TextSize = 13
                GroupboxTitle.TextXAlignment = Enum.TextXAlignment.Left

                GroupboxContent.Name = "Content"
                GroupboxContent.Parent = GroupboxFrame
                GroupboxContent.BackgroundTransparency = 1
                GroupboxContent.Position = UDim2.new(0, 12, 0, 40)
                GroupboxContent.Size = UDim2.new(1, -24, 1, -45)

                GroupboxLayout.Parent = GroupboxContent
                GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
                GroupboxLayout.Padding = UDim.new(0, 10)

                local groupbox = {
                    Frame = GroupboxFrame,
                    Content = GroupboxContent,
                    Layout = GroupboxLayout,
                    Side = side,
                    Elements = {},
                    
                    -- ENHANCED TOGGLE WITH SLIDE ANIMATION
                    AddToggle = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local ToggleFrame = Instance.new("Frame")
                        local ToggleButton = Instance.new("TextButton")
                        local ToggleSwitch = Instance.new("Frame")
                        local ToggleSwitchCorner = Instance.new("UICorner")
                        local ToggleKnob = Instance.new("Frame")
                        local ToggleKnobCorner = Instance.new("UICorner")
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
                            ColorIcon.Size = UDim2.new(0, 20, 0, 20)
                            ColorIcon.Text = ""
                            ColorIcon.AutoButtonColor = false
                            ColorIcon.ZIndex = 2
                            ColorIcon.BorderSizePixel = 0
                            
                            local colorCorner = Instance.new("UICorner")
                            colorCorner.CornerRadius = UDim.new(0, 5)
                            colorCorner.Parent = ColorIcon
                            
                            local colorStroke = Instance.new("UIStroke")
                            colorStroke.Color = Color3.fromRGB(70, 70, 70)
                            colorStroke.Thickness = 2
                            colorStroke.Parent = ColorIcon
                            
                            -- Gradient overlay for color icon
                            local colorGradient = Instance.new("UIGradient")
                            colorGradient.Color = ColorSequence.new(options.DefaultColor or Window.DefaultColor)
                            colorGradient.Rotation = 45
                            colorGradient.Parent = ColorIcon
                            
                            -- Hover effect
                            ColorIcon.MouseEnter:Connect(function()
                                smoothTween(colorStroke, {Thickness = 2.5}, 0.15)
                                smoothTween(ColorIcon, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
                            end)
                            ColorIcon.MouseLeave:Connect(function()
                                smoothTween(colorStroke, {Thickness = 2}, 0.15)
                                smoothTween(ColorIcon, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
                            end)
                        end
                    
                        ToggleFrame.Name = id .. "Toggle"
                        ToggleFrame.Parent = GroupboxContent
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
                        ToggleFrame.LayoutOrder = #self.Elements + 1
                    
                        ToggleButton.Name = "Button"
                        ToggleButton.Parent = ToggleFrame
                        ToggleButton.BackgroundTransparency = 1
                        ToggleButton.Size = UDim2.new(1, options.HasColorPicker and -30 or 0, 1, 0)
                        ToggleButton.Text = ""
                        ToggleButton.AutoButtonColor = false
                    
                        -- Modern toggle switch design
                        ToggleSwitch.Name = "Switch"
                        ToggleSwitch.Parent = ToggleFrame
                        ToggleSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        ToggleSwitch.BorderSizePixel = 0
                        ToggleSwitch.Position = UDim2.new(0, 0, 0.5, -10)
                        ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                    
                        ToggleSwitchCorner.CornerRadius = UDim.new(1, 0)
                        ToggleSwitchCorner.Parent = ToggleSwitch
                        
                        local ToggleSwitchStroke = Instance.new("UIStroke")
                        ToggleSwitchStroke.Color = Color3.fromRGB(60, 60, 60)
                        ToggleSwitchStroke.Thickness = 1.5
                        ToggleSwitchStroke.Parent = ToggleSwitch
                        
                        -- Sliding knob
                        ToggleKnob.Name = "Knob"
                        ToggleKnob.Parent = ToggleSwitch
                        ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                        ToggleKnob.BorderSizePixel = 0
                        ToggleKnob.Position = UDim2.new(0, 3, 0.5, -7)
                        ToggleKnob.Size = UDim2.new(0, 14, 0, 14)
                        ToggleKnob.ZIndex = 2
                    
                        ToggleKnobCorner.CornerRadius = UDim.new(1, 0)
                        ToggleKnobCorner.Parent = ToggleKnob
                        
                        -- Shadow effect for knob
                        local KnobShadow = Instance.new("ImageLabel")
                        KnobShadow.Name = "Shadow"
                        KnobShadow.Parent = ToggleKnob
                        KnobShadow.BackgroundTransparency = 1
                        KnobShadow.Position = UDim2.new(0, -4, 0, -4)
                        KnobShadow.Size = UDim2.new(1, 8, 1, 8)
                        KnobShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                        KnobShadow.ImageColor3 = Color3.new(0, 0, 0)
                        KnobShadow.ImageTransparency = 0.8
                        KnobShadow.ZIndex = 1
                    
                        ToggleText.Name = "Text"
                        ToggleText.Parent = ToggleFrame
                        ToggleText.BackgroundTransparency = 1
                        ToggleText.Position = UDim2.new(0, 48, 0, 0)
                        ToggleText.Size = UDim2.new(1, options.HasColorPicker and -78 or -48, 1, 0)
                        ToggleText.Font = Enum.Font.Gotham
                        ToggleText.Text = options.Text or id
                        ToggleText.TextColor3 = options.TextColor
                        ToggleText.TextSize = 13
                        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                        ToggleText.TextTruncate = Enum.TextTruncate.AtEnd
                    
                        local toggled = options.Default or false
                    
                        local function updateToggle(instant)
                            local duration = instant and 0 or 0.25
                            if toggled then
                                smoothTween(ToggleSwitch, {BackgroundColor3 = options.DefaultColor}, duration, Enum.EasingStyle.Quart)
                                smoothTween(ToggleSwitchStroke, {Color = options.DefaultColor}, duration)
                                smoothTween(ToggleKnob, {Position = UDim2.new(1, -17, 0.5, -7)}, duration, Enum.EasingStyle.Quart)
                            else
                                smoothTween(ToggleSwitch, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, duration, Enum.EasingStyle.Quart)
                                smoothTween(ToggleSwitchStroke, {Color = Color3.fromRGB(60, 60, 60)}, duration)
                                smoothTween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, -7)}, duration, Enum.EasingStyle.Quart)
                            end
                            
                            if options.Callback then
                                options.Callback(toggled)
                            end
                        end
                        
                        -- Hover effect
                        ToggleButton.MouseEnter:Connect(function()
                            if not toggled then
                                smoothTween(ToggleSwitch, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                            else
                                local h, s, v = RGBtoHSV(options.DefaultColor.R, options.DefaultColor.G, options.DefaultColor.B)
                                local r, g, b = HSVtoRGB(h, s, math.min(v * 1.2, 1))
                                smoothTween(ToggleSwitch, {BackgroundColor3 = Color3.new(r, g, b)}, 0.15)
                            end
                            smoothTween(ToggleSwitch, {Size = UDim2.new(0, 42, 0, 21)}, 0.15)
                        end)
                        
                        ToggleButton.MouseLeave:Connect(function()
                            if not toggled then
                                smoothTween(ToggleSwitch, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                            else
                                smoothTween(ToggleSwitch, {BackgroundColor3 = options.DefaultColor}, 0.15)
                            end
                            smoothTween(ToggleSwitch, {Size = UDim2.new(0, 40, 0, 20)}, 0.15)
                        end)
                    
                        ToggleButton.MouseButton1Click:Connect(function()
                            toggled = not toggled
                            updateToggle()
                        end)
                        
                        -- Initialize
                        if toggled then
                            updateToggle(true)
                        end
                    
                        -- Color picker implementation (ENHANCED)
                        local colorPicker = nil
                        if options.HasColorPicker then
                            -- Create dedicated ScreenGui for color picker
                            local colorPickerScreenGui = Instance.new("ScreenGui")
                            colorPickerScreenGui.Name = "ColorPickerGui_" .. id
                            colorPickerScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                            colorPickerScreenGui.ResetOnSpawn = false
                            colorPickerScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            colorPickerScreenGui.DisplayOrder = 999
                            
                            -- Create main color picker window (LARGER)
                            local colorPickerWindow = Instance.new("Frame")
                            colorPickerWindow.Name = "ColorPickerWindow"
                            colorPickerWindow.Parent = colorPickerScreenGui
                            colorPickerWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                            colorPickerWindow.BorderSizePixel = 0
                            colorPickerWindow.Position = UDim2.new(0.5, -150, 0.5, -135)
                            colorPickerWindow.Size = UDim2.new(0, 300, 0, 270)
                            colorPickerWindow.Visible = false
                            colorPickerWindow.ZIndex = 100
                            
                            local windowCorner = Instance.new("UICorner")
                            windowCorner.CornerRadius = UDim.new(0, 10)
                            windowCorner.Parent = colorPickerWindow
                            
                            local windowStroke = Instance.new("UIStroke")
                            windowStroke.Color = options.DefaultColor
                            windowStroke.LineJoinMode = Enum.LineJoinMode.Miter
                            windowStroke.Thickness = 2
                            windowStroke.Parent = colorPickerWindow
                            
                            -- Header bar
                            local headerBar = Instance.new("Frame")
                            headerBar.Name = "HeaderBar"
                            headerBar.Size = UDim2.new(1, 0, 0, 35)
                            headerBar.Position = UDim2.new(0, 0, 0, 0)
                            headerBar.Parent = colorPickerWindow
                            headerBar.BackgroundColor3 = options.DefaultColor
                            headerBar.BorderSizePixel = 0
                            headerBar.ZIndex = 101
                            
                            local headerCorner = Instance.new("UICorner")
                            headerCorner.CornerRadius = UDim.new(0, 10)
                            headerCorner.Parent = headerBar
                            
                            -- Cover for bottom of header
                            local headerCover = Instance.new("Frame")
                            headerCover.Parent = headerBar
                            headerCover.BackgroundColor3 = options.DefaultColor
                            headerCover.BorderSizePixel = 0
                            headerCover.Position = UDim2.new(0, 0, 1, -10)
                            headerCover.Size = UDim2.new(1, 0, 0, 10)
                            headerCover.ZIndex = 101
                            
                            local headerTitle = Instance.new("TextLabel")
                            headerTitle.Parent = headerBar
                            headerTitle.BackgroundTransparency = 1
                            headerTitle.Position = UDim2.new(0, 15, 0, 0)
                            headerTitle.Size = UDim2.new(1, -30, 1, 0)
                            headerTitle.Font = Enum.Font.GothamBold
                            headerTitle.Text = "Color Picker"
                            headerTitle.TextColor3 = Color3.new(1, 1, 1)
                            headerTitle.TextSize = 14
                            headerTitle.TextXAlignment = Enum.TextXAlignment.Left
                            headerTitle.ZIndex = 102
                            
                            -- Close button
                            local closeButton = Instance.new("TextButton")
                            closeButton.Parent = headerBar
                            closeButton.BackgroundTransparency = 1
                            closeButton.Position = UDim2.new(1, -30, 0, 0)
                            closeButton.Size = UDim2.new(0, 30, 1, 0)
                            closeButton.Font = Enum.Font.GothamBold
                            closeButton.Text = "×"
                            closeButton.TextColor3 = Color3.new(1, 1, 1)
                            closeButton.TextSize = 20
                            closeButton.ZIndex = 102
                            closeButton.AutoButtonColor = false
                            
                            closeButton.MouseButton1Click:Connect(function()
                                colorPickerWindow.Visible = false
                            end)
                            
                            -- Content frame for color picker
                            local colorPickerFrame = Instance.new("Frame")
                            colorPickerFrame.Name = "ColorPickerFrame"
                            colorPickerFrame.Parent = colorPickerWindow
                            colorPickerFrame.BackgroundTransparency = 1
                            colorPickerFrame.Position = UDim2.new(0, 15, 0, 45)
                            colorPickerFrame.Size = UDim2.new(1, -30, 1, -55)
                            colorPickerFrame.ZIndex = 101
                            
                            -- Saturation/Value box (LARGER)
                            local saturationValueBox = Instance.new("Frame")
                            saturationValueBox.Name = "SaturationValueBox"
                            saturationValueBox.Parent = colorPickerFrame
                            saturationValueBox.BackgroundColor3 = Color3.new(1, 0, 0)
                            saturationValueBox.BorderSizePixel = 0
                            saturationValueBox.Position = UDim2.new(0, 0, 0, 0)
                            saturationValueBox.Size = UDim2.new(0, 210, 0, 160)
                            saturationValueBox.ZIndex = 101
                            
                            local svCorner = Instance.new("UICorner")
                            svCorner.CornerRadius = UDim.new(0, 8)
                            svCorner.Parent = saturationValueBox
                            
                            local svStroke = Instance.new("UIStroke")
                            svStroke.Color = Color3.fromRGB(70, 70, 70)
                            svStroke.Thickness = 2
                            svStroke.Parent = saturationValueBox
                            
                            -- Create overlay frame for saturation gradient
                            local svOverlay = Instance.new("Frame")
                            svOverlay.Name = "SVOverlay"
                            svOverlay.Parent = saturationValueBox
                            svOverlay.BackgroundTransparency = 0
                            svOverlay.Size = UDim2.new(1, 0, 1, 0)
                            svOverlay.ZIndex = 102
                            
                            local svOverlayCorner = Instance.new("UICorner")
                            svOverlayCorner.CornerRadius = UDim.new(0, 8)
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
                            svOverlay2Corner.CornerRadius = UDim.new(0, 8)
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
                            saturationValueButton.Position = UDim2.new(0.5, -6, 0.5, -6)
                            saturationValueButton.Size = UDim2.new(0, 12, 0, 12)
                            saturationValueButton.Text = ""
                            saturationValueButton.ZIndex = 104
                            saturationValueButton.AutoButtonColor = false
                            
                            local svButtonCorner = Instance.new("UICorner")
                            svButtonCorner.CornerRadius = UDim.new(1, 0)
                            svButtonCorner.Parent = saturationValueButton
                            
                            local svButtonStroke = Instance.new("UIStroke")
                            svButtonStroke.Color = Color3.fromRGB(255, 255, 255)
                            svButtonStroke.Thickness = 3
                            svButtonStroke.Parent = saturationValueButton

                            -- Hue slider (LARGER)
                            local hueSlider = Instance.new("Frame")
                            hueSlider.Name = "HueSlider"
                            hueSlider.Parent = colorPickerFrame
                            hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                            hueSlider.BorderSizePixel = 0
                            hueSlider.Position = UDim2.new(0, 225, 0, 0)
                            hueSlider.Size = UDim2.new(0, 30, 0, 160)
                            hueSlider.ZIndex = 101
                            
                            local hueCorner = Instance.new("UICorner")
                            hueCorner.CornerRadius = UDim.new(0, 8)
                            hueCorner.Parent = hueSlider
                            
                            local hueStroke = Instance.new("UIStroke")
                            hueStroke.Color = Color3.fromRGB(70, 70, 70)
                            hueStroke.Thickness = 2
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
                            hueSliderButton.Position = UDim2.new(0, -4, 0, 0)
                            hueSliderButton.Size = UDim2.new(1, 8, 0, 8)
                            hueSliderButton.Text = ""
                            hueSliderButton.ZIndex = 102
                            hueSliderButton.AutoButtonColor = false
                            
                            local hueButtonCorner = Instance.new("UICorner")
                            hueButtonCorner.CornerRadius = UDim.new(0, 4)
                            hueButtonCorner.Parent = hueSliderButton
                            
                            local hueButtonStroke = Instance.new("UIStroke")
                            hueButtonStroke.Color = Color3.fromRGB(255, 255, 255)
                            hueButtonStroke.Thickness = 3
                            hueButtonStroke.Parent = hueSliderButton
                            
                            -- HEX INPUT FIELD
                            local hexInputFrame = Instance.new("Frame")
                            hexInputFrame.Name = "HexInputFrame"
                            hexInputFrame.Parent = colorPickerFrame
                            hexInputFrame.BackgroundTransparency = 1
                            hexInputFrame.Position = UDim2.new(0, 0, 0, 170)
                            hexInputFrame.Size = UDim2.new(1, 0, 0, 30)
                            hexInputFrame.ZIndex = 101
                            
                            local hexLabel = Instance.new("TextLabel")
                            hexLabel.Parent = hexInputFrame
                            hexLabel.BackgroundTransparency = 1
                            hexLabel.Position = UDim2.new(0, 0, 0, 0)
                            hexLabel.Size = UDim2.new(0, 40, 1, 0)
                            hexLabel.Font = Enum.Font.GothamBold
                            hexLabel.Text = "HEX:"
                            hexLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                            hexLabel.TextSize = 12
                            hexLabel.TextXAlignment = Enum.TextXAlignment.Left
                            hexLabel.ZIndex = 102
                            
                            local hexInput = Instance.new("TextBox")
                            hexInput.Name = "HexInput"
                            hexInput.Parent = hexInputFrame
                            hexInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            hexInput.BorderSizePixel = 0
                            hexInput.Position = UDim2.new(0, 45, 0, 0)
                            hexInput.Size = UDim2.new(0, 100, 1, 0)
                            hexInput.Font = Enum.Font.GothamMedium
                            hexInput.PlaceholderText = "#FFFFFF"
                            hexInput.Text = "#FFFFFF"
                            hexInput.TextColor3 = Color3.new(1, 1, 1)
                            hexInput.TextSize = 12
                            hexInput.ZIndex = 102
                            hexInput.ClearTextOnFocus = false
                            
                            local hexCorner = Instance.new("UICorner")
                            hexCorner.CornerRadius = UDim.new(0, 6)
                            hexCorner.Parent = hexInput
                            
                            local hexStroke = Instance.new("UIStroke")
                            hexStroke.Color = Color3.fromRGB(60, 60, 60)
                            hexStroke.Thickness = 1.5
                            hexStroke.Parent = hexInput
                            
                            -- RGB INPUT FIELDS
                            local rgbFrame = Instance.new("Frame")
                            rgbFrame.Name = "RGBFrame"
                            rgbFrame.Parent = colorPickerFrame
                            rgbFrame.BackgroundTransparency = 1
                            rgbFrame.Position = UDim2.new(0, 150, 0, 170)
                            rgbFrame.Size = UDim2.new(0, 105, 0, 30)
                            rgbFrame.ZIndex = 101
                            
                            local function createRGBInput(name, xPos)
                                local frame = Instance.new("Frame")
                                frame.Name = name .. "Frame"
                                frame.Parent = rgbFrame
                                frame.BackgroundTransparency = 1
                                frame.Position = UDim2.new(0, xPos, 0, 0)
                                frame.Size = UDim2.new(0, 30, 1, 0)
                                frame.ZIndex = 101
                                
                                local label = Instance.new("TextLabel")
                                label.Parent = frame
                                label.BackgroundTransparency = 1
                                label.Position = UDim2.new(0, 0, 0, 0)
                                label.Size = UDim2.new(1, 0, 0, 12)
                                label.Font = Enum.Font.GothamBold
                                label.Text = name
                                label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                                label.TextSize = 10
                                label.TextXAlignment = Enum.TextXAlignment.Center
                                label.ZIndex = 102
                                
                                local input = Instance.new("TextBox")
                                input.Name = name .. "Input"
                                input.Parent = frame
                                input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                                input.BorderSizePixel = 0
                                input.Position = UDim2.new(0, 0, 0, 14)
                                input.Size = UDim2.new(1, 0, 0, 16)
                                input.Font = Enum.Font.GothamMedium
                                input.Text = "255"
                                input.TextColor3 = Color3.new(1, 1, 1)
                                input.TextSize = 10
                                input.ZIndex = 102
                                input.ClearTextOnFocus = false
                                
                                local inputCorner = Instance.new("UICorner")
                                inputCorner.CornerRadius = UDim.new(0, 4)
                                inputCorner.Parent = input
                                
                                local inputStroke = Instance.new("UIStroke")
                                inputStroke.Color = Color3.fromRGB(60, 60, 60)
                                inputStroke.Thickness = 1
                                inputStroke.Parent = input
                                
                                return input
                            end
                            
                            local rInput = createRGBInput("R", 0)
                            local gInput = createRGBInput("G", 37)
                            local bInput = createRGBInput("B", 74)
                            
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
                                
                                local hueY = math.clamp(hue * 152, 0, 152)
                                local satX = math.clamp(saturation * 200, 0, 200)
                                local valY = math.clamp((1 - value) * 150, 0, 150)
                                
                                smoothTween(hueSliderButton, {Position = UDim2.new(0, -4, 0, hueY)}, 0.08)
                                smoothTween(saturationValueButton, {Position = UDim2.new(0, satX, 0, valY)}, 0.08)
                                
                                if ColorIcon then
                                    smoothTween(ColorIcon, {BackgroundColor3 = currentColor}, 0.12)
                                end
                                
                                -- Update hex and RGB inputs
                                hexInput.Text = RGBtoHex(currentColor)
                                rInput.Text = tostring(math.floor(currentColor.R * 255))
                                gInput.Text = tostring(math.floor(currentColor.G * 255))
                                bInput.Text = tostring(math.floor(currentColor.B * 255))
                                
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
                            
                            -- Hex input handling
                            hexInput.FocusLost:Connect(function()
                                local color = HexToRGB(hexInput.Text)
                                if color then
                                    updateFromRGB(color)
                                else
                                    hexInput.Text = RGBtoHex(currentColor)
                                end
                            end)
                            
                            -- RGB input handling
                            local function handleRGBInput()
                                local r = math.clamp(tonumber(rInput.Text) or 255, 0, 255) / 255
                                local g = math.clamp(tonumber(gInput.Text) or 255, 0, 255) / 255
                                local b = math.clamp(tonumber(bInput.Text) or 255, 0, 255) / 255
                                updateFromRGB(Color3.new(r, g, b))
                            end
                            
                            rInput.FocusLost:Connect(handleRGBInput)
                            gInput.FocusLost:Connect(handleRGBInput)
                            bInput.FocusLost:Connect(handleRGBInput)
                            
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
                                        local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 152)
                                        hue = yPos / 152
                                        updateColor()
                                    elseif svDragging then
                                        local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 200)
                                        local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 150)
                                        saturation = xPos / 200
                                        value = 1 - (yPos / 150)
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
                                    local xPos = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, 200)
                                    local yPos = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, 150)
                                    saturation = xPos / 200
                                    value = 1 - (yPos / 150)
                                    updateColor()
                                    svDragging = true
                                end
                            end)
                            
                            hueSlider.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    local yPos = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, 152)
                                    hue = yPos / 152
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
                        end

                        local element = {
                            Type = "Toggle",
                            Frame = ToggleFrame,
                            SetValue = function(value)
                                toggled = value
                                updateToggle()
                            end,
                            GetValue = function()
                                return toggled
                            end,
                            ColorPicker = colorPicker
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    
                    -- ENHANCED SLIDER WITH DRAGGABLE HANDLE
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
                        local SliderHandle = Instance.new("Frame")
                        local SliderHandleCorner = Instance.new("UICorner")
                        local SliderButton = Instance.new("TextButton")
                        local ValueLabel = Instance.new("TextLabel")

                        SliderFrame.Name = id .. "Slider"
                        SliderFrame.Parent = GroupboxContent
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Size = UDim2.new(1, 0, 0, 48)
                        SliderFrame.LayoutOrder = #self.Elements + 1

                        SliderText.Name = "Text"
                        SliderText.Parent = SliderFrame
                        SliderText.BackgroundTransparency = 1
                        SliderText.Position = UDim2.new(0, 0, 0, 0)
                        SliderText.Size = UDim2.new(1, -40, 0, 20)
                        SliderText.Font = Enum.Font.Gotham
                        SliderText.Text = options.Text or id
                        SliderText.TextColor3 = options.TextColor
                        SliderText.TextSize = 13
                        SliderText.TextXAlignment = Enum.TextXAlignment.Left

                        SliderBackground.Name = "Background"
                        SliderBackground.Parent = SliderFrame
                        SliderBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        SliderBackground.BorderSizePixel = 0
                        SliderBackground.Position = UDim2.new(0, 0, 0, 28)
                        SliderBackground.Size = UDim2.new(1, -40, 0, 12)

                        SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
                        SliderBackgroundCorner.Parent = SliderBackground
                        
                        local SliderStroke = Instance.new("UIStroke")
                        SliderStroke.Color = Color3.fromRGB(55, 55, 55)
                        SliderStroke.Thickness = 1.5
                        SliderStroke.Parent = SliderBackground

                        SliderFill.Name = "Fill"
                        SliderFill.Parent = SliderBackground
                        SliderFill.BackgroundColor3 = options.DefaultColor
                        SliderFill.BorderSizePixel = 0
                        SliderFill.Size = UDim2.new(0, 0, 1, 0)

                        SliderFillCorner.CornerRadius = UDim.new(1, 0)
                        SliderFillCorner.Parent = SliderFill
                        
                        -- Gradient on fill for extra flair
                        local fillGradient = Instance.new("UIGradient")
                        fillGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, options.DefaultColor),
                            ColorSequenceKeypoint.new(1, Window.SecondaryColor)
                        }
                        fillGradient.Parent = SliderFill
                        
                        -- Draggable handle
                        SliderHandle.Name = "Handle"
                        SliderHandle.Parent = SliderBackground
                        SliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
                        SliderHandle.BorderSizePixel = 0
                        SliderHandle.Position = UDim2.new(0, -8, 0.5, -8)
                        SliderHandle.Size = UDim2.new(0, 16, 0, 16)
                        SliderHandle.ZIndex = 2

                        SliderHandleCorner.CornerRadius = UDim.new(1, 0)
                        SliderHandleCorner.Parent = SliderHandle
                        
                        local HandleStroke = Instance.new("UIStroke")
                        HandleStroke.Color = options.DefaultColor
                        HandleStroke.Thickness = 3
                        HandleStroke.Parent = SliderHandle
                        
                        -- Shadow effect
                        local HandleShadow = Instance.new("UIStroke")
                        HandleShadow.Color = Color3.new(0, 0, 0)
                        HandleShadow.Thickness = 1
                        HandleShadow.Transparency = 0.7
                        HandleShadow.Parent = SliderHandle

                        SliderButton.Name = "Button"
                        SliderButton.Parent = SliderBackground
                        SliderButton.BackgroundTransparency = 1
                        SliderButton.Size = UDim2.new(1, 0, 1, 0)
                        SliderButton.Text = ""
                        SliderButton.AutoButtonColor = false
                        SliderButton.ZIndex = 3

                        ValueLabel.Name = "Value"
                        ValueLabel.Parent = SliderFrame
                        ValueLabel.BackgroundTransparency = 1
                        ValueLabel.Position = UDim2.new(1, -40, 0, 0)
                        ValueLabel.Size = UDim2.new(0, 35, 0, 20)
                        ValueLabel.Font = Enum.Font.GothamBold
                        ValueLabel.Text = tostring(options.Default or options.Min or 0)
                        ValueLabel.TextColor3 = options.DefaultColor
                        ValueLabel.TextSize = 12
                        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

                        local min = options.Min or 0
                        local max = options.Max or 100
                        local rounding = options.Rounding or 1
                        local value = options.Default or min
                        local dragging = false
                        local hovering = false

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

                            smoothTween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.08)
                            smoothTween(SliderHandle, {Position = UDim2.new(sizeX, -8, 0.5, -8)}, 0.08)
                            ValueLabel.Text = tostring(value)
                            
                            if options.Callback then
                                options.Callback(value)
                            end
                        end
                        
                        -- Hover effects
                        SliderButton.MouseEnter:Connect(function()
                            hovering = true
                            smoothTween(SliderHandle, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
                            smoothTween(HandleStroke, {Thickness = 4}, 0.15)
                        end)
                        
                        SliderButton.MouseLeave:Connect(function()
                            hovering = false
                            if not dragging then
                                smoothTween(SliderHandle, {Size = UDim2.new(0, 16, 0, 16)}, 0.15)
                                smoothTween(HandleStroke, {Thickness = 3}, 0.15)
                            end
                        end)

                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true
                                smoothTween(SliderHandle, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
                                updateSlider(input)
                            end
                        end)

                        SliderButton.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                                if hovering then
                                    smoothTween(SliderHandle, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
                                else
                                    smoothTween(SliderHandle, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
                                end
                            end
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                updateSlider(input)
                            end
                        end)

                        local initialPercent = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
                        SliderHandle.Position = UDim2.new(initialPercent, -8, 0.5, -8)
                        ValueLabel.Text = tostring(value)

                        local element = {
                            Type = "Slider",
                            Frame = SliderFrame,
                            SetValue = function(newValue)
                                value = math.max(min, math.min(max, newValue))
                                local percent = (value - min) / (max - min)
                                smoothTween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15)
                                smoothTween(SliderHandle, {Position = UDim2.new(percent, -8, 0.5, -8)}, 0.15)
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
                    
                    -- ENHANCED DROPDOWN
                    AddDropdown = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local DropdownFrame = Instance.new("Frame")
                        local DropdownText = Instance.new("TextLabel")
                        local DropdownButton = Instance.new("TextButton")
                        local DropdownButtonCorner = Instance.new("UICorner")
                        local DropdownArrow = Instance.new("TextLabel")
                        local DropdownList = Instance.new("ScrollingFrame")
                        local DropdownListLayout = Instance.new("UIListLayout")
                        local DropdownListCorner = Instance.new("UICorner")

                        DropdownFrame.Name = id .. "Dropdown"
                        DropdownFrame.Parent = GroupboxContent
                        DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 50)
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
                        DropdownText.TextSize = 13
                        DropdownText.TextXAlignment = Enum.TextXAlignment.Left

                        DropdownButton.Name = "Button"
                        DropdownButton.Parent = DropdownFrame
                        DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        DropdownButton.BorderSizePixel = 0
                        DropdownButton.Position = UDim2.new(0, 0, 0, 26)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 24)
                        DropdownButton.Font = Enum.Font.Gotham
                        DropdownButton.Text = "  " .. (options.Values[1] or "Select...")
                        DropdownButton.TextColor3 = options.TextColor
                        DropdownButton.TextSize = 12
                        DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                        DropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
                        DropdownButton.ZIndex = 2
                        DropdownButton.AutoButtonColor = false

                        DropdownButtonCorner.CornerRadius = UDim.new(0, 6)
                        DropdownButtonCorner.Parent = DropdownButton
                        
                        local DropdownStroke = Instance.new("UIStroke")
                        DropdownStroke.Color = Color3.fromRGB(60, 60, 60)
                        DropdownStroke.Thickness = 1.5
                        DropdownStroke.Parent = DropdownButton

                        DropdownArrow.Name = "Arrow"
                        DropdownArrow.Parent = DropdownButton
                        DropdownArrow.BackgroundTransparency = 1
                        DropdownArrow.Position = UDim2.new(1, -24, 0, 0)
                        DropdownArrow.Size = UDim2.new(0, 24, 1, 0)
                        DropdownArrow.Font = Enum.Font.GothamBold
                        DropdownArrow.Text = "▼"
                        DropdownArrow.TextColor3 = options.DefaultColor
                        DropdownArrow.TextSize = 10

                        DropdownList.Name = "List"
                        DropdownList.Parent = DropdownFrame
                        DropdownList.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                        DropdownList.BorderSizePixel = 0
                        DropdownList.Position = UDim2.new(0, 0, 0, 52)
                        DropdownList.Size = UDim2.new(1, 0, 0, 0)
                        DropdownList.Visible = false
                        DropdownList.ZIndex = 10
                        DropdownList.ClipsDescendants = true
                        DropdownList.ScrollBarThickness = 4
                        DropdownList.ScrollBarImageColor3 = options.DefaultColor

                        DropdownListCorner.CornerRadius = UDim.new(0, 6)
                        DropdownListCorner.Parent = DropdownList
                        
                        local DropdownListStroke = Instance.new("UIStroke")
                        DropdownListStroke.Color = options.DefaultColor
                        DropdownListStroke.Thickness = 1.5
                        DropdownListStroke.Parent = DropdownList

                        DropdownListLayout.Parent = DropdownList
                        DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        DropdownListLayout.Padding = UDim.new(0, 2)
                        
                        local DropdownPadding = Instance.new("UIPadding")
                        DropdownPadding.Parent = DropdownList
                        DropdownPadding.PaddingTop = UDim.new(0, 5)
                        DropdownPadding.PaddingBottom = UDim.new(0, 5)
                        DropdownPadding.PaddingLeft = UDim.new(0, 5)
                        DropdownPadding.PaddingRight = UDim2.new(0, 5)

                        local isOpen = false
                        local selectedValue = options.Values[1] or ""

                        for i, option in ipairs(options.Values) do
                            local OptionButton = Instance.new("TextButton")
                            local OptionButtonCorner = Instance.new("UICorner")

                            OptionButton.Name = "Option" .. i
                            OptionButton.Parent = DropdownList
                            OptionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            OptionButton.BorderSizePixel = 0
                            OptionButton.Size = UDim2.new(1, 0, 0, 24)
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.Text = "  " .. option
                            OptionButton.TextColor3 = options.TextColor
                            OptionButton.TextSize = 12
                            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                            OptionButton.ZIndex = 11
                            OptionButton.AutoButtonColor = false

                            OptionButtonCorner.CornerRadius = UDim.new(0, 4)
                            OptionButtonCorner.Parent = OptionButton

                            OptionButton.MouseEnter:Connect(function()
                                smoothTween(OptionButton, {BackgroundColor3 = options.DefaultColor}, 0.15)
                                smoothTween(OptionButton, {TextColor3 = Color3.new(1, 1, 1)}, 0.15)
                            end)

                            OptionButton.MouseLeave:Connect(function()
                                smoothTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.15)
                                smoothTween(OptionButton, {TextColor3 = options.TextColor}, 0.15)
                            end)

                            OptionButton.MouseButton1Click:Connect(function()
                                selectedValue = option
                                DropdownButton.Text = "  " .. option
                                
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.2, Enum.EasingStyle.Back)
                                task.wait(0.2)
                                DropdownList.Visible = false
                                isOpen = false
                                
                                if options.Callback then
                                    options.Callback(option)
                                end
                            end)
                        end

                        DropdownButton.MouseButton1Click:Connect(function()
                            isOpen = not isOpen
                            if isOpen then
                                DropdownList.Visible = true
                                local targetHeight = math.min((#options.Values * 26) + 12, 150)
                                DropdownList.CanvasSize = UDim2.new(0, 0, 0, (#options.Values * 26) + 12)
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.25, Enum.EasingStyle.Back)
                                smoothTween(DropdownArrow, {Rotation = 180}, 0.25, Enum.EasingStyle.Back)
                            else
                                smoothTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back)
                                smoothTween(DropdownArrow, {Rotation = 0}, 0.2, Enum.EasingStyle.Back)
                                task.wait(0.2)
                                DropdownList.Visible = false
                            end
                        end)
                        
                        -- Hover effect
                        DropdownButton.MouseEnter:Connect(function()
                            smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                            smoothTween(DropdownStroke, {Color = options.DefaultColor}, 0.15)
                        end)
                        
                        DropdownButton.MouseLeave:Connect(function()
                            smoothTween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.15)
                            if not isOpen then
                                smoothTween(DropdownStroke, {Color = Color3.fromRGB(60, 60, 60)}, 0.15)
                            end
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
                    
                    -- Button remains largely the same but with enhanced effects
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
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 32)
                        ButtonFrame.LayoutOrder = #self.Elements + 1

                        Button.Name = "Button"
                        Button.Parent = ButtonFrame
                        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        Button.BorderSizePixel = 0
                        Button.Position = UDim2.new(0, 0, 0, 0)
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.Font = Enum.Font.GothamSemibold
                        Button.Text = options.Text or id
                        Button.TextColor3 = options.TextColor
                        Button.TextSize = 13
                        Button.AutoButtonColor = false

                        ButtonCorner.CornerRadius = UDim.new(0, 7)
                        ButtonCorner.Parent = Button
                        
                        local ButtonStroke = Instance.new("UIStroke")
                        ButtonStroke.Color = Color3.fromRGB(65, 65, 65)
                        ButtonStroke.Thickness = 1.5
                        ButtonStroke.Parent = Button
                        
                        -- Gradient overlay
                        local buttonGradient = Instance.new("UIGradient")
                        buttonGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 45))
                        }
                        buttonGradient.Rotation = 90
                        buttonGradient.Parent = Button

                        Button.MouseEnter:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                            smoothTween(ButtonStroke, {Color = options.DefaultColor, Thickness = 2}, 0.15)
                        end)

                        Button.MouseLeave:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                            smoothTween(ButtonStroke, {Color = Color3.fromRGB(65, 65, 65), Thickness = 1.5}, 0.15)
                        end)

                        Button.MouseButton1Click:Connect(function()
                            smoothTween(Button, {BackgroundColor3 = options.DefaultColor}, 0.05)
                            smoothTween(Button, {TextColor3 = Color3.new(1, 1, 1)}, 0.05)
                            task.wait(0.1)
                            smoothTween(Button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                            smoothTween(Button, {TextColor3 = options.TextColor}, 0.15)
                            
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
                        LabelFrame.Size = UDim2.new(1, 0, 0, 22)
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
                        Label.TextWrapped = true

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
                        TextBoxFrame.Size = UDim2.new(1, 0, 0, 32)
                        TextBoxFrame.LayoutOrder = #self.Elements + 1

                        TextBox.Name = "TextBox"
                        TextBox.Parent = TextBoxFrame
                        TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        TextBox.BorderSizePixel = 0
                        TextBox.Position = UDim2.new(0, 0, 0, 0)
                        TextBox.Size = UDim2.new(1, 0, 1, 0)
                        TextBox.Font = Enum.Font.Gotham
                        TextBox.PlaceholderText = options.Placeholder or "Enter text..."
                        TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                        TextBox.Text = options.Default or ""
                        TextBox.TextColor3 = options.TextColor
                        TextBox.TextSize = 12
                        TextBox.ClearTextOnFocus = options.ClearOnFocus or false

                        TextBoxCorner.CornerRadius = UDim.new(0, 7)
                        TextBoxCorner.Parent = TextBox
                        
                        local TextBoxStroke = Instance.new("UIStroke")
                        TextBoxStroke.Color = Color3.fromRGB(60, 60, 60)
                        TextBoxStroke.Thickness = 1.5
                        TextBoxStroke.Parent = TextBox
                        
                        local TextBoxPadding = Instance.new("UIPadding")
                        TextBoxPadding.Parent = TextBox
                        TextBoxPadding.PaddingLeft = UDim.new(0, 10)
                        TextBoxPadding.PaddingRight = UDim.new(0, 10)
                        
                        -- Focus effects
                        TextBox.Focused:Connect(function()
                            smoothTween(TextBoxStroke, {Color = options.DefaultColor, Thickness = 2}, 0.15)
                            smoothTween(TextBox, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                        end)
                        
                        TextBox.FocusLost:Connect(function()
                            smoothTween(TextBoxStroke, {Color = Color3.fromRGB(60, 60, 60), Thickness = 1.5}, 0.15)
                            smoothTween(TextBox, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.15)
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
                    
                    -- NEW: Keybind Selector
                    AddKeybind = function(self, id, options)
                        options = options or {}
                        options.DefaultColor = options.DefaultColor or Window.DefaultColor
                        options.TextColor = options.TextColor or Window.TextColor
                        
                        local KeybindFrame = Instance.new("Frame")
                        local KeybindText = Instance.new("TextLabel")
                        local KeybindButton = Instance.new("TextButton")
                        local KeybindCorner = Instance.new("UICorner")

                        KeybindFrame.Name = id .. "Keybind"
                        KeybindFrame.Parent = GroupboxContent
                        KeybindFrame.BackgroundTransparency = 1
                        KeybindFrame.Size = UDim2.new(1, 0, 0, 26)
                        KeybindFrame.LayoutOrder = #self.Elements + 1

                        KeybindText.Name = "Text"
                        KeybindText.Parent = KeybindFrame
                        KeybindText.BackgroundTransparency = 1
                        KeybindText.Position = UDim2.new(0, 0, 0, 0)
                        KeybindText.Size = UDim2.new(1, -70, 1, 0)
                        KeybindText.Font = Enum.Font.Gotham
                        KeybindText.Text = options.Text or id
                        KeybindText.TextColor3 = options.TextColor
                        KeybindText.TextSize = 13
                        KeybindText.TextXAlignment = Enum.TextXAlignment.Left

                        KeybindButton.Name = "Button"
                        KeybindButton.Parent = KeybindFrame
                        KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        KeybindButton.BorderSizePixel = 0
                        KeybindButton.Position = UDim2.new(1, -65, 0, 0)
                        KeybindButton.Size = UDim2.new(0, 65, 1, 0)
                        KeybindButton.Font = Enum.Font.GothamSemibold
                        KeybindButton.Text = options.Default and options.Default.Name or "None"
                        KeybindButton.TextColor3 = options.TextColor
                        KeybindButton.TextSize = 11
                        KeybindButton.AutoButtonColor = false

                        KeybindCorner.CornerRadius = UDim.new(0, 6)
                        KeybindCorner.Parent = KeybindButton
                        
                        local KeybindStroke = Instance.new("UIStroke")
                        KeybindStroke.Color = Color3.fromRGB(65, 65, 65)
                        KeybindStroke.Thickness = 1.5
                        KeybindStroke.Parent = KeybindButton

                        local currentKey = options.Default
                        local listening = false

                        local function updateKeybind(key)
                            currentKey = key
                            KeybindButton.Text = key and key.Name or "None"
                            if options.Callback then
                                options.Callback(key)
                            end
                        end

                        KeybindButton.MouseButton1Click:Connect(function()
                            listening = true
                            KeybindButton.Text = "..."
                            smoothTween(KeybindButton, {BackgroundColor3 = options.DefaultColor}, 0.15)
                            smoothTween(KeybindStroke, {Color = options.DefaultColor}, 0.15)
                        end)

                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if listening and not gameProcessed then
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    updateKeybind(input.KeyCode)
                                    listening = false
                                    smoothTween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                                    smoothTween(KeybindStroke, {Color = Color3.fromRGB(65, 65, 65)}, 0.15)
                                end
                            end
                        end)

                        KeybindButton.MouseEnter:Connect(function()
                            if not listening then
                                smoothTween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                            end
                        end)

                        KeybindButton.MouseLeave:Connect(function()
                            if not listening then
                                smoothTween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                            end
                        end)

                        local element = {
                            Type = "Keybind",
                            Frame = KeybindFrame,
                            SetKey = function(key)
                                updateKeybind(key)
                            end,
                            GetKey = function()
                                return currentKey
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    
                    UpdateSize = function(self)
                        local totalHeight = 45
                        for _, element in ipairs(self.Elements) do
                            totalHeight = totalHeight + element.Frame.Size.Y.Offset + 10
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
                smoothTween(tabData.Button, {TextTransparency = 0.5, BackgroundTransparency = 1}, 0.2)
                if tabData.Button:FindFirstChild("Icon") then
                    smoothTween(tabData.Button.Icon, {TextTransparency = 0.5}, 0.2)
                end
                if tabData.Button:FindFirstChild("TabText") then
                    smoothTween(tabData.Button.TabText, {TextTransparency = 0.5}, 0.2)
                end
            end

            TabContent.Visible = true
            TabHighlight.Visible = true
            smoothTween(TabButton, {TextTransparency = 0, BackgroundTransparency = 0}, 0.25)
            if TabIcon then
                smoothTween(TabIcon, {TextTransparency = 0}, 0.25)
            end
            smoothTween(TabText, {TextTransparency = 0}, 0.25)
            currentTab = tab
            Window.ActiveTab = tab
        end)
        
        -- Hover effect for tabs
        TabButton.MouseEnter:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 0.9}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= tab then
                smoothTween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        tabs[name] = tab

        if not currentTab then
            TabContent.Visible = true
            TabHighlight.Visible = true
            TabButton.TextTransparency = 0
            TabButton.BackgroundTransparency = 0
            if TabIcon then
                TabIcon.TextTransparency = 0
            end
            TabText.TextTransparency = 0
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
            smoothTween(MainBackGround, {Size = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back)
            task.wait(0.25)
            ScreenGui.Enabled = false
        else
            ScreenGui.Enabled = true
            MainBackGround.Size = UDim2.new(0, 0, 0, 0)
            smoothTween(MainBackGround, {Size = options.Size}, 0.35, Enum.EasingStyle.Back)
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
        TabHolder.Size = UDim2.new(0, 140, 1, -35)
        ContentFrame.Size = UDim2.new(1, -160, 1, -55)
    end

    function Window:GetSize()
        return MainBackGround.Size
    end

    -- Enhanced dragging with momentum
    local dragToggle = nil
    local dragSpeed = 0.12
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

    TopBar.InputBegan:Connect(function(input)
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
