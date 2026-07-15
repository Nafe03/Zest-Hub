local UILibrary = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/ui5.lua"))()

local Draw = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/drawlib.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

-- ── State for Box ESP ─────────────────────────────────────────────────
local BoxEnabled       = false
local BoxFilled        = true
local BoxColor         = Color3.fromRGB(255, 255, 255)
local BoxFillColor     = Color3.fromRGB(255, 0, 0)
local BoxFillTrans     = 0.7   -- 0 = opaque, 1 = invisible
local BoxThickness     = 1
local BoxRounding      = 0

local GradientEnabled  = false
local GradientColorA   = Color3.fromRGB(255, 0, 0)
local GradientColorB   = Color3.fromRGB(0, 255, 0)
local GradientColorC   = Color3.fromRGB(0, 0, 255)
local GradientStops    = 2 -- 2 or 3
local GradientRotation = 90

local Boxes = {} -- [player] = drawHandle

-- ── State for Mouse Trackers ──────────────────────────────────────────
local MouseTrackingEnabled = false

local MouseCircleEnabled = true
local MouseCircleColor   = Color3.fromRGB(0, 255, 255)
local MouseCircleRadius  = 15

local MouseLineEnabled   = true
local MouseLineColor     = Color3.fromRGB(255, 255, 0)
local MouseLineThickness = 1

local MouseTextEnabled   = true
local MouseTextColor     = Color3.fromRGB(255, 255, 255)

-- Create the static drawing objects for the mouse
local mouseCircle = Draw.new("Circle")
mouseCircle.Visible = false
mouseCircle.Filled = false
mouseCircle.Thickness = 2
mouseCircle.Radius = MouseCircleRadius

local mouseLine = Draw.new("Line")
mouseLine.Visible = false

local mouseText = Draw.new("Text")
mouseText.Visible = false
mouseText.Text = "Mouse Cursor"
mouseText.Size = 14
mouseText.Outline = true
mouseText.Center = false

-- ── Color sanitizer ──────────────────────────────────────────────────
local function toColor3(c)
    if typeof(c) == "Color3" then
        return c
    end

    if type(c) == "table" then
        local r = c.R or c.r or c[1]
        local g = c.G or c.g or c[2]
        local b = c.B or c.b or c[3]

        if r ~= nil and g ~= nil and b ~= nil then
            if r > 1 or g > 1 or b > 1 then
                return Color3.fromRGB(r, g, b)
            else
                return Color3.new(r, g, b)
            end
        end
    end

    warn("[Box ESP] Invalid color value received, falling back to white:", c)
    return Color3.new(1, 1, 1)
end

local function buildGradient()
    if not GradientEnabled then return nil end
    if GradientStops == 3 then
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0,   toColor3(GradientColorA)),
            ColorSequenceKeypoint.new(0.5, toColor3(GradientColorB)),
            ColorSequenceKeypoint.new(1,   toColor3(GradientColorC)),
        })
    else
        return ColorSequence.new(toColor3(GradientColorA), toColor3(GradientColorB))
    end
end

local function refreshGradient()
    local grad = buildGradient()
    for _, b in pairs(Boxes) do
        b.Gradient = grad
    end
end

local function getBox(player)
    if not Boxes[player] then
        local box = Draw.new("Square")
        box.Visible          = false
        box.Filled           = BoxFilled
        box.Color            = BoxColor
        box.FillColor        = BoxFillColor
        box.FillTransparency = BoxFillTrans
        box.Thickness        = BoxThickness
        box.Rounding         = BoxRounding
        box.Gradient         = buildGradient()
        box.GradientRotation = GradientRotation
        Boxes[player] = box
    end
    return Boxes[player]
end

local function removeBox(player)
    if Boxes[player] then
        Boxes[player]:Remove()
        Boxes[player] = nil
    end
end

-- ── Cleanup on player leave ──────────────────────────────────────────
Players.PlayerRemoving:Connect(function(player)
    removeBox(player)
end)

-- ── Main Render Loop ─────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local camCF = camera.CFrame

    -- 1. Handle Player ESP Boxes
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local box = getBox(player)
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")

        if BoxEnabled and hrp and hum and hum.Health > 0 then
            local rootPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen and rootPos.Z > 0 then
                local right = camCF.RightVector
                local up    = camCF.UpVector

                local topPos       = camera:WorldToViewportPoint(hrp.Position + up * 3)
                local bottomPos    = camera:WorldToViewportPoint(hrp.Position - up * 3)
                local rightPos     = camera:WorldToViewportPoint(hrp.Position + right * 2)
                local leftPos      = camera:WorldToViewportPoint(hrp.Position - right * 2)

                local width  = math.abs(rightPos.X - leftPos.X)
                local height = math.abs(bottomPos.Y - topPos.Y)

                local posX = rootPos.X - (width / 2)
                local posY = topPos.Y

                box.Size     = Vector2.new(width, height)
                box.Position = Vector2.new(posX, posY)
                box.Visible  = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end

    -- 2. Handle Mouse Drawings
    if MouseTrackingEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        local viewportSize = camera.ViewportSize

        if MouseCircleEnabled then
            mouseCircle.Position = mousePos
            mouseCircle.Color = MouseCircleColor
            mouseCircle.Visible = true
        else
            mouseCircle.Visible = false
        end

        if MouseLineEnabled then
            -- Draw a tracer line from the bottom center of the screen to the mouse
            mouseLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            mouseLine.To = mousePos
            mouseLine.Color = MouseLineColor
            mouseLine.Thickness = MouseLineThickness
            mouseLine.Visible = true
        else
            mouseLine.Visible = false
        end

        if MouseTextEnabled then
            -- Offset the text slightly so it isn't completely hidden behind the cursor
            mouseText.Position = mousePos + Vector2.new(15, 15)
            mouseText.Color = MouseTextColor
            mouseText.Visible = true
        else
            mouseText.Visible = false
        end
    else
        mouseCircle.Visible = false
        mouseLine.Visible = false
        mouseText.Visible = false
    end
end)

-- ── UI ────────────────────────────────────────────────────────────────
local Window = UILibrary.new({
    Name          = "ESP & Mouse Tracker",
    ToggleKey     = Enum.KeyCode.RightShift,
    CloseKey      = Enum.KeyCode.X,
    DefaultColor  = Color3.fromRGB(165, 127, 159),
    TextColor     = Color3.fromRGB(200, 200, 200),
    Size          = UDim2.new(0, 570, 0, 469),
    Position      = UDim2.new(0.226, 0, 0.146, 0),
    Watermark     = true,
    WatermarkText = "Custom Overlay",
})

-- == TAB 1: Box ESP ==
local MainTab  = Window:AddTab("Player ESP")
local LeftGrp  = MainTab:AddLeftGroupbox("Box ESP")
local RightGrp = MainTab:AddRightGroupbox("Fill & Gradient")

LeftGrp:AddToggle("BoxToggle", {
    Text           = "Enable Box ESP",
    Default        = false,
    HasColorPicker = true,
    Callback = function(v)
        BoxEnabled = v
        if not v then
            for _, b in pairs(Boxes) do b.Visible = false end
        end
    end,
    ColorCallback = function(c)
        BoxColor = toColor3(c)
        for _, b in pairs(Boxes) do b.Color = BoxColor end
    end,
})

LeftGrp:AddSlider("BoxThicknessSlider", {
    Text = "Outline Thickness", Min = 0, Max = 5, Default = 1, Rounding = 1,
    Callback = function(v)
        BoxThickness = v
        for _, b in pairs(Boxes) do b.Thickness = v end
    end,
})

LeftGrp:AddSlider("BoxRoundingSlider", {
    Text = "Corner Rounding", Min = 0, Max = 12, Default = 0, Rounding = 1,
    Callback = function(v)
        BoxRounding = v
        for _, b in pairs(Boxes) do b.Rounding = v end
    end,
})

RightGrp:AddToggle("BoxFillToggle", {
    Text = "Enable Fill", Default = true, HasColorPicker = true,
    Callback = function(v)
        BoxFilled = v
        for _, b in pairs(Boxes) do b.Filled = v end
    end,
    ColorCallback = function(c)
        BoxFillColor = toColor3(c)
        for _, b in pairs(Boxes) do b.FillColor = BoxFillColor end
    end,
})

RightGrp:AddSlider("BoxFillTransSlider", {
    Text = "Fill Transparency", Min = 0, Max = 100, Default = 70, Rounding = 2,
    Callback = function(v)
        BoxFillTrans = v / 100
        for _, b in pairs(Boxes) do b.FillTransparency = BoxFillTrans end
    end,
})

RightGrp:AddDropdown("BoxGradientStops", {
    Text = "Gradient Stops", Values = { "2", "3" }, Default = 1, Multi = false,
    Callback = function(v)
        GradientStops = tonumber(v)
        if GradientEnabled then refreshGradient() end
    end,
})

local gradToggle = RightGrp:AddToggle("BoxGradientToggle", {
    Text = "Enable Gradient", Default = false, HasColorPicker = true,
    Callback = function(v)
        GradientEnabled = v
        refreshGradient()
    end,
    ColorCallback = function(c)
        GradientColorA = toColor3(c)
        if GradientEnabled then refreshGradient() end
    end,
})
gradToggle:AddColorPickerIcon("GradientColorB", {
    Default = GradientColorB,
    Callback = function(c)
        GradientColorB = toColor3(c)
        if GradientEnabled then refreshGradient() end
    end,
})
gradToggle:AddColorPickerIcon("GradientColorC", {
    Default = GradientColorC,
    Callback = function(c)
        GradientColorC = toColor3(c)
        if GradientEnabled and GradientStops == 3 then refreshGradient() end
    end,
})

RightGrp:AddSlider("BoxGradientRotation", {
    Text = "Gradient Angle", Min = 0, Max = 360, Default = 90, Rounding = 1,
    Callback = function(v)
        GradientRotation = v
        for _, b in pairs(Boxes) do b.GradientRotation = v end
    end,
})
