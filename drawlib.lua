--[[
    drawlib.lua  v3
    ─────────────────────────────────────────────────────────────────────
    Drop-in replacement for the native executor Drawing API.
    Implemented with ScreenGui / Frame / TextLabel / UIStroke.

    FIXES vs v2
    ───────────
    • Line AnchorPoint set to (0, 0.5) consistently — rotation pivot is
      always the FROM point, so the line draws exactly from From → To.
    • Line Position now correctly places the pivot AT the From point
      (no sub-pixel offset from previous UDim2 rounding).
    • Circle Position anchor (0.5, 0.5) so .Position is the CENTER of
      the circle, matching native Drawing API behaviour.
    • Square Position is top-left as expected.
    • Text OutlineColor defaulted to black; stroke always synced.
    • Remove() / Destroy() are idempotent — calling twice won't error.
    • All _props keys protected: unknown writes are silently dropped.
    • ZIndex properly propagated to all child segments in Quad/Triangle.

    SUPPORTED TYPES
      "Square"   – rect, optional fill / rounding / separate OutlineColor
      "Text"     – TextLabel, outline / center / right-align
      "Line"     – rotated Frame, From → To, pivot at From
      "Circle"   – UICorner ring or filled disc, pivot at CENTER
      "Quad"     – 4-point outline (4 Line segments)
      "Triangle" – 3-point outline (3 Line segments)
      "Image"    – ImageLabel, optional rounding

    SHARED PROPERTIES  (all types)
      .Visible (bool)
      .ZIndex  (number)
      .Color   (Color3)
      .Transparency (0–1, 0 = fully opaque)
      :Remove() / :Destroy()
--]]

local Draw = {}

-- ─── ScreenGui (shared canvas) ───────────────────────────────────────
local CoreGui   = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "DrawLibCanvas"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.DisplayOrder    = 999
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer
                           :WaitForChild("PlayerGui")
end
Draw.ScreenGui = ScreenGui

-- ─── Helpers ─────────────────────────────────────────────────────────
local function c01(n) return math.clamp(n, 0, 1) end

-- ─── Class tags ───────────────────────────────────────────────────────
local TAG = {
    Square   = {},
    Text     = {},
    Line     = {},
    Circle   = {},
    Quad     = {},
    Triangle = {},
    Image    = {},
}

-- ─── Forward declarations ─────────────────────────────────────────────
local applyLine

-- ─── Apply functions ──────────────────────────────────────────────────

local function applySquare(obj)
    local p  = obj._props
    local f  = obj._frame
    local sk = obj._stroke

    f.Visible                = p.Visible
    f.ZIndex                 = p.ZIndex
    f.Size                   = UDim2.new(0, p.Size.X,     0, p.Size.Y)
    f.Position               = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    f.BackgroundColor3       = p.Color
    f.BackgroundTransparency = p.Filled and c01(p.Transparency) or 1

    sk.Color        = p.OutlineColor or p.Color
    sk.Thickness    = p.Thickness
    sk.Enabled      = not p.Filled and p.Thickness > 0
    sk.Transparency = c01(p.Transparency)

    local corner = f:FindFirstChildOfClass("UICorner")
    if p.Rounding and p.Rounding > 0 then
        if not corner then
            corner        = Instance.new("UICorner")
            corner.Parent = f
        end
        corner.CornerRadius = UDim.new(0, p.Rounding)
    elseif corner then
        corner:Destroy()
    end
end

local function applyText(obj)
    local p = obj._props
    local l = obj._label

    l.Visible          = p.Visible
    l.ZIndex           = p.ZIndex
    l.Text             = tostring(p.Text)
    l.TextSize         = p.Size
    l.TextColor3       = p.Color
    l.TextTransparency = c01(p.Transparency)
    l.Font             = p.Font
    l.Position         = UDim2.new(0, p.Position.X, 0, p.Position.Y)

    if p.Center then
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.AnchorPoint    = Vector2.new(0.5, 0)
    elseif p.Right then
        l.TextXAlignment = Enum.TextXAlignment.Right
        l.AnchorPoint    = Vector2.new(1, 0)
    else
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.AnchorPoint    = Vector2.new(0, 0)
    end

    l.TextStrokeTransparency = p.Outline and c01(p.Transparency) or 1
    l.TextStrokeColor3       = p.OutlineColor
end

-- FIX: AnchorPoint (0, 0.5) means the frame's left-center sits AT
-- the From point. Rotation then pivots around From, so the line
-- always extends exactly from From toward To — no offset.
applyLine = function(obj)
    local p     = obj._props
    local from  = p.From
    local to    = p.To
    local delta = to - from
    local len   = delta.Magnitude

    local f = obj._frame
    f.ZIndex                  = p.ZIndex
    f.BackgroundColor3        = p.Color
    f.BackgroundTransparency  = c01(p.Transparency)
    f.AnchorPoint             = Vector2.new(0, 0.5)   -- pivot at FROM
    f.Size                    = UDim2.new(0, len, 0, math.max(p.Thickness, 1))
    f.Position                = UDim2.new(0, from.X, 0, from.Y)
    f.Rotation                = math.deg(math.atan2(delta.Y, delta.X))
    f.Visible                 = p.Visible and len > 0
end

-- FIX: AnchorPoint (0.5, 0.5) so .Position is the CENTER of the
-- circle, matching native Drawing.Circle behaviour.
local function applyCircle(obj)
    local p = obj._props
    local f = obj._frame
    local d = p.Radius * 2

    f.Visible               = p.Visible
    f.ZIndex                = p.ZIndex
    f.AnchorPoint           = Vector2.new(0.5, 0.5)
    f.Size                  = UDim2.new(0, d, 0, d)
    f.Position              = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    f.BackgroundColor3      = p.Color
    f.BackgroundTransparency = p.Filled and c01(p.Transparency) or 1

    obj._stroke.Color        = p.Color
    obj._stroke.Thickness    = p.Thickness
    obj._stroke.Enabled      = p.Thickness > 0
    obj._stroke.Transparency = c01(p.Transparency)
end

local function applySegments(obj, pts)
    local p = obj._props
    local n = #pts
    for i, seg in ipairs(obj._segments) do
        local sp        = seg._props
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
    applySegments(obj, { p.PointA, p.PointB, p.PointC, p.PointD })
end

local function applyTriangle(obj)
    local p = obj._props
    applySegments(obj, { p.PointA, p.PointB, p.PointC })
end

local function applyImage(obj)
    local p = obj._props
    local i = obj._img

    i.Visible           = p.Visible
    i.ZIndex            = p.ZIndex
    i.Image             = p.Data
    i.ImageColor3       = p.Color
    i.ImageTransparency = c01(p.Transparency)
    i.Size              = UDim2.new(0, p.Size.X,     0, p.Size.Y)
    i.Position          = UDim2.new(0, p.Position.X, 0, p.Position.Y)

    local corner = i:FindFirstChildOfClass("UICorner")
    if p.Rounding and p.Rounding > 0 then
        if not corner then
            corner        = Instance.new("UICorner")
            corner.Parent = i
        end
        corner.CornerRadius = UDim.new(0, p.Rounding)
    elseif corner then
        corner:Destroy()
    end
end

-- ─── Constructors ─────────────────────────────────────────────────────

local function newSquare()
    local f                  = Instance.new("Frame")
    f.Name                   = "Draw_Square"
    f.BorderSizePixel        = 0
    f.BackgroundTransparency = 1
    f.Size                   = UDim2.new(0, 0, 0, 0)
    f.Parent                 = ScreenGui

    local sk           = Instance.new("UIStroke")
    sk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sk.Thickness       = 1
    sk.Parent          = f

    return {
        _tag = TAG.Square, _frame = f, _stroke = sk,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            Size         = Vector2.new(0, 0),
            Position     = Vector2.new(0, 0),
            Thickness    = 1,
            Filled       = false,
            Rounding     = 0,
            OutlineColor = false,
        },
    }
end

local function newText()
    local l                  = Instance.new("TextLabel")
    l.Name                   = "Draw_Text"
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    l.Font                   = Enum.Font.Code
    l.Text                   = ""
    l.TextSize               = 14
    l.TextColor3             = Color3.new(1, 1, 1)
    l.TextStrokeTransparency = 1
    l.AnchorPoint            = Vector2.new(0, 0)
    l.AutomaticSize          = Enum.AutomaticSize.XY
    l.Size                   = UDim2.new(0, 0, 0, 0)
    l.Parent                 = ScreenGui

    return {
        _tag = TAG.Text, _label = l,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            Text         = "",
            Size         = 14,
            Position     = Vector2.new(0, 0),
            Center       = false,
            Right        = false,
            Outline      = false,
            OutlineColor = Color3.new(0, 0, 0),
            Font         = Enum.Font.Code,
        },
    }
end

local function newLine()
    local f            = Instance.new("Frame")
    f.Name             = "Draw_Line"
    f.BorderSizePixel  = 0
    f.BackgroundColor3 = Color3.new(1, 1, 1)
    f.AnchorPoint      = Vector2.new(0, 0.5)
    f.Size             = UDim2.new(0, 0, 0, 1)
    f.Visible          = false
    f.Parent           = ScreenGui

    return {
        _tag = TAG.Line, _frame = f,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            From         = Vector2.new(0, 0),
            To           = Vector2.new(0, 0),
            Thickness    = 1,
        },
    }
end

local function newCircle()
    local f                  = Instance.new("Frame")
    f.Name                   = "Draw_Circle"
    f.BorderSizePixel        = 0
    f.BackgroundTransparency = 1
    f.AnchorPoint            = Vector2.new(0.5, 0.5)
    f.Size                   = UDim2.new(0, 0, 0, 0)
    f.Parent                 = ScreenGui

    local corner            = Instance.new("UICorner")
    corner.CornerRadius     = UDim.new(1, 0)
    corner.Parent           = f

    local sk                = Instance.new("UIStroke")
    sk.ApplyStrokeMode      = Enum.ApplyStrokeMode.Border
    sk.Thickness            = 1
    sk.Parent               = f

    return {
        _tag = TAG.Circle, _frame = f, _stroke = sk,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            Position     = Vector2.new(0, 0),
            Radius       = 0,
            Thickness    = 1,
            Filled       = false,
            NumSides     = 0,
        },
    }
end

local function makeSegment()
    local f              = Instance.new("Frame")
    f.Name               = "Draw_Seg"
    f.BorderSizePixel    = 0
    f.BackgroundColor3   = Color3.new(1, 1, 1)
    f.AnchorPoint        = Vector2.new(0, 0.5)
    f.Size               = UDim2.new(0, 0, 0, 1)
    f.Visible            = false
    f.Parent             = ScreenGui
    return {
        _frame = f,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            Thickness    = 1,
            From         = Vector2.new(0, 0),
            To           = Vector2.new(0, 0),
        },
    }
end

local function newPoly(tag, pointNames, nSegs)
    local segs = {}
    for i = 1, nSegs do segs[i] = makeSegment() end
    local props = {
        Visible      = false,
        ZIndex       = 1,
        Color        = Color3.new(1, 1, 1),
        Transparency = 0,
        Thickness    = 1,
    }
    for _, name in ipairs(pointNames) do
        props[name] = Vector2.new(0, 0)
    end
    return { _tag = tag, _segments = segs, _props = props }
end

local function newQuad()
    return newPoly(TAG.Quad, { "PointA","PointB","PointC","PointD" }, 4)
end

local function newTriangle()
    return newPoly(TAG.Triangle, { "PointA","PointB","PointC" }, 3)
end

local function newImage()
    local i                  = Instance.new("ImageLabel")
    i.Name                   = "Draw_Image"
    i.BackgroundTransparency = 1
    i.BorderSizePixel        = 0
    i.Parent                 = ScreenGui

    return {
        _tag = TAG.Image, _img = i,
        _props = {
            Visible      = false,
            ZIndex       = 1,
            Color        = Color3.new(1, 1, 1),
            Transparency = 0,
            Position     = Vector2.new(0, 0),
            Size         = Vector2.new(32, 32),
            Data         = "",
            Rounding     = 0,
        },
    }
end

-- ─── Dispatch tables ──────────────────────────────────────────────────

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
    [TAG.Square] = function(obj)
        if obj._frame then obj._frame:Destroy() end
        obj._frame = nil; obj._stroke = nil; obj._props = nil
    end,
    [TAG.Text] = function(obj)
        if obj._label then obj._label:Destroy() end
        obj._label = nil; obj._props = nil
    end,
    [TAG.Line] = function(obj)
        if obj._frame then obj._frame:Destroy() end
        obj._frame = nil; obj._props = nil
    end,
    [TAG.Circle] = function(obj)
        if obj._frame then obj._frame:Destroy() end
        obj._frame = nil; obj._stroke = nil; obj._props = nil
    end,
    [TAG.Quad] = function(obj)
        for _, seg in ipairs(obj._segments or {}) do
            if seg._frame then seg._frame:Destroy() end
        end
        obj._segments = {}; obj._props = nil
    end,
    [TAG.Triangle] = function(obj)
        for _, seg in ipairs(obj._segments or {}) do
            if seg._frame then seg._frame:Destroy() end
        end
        obj._segments = {}; obj._props = nil
    end,
    [TAG.Image] = function(obj)
        if obj._img then obj._img:Destroy() end
        obj._img = nil; obj._props = nil
    end,
}

local CONSTRUCTORS = {
    Square   = newSquare,
    Text     = newText,
    Line     = newLine,
    Circle   = newCircle,
    Quad     = newQuad,
    Triangle = newTriangle,
    Image    = newImage,
}

-- ─── Draw.new ─────────────────────────────────────────────────────────

function Draw.new(kind)
    local ctor = CONSTRUCTORS[kind]
    assert(ctor, "drawlib: unsupported type '" .. tostring(kind) .. "'")

    local obj     = ctor()
    local applier = APPLIERS[obj._tag]
    local remover = REMOVERS[obj._tag]
    local removed = false

    return setmetatable({}, {

        __index = function(_, k)
            if k == "Remove" or k == "Destroy" then
                return function()
                    if removed then return end
                    removed = true
                    if remover then remover(obj) end
                end
            end

            if k == "TextBounds" and obj._label then
                return obj._label.TextBounds
            end

            local props = obj._props
            if props then
                local v = props[k]
                if v ~= nil then return v end
            end
            return nil
        end,

        __newindex = function(_, k, v)
            if removed then return end
            local props = obj._props
            if props and props[k] ~= nil then
                props[k] = v
                if applier then applier(obj) end
            end
        end,
    })
end

-- ─── Draw.Clear ───────────────────────────────────────────────────────

function Draw.Clear()
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
end

return Draw
