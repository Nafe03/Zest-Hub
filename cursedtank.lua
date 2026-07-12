local UILibrary = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/ui4.lua"))()

local Draw = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/drawlib.lua"))()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════════════════
local BoxEnabled       = false
local BoxFilled        = true
local BoxColor         = Color3.fromRGB(255, 255, 255)
local BoxFillColor     = Color3.fromRGB(255, 0, 0)
local BoxFillTrans     = 0.7
local BoxThickness     = 1
local BoxRounding      = 0
local GradientEnabled  = false
local GradientColorA   = Color3.fromRGB(255, 0, 0)
local GradientColorB   = Color3.fromRGB(0, 255, 0)
local GradientColorC   = Color3.fromRGB(0, 0, 255)
local GradientStops    = 2
local GradientRotation = 90

local AmmoLabelEnabled       = true
local AmmoLabelColor         = Color3.fromRGB(255, 215, 0)

local AmmoHighlightEnabled      = true
local AmmoHighlightFillColor    = Color3.fromRGB(255, 100, 0)
local AmmoHighlightOutlineColor = Color3.fromRGB(255, 255, 255)
local AmmoHighlightFillTrans    = 0.5
local AmmoHighlightOutlineTrans = 0

-- ══════════════════════════════════════════════════════════════════════
-- POOLS
-- ══════════════════════════════════════════════════════════════════════
local Boxes          = {}   -- [chassisName]   = Square draw obj
local NameLabels     = {}   -- [chassisName]   = Text draw obj
local AmmoLabels     = {}   -- [ammoMeshPart]  = Text draw obj
local AmmoHighlights = {}   -- [ammoMeshPart]  = Highlight instance

-- ══════════════════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════════════════
local function toColor3(c)
    if typeof(c) == "Color3" then return c end
    if type(c) == "table" then
        local r = c.R or c.r or c[1]
        local g = c.G or c.g or c[2]
        local b = c.B or c.b or c[3]
        if r ~= nil and g ~= nil and b ~= nil then
            if r > 1 or g > 1 or b > 1 then return Color3.fromRGB(r, g, b)
            else return Color3.new(r, g, b) end
        end
    end
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
    for _, b in pairs(Boxes) do b.Gradient = grad end
end

local function getPlayerName(chassisName)
    return chassisName:match("^Chassis(.+)$") or chassisName
end

local function getTeamColor(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName and p.Team then
            return p.Team.TeamColor.Color
        end
    end
    return nil
end

-- Recursively collect EVERY MeshPart named "Ammunition" inside a chassis.
-- This handles tanks with multiple ammo racks in different Hull branches.
local function collectAllAmmo(parent, results)
    results = results or {}
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "Ammunition" and child:IsA("MeshPart") then
            table.insert(results, child)
        end
        -- Always recurse so we catch deeply nested racks
        collectAllAmmo(child, results)
    end
    return results
end

-- Read ammo count from Attributes on the MeshPart.
-- Tries common names; falls back to first numeric attribute found.
local function readAmmoAttribute(meshPart)
    for _, name in ipairs({ "Ammo", "ammo", "AmmoCount", "Count", "Rounds" }) do
        local v = meshPart:GetAttribute(name)
        if v ~= nil then return tostring(v) end
    end
    for _, v in pairs(meshPart:GetAttributes()) do
        if type(v) == "number" then return tostring(v) end
    end
    return "?"
end

-- ══════════════════════════════════════════════════════════════════════
-- CHASSIS BOX / NAME LABEL
-- ══════════════════════════════════════════════════════════════════════
local function getOrCreateChassis(key)
    if not Boxes[key] then
        local box            = Draw.new("Square")
        box.Visible          = false
        box.Filled           = BoxFilled
        box.Color            = BoxColor
        box.FillColor        = BoxFillColor
        box.FillTransparency = BoxFillTrans
        box.Thickness        = BoxThickness
        box.Rounding         = BoxRounding
        box.Gradient         = buildGradient()
        box.GradientRotation = GradientRotation
        Boxes[key]           = box

        local lbl       = Draw.new("Text")
        lbl.Visible     = false
        lbl.Size        = 14
        lbl.Center      = true
        lbl.Outline     = true
        lbl.Color       = Color3.fromRGB(255, 255, 255)
        NameLabels[key] = lbl
    end
    return Boxes[key], NameLabels[key]
end

local function removeChassis(key)
    if Boxes[key]      then Boxes[key]:Remove();      Boxes[key]      = nil end
    if NameLabels[key] then NameLabels[key]:Remove(); NameLabels[key] = nil end
end

local function hideChassis(key)
    if Boxes[key]      then Boxes[key].Visible      = false end
    if NameLabels[key] then NameLabels[key].Visible  = false end
end

-- ══════════════════════════════════════════════════════════════════════
-- AMMO LABEL + HIGHLIGHT  (one per Ammunition MeshPart instance)
-- ══════════════════════════════════════════════════════════════════════
local function getOrCreateAmmo(mp)
    if not AmmoLabels[mp] then
        local lbl    = Draw.new("Text")
        lbl.Visible  = false
        lbl.Size     = 13
        lbl.Center   = true
        lbl.Outline  = true
        lbl.Color    = AmmoLabelColor
        AmmoLabels[mp] = lbl
    end
    if not AmmoHighlights[mp] then
        local hl = Instance.new("Highlight")
        hl.Adornee             = mp
        hl.FillColor           = AmmoHighlightFillColor
        hl.OutlineColor        = AmmoHighlightOutlineColor
        hl.FillTransparency    = AmmoHighlightFillTrans
        hl.OutlineTransparency = AmmoHighlightOutlineTrans
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled             = false
        hl.Parent              = mp
        AmmoHighlights[mp] = hl
    end
    return AmmoLabels[mp], AmmoHighlights[mp]
end

local function removeAmmo(mp)
    if AmmoLabels[mp] then
        AmmoLabels[mp]:Remove()
        AmmoLabels[mp] = nil
    end
    if AmmoHighlights[mp] then
        pcall(function() AmmoHighlights[mp]:Destroy() end)
        AmmoHighlights[mp] = nil
    end
end

local function hideAmmo(mp)
    if AmmoLabels[mp]     then AmmoLabels[mp].Visible      = false end
    if AmmoHighlights[mp] then AmmoHighlights[mp].Enabled  = false end
end

-- ══════════════════════════════════════════════════════════════════════
-- CLEANUP
-- ══════════════════════════════════════════════════════════════════════
local function cleanupStaleChassis()
    local vehicles = workspace:FindFirstChild("Vehicles")
    for key in pairs(Boxes) do
        if not vehicles or not vehicles:FindFirstChild(key) then
            removeChassis(key)
        end
    end
end

local function cleanupStaleAmmo()
    for mp in pairs(AmmoLabels) do
        if not mp or not mp.Parent then
            removeAmmo(mp)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- ══════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local camera   = workspace.CurrentCamera
    if not camera then return end
    local camCF    = camera.CFrame
    local vehicles = workspace:FindFirstChild("Vehicles")

    if not BoxEnabled or not vehicles then
        for key in pairs(Boxes)      do hideChassis(key) end
        for mp  in pairs(AmmoLabels) do hideAmmo(mp)     end
        cleanupStaleChassis()
        cleanupStaleAmmo()
        return
    end

    cleanupStaleChassis()
    cleanupStaleAmmo()

    local touchedAmmo = {}

    for _, chassis in ipairs(vehicles:GetChildren()) do
        local chassisName = chassis.Name
        if not chassisName:match("^Chassis") then continue end

        local playerName = getPlayerName(chassisName)
        if playerName == LocalPlayer.Name then continue end

        -- ── Chassis box + name ───────────────────────────────────────
        local rootPt = chassis:FindFirstChild("VehicleSeat")
                    or chassis.PrimaryPart
                    or chassis:FindFirstChildWhichIsA("BasePart")

        local box, nameLabel = getOrCreateChassis(chassisName)

        if rootPt then
            local rootPos, onScreen = camera:WorldToViewportPoint(rootPt.Position)
            if onScreen and rootPos.Z > 0 then
                local teamColor = getTeamColor(playerName)
                box.Color = teamColor or BoxColor

                local up    = camCF.UpVector
                local right = camCF.RightVector

                local topPos,    onTop    = camera:WorldToViewportPoint(rootPt.Position + up    * 3)
                local bottomPos, onBottom = camera:WorldToViewportPoint(rootPt.Position - up    * 3)
                local rightPos,  onRight  = camera:WorldToViewportPoint(rootPt.Position + right * 2)
                local leftPos,   onLeft   = camera:WorldToViewportPoint(rootPt.Position - right * 2)

                if onTop and onBottom and onRight and onLeft then
                    local width  = math.abs(rightPos.X - leftPos.X)
                    local height = math.abs(bottomPos.Y - topPos.Y)
                    box.Size     = Vector2.new(width, height)
                    box.Position = Vector2.new(rootPos.X - width / 2, topPos.Y)
                    box.Visible  = true

                    nameLabel.Text     = playerName
                    nameLabel.Position = Vector2.new(rootPos.X, topPos.Y - 16)
                    nameLabel.Color    = teamColor or Color3.fromRGB(255, 255, 255)
                    nameLabel.Visible  = true
                else
                    hideChassis(chassisName)
                end
            else
                hideChassis(chassisName)
            end
        else
            hideChassis(chassisName)
        end

        -- ── ALL Ammunition MeshParts — highlight + label ─────────────
        -- collectAllAmmo recurses the entire chassis so every rack is found
        local allAmmo = collectAllAmmo(chassis)

        for i, mp in ipairs(allAmmo) do
            touchedAmmo[mp] = true
            local lbl, hl = getOrCreateAmmo(mp)

            -- Highlight
            if AmmoHighlightEnabled then
                hl.FillColor           = AmmoHighlightFillColor
                hl.OutlineColor        = AmmoHighlightOutlineColor
                hl.FillTransparency    = AmmoHighlightFillTrans
                hl.OutlineTransparency = AmmoHighlightOutlineTrans
                hl.Enabled             = true
            else
                hl.Enabled = false
            end

            -- Label
            if AmmoLabelEnabled then
                local ammoPos, ammoOnScreen = camera:WorldToViewportPoint(mp.Position)
                if ammoOnScreen and ammoPos.Z > 0 then
                    local ammoVal = readAmmoAttribute(mp)
                    -- Show rack index if there are multiple racks on this tank
                    local prefix = #allAmmo > 1 and ("Rack " .. i .. " | ") or ""
                    lbl.Text     = prefix .. "Ammo: " .. ammoVal
                    lbl.Position = Vector2.new(ammoPos.X, ammoPos.Y - 14)
                    lbl.Color    = AmmoLabelColor
                    lbl.Visible  = true
                else
                    lbl.Visible = false
                end
            else
                lbl.Visible = false
            end
        end
    end

    -- Hide ESP for any ammo mesh not touched this frame
    for mp in pairs(AmmoLabels) do
        if not touchedAmmo[mp] then
            hideAmmo(mp)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════════════════════════════════
local Window = UILibrary.new({
    Name          = "Zest Hub",
    ToggleKey     = Enum.KeyCode.RightShift,
    CloseKey      = Enum.KeyCode.X,
    DefaultColor  = Color3.fromRGB(165, 127, 159),
    TextColor     = Color3.fromRGB(200, 200, 200),
    Size          = UDim2.new(0, 570, 0, 469),
    Position      = UDim2.new(0.226, 0, 0.146, 0),
    Watermark     = true,
    WatermarkText = "Zest Hub",
})

-- ── TAB 1 — Chassis ESP ───────────────────────────────────────────────
local MainTab  = Window:AddTab("ESP")
local LeftGrp  = MainTab:AddLeftGroupbox("Box ESP")
local RightGrp = MainTab:AddRightGroupbox("Fill & Gradient")

LeftGrp:AddToggle("BoxToggle", {
    Text = "Enable Box ESP", Default = false, HasColorPicker = true,
    Callback = function(v)
        BoxEnabled = v
        if not v then for key in pairs(Boxes) do hideChassis(key) end end
    end,
    ColorCallback = function(c) BoxColor = toColor3(c) end,
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

local espToggle = RightGrp:AddToggle("BoxGradientToggle", {
    Text = "Enable Gradient", Default = false, HasColorPicker = true,
    Callback = function(v) GradientEnabled = v; refreshGradient() end,
    ColorCallback = function(c)
        GradientColorA = toColor3(c)
        if GradientEnabled then refreshGradient() end
    end,
})

espToggle:AddColorPickerIcon("GradientColorB", {
    Default = GradientColorB,
    Callback = function(c)
        GradientColorB = toColor3(c)
        if GradientEnabled then refreshGradient() end
    end,
})

espToggle:AddColorPickerIcon("GradientColorC", {
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

-- ── TAB 2 — Ammo ESP ──────────────────────────────────────────────────
local AmmoTab   = Window:AddTab("Ammo ESP")
local ALeftGrp  = AmmoTab:AddLeftGroupbox("Ammo Label")
local ARightGrp = AmmoTab:AddRightGroupbox("Ammo Highlight")

ALeftGrp:AddToggle("AmmoLabelToggle", {
    Text = "Show Ammo Labels", Default = true, HasColorPicker = true,
    Callback = function(v)
        AmmoLabelEnabled = v
        if not v then
            for _, lbl in pairs(AmmoLabels) do lbl.Visible = false end
        end
    end,
    ColorCallback = function(c)
        AmmoLabelColor = toColor3(c)
        for _, lbl in pairs(AmmoLabels) do lbl.Color = AmmoLabelColor end
    end,
})

ARightGrp:AddToggle("AmmoHighlightToggle", {
    Text = "Highlight Ammo Mesh", Default = true, HasColorPicker = true,
    Callback = function(v)
        AmmoHighlightEnabled = v
        if not v then
            for _, hl in pairs(AmmoHighlights) do hl.Enabled = false end
        end
    end,
    ColorCallback = function(c)
        AmmoHighlightFillColor = toColor3(c)
        for _, hl in pairs(AmmoHighlights) do hl.FillColor = AmmoHighlightFillColor end
    end,
})

ARightGrp:AddSlider("HighlightFillTransSlider", {
    Text = "Fill Transparency", Min = 0, Max = 100, Default = 50, Rounding = 0,
    Callback = function(v)
        AmmoHighlightFillTrans = v / 100
        for _, hl in pairs(AmmoHighlights) do hl.FillTransparency = AmmoHighlightFillTrans end
    end,
})

ARightGrp:AddSlider("HighlightOutlineTransSlider", {
    Text = "Outline Transparency", Min = 0, Max = 100, Default = 0, Rounding = 0,
    Callback = function(v)
        AmmoHighlightOutlineTrans = v / 100
        for _, hl in pairs(AmmoHighlights) do hl.OutlineTransparency = AmmoHighlightOutlineTrans end
    end,
})
