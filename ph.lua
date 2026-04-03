-- ============================================================
--  ZestHub  |  phv6
-- ============================================================
setfflag("DebugRunParallelLuaOnMainThread", "True")

task.wait(2)

if not LPH_OBFUSCATED then
    LPH_JIT          = function(f) return f end
    LPH_JIT_MAX      = function(f) return f end
    LPH_NO_VIRTUALIZE = function(f) return f end
    LPH_NO_UPVALUES  = function(f) return function(...) return f(...) end end
    LPH_ENCSTR       = function(s) return s end
    LPH_ENCNUM       = function(n) return n end
    LPH_CRASH        = function() return print("DEBUG CRASH") end
end

-- ==============================================================
--  MODULE BLOCK  (loader injects us inside a getgc loop so
--  `func` is already the ClientLoader require function)
-- ==============================================================
LPH_JIT_MAX(function()
    local modules = {}
    local moduleCache

    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "ScreenCull") and rawget(v, "NetworkClient") then
            moduleCache = v
            break
        end
    end

    if moduleCache then
        for name, data in moduleCache do
            if data then
                modules[name] = (type(data) == "table") and data.module or data
            end
        end
    else
        warn("[ZestHub] moduleCache not found - trying ClientLoader fallback")
        local ok, cache = pcall(function() return debug.getupvalue(func, 1)._cache end)
        if ok and cache then
            for name, data in cache do
                if data then modules[name] = (type(data) == "table") and data.module or data end
            end
        else
            warn("[ZestHub] FATAL: Cannot find modules")
            return
        end
    end

    local recoil             = modules.RecoilSprings
    local network            = modules.NetworkClient
    local firearmObject      = modules.FirearmObject
    local cameraObject       = modules.MainCameraObject
    local contentInterface   = modules.ContentInterface
    local hudScopeInterface  = modules.HudScopeInterface
    local unscaledScreenGui  = modules.UnscaledScreenGui
    local cameraInterface    = modules.CameraInterface
    local charInterface      = modules.CharacterInterface
    local publicSettings     = modules.PublicSettings
    local weaponInterface    = modules.WeaponControllerInterface
    local replicationInterface = modules.ReplicationInterface
    local bulletObject       = modules.BulletObject
    local playerDataUtils    = modules.PlayerDataUtils
    local playerClient       = modules.PlayerDataClientInterface
    local skinCaseUtils      = modules.SkinCaseUtils

    -- Silence third-person console spam
    if getfenv then
        pcall(function()
            getfenv(cameraInterface.setCameraType).print = function() end
            getfenv(cameraInterface.setCameraType).warn  = function() end
        end)
    end

    -- Expose to outer scope
    getgenv().ZH_replicationInterface = replicationInterface
    getgenv().ZH_weaponInterface      = weaponInterface
    getgenv().ZH_cameraInterface      = cameraInterface
    getgenv().ZH_publicSettings       = publicSettings
    getgenv().ZH_charInterface        = charInterface
    getgenv().ZH_bulletObject         = bulletObject
    getgenv().ZH_network              = network
    getgenv().ZH_playerDataUtils      = playerDataUtils
    getgenv().ZH_playerClient         = playerClient

    getHealth = LPH_NO_VIRTUALIZE(function(plr)
        local ok, hp = pcall(function() return replicationInterface.getEntry(plr):getHealth() end)
        return ok and hp or 100, 100
    end)

    -- RECOIL MULTIPLIER  (100 % = original / 0 % = no recoil, works for every gun)
    local applyImpulse = recoil.applyImpulse
    function recoil.applyImpulse(spring, x, y, ...)
        local pct = (getgenv().ZH_RecoilMultiplier ~= nil) and getgenv().ZH_RecoilMultiplier or 100
        -- 0 % → block entirely (no recoil)
        if pct <= 0 then return end
        -- 100 % → pass through unmodified (fully original recoil for every gun)
        if pct >= 100 then return applyImpulse(spring, x, y, ...) end
        -- anything in between → scale x and y impulse proportionally
        local factor = pct / 100
        return applyImpulse(spring,
            (type(x) == "number") and x * factor or x,
            (type(y) == "number") and y * factor or y,
            ...)
    end

    -- NO SPREAD + SMALL CROSSHAIR
    local getWeaponData = contentInterface.getWeaponData
    function contentInterface.getWeaponData(weaponName, makeClone)
        local data = getWeaponData(weaponName, makeClone)
        if makeClone then
            pcall(setreadonly, data, false)
            if getgenv().ZH_NoSpread then
                data.hipfirespread        = 0
                data.hipfirestability     = 99999
                data.hipfirespreadrecover = 99999
            end
            if getgenv().ZH_SmallCrosshair then
                data.crosssize = 10; data.crossexpansion = 0
                data.crossspeed = 100; data.crossdamper = 1
            end
        end
        return data
    end

    -- NO WALK SWAY
    local computeWalkSway = firearmObject.computeWalkSway
    function firearmObject:computeWalkSway(dy, dx)
        if getgenv().ZH_NoWalkSway then dy = 0; dx = 0 end
        return computeWalkSway(self, dy, dx)
    end

    -- NO GUN SWAY
    local computeGunSway = firearmObject.computeGunSway
    function firearmObject.computeGunSway(...)
        if getgenv().ZH_NoGunSway then return CFrame.identity end
        return computeGunSway(...)
    end

    -- NO CAMERA SWAY (hook cameraObject.step - same as source)
    local mainStep = cameraObject.step
    cameraObject.step = LPH_NO_VIRTUALIZE(function(self, dt)
        -- FOV override: set _baseFov before mainStep so the game uses our value
        pcall(function()
            if getgenv().Visual and getgenv().Visual.FieldOfView then
                self._baseFov = getgenv().Visual.FieldOfView
            end
        end)
        if getgenv().ZH_NoCameraSway then
            mainStep(self, 0)
            self._lookDt = dt
            return
        end
        return mainStep(self, dt)
    end)

    -- NO SNIPER SCOPE
    pcall(function()
        local sg = unscaledScreenGui.getScreenGui()
        local frontLayer = sg.DisplayScope.ImageFrontLayer
        local rearLayer  = sg.DisplayScope.ImageRearLayer
        local updateScope = hudScopeInterface.updateScope
        function hudScopeInterface.updateScope(...)
            local hide = getgenv().ZH_NoSniperScope
            frontLayer.ImageTransparency = hide and 1 or 0
            rearLayer.ImageTransparency  = hide and 1 or 0
            for _, layer in ipairs({frontLayer, rearLayer}) do
                for _, f in layer:GetChildren() do
                    if f.ClassName == "Frame" then f.Visible = not hide end
                end
            end
            return updateScope(...)
        end
    end)

    -- INSTANT RELOAD
    local reload = firearmObject.reload
    function firearmObject:reload()
        if getgenv().ZH_InstantReload and self._spareCount > 0 then
            if self._spareCount >= self._weaponData.magsize then
                self._spareCount = self._spareCount - (self._weaponData.magsize - self._magCount)
                self._magCount   = self._weaponData.magsize
            else
                self._magCount   = self._spareCount
                self._spareCount = 0
            end
            pcall(function() network:send("reload") end)
            return
        end
        return reload(self)
    end

end)()

-- ==============================================================
--  EXECUTOR COMPAT STUBS
-- ==============================================================
if not getgenv           then getgenv           = function() return _G end end
if not cloneref          then cloneref          = function(r) return r end end
if not clonefunction     then clonefunction     = function(f) return f end end
if not newcclosure       then newcclosure       = function(f) return f end end
if not hookfunction      then hookfunction      = function(o) return o end end
if not hookmetamethod    then hookmetamethod    = function(o, m, n) return n end end
if not getrenv           then getrenv           = function() return {} end end
if not getsenv           then getsenv           = function() return {} end end
if not getnilinstances   then getnilinstances   = function() return {} end end
if not checkcaller       then checkcaller       = function() return false end end

-- ==============================================================
--  SERVICES
-- ==============================================================
local runService      = cloneref(game:GetService("RunService"))
local replicatedFirst = cloneref(game:GetService("ReplicatedFirst"))
local Players         = cloneref(game:GetService("Players"))
local Lighting        = cloneref(game:GetService("Lighting"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService    = cloneref(game:GetService("TweenService"))
local camera          = workspace.CurrentCamera
local Camera          = cloneref(camera)
local player          = Players.LocalPlayer

local replicationInterface = getgenv().ZH_replicationInterface
local weaponInterface      = getgenv().ZH_weaponInterface
local cameraInterface      = getgenv().ZH_cameraInterface
local publicSettings       = getgenv().ZH_publicSettings
local charInterface        = getgenv().ZH_charInterface
local playerDataUtils      = getgenv().ZH_playerDataUtils
local playerClient         = getgenv().ZH_playerClient

-- ==============================================================
--  UNLOCK STATE
-- ==============================================================
local unlockAttachments = false
local unlockKnives      = false
local unlockCamos       = false

-- Weapon folder for knife unlock check (same path as source)
local weaponFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Content")
weaponFolder = weaponFolder and weaponFolder:FindFirstChild("ProductionContent")
weaponFolder = weaponFolder and weaponFolder:FindFirstChild("WeaponDatabase")

-- CamoDatabase lookup (identical fingerprint to source)
local camoDatabase
for _, v in getgc(true) do
    if type(v) == "table" and rawget(v, "Mentha Spicata") and rawget(v, "Dove blue") then
        camoDatabase = v
        break
    end
end

-- HOOK: Unlock All Attachments — inflate kills to max so all attachments appear owned
if playerDataUtils then
    local getUnlocksData = playerDataUtils.getUnlocksData
    function playerDataUtils.getUnlocksData(player)
        local unlocks = getUnlocksData(player)
        if playerClient and player == playerClient.getPlayerData() and unlockAttachments then
            local oldUnlocks = unlocks
            unlocks = setmetatable({}, {
                __index = function(_, index)
                    if not oldUnlocks[index] then oldUnlocks[index] = {} end
                    oldUnlocks[index].kills = 1000000000
                    return oldUnlocks[index]
                end,
                __newindex = function(_, index, value)
                    oldUnlocks[index] = value
                end
            })
        end
        return unlocks
    end

    -- HOOK: Unlock All Knives — return true for any knife category part
    local ownsWeapon = playerDataUtils.ownsWeapon
    function playerDataUtils.ownsWeapon(player, wepName)
        if unlockKnives and weaponFolder then
            for _, category in ipairs({"ONE HAND BLUNT","ONE HAND BLADE","TWO HAND BLUNT","TWO HAND BLADE"}) do
                local folder = weaponFolder:FindFirstChild(category)
                if folder and folder:FindFirstChild(string.upper(wepName)) then
                    return true
                end
            end
        end
        return ownsWeapon(player, wepName)
    end
end

getgenv().ZH_RecoilMultiplier = 100   -- 100 = full / 0 = none
getgenv().ZH_NoSpread       = false
getgenv().ZH_NoWalkSway     = false
getgenv().ZH_NoGunSway      = false
getgenv().ZH_NoCameraSway   = false
getgenv().ZH_NoSniperScope  = false
getgenv().ZH_InstantReload  = false
getgenv().ZH_SmallCrosshair = false

print("[ZestHub] Initializing...")

-- ==============================================================
--  ANTICHEAT BYPASS
-- ==============================================================
LPH_NO_VIRTUALIZE(function()
    replicatedFirst.ChildAdded:Connect(function(actor)
        if actor:IsA("Actor") then
            replicatedFirst.ChildAdded:Wait()
            for _, ls in next, actor:GetChildren() do
                ls.Parent = replicatedFirst
            end
        end
    end)
end)()

pcall(function()
    local s__i
    s__i = hookmetamethod(runService.Stepped, "__index", newcclosure(function(self, funcname)
        local fn = s__i(self, funcname)
        if funcname == "ConnectParallel" and not checkcaller() then
            hookfunction(fn, newcclosure(function(event, cb)
                return s__i(self, "Connect")(event, function()
                    return self:Wait() and cb()
                end)
            end))
        end
        return fn
    end))
end)

-- ==============================================================
--  GLOBAL SETTINGS
-- ==============================================================
getgenv().Light = {
    Shadows        = true,
    Ambient        = Color3.fromRGB(150, 150, 150),
    OutdoorAmbient = Color3.fromRGB(140, 140, 140),
    ClockTime      = Lighting.ClockTime,
    Brightness     = Lighting.Brightness,
    FogEnd         = Lighting.FogEnd,
    FogEnabled     = false,
}
getgenv().Visual = { FieldOfView = camera.FieldOfView }
getgenv().WorldExtra = {
    FullBright  = false,
    NoBlur      = false,
}

-- ==============================================================
--  PLAYER HIGHLIGHTS
-- ==============================================================
local highlights          = {}
local highlightConnection = nil

getgenv().HighlightColor            = Color3.fromRGB(255, 0, 0)
getgenv().HighlightFillTransparency = 0.5
getgenv().HighlightTeam             = false

local function createNeonHighlight(character)
    local parts = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local np = Instance.new("Part")
            np.Size = part.Size * 1.05; np.CFrame = part.CFrame
            np.Anchored = false; np.CanCollide = false
            np.CanQuery = false; np.CanTouch = false
            np.Material = Enum.Material.Neon
            np.Color = getgenv().HighlightColor
            np.Transparency = getgenv().HighlightFillTransparency
            np.CastShadow = false; np.Massless = true
            local w = Instance.new("WeldConstraint")
            w.Part0 = part; w.Part1 = np; w.Parent = np
            np.Parent = character
            table.insert(parts, np)
        end
    end
    return {parts = parts}
end

local function removeHighlight(h)
    if not h or not h.parts then return end
    for _, p in pairs(h.parts) do pcall(function() p:Destroy() end) end
end

local function playerhighlights(state)
    if highlightConnection then highlightConnection:Disconnect(); highlightConnection = nil end
    for _, h in pairs(highlights) do removeHighlight(h) end
    highlights = {}
    if not state then return end
    highlightConnection = runService.Heartbeat:Connect(function()
        local seen = {}
        if replicationInterface then
            replicationInterface.operateOnAllEntries(function(plr, entry)
                local tp   = entry._thirdPersonObject
                local char = tp and tp._character
                if char then
                    seen[char] = true
                    if not highlights[char] then
                        if not entry._isEnemy and not getgenv().HighlightTeam then return end
                        highlights[char] = createNeonHighlight(char)
                    end
                end
            end)
        end
        for char, h in pairs(highlights) do
            if not seen[char] then removeHighlight(h); highlights[char] = nil end
        end
    end)
end
getgenv().playerhighlights = playerhighlights

-- ==============================================================
--  WEAPON CHAMS
-- ==============================================================
local weaponChamsModels    = {}
local weaponChamsConnection = nil
getgenv().WeaponChamsColor = Color3.fromRGB(255, 0, 0)

local function findWeaponInModel(model)
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("Model") and child.Name ~= "Character" then return child end
    end
end

local function weaponchams(state)
    if weaponChamsConnection then weaponChamsConnection:Disconnect(); weaponChamsConnection = nil end
    for _, c in pairs(weaponChamsModels) do if c and c.Parent then c:Destroy() end end
    weaponChamsModels = {}
    if not state then return end
    weaponChamsConnection = runService.Heartbeat:Connect(function()
        if not replicationInterface then return end
        replicationInterface.operateOnAllEntries(function(plr, entry)
            if not entry._isEnemy then return end
            local tp   = entry._thirdPersonObject
            local char = tp and tp._character
            if not char then return end
            local weapon = findWeaponInModel(char)
            if weapon and not weapon:FindFirstChild("_ZHCham") then
                local cham = weapon:Clone()
                local tag  = Instance.new("BoolValue"); tag.Name = "_ZHCham"; tag.Parent = cham
                for _, p in ipairs(cham:GetDescendants()) do
                    if p:IsA("BasePart") and p.Transparency ~= 1 then
                        p.Color        = getgenv().WeaponChamsColor
                        p.Material     = Enum.Material.Neon
                        p.Transparency = 0.3
                    end
                end
                cham.Parent = char
                table.insert(weaponChamsModels, cham)
            end
        end)
    end)
end
getgenv().weaponchams = weaponchams

-- ==============================================================
--  AIMBOT
-- ==============================================================
local pi  = math.pi
local tau = pi * 2

local function solve(v44, v45, v46, v47, v48)
    if not v44 then return
    elseif v44 > -1e-10 and v44 < 1e-10 then return solve(v45,v46,v47,v48)
    else
        if v48 then
            local v49 = -v45/(4*v44)
            local v50 = (v46+v49*(3*v45+6*v44*v49))/v44
            local v51 = (v47+v49*(2*v46+v49*(3*v45+4*v44*v49)))/v44
            local v52 = (v48+v49*(v47+v49*(v46+v49*(v45+v44*v49))))/v44
            if v51>-1e-10 and v51<1e-10 then
                local v53,v54 = solve(1,v50,v52)
                if not v54 or v54<0 then return end
                return v49-math.sqrt(v54), v49-math.sqrt(v53), v49+math.sqrt(v53), v49+math.sqrt(v54)
            else
                local v57,_,v59 = solve(1,2*v50,v50*v50-4*v52,-v51*v51)
                local v60 = v59 or v57; local v61 = math.sqrt(v60)
                local v62,v63 = solve(1,v61,(v60+v50-v51/v61)/2)
                local v64,v65 = solve(1,-v61,(v60+v50+v51/v61)/2)
                if v62 and v64 then return v49+v62,v49+v63,v49+v64,v49+v65
                elseif v62 then return v49+v62,v49+v63
                elseif v64 then return v49+v64,v49+v65 end
            end
        elseif v47 then
            local v66=-v45/(3*v44)
            local v67=-(v46+v66*(2*v45+3*v44*v66))/(3*v44)
            local v68=-(v47+v66*(v46+v66*(v45+v44*v66)))/(2*v44)
            local v69=v68*v68-v67*v67*v67
            local v70=math.sqrt(math.abs(v69))
            if v69>0 then
                local a=v68+v70; local b=v68-v70
                a = a<0 and -(-a)^(1/3) or a^(1/3)
                b = b<0 and -(-b)^(1/3) or b^(1/3)
                return v66+a+b
            else
                local v74=math.atan2(v70,v68)/3; local v75=2*math.sqrt(v67)
                return v66-v75*math.sin(v74+pi/6), v66+v75*math.sin(v74-pi/6), v66+v75*math.cos(v74)
            end
        elseif v46 then
            local v76=-v45/(2*v44); local v77=v76*v76-v46/v44
            if v77<0 then return end
            local v78=math.sqrt(v77); return v76-v78, v76+v78
        elseif v45 then
            return -v45/v44
        end
    end
end

local function complexTrajectory(o, a, t, s, e)
    local ld = t - o; a = -a; e = e or Vector3.zero
    local r1,r2,r3,r4 = solve(
        a:Dot(a)*0.25, a:Dot(e),
        a:Dot(ld)+e:Dot(e)-s^2,
        ld:Dot(e)*2, ld:Dot(ld)
    )
    local x = (r1 and r1>0 and r1) or (r2 and r2>0 and r2) or (r3 and r3>0 and r3) or r4
    if not x then return nil end
    return (ld + e*x + 0.5*a*x^2)/x, x
end

local function toanglesyx(v)
    local x,y,z = v.X, v.Y, v.Z
    return math.asin(y/(x*x+y*y+z*z)^0.5), math.atan2(-x,-z), 0
end

getgenv().ZH_Aimbot = {
    Enabled    = false,
    FOVRadius  = 200,
    ShowFOV    = false,
    FOVColor   = Color3.fromRGB(255,255,255),
    Smoothness = 0.1,
    TargetPart = "Head",
    VisCheck   = false,
    RequireAim = true,
}

local aimbotFOVCircle = Drawing.new("Circle")
aimbotFOVCircle.Color     = Color3.fromRGB(255,255,255)
aimbotFOVCircle.Radius    = 200
aimbotFOVCircle.NumSides  = 64
aimbotFOVCircle.Visible   = false
aimbotFOVCircle.Filled    = false
aimbotFOVCircle.Thickness = 1

local movementCache  = {time = {}, position = {}}
local aimTime        = nil
local aimbotting     = false

local rayParams = RaycastParams.new()
-- FIX: Blacklist deprecated in newer Roblox; fall back gracefully
rayParams.FilterType = (Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist)
local function visCheck(origin, target)
    local ignore = {camera}
    if workspace:FindFirstChild("Players") then table.insert(ignore, workspace.Players) end
    if workspace:FindFirstChild("Ignore")  then table.insert(ignore, workspace.Ignore) end
    rayParams.FilterDescendantsInstances = ignore
    return workspace:Raycast(origin, target - origin, rayParams) == nil
end

local function getClosest(origin, fovRadius, partName)
    local bestDist = fovRadius or math.huge
    local bestPos, bestEntry
    if not replicationInterface then return end
    replicationInterface.operateOnAllEntries(function(plr, entry)
        if not entry._isEnemy then return end
        local tp       = entry._thirdPersonObject
        local charHash = tp and tp._characterModelHash
        if not charHash then return end
        local part = charHash[partName] or charHash["Torso"] or charHash["Head"]
        if not part then return end
        local worldPos   = part.Position
        local sp         = camera:WorldToViewportPoint(worldPos)
        if sp.Z <= 0 then return end
        local screenDist = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
        if screenDist < bestDist then
            if getgenv().ZH_Aimbot.VisCheck and not visCheck(camera.CFrame.Position, worldPos) then return end
            bestDist  = screenDist
            bestPos   = worldPos
            bestEntry = entry
        end
    end)
    return bestPos, bestEntry
end

runService.Stepped:Connect(function()
    if not replicationInterface then return end
    replicationInterface.operateOnAllEntries(function(plr, entry)
        if not entry._isEnemy then return end
        local tp       = entry._thirdPersonObject
        local charHash = tp and tp._characterModelHash
        movementCache.position[plr] = movementCache.position[plr] or {}
        if charHash and charHash.Head then
            table.insert(movementCache.position[plr], 1, charHash.Head.Position)
            if #movementCache.position[plr] > 15 then table.remove(movementCache.position[plr]) end
        end
    end)
    table.insert(movementCache.time, 1, os.clock())
    if #movementCache.time > 15 then table.remove(movementCache.time) end
end)

local lastAimbotTick = 0
runService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
    local circleCenter = camera.ViewportSize * 0.5
    aimbotFOVCircle.Position = circleCenter
    aimbotFOVCircle.Visible  = getgenv().ZH_Aimbot.ShowFOV
    aimbotFOVCircle.Color    = getgenv().ZH_Aimbot.FOVColor
    aimbotFOVCircle.Radius   = getgenv().ZH_Aimbot.FOVRadius

    aimbotting = false

    -- Rate-limit aimbot to 30fps (same as source)
    local now = tick()
    if now - lastAimbotTick < 1/30 then return end
    lastAimbotTick = now

    if not getgenv().ZH_Aimbot.Enabled then aimTime = nil; return end
    if not weaponInterface or not cameraInterface then return end

    local ctrl   = weaponInterface.getActiveWeaponController()
    local weapon = ctrl and ctrl:getActiveWeapon()
    if not weapon then aimTime = nil; return end
    if getgenv().ZH_Aimbot.RequireAim and not weapon._aiming then aimTime = nil; return end

    local clockTime = os.clock()
    local target, entry = getClosest(circleCenter, getgenv().ZH_Aimbot.FOVRadius, getgenv().ZH_Aimbot.TargetPart)
    if not target or not entry then aimTime = nil; return end

    local plr   = entry._player
    local cache = movementCache.position[plr]
    -- Require 15 samples to match source exactly — stable velocity prediction
    if not cache or not cache[15] then return end
    if not movementCache.time[15] then return end

    -- cache[1]=newest, cache[15]=oldest (items inserted at index 1, newest-first)
    -- time[1]=newest,  time[15]=oldest
    -- (old-new)/(old_time-new_time) → both differences negative → correct positive velocity
    local tDelta = movementCache.time[15] - movementCache.time[1]
    if math.abs(tDelta) < 1e-4 then return end

    local velocity = complexTrajectory(
        camera.CFrame * Vector3.new(0, 0, 0.5),
        publicSettings and publicSettings.bulletAcceleration or Vector3.new(0, -workspace.Gravity, 0),
        target,
        (weapon._weaponData and weapon._weaponData.bulletspeed) or 10000,
        (cache[15] - cache[1]) / tDelta
    )
    if not velocity then return end

    aimbotting = true
    aimTime = aimTime or clockTime

    local vx, vy = toanglesyx(velocity)
    local camObj = cameraInterface.getActiveCamera()
    if not camObj then return end

    local cy  = camObj._angles.y
    -- Direct ternary clamp matching source (no fallback defaults needed)
    local x   = vx > camObj._maxAngle and camObj._maxAngle or vx < camObj._minAngle and camObj._minAngle or vx
    local y   = (vy + pi - cy) % tau - pi + cy
    local newAngles = Vector3.new(x, y, 0)
    local smoothing = getgenv().ZH_Aimbot.Smoothness

    if smoothing ~= 0 then
        -- Vector3:lerp() is lowercase in Roblox Luau
        newAngles = camObj._angles:lerp(newAngles,
            math.clamp(1 - smoothing + (clockTime - aimTime)^2, 0, 1))
    end

    camObj._delta  = (newAngles - camObj._angles) / dt
    camObj._angles = newAngles

    -- FIX: only clear aimTime when no longer aimbotting (matches source)
    aimTime = aimbotting and aimTime
end))

-- ==============================================================
--  BULLET TRACERS
-- ==============================================================
getgenv().BulletTracers = {
    Enabled = false, Color = Color3.fromRGB(255,0,0),
    TextureID = "rbxassetid://446111271",
    Transparency = 0, Size = 0.3, TimeAlive = 2, FadeTime = 0.3,
}

local function CreateBulletTracer(startPos, endPos)
    if not getgenv().BulletTracers.Enabled then return end
    local bt = getgenv().BulletTracers

    local function makePart(pos)
        local p = Instance.new("Part")
        p.Anchored = true; p.CanCollide = false; p.Transparency = 1
        p.Size = Vector3.new(0.2,0.2,0.2); p.Material = Enum.Material.ForceField
        p.CanTouch = false; p.CanQuery = false; p.Massless = true
        p.Position = pos; p.Parent = workspace
        return p
    end

    local sp, ep = makePart(startPos), makePart(endPos)
    local a0 = Instance.new("Attachment", sp)
    local a1 = Instance.new("Attachment", ep)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a0; beam.Attachment1 = a1
    beam.Parent = sp; beam.FaceCamera = true
    beam.Color = ColorSequence.new(bt.Color)
    beam.Texture = bt.TextureID; beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(bt.Transparency)
    beam.Width0 = bt.Size; beam.Width1 = bt.Size

    task.delay(bt.TimeAlive, function()
        if beam and beam.Parent then
            TweenService:Create(beam,
                TweenInfo.new(bt.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Width0 = 0, Width1 = 0 }):Play()
            task.wait(bt.FadeTime)
        end
        pcall(function() sp:Destroy() end)
        pcall(function() ep:Destroy() end)
    end)
end

-- ==============================================================
--  SILENT AIM
-- ==============================================================
getgenv().ZH_SilentAim = {
    Enabled   = false,
    FOVRadius = 300,
    ShowFOV   = false,
    FOVColor  = Color3.fromRGB(255, 255, 255),
    VisCheck  = false,
    TargetPart = "Head",
}

local silentAimFOVCircle = Drawing.new("Circle")
silentAimFOVCircle.Color    = Color3.fromRGB(255,255,255)
silentAimFOVCircle.Radius   = 300
silentAimFOVCircle.NumSides = 48
silentAimFOVCircle.Visible  = false
silentAimFOVCircle.Filled   = false
silentAimFOVCircle.Thickness = 1

runService.RenderStepped:Connect(function()
    silentAimFOVCircle.Position = camera.ViewportSize * 0.5
    silentAimFOVCircle.Visible  = getgenv().ZH_SilentAim.Enabled and getgenv().ZH_SilentAim.ShowFOV
    silentAimFOVCircle.Color    = getgenv().ZH_SilentAim.FOVColor
    silentAimFOVCircle.Radius   = getgenv().ZH_SilentAim.FOVRadius
end)

-- ==============================================================
--  HITMARKER
-- ==============================================================
getgenv().ZH_Hitmarker = {
    Enabled   = false,
    Color     = Color3.fromRGB(255, 255, 255),
    KillColor = Color3.fromRGB(255, 50,  50),
    Size      = 10,
    Thickness = 2,
    Duration  = 0.3,
}

local hitmarkerLines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Thickness = 2
    l.Color     = Color3.fromRGB(255,255,255)
    hitmarkerLines[i] = l
end

local function showHitmarker(isKill)
    if not getgenv().ZH_Hitmarker.Enabled then return end
    local hm   = getgenv().ZH_Hitmarker
    local cx   = camera.ViewportSize.X / 2
    local cy   = camera.ViewportSize.Y / 2
    local s    = hm.Size
    local col  = isKill and hm.KillColor or hm.Color

    -- top-left → bottom-right, top-right → bottom-left (×)
    local dirs = {
        {Vector2.new(cx-s, cy-s), Vector2.new(cx-2, cy-2)},
        {Vector2.new(cx+s, cy+s), Vector2.new(cx+2, cy+2)},
        {Vector2.new(cx+s, cy-s), Vector2.new(cx+2, cy-2)},
        {Vector2.new(cx-s, cy+s), Vector2.new(cx-2, cy+2)},
    }
    for i, l in ipairs(hitmarkerLines) do
        l.From      = dirs[i][1]
        l.To        = dirs[i][2]
        l.Color     = col
        l.Thickness = hm.Thickness
        l.Visible   = true
    end

    task.delay(hm.Duration, function()
        for _, l in ipairs(hitmarkerLines) do l.Visible = false end
    end)
end

-- ==============================================================
--  SILENT AIM HELPER  (shared by both hooks)
-- ==============================================================
local function getSilentAimTarget()
    local sa       = getgenv().ZH_SilentAim
    local center   = camera.ViewportSize * 0.5
    local bestDist = sa.FOVRadius
    local bestPos, bestEntry

    if replicationInterface then
        replicationInterface.operateOnAllEntries(function(plr, entry)
            if not entry._isEnemy then return end
            local tp       = entry._thirdPersonObject
            local charHash = tp and tp._characterModelHash
            if not charHash then return end
            local part = charHash[sa.TargetPart] or charHash["Head"] or charHash["Torso"]
            if not part then return end
            local wp = part.Position
            local sp = camera:WorldToViewportPoint(wp)
            if sp.Z <= 0 then return end
            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if d < bestDist then
                if sa.VisCheck then
                    local rp = RaycastParams.new()
                    rp.FilterType = (Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist)
                    rp.FilterDescendantsInstances = {camera, workspace.Players}
                    if workspace:Raycast(camera.CFrame.Position, wp - camera.CFrame.Position, rp) then return end
                end
                bestDist  = d
                bestPos   = wp
                bestEntry = entry
            end
        end)
    end
    return bestPos, bestEntry
end

local function getSilentAimVelocityUnit(firepos, targetPos, bulletspeed, targetVel)
    if not targetPos then return nil end
    local vel = complexTrajectory(
        firepos,
        publicSettings and publicSettings.bulletAcceleration or Vector3.new(0, -workspace.Gravity, 0),
        targetPos,
        bulletspeed or 10000,
        targetVel or Vector3.zero
    )
    return vel and vel.Unit or nil
end

-- ==============================================================
--  NETWORK SEND HOOK  (redirects "newbullets" → actual damage)
-- ==============================================================
-- This is the hook that makes silent aim deal damage.
-- bulletObject.new only affects local hit detection visuals.
-- The server uses the "newbullets" packet direction to register hits.
local zhNetwork = getgenv().ZH_network
if zhNetwork then
    local origSend = zhNetwork.send
    function zhNetwork:send(name, ...)
        if name == "newbullets" and getgenv().ZH_SilentAim.Enabled then
            local uniqueId, bulletData, time = ...
            if bulletData and bulletData.bullets and bulletData.firepos then
                local ctrl   = weaponInterface and weaponInterface.getActiveWeaponController()
                local weapon = ctrl and ctrl:getActiveWeapon()
                local bspeed = weapon and weapon._weaponData and weapon._weaponData.bulletspeed or 10000

                local targetPos, targetEntry = getSilentAimTarget()
                if targetPos and targetEntry then
                    local plr = targetEntry._player
                    local cache = movementCache.position[plr]
                    local targetVel = Vector3.zero
                    if cache and cache[15] and movementCache.time[15] then
                        local tDelta = movementCache.time[15] - movementCache.time[1]
                        if math.abs(tDelta) > 1e-4 then
                            targetVel = (cache[15] - cache[1]) / tDelta
                        end
                    end
                    local unitVel = getSilentAimVelocityUnit(bulletData.firepos, targetPos, bspeed, targetVel)
                    if unitVel then
                        for _, bullet in bulletData.bullets do
                            bullet[1] = unitVel  -- bullet[1] is the direction unit vector
                        end
                    end
                end
            end
            return origSend(self, name, ...)
        end
        return origSend(self, name, ...)
    end
end

-- ==============================================================
--  BULLETOBJECT HOOK  (local hit detection + tracers + hitmarker)
-- ==============================================================
local bulletObject = getgenv().ZH_bulletObject

if bulletObject then
    local newbullet = bulletObject.new
    function bulletObject.new(bulletData)
        if bulletData.onplayerhit then

            -- ── SILENT AIM (local sim redirect) ─────────────────────────
            if getgenv().ZH_SilentAim.Enabled then
                local targetPos, targetEntry = getSilentAimTarget()
                if targetPos and targetEntry then
                    local plr   = targetEntry._player
                    local cache = movementCache.position[plr]
                    -- Use cached velocity for lead prediction if 15 samples available
                    local targetVel = Vector3.zero
                    if cache and cache[15] and movementCache.time[15] then
                        local tDelta = movementCache.time[15] - movementCache.time[1]
                        if math.abs(tDelta) > 1e-4 then
                            targetVel = (cache[15] - cache[1]) / tDelta
                        end
                    end
                    local vel = complexTrajectory(
                        bulletData.position,
                        bulletData.acceleration or (publicSettings and publicSettings.bulletAcceleration) or Vector3.new(0, -workspace.Gravity, 0),
                        targetPos,
                        bulletData.velocity.Magnitude,
                        targetVel
                    )
                    if vel then bulletData.velocity = vel end
                end
            end

            -- ── BULLET TRACERS (Beam-based) ──────────────────────────────
            if getgenv().BulletTracers.Enabled then
                local firePos = bulletData.position
                local fireDir = bulletData.velocity.Unit
                local fireSpd = bulletData.velocity.Magnitude
                -- Simulate ~1.5s of flight for the full visual path
                local simEnd  = firePos + fireDir * (fireSpd * 1.5)
                task.spawn(function()
                    CreateBulletTracer(firePos, simEnd)
                end)
            end

            -- ── HITMARKER ───────────────────────────────────────────────
            -- Wrap onplayerhit to fire hitmarker when a hit is confirmed
            if getgenv().ZH_Hitmarker.Enabled then
                local origHit = bulletData.onplayerhit
                bulletData.onplayerhit = function(...)
                    local args = {...}                          -- capture varargs before nesting
                    local result = origHit(table.unpack(args))
                    task.spawn(function()
                        local isKill = false
                        pcall(function()
                            local hitPlayer = args[1]           -- use captured table, not ...
                            if hitPlayer then
                                local entry = replicationInterface and replicationInterface.getEntry(hitPlayer)
                                isKill = entry and (entry:getHealth() <= 0)
                            end
                        end)
                        showHitmarker(isKill)
                    end)
                    return result
                end
            end
        end

        return newbullet(bulletData)
    end
end

-- ==============================================================
--  ESP
--
--  ROOT CAUSE OF OLD ESP SHOWING NOTHING:
--  Used entry._thirdPersonObject (raw field) instead of
--  entry:getThirdPersonObject() (method), and did not check
--  entry:isReady() or entry._smoothReplication._prevFrameTime.
--  Without those checks, all character lookups returned nil
--  every single frame.
-- ==============================================================
local ESP = {}
ESP.enabled    = false
ESP.entries    = {}
ESP.updateConn = nil

ESP.settings = {
    enemyColor         = Color3.fromRGB(255, 50, 50),
    teamColor          = Color3.fromRGB(50, 255, 50),
    showTeamESP        = false,
    thickness          = 1.5,
    textSize           = 14,
    showHealthBar      = true,
    healthBarThickness = 2,
    showHealthText     = true,
    showWeaponText     = true,
    showDistance       = false,
    showTracer         = false,
    tracerColor        = Color3.fromRGB(255, 100, 100),
    showBoxFill        = false,
    boxFillColor       = Color3.fromRGB(255, 50, 50),
    boxFillOpacity     = 0.3,
}

local function newLine(color, thickness)
    local l = Drawing.new("Line")
    l.Color = color or Color3.new(1,1,1); l.Thickness = thickness or 1; l.Visible = false; return l
end
local function newText(size, color)
    local t = Drawing.new("Text")
    t.Size = size or 13; t.Color = color or Color3.new(1,1,1)
    t.Outline = true; t.Center = true; t.Visible = false; return t
end
local function newSquare(filled)
    local s = Drawing.new("Square"); s.Filled = filled or false; s.Visible = false; return s
end

local function createESPObjects()
    return {
        Box          = newSquare(false),
        BoxFill      = newSquare(true),
        HealthBG     = newLine(Color3.new(0,0,0), 4),
        HealthBar    = newLine(Color3.new(0,1,0), 2),
        HealthText   = newText(10, Color3.fromRGB(220,220,220)),
        NameText     = newText(14, Color3.new(1,1,1)),
        WeaponText   = newText(10, Color3.fromRGB(200,200,255)),
        DistanceText = newText(10, Color3.fromRGB(180,180,180)),
        Tracer       = newLine(Color3.fromRGB(255,100,100), 1),
    }
end

local function removeESPObjects(obj)
    for _, d in pairs(obj) do pcall(function() d:Remove() end) end
end
local function hideESPObjects(obj)
    for _, d in pairs(obj) do d.Visible = false end
end
local function healthColor(pct)
    if pct > 75 then return Color3.new(0,1,0)
    elseif pct > 50 then return Color3.new(1,1,0)
    elseif pct > 25 then return Color3.new(1,0.5,0)
    else return Color3.new(1,0,0) end
end

-- THE KEY FIX: use methods like source espInterface.getCharacter
local function getEntryData(entry)
    local charModel, rootPart
    pcall(function()
        if not entry:isReady() then return end
        local sm = entry._smoothReplication
        -- FIX: was "if not sm._prevFrameTime" — 0 is falsy in Lua, causing valid
        -- players to be skipped. Use ~= nil so any number (including 0) passes.
        if not sm or sm._prevFrameTime == nil then return end
        local tp = entry:getThirdPersonObject()
        if not tp then return end
        charModel = tp:getCharacterModel()
        rootPart  = tp:getRootPart()
    end)
    -- Fallback to raw fields in case methods are unavailable
    if not charModel then
        pcall(function()
            local tp = entry._thirdPersonObject
            if tp then charModel = tp._character; rootPart = tp._rootPart end
        end)
    end
    return charModel, rootPart
end

local function renderEntry(obj, entry, s)
    local charModel, rootPart = getEntryData(entry)
    if not charModel then hideESPObjects(obj); return end

    local ok, bCF, bSize = pcall(function() return charModel:GetBoundingBox() end)
    if not ok or not bCF then hideESPObjects(obj); return end

    local half = bSize / 2
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local onScreen = false

    for _, dir in ipairs({
        Vector3.new( 1, 1, 1), Vector3.new( 1, 1,-1),
        Vector3.new( 1,-1, 1), Vector3.new( 1,-1,-1),
        Vector3.new(-1, 1, 1), Vector3.new(-1, 1,-1),
        Vector3.new(-1,-1, 1), Vector3.new(-1,-1,-1),
    }) do
        local sp = camera:WorldToViewportPoint(bCF:PointToWorldSpace(half * dir))
        if sp.Z > 0 then
            onScreen = true
            minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
            maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
        end
    end

    if not onScreen then hideESPObjects(obj); return end

    local px, py = minX, minY
    local pw, ph = maxX - minX, maxY - minY
    local color  = entry._isEnemy and s.enemyColor or s.teamColor

    -- Box outline
    obj.Box.Position  = Vector2.new(px, py)
    obj.Box.Size      = Vector2.new(pw, ph)
    obj.Box.Color     = color
    obj.Box.Thickness = s.thickness
    obj.Box.Visible   = true

    -- Box fill
    if s.showBoxFill then
        obj.BoxFill.Position     = Vector2.new(px, py)
        obj.BoxFill.Size         = Vector2.new(pw, ph)
        obj.BoxFill.Color        = s.boxFillColor
        obj.BoxFill.Transparency = 1 - s.boxFillOpacity
        obj.BoxFill.Visible      = true
    else obj.BoxFill.Visible = false end

    -- Name
    local plr     = entry._player
    obj.NameText.Text     = plr and plr.Name or "?"
    obj.NameText.Size     = s.textSize
    obj.NameText.Color    = color
    obj.NameText.Position = Vector2.new(px + pw/2, py - s.textSize - 2)
    obj.NameText.Visible  = true

    -- Health via entry:getHealth() (same as source)
    local hp = 100
    pcall(function() hp = entry:getHealth() end)
    local hpPct = math.clamp(hp, 0, 100)
    local barX  = px - 6
    local fill  = ph * (hpPct / 100)

    if s.showHealthBar then
        obj.HealthBG.From      = Vector2.new(barX, py)
        obj.HealthBG.To        = Vector2.new(barX, py + ph)
        obj.HealthBG.Thickness = s.healthBarThickness + 2
        obj.HealthBG.Visible   = true
        obj.HealthBar.From      = Vector2.new(barX, py + ph)
        obj.HealthBar.To        = Vector2.new(barX, py + ph - fill)
        obj.HealthBar.Color     = healthColor(hpPct)
        obj.HealthBar.Thickness = s.healthBarThickness
        obj.HealthBar.Visible   = true
        if s.showHealthText then
            obj.HealthText.Text     = math.floor(hp + 0.5) .. " HP"
            obj.HealthText.Position = Vector2.new(barX - 2, py + ph/2)
            obj.HealthText.Visible  = true
        else obj.HealthText.Visible = false end
    else
        obj.HealthBG.Visible  = false
        obj.HealthBar.Visible = false
        obj.HealthText.Visible = false
    end

    local bOff = 2
    -- Weapon
    if s.showWeaponText then
        local wepName = "?"
        pcall(function()
            local wobj = entry:getWeaponObject()
            if entry:isAlive() and wobj then wepName = wobj.weaponName or "?" end
        end)
        obj.WeaponText.Text     = "[" .. wepName .. "]"
        obj.WeaponText.Color    = Color3.fromRGB(200, 200, 255)
        obj.WeaponText.Position = Vector2.new(px + pw/2, py + ph + bOff)
        obj.WeaponText.Visible  = true
        bOff = bOff + 12
    else obj.WeaponText.Visible = false end

    -- Distance
    if s.showDistance and rootPart then
        local dist = math.floor((camera.CFrame.Position - rootPart.Position).Magnitude + 0.5)
        obj.DistanceText.Text     = dist .. "m"
        obj.DistanceText.Position = Vector2.new(px + pw/2, py - s.textSize - 16)
        obj.DistanceText.Visible  = true
    else obj.DistanceText.Visible = false end

    -- Tracer
    if s.showTracer then
        obj.Tracer.From      = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
        obj.Tracer.To        = Vector2.new(px + pw/2, py + ph)
        obj.Tracer.Color     = s.tracerColor
        obj.Tracer.Thickness = s.thickness
        obj.Tracer.Visible   = true
    else obj.Tracer.Visible = false end
end

function ESP:startLoop()
    if self.updateConn then return end
    self.updateConn = runService.Heartbeat:Connect(function()
        if not self.enabled or not replicationInterface then return end
        local alive = {}
        replicationInterface.operateOnAllEntries(function(plr, entry)
            if plr == player then return end
            if not entry._isEnemy and not self.settings.showTeamESP then return end
            alive[entry] = true
            if not self.entries[entry] then self.entries[entry] = createESPObjects() end
            renderEntry(self.entries[entry], entry, self.settings)
        end)
        for entry, obj in pairs(self.entries) do
            if not alive[entry] then removeESPObjects(obj); self.entries[entry] = nil end
        end
    end)
end

function ESP:stopLoop()
    if self.updateConn then self.updateConn:Disconnect(); self.updateConn = nil end
end

function ESP:clearAll()
    for _, obj in pairs(self.entries) do removeESPObjects(obj) end
    self.entries = {}
end

function ESP:setEnabled(state)
    self.enabled = state
    if state then self:startLoop() else self:stopLoop(); self:clearAll() end
end

_G.ESP = ESP

-- ==============================================================
--  HIGHLIGHT ESP  (native Roblox Highlight instances)
--  Much cheaper than neon-part highlights and renders through walls.
-- ==============================================================
getgenv().ZH_HighlightESP = {
    Enabled           = false,
    ShowTeam          = false,
    EnemyFill         = Color3.fromRGB(255, 50,  50),
    EnemyFillAlpha    = 0.5,
    EnemyOutline      = Color3.fromRGB(255, 255, 255),
    EnemyOutlineAlpha = 0,
    TeamFill          = Color3.fromRGB(50,  220, 50),
    TeamFillAlpha     = 0.5,
    TeamOutline       = Color3.fromRGB(255, 255, 255),
    TeamOutlineAlpha  = 0,
}

local _hlCache   = {}  -- [entry] = Highlight instance
local _hlConn    = nil
local _hlFolder  = nil
pcall(function()
    _hlFolder = Instance.new("Folder")
    _hlFolder.Name   = "ZH_HighlightESP"
    _hlFolder.Parent = game:GetService("CoreGui")
end)

local function _hlGetChar(entry)
    local char
    pcall(function()
        if entry.isReady and not entry:isReady() then return end
        local tp = entry.getThirdPersonObject and entry:getThirdPersonObject()
        if tp then char = (tp.getCharacterModel and tp:getCharacterModel()) or tp._character end
        if not char then
            local tpR = entry._thirdPersonObject
            char = tpR and tpR._character
        end
    end)
    return char
end

local function startHighlightESP()
    if _hlConn then return end
    _hlConn = runService.Heartbeat:Connect(function()
        local cfg = getgenv().ZH_HighlightESP
        if not cfg.Enabled or not replicationInterface then return end
        local alive = {}
        replicationInterface.operateOnAllEntries(function(plr, entry)
            if plr == player then return end
            if not entry._isEnemy and not cfg.ShowTeam then return end
            local char = _hlGetChar(entry)
            if not char then return end
            alive[entry] = true
            -- Create highlight if missing
            if not _hlCache[entry] then
                local h = Instance.new("Highlight")
                h.Name             = "ZH_HL"
                h.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent           = _hlFolder or workspace
                _hlCache[entry]    = h
            end
            local h = _hlCache[entry]
            h.Adornee = char
            if entry._isEnemy then
                h.FillColor           = cfg.EnemyFill
                h.FillTransparency    = cfg.EnemyFillAlpha
                h.OutlineColor        = cfg.EnemyOutline
                h.OutlineTransparency = cfg.EnemyOutlineAlpha
            else
                h.FillColor           = cfg.TeamFill
                h.FillTransparency    = cfg.TeamFillAlpha
                h.OutlineColor        = cfg.TeamOutline
                h.OutlineTransparency = cfg.TeamOutlineAlpha
            end
        end)
        for entry, h in pairs(_hlCache) do
            if not alive[entry] then
                pcall(function() h:Destroy() end)
                _hlCache[entry] = nil
            end
        end
    end)
end

local function stopHighlightESP()
    if _hlConn then _hlConn:Disconnect(); _hlConn = nil end
    for _, h in pairs(_hlCache) do pcall(function() h:Destroy() end) end
    _hlCache = {}
end

getgenv().ZH_StartHighlightESP = startHighlightESP
getgenv().ZH_StopHighlightESP  = stopHighlightESP

-- ==============================================================
--  ARM / GUN CHAMS  (hooks camera.ChildAdded like source)
--  Arms  = Model that contains a child named "Arm"
--  Guns  = Model that does NOT contain "Arm"
-- ==============================================================
getgenv().ZH_ArmChams = {
    Enabled      = false,
    Color        = Color3.fromRGB(255, 100, 50),
    Material     = "Neon",
    Transparency = 0,
}
getgenv().ZH_GunChams = {
    Enabled      = false,
    Color        = Color3.fromRGB(50, 200, 255),
    Material     = "Neon",
    Transparency = 0,
}

local chamMaterialEnum = {
    Neon        = Enum.Material.Neon,
    ForceField  = Enum.Material.ForceField,
    Glass       = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic,
}

local function applyChamToModel(model, cfg)
    for _, p in model:GetDescendants() do
        if p:IsA("BasePart") then
            pcall(function()
                p.Color        = cfg.Color
                p.Material     = chamMaterialEnum[cfg.Material] or Enum.Material.Neon
                p.Transparency = cfg.Transparency
                p.CastShadow   = false
            end)
        end
    end
end

local function removeChamFromModel(model, originals)
    if not originals then return end
    for _, p in model:GetDescendants() do
        if p:IsA("BasePart") and originals[p] then
            pcall(function()
                p.Color        = originals[p].Color
                p.Material     = originals[p].Material
                p.Transparency = originals[p].Transparency
                p.CastShadow   = originals[p].CastShadow
            end)
        end
    end
end

local function snapshotModel(model)
    local snap = {}
    for _, p in model:GetDescendants() do
        if p:IsA("BasePart") then
            snap[p] = {
                Color        = p.Color,
                Material     = p.Material,
                Transparency = p.Transparency,
                CastShadow   = p.CastShadow,
            }
        end
    end
    return snap
end

local chamTracked = {}   -- [model] = {isArm, originals, connection}

camera.ChildAdded:Connect(function(model)
    if model.ClassName ~= "Model" then return end
    task.defer(function()   -- defer so all children have loaded
        local isArm = model:FindFirstChild("Arm") ~= nil
        local cfg   = isArm and getgenv().ZH_ArmChams or getgenv().ZH_GunChams
        if not cfg.Enabled then return end

        local originals = snapshotModel(model)
        applyChamToModel(model, cfg)

        local conn = model:GetPropertyChangedSignal("Parent"):Connect(function()
            if model.Parent ~= camera then
                removeChamFromModel(model, originals)
                if chamTracked[model] then
                    chamTracked[model].connection:Disconnect()
                    chamTracked[model] = nil
                end
            end
        end)
        chamTracked[model] = { isArm = isArm, originals = originals, connection = conn }
    end)
end)

-- Exported helpers so UI callbacks can re-apply to already-loaded models
local function refreshCameraChams()
    for model, data in pairs(chamTracked) do
        local cfg = data.isArm and getgenv().ZH_ArmChams or getgenv().ZH_GunChams
        if cfg.Enabled then
            applyChamToModel(model, cfg)
        else
            removeChamFromModel(model, data.originals)
        end
    end
end
getgenv().ZH_RefreshChams = refreshCameraChams

-- ==============================================================
--  ENEMY CHAMS  (source-style cham.new pattern – overrides BasePart
--  properties every RenderStepped frame so they persist through
--  the game's own material resets)
-- ==============================================================
getgenv().ZH_EnemyChams = {
    Enabled      = false,
    Color        = Color3.fromRGB(255, 50,  50),
    TeamColor    = Color3.fromRGB(50,  255, 50),
    ShowTeam     = false,
    Material     = "Neon",
    Transparency = 0.3,
}

local enemyChamCache    = {}   -- [entry] = { parts={}, originals={}, isEnemy=bool }
local enemyChamConn     = nil
local chamMatLookup     = {
    Neon          = Enum.Material.Neon,
    ForceField    = Enum.Material.ForceField,
    Glass         = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic,
}

local function ecCollectParts(model)
    local parts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            table.insert(parts, p)
        end
    end
    return parts
end

local function ecSnapshot(parts)
    local snap = {}
    for _, p in ipairs(parts) do
        snap[p] = { Color=p.Color, Material=p.Material,
                    Transparency=p.Transparency, CastShadow=p.CastShadow }
    end
    return snap
end

local function ecApply(data)
    local cfg = getgenv().ZH_EnemyChams
    local col = data.isEnemy and cfg.Color or cfg.TeamColor
    local mat = chamMatLookup[cfg.Material] or Enum.Material.Neon
    for _, p in ipairs(data.parts) do
        pcall(function()
            if p.Transparency == 1 then return end  -- keep invisible parts invisible (like source)
            p.Color        = col
            p.Material     = mat
            p.Transparency = cfg.Transparency
            p.CastShadow   = false
        end)
    end
end

local function ecRestore(data)
    for _, p in ipairs(data.parts) do
        local orig = data.originals[p]
        if orig then
            pcall(function()
                p.Color        = orig.Color
                p.Material     = orig.Material
                p.Transparency = orig.Transparency
                p.CastShadow   = orig.CastShadow
            end)
        end
    end
end

local function startEnemyChams()
    if enemyChamConn then return end
    enemyChamConn = runService.Heartbeat:Connect(function()
        local cfg = getgenv().ZH_EnemyChams
        if not cfg.Enabled or not replicationInterface then return end

        local alive = {}
        replicationInterface.operateOnAllEntries(function(plr, entry)
            if plr == player then return end
            if not entry._isEnemy and not cfg.ShowTeam then return end

            local charModel
            pcall(function()
                if entry.isReady and not entry:isReady() then return end
                local tp = entry.getThirdPersonObject and entry:getThirdPersonObject()
                if tp then
                    charModel = (tp.getCharacterModel and tp:getCharacterModel())
                             or tp._character
                end
                if not charModel then
                    local tpRaw = entry._thirdPersonObject
                    charModel = tpRaw and tpRaw._character
                end
            end)
            if not charModel then return end

            alive[entry] = true

            if not enemyChamCache[entry] then
                local parts = ecCollectParts(charModel)
                if #parts == 0 then return end
                enemyChamCache[entry] = {
                    parts     = parts,
                    originals = ecSnapshot(parts),
                    isEnemy   = entry._isEnemy,
                }
            end

            ecApply(enemyChamCache[entry])
        end)

        -- clean up stale entries and restore their materials
        for entry, data in pairs(enemyChamCache) do
            if not alive[entry] then
                ecRestore(data)
                enemyChamCache[entry] = nil
            end
        end
    end)
end

local function stopEnemyChams()
    if enemyChamConn then enemyChamConn:Disconnect(); enemyChamConn = nil end
    for _, data in pairs(enemyChamCache) do ecRestore(data) end
    enemyChamCache = {}
end

getgenv().ZH_StartEnemyChams = startEnemyChams
getgenv().ZH_StopEnemyChams  = stopEnemyChams

-- ==============================================================
--  LIGHTING / FOV HEARTBEAT
-- ==============================================================
-- Cache original sky so we can restore it
local _originalSky = Lighting:FindFirstChildOfClass("Sky")

runService.Heartbeat:Connect(function(dt)
    local L  = getgenv().Light
    local WE = getgenv().WorldExtra

    -- FullBright overrides ambient + brightness
    if WE and WE.FullBright then
        Lighting.GlobalShadows  = false
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness     = 10
    else
        Lighting.GlobalShadows  = L.Shadows
        Lighting.Ambient        = L.Ambient
        Lighting.OutdoorAmbient = L.OutdoorAmbient
        Lighting.Brightness     = L.Brightness
    end

    Lighting.ClockTime = L.ClockTime

    if L.FogEnabled then
        Lighting.FogEnd   = L.FogEnd
        Lighting.FogStart = 0
    end

    -- NoBlur: disable any BlurEffect / DepthOfField the game re-adds
    if WE and WE.NoBlur then
        for _, fx in Lighting:GetChildren() do
            if fx:IsA("BlurEffect") or fx:IsA("DepthOfFieldEffect") then
                pcall(function() fx.Enabled = false end)
            end
        end
    end
end)

-- ==============================================================
--  UI
-- ==============================================================
print("[ZestHub] Loading UI library...")
local UILibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nafe03/Zest-Hub/refs/heads/main/ui4.lua"))()

local Window = UILibrary.new({
    Name = "ZestHub", ToggleKey = Enum.KeyCode.RightShift,
    DefaultColor = Color3.fromRGB(165, 127, 160),
    TextColor    = Color3.fromRGB(200, 200, 200),
    Size         = UDim2.new(0, 600, 0, 500),
    Position     = UDim2.new(0.226, 0, 0.146, 0),
    Watermark    = true, WatermarkText = "ZestHub",
})

-- ==============================================================
--  ELEMENT REGISTRY  (auto-registers every UI element by id
--  so the config system can snapshot and restore them all)
-- ==============================================================
local _reg = {}   -- [id] = { elem, kind, cb, colorCb }

local function _wrap(group)
    local orig_toggle    = group.AddToggle
    local orig_slider    = group.AddSlider
    local orig_dropdown  = group.AddDropdown
    local orig_colorpick = group.AddColorPicker
    local orig_label     = group.AddLabel
    local orig_keypicker = group.AddKeyPicker

    group.AddToggle = function(self, id, opts)
        local e = orig_toggle(self, id, opts)
        _reg[id] = { elem=e, kind="Toggle", cb=opts and opts.Callback, colorCb=opts and opts.ColorCallback }
        return e
    end
    group.AddSlider = function(self, id, opts)
        local e = orig_slider(self, id, opts)
        _reg[id] = { elem=e, kind="Slider", cb=opts and opts.Callback }
        return e
    end
    group.AddDropdown = function(self, id, opts)
        local e = orig_dropdown(self, id, opts)
        _reg[id] = { elem=e, kind="Dropdown", cb=opts and opts.Callback }
        return e
    end
    if orig_colorpick then
        group.AddColorPicker = function(self, id, opts)
            local e = orig_colorpick(self, id, opts)
            _reg[id] = { elem=e, kind="ColorPicker", cb=opts and opts.Callback }
            return e
        end
    end
    if orig_keypicker then
        group.AddKeyPicker = function(self, id, opts)
            local e = orig_keypicker(self, id, opts)
            _reg[id] = { elem=e, kind="KeyPicker", cb=opts and opts.Callback }
            return e
        end
    end
    if orig_label then
        group.AddLabel = function(self, text)
            local lbl = orig_label(self, text)
            if lbl and lbl.AddColorPicker then
                local origLblCP = lbl.AddColorPicker
                lbl.AddColorPicker = function(lself, id, opts)
                    local e = origLblCP(lself, id, opts)
                    _reg[id] = { elem=e, kind="ColorPicker", cb=opts and opts.Callback }
                    return e
                end
            end
            return lbl
        end
    end
    return group
end

local function _wrapTab(tab)
    local origL = tab.AddLeftGroupbox
    local origR = tab.AddRightGroupbox
    tab.AddLeftGroupbox  = function(self, name) return _wrap(origL(self, name)) end
    tab.AddRightGroupbox = function(self, name) return _wrap(origR(self, name)) end
    return tab
end

-- Wrap Window.AddTab so every future tab auto-wraps its groupboxes
local _origAddTab = Window.AddTab
Window.AddTab = function(self, name) return _wrapTab(_origAddTab(self, name)) end

local ESPTab     = Window:AddTab("ESP")
local AimbotTab  = Window:AddTab("Aimbot")
local GunModsTab = Window:AddTab("Gun Mods")
local WorldTab   = Window:AddTab("World")
local VisualsTab = Window:AddTab("Visuals")
local BulletTab  = Window:AddTab("Bullet")
local TweaksTab  = Window:AddTab("Tweaks")

-- ESP tab groupboxes
local ESPGroupbox       = ESPTab:AddLeftGroupbox("Box ESP")
local ESPDisplayGroup   = ESPTab:AddRightGroupbox("Display Options")
local HighlightESPGroup = ESPTab:AddLeftGroupbox("Highlight ESP")
local HighlightESPRight = ESPTab:AddRightGroupbox("Highlight Colors")

-- Aimbot tab
local AimbotGroup      = AimbotTab:AddLeftGroupbox("Aimbot")
local AimbotFOVGroup   = AimbotTab:AddRightGroupbox("FOV & Options")

-- Gun Mods tab
local GunModsGroup     = GunModsTab:AddLeftGroupbox("Gun Mods")
local GunModsGroup2    = GunModsTab:AddRightGroupbox("Advanced")

-- World tab (clean, no gimmicks)
local WorldGroupbox    = WorldTab:AddLeftGroupbox("Lighting")
local WorldGroupbox2   = WorldTab:AddRightGroupbox("Environment")

-- Visuals tab
local WeaponChamsGroup = VisualsTab:AddLeftGroupbox("Weapon Chams")
local HighlightGroup   = VisualsTab:AddRightGroupbox("Player Highlights")
local ArmChamsGroup    = VisualsTab:AddLeftGroupbox("Arm Chams")
local GunChamsGroup    = VisualsTab:AddRightGroupbox("Gun Chams")
local EnemyChamsGroup  = VisualsTab:AddLeftGroupbox("Enemy Chams")

-- Bullet tab
local BulletTracerGroup = BulletTab:AddLeftGroupbox("Bullet Tracers")
local SilentAimGroup    = BulletTab:AddRightGroupbox("Silent Aim")
local HitmarkerGroup    = BulletTab:AddLeftGroupbox("Hitmarker")

-- Tweaks tab
local TweaksGroup  = TweaksTab:AddLeftGroupbox("Unlocks")

-- ESP
ESPGroupbox:AddToggle("ESPEnabled", {
    Text = "Enable ESP", Default = false,
    Callback = function(v) ESP:setEnabled(v) end,
    HasColorPicker = true, ColorCallback = function(c) ESP.settings.enemyColor = c end,
})
ESPGroupbox:AddToggle("TeamESP", {
    Text = "Show Team ESP", Default = false,
    Callback = function(v) ESP.settings.showTeamESP = v; if ESP.enabled then ESP:clearAll() end end,
    HasColorPicker = true, ColorCallback = function(c) ESP.settings.teamColor = c end,
})
ESPGroupbox:AddToggle("HealthBar",   {Text="Health Bar",   Default=true,  Callback=function(v) ESP.settings.showHealthBar  = v end})
ESPGroupbox:AddToggle("HealthText",  {Text="HP Numbers",   Default=true,  Callback=function(v) ESP.settings.showHealthText = v end})
ESPGroupbox:AddToggle("WeaponESP",   {Text="Weapon Name",  Default=true,  Callback=function(v) ESP.settings.showWeaponText = v end})
ESPGroupbox:AddToggle("DistanceESP", {Text="Distance",     Default=false, Callback=function(v) ESP.settings.showDistance   = v end})
ESPGroupbox:AddToggle("TracerESP", {
    Text="Tracer", Default=false, Callback=function(v) ESP.settings.showTracer = v end,
    HasColorPicker=true, ColorCallback=function(c) ESP.settings.tracerColor = c end,
})
ESPGroupbox:AddToggle("BoxFillESP", {
    Text="Box Fill", Default=false, Callback=function(v) ESP.settings.showBoxFill = v end,
    HasColorPicker=true, ColorCallback=function(c) ESP.settings.boxFillColor = c end,
})
ESPDisplayGroup:AddSlider("BoxThick",  {Text="Box Thickness",       Min=1,  Max=5,  Default=2,   Rounding=1, Callback=function(v) ESP.settings.thickness          = v end})
ESPDisplayGroup:AddSlider("TextSz",    {Text="Name Text Size",      Min=10, Max=30, Default=14,  Rounding=1, Callback=function(v) ESP.settings.textSize            = v end})
ESPDisplayGroup:AddSlider("HBarThick", {Text="Health Bar Thickness",Min=1,  Max=5,  Default=2,   Rounding=1, Callback=function(v) ESP.settings.healthBarThickness  = v end})
ESPDisplayGroup:AddSlider("BoxFillOp", {Text="Box Fill Opacity",    Min=0,  Max=1,  Default=0.3, Rounding=2, Callback=function(v) ESP.settings.boxFillOpacity       = v end})

-- ── Highlight ESP ─────────────────────────────────────────────
HighlightESPGroup:AddToggle("HLESPEnabled", {
    Text    = "Enable Highlight ESP",
    Default = false,
    Callback = function(v)
        getgenv().ZH_HighlightESP.Enabled = v
        if v then startHighlightESP() else stopHighlightESP() end
    end,
})
HighlightESPGroup:AddToggle("HLESPTeam", {
    Text    = "Show Teammates",
    Default = false,
    Callback = function(v) getgenv().ZH_HighlightESP.ShowTeam = v end,
})
HighlightESPGroup:AddSlider("HLESPEnemyAlpha", {
    Text="Enemy Fill Opacity", Min=0, Max=1, Default=0.5, Rounding=2,
    Callback=function(v) getgenv().ZH_HighlightESP.EnemyFillAlpha = v end,
})
HighlightESPGroup:AddSlider("HLESPEnemyOutAlpha", {
    Text="Enemy Outline Opacity", Min=0, Max=1, Default=0, Rounding=2,
    Callback=function(v) getgenv().ZH_HighlightESP.EnemyOutlineAlpha = v end,
})
HighlightESPGroup:AddSlider("HLESPTeamAlpha", {
    Text="Team Fill Opacity", Min=0, Max=1, Default=0.5, Rounding=2,
    Callback=function(v) getgenv().ZH_HighlightESP.TeamFillAlpha = v end,
})

HighlightESPRight:AddColorPicker("HLESPEnemyFill", {
    Text    = "Enemy Fill Color",
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(c) getgenv().ZH_HighlightESP.EnemyFill = c end,
})
HighlightESPRight:AddColorPicker("HLESPEnemyOutline", {
    Text    = "Enemy Outline Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) getgenv().ZH_HighlightESP.EnemyOutline = c end,
})
HighlightESPRight:AddColorPicker("HLESPTeamFill", {
    Text    = "Team Fill Color",
    Default = Color3.fromRGB(50, 220, 50),
    Callback = function(c) getgenv().ZH_HighlightESP.TeamFill = c end,
})
HighlightESPRight:AddColorPicker("HLESPTeamOutline", {
    Text    = "Team Outline Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) getgenv().ZH_HighlightESP.TeamOutline = c end,
})

-- Aimbot
AimbotGroup:AddToggle("AimbotEnabled",    {Text="Enable Aimbot",      Default=false, Callback=function(v) getgenv().ZH_Aimbot.Enabled    = v end})
AimbotGroup:AddToggle("AimbotRequireADS", {Text="Require ADS",        Default=true,  Callback=function(v) getgenv().ZH_Aimbot.RequireAim = v end})
AimbotGroup:AddDropdown("AimbotPart", {
    Text="Target Part", Values={"Head","Torso"},
    Callback=function(v) getgenv().ZH_Aimbot.TargetPart = v end,
})
AimbotGroup:AddSlider("AimbotSmooth", {
    Text="Smoothness (0=instant)", Min=0, Max=0.99, Default=0.1, Rounding=2,
    Callback=function(v) getgenv().ZH_Aimbot.Smoothness = v end,
})
AimbotFOVGroup:AddToggle("ShowFOV", {
    Text="Show FOV Circle", Default=false,
    Callback=function(v) getgenv().ZH_Aimbot.ShowFOV = v end,
    HasColorPicker=true, ColorCallback=function(c) getgenv().ZH_Aimbot.FOVColor = c end,
})
AimbotFOVGroup:AddSlider("FOVRadius", {
    Text="FOV Radius", Min=10, Max=600, Default=200, Rounding=1,
    Callback=function(v) getgenv().ZH_Aimbot.FOVRadius = v; aimbotFOVCircle.Radius = v end,
})
AimbotFOVGroup:AddToggle("AimbotVisCheck", {Text="Visible Check", Default=false, Callback=function(v) getgenv().ZH_Aimbot.VisCheck = v end})

-- Gun Mods
GunModsGroup:AddSlider("RecoilMult", {
    Text    = "Recoil Multiplier",
    Min     = 0, Max = 100, Default = 100, Rounding = 1,
    Suffix  = "%",
    Callback = function(v) getgenv().ZH_RecoilMultiplier = v end,
})
GunModsGroup:AddToggle("NoSpread",   {Text="No Spread",   Default=false, Callback=function(v) getgenv().ZH_NoSpread   = v end})
GunModsGroup:AddToggle("NoWalkSway", {Text="No Walk Sway",Default=false, Callback=function(v) getgenv().ZH_NoWalkSway = v end})
GunModsGroup:AddToggle("NoGunSway",  {Text="No Gun Sway", Default=false, Callback=function(v) getgenv().ZH_NoGunSway  = v end})
GunModsGroup2:AddToggle("NoCamSway",  {Text="No Camera Sway", Default=false, Callback=function(v) getgenv().ZH_NoCameraSway  = v end})
GunModsGroup2:AddToggle("NoScope",    {Text="No Sniper Scope",Default=false, Callback=function(v) getgenv().ZH_NoSniperScope = v end})
GunModsGroup2:AddToggle("InstReload", {Text="Instant Reload", Default=false, Callback=function(v) getgenv().ZH_InstantReload = v end})
GunModsGroup2:AddToggle("SmallCross", {Text="Small Crosshair",Default=false, Callback=function(v) getgenv().ZH_SmallCrosshair= v end})

-- ── World ─────────────────────────────────────────────────────
-- Lighting groupbox
WorldGroupbox:AddToggle("Shadow", {
    Text="Shadows", Default=true,
    Callback=function(v) getgenv().Light.Shadows = v end,
})
WorldGroupbox:AddSlider("Time", {
    Text="Time of Day", Min=0, Max=24,
    Default=math.floor(Lighting.ClockTime + 0.5), Rounding=1,
    Callback=function(v) getgenv().Light.ClockTime = v end,
})
WorldGroupbox:AddSlider("Brightness", {
    Text="Brightness", Min=0, Max=10, Default=2, Rounding=2,
    Callback=function(v) getgenv().Light.Brightness = v end,
})
WorldGroupbox:AddSlider("FOV", {
    Text="Field of View", Min=45, Max=120,
    Default=math.floor(camera.FieldOfView + 0.5), Rounding=1,
    Callback=function(v) getgenv().Visual.FieldOfView = v end,
})
WorldGroupbox:AddDropdown("LightTech", {
    Text    = "Lighting Technology",
    Values  = {"Voxel", "Compatibility", "ShadowMap", "Future"},
    Default = "ShadowMap",
    Callback = function(v)
        pcall(function() Lighting.Technology = Enum.Technology[v] end)
    end,
})
WorldGroupbox:AddToggle("FullBright", {
    Text="Full Bright", Default=false,
    Callback=function(v) getgenv().WorldExtra.FullBright = v end,
})
WorldGroupbox:AddToggle("NoBlur", {
    Text="No Blur / No DOF", Default=false,
    Callback=function(v) getgenv().WorldExtra.NoBlur = v end,
})

-- Environment groupbox
WorldGroupbox2:AddColorPicker("AmbientColor", {
    Text    = "Ambient (indoor)",
    Default = Color3.fromRGB(150, 150, 150),
    Callback = function(c) getgenv().Light.Ambient = c end,
})
WorldGroupbox2:AddColorPicker("OutdoorAmbientColor", {
    Text    = "Ambient (outdoor)",
    Default = Color3.fromRGB(140, 140, 140),
    Callback = function(c) getgenv().Light.OutdoorAmbient = c end,
})
WorldGroupbox2:AddToggle("FogEnabled", {
    Text="Enable Fog", Default=false,
    Callback=function(v) getgenv().Light.FogEnabled = v end,
})
WorldGroupbox2:AddSlider("FogDist", {
    Text="Fog Distance", Min=10, Max=5000, Default=1000, Rounding=1,
    Callback=function(v) getgenv().Light.FogEnd = v end,
})
WorldGroupbox2:AddColorPicker("FogColor", {
    Text    = "Fog Color",
    Default = Color3.fromRGB(200, 200, 200),
    Callback = function(c) Lighting.FogColor = c end,
})
WorldGroupbox2:AddToggle("NoSky", {
    Text    = "Remove Sky",
    Default = false,
    Callback = function(v)
        if v then
            -- cache the existing sky and remove it
            _originalSky = _originalSky or Lighting:FindFirstChildOfClass("Sky")
            if _originalSky then _originalSky.Parent = nil end
        else
            -- restore it
            if _originalSky then _originalSky.Parent = Lighting end
        end
    end,
})

-- Weapon Chams
WeaponChamsGroup:AddToggle("WeaponChams", {
    Text="Weapon Chams", Default=false, HasColorPicker=true,
    Callback=function(v) weaponchams(v) end,
    ColorCallback=function(c) getgenv().WeaponChamsColor = c end,
})

-- Player Highlights
HighlightGroup:AddToggle("PlayerHighlights", {
    Text="Player Highlights", Default=false, HasColorPicker=true,
    Callback=function(v) playerhighlights(v) end,
    ColorCallback=function(c)
        getgenv().HighlightColor = c
        for _, h in pairs(highlights) do
            if h.parts then for _, p in pairs(h.parts) do pcall(function() p.Color = c end) end end
        end
    end,
})
HighlightGroup:AddToggle("HLTeam",   {Text="Highlight Teammates", Default=false, Callback=function(v) getgenv().HighlightTeam = v end})
HighlightGroup:AddSlider("HLOpacity",{
    Text="Highlight Opacity", Min=0, Max=1, Default=0.5, Rounding=2,
    Callback=function(v)
        getgenv().HighlightFillTransparency = v
        for _, h in pairs(highlights) do
            if h.parts then for _, p in pairs(h.parts) do pcall(function() p.Transparency = v end) end end
        end
    end,
})

-- Arm Chams  (these groupboxes were defined but never wired to the UI)
ArmChamsGroup:AddToggle("ArmChamsEnabled", {
    Text="Arm Chams", Default=false, HasColorPicker=true,
    Callback=function(v)
        getgenv().ZH_ArmChams.Enabled = v
        refreshCameraChams()
    end,
    ColorCallback=function(c)
        getgenv().ZH_ArmChams.Color = c
        refreshCameraChams()
    end,
})
ArmChamsGroup:AddDropdown("ArmChamsMat", {
    Text="Material", Values={"Neon","ForceField","Glass","SmoothPlastic"}, Default="Neon",
    Callback=function(v)
        getgenv().ZH_ArmChams.Material = v
        refreshCameraChams()
    end,
})
ArmChamsGroup:AddSlider("ArmChamsTransp", {
    Text="Transparency", Min=0, Max=1, Default=0, Rounding=2,
    Callback=function(v)
        getgenv().ZH_ArmChams.Transparency = v
        refreshCameraChams()
    end,
})

-- Gun Chams  (same deal, was never wired)
GunChamsGroup:AddToggle("GunChamsEnabled", {
    Text="Gun Chams", Default=false, HasColorPicker=true,
    Callback=function(v)
        getgenv().ZH_GunChams.Enabled = v
        refreshCameraChams()
    end,
    ColorCallback=function(c)
        getgenv().ZH_GunChams.Color = c
        refreshCameraChams()
    end,
})
GunChamsGroup:AddDropdown("GunChamsMat", {
    Text="Material", Values={"Neon","ForceField","Glass","SmoothPlastic"}, Default="Neon",
    Callback=function(v)
        getgenv().ZH_GunChams.Material = v
        refreshCameraChams()
    end,
})
GunChamsGroup:AddSlider("GunChamsTransp", {
    Text="Transparency", Min=0, Max=1, Default=0, Rounding=2,
    Callback=function(v)
        getgenv().ZH_GunChams.Transparency = v
        refreshCameraChams()
    end,
})

-- Enemy Chams  (new – uses source-style per-frame property override)
EnemyChamsGroup:AddToggle("EnemyChamsEnabled", {
    Text="Enemy Chams", Default=false, HasColorPicker=true,
    Callback=function(v)
        getgenv().ZH_EnemyChams.Enabled = v
        if v then startEnemyChams() else stopEnemyChams() end
    end,
    ColorCallback=function(c) getgenv().ZH_EnemyChams.Color = c end,
})
EnemyChamsGroup:AddToggle("EnemyChamsTeam", {
    Text="Show Teammates", Default=false, HasColorPicker=true,
    Callback=function(v) getgenv().ZH_EnemyChams.ShowTeam = v end,
    ColorCallback=function(c) getgenv().ZH_EnemyChams.TeamColor = c end,
})
EnemyChamsGroup:AddDropdown("EnemyChamsMat", {
    Text="Material", Values={"Neon","ForceField","Glass","SmoothPlastic"}, Default="Neon",
    Callback=function(v) getgenv().ZH_EnemyChams.Material = v end,
})
EnemyChamsGroup:AddSlider("EnemyChamsTransp", {
    Text="Transparency", Min=0, Max=1, Default=0.3, Rounding=2,
    Callback=function(v) getgenv().ZH_EnemyChams.Transparency = v end,
})

-- Bullet Tracers
BulletTracerGroup:AddToggle("BulletTracersEnabled", {
    Text="Enable Bullet Tracers", Default=false,
    Callback=function(v) getgenv().BulletTracers.Enabled = v end,
    HasColorPicker=true, ColorCallback=function(c) getgenv().BulletTracers.Color = c end,
})
BulletTracerGroup:AddSlider("TracerSize",        {Text="Tracer Size",       Min=0.05, Max=1,  Default=0.3, Rounding=2, Callback=function(v) getgenv().BulletTracers.Size        = v end})
BulletTracerGroup:AddSlider("TracerTransp",      {Text="Transparency",      Min=0,    Max=1,  Default=0,   Rounding=2, Callback=function(v) getgenv().BulletTracers.Transparency = v end})
BulletTracerGroup:AddSlider("TracerTimeAlive",   {Text="Time Alive (sec)",  Min=0.5,  Max=10, Default=2,   Rounding=1, Callback=function(v) getgenv().BulletTracers.TimeAlive    = v end})
BulletTracerGroup:AddSlider("TracerFadeTime",    {Text="Fade Time (sec)",   Min=0,    Max=2,  Default=0.3, Rounding=2, Callback=function(v) getgenv().BulletTracers.FadeTime     = v end})

-- Silent Aim
SilentAimGroup:AddToggle("SilentAimEnabled", {
    Text="Enable Silent Aim", Default=false,
    Callback=function(v) getgenv().ZH_SilentAim.Enabled = v end,
})
SilentAimGroup:AddToggle("SilentAimShowFOV", {
    Text="Show FOV Circle", Default=false,
    Callback=function(v) getgenv().ZH_SilentAim.ShowFOV = v end,
    HasColorPicker=true, ColorCallback=function(c)
        getgenv().ZH_SilentAim.FOVColor = c
        silentAimFOVCircle.Color = c
    end,
})
SilentAimGroup:AddSlider("SilentAimFOV", {
    Text="FOV Radius", Min=10, Max=600, Default=300, Rounding=1,
    Callback=function(v) getgenv().ZH_SilentAim.FOVRadius = v; silentAimFOVCircle.Radius = v end,
})
SilentAimGroup:AddToggle("SilentAimVisCheck", {
    Text="Visible Check", Default=false,
    Callback=function(v) getgenv().ZH_SilentAim.VisCheck = v end,
})
SilentAimGroup:AddDropdown("SilentAimPart", {
    Text="Target Part", Values={"Head","Torso"},
    Callback=function(v) getgenv().ZH_SilentAim.TargetPart = v end,
})

-- Hitmarker
HitmarkerGroup:AddToggle("HitmarkerEnabled", {
    Text="Enable Hitmarker", Default=false,
    Callback=function(v) getgenv().ZH_Hitmarker.Enabled = v end,
    HasColorPicker=true, ColorCallback=function(c) getgenv().ZH_Hitmarker.Color = c end,
})
HitmarkerGroup:AddColorPicker("HMKillColor", {
    Text="Kill Color", Default=Color3.fromRGB(255,50,50),
    Callback=function(c) getgenv().ZH_Hitmarker.KillColor = c end,
})
HitmarkerGroup:AddSlider("HMSize",      {Text="Size",      Min=4,   Max=30,  Default=10,  Rounding=1, Callback=function(v) getgenv().ZH_Hitmarker.Size      = v end})
HitmarkerGroup:AddSlider("HMThickness", {Text="Thickness", Min=1,   Max=5,   Default=2,   Rounding=1, Callback=function(v) getgenv().ZH_Hitmarker.Thickness = v end})
HitmarkerGroup:AddSlider("HMDuration",  {Text="Duration",  Min=0.05,Max=1,   Default=0.3, Rounding=2, Callback=function(v) getgenv().ZH_Hitmarker.Duration  = v end})

-- Tweaks (Unlocks)
TweaksGroup:AddToggle("UnlockAttachments", {
    Text    = "Unlock All Attachments",
    Default = false,
    Callback = function(v) unlockAttachments = v end,
})
TweaksGroup:AddToggle("UnlockKnives", {
    Text    = "Unlock All Knives",
    Default = false,
    Callback = function(v) unlockKnives = v end,
})
TweaksGroup:AddToggle("UnlockCamos", {
    Text    = "Unlock All Camos",
    Default = false,
    Callback = function(v)
        unlockCamos = v
        if v and camoDatabase and playerDataUtils and playerClient then
            pcall(function()
                for camoName, camoData in camoDatabase do
                    if camoData.Case then
                        playerDataUtils.getCasePacketData(
                            playerClient.getPlayerData(), camoData.Case, true
                        ).Skins[camoName] = { ALL = true }
                    end
                end
            end)
        end
    end,
})

-- ==============================================================
--  CONFIG SYSTEM  (saves / loads every Toggle, Slider, Dropdown,
--  ColorPicker, and KeyPicker from the registry above)
-- ==============================================================
local HttpService = game:GetService("HttpService")
local CFG_FOLDER  = "ZestHub-Phantom"
local CFG_SUB     = "ZestHub-Phantom/configs"
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
            local val = e.GetValue and e.GetValue() or false
            local col = e.ColorPicker and e.ColorPicker.GetColor and e.ColorPicker.GetColor()
            snap[id] = { k="T", v=val, c = col and c3hex(col) or nil }
        elseif kind == "Slider" then
            snap[id] = { k="S", v = e.GetValue and e.GetValue() or 0 }
        elseif kind == "Dropdown" then
            snap[id] = { k="D", v = e.GetValue and e.GetValue() or "" }
        elseif kind == "ColorPicker" then
            local col = e.GetColor and e.GetColor()
            if col then snap[id] = { k="C", c = c3hex(col) } end
        elseif kind == "KeyPicker" then
            local key  = e.GetValue and e.GetValue()
            local mode = e.GetMode  and e.GetMode()
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
            if e.SetValue then e.SetValue(val) end
            if entry.cb then pcall(entry.cb, val) end
            if data.c and e.ColorPicker and e.ColorPicker.SetColor then
                -- FIX: Color3.fromHex is static; old code passed Color3 table as bogus self
                local ok, col = pcall(function() return Color3.fromHex(data.c) end)
                if ok and col then
                    e.ColorPicker.SetColor(col)
                    if entry.colorCb then pcall(entry.colorCb, col) end
                end
            end
        elseif data.k == "S" then
            local val = tonumber(data.v) or 0
            if e.SetValue then e.SetValue(val) end
            if entry.cb then pcall(entry.cb, val) end
        elseif data.k == "D" then
            if e.SetValue and data.v and data.v ~= "" then
                e.SetValue(data.v)
                if entry.cb then pcall(entry.cb, data.v) end
            end
        elseif data.k == "C" then
            if data.c then
                local ok, col = pcall(function() return Color3.fromHex(data.c) end)
                if ok and col then
                    if e.SetColor then e.SetColor(col) end
                    if entry.cb then pcall(entry.cb, col) end
                end
            end
        elseif data.k == "K" then
            if data.v and data.v ~= "" then
                local ok, kc = pcall(function() return Enum.KeyCode[data.v] end)
                if ok and kc then
                    if e.SetKey  then pcall(e.SetKey,  kc) end
                    if data.m and e.SetMode then pcall(e.SetMode, data.m) end
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

-- Auto-load 1 second after start so all hooks/modules are settled
task.spawn(function()
    task.wait(1)
    local auto = getAutoload()
    if auto and auto ~= "" then
        local ok = loadConfig(auto)
        print(ok and ("[Config] Auto-loaded: "..auto) or "[Config] Auto-load failed")
    end
end)

-- ── Config Tab ────────────────────────────────────────
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

print("[ZestHub] v9 Loaded - Toggle: RightShift")
