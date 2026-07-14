local UILibrary = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/ui5.lua"))()

local Draw = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/drawlib.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local _reg = {}
local function RegElem(id, kind, elem)
    _reg[id] = { elem = elem, kind = kind }
    return elem
end

local World = {
    RemoveGrass = false,

    TimeEnabled = false,
    Time = 14,

    AmbientEnabled = false,
    Ambient = Lighting.Ambient,

    OutdoorAmbientEnabled = false,
    OutdoorAmbient = Lighting.OutdoorAmbient,

    FogEnabled = false,
    FogColor = Lighting.FogColor,
    FogStart = 0,
    FogEnd = 100000,

    BrightnessEnabled = false,
    Brightness = Lighting.Brightness,
}

local BoxEnabled       = false
local BoxFilled        = true
local BoxColor         = Color3.fromRGB(255, 255, 255)
local BoxFillColor     = Color3.fromRGB(255, 0, 0)
local BoxFillTrans     = 0.7
local BoxThickness     = 1
local BoxRounding      = 0
local DistanceEnabled  = false -- NEW: Distance ESP Toggle
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

-- Aimbot
local AimbotEnabled    = false
local AimbotKey        = Enum.UserInputType.MouseButton2
local AimbotSmoothing  = 0.25
local IsAiming         = false

-- New Aimbot Logic Toggles
local AimTargetPart    = "Both" -- "Root", "Ammo", "Both"
local AimPrioritizePen = true
local AimStrictPen     = false

local FovEnabled      = false
local FovRadius       = 15
local FovColor        = Color3.fromRGB(255, 255, 255)
local FovThickness    = 1
local FovTransparency = 1

-- Penetration Viewer State
local Other = {
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
-- POOLS, CACHES & GLOBALS
-- ══════════════════════════════════════════════════════════════════════
local Boxes          = {}   
local NameLabels     = {}   
local AmmoLabels     = {}   
local AmmoHighlights = {}   

local AmmoCache      = {} 
local TeamColorCache = {} 

local FovCircle = Draw.new("Circle")
FovCircle.Visible = false
FovCircle.Filled = false
FovCircle.Thickness = FovThickness
FovCircle.Radius = 15
FovCircle.Color = FovColor
FovCircle.Transparency = FovTransparency

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
    local p = Players:FindFirstChild(playerName)
    if p and p.Team then
        return p.Team.TeamColor.Color
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
    local v = meshPart:GetAttribute("Ammo") or meshPart:GetAttribute("ammo") or 
              meshPart:GetAttribute("AmmoCount") or meshPart:GetAttribute("Count") or 
              meshPart:GetAttribute("Rounds")
    if v ~= nil then return tostring(v) end
    
    for _, val in pairs(meshPart:GetAttributes()) do
        if type(val) == "number" then return tostring(val) end
    end
    return "?"
end

-- ══════════════════════════════════════════════════════════════════════
-- INPUT HANDLING
-- ══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == AimbotKey or input.KeyCode == AimbotKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == AimbotKey or input.KeyCode == AimbotKey then
        IsAiming = false
    end
end)

-- ══════════════════════════════════════════════════════════════════════
-- PENETRATION LOGIC FOR AIMBOT AND ESP
-- ══════════════════════════════════════════════════════════════════════
local function PenView_CreateUI()
    for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "PenViewport" then v:Destroy() end
    end
    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.DisplayOrder = -100; sg.Name = "PenViewport"; sg.Parent = LocalPlayer.PlayerGui
    local vp = Instance.new("ViewportFrame", sg)
    vp.Size = UDim2.new(1, 0, 1, 0); vp.BackgroundTransparency = 1; vp.ImageTransparency = 0.25; vp.ZIndex = -100
    local cam = Instance.new("Camera")
    vp.CurrentCamera = cam; cam.CameraType = Enum.CameraType.Scriptable
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
    if not ui or not ui.viewport or not ui.viewport.Parent then return end
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
        clone.Transparency = 0.3; clone.CanCollide = false; clone.Anchored = true; clone.Parent = ui.viewport
        mesh = clone
    end
    if not mesh then return end
    pcall(function() mesh.CFrame = part.CFrame end)
    ui.vpcam.CFrame = workspace.CurrentCamera.CFrame
    ui.vpcam.FieldOfView = workspace.CurrentCamera.FieldOfView
    
    local color
    if thickness <= 0.1 or pen <= 0 then color = Color3.fromRGB(90, 90, 90)
    elseif thickness <= pen * 0.5 then color = Color3.fromRGB(0, 255, 0)
    elseif thickness < pen then
        local t = (thickness - pen * 0.5) / (pen * 0.5)
        color = Color3.new(1, 1 - t, 0)
    else color = Color3.fromRGB(255, 0, 0) end
    mesh.Color = color
end

local function PenView_StartHeartbeat(ui)
    if PenView.HeartbeatConnection then PenView.HeartbeatConnection:Disconnect() end
    PenView.LastPart = nil
    
    PenView.HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not ui or not ui.viewport or not ui.viewport.Parent then
            if PenView.HeartbeatConnection then PenView.HeartbeatConnection:Disconnect(); PenView.HeartbeatConnection = nil end
            return
        end
        
        local vehicles = workspace:FindFirstChild("Vehicles")
        local chassis = vehicles and vehicles:FindFirstChild("Chassis" .. LocalPlayer.Name)
        if not chassis then
            if ui.viewport then ui.viewport:ClearAllChildren() end
            PenView.LastPart = nil; PenView.LastChassisName = nil; return
        end
        if chassis.Name ~= PenView.LastChassisName then
            PenView.LastChassisName = chassis.Name; PenView.LastPart = nil
        end
        
        local gunBrick = PenView_FindGunBrick(chassis)
        if not gunBrick then return end
        
        local pen = PenView_GetPenetration()
        local origin = gunBrick.Position + gunBrick.CFrame.LookVector * 2
        local dir = gunBrick.CFrame.LookVector
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {chassis, workspace:FindFirstChild("Projectiles")}
        rayParams.IgnoreWater = true; rayParams.CollisionGroup = "Default"
        
        local result = workspace:Raycast(origin, dir * 3000, rayParams)
        if result and result.Instance and table.find(PenView.ArmorTypes, result.Instance.Name) and result.Instance.CanCollide then
            if not ui.viewport:FindFirstChildWhichIsA("BasePart") then PenView.LastPart = nil end
            local thickness = PenView_GetArmorThickness(result.Instance, result.Position, dir, result.Normal)
            PenView_UpdateViewport(ui, result.Instance, thickness, pen)
        else
            if ui.viewport then ui.viewport:ClearAllChildren() end
            PenView.LastPart = nil
        end
    end)
end

local function PenView_Reset()
    if PenView.HeartbeatConnection then PenView.HeartbeatConnection:Disconnect(); PenView.HeartbeatConnection = nil end
    PenView.LastPart = nil; PenView.LastChassisName = nil
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
                if PenView.UI and PenView.UI.viewport then PenView.UI.viewport:ClearAllChildren() end
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
            if child.Name == "Vehicles" then task.wait(0.8); PenView_Reset() end
        end)
        PenView_VehiclesRemovedConn = vehiclesFolder.ChildRemoved:Connect(function(child)
            if child.Name == "Vehicles" then
                if PenView.UI and PenView.UI.viewport then PenView.UI.viewport:ClearAllChildren() end
            end
        end)
    end
end

local function PenView_Stop()
    if PenView.HeartbeatConnection then PenView.HeartbeatConnection:Disconnect(); PenView.HeartbeatConnection = nil end
    if PenView_VehiclesAddedConn then PenView_VehiclesAddedConn:Disconnect(); PenView_VehiclesAddedConn = nil end
    if PenView_VehiclesRemovedConn then PenView_VehiclesRemovedConn:Disconnect(); PenView_VehiclesRemovedConn = nil end
    local vp = LocalPlayer.PlayerGui:FindFirstChild("PenViewport")
    if vp then vp:Destroy() end
    PenView.UI = nil; PenView.LastPart = nil; PenView.LastChassisName = nil
end

-- ══════════════════════════════════════════════════════════════════════
-- ESP POOL METHODS
-- ══════════════════════════════════════════════════════════════════════
local function getOrCreateChassis(key)
    if not Boxes[key] then
        local box = Draw.new("Square"); box.Visible = false; box.Filled = BoxFilled; box.Color = BoxColor
        box.FillColor = BoxFillColor; box.FillTransparency = BoxFillTrans; box.Thickness = BoxThickness
        box.Rounding = BoxRounding; box.Gradient = buildGradient(); box.GradientRotation = GradientRotation
        Boxes[key] = box
        local lbl = Draw.new("Text"); lbl.Visible = false; lbl.Size = 14; lbl.Center = true
        lbl.Outline = true; lbl.Color = Color3.fromRGB(255, 255, 255)
        NameLabels[key] = lbl
    end
    return Boxes[key], NameLabels[key]
end

local function removeChassis(key)
    if Boxes[key] then Boxes[key]:Remove(); Boxes[key] = nil end
    if NameLabels[key] then NameLabels[key]:Remove(); NameLabels[key] = nil end
end

local function hideChassis(key)
    if Boxes[key] then Boxes[key].Visible = false end
    if NameLabels[key] then NameLabels[key].Visible = false end
end

local function getOrCreateAmmo(mp)
    if not AmmoLabels[mp] then
        local lbl = Draw.new("Text"); lbl.Visible = false; lbl.Size = 13; lbl.Center = true
        lbl.Outline = true; lbl.Color = AmmoLabelColor
        AmmoLabels[mp] = lbl
    end
    if not AmmoHighlights[mp] then
        local hl = Instance.new("Highlight")
        hl.Adornee = mp; hl.FillColor = AmmoHighlightFillColor; hl.OutlineColor = AmmoHighlightOutlineColor
        hl.FillTransparency = AmmoHighlightFillTrans; hl.OutlineTransparency = AmmoHighlightOutlineTrans
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false; hl.Parent = mp
        AmmoHighlights[mp] = hl
    end
    return AmmoLabels[mp], AmmoHighlights[mp]
end

local function removeAmmo(mp)
    if AmmoLabels[mp] then AmmoLabels[mp]:Remove(); AmmoLabels[mp] = nil end
    if AmmoHighlights[mp] then pcall(function() AmmoHighlights[mp]:Destroy() end); AmmoHighlights[mp] = nil end
end

local function hideAmmo(mp)
    if AmmoLabels[mp] then AmmoLabels[mp].Visible = false end
    if AmmoHighlights[mp] then AmmoHighlights[mp].Enabled = false end
end

local function cleanupStaleChassis()
    local vehicles = workspace:FindFirstChild("Vehicles")
    for key in pairs(Boxes) do
        if not vehicles or not vehicles:FindFirstChild(key) then removeChassis(key) end
    end
    for chassis in pairs(AmmoCache) do
        if not vehicles or not chassis:IsDescendantOf(vehicles) then AmmoCache[chassis] = nil end
    end
end

local function cleanupStaleAmmo()
    for mp in pairs(AmmoLabels) do
        if not mp or not mp.Parent then removeAmmo(mp) end
    end
end

-- ══════════════════════════════════════════════════════════════════════
-- MAIN RENDER LOOP (Visuals, Aimbot, ESP)
-- ══════════════════════════════════════════════════════════════════════
local OriginalLighting = {
    ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, FogColor = Lighting.FogColor
}

RunService.RenderStepped:Connect(function()
    pcall(function() workspace.Terrain.Decoration = not World.RemoveGrass end)
    if World.TimeEnabled then Lighting.ClockTime = World.Time end
    if World.AmbientEnabled then Lighting.Ambient = World.Ambient end
    if World.OutdoorAmbientEnabled then Lighting.OutdoorAmbient = World.OutdoorAmbient end
    if World.BrightnessEnabled then Lighting.Brightness = World.Brightness end
    local atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if World.FogEnabled then
        Lighting.FogStart = World.FogStart; Lighting.FogEnd = World.FogEnd; Lighting.FogColor = World.FogColor
        if atmosphere then atmosphere.Density = 0 end
    end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local camCF = camera.CFrame
    local vehicles = workspace:FindFirstChild("Vehicles")
    local mouseLoc = UserInputService:GetMouseLocation()

    FovCircle.Visible = FovEnabled; FovCircle.Radius = FovRadius; FovCircle.Position = mouseLoc
    FovCircle.Color = FovColor; FovCircle.Thickness = FovThickness; FovCircle.Transparency = FovTransparency

    if not vehicles then
        for key in pairs(Boxes) do hideChassis(key) end
        for mp in pairs(AmmoLabels) do hideAmmo(mp) end
        cleanupStaleChassis(); cleanupStaleAmmo()
        return
    end

    cleanupStaleChassis(); cleanupStaleAmmo()

    local touchedAmmo = {}
    local bestTarget = nil
    local bestScore = math.huge
    
    local myChassis = vehicles:FindFirstChild("Chassis" .. LocalPlayer.Name)
    local myGunBrick = myChassis and PenView_FindGunBrick(myChassis)
    local myPenValue = myChassis and PenView_GetPenetration() or 0

    for _, chassis in ipairs(vehicles:GetChildren()) do
        local chassisName = chassis.Name
        if not chassisName:match("^Chassis") then continue end
        local playerName = getPlayerName(chassisName)
        if playerName == LocalPlayer.Name then continue end

        local playerObj = Players:FindFirstChild(playerName)
        if playerObj and playerObj.Team and LocalPlayer.Team and playerObj.Team == LocalPlayer.Team then
            hideChassis(chassisName); continue
        end

        local rootPt = chassis:FindFirstChild("VehicleSeat") or chassis.PrimaryPart or chassis:FindFirstChildWhichIsA("BasePart")
        
        local allAmmo = AmmoCache[chassis]
        if not allAmmo then
            allAmmo = collectAllAmmo(chassis)
            AmmoCache[chassis] = allAmmo
        end

        if AimbotEnabled and IsAiming then
            local potentialTargets = {}
            if AimTargetPart == "Both" or AimTargetPart == "Root" then
                if rootPt then table.insert(potentialTargets, {part = rootPt, isAmmo = false}) end
            end
            if AimTargetPart == "Both" or AimTargetPart == "Ammo" then
                for _, mp in ipairs(allAmmo) do
                    table.insert(potentialTargets, {part = mp, isAmmo = true})
                end
            end

            for _, tData in ipairs(potentialTargets) do
                local pt = tData.part
                local screenPos, onScreen = camera:WorldToViewportPoint(pt.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if dist <= FovRadius then
                        local score = dist
                        local isPenetrable = false

                        if tData.isAmmo then score = score - 1500 end 

                        if AimPrioritizePen and myGunBrick then
                            local origin = myGunBrick.Position
                            local dir = (pt.Position - origin).Unit
                            local rayDist = (pt.Position - origin).Magnitude
                            
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rayParams.FilterDescendantsInstances = {myChassis, workspace:FindFirstChild("Projectiles")}
                            
                            local result = workspace:Raycast(origin, dir * rayDist, rayParams)
                            if result and table.find(PenView.ArmorTypes, result.Instance.Name) then
                                local thickness = PenView_GetArmorThickness(result.Instance, result.Position, dir, result.Normal)
                                if thickness < myPenValue then
                                    isPenetrable = true
                                end
                            else
                                isPenetrable = true 
                            end
                            
                            if isPenetrable then
                                score = score - 5000 
                            elseif AimStrictPen then
                                continue 
                            end
                        end

                        if score < bestScore then
                            bestScore = score
                            bestTarget = pt
                        end
                    end
                end
            end
        end

        local box, nameLabel = getOrCreateChassis(chassisName)
        if rootPt and BoxEnabled then
            local rootPos, onScreen = camera:WorldToViewportPoint(rootPt.Position)
            if onScreen and rootPos.Z > 0 then
                local teamColor = getTeamColor(playerName)
                box.Color = teamColor or BoxColor

                local up = camCF.UpVector; local right = camCF.RightVector
                local topPos, onTop = camera:WorldToViewportPoint(rootPt.Position + up * 3)
                local bottomPos, onBottom = camera:WorldToViewportPoint(rootPt.Position - up * 3)
                local rightPos, onRight = camera:WorldToViewportPoint(rootPt.Position + right * 2)
                local leftPos, onLeft = camera:WorldToViewportPoint(rootPt.Position - right * 2)

                if onTop and onBottom and onRight and onLeft then
                    local width = math.abs(rightPos.X - leftPos.X); local height = math.abs(bottomPos.Y - topPos.Y)
                    box.Size = Vector2.new(width, height); box.Position = Vector2.new(rootPos.X - width / 2, topPos.Y); box.Visible = true
                    
                    -- IMPLEMENTED: Calculate distance and append to the ESP text[cite: 3]
                    local distMagnitude = (camera.CFrame.Position - rootPt.Position).Magnitude
                    local distText = DistanceEnabled and (" [" .. math.floor(distMagnitude) .. "s]") or ""
                    
                    nameLabel.Text = playerName .. distText
                    nameLabel.Position = Vector2.new(rootPos.X, topPos.Y - 16)
                    nameLabel.Color = teamColor or Color3.fromRGB(255, 255, 255); nameLabel.Visible = true
                else
                    hideChassis(chassisName)
                end
            else hideChassis(chassisName) end
        else hideChassis(chassisName) end

        for i, mp in ipairs(allAmmo) do
            touchedAmmo[mp] = true
            local lbl, hl = getOrCreateAmmo(mp)

            if AmmoHighlightEnabled then
                hl.FillColor = AmmoHighlightFillColor; hl.OutlineColor = AmmoHighlightOutlineColor
                hl.FillTransparency = AmmoHighlightFillTrans; hl.OutlineTransparency = AmmoHighlightOutlineTrans
                hl.Enabled = true
            else hl.Enabled = false end

            if AmmoLabelEnabled then
                local ammoPos, ammoOnScreen = camera:WorldToViewportPoint(mp.Position)
                if ammoOnScreen and ammoPos.Z > 0 then
                    local ammoVal = readAmmoAttribute(mp)
                    local prefix = #allAmmo > 1 and ("Rack " .. i .. " | ") or ""
                    lbl.Text = prefix .. "Ammo: " .. ammoVal
                    lbl.Position = Vector2.new(ammoPos.X, ammoPos.Y - 14)
                    lbl.Color = AmmoLabelColor; lbl.Visible = true
                else lbl.Visible = false end
            else lbl.Visible = false end
        end
    end

    for mp in pairs(AmmoLabels) do if not touchedAmmo[mp] then hideAmmo(mp) end end

    if IsAiming and AimbotEnabled and bestTarget and mousemoverel then
        local screenPos, onScreen = camera:WorldToViewportPoint(bestTarget.Position)
        if onScreen then
            local dX = (screenPos.X - mouseLoc.X) * AimbotSmoothing
            local dY = (screenPos.Y - mouseLoc.Y) * AimbotSmoothing
            mousemoverel(dX, dY)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════
-- WINDOW SETUP (CONFIG REGISTRATION APPLIED)
-- ══════════════════════════════════════════════════════════════════════
local Window = UILibrary.new({
    Name          = "Zest Hub",
    ToggleKey     = Enum.KeyCode.RightShift,
    CloseKey      = Enum.KeyCode.X,
    DefaultColor  = Color3.fromRGB(165, 127, 159),
    TextColor     = Color3.fromRGB(200, 200, 200),
    Size          = UDim2.new(0, 570, 0, 500),
    Position      = UDim2.new(0.226, 0, 0.146, 0),
    Watermark     = true,
    WatermarkText = "Zest Hub",
})

-- ── TAB 1 — Aimbot ────────────────────────────────────────────────────
local AimTab   = Window:AddTab("Aimbot")
local AimGrp   = AimTab:AddLeftGroupbox("Targeting")
local FovGrp   = AimTab:AddRightGroupbox("Field of View")

RegElem("AimToggle", "Toggle", AimGrp:AddToggle("AimToggle", {
    Text = "Enable Aimbot", Default = false,
    Callback = function(v) AimbotEnabled = v end
}))

RegElem("AimKeybind", "Dropdown", AimGrp:AddDropdown("AimKeybind", {
    Text = "Aim Keybind", Values = {"MouseButton2", "E", "Q", "C", "V", "LeftAlt"}, Default = 1, Multi = false,
    Callback = function(v)
        if v == "MouseButton2" then AimbotKey = Enum.UserInputType.MouseButton2
        else AimbotKey = Enum.KeyCode[v] end
    end,
}))

RegElem("AimSmoothing", "Slider", AimGrp:AddSlider("AimSmoothing", {
    Text = "Mouse Smoothing", Min = 0.05, Max = 1, Default = 0.25, Rounding = 2,
    Callback = function(v) AimbotSmoothing = v end,
}))

RegElem("AimTargetPart", "Dropdown", AimGrp:AddDropdown("AimTargetPart", {
    Text = "Target Parts", Values = {"Both", "Ammo", "Root"}, Default = 1, Multi = false,
    Callback = function(v) AimTargetPart = v end,
}))

RegElem("AimPrioritizePen", "Toggle", AimGrp:AddToggle("AimPrioritizePen", {
    Text = "Prioritize Penetrable Parts", Default = true,
    Tooltip = "Prioritizes targets where armor thickness is less than your shell pen.",
    Callback = function(v) AimPrioritizePen = v end
}))

RegElem("AimStrictPen", "Toggle", AimGrp:AddToggle("AimStrictPen", {
    Text = "Strict Penetration Mode", Default = false,
    Tooltip = "Aimbot will IGNORE parts it cannot penetrate.",
    Callback = function(v) AimStrictPen = v end
}))

RegElem("FovToggle", "Toggle", FovGrp:AddToggle("FovToggle", {
    Text = "Show FOV Circle", Default = false, HasColorPicker = true,
    Callback = function(v) FovEnabled = v end,
    ColorCallback = function(c) FovColor = toColor3(c) end,
}))

RegElem("FovRadiusSlider", "Slider", FovGrp:AddSlider("FovRadiusSlider", {
    Text = "FOV Radius", Min = 10, Max = 1000, Default = 150, Rounding = 0,
    Callback = function(v) FovRadius = v end,
}))

RegElem("FovThicknessSlider", "Slider", FovGrp:AddSlider("FovThicknessSlider", {
    Text = "FOV Thickness", Min = 1, Max = 5, Default = 1, Rounding = 1,
    Callback = function(v) FovThickness = v end,
}))

-- ── TAB 2 — Chassis ESP ───────────────────────────────────────────────
local MainTab  = Window:AddTab("ESP")
local LeftGrp  = MainTab:AddLeftGroupbox("Box ESP")
local RightGrp = MainTab:AddRightGroupbox("Fill & Gradient")

RegElem("BoxToggle", "Toggle", LeftGrp:AddToggle("BoxToggle", {
    Text = "Enable Box ESP", Default = false, HasColorPicker = true,
    Callback = function(v) BoxEnabled = v; if not v then for key in pairs(Boxes) do hideChassis(key) end end end,
    ColorCallback = function(c) BoxColor = toColor3(c) end,
}))

RegElem("BoxThicknessSlider", "Slider", LeftGrp:AddSlider("BoxThicknessSlider", {
    Text = "Outline Thickness", Min = 0, Max = 5, Default = 1, Rounding = 1,
    Callback = function(v) BoxThickness = v; for _, b in pairs(Boxes) do b.Thickness = v end end,
}))

RegElem("BoxRoundingSlider", "Slider", LeftGrp:AddSlider("BoxRoundingSlider", {
    Text = "Corner Rounding", Min = 0, Max = 12, Default = 0, Rounding = 1,
    Callback = function(v) BoxRounding = v; for _, b in pairs(Boxes) do b.Rounding = v end end,
}))

-- IMPLEMENTED: Distance Toggle UI Registration[cite: 3]
RegElem("DistanceToggle", "Toggle", LeftGrp:AddToggle("DistanceToggle", {
    Text = "Show Distance", Default = false,
    Callback = function(v) DistanceEnabled = v end,
}))

RegElem("BoxFillToggle", "Toggle", RightGrp:AddToggle("BoxFillToggle", {
    Text = "Enable Fill", Default = true, HasColorPicker = true,
    Callback = function(v) BoxFilled = v; for _, b in pairs(Boxes) do b.Filled = v end end,
    ColorCallback = function(c) BoxFillColor = toColor3(c); for _, b in pairs(Boxes) do b.FillColor = BoxFillColor end end,
}))

RegElem("BoxFillTransSlider", "Slider", RightGrp:AddSlider("BoxFillTransSlider", {
    Text = "Fill Transparency", Min = 0, Max = 100, Default = 70, Rounding = 2,
    Callback = function(v) BoxFillTrans = v / 100; for _, b in pairs(Boxes) do b.FillTransparency = BoxFillTrans end end,
}))

RegElem("BoxGradientStops", "Dropdown", RightGrp:AddDropdown("BoxGradientStops", {
    Text = "Gradient Stops", Values = { "2", "3" }, Default = 1, Multi = false,
    Callback = function(v) GradientStops = tonumber(v); if GradientEnabled then refreshGradient() end end,
}))

local espToggle = RegElem("BoxGradientToggle", "Toggle", RightGrp:AddToggle("BoxGradientToggle", {
    Text = "Enable Gradient", Default = false, HasColorPicker = true,
    Callback = function(v) GradientEnabled = v; refreshGradient() end,
    ColorCallback = function(c) GradientColorA = toColor3(c); if GradientEnabled then refreshGradient() end end,
}))

RegElem("GradientColorB", "ColorPicker", espToggle:AddColorPickerIcon("GradientColorB", { Default = GradientColorB, Callback = function(c) GradientColorB = toColor3(c); if GradientEnabled then refreshGradient() end end }))
RegElem("GradientColorC", "ColorPicker", espToggle:AddColorPickerIcon("GradientColorC", { Default = GradientColorC, Callback = function(c) GradientColorC = toColor3(c); if GradientEnabled and GradientStops == 3 then refreshGradient() end end }))

RegElem("BoxGradientRotation", "Slider", RightGrp:AddSlider("BoxGradientRotation", {
    Text = "Gradient Angle", Min = 0, Max = 360, Default = 90, Rounding = 1,
    Callback = function(v) GradientRotation = v; for _, b in pairs(Boxes) do b.GradientRotation = v end end,
}))

-- ── TAB 3 — Ammo ESP ──────────────────────────────────────────────────
local AmmoTab   = Window:AddTab("Ammo ESP")
local ALeftGrp  = AmmoTab:AddLeftGroupbox("Ammo Label")
local ARightGrp = AmmoTab:AddRightGroupbox("Ammo Highlight")

RegElem("AmmoLabelToggle", "Toggle", ALeftGrp:AddToggle("AmmoLabelToggle", {
    Text = "Show Ammo Labels", Default = true, HasColorPicker = true,
    Callback = function(v) AmmoLabelEnabled = v; if not v then for _, lbl in pairs(AmmoLabels) do lbl.Visible = false end end end,
    ColorCallback = function(c) AmmoLabelColor = toColor3(c); for _, lbl in pairs(AmmoLabels) do lbl.Color = AmmoLabelColor end end,
}))

RegElem("AmmoHighlightToggle", "Toggle", ARightGrp:AddToggle("AmmoHighlightToggle", {
    Text = "Highlight Ammo Mesh", Default = true, HasColorPicker = true,
    Callback = function(v) AmmoHighlightEnabled = v; if not v then for _, hl in pairs(AmmoHighlights) do hl.Enabled = false end end end,
    ColorCallback = function(c) AmmoHighlightFillColor = toColor3(c); for _, hl in pairs(AmmoHighlights) do hl.FillColor = AmmoHighlightFillColor end end,
}))

RegElem("HighlightFillTransSlider", "Slider", ARightGrp:AddSlider("HighlightFillTransSlider", {
    Text = "Fill Transparency", Min = 0, Max = 100, Default = 50, Rounding = 0,
    Callback = function(v) AmmoHighlightFillTrans = v / 100; for _, hl in pairs(AmmoHighlights) do hl.FillTransparency = AmmoHighlightFillTrans end end,
}))

RegElem("HighlightOutlineTransSlider", "Slider", ARightGrp:AddSlider("HighlightOutlineTransSlider", {
    Text = "Outline Transparency", Min = 0, Max = 100, Default = 0, Rounding = 0,
    Callback = function(v) AmmoHighlightOutlineTrans = v / 100; for _, hl in pairs(AmmoHighlights) do hl.OutlineTransparency = AmmoHighlightOutlineTrans end end,
}))

-- ── TAB 4 — Combat / Pen View ─────────────────────────────────────────
local CombatTab = Window:AddTab("Pen View")
local PenGrp    = CombatTab:AddLeftGroupbox("Penetration Indicator")

RegElem("PenViewToggle", "Toggle", PenGrp:AddToggle("PenViewToggle", {
    Text = "Enable Pen View", Default = false,
    Callback = function(v) Other.PenView = v; if v then PenView_Start() else PenView_Stop() end end
}))

-- ── TAB 5 — Visuals ───────────────────────────────────────────────────
local WorldTab = Window:AddTab("Visuals")
local WorldVis = WorldTab:AddLeftGroupbox("World")
local LightVis = WorldTab:AddRightGroupbox("Lighting")

RegElem("RemoveGrass", "Toggle", WorldVis:AddToggle("RemoveGrass", { Text = "Remove Grass", Default = false, Callback = function(v) World.RemoveGrass = v end }))
RegElem("TimeToggle", "Toggle", LightVis:AddToggle("TimeToggle", { Text = "Custom Time", Default = false, Callback = function(v) World.TimeEnabled = v; if not v then Lighting.ClockTime = OriginalLighting.ClockTime end end }))
RegElem("TimeSlider", "Slider", LightVis:AddSlider("TimeSlider", { Text = "Time", Min = 0, Max = 24, Default = 14, Rounding = 1, Callback = function(v) World.Time = v end }))
RegElem("BrightnessToggle", "Toggle", LightVis:AddToggle("BrightnessToggle", { Text = "Brightness", Default = false, Callback = function(v) World.BrightnessEnabled = v; if not v then Lighting.Brightness = OriginalLighting.Brightness end end }))
RegElem("BrightnessSlider", "Slider", LightVis:AddSlider("BrightnessSlider", { Text = "Brightness Amount", Min = 0, Max = 10, Default = Lighting.Brightness, Rounding = 1, Callback = function(v) World.Brightness = v end }))
RegElem("AmbientToggle", "Toggle", LightVis:AddToggle("AmbientToggle", { Text = "Ambient", Default = false, HasColorPicker = true, Callback = function(v) World.AmbientEnabled = v; if not v then Lighting.Ambient = OriginalLighting.Ambient end end, ColorCallback = function(c) World.Ambient = toColor3(c) end }))
RegElem("OutdoorAmbientToggle", "Toggle", LightVis:AddToggle("OutdoorAmbientToggle", { Text = "Outdoor Ambient", Default = false, HasColorPicker = true, Callback = function(v) World.OutdoorAmbientEnabled = v; if not v then Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient end end, ColorCallback = function(c) World.OutdoorAmbient = toColor3(c) end }))
RegElem("FogToggle", "Toggle", LightVis:AddToggle("FogToggle", { Text = "Custom Fog", Default = false, HasColorPicker = true, Callback = function(v) World.FogEnabled = v; if not v then Lighting.FogColor = OriginalLighting.FogColor; Lighting.FogStart = OriginalLighting.FogStart; Lighting.FogEnd = OriginalLighting.FogEnd; local atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere"); if atmosphere then atmosphere.Density = 0.3 end end end, ColorCallback = function(c) World.FogColor = toColor3(c) end }))
RegElem("FogStart", "Slider", LightVis:AddSlider("FogStart", { Text = "Fog Start", Min = 0, Max = 5000, Default = 0, Rounding = 0, Callback = function(v) World.FogStart = v end }))
RegElem("FogEnd", "Slider", LightVis:AddSlider("FogEnd", { Text = "Fog End", Min = 0, Max = 100000, Default = 100000, Rounding = 0, Callback = function(v) World.FogEnd = v end }))

-- ══════════════════════════════════════════════════════════════════════
-- FIXED CONFIGURATION MANAGER
-- ══════════════════════════════════════════════════════════════════════
local HttpService = game:GetService("HttpService")
local CFG_FOLDER  = "CursedTank"
local CFG_SUB     = "CursedTank/configs"
for _, p in ipairs({ CFG_FOLDER, CFG_SUB }) do
    if not isfolder(p) then makefolder(p) end
end

local function c3hex(c)
    return string.format("%02x%02x%02x",
        math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
end

local function buildSnapshot()
    local snap = {}
    for id, entry in pairs(_reg) do
        local e, kind = entry.elem, entry.kind
        if kind == "Toggle" then
            local val = type(e.GetValue) == "function" and e:GetValue() or (e.GetValue and e.GetValue()) or e.Value or false
            local col = e.ColorPicker and ((type(e.ColorPicker.GetColor) == "function" and e.ColorPicker:GetColor()) or (e.ColorPicker.GetColor and e.ColorPicker.GetColor()) or e.ColorPicker.Value)
            snap[id] = { k="T", v=val, c = col and c3hex(col) or nil }
        elseif kind == "Slider" then
            snap[id] = { k="S", v = type(e.GetValue) == "function" and e:GetValue() or (e.GetValue and e.GetValue()) or e.Value or 0 }
        elseif kind == "Dropdown" then
            snap[id] = { k="D", v = type(e.GetValue) == "function" and e:GetValue() or (e.GetValue and e.GetValue()) or e.Value or "" }
        elseif kind == "ColorPicker" then
            local col = type(e.GetColor) == "function" and e:GetColor() or (e.GetColor and e.GetColor()) or e.Value
            if col then snap[id] = { k="C", c = c3hex(col) } end
        elseif kind == "KeyPicker" then
            local key  = type(e.GetValue) == "function" and e:GetValue() or (e.GetValue and e.GetValue()) or e.Value
            local mode = type(e.GetMode) == "function" and e:GetMode() or (e.GetMode and e.GetMode()) or e.Mode
            if key then snap[id] = { k="K", v=key.Name, m=mode or "Toggle" } end
        end
    end
    return snap
end

local function applySnapshot(snap)
    for id, data in pairs(snap) do
        local entry = _reg[id]
        if not entry then continue end
        local e = entry.elem
        
        if data.k == "T" then
            local val = data.v == true
            if type(e.SetValue) == "function" then 
                pcall(function() e:SetValue(val) end) 
            elseif e.SetValue then 
                pcall(function() e.SetValue(val) end) 
            else 
                e.Value = val 
            end
            if entry.cb then pcall(entry.cb, val) end
            if data.c and e.ColorPicker then
                local ok, col = pcall(function() return Color3.fromHex(data.c) end)
                if ok and col then
                    if type(e.ColorPicker.SetColor) == "function" then 
                        pcall(function() e.ColorPicker:SetColor(col) end) 
                    elseif e.ColorPicker.SetColor then 
                        pcall(function() e.ColorPicker.SetColor(col) end) 
                    else 
                        e.ColorPicker.Value = col 
                    end
                    if entry.colorCb then pcall(entry.colorCb, col) end
                end
            end
            
        elseif data.k == "S" then
            -- Double check we are passing a valid number to sliders
            local val = tonumber(data.v) or 0
            if type(e.SetValue) == "function" then 
                local ok, err = pcall(function() e:SetValue(val) end)
                if not ok then
                    warn("[Config Error] Failed to set slider '" .. tostring(id) .. "': " .. tostring(err))
                end
            elseif e.SetValue then 
                pcall(function() e.SetValue(val) end) 
            else 
                e.Value = val 
            end
            if entry.cb then pcall(entry.cb, val) end
            
        elseif data.k == "D" then
            if data.v and data.v ~= "" then
                if type(e.SetValue) == "function" then 
                    pcall(function() e:SetValue(data.v) end) 
                elseif e.SetValue then 
                    pcall(function() e.SetValue(data.v) end) 
                else 
                    e.Value = data.v 
                end
                if entry.cb then pcall(entry.cb, data.v) end
            end
            
        elseif data.k == "C" then
            if data.c then
                local ok, col = pcall(function() return Color3.fromHex(data.c) end)
                if ok and col then
                    if type(e.SetColor) == "function" then 
                        pcall(function() e:SetColor(col) end) 
                    elseif e.SetColor then 
                        pcall(function() e.SetColor(col) end) 
                    else 
                        e.Value = col 
                    end
                    if entry.cb then pcall(entry.cb, col) end
                end
            end
            
        elseif data.k == "K" then
            if data.v and data.v ~= "" then
                local ok, kc = pcall(function() return Enum.KeyCode[data.v] end)
                if ok and kc then
                    if type(e.SetKey) == "function" then 
                        pcall(function() e:SetKey(kc) end) 
                    elseif e.SetKey then 
                        pcall(function() e.SetKey(kc) end) 
                    end
                    if data.m then
                        if type(e.SetMode) == "function" then 
                            pcall(function() e:SetMode(data.m) end) 
                        elseif e.SetMode then 
                            pcall(function() e.SetMode(data.m) end) 
                        end
                    end
                end
            end
        end
    end
end

local function cfgPath(name)   return CFG_SUB.."/"..name..".json" end

local function listConfigs()
    local out = {}
    for _, f in ipairs(listfiles(CFG_SUB)) do
        if f:sub(-5) == ".json" then
            local n = f:match("[/\\]([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
    end
    return out
end

local function saveConfig(name)
    if not name or name:gsub(" ","") == "" then return false, "empty name" end
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, buildSnapshot())
    if not ok then return false, "encode error" end
    writefile(cfgPath(name), enc)
    return true
end

local function loadConfig(name)
    if not name then return false, "no name" end
    if not isfile(cfgPath(name)) then return false, "not found" end
    local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(cfgPath(name)))
    if not ok then return false, "decode error" end
    applySnapshot(dec)
    return true
end

local function deleteConfig(name)
    if isfile(cfgPath(name)) then delfile(cfgPath(name)); return true end
    return false
end

local function getAutoload()
    local p = CFG_SUB.."/autoload.txt"
    return isfile(p) and readfile(p) or nil
end
local function setAutoload(name)
    writefile(CFG_SUB.."/autoload.txt", name or "")
end

task.spawn(function()
    task.wait(1)
    local auto = getAutoload()
    if auto and auto ~= "" then
        local ok = loadConfig(auto)
        print(ok and ("[Config] Auto-loaded: "..auto) or "[Config] Auto-load failed")
    end
end)

local CfgTab   = Window:AddTab("Config")
local CfgLeft  = CfgTab:AddLeftGroupbox("Actions")
local CfgRight = CfgTab:AddRightGroupbox("Configs")

local _cfgList   = listConfigs()
local _cfgSel    = nil
local _cfgSelLbl = nil

CfgRight:AddDropdown("CfgListDrop", {
    Text     = "Select Config",
    Values   = #_cfgList > 0 and _cfgList or {"(no configs yet)"},
    Default  = 1,
    Callback = function(v)
        if v == "(no configs yet)" then _cfgSel = nil; return end
        _cfgSel = v
        if _cfgSelLbl then _cfgSelLbl.SetText("Selected: "..v) end
    end,
})

_cfgSelLbl = CfgRight:AddLabel("Selected: none")

CfgRight:AddButton("CfgRefreshBtn", {
    Text = "Refresh List",
    Callback = function()
        _cfgList = listConfigs()
        local names = table.concat(_cfgList, ", ")
        print("[Config] "..#_cfgList.." config(s): "..(names ~= "" and names or "none"))
        Window:Notify(#_cfgList.." config(s) found", 1, 3)
    end,
})

local _autoLbl = CfgRight:AddLabel("Autoload: "..(getAutoload() or "none"))

CfgLeft:AddButton("CfgSaveNewBtn", {
    Text = "Save New Config",
    Callback = function()
        local name = "config_"..os.date("%m%d_%H%M%S")
        local ok, err = saveConfig(name)
        if ok then
            _cfgList = listConfigs()
            _cfgSel  = name
            if _cfgSelLbl then _cfgSelLbl.SetText("Selected: "..name) end
            print("[Config] Saved: "..name)
            Window:Notify("Saved: "..name, 2, 3)
        else
            warn("[Config] "..tostring(err))
            Window:Notify("Save failed: "..tostring(err), 3, 3)
        end
    end,
})

CfgLeft:AddButton("CfgLoadBtn", {
    Text = "Load Selected",
    Callback = function()
        if not _cfgSel then Window:Notify("Select a config first", 4, 3); return end
        local ok, err = loadConfig(_cfgSel)
        if ok then
            print("[Config] Loaded: ".._cfgSel)
            Window:Notify("Loaded: ".._cfgSel, 2, 3)
        else
            warn("[Config] "..tostring(err))
            Window:Notify("Load failed: "..tostring(err), 3, 3)
        end
    end,
})

CfgLeft:AddButton("CfgOverwriteBtn", {
    Text = "Overwrite Selected",
    Callback = function()
        if not _cfgSel then Window:Notify("Select a config first", 4, 3); return end
        local ok, err = saveConfig(_cfgSel)
        if ok then
            print("[Config] Overwritten: ".._cfgSel)
            Window:Notify("Overwritten: ".._cfgSel, 2, 3)
        else
            warn("[Config] "..tostring(err))
            Window:Notify("Overwrite failed: "..tostring(err), 3, 3)
        end
    end,
})

CfgLeft:AddButton("CfgDeleteBtn", {
    Text = "Delete Selected",
    Callback = function()
        if not _cfgSel then Window:Notify("Select a config first", 4, 3); return end
        deleteConfig(_cfgSel)
        print("[Config] Deleted: ".._cfgSel)
        Window:Notify("Deleted: ".._cfgSel, 3, 3)
        _cfgSel  = nil
        _cfgList = listConfigs()
        if _cfgSelLbl then _cfgSelLbl.SetText("Selected: none") end
    end,
})

CfgLeft:AddButton("CfgAutoloadBtn", {
    Text = "Set as Autoload",
    Callback = function()
        if not _cfgSel then Window:Notify("Select a config first", 4, 3); return end
        setAutoload(_cfgSel)
        _autoLbl.SetText("Autoload: ".._cfgSel)
        print("[Config] Autoload → ".._cfgSel)
        Window:Notify("Autoload set: ".._cfgSel, 2, 3)
    end,
})

CfgLeft:AddButton("CfgClearAutoBtn", {
    Text = "Clear Autoload",
    Callback = function()
        setAutoload("")
        _autoLbl.SetText("Autoload: none")
        print("[Config] Autoload cleared")
        Window:Notify("Autoload cleared", 1, 3)
    end,
})
