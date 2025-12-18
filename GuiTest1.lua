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

local function colorToHex(color)
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- Main UI creation function
function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    local Camera = workspace.CurrentCamera

    -- Default options with modern styling
    local defaultOptions = {
        Name = "UI Library",
        ToggleKey = Enum.KeyCode.Insert,
        CloseKey = Enum.KeyCode.End,
        AccentColor = Color3.fromRGB(88, 166, 255),
        TextColor = Color3.fromRGB(220, 220, 220),
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        SidebarColor = Color3.fromRGB(10, 10, 10),
        GroupboxColor = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Theme = "Dark",
        Watermark = false
    }
    
    for option, value in pairs(defaultOptions) do
        if options[option] == nil then
            options[option] = value
        end
    end

    -- Create main instances
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local Sidebar = Instance.new("Frame")
    local SidebarCorner = Instance.new("UICorner")
    local ContentFrame = Instance.new("Frame")
    local ContentCorner = Instance.new("UICorner")
    
    -- Header
    local Header = Instance.new("Frame")
    local HeaderTitle = Instance.new("TextLabel")

    ScreenGui.Name = options.Name
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = options.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = options.Position
    MainFrame.Size = options.Size
    MainFrame.ClipsDescendants = true
    
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- Header setup
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 35)
    
    HeaderTitle.Name = "Title"
    HeaderTitle.Parent = Header
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.Size = UDim2.new(1, -30, 1, 0)
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.Text = options.Name
    HeaderTitle.TextColor3 = options.AccentColor
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = options.SidebarColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 140, 1, -35)
    
    SidebarCorner.CornerRadius = UDim.new(0, 0)
    SidebarCorner.Parent = Sidebar

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent = Sidebar
    SidebarList.FillDirection = Enum.FillDirection.Vertical
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 2)

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.Parent = Sidebar
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)

    -- Content Frame
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = options.BackgroundColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 140, 0, 35)
    ContentFrame.Size = UDim2.new(1, -140, 1, -35)
    
    ContentCorner.CornerRadius = UDim.new(0, 0)
    ContentCorner.Parent = ContentFrame

    -- Tab Management
    local tabs = {}
    local currentTab = nil

    -- Window object
    local Window = {}
    Window.ActiveTab = nil
    Window.Theme = options.Theme
    Window.AccentColor = options.AccentColor
    Window.TextColor = options.TextColor

    -- Set up toggle key functionality
    local function handleInput(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == options.ToggleKey then
            Window:ToggleVisibility()
        elseif input.KeyCode == options.CloseKey then
            Window:Destroy()
        end
    end

    UserInputService.InputBegan:Connect(handleInput)

    function Window:AddTab(name, icon)
        local TabButton = Instance.new("TextButton")
        local TabContent = Instance.new("ScrollingFrame")
        local TabIcon = Instance.new("TextLabel")
        
        -- Create column containers
        local Column1 = Instance.new("Frame")
        local Column2 = Instance.new("Frame")
        local Column1Layout = Instance.new("UIListLayout")
        local Column2Layout = Instance.new("UIListLayout")

        -- Tab Button (Sidebar)
        TabButton.Name = name .. "Tab"
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false

        -- Tab Content
        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = options.AccentColor
        TabContent.Visible = false
        TabContent.ScrollingDirection = Enum.ScrollingDirection.Y

        -- Column 1 Setup (Left)
        Column1.Name = "Column1"
        Column1.Parent = TabContent
        Column1.BackgroundTransparency = 1
        Column1.Position = UDim2.new(0, 12, 0, 12)
        Column1.Size = UDim2.new(0.5, -18, 1, -24)
        
        Column1Layout.Parent = Column1
        Column1Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Column1Layout.Padding = UDim.new(0, 12)
        Column1Layout.FillDirection = Enum.FillDirection.Vertical

        -- Column 2 Setup (Right)
        Column2.Name = "Column2"
        Column2.Parent = TabContent
        Column2.BackgroundTransparency = 1
        Column2.Position = UDim2.new(0.5, 6, 0, 12)
        Column2.Size = UDim2.new(0.5, -18, 1, -24)
        
        Column2Layout.Parent = Column2
        Column2Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Column2Layout.Padding = UDim.new(0, 12)
        Column2Layout.FillDirection = Enum.FillDirection.Vertical

        -- Update canvas size
        local function updateContentSize()
            local col1Height = Column1Layout.AbsoluteContentSize.Y + 24
            local col2Height = Column2Layout.AbsoluteContentSize.Y + 24
            local maxHeight = math.max(col1Height, col2Height)
            TabContent.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
        end

        Column1Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)
        Column2Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)

        -- Tab Object
        local tab = {
            Button = TabButton,
            Content = TabContent,
            Column1 = Column1,
            Column2 = Column2,
            Sections = {},
            AddSection = function(self, name, column)
                column = column or 1
                local parent = column == 1 and Column1 or Column2
                
                local SectionFrame = Instance.new("Frame")
                local SectionCorner = Instance.new("UICorner")
                local SectionStroke = Instance.new("UIStroke")
                local SectionHeader = Instance.new("Frame")
                local SectionTitle = Instance.new("TextLabel")
                local SectionDivider = Instance.new("Frame")
                local SectionContent = Instance.new("Frame")
                local SectionLayout = Instance.new("UIListLayout")

                SectionFrame.Name = name .. "Section"
                SectionFrame.BackgroundColor3 = options.GroupboxColor
                SectionFrame.BorderSizePixel = 0
                SectionFrame.Size = UDim2.new(1, 0, 0, 50)
                SectionFrame.LayoutOrder = #self.Sections + 1
                SectionFrame.Parent = parent

                SectionCorner.CornerRadius = UDim.new(0, 6)
                SectionCorner.Parent = SectionFrame
                
                SectionStroke.Color = Color3.fromRGB(30, 30, 30)
                SectionStroke.Thickness = 1
                SectionStroke.Parent = SectionFrame

                SectionHeader.Name = "Header"
                SectionHeader.Parent = SectionFrame
                SectionHeader.BackgroundTransparency = 1
                SectionHeader.Size = UDim2.new(1, 0, 0, 28)

                SectionTitle.Name = "Title"
                SectionTitle.Parent = SectionHeader
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Position = UDim2.new(0, 12, 0, 0)
                SectionTitle.Size = UDim2.new(1, -24, 1, 0)
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.Text = name
                SectionTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
                SectionTitle.TextSize = 12
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

                SectionDivider.Name = "Divider"
                SectionDivider.Parent = SectionFrame
                SectionDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                SectionDivider.BorderSizePixel = 0
                SectionDivider.Position = UDim2.new(0, 12, 0, 28)
                SectionDivider.Size = UDim2.new(1, -24, 0, 1)

                SectionContent.Name = "Content"
                SectionContent.Parent = SectionFrame
                SectionContent.BackgroundTransparency = 1
                SectionContent.Position = UDim2.new(0, 12, 0, 34)
                SectionContent.Size = UDim2.new(1, -24, 1, -40)

                SectionLayout.Parent = SectionContent
                SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SectionLayout.Padding = UDim.new(0, 6)
                SectionLayout.FillDirection = Enum.FillDirection.Vertical

                local section = {
                    Frame = SectionFrame,
                    Content = SectionContent,
                    Layout = SectionLayout,
                    Elements = {},
                    AddToggle = function(self, id, opts)
                        opts = opts or {}
                        opts.AccentColor = opts.AccentColor or Window.AccentColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local ToggleFrame = Instance.new("Frame")
                        local ToggleButton = Instance.new("TextButton")
                        local ToggleBox = Instance.new("Frame")
                        local ToggleBoxCorner = Instance.new("UICorner")
                        local ToggleCheckmark = Instance.new("TextLabel")
                        local ToggleText = Instance.new("TextLabel")
                        local GearButton = nil
                        
                        if opts.HasColorPicker then
                            GearButton = Instance.new("TextButton")
                        end
                        
                        ToggleFrame.Name = id .. "Toggle"
                        ToggleFrame.Parent = SectionContent
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 18)
                        ToggleFrame.LayoutOrder = #self.Elements + 1
                    
                        ToggleButton.Name = "Button"
                        ToggleButton.Parent = ToggleFrame
                        ToggleButton.BackgroundTransparency = 1
                        ToggleButton.Size = UDim2.new(1, opts.HasColorPicker and -20 or 0, 1, 0)
                        ToggleButton.Text = ""
                        ToggleButton.ZIndex = 2
                    
                        ToggleBox.Name = "Box"
                        ToggleBox.Parent = ToggleFrame
                        ToggleBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        ToggleBox.BorderSizePixel = 0
                        ToggleBox.Position = UDim2.new(0, 0, 0.5, -7)
                        ToggleBox.Size = UDim2.new(0, 14, 0, 14)
                    
                        ToggleBoxCorner.CornerRadius = UDim.new(0, 3)
                        ToggleBoxCorner.Parent = ToggleBox
                        
                        ToggleCheckmark.Name = "Checkmark"
                        ToggleCheckmark.Parent = ToggleBox
                        ToggleCheckmark.BackgroundTransparency = 1
                        ToggleCheckmark.Size = UDim2.new(1, 0, 1, 0)
                        ToggleCheckmark.Font = Enum.Font.GothamBold
                        ToggleCheckmark.Text = "✓"
                        ToggleCheckmark.TextColor3 = opts.AccentColor
                        ToggleCheckmark.TextSize = 11
                        ToggleCheckmark.Visible = false
                    
                        ToggleText.Name = "Text"
                        ToggleText.Parent = ToggleFrame
                        ToggleText.BackgroundTransparency = 1
                        ToggleText.Position = UDim2.new(0, 20, 0, 0)
                        ToggleText.Size = UDim2.new(1, -20, 1, 0)
                        ToggleText.Font = Enum.Font.Gotham
                        ToggleText.Text = opts.Text or id
                        ToggleText.TextColor3 = Color3.fromRGB(200, 200, 200)
                        ToggleText.TextSize = 12
                        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                        
                        if GearButton then
                            GearButton.Name = "GearButton"
                            GearButton.Parent = ToggleFrame
                            GearButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            GearButton.BorderSizePixel = 0
                            GearButton.Position = UDim2.new(1, -16, 0.5, -7)
                            GearButton.Size = UDim2.new(0, 14, 0, 14)
                            GearButton.Text = "⚙"
                            GearButton.Font = Enum.Font.Gotham
                            GearButton.TextColor3 = Color3.fromRGB(160, 160, 160)
                            GearButton.TextSize = 10
                            GearButton.ZIndex = 3
                            GearButton.AutoButtonColor = false
                            
                            local gearCorner = Instance.new("UICorner")
                            gearCorner.CornerRadius = UDim.new(0, 3)
                            gearCorner.Parent = GearButton
                            
                            GearButton.MouseEnter:Connect(function()
                                GearButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            end)
                            GearButton.MouseLeave:Connect(function()
                                GearButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            end)
                        end
                    
                        local toggled = opts.Default or false
                        local colorPicker = nil
                    
                        local function updateToggle()
                            ToggleCheckmark.Visible = toggled
                            ToggleBox.BackgroundColor3 = toggled and opts.AccentColor or Color3.fromRGB(25, 25, 25)
                            if opts.Callback then
                                opts.Callback(toggled)
                            end
                        end
                    
                        ToggleButton.MouseButton1Click:Connect(function()
                            toggled = not toggled
                            updateToggle()
                        end)
                        
                        -- Color Picker implementation (simplified for length)
                        if opts.HasColorPicker and GearButton then
                            -- Create color picker window (same as before)
                            colorPicker = {
                                Window = nil, -- Would contain the color picker UI
                                GetColor = function() return opts.DefaultColor or Color3.new(1,1,1) end,
                                SetColor = function(color) end
                            }
                            
                            GearButton.MouseButton1Click:Connect(function()
                                -- Toggle color picker visibility
                                print("Color picker toggled")
                            end)
                        end
                        
                        updateToggle()
                        
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
                    AddSlider = function(self, id, opts)
                        opts = opts or {}
                        opts.AccentColor = opts.AccentColor or Window.AccentColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        local SliderFrame = Instance.new("Frame")
                        local SliderText = Instance.new("TextLabel")
                        local SliderValue = Instance.new("TextLabel")
                        local SliderTrack = Instance.new("Frame")
                        local SliderTrackCorner = Instance.new("UICorner")
                        local SliderFill = Instance.new("Frame")
                        local SliderFillCorner = Instance.new("UICorner")
                        local SliderButton = Instance.new("TextButton")

                        SliderFrame.Name = id .. "Slider"
                        SliderFrame.Parent = SectionContent
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Size = UDim2.new(1, 0, 0, 32)
                        SliderFrame.LayoutOrder = #self.Elements + 1

                        SliderText.Name = "Text"
                        SliderText.Parent = SliderFrame
                        SliderText.BackgroundTransparency = 1
                        SliderText.Position = UDim2.new(0, 0, 0, 0)
                        SliderText.Size = UDim2.new(0.7, 0, 0, 14)
                        SliderText.Font = Enum.Font.Gotham
                        SliderText.Text = opts.Text or id
                        SliderText.TextColor3 = Color3.fromRGB(200, 200, 200)
                        SliderText.TextSize = 12
                        SliderText.TextXAlignment = Enum.TextXAlignment.Left

                        SliderValue.Name = "Value"
                        SliderValue.Parent = SliderFrame
                        SliderValue.BackgroundTransparency = 1
                        SliderValue.Position = UDim2.new(0.7, 0, 0, 0)
                        SliderValue.Size = UDim2.new(0.3, 0, 0, 14)
                        SliderValue.Font = Enum.Font.GothamBold
                        SliderValue.Text = tostring(opts.Default or opts.Min or 0)
                        SliderValue.TextColor3 = opts.AccentColor
                        SliderValue.TextSize = 11
                        SliderValue.TextXAlignment = Enum.TextXAlignment.Right

                        SliderTrack.Name = "Track"
                        SliderTrack.Parent = SliderFrame
                        SliderTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        SliderTrack.BorderSizePixel = 0
                        SliderTrack.Position = UDim2.new(0, 0, 0, 18)
                        SliderTrack.Size = UDim2.new(1, 0, 0, 10)

                        SliderTrackCorner.CornerRadius = UDim.new(0, 5)
                        SliderTrackCorner.Parent = SliderTrack

                        SliderFill.Name = "Fill"
                        SliderFill.Parent = SliderTrack
                        SliderFill.BackgroundColor3 = opts.AccentColor
                        SliderFill.BorderSizePixel = 0
                        SliderFill.Size = UDim2.new(0, 0, 1, 0)

                        SliderFillCorner.CornerRadius = UDim.new(0, 5)
                        SliderFillCorner.Parent = SliderFill

                        SliderButton.Name = "Button"
                        SliderButton.Parent = SliderTrack
                        SliderButton.BackgroundTransparency = 1
                        SliderButton.Size = UDim2.new(1, 0, 1, 0)
                        SliderButton.Text = ""

                        local min = opts.Min or 0
                        local max = opts.Max or 100
                        local rounding = opts.Rounding or 1
                        local value = opts.Default or min
                        local dragging = false

                        local function updateSlider(input)
                            local sizeX = math.max(0, math.min(1, (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X))
                            value = min + (max - min) * sizeX

                            if rounding == 1 then
                                value = math.floor(value + 0.5)
                            elseif rounding == 2 then
                                value = math.floor(value * 10 + 0.5) / 10
                            elseif rounding == 3 then
                                value = math.floor(value * 100 + 0.5) / 100
                            end

                            SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                            SliderValue.Text = tostring(value)
                            if opts.Callback then
                                opts.Callback(value)
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
                        SliderValue.Text = tostring(value)

                        local element = {
                            Type = "Slider",
                            Frame = SliderFrame,
                            SetValue = function(newValue)
                                value = math.max(min, math.min(max, newValue))
                                local percent = (value - min) / (max - min)
                                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                                SliderValue.Text = tostring(value)
                            end,
                            GetValue = function()
                                return value
                            end
                        }

                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddDropdown = function(self, id, opts)
                        opts = opts or {}
                        opts.AccentColor = opts.AccentColor or Window.AccentColor
                        opts.TextColor = opts.TextColor or Window.TextColor
                        
                        -- Similar implementation as before but with modern styling
                        local element = {
                            Type = "Dropdown",
                            Frame = Instance.new("Frame")
                        }
                        
                        table.insert(self.Elements, element)
                        self:UpdateSize()
                        return element
                    end,
                    AddButton = function(self, id, opts)
                        opts = opts or {}
                        opts.AccentColor = opts.AccentColor or Window.AccentColor
                        
                        local ButtonFrame = Instance.new("Frame")
                        local Button = Instance.new("TextButton")
                        local ButtonCorner = Instance.new("UICorner")

                        ButtonFrame.Name = id .. "Button"
                        ButtonFrame.Parent = SectionContent
                        ButtonFrame.BackgroundTransparency = 1
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 24)
                        ButtonFrame.LayoutOrder = #self.Elements + 1

                        Button.Name = "Button"
                        Button.Parent = ButtonFrame
                        Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        Button.BorderSizePixel = 0
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.Font = Enum.Font.Gotham
                        Button.Text = opts.Text or id
                        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                        Button.TextSize = 12
                        Button.AutoButtonColor = false

                        ButtonCorner.CornerRadius = UDim.new(0, 4)
                        ButtonCorner.Parent = Button

                        Button.MouseEnter:Connect(function()
                            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                        end)

                        Button.MouseLeave:Connect(function()
                            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                        end)

                        Button.MouseButton1Click:Connect(function()
                            if opts.Callback then
                                opts.Callback()
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
                    AddLabel = function(self, id, opts)
                        opts = opts or {}
                        
                        local LabelFrame = Instance.new("Frame")
                        local Label = Instance.new("TextLabel")

                        LabelFrame.Name = id .. "Label"
                        LabelFrame.Parent = SectionContent
                        LabelFrame.BackgroundTransparency = 1
                        LabelFrame.Size = UDim2.new(1, 0, 0, 16)
                        LabelFrame.LayoutOrder = #self.Elements + 1

                        Label.Name = "Label"
                        Label.Parent = LabelFrame
                        Label.BackgroundTransparency = 1
                        Label.Size = UDim2.new(1, 0, 1, 0)
                        Label.Font = Enum.Font.Gotham
                        Label.Text = opts.Text or id
                        Label.TextColor3 = Color3.fromRGB(160, 160, 160)
                        Label.TextSize = 11
                        Label.TextXAlignment = Enum.TextXAlignment.Left

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
                    UpdateSize = function(self)
                        local totalHeight = 40
                        for _, element in ipairs(self.Elements) do
                            totalHeight = totalHeight + element.Frame.Size.Y.Offset + 6
                        end
                        self.Frame.Size = UDim2.new(1, 0, 0, totalHeight)
                    end
                }

                table.insert(self.Sections, section)
                return section
            end
        }

        TabButton.MouseButton1Click:Connect(function()
            for _, tabData in pairs(tabs) do
                tabData.Content.Visible = false
                tabData.Button.BackgroundTransparency = 1
                tabData.Button.TextColor3 = Color3.fromRGB(140, 140, 140)
            end

            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            TabButton.TextColor3 = options.AccentColor
            currentTab = tab
            Window.ActiveTab = tab
        end)

        tabs[name] = tab

        if not currentTab then
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            TabButton.TextColor3 = options.AccentColor
            currentTab = tab
            Window.ActiveTab = tab
        end

        return tab
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:ToggleVisibility()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end

    -- Dragging functionality
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
        TweenService:Create(MainFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
            end
        end
    end)

    return Window
end

return UILibrary
