-- ================================================================
--  UILibrary v2.0  |  Improved & Bug-Fixed
--  Inspired by juju.lua design patterns
-- ================================================================

local UILibrary = {}

local Players         = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local GuiService      = game:GetService("GuiService")

-- ================================================================
-- Utility
-- ================================================================

local function HSVtoRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p, q, t = v*(1-s), v*(1-f*s), v*(1-(1-f)*s)
    local m = i % 6
    if m==0 then return v,t,p elseif m==1 then return q,v,p
    elseif m==2 then return p,v,t elseif m==3 then return p,q,v
    elseif m==4 then return t,p,v else return v,p,q end
end

local function RGBtoHSV(r, g, b)
    local max, min = math.max(r,g,b), math.min(r,g,b)
    local h, s, v = 0, 0, max
    local d = max - min
    s = max == 0 and 0 or d/max
    if max ~= min then
        if     max==r then h = (g-b)/d + (g<b and 6 or 0)
        elseif max==g then h = (b-r)/d + 2
        else              h = (r-g)/d + 4 end
        h = h/6
    end
    return h, s, v
end

local function tween(inst, props, dur)
    dur = dur or 0.2
    TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function safeParent(gui, player)
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end

local function make(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

-- ================================================================
-- Shared Color Picker Builder  (no more copy-paste!)
-- ================================================================

local function buildColorPicker(id, defaultColor, iconBtn, onChange, overlayGui)
    local accent = defaultColor or Color3.fromRGB(138, 102, 204)

    -- Window (lives in the shared overlay ScreenGui)
    local win = make("Frame", {
        Name = "CP_"..id, Parent = overlayGui,
        BackgroundColor3 = Color3.fromRGB(17, 17, 17),
        BorderSizePixel = 0, Size = UDim2.new(0,252,0,220),
        Visible = false, ZIndex = 300,
    })
    make("UICorner",  {CornerRadius = UDim.new(0,8),  Parent = win})
    make("UIStroke",  {Color = Color3.fromRGB(50,50,50), Thickness = 1.5, Parent = win})

    -- Coloured top bar
    local topBar = make("Frame", {
        Parent = win, BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,3), BackgroundColor3 = accent, ZIndex = 301,
    })
    make("UICorner", {CornerRadius = UDim.new(0,8), Parent = topBar})

    make("TextLabel", {
        Parent = win, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,-20,0,18),
        Font = Enum.Font.GothamBold, TextSize = 11,
        Text = "Colour Picker", TextColor3 = Color3.fromRGB(170,170,170),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 301,
    })

    local inner = make("Frame", {
        Parent = win, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,26), Size = UDim2.new(1,-20,0,160), ZIndex = 301,
    })

    -- Saturation-Value box
    local svBox = make("Frame", {
        Parent = inner, BackgroundColor3 = Color3.fromHSV(0,1,1),
        BorderSizePixel = 0, Size = UDim2.new(0,182,0,155), ZIndex = 301,
    })
    make("UICorner", {CornerRadius = UDim.new(0,4), Parent = svBox})

    local ov1 = make("Frame", {Parent=svBox, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=302})
    make("UIGradient", {
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)), ColorSequenceKeypoint.new(1,Color3.new(1,1,1))},
        Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)},
        Parent = ov1,
    })
    local ov2 = make("Frame", {Parent=svBox, BackgroundColor3=Color3.new(0,0,0), BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=303})
    make("UIGradient", {
        Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)},
        Rotation = 90, Parent = ov2,
    })

    -- SV cursor dot
    local svCursor = make("Frame", {
        Parent = svBox, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0, Size = UDim2.new(0,10,0,10),
        AnchorPoint = Vector2.new(0.5,0.5), ZIndex = 305,
    })
    make("UICorner", {CornerRadius = UDim.new(1,0), Parent = svCursor})
    make("UIStroke", {Color = Color3.new(1,1,1), Thickness = 2, Parent = svCursor})

    local svBtn = make("TextButton", {
        Parent = svBox, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", ZIndex = 304, AutoButtonColor = false,
    })

    -- Hue strip
    local hueStrip = make("Frame", {
        Parent = inner, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Position = UDim2.new(0,190,0,0), Size = UDim2.new(0,22,0,155), ZIndex = 301,
    })
    make("UICorner", {CornerRadius = UDim.new(0,5), Parent = hueStrip})
    make("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
        },
        Rotation = 90, Parent = hueStrip,
    })

    -- Hue cursor line
    local hueCursor = make("Frame", {
        Parent = hueStrip, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Position = UDim2.new(0,-3,0,0), Size = UDim2.new(1,6,0,5), ZIndex = 302,
    })
    make("UICorner",  {CornerRadius = UDim.new(0,3), Parent = hueCursor})
    make("UIStroke",  {Color = Color3.new(1,1,1), Thickness = 2, Parent = hueCursor})

    local hueBtn = make("TextButton", {
        Parent = hueStrip, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", ZIndex = 302, AutoButtonColor = false,
    })

    -- Bottom row: preview + hex input
    local bottomRow = make("Frame", {
        Parent = win, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,193), Size = UDim2.new(1,-20,0,20), ZIndex = 301,
    })

    local preview = make("Frame", {
        Parent = bottomRow, BackgroundColor3 = accent,
        BorderSizePixel = 0, Size = UDim2.new(0,20,0,20), ZIndex = 302,
    })
    make("UICorner", {CornerRadius = UDim.new(0,4), Parent = preview})
    make("UIStroke", {Color = Color3.fromRGB(55,55,55), Thickness = 1, Parent = preview})

    local hexBox = make("TextBox", {
        Parent = bottomRow, BackgroundColor3 = Color3.fromRGB(25,25,25),
        BorderSizePixel = 0,
        Position = UDim2.new(0,26,0,0), Size = UDim2.new(1,-26,0,20),
        Font = Enum.Font.GothamBold, TextSize = 11,
        Text = "FFFFFF", PlaceholderText = "RRGGBB",
        TextColor3 = Color3.fromRGB(200,200,200),
        PlaceholderColor3 = Color3.fromRGB(90,90,90), ZIndex = 302,
    })
    make("UICorner",  {CornerRadius = UDim.new(0,4), Parent = hexBox})
    make("UIStroke",  {Color = Color3.fromRGB(50,50,50), Thickness = 1, Parent = hexBox})
    make("UIPadding", {PaddingLeft = UDim.new(0,7), Parent = hexBox})

    -- State
    local hue, sat, val = 0, 0, 1
    local currentColor = accent
    local svDrag, hueDrag = false, false
    local syncing = false

    local function toHex(c)
        return ("%02X%02X%02X"):format(math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
    end

    local function syncUI()
        if syncing then return end syncing = true
        local r,g,b = HSVtoRGB(hue, sat, val)
        currentColor = Color3.new(r,g,b)
        svBox.BackgroundColor3 = Color3.fromHSV(hue,1,1)
        svCursor.Position = UDim2.new(0, math.clamp(sat*182,0,182), 0, math.clamp((1-val)*155,0,155))
        hueCursor.Position = UDim2.new(0,-3,0, math.clamp(hue*150,0,150))
        preview.BackgroundColor3  = currentColor
        topBar.BackgroundColor3   = currentColor
        hexBox.Text = toHex(currentColor)
        if iconBtn then tween(iconBtn, {BackgroundColor3 = currentColor}, 0.1) end
        syncing = false
        if onChange then onChange(currentColor) end
    end

    local function fromColor(c)
        if syncing then return end
        hue, sat, val = RGBtoHSV(c.R, c.G, c.B)
        syncUI()
    end

    local function svInput(inp)
        local ap, as = svBox.AbsolutePosition, svBox.AbsoluteSize
        sat = math.clamp((inp.Position.X - ap.X)/as.X, 0, 1)
        val = 1 - math.clamp((inp.Position.Y - ap.Y)/as.Y, 0, 1)
        syncUI()
    end
    local function hueInput(inp)
        local ap, as = hueStrip.AbsolutePosition, hueStrip.AbsoluteSize
        hue = math.clamp((inp.Position.Y - ap.Y)/as.Y, 0, 1)
        syncUI()
    end

    svBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag=true; svInput(i) end end)
    hueBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag=true; hueInput(i) end end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if svDrag then svInput(i) elseif hueDrag then hueInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag=false; hueDrag=false end
    end)

    hexBox.FocusLost:Connect(function()
        local h6 = hexBox.Text:gsub("#","")
        if #h6 == 6 then
            local r,g,b = tonumber(h6:sub(1,2),16), tonumber(h6:sub(3,4),16), tonumber(h6:sub(5,6),16)
            if r and g and b then fromColor(Color3.fromRGB(r,g,b)) end
        end
        hexBox.Text = toHex(currentColor)
    end)

    -- Close on outside click
    local closeConn
    closeConn = UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not win.Visible then return end
        local mp = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        mp = Vector2.new(mp.X, mp.Y - inset.Y)
        local wp, ws = win.AbsolutePosition, win.AbsoluteSize
        local onIcon = false
        if iconBtn then
            local ip, is = iconBtn.AbsolutePosition, iconBtn.AbsoluteSize
            onIcon = mp.X>=ip.X and mp.X<=ip.X+is.X and mp.Y>=ip.Y and mp.Y<=ip.Y+is.Y
        end
        if not onIcon and (mp.X<wp.X or mp.X>wp.X+ws.X or mp.Y<wp.Y or mp.Y>wp.Y+ws.Y) then
            win.Visible = false
        end
    end)

    -- Toggle + smart position on icon click
    if iconBtn then
        iconBtn.MouseButton1Click:Connect(function()
            if win.Visible then win.Visible = false; return end
            local inset = GuiService:GetGuiInset()
            local vp = workspace.CurrentCamera.ViewportSize
            local ip, is = iconBtn.AbsolutePosition, iconBtn.AbsoluteSize
            local pw, ph = 252, 220
            local x = ip.X + is.X + 6
            local y = ip.Y - inset.Y
            if x + pw > vp.X - 8 then x = ip.X - pw - 6 end
            if y + ph > vp.Y - inset.Y - 8 then y = vp.Y - inset.Y - ph - 8 end
            win.Position = UDim2.new(0, x, 0, math.max(4, y))
            win.Visible = true
        end)
    end

    fromColor(defaultColor or Color3.new(1,1,1))

    return {
        Window   = win,
        SetColor = fromColor,
        GetColor = function() return currentColor end,
        Show     = function() win.Visible = true end,
        Hide     = function() win.Visible = false end,
        Destroy  = function()
            if closeConn then closeConn:Disconnect() end
            win:Destroy()
        end,
    }
end

-- ================================================================
-- Colour-icon helper (reused in toggles, labels, standalone)
-- ================================================================

local function makeColorIcon(parent, defaultColor)
    local icon = make("TextButton", {
        Parent = parent, BackgroundColor3 = defaultColor,
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        Size = UDim2.new(0,18,0,18),
        Text = "", AutoButtonColor = false,
        ZIndex = 2, BorderSizePixel = 0,
    })
    local ic = make("UICorner", {CornerRadius = UDim.new(0,4), Parent = icon})
    local is = make("UIStroke", {Color = Color3.fromRGB(60,60,60), Thickness = 1.5, Parent = icon})
    icon.MouseEnter:Connect(function() tween(is,{Thickness=2}) end)
    icon.MouseLeave:Connect(function() tween(is,{Thickness=1.5}) end)
    return icon
end

-- ================================================================
-- Main Library
-- ================================================================

function UILibrary.new(options)
    options = options or {}
    local player = Players.LocalPlayer

    local D = {
        Name            = "UI Library",
        ToggleKey       = Enum.KeyCode.RightShift,
        DefaultColor    = Color3.fromRGB(138, 102, 204),
        TextColor       = Color3.fromRGB(210, 210, 210),
        BackgroundColor = Color3.fromRGB(14, 14, 14),
        TabHolderColor  = Color3.fromRGB(10, 10, 10),
        GroupboxColor   = Color3.fromRGB(19, 19, 19),
        Size            = UDim2.new(0, 610, 0, 480),
        Position        = UDim2.new(0.5, -305, 0.5, -240),
        Watermark       = true,
        WatermarkText   = "UI Library v2.0",
    }
    for k,v in pairs(D) do if options[k]==nil then options[k]=v end end

    local accent = options.DefaultColor

    -- Shared overlay (color pickers, dropdowns – always on top)
    local OverlayGui = make("ScreenGui", {
        Name = options.Name.."_Overlay", ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false, DisplayOrder = 10002,
    })
    safeParent(OverlayGui, player)

    -- Main ScreenGui
    local ScreenGui = make("ScreenGui", {
        Name = options.Name, ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false, DisplayOrder = 10000,
    })
    safeParent(ScreenGui, player)

    -- Root window frame
    local Root = make("Frame", {
        Name = "Root", Parent = ScreenGui,
        BackgroundColor3 = options.BackgroundColor,
        BorderSizePixel = 0,
        Position = options.Position,
        Size = options.Size,
        ClipsDescendants = false,
    })
    make("UICorner", {CornerRadius = UDim.new(0,9), Parent = Root})
    make("UIStroke", {Color = Color3.fromRGB(38,38,38), Thickness = 1.5, Parent = Root})

    -- Top accent gradient bar
    local accentBar = make("Frame", {
        Parent = Root, BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,2), ZIndex = 5,
        BackgroundColor3 = accent,
    })
    make("UICorner",  {CornerRadius = UDim.new(0,9), Parent = accentBar})
    make("UIGradient",{
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   accent),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(
                math.min(255, accent.R*255+50),
                math.min(255, accent.G*255+30),
                math.min(255, accent.B*255+50)
            )),
            ColorSequenceKeypoint.new(1,   accent),
        },
        Parent = accentBar,
    })

    -- Header / drag bar
    local Header = make("Frame", {
        Name = "Header", Parent = Root,
        BackgroundColor3 = options.TabHolderColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,38), ZIndex = 3,
    })
    make("UICorner", {CornerRadius = UDim.new(0,9), Parent = Header})

    -- Window title
    make("TextLabel", {
        Parent = Header, BackgroundTransparency = 1,
        Position = UDim2.new(0,14,0,0), Size = UDim2.new(0.6,0,1,0),
        Font = Enum.Font.GothamBold, TextSize = 13,
        Text = options.Name, TextColor3 = accent,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
    })

    -- Close button
    local closeBtn = make("TextButton", {
        Parent = Header, BackgroundColor3 = Color3.fromRGB(45,45,45),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-10,0.5,0),
        Size = UDim2.new(0,18,0,18),
        Font = Enum.Font.GothamBold, TextSize = 14,
        Text = "×", TextColor3 = Color3.fromRGB(170,170,170),
        AutoButtonColor = false, ZIndex = 4,
    })
    make("UICorner", {CornerRadius = UDim.new(1,0), Parent = closeBtn})
    closeBtn.MouseEnter:Connect(function() tween(closeBtn,{BackgroundColor3=Color3.fromRGB(210,55,55), TextColor3=Color3.new(1,1,1)},0.15) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn,{BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.fromRGB(170,170,170)},0.15) end)
    closeBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

    -- Horizontal separator under header
    make("Frame", {
        Parent = Root, BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel = 0, Position = UDim2.new(0,0,0,38),
        Size = UDim2.new(1,0,0,1), ZIndex = 3,
    })

    -- Tab sidebar
    local TabHolder = make("Frame", {
        Name = "TabHolder", Parent = Root,
        BackgroundColor3 = options.TabHolderColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,39),
        Size = UDim2.new(0,128,1,-39),
    })
    make("UICorner",    {CornerRadius = UDim.new(0,9), Parent = TabHolder})
    make("UIListLayout",{
        Parent = TabHolder, FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2),
    })
    make("UIPadding", {
        Parent = TabHolder,
        PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
    })

    -- Vertical divider
    make("Frame", {
        Parent = Root, BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel = 0,
        Position = UDim2.new(0,128,0,39),
        Size = UDim2.new(0,1,1,-39), ZIndex = 3,
    })

    -- Content area
    local ContentArea = make("Frame", {
        Name = "ContentArea", Parent = Root,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0,134,0,44),
        Size = UDim2.new(1,-140,1,-50),
    })

    -- Watermark
    if options.Watermark then
        local wm = make("TextLabel", {
            Name = "Watermark", Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(12,12,12),
            BackgroundTransparency = 0.25,
            Position = UDim2.new(0,8,0,8),
            Size = UDim2.new(0,0,0,24),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold, TextSize = 12,
            Text = "  "..options.WatermarkText.."  ",
            TextColor3 = accent,
        })
        make("UICorner", {CornerRadius = UDim.new(0,6), Parent = wm})
        make("UIStroke", {Color = Color3.fromRGB(38,38,38), Thickness = 1, Parent = wm})
    end

    -- ============================================================
    -- Notification system
    -- ============================================================
    local notifHolder = make("Frame", {
        Name = "Notifications", Parent = OverlayGui,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,-10,1,-10),
        Size = UDim2.new(0,290,1,0),
    })
    make("UIListLayout",{
        Parent = notifHolder,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,5),
    })

    -- ============================================================
    -- Drag (header only)
    -- ============================================================
    local dragging, dragOrigin, dragPos = false, nil, nil
    Header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            dragOrigin = inp.Position
            dragPos    = Root.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = inp.Position - dragOrigin
        tween(Root, {
            Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset+d.X, dragPos.Y.Scale, dragPos.Y.Offset+d.Y)
        }, 0.06)
    end)

    -- ============================================================
    -- Window object
    -- ============================================================
    local tabs       = {}
    local currentTab = nil
    local Window     = {DefaultColor = accent, TextColor = options.TextColor}

    -- Toggle key
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == options.ToggleKey then Window:ToggleVisibility() end
    end)

    -- Notifications
    function Window:Notify(text, kind, duration)
        duration = duration or 3
        kind = kind or 1
        local colours = {
            [1] = Color3.fromRGB(90,130,220),  -- info
            [2] = Color3.fromRGB(70,200,110),  -- success
            [3] = Color3.fromRGB(220,75,75),   -- error
            [4] = Color3.fromRGB(220,165,55),  -- warning
        }
        local icons = {[1]="ℹ",[2]="✓",[3]="✗",[4]="⚠"}
        local col = colours[kind] or colours[1]

        local n = make("Frame", {
            Parent = notifHolder, BackgroundColor3 = Color3.fromRGB(18,18,18),
            BackgroundTransparency = 0.05, BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,46), Position = UDim2.new(1,10,0,0),
        })
        make("UICorner", {CornerRadius = UDim.new(0,7), Parent = n})
        make("UIStroke", {Color = Color3.fromRGB(40,40,40), Thickness = 1, Parent = n})

        local side = make("Frame",{Parent=n, BackgroundColor3=col, BorderSizePixel=0,
            Position=UDim2.new(0,5,0,6), Size=UDim2.new(0,3,1,-12), ZIndex=2})
        make("UICorner",{CornerRadius=UDim.new(1,0),Parent=side})

        make("TextLabel",{Parent=n, BackgroundTransparency=1,
            Position=UDim2.new(0,14,0,0), Size=UDim2.new(0,20,1,0),
            Font=Enum.Font.GothamBold, TextSize=14, Text=icons[kind], TextColor3=col, ZIndex=2})

        make("TextLabel",{Parent=n, BackgroundTransparency=1,
            Position=UDim2.new(0,38,0,0), Size=UDim2.new(1,-44,1,0),
            Font=Enum.Font.Gotham, TextSize=12,
            Text=text, TextColor3=Color3.fromRGB(195,195,195),
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=2})

        -- Progress bar
        local pbg = make("Frame",{Parent=n, BackgroundColor3=Color3.fromRGB(32,32,32),
            BorderSizePixel=0, Position=UDim2.new(0,5,1,-4), Size=UDim2.new(1,-10,0,2), ZIndex=2})
        make("UICorner",{CornerRadius=UDim.new(1,0),Parent=pbg})
        local pf = make("Frame",{Parent=pbg, BackgroundColor3=col, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=3})
        make("UICorner",{CornerRadius=UDim.new(1,0),Parent=pf})

        tween(n,{Position=UDim2.new(0,0,0,0)},0.22)
        task.spawn(function()
            tween(pf,{Size=UDim2.new(0,0,1,0)},duration)
            task.wait(duration)
            tween(n,{Position=UDim2.new(1,10,0,0), BackgroundTransparency=1},0.25)
            task.wait(0.25)
            n:Destroy()
        end)
    end

    -- AddTab
    function Window:AddTab(name)
        -- Button
        local TabBtn = make("TextButton", {
            Name = name.."Tab", Parent = TabHolder,
            BackgroundColor3 = Color3.fromRGB(28,28,28),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,32),
            Font = Enum.Font.GothamSemibold, TextSize = 12,
            Text = name, TextColor3 = Color3.fromRGB(110,110,110),
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false, LayoutOrder = #tabs+1,
        })
        make("UICorner",  {CornerRadius = UDim.new(0,6), Parent = TabBtn})
        make("UIPadding", {PaddingLeft = UDim.new(0,20), Parent = TabBtn})

        -- Left indicator bar (FIX: was at x=-17 and got clipped)
        local Indicator = make("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = accent, BorderSizePixel = 0,
            Position = UDim2.new(0,0,0.15,0),
            Size = UDim2.new(0,3,0.7,0),
            ZIndex = 2, Visible = false,
        })
        make("UICorner", {CornerRadius = UDim.new(1,0), Parent = Indicator})

        -- Scroll frame for content
        local TabContent = make("ScrollingFrame", {
            Name = name.."Content", Parent = ContentArea,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,   -- FIX: auto-scrollable height
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = accent,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
        })

        -- Two auto-sizing columns (FIX: was fixed height, groups got clipped)
        local function makeColumn(xPos, xSize)
            local col = make("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Position = xPos,
                Size = xSize,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            make("UIListLayout",{Parent=col, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,10)})
            return col
        end
        local LeftCol  = makeColumn(UDim2.new(0,8,0,8),   UDim2.new(0.5,-14,0,0))
        local RightCol = makeColumn(UDim2.new(0.5,6,0,8),  UDim2.new(0.5,-14,0,0))

        -- Tab object
        local tab = {
            Button = TabBtn, Content = TabContent,
            Indicator = Indicator,
            LeftContainer = LeftCol, RightContainer = RightCol,
            Groupboxes = {},
        }
        function tab:AddLeftGroupbox(n)  return self:CreateGroupbox(n,"Left")  end
        function tab:AddRightGroupbox(n) return self:CreateGroupbox(n,"Right") end

        function tab:CreateGroupbox(gbName, side)
            -- Auto-sizing groupbox (FIX: was UDim2.new(1,0,0,40) – too small)
            local GBF = make("Frame", {
                Name = gbName.."Groupbox",
                Parent = side=="Left" and LeftCol or RightCol,
                BackgroundColor3 = options.GroupboxColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #self.Groupboxes+1,
            })
            make("UICorner", {CornerRadius = UDim.new(0,7), Parent = GBF})
            make("UIStroke", {Color = Color3.fromRGB(30,30,30), Thickness = 1, Parent = GBF})

            -- Title
            make("TextLabel", {
                Name = "Title", Parent = GBF,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,12,0,8),
                Size = UDim2.new(1,-24,0,17),
                Font = Enum.Font.GothamBold, TextSize = 12,
                Text = gbName, TextColor3 = accent,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            -- Separator line below title (visual upgrade from juju)
            make("Frame", {
                Parent = GBF, BackgroundColor3 = Color3.fromRGB(30,30,30),
                BorderSizePixel = 0,
                Position = UDim2.new(0,8,0,29),
                Size = UDim2.new(1,-16,0,1),
            })

            -- Content pane (auto-sizes)
            local GBC = make("Frame", {
                Name = "Content", Parent = GBF,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,10,0,36),
                Size = UDim2.new(1,-20,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            local GBL = make("UIListLayout", {
                Parent = GBC, SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,7),
            })
            make("UIPadding",{PaddingBottom=UDim.new(0,10), Parent=GBC})

            local gb = {Frame=GBF, Content=GBC, Layout=GBL, Elements={}}

            -- --------------------------------------------------
            -- Toggle
            -- --------------------------------------------------
            function gb:AddToggle(id, opts)
                opts = opts or {}
                local col = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor

                local TF = make("Frame", {
                    Name=id.."Toggle", Parent=GBC,
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,20),
                    LayoutOrder=#self.Elements+1,
                })
                local tbtn = make("TextButton", {
                    Parent=TF, BackgroundTransparency=1,
                    Size=UDim2.new(1, opts.HasColorPicker and -26 or 0, 1,0),
                    Text="", AutoButtonColor=false,
                })

                local TInd = make("Frame", {
                    Parent=TF, BackgroundColor3=Color3.fromRGB(28,28,28),
                    BorderSizePixel=0,
                    Position=UDim2.new(0,0,0.5,-8),
                    Size=UDim2.new(0,16,0,16),
                })
                make("UICorner",{CornerRadius=UDim.new(0,4),Parent=TInd})
                local tStroke = make("UIStroke",{Color=Color3.fromRGB(52,52,52),Thickness=1.5,Parent=TInd})
                local tCheck = make("TextLabel",{
                    Parent=TInd, BackgroundTransparency=1,
                    Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamBold, TextSize=11,
                    Text="✓", TextColor3=Color3.new(1,1,1),
                    TextTransparency=1,
                })
                make("TextLabel",{
                    Parent=TF, BackgroundTransparency=1,
                    Position=UDim2.new(0,22,0,0),
                    Size=UDim2.new(1, opts.HasColorPicker and -48 or -22, 1,0),
                    Font=Enum.Font.Gotham, TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd,
                })

                local on = opts.Default or false
                local function refresh()
                    if on then
                        tween(TInd,   {BackgroundColor3=col})
                        tween(tStroke,{Color=col})
                        tween(tCheck, {TextTransparency=0})
                    else
                        tween(TInd,   {BackgroundColor3=Color3.fromRGB(28,28,28)})
                        tween(tStroke,{Color=Color3.fromRGB(52,52,52)})
                        tween(tCheck, {TextTransparency=1})
                    end
                    if opts.Callback then opts.Callback(on) end
                end

                tbtn.MouseEnter:Connect(function()  if not on then tween(TInd,{BackgroundColor3=Color3.fromRGB(38,38,38)}) end end)
                tbtn.MouseLeave:Connect(function()  if not on then tween(TInd,{BackgroundColor3=Color3.fromRGB(28,28,28)}) end end)
                tbtn.MouseButton1Click:Connect(function() on = not on; refresh() end)
                refresh()

                -- Optional colour picker
                local cp = nil
                if opts.HasColorPicker then
                    local icon = makeColorIcon(TF, col)
                    cp = buildColorPicker(id, col, icon, opts.ColorCallback, OverlayGui)
                end

                local el = {
                    Type="Toggle", Frame=TF, ColorPicker=cp,
                    SetValue=function(v) on=v; refresh() end,
                    GetValue=function() return on end,
                }
                table.insert(self.Elements, el)
                return el
            end

            -- --------------------------------------------------
            -- Slider  (with thumb dot – cleaner feel)
            -- --------------------------------------------------
            function gb:AddSlider(id, opts)
                opts = opts or {}
                local col  = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor
                local suffix = opts.Suffix or ""

                local SF = make("Frame",{
                    Name=id.."Slider", Parent=GBC,
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,38),
                    LayoutOrder=#self.Elements+1,
                })
                make("TextLabel",{Parent=SF, BackgroundTransparency=1,
                    Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,-55,0,18),
                    Font=Enum.Font.Gotham, TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
                local VL = make("TextLabel",{Parent=SF, BackgroundTransparency=1,
                    Position=UDim2.new(1,-52,0,0), Size=UDim2.new(0,52,0,18),
                    Font=Enum.Font.GothamBold, TextSize=11,
                    TextColor3=col, TextXAlignment=Enum.TextXAlignment.Right,
                })
                local SBg = make("Frame",{Parent=SF,
                    BackgroundColor3=Color3.fromRGB(26,26,26),
                    BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,22), Size=UDim2.new(1,0,0,8),
                })
                make("UICorner",{CornerRadius=UDim.new(1,0),Parent=SBg})
                make("UIStroke",{Color=Color3.fromRGB(38,38,38),Thickness=1,Parent=SBg})

                local SFill = make("Frame",{Parent=SBg,BackgroundColor3=col,BorderSizePixel=0,Size=UDim2.new(0,0,1,0)})
                make("UICorner",{CornerRadius=UDim.new(1,0),Parent=SFill})

                -- Thumb
                local thumb = make("Frame",{Parent=SBg,
                    BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                    Size=UDim2.new(0,12,0,12),
                    AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0,0,0.5,0), ZIndex=2,
                })
                make("UICorner",{CornerRadius=UDim.new(1,0),Parent=thumb})
                make("UIStroke",{Color=col,Thickness=2,Parent=thumb})

                local SBtn = make("TextButton",{Parent=SBg,
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,3,0), Position=UDim2.new(0,0,-1,0),
                    Text="", AutoButtonColor=false, ZIndex=3,
                })

                local mn, mx, rnd = opts.Min or 0, opts.Max or 100, opts.Rounding or 0
                local val = opts.Default or mn
                local draggingSlider = false

                local function applyVal(inp)
                    local pct = math.clamp((inp.Position.X-SBg.AbsolutePosition.X)/SBg.AbsoluteSize.X,0,1)
                    local raw = mn + (mx-mn)*pct
                    local mult = 10^rnd
                    val = math.floor(raw*mult+0.5)/mult
                    tween(SFill,{Size=UDim2.new(pct,0,1,0)},0.08)
                    tween(thumb,{Position=UDim2.new(pct,0,0.5,0)},0.08)
                    VL.Text = tostring(val)..suffix
                    if opts.Callback then opts.Callback(val) end
                end

                SBtn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        draggingSlider=true; applyVal(i)
                        tween(thumb,{Size=UDim2.new(0,14,0,14)},0.1)
                    end
                end)
                SBtn.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        draggingSlider=false
                        tween(thumb,{Size=UDim2.new(0,12,0,12)},0.1)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if draggingSlider and i.UserInputType==Enum.UserInputType.MouseMovement then applyVal(i) end
                end)

                local p0 = (val-mn)/(mx-mn)
                SFill.Size = UDim2.new(p0,0,1,0)
                thumb.Position = UDim2.new(p0,0,0.5,0)
                VL.Text = tostring(val)..suffix

                local el = {Type="Slider", Frame=SF,
                    SetValue=function(v)
                        val=math.clamp(v,mn,mx)
                        local p=(val-mn)/(mx-mn)
                        tween(SFill,{Size=UDim2.new(p,0,1,0)},0.15)
                        tween(thumb,{Position=UDim2.new(p,0,0.5,0)},0.15)
                        VL.Text=tostring(val)..suffix
                    end,
                    GetValue=function() return val end,
                }
                table.insert(self.Elements, el)
                return el
            end

            -- --------------------------------------------------
            -- Dropdown  (FIX: list now lives in OverlayGui, no clipping)
            -- --------------------------------------------------
            function gb:AddDropdown(id, opts)
                opts = opts or {}
                local col  = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor
                opts.Values = opts.Values or {}

                local DF = make("Frame",{
                    Name=id.."Dropdown", Parent=GBC,
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,42),
                    LayoutOrder=#self.Elements+1,
                    ZIndex=2, ClipsDescendants=false,
                })
                make("TextLabel",{Parent=DF, BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,18),
                    Font=Enum.Font.Gotham, TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
                local DBtn = make("TextButton",{Parent=DF,
                    BackgroundColor3=Color3.fromRGB(22,22,22),
                    BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,22), Size=UDim2.new(1,0,0,20),
                    Text="", AutoButtonColor=false, ZIndex=2,
                })
                make("UICorner",{CornerRadius=UDim.new(0,4),Parent=DBtn})
                make("UIStroke",{Color=Color3.fromRGB(46,46,46),Thickness=1,Parent=DBtn})

                local DSel = make("TextLabel",{Parent=DBtn,BackgroundTransparency=1,
                    Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-24,1,0),
                    Font=Enum.Font.Gotham, TextSize=11,
                    Text=opts.Default or opts.Values[1] or "Select…",
                    TextColor3=tcol, TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=3,
                })
                local DArrow = make("TextLabel",{Parent=DBtn,BackgroundTransparency=1,
                    AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-6,0.5,0), Size=UDim2.new(0,12,0,12),
                    Font=Enum.Font.GothamBold, TextSize=11,
                    Text="▾", TextColor3=col, ZIndex=3,
                })

                -- List lives in OverlayGui so it's never clipped
                local DList = make("Frame",{
                    Name=id.."_List", Parent=OverlayGui,
                    BackgroundColor3=Color3.fromRGB(20,20,20),
                    BorderSizePixel=0, Size=UDim2.new(0,100,0,0),
                    Visible=false, ZIndex=400, ClipsDescendants=true,
                })
                make("UICorner",{CornerRadius=UDim.new(0,6),Parent=DList})
                make("UIStroke",{Color=Color3.fromRGB(46,46,46),Thickness=1,Parent=DList})
                local DLL = make("UIListLayout",{Parent=DList,
                    SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)})
                make("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),
                    PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),Parent=DList})

                local isOpen = false
                local selected = opts.Default or opts.Values[1] or ""

                local function addOption(v)
                    local ob = make("TextButton",{Parent=DList,
                        BackgroundColor3=Color3.fromRGB(26,26,26),
                        BorderSizePixel=0, Size=UDim2.new(1,0,0,20),
                        Font=Enum.Font.Gotham, TextSize=11,
                        Text="  "..v, TextColor3=tcol,
                        TextXAlignment=Enum.TextXAlignment.Left,
                        ZIndex=401, AutoButtonColor=false,
                    })
                    make("UICorner",{CornerRadius=UDim.new(0,4),Parent=ob})
                    ob.MouseEnter:Connect(function() tween(ob,{BackgroundColor3=Color3.fromRGB(36,36,36)}) end)
                    ob.MouseLeave:Connect(function() tween(ob,{BackgroundColor3=Color3.fromRGB(26,26,26)}) end)
                    ob.MouseButton1Click:Connect(function()
                        selected=v; DSel.Text=v
                        isOpen=false
                        tween(DList,{Size=UDim2.new(0,DList.AbsoluteSize.X,0,0)},0.13)
                        tween(DArrow,{Rotation=0},0.13)
                        task.wait(0.14); DList.Visible=false
                        if opts.Callback then opts.Callback(v) end
                    end)
                end
                for _,v in ipairs(opts.Values) do addOption(v) end

                local function openList()
                    local inset = GuiService:GetGuiInset()
                    local ap,as = DBtn.AbsolutePosition, DBtn.AbsoluteSize
                    local h = math.min(#opts.Values*21+10, 160)
                    DList.Position = UDim2.new(0, ap.X, 0, ap.Y+as.Y+2-inset.Y)
                    DList.Size     = UDim2.new(0, as.X, 0, 0)
                    DList.Visible  = true
                    tween(DList,{Size=UDim2.new(0,as.X,0,h)},0.13)
                    tween(DArrow,{Rotation=180},0.13)
                end
                local function closeList()
                    tween(DList,{Size=UDim2.new(0,DList.AbsoluteSize.X,0,0)},0.13)
                    tween(DArrow,{Rotation=0},0.13)
                    task.wait(0.14); DList.Visible=false
                end

                DBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    if isOpen then openList() else task.spawn(closeList) end
                end)
                DBtn.MouseEnter:Connect(function() tween(DBtn,{BackgroundColor3=Color3.fromRGB(28,28,28)}) end)
                DBtn.MouseLeave:Connect(function() tween(DBtn,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)

                -- Close on outside click
                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType~=Enum.UserInputType.MouseButton1 or not isOpen then return end
                    local mp   = UserInputService:GetMouseLocation()
                    local ins  = GuiService:GetGuiInset()
                    mp = Vector2.new(mp.X, mp.Y-ins.Y)
                    local lp,ls = DList.AbsolutePosition, DList.AbsoluteSize
                    local bp,bs = DBtn.AbsolutePosition,  DBtn.AbsoluteSize
                    local onL = mp.X>=lp.X and mp.X<=lp.X+ls.X and mp.Y>=lp.Y and mp.Y<=lp.Y+ls.Y
                    local onB = mp.X>=bp.X and mp.X<=bp.X+bs.X and mp.Y>=(bp.Y-ins.Y) and mp.Y<=(bp.Y-ins.Y+bs.Y)
                    if not onL and not onB then isOpen=false; task.spawn(closeList) end
                end)

                local el = {Type="Dropdown", Frame=DF,
                    SetValue=function(v) selected=v; DSel.Text=v end,
                    GetValue=function() return selected end,
                }
                table.insert(self.Elements, el)
                return el
            end

            -- --------------------------------------------------
            -- Button
            -- --------------------------------------------------
            function gb:AddButton(id, opts)
                opts = opts or {}
                local col  = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor

                local BF = make("Frame",{Name=id.."Button",Parent=GBC,
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,26),
                    LayoutOrder=#self.Elements+1,
                })
                local B = make("TextButton",{Parent=BF,
                    BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamSemibold, TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    AutoButtonColor=false,
                })
                make("UICorner",{CornerRadius=UDim.new(0,5),Parent=B})
                local bStroke=make("UIStroke",{Color=Color3.fromRGB(46,46,46),Thickness=1,Parent=B})

                B.MouseEnter:Connect(function()    tween(B,{BackgroundColor3=Color3.fromRGB(36,36,36)}); tween(bStroke,{Color=col},0.2) end)
                B.MouseLeave:Connect(function()    tween(B,{BackgroundColor3=Color3.fromRGB(28,28,28)}); tween(bStroke,{Color=Color3.fromRGB(46,46,46)},0.2) end)
                B.MouseButton1Down:Connect(function() tween(B,{BackgroundColor3=Color3.fromRGB(48,48,48)},0.05) end)
                B.MouseButton1Up:Connect(function()   tween(B,{BackgroundColor3=Color3.fromRGB(36,36,36)},0.1) end)
                B.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)

                local el={Type="Button",Frame=BF,Button=B,SetText=function(t) B.Text=t end}
                table.insert(self.Elements,el); return el
            end

            -- --------------------------------------------------
            -- Label  (supports inline AddColorPicker)
            -- --------------------------------------------------
            function gb:AddLabel(text, opts)
                opts = opts or {}
                local tcol = opts.TextColor or Window.TextColor

                local LF = make("Frame",{Name=(text or "Label").."Label",Parent=GBC,
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,18),
                    LayoutOrder=#self.Elements+1,
                })
                local Lbl = make("TextLabel",{Parent=LF,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.Gotham, TextSize=12,
                    Text=text or "Label", TextColor3=tcol,
                    TextXAlignment=opts.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                    TextWrapped=true,
                })

                local el = {Type="Label",Frame=LF,Label=Lbl,
                    SetText=function(t) Lbl.Text=t end,
                }
                function el:AddColorPicker(pid, popts)
                    popts = popts or {}
                    local pcol = popts.Default or popts.DefaultColor or Window.DefaultColor
                    local icon = makeColorIcon(LF, pcol)
                    Lbl.Size = UDim2.new(1,-26,1,0)
                    local cp = buildColorPicker(pid or text or "label", pcol, icon, popts.Callback, OverlayGui)
                    self.ColorPicker = cp
                    return cp
                end

                table.insert(self.Elements, el)
                return el
            end

            -- --------------------------------------------------
            -- TextBox
            -- --------------------------------------------------
            function gb:AddTextBox(id, opts)
                opts = opts or {}
                local col  = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor

                local TBF = make("Frame",{Name=id.."TextBox",Parent=GBC,
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,40),
                    LayoutOrder=#self.Elements+1,
                })
                make("TextLabel",{Parent=TBF,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,18),
                    Font=Enum.Font.Gotham,TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
                local TB = make("TextBox",{Parent=TBF,
                    BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,20),
                    Font=Enum.Font.Gotham, TextSize=12,
                    PlaceholderText=opts.Placeholder or "Type here…",
                    PlaceholderColor3=Color3.fromRGB(90,90,90),
                    Text=opts.Default or "", TextColor3=tcol,
                    ClearTextOnFocus=opts.ClearOnFocus or false,
                })
                make("UICorner",{CornerRadius=UDim.new(0,5),Parent=TB})
                local tbS=make("UIStroke",{Color=Color3.fromRGB(46,46,46),Thickness=1,Parent=TB})
                make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=TB})

                TB.Focused:Connect(function()    tween(tbS,{Color=col,Thickness=1.5},0.15) end)
                TB.FocusLost:Connect(function()
                    tween(tbS,{Color=Color3.fromRGB(46,46,46),Thickness=1},0.15)
                    if opts.Callback then opts.Callback(TB.Text) end
                end)

                local el={Type="TextBox",Frame=TBF,
                    SetText=function(t) TB.Text=t end,
                    GetText=function() return TB.Text end,
                }
                table.insert(self.Elements,el); return el
            end

            -- --------------------------------------------------
            -- KeyPicker
            -- --------------------------------------------------
            function gb:AddKeyPicker(id, opts)
                opts = opts or {}
                local col  = opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor

                local kn = {
                    [Enum.KeyCode.LeftAlt]="L-Alt",[Enum.KeyCode.RightAlt]="R-Alt",
                    [Enum.KeyCode.LeftControl]="L-Ctrl",[Enum.KeyCode.RightControl]="R-Ctrl",
                    [Enum.KeyCode.LeftShift]="L-Shift",[Enum.KeyCode.RightShift]="R-Shift",
                    [Enum.KeyCode.Tab]="Tab",[Enum.KeyCode.CapsLock]="Caps",
                    [Enum.KeyCode.Backspace]="Bksp",[Enum.KeyCode.Return]="Enter",
                    [Enum.KeyCode.Space]="Space",[Enum.KeyCode.Delete]="Del",
                    [Enum.KeyCode.PageUp]="PgUp",[Enum.KeyCode.PageDown]="PgDn",
                    [Enum.KeyCode.Home]="Home",[Enum.KeyCode.End]="End",
                }
                for i=1,12 do kn[Enum.KeyCode["F"..i]]="F"..i end
                local function kname(kc) return kn[kc] or tostring(kc):match("KeyCode%.(.+)") or "?" end

                local curKey = opts.Default or Enum.KeyCode.RightShift
                local modes  = {"Hold","Toggle","Always"}
                local modeI  = 1
                for i,m in ipairs(modes) do if m==opts.Mode then modeI=i break end end
                local mode, listening = modes[modeI], false
                local isActive = false
                local iConn, dConn, uConn
                local bind

                local KF = make("Frame",{Name=id.."KeyPicker",Parent=GBC,
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,36),
                    LayoutOrder=#self.Elements+1,
                })
                make("TextLabel",{Parent=KF,BackgroundTransparency=1,
                    Size=UDim2.new(1,-70,0,18),
                    Font=Enum.Font.Gotham,TextSize=12,
                    Text=opts.Text or id,TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
                local KBtn = make("TextButton",{Parent=KF,
                    BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0,
                    AnchorPoint=Vector2.new(1,0),
                    Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,66,0,18),
                    Text="",AutoButtonColor=false,ClipsDescendants=true,
                })
                make("UICorner",{CornerRadius=UDim.new(0,4),Parent=KBtn})
                local kbS=make("UIStroke",{Color=Color3.fromRGB(46,46,46),Thickness=1,Parent=KBtn})
                local KLbl=make("TextLabel",{Parent=KBtn,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamBold,TextSize=11,
                    Text="["..kname(curKey).."]",TextColor3=col,
                })
                local MLbl=make("TextLabel",{Parent=KF,BackgroundTransparency=1,
                    Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,14),
                    Font=Enum.Font.Gotham,TextSize=10,
                    Text="Mode: "..mode,TextColor3=Color3.fromRGB(100,100,100),
                    TextXAlignment=Enum.TextXAlignment.Left,
                })

                local function stopListen()
                    if iConn then iConn:Disconnect(); iConn=nil end
                    listening=false
                    KLbl.Text="["..kname(curKey).."]"; KLbl.TextColor3=col
                    tween(kbS,{Color=Color3.fromRGB(46,46,46)},0.15)
                    tween(KBtn,{BackgroundColor3=Color3.fromRGB(22,22,22)},0.15)
                end
                local function startListen()
                    listening=true
                    KLbl.Text="…"; KLbl.TextColor3=Color3.fromRGB(210,210,210)
                    tween(kbS,{Color=col},0.15)
                    tween(KBtn,{BackgroundColor3=Color3.fromRGB(34,34,34)},0.15)
                    iConn=UserInputService.InputBegan:Connect(function(i,gp)
                        if gp then return end
                        if i.UserInputType==Enum.UserInputType.Keyboard then
                            if i.KeyCode==Enum.KeyCode.Escape then stopListen(); return end
                            curKey=i.KeyCode; stopListen()
                            if dConn then dConn:Disconnect() end
                            if uConn then uConn:Disconnect() end
                            bind()
                        end
                    end)
                end

                bind = function()
                    if mode=="Always" then isActive=true; if opts.Callback then opts.Callback(true) end return end
                    dConn=UserInputService.InputBegan:Connect(function(i,gp)
                        if gp then return end
                        if i.KeyCode==curKey then
                            if mode=="Hold" then isActive=true; if opts.Callback then opts.Callback(true) end
                            elseif mode=="Toggle" then isActive=not isActive; if opts.Callback then opts.Callback(isActive) end end
                        end
                    end)
                    if mode=="Hold" then
                        uConn=UserInputService.InputEnded:Connect(function(i)
                            if i.KeyCode==curKey then isActive=false; if opts.Callback then opts.Callback(false) end end
                        end)
                    end
                end
                bind()

                KBtn.MouseButton1Click:Connect(function() if listening then stopListen() else startListen() end end)
                KBtn.MouseButton2Click:Connect(function()
                    modeI=(modeI%#modes)+1; mode=modes[modeI]; MLbl.Text="Mode: "..mode
                    if dConn then dConn:Disconnect() end
                    if uConn then uConn:Disconnect() end
                    isActive=false; bind()
                end)
                KBtn.MouseEnter:Connect(function() if not listening then tween(KBtn,{BackgroundColor3=Color3.fromRGB(30,30,30)},0.12) end end)
                KBtn.MouseLeave:Connect(function() if not listening then tween(KBtn,{BackgroundColor3=Color3.fromRGB(22,22,22)},0.12) end end)

                local el={Type="KeyPicker",Frame=KF,
                    GetValue=function() return curKey end,
                    IsActive=function() return isActive end,
                    GetMode=function() return mode end,
                    SetKey=function(kc) curKey=kc; KLbl.Text="["..kname(kc).."]"; if dConn then dConn:Disconnect() end if uConn then uConn:Disconnect() end bind() end,
                    SetMode=function(m)
                        for i,v in ipairs(modes) do if v==m then modeI=i break end end
                        mode=modes[modeI]; MLbl.Text="Mode: "..mode
                        if dConn then dConn:Disconnect() end
                        if uConn then uConn:Disconnect() end
                        isActive=false; bind()
                    end,
                }
                table.insert(self.Elements,el); return el
            end

            -- --------------------------------------------------
            -- Standalone ColorPicker
            -- --------------------------------------------------
            function gb:AddColorPicker(id, opts)
                opts = opts or {}
                local col  = opts.Default or opts.DefaultColor or Window.DefaultColor
                local tcol = opts.TextColor or Window.TextColor

                local CPF = make("Frame",{Name=id.."CP",Parent=GBC,
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,20),
                    LayoutOrder=#self.Elements+1,
                })
                make("TextLabel",{Parent=CPF,BackgroundTransparency=1,
                    Size=UDim2.new(1,-26,1,0),
                    Font=Enum.Font.Gotham,TextSize=12,
                    Text=opts.Text or id, TextColor3=tcol,
                    TextXAlignment=Enum.TextXAlignment.Left,
                })
                local icon = makeColorIcon(CPF, col)
                local cp = buildColorPicker(id, col, icon, opts.Callback, OverlayGui)

                local el={Type="ColorPicker",Frame=CPF,ColorPicker=cp,
                    SetColor=cp.SetColor, GetColor=cp.GetColor,
                }
                table.insert(self.Elements,el); return el
            end

            table.insert(self.Groupboxes, gb)
            return gb
        end  -- CreateGroupbox

        -- Tab click
        TabBtn.MouseButton1Click:Connect(function()
            for _,t in pairs(tabs) do
                t.Content.Visible = false
                t.Indicator.Visible = false
                tween(t.Button, {TextColor3=Color3.fromRGB(110,110,110), BackgroundTransparency=1}, 0.18)
            end
            TabContent.Visible = true
            Indicator.Visible  = true
            tween(TabBtn, {TextColor3=Window.TextColor, BackgroundTransparency=0.88}, 0.18)
            currentTab = tab; Window.ActiveTab = tab
        end)
        TabBtn.MouseEnter:Connect(function()
            if currentTab~=tab then tween(TabBtn,{BackgroundTransparency=0.93}) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if currentTab~=tab then tween(TabBtn,{BackgroundTransparency=1}) end
        end)

        tabs[name] = tab

        -- Auto-select first tab
        if not currentTab then
            TabContent.Visible = true; Indicator.Visible = true
            TabBtn.TextColor3 = Window.TextColor; TabBtn.BackgroundTransparency = 0.88
            currentTab = tab; Window.ActiveTab = tab
        end

        return tab
    end  -- AddTab

    -- ============================================================
    -- Window methods
    -- ============================================================

    function Window:ToggleVisibility()
        if ScreenGui.Enabled then
            task.spawn(function()
                tween(Root,{Size=UDim2.new(0,0,0,0)},0.2)
                task.wait(0.21)
                ScreenGui.Enabled = false
            end)
        else
            ScreenGui.Enabled = true
            Root.Size = UDim2.new(0,0,0,0)
            tween(Root,{Size=options.Size},0.28)
        end
    end

    function Window:Destroy()
        task.spawn(function()
            tween(Root,{Size=UDim2.new(0,0,0,0)},0.22)
            task.wait(0.23)
            ScreenGui:Destroy(); OverlayGui:Destroy()
        end)
    end

    function Window:SetThemeColor(color)
        Window.DefaultColor = color; accent = color
        accentBar.BackgroundColor3 = color
    end

    function Window:SetPosition(pos) tween(Root,{Position=pos},0.25) end
    function Window:GetPosition()    return Root.Position end
    function Window:SetSize(sz)
        tween(Root,{Size=sz},0.25)
        options.Size = sz
    end

    return Window
end

return UILibrary
