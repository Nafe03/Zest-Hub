local UILibrary = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/ui4.lua"))()

local Draw = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/drawlib.lua"))()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════
-- CONFIG & CONFIG VALUES
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

-- Penetration Viewer State
local Other = {
    RemoveFog = false,
    PenView = false
}

local PenView = {
    UI = nil,
    HeartbeatConnection = nil,
    LastPart = nil,
    LastChassisName = nil,
    ArmorTypes = {
        "Structural Steel", "RHA", "HHRA", "CHA", "NERA", "Internal RHA", "Internal HHRA",
        "Internal CHA", "Composite Screen", "Rubber-fabric Screen", "Internal Aluminium",
        "Aluminium", "Aluminium Alloy", "Internal Aluminium Alloy", "Internal Structural Steel",
        "ERA", "Wood", "Armour"
    }
}

-- ══════════════════════════════════════════════════════════════════════
-- POOLS
-- ══════════════════════════════════════════════════════════════════════
local Boxes          = {}   -- [chassisName]   = Square draw obj
local NameLabels     = {}   -- [chassisName]   = Text draw obj
local AmmoLabels     = {}   -- [ammoMeshPart]  = Text draw obj
local AmmoHighlights = {}   -- [ammoMeshPart]  = Highlight instance

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

local function collectAllAmmo(parent, results)
    results = results or {}
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "Ammunition" and child:IsA("MeshPart") then
            table.insert(results, child)
        end
        collectAllAmmo(child, results)
    end
    return results
end

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
-- PENETRATION VIEWER CORE METHODS
-- ══════════════════════════════════════════════════════════════════════
local function PenView_CreateUI()
    for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "PenViewport" then v:Destroy() end
    end
    
    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = -100
    sg.Name = "PenViewport"
    sg.Parent = LocalPlayer.PlayerGui
    
    local vp = Instance.new("ViewportFrame", sg)
    vp.Size = UDim2.new(1, 0, 1, 0)
    vp.BackgroundTransparency = 1
    vp.ImageTransparency = 0.25
    vp.ZIndex = -100
    
    local cam = Instance.new("Camera")
    vp.CurrentCamera = cam
    cam.CameraType = Enum.CameraType.Scriptable
    
    return {viewport = vp, vpcam = cam}
end

local function PenView_GetPenetration()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return 200 end
    
    local chassis = vehicles:FindFirstChild("Chassis" .. LocalPlayer.Name)
    if not chassis then return 200 end
    
    local gunFolder = chassis:FindFirstChild("Gun")
    if not gunFolder then return 200 end
    
    for _, gunWeapon in ipairs(gunFolder:GetChildren()) do
        local config = gunWeapon:FindFirstChild("Config")
        if config then
            local shells = config:FindFirstChild("Shells")
            if shells then
                for _, folder in ipairs(shells:GetChildren()) do
                    local penVal = folder:FindFirstChild("Penetration")
                    if penVal then return penVal.Value end
                end
            end
        end
    end
    
    return 200
end

local function PenView_FindGunBrick(chassis)
    local gun = chassis:FindFirstChild("Gun", true)
    if not gun then return nil end
    for _, obj in ipairs(gun:GetDescendants()) do
        if obj.Name == "GunBrick" then return obj end
    end
    return nil
end

local function PenView_GetArmorThickness(hitPart, hitPos, direction, hitNormal)
    if not hitPart or not hitPos then return 0 end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = {hitPart}
    
    local result = workspace:Raycast(hitPos + direction * 4, -direction * 50, params)
    if result and result.Instance == hitPart then
        local thickness = (hitPos - result.Position).Magnitude / 0.00357
        if hitNormal then
            local cos = math.abs(hitNormal:Dot(-direction.Unit))
            thickness = thickness / math.max(cos, 0.05)
        end
        return thickness
    end
    return 0
end

local function PenView_UpdateViewport(ui, part, thickness, pen)
    if not ui or not ui.viewport or not ui.viewport.Parent then
        return
    end
    
    if not part or not part.Parent then
        if ui.viewport then ui.viewport:ClearAllChildren() end
        PenView.LastPart = nil
        return
    end
    
    local mesh = ui.viewport:FindFirstChildWhichIsA("BasePart")
    
    if PenView.LastPart ~= part or not mesh then
        PenView.LastPart = part
        ui.viewport:ClearAllChildren()
        
        local clone = part:Clone()
        clone.Transparency = 0.3
        clone.CanCollide = false
        clone.Anchored = true
        clone.Parent = ui.viewport
        
        mesh = clone
    end
    
    if not mesh then return end
    
    local ok = pcall(function()
        mesh.CFrame = part.CFrame
    end)
    if not ok then
        ui.viewport:ClearAllChildren()
        PenView.LastPart = nil
        return
    end
    
    ui.vpcam.CFrame = workspace.CurrentCamera.CFrame
    ui.vpcam.FieldOfView = workspace.CurrentCamera.FieldOfView
    
    local color
    if thickness <= 0.1 or pen <= 0 then
        color = Color3.fromRGB(90, 90, 90)
    elseif thickness <= pen * 0.5 then
        color = Color3.fromRGB(0, 255, 0)
    elseif thickness < pen then
        local t = (thickness - pen * 0.5) / (pen * 0.5)
        color = Color3.new(1, 1 - t, 0)
    else
        color = Color3.fromRGB(255, 0, 0)
    end
    mesh.Color = color
end

local function PenView_StartHeartbeat(ui)
    if PenView.HeartbeatConnection then PenView.HeartbeatConnection:Disconnect() end
    PenView.LastPart = nil
    
    PenView.HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not ui or not ui.viewport or not ui.viewport.Parent then
            if PenView.HeartbeatConnection then 
                PenView.HeartbeatConnection:Disconnect()
                PenView.HeartbeatConnection = nil
            end
            return
        end
        
        local vehicles = workspace:FindFirstChild("Vehicles")
        if not vehicles or not ui then
            if ui and ui.viewport then ui.viewport:ClearAllChildren() end
            return
        end
        
        local chassis = vehicles:FindFirstChild("Chassis" .. LocalPlayer.Name)
        if not chassis then
            if ui.viewport then ui.viewport:ClearAllChildren() end
            PenView.LastPart = nil
            PenView.LastChassisName = nil
            return
        end
        
        if chassis.Name ~= PenView.LastChassisName then
            PenView.LastChassisName = chassis.Name
            PenView.LastPart = nil
        end
        
        local gunBrick = PenView_FindGunBrick(chassis)
        if not gunBrick then return end
        
        local pen = PenView_GetPenetration()
        local origin = gunBrick.Position + gunBrick.CFrame.LookVector * 2
        local dir = gunBrick.CFrame.LookVector
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {chassis, workspace:FindFirstChild("Projectiles")}
        rayParams.IgnoreWater = true
        rayParams.CollisionGroup = "Default"
        
        local result = workspace:Raycast(origin, dir * 3000, rayParams)
        
        if result and result.Instance and table.find(PenView.ArmorTypes, result.Instance.Name) and result.Instance.CanCollide then
            if not ui.viewport:FindFirstChildWhichIsA("BasePart") then
                PenView.LastPart = nil
            end
            
            local thickness = PenView_GetArmorThickness(result.Instance, result.Position, dir, result.Normal)
            PenView_UpdateViewport(ui, result.Instance, thickness, pen)
        else
            if ui.viewport then ui.viewport:ClearAllChildren() end
            PenView.LastPart = nil
        end
    end)
end

local function PenView_Reset()
    if PenView.HeartbeatConnection then
        PenView.HeartbeatConnection:Disconnect()
        PenView.HeartbeatConnection = nil
    end
    PenView.LastPart = nil
    PenView.LastChassisName = nil

    PenView.UI = PenView_CreateUI()
    PenView_StartHeartbeat(PenView.UI)
end

local function PenView_Monitor()
    task.spawn(function()
        while Other.PenView do
            local vehicles = workspace:FindFirstChild("Vehicles")
            local chassis = vehicles and vehicles:FindFirstChild("Chassis" .. LocalPlayer.Name)
            
            if chassis and not PenView.HeartbeatConnection then
                PenView_Reset()
            elseif not chassis and PenView.HeartbeatConnection then
                if PenView.UI and PenView.UI.viewport then
                    PenView.UI.viewport:ClearAllChildren()
                end
            end
            task.wait(0.5)
        end
    end)
end

local PenView_VehiclesAddedConn
local PenView_VehiclesRemovedConn

local function PenView_Start()
    PenView_Reset()
    PenView_Monitor()
    
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        PenView_VehiclesAddedConn = vehiclesFolder.ChildAdded:Connect(function(child)
            if child.Name == "Vehicles" then
                task.wait(0.8)
                PenView_Reset()
            end
        end)
        
        PenView_VehiclesRemovedConn = vehiclesFolder.ChildRemoved:Connect(function(child)
            if child.Name == "Vehicles" then
                if PenView.UI and PenView.UI.viewport then
                    PenView.UI.viewport:ClearAllChildren()
                end
            end
        end)
    end
end

local function PenView_Stop()
    if PenView.HeartbeatConnection then
        PenView.HeartbeatConnection:Disconnect()
        PenView.HeartbeatConnection = nil
    end
    
    if PenView_VehiclesAddedConn then
        PenView_VehiclesAddedConn:Disconnect()
        PenView_VehiclesAddedConn = nil
    end
    
    if PenView_VehiclesRemovedConn then
        PenView_VehiclesRemovedConn:Disconnect()
        PenView_VehiclesRemovedConn = nil
    end
    
    local pg = LocalPlayer.PlayerGui
    local vp = pg:FindFirstChild("PenViewport")
    if vp then vp:Destroy() end
    
    PenView.UI = nil
    PenView.LastPart = nil
    PenView.LastChassisName = nil
end

-- ══════════════════════════════════════════════════════════════════════
-- CHASSIS BOX / NAME LABEL ESP POOL METHODS
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
-- AMMO LABEL + HIGHLIGHT POOL METHODS
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
        for key in pairs(Boxes)    do hideChassis(key) end
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

    for mp in pairs(AmmoLabels) do
        if not touchedAmmo[mp] then
            hideAmmo(mp)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════
-- WINDOW SETUP
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

-- ── TAB 3 — Combat / Pen View ─────────────────────────────────────────
local CombatTab = Window:AddTab("Pen View")
local PenGrp    = CombatTab:AddLeftGroupbox("Penetration Indicator")

PenGrp:AddToggle("PenViewToggle", {
    Text = "Enable Pen View", Default = false,
    Callback = function(v)
        Other.PenView = v
        if v then
            PenView_Start()
        else
            PenView_Stop()
        end
    end
})
