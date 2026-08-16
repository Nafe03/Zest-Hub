local Draw = {}

local CoreGui   = game:GetService("CoreGui")
local Players   = game:GetService("Players")
local Camera    = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DrawLibCanvas"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
Draw.ScreenGui = ScreenGui

-- expose viewport size, kept up to date
Draw.ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
    if Camera then
        Draw.ViewportSize = Camera.ViewportSize
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            Draw.ViewportSize = Camera.ViewportSize
        end)
    end
end)

if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        Draw.ViewportSize = Camera.ViewportSize
    end)
end

function Draw.GetCenter()
    return Vector2.new(Draw.ViewportSize.X * 0.5, Draw.ViewportSize.Y * 0.5)
end

local function c01(n) return math.clamp(n, 0, 1) end

local TAG = {
    Square   = {},
    Text     = {},
    Line     = {},
    Circle   = {},
    Quad     = {},
    Triangle = {},
    Image    = {},
}

-- ── DEFAULTS ────────────────────────────────────────────────────────
local DEFAULTS = {
    Square = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
        Size=Vector2.new(0,0), Position=Vector2.new(0,0),
        Thickness=1, Filled=false, Rounding=0, OutlineColor=false,
        FillColor=false,            -- false = use Color
        FillTransparency=0,         -- independent fill alpha
        Gradient=nil,                -- ColorSequence or nil
        GradientTransparency=nil,    -- NumberSequence or nil
        GradientRotation=0,
    },
    Text = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
        Text="", Size=14, Position=Vector2.new(0,0),
        Center=false, Right=false, Outline=false,
        OutlineColor=Color3.new(0,0,0), Font=Enum.Font.Code,
    },
    Line = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
        From=Vector2.new(0,0), To=Vector2.new(0,0), Thickness=1,
    },
    Circle = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
        Position=Vector2.new(0,0), Radius=0, Thickness=1, Filled=false, NumSides=0,
        FillColor=false,
        FillTransparency=0,
        Gradient=nil,
        GradientTransparency=nil,
        GradientRotation=0,
    },
    Quad = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0, Thickness=1,
        PointA=Vector2.new(0,0), PointB=Vector2.new(0,0),
        PointC=Vector2.new(0,0), PointD=Vector2.new(0,0),
    },
    Triangle = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0, Thickness=1,
        PointA=Vector2.new(0,0), PointB=Vector2.new(0,0), PointC=Vector2.new(0,0),
    },
    Image = {
        Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
        Position=Vector2.new(0,0), Size=Vector2.new(32,32), Data="", Rounding=0,
    },
}

-- Keys whose *default* value is `nil` (Gradient / GradientTransparency).
-- A table constructor like `{Gradient = nil}` never actually creates the
-- key, so pairs(DEFAULTS.Square) never yields "Gradient" or
-- "GradientTransparency" and the __newindex "recognized property" check
-- below would always reject writes to them. This allow-list fixes that.
local NILABLE_KEYS = {
    Gradient = true,
    GradientTransparency = true,
}

local function shallowCopy(t)
    local o = {}
    for k, v in pairs(t) do o[k] = v end
    return o
end

-- ── shared gradient applier ────────────────────────────────────────
local DEFAULT_TRANS_SEQ = NumberSequence.new(0)

local function applyGradient(grad, p)
    if p.Gradient then
        if grad.Color ~= p.Gradient then grad.Color = p.Gradient end

        local transSeq = p.GradientTransparency or DEFAULT_TRANS_SEQ
        if grad.Transparency ~= transSeq then grad.Transparency = transSeq end

        if grad.Rotation ~= p.GradientRotation then grad.Rotation = p.GradientRotation end
        if not grad.Enabled then grad.Enabled = true end
    else
        if grad.Enabled then grad.Enabled = false end
    end
end

-- ── APPLIERS ────────────────────────────────────────────────────────
local applyLine

local function applySquare(obj)
    local p    = obj._props
    local f    = obj._frame
    local sk   = obj._stroke
    local grad = obj._gradient

    if f.Visible ~= p.Visible then f.Visible = p.Visible end
    if f.ZIndex  ~= p.ZIndex  then f.ZIndex  = p.ZIndex  end

    local size = UDim2.new(0, p.Size.X, 0, p.Size.Y)
    if f.Size ~= size then f.Size = size end

    local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    if f.Position ~= pos then f.Position = pos end

    -- fill color falls back to Color when FillColor not set
    local fillColor = p.FillColor or p.Color
    if f.BackgroundColor3 ~= fillColor then f.BackgroundColor3 = fillColor end

    -- fill transparency independent from outline transparency
    local bgTrans = p.Filled and c01(p.FillTransparency) or 1
    if f.BackgroundTransparency ~= bgTrans then f.BackgroundTransparency = bgTrans end

    -- outline
    local outlineColor = p.OutlineColor or p.Color
    if sk.Color ~= outlineColor then sk.Color = outlineColor end
    if sk.Thickness ~= p.Thickness then sk.Thickness = p.Thickness end

    local skEnabled = p.Thickness > 0
    if sk.Enabled ~= skEnabled then sk.Enabled = skEnabled end

    local skTrans = c01(p.Transparency)
    if sk.Transparency ~= skTrans then sk.Transparency = skTrans end

    -- gradient (applies to the fill)
    applyGradient(grad, p)

    -- corner rounding
    if obj._lastRounding ~= p.Rounding then
        obj._lastRounding = p.Rounding
        local corner = obj._corner
        if p.Rounding and p.Rounding > 0 then
            if not corner then
                corner = Instance.new("UICorner")
                corner.Parent = f
                obj._corner = corner
            end
            corner.CornerRadius = UDim.new(0, p.Rounding)
        elseif corner then
            corner:Destroy()
            obj._corner = nil
        end
    end
end

local function applyText(obj)
    local p = obj._props
    local l = obj._label

    if l.Visible ~= p.Visible then l.Visible = p.Visible end
    if l.ZIndex  ~= p.ZIndex  then l.ZIndex  = p.ZIndex  end

    local text = tostring(p.Text)
    if l.Text ~= text then l.Text = text end

    if l.TextSize ~= p.Size then l.TextSize = p.Size end
    if l.TextColor3 ~= p.Color then l.TextColor3 = p.Color end

    local trans = c01(p.Transparency)
    if l.TextTransparency ~= trans then l.TextTransparency = trans end

    if l.Font ~= p.Font then l.Font = p.Font end

    local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    if l.Position ~= pos then l.Position = pos end

    local mode = p.Center and "center" or (p.Right and "right" or "left")
    if obj._lastAlign ~= mode then
        obj._lastAlign = mode
        if mode == "center" then
            l.TextXAlignment = Enum.TextXAlignment.Center
            l.AnchorPoint    = Vector2.new(0.5, 0)
        elseif mode == "right" then
            l.TextXAlignment = Enum.TextXAlignment.Right
            l.AnchorPoint    = Vector2.new(1, 0)
        else
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.AnchorPoint    = Vector2.new(0, 0)
        end
    end

    local strokeTrans = p.Outline and trans or 1
    if l.TextStrokeTransparency ~= strokeTrans then l.TextStrokeTransparency = strokeTrans end
    if l.TextStrokeColor3 ~= p.OutlineColor then l.TextStrokeColor3 = p.OutlineColor end
end

-- ── LINE ────────────────────────────────────────────────────────────
applyLine = function(obj)
    local p     = obj._props
    local from  = p.From
    local to    = p.To
    local delta = to - from
    local len   = delta.Magnitude
    local f     = obj._frame

    if len == 0 or not p.Visible then
        if f.Visible then f.Visible = false end
        return
    end

    local thick = p.Thickness > 1 and p.Thickness or 1
    local angle = math.deg(math.atan2(delta.Y, delta.X))
    local midX  = (from.X + to.X) * 0.5
    local midY  = (from.Y + to.Y) * 0.5

    if f.ZIndex ~= p.ZIndex then f.ZIndex = p.ZIndex end
    if f.BackgroundColor3 ~= p.Color then f.BackgroundColor3 = p.Color end

    local trans = c01(p.Transparency)
    if f.BackgroundTransparency ~= trans then f.BackgroundTransparency = trans end

    local size = UDim2.new(0, len, 0, thick)
    if f.Size ~= size then f.Size = size end

    local pos = UDim2.new(0, midX, 0, midY)
    if f.Position ~= pos then f.Position = pos end

    if f.Rotation ~= angle then f.Rotation = angle end
    if not f.Visible then f.Visible = true end
end

local function applyCircle(obj)
    local p    = obj._props
    local f    = obj._frame
    local sk   = obj._stroke
    local grad = obj._gradient
    local d    = p.Radius * 2

    if f.Visible ~= p.Visible then f.Visible = p.Visible end
    if f.ZIndex  ~= p.ZIndex  then f.ZIndex  = p.ZIndex  end

    local size = UDim2.new(0, d, 0, d)
    if f.Size ~= size then f.Size = size end

    local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    if f.Position ~= pos then f.Position = pos end

    local fillColor = p.FillColor or p.Color
    if f.BackgroundColor3 ~= fillColor then f.BackgroundColor3 = fillColor end

    local bgTrans = p.Filled and c01(p.FillTransparency) or 1
    if f.BackgroundTransparency ~= bgTrans then f.BackgroundTransparency = bgTrans end

    if sk.Color ~= p.Color then sk.Color = p.Color end
    if sk.Thickness ~= p.Thickness then sk.Thickness = p.Thickness end

    local skEnabled = p.Thickness > 0
    if sk.Enabled ~= skEnabled then sk.Enabled = skEnabled end

    local skTrans = c01(p.Transparency)
    if sk.Transparency ~= skTrans then sk.Transparency = skTrans end

    applyGradient(grad, p)
end

-- pooled scratch table for polygon points
local _scratchPts = {}

local function applySegments(obj, pts, n)
    local p = obj._props
    for i = 1, n do
        local seg = obj._segments[i]
        local sp  = seg._props
        sp.Visible      = p.Visible
        sp.ZIndex       = p.ZIndex
        sp.Color        = p.Color
        sp.Transparency = p.Transparency
        sp.Thickness    = p.Thickness
        sp.From         = pts[i]
        sp.To           = pts[(i % n) + 1]
        applyLine(seg)
    end
end

local function applyQuad(obj)
    local p = obj._props
    _scratchPts[1] = p.PointA
    _scratchPts[2] = p.PointB
    _scratchPts[3] = p.PointC
    _scratchPts[4] = p.PointD
    applySegments(obj, _scratchPts, 4)
end

local function applyTriangle(obj)
    local p = obj._props
    _scratchPts[1] = p.PointA
    _scratchPts[2] = p.PointB
    _scratchPts[3] = p.PointC
    applySegments(obj, _scratchPts, 3)
end

local function applyImage(obj)
    local p = obj._props
    local i = obj._img

    if i.Visible ~= p.Visible then i.Visible = p.Visible end
    if i.ZIndex  ~= p.ZIndex  then i.ZIndex  = p.ZIndex  end
    if i.Image   ~= p.Data    then i.Image   = p.Data    end
    if i.ImageColor3 ~= p.Color then i.ImageColor3 = p.Color end

    local trans = c01(p.Transparency)
    if i.ImageTransparency ~= trans then i.ImageTransparency = trans end

    local size = UDim2.new(0, p.Size.X, 0, p.Size.Y)
    if i.Size ~= size then i.Size = size end

    local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    if i.Position ~= pos then i.Position = pos end

    if obj._lastRounding ~= p.Rounding then
        obj._lastRounding = p.Rounding
        local corner = obj._corner
        if p.Rounding and p.Rounding > 0 then
            if not corner then
                corner = Instance.new("UICorner")
                corner.Parent = i
                obj._corner = corner
            end
            corner.CornerRadius = UDim.new(0, p.Rounding)
        elseif corner then
            corner:Destroy()
            obj._corner = nil
        end
    end
end

-- ── CONSTRUCTORS ────────────────────────────────────────────────────

local function newSquare()
    local f = Instance.new("Frame")
    f.Name = "Draw_Square"; f.BorderSizePixel = 0
    f.BackgroundTransparency = 1; f.Size = UDim2.new(0,0,0,0)
    f.Visible = false
    f.Parent = ScreenGui

    local sk = Instance.new("UIStroke")
    sk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sk.Thickness = 1
    sk.Parent = f

    local grad = Instance.new("UIGradient")
    grad.Enabled = false
    grad.Parent = f

    return {
        _tag = TAG.Square, _frame = f, _stroke = sk, _gradient = grad,
        _corner = nil, _lastRounding = 0,
        _props = shallowCopy(DEFAULTS.Square),
    }
end

local function newText()
    local l = Instance.new("TextLabel")
    l.Name = "Draw_Text"; l.BackgroundTransparency = 1; l.BorderSizePixel = 0
    l.Font = Enum.Font.Code; l.Text = ""; l.TextSize = 14
    l.TextColor3 = Color3.new(1,1,1); l.TextStrokeTransparency = 1
    l.AnchorPoint = Vector2.new(0,0); l.AutomaticSize = Enum.AutomaticSize.None
    l.Size = UDim2.new(0,0,0,0); l.Visible = false
    l.Parent = ScreenGui
    return {
        _tag = TAG.Text, _label = l, _lastAlign = "left",
        _props = shallowCopy(DEFAULTS.Text),
    }
end

local function newLine()
    local f = Instance.new("Frame")
    f.Name = "Draw_Line"; f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.new(1,1,1)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Size = UDim2.new(0,0,0,1); f.Visible = false; f.Parent = ScreenGui
    return {
        _tag = TAG.Line, _frame = f,
        _props = shallowCopy(DEFAULTS.Line),
    }
end

local function newCircle()
    local f = Instance.new("Frame")
    f.Name = "Draw_Circle"; f.BorderSizePixel = 0
    f.BackgroundTransparency = 1; f.AnchorPoint = Vector2.new(0.5,0.5)
    f.Size = UDim2.new(0,0,0,0); f.Visible = false
    f.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0); corner.Parent = f

    local sk = Instance.new("UIStroke")
    sk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; sk.Thickness = 1; sk.Parent = f

    local grad = Instance.new("UIGradient")
    grad.Enabled = false
    grad.Parent = f

    return {
        _tag = TAG.Circle, _frame = f, _stroke = sk, _gradient = grad,
        _props = shallowCopy(DEFAULTS.Circle),
    }
end

local function makeSegment()
    local f = Instance.new("Frame")
    f.Name = "Draw_Seg"; f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.new(1,1,1)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Size = UDim2.new(0,0,0,1); f.Visible = false; f.Parent = ScreenGui
    return {
        _frame = f,
        _props = {
            Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
            Thickness=1, From=Vector2.new(0,0), To=Vector2.new(0,0),
        },
    }
end

local function newPoly(tag, defaults, nSegs)
    local segs = {}
    for i = 1, nSegs do segs[i] = makeSegment() end
    return { _tag = tag, _segments = segs, _props = shallowCopy(defaults) }
end

local function newQuad()
    return newPoly(TAG.Quad, DEFAULTS.Quad, 4)
end

local function newTriangle()
    return newPoly(TAG.Triangle, DEFAULTS.Triangle, 3)
end

local function newImage()
    local i = Instance.new("ImageLabel")
    i.Name = "Draw_Image"; i.BackgroundTransparency = 1
    i.BorderSizePixel = 0; i.Visible = false
    i.Parent = ScreenGui
    return {
        _tag = TAG.Image, _img = i, _corner = nil, _lastRounding = 0,
        _props = shallowCopy(DEFAULTS.Image),
    }
end

local APPLIERS = {
    [TAG.Square]   = applySquare,
    [TAG.Text]     = applyText,
    [TAG.Line]     = applyLine,
    [TAG.Circle]   = applyCircle,
    [TAG.Quad]     = applyQuad,
    [TAG.Triangle] = applyTriangle,
    [TAG.Image]    = applyImage,
}

local REMOVERS = {
    [TAG.Square] = function(o)
        if o._gradient then o._gradient:Destroy(); o._gradient = nil end
        if o._corner   then o._corner:Destroy();   o._corner   = nil end
        if o._stroke   then o._stroke:Destroy();   o._stroke   = nil end
        if o._frame    then o._frame:Destroy();    o._frame    = nil end
        o._props = nil
    end,
    [TAG.Text] = function(o)
        if o._label then o._label:Destroy(); o._label = nil end
        o._props = nil
    end,
    [TAG.Line] = function(o)
        if o._frame then o._frame:Destroy(); o._frame = nil end
        o._props = nil
    end,
    [TAG.Circle] = function(o)
        if o._gradient then o._gradient:Destroy(); o._gradient = nil end
        if o._stroke   then o._stroke:Destroy();   o._stroke   = nil end
        if o._frame    then o._frame:Destroy();    o._frame    = nil end
        o._props = nil
    end,
    [TAG.Quad] = function(o)
        for _, s in ipairs(o._segments or {}) do
            if s._frame then s._frame:Destroy() end
            s._props = nil
        end
        o._segments = nil
        o._props = nil
    end,
    [TAG.Triangle] = function(o)
        for _, s in ipairs(o._segments or {}) do
            if s._frame then s._frame:Destroy() end
            s._props = nil
        end
        o._segments = nil
        o._props = nil
    end,
    [TAG.Image] = function(o)
        if o._corner then o._corner:Destroy(); o._corner = nil end
        if o._img    then o._img:Destroy();    o._img    = nil end
        o._props = nil
    end,
}

local CONSTRUCTORS = {
    Square=newSquare, Text=newText, Line=newLine, Circle=newCircle,
    Quad=newQuad, Triangle=newTriangle, Image=newImage,
}

-- track all live objects so Clear() can wipe them properly
local ActiveObjects = {}
local DirtyObjects = {}

local function MarkDirty(obj)
    DirtyObjects[obj] = true
end

RunService.RenderStepped:Connect(function()
    for obj in pairs(DirtyObjects) do
        local applier = APPLIERS[obj._tag]
        if applier and obj._props then
            applier(obj)
        end
        DirtyObjects[obj] = nil
    end
end)

function Draw.new(kind)
    local ctor = CONSTRUCTORS[kind]
    assert(ctor, "drawlib: unsupported type '" .. tostring(kind) .. "'")
    local obj     = ctor()
    local applier = APPLIERS[obj._tag]
    local remover = REMOVERS[obj._tag]
    local removed = false

    local handle = setmetatable({}, {
        __index = function(_, k)
            if k == "Remove" or k == "Destroy" then
                return function()
                    if removed then return end
                    removed = true
                    _liveObjects[obj] = nil
                    if remover then remover(obj) end
                end
            end
            if k == "TextBounds" and obj._label then return obj._label.TextBounds end
            local props = obj._props
            if props then
                local v = props[k]
                if v ~= nil then return v end
                -- allow reading keys whose default is nil/false explicitly
                if k == "OutlineColor" or k == "FillColor"
                    or k == "Gradient" or k == "GradientTransparency" then
                    return props[k]
                end
            end
            return nil
        end,
        __newindex = function(_, k, v)
            if removed then return end
            local props = obj._props
            if not props then return end
            if props[k] ~= v then
                -- only allow writing keys that exist in the defaults table
                if rawget(props, k) ~= nil or props[k] == nil then
                    -- check key is a recognized property name
                    local recognized = NILABLE_KEYS[k] == true
                    if not recognized then
                        for key in pairs(DEFAULTS[
                            obj._tag == TAG.Square and "Square"
                            or obj._tag == TAG.Text and "Text"
                            or obj._tag == TAG.Line and "Line"
                            or obj._tag == TAG.Circle and "Circle"
                            or obj._tag == TAG.Quad and "Quad"
                            or obj._tag == TAG.Triangle and "Triangle"
                            or "Image"
                        ]) do
                            if key == k then recognized = true break end
                        end
                    end
                    if recognized then
                        props[k] = v
                        MarkDirty(obj)
                    end
                end
            end
        end,
    })

    ActiveObjects[obj] = true
    MarkDirty(obj)
    return handle
end

function Draw.Clear()
    for obj in pairs(_liveObjects) do
        local remover = REMOVERS[obj._tag]
        if remover then remover(obj) end
    end
    _liveObjects = setmetatable({}, { __mode = "k" })

    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
end

return Draw
