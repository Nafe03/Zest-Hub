--[[
    drawlib.lua  v2
    ─────────────────────────────────────────────────────────────────────
    Drop-in replacement for the native executor Drawing API.
    Implemented with ScreenGui / Frame / TextLabel / UIStroke so it
    works on any executor without a native Drawing library.

    BUGS FIXED vs v1
    ────────────────
    • __index ternary  – "and/or" returned nil for any _props value that
      was false (e.g. Visible=false read back as nil). Replaced with an
      explicit nil-guard.
    • applyQuad        – was rawset-ting fields on the inner Line objects
      instead of writing to their _props, so applyLine was never called
      and the frames never moved. Now drives _props + applyLine directly.
    • applyLine ghost  – zero-length line (From==To) forced Visible=true
      and left a 1-pixel artefact; now hides automatically when len==0.
    • Post-remove safety – _props is nulled on Remove() so a stale proxy
      silently drops further writes instead of erroring.
    • Unknown key writes silently dropped – the old fallback did
      "obj[k] = v" which could corrupt internal fields like _frame.

    NEW IN v2
    ─────────
    • Triangle  – PointA / PointB / PointC outline (3 segments)
    • Square.OutlineColor  – separate stroke colour (false = use Color)
    • Image.Rounding       – UICorner on ImageLabel
    • Text.TextBounds      – read-only computed property
    • All multi-segment types (Quad, Triangle) share one code-path

    SUPPORTED TYPES
      "Square"   – rect, optional fill / rounding, separate OutlineColor
      "Text"     – TextLabel, optional outline / center / right-align
      "Line"     – rotated Frame from .From → .To
      "Circle"   – UICorner circle/ring, optional fill
      "Quad"     – 4-point outline (4 Line segments)
      "Triangle" – 3-point outline (3 Line segments)
      "Image"    – ImageLabel, optional rounding

    SHARED PROPERTIES  (all types)
      .Visible (bool)  .ZIndex (number)
      .Color (Color3)  .Transparency (0-1, 0=opaque)
      :Remove() / :Destroy()

    USAGE
      local Draw = loadstring(game:HttpGetAsync("<url>"))()

      local box = Draw.new("Square")
      box.Size      = Vector2.new(100, 50)
      box.Position  = Vector2.new(200, 150)
      box.Color     = Color3.fromRGB(255, 80, 80)
      box.Thickness = 1.5
      box.Filled    = false
      box.Visible   = true

      local ln = Draw.new("Line")
      ln.From      = Vector2.new(0, 0)
      ln.To        = Vector2.new(400, 300)
      ln.Thickness = 2
      ln.Color     = Color3.new(1, 1, 0)
      ln.Visible   = true

      box:Remove()
--]]

local Draw = {}

----------------------------------------------------------------------
-- ScreenGui (shared canvas)
----------------------------------------------------------------------
local CoreGui   = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DrawLibCanvas"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer
                           :WaitForChild("PlayerGui")
end
Draw.ScreenGui = ScreenGui

----------------------------------------------------------------------
-- Internal helpers
----------------------------------------------------------------------
local function clamp01(n) return math.clamp(n, 0, 1) end

-- Build a lightweight line-segment struct for use inside Quad / Triangle.
-- These are NOT user-facing proxies; applyLine writes to them directly.
local function makeSegment()
    local f               = Instance.new("Frame")
    f.BorderSizePixel     = 0
    f.BackgroundColor3    = Color3.new(1, 1, 1)
    f.AnchorPoint         = Vector2.new(0, 0.5)
    f.Size                = UDim2.new(0, 0, 0, 1)
    f.Visible             = false
    f.Parent              = ScreenGui
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

----------------------------------------------------------------------
-- Class tags  (plain tables used as unique keys in dispatch maps)
----------------------------------------------------------------------
local TAG = {
    Square   = {},
    Text     = {},
    Line     = {},
    Circle   = {},
    Quad     = {},
    Triangle = {},
    Image    = {},
}

----------------------------------------------------------------------
-- Apply functions   (read _props → write Roblox instances)
-- Each function is the single authoritative renderer for its type.
----------------------------------------------------------------------

-- Forward-declare so applyQuad / applyTriangle can call it before its
-- definition appears in the file.
local applyLine

local function applySquare(obj)
    local p  = obj._props
    local f  = obj._frame
    local sk = obj._stroke

    f.Visible                = p.Visible
    f.ZIndex                 = p.ZIndex
    f.Size                   = UDim2.new(0, p.Size.X,     0, p.Size.Y)
    f.Position               = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    f.BackgroundColor3       = p.Color
    f.BackgroundTransparency = p.Filled and clamp01(p.Transparency) or 1

    -- OutlineColor: false means "inherit Color", any Color3 overrides
    sk.Color        = p.OutlineColor or p.Color
    sk.Thickness    = p.Thickness
    sk.Enabled      = p.Thickness > 0
    sk.Transparency = clamp01(p.Transparency)

    -- Optional rounded corners (Rounding = 0 removes UICorner)
    local corner = f:FindFirstChildOfClass("UICorner")
    if p.Rounding > 0 then
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
    l.TextTransparency = clamp01(p.Transparency)
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

    l.TextStrokeTransparency = p.Outline and clamp01(p.Transparency) or 1
    l.TextStrokeColor3       = p.OutlineColor
end

-- FIX: hide when From==To (was showing a 1px ghost frame at origin)
applyLine = function(obj)
    local p     = obj._props
    local from  = p.From
    local to    = p.To
    local delta = to - from
    local len   = delta.Magnitude

    obj._frame.ZIndex                = p.ZIndex
    obj._frame.BackgroundColor3      = p.Color
    obj._frame.BackgroundTransparency = clamp01(p.Transparency)
    obj._frame.Size                  = UDim2.new(0, len, 0, math.max(p.Thickness, 1))
    obj._frame.Position              = UDim2.new(0, from.X, 0, from.Y)
    obj._frame.Rotation              = math.deg(math.atan2(delta.Y, delta.X))
    obj._frame.Visible               = p.Visible and len > 0
end

local function applyCircle(obj)
    local p = obj._props

    obj._frame.Visible               = p.Visible
    obj._frame.ZIndex                = p.ZIndex
    obj._frame.Size                  = UDim2.new(0, p.Radius * 2, 0, p.Radius * 2)
    obj._frame.Position              = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    obj._frame.BackgroundColor3      = p.Color
    obj._frame.BackgroundTransparency = p.Filled and clamp01(p.Transparency) or 1

    obj._stroke.Color        = p.Color
    obj._stroke.Thickness    = p.Thickness
    obj._stroke.Enabled      = p.Thickness > 0
    obj._stroke.Transparency = clamp01(p.Transparency)
end

-- Shared renderer for Quad and Triangle.
-- FIX: previously applyQuad did "ln.From = v" which rawset on the table
-- (no __newindex) so _props was never updated and applyLine was never
-- called.  Now we write directly to _props and call applyLine ourselves.
local function applySegments(obj, pts)
    local p = obj._props
    local n = #pts
    for i, seg in ipairs(obj._segments) do
        local sp    = seg._props
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
    i.ImageTransparency = clamp01(p.Transparency)
    i.Size              = UDim2.new(0, p.Size.X,     0, p.Size.Y)
    i.Position          = UDim2.new(0, p.Position.X, 0, p.Position.Y)

    local corner = i:FindFirstChildOfClass("UICorner")
    if p.Rounding > 0 then
        if not corner then
            corner        = Instance.new("UICorner")
            corner.Parent = i
        end
        corner.CornerRadius = UDim.new(0, p.Rounding)
    elseif corner then
        corner:Destroy()
    end
end

----------------------------------------------------------------------
-- Constructors  (return plain tables; TAG field identifies the type)
----------------------------------------------------------------------
local function newSquare()
    local f                  = Instance.new("Frame")
    f.Name                   = "Draw_Square"
    f.BorderSizePixel        = 0
    f.BackgroundColor3       = Color3.new(1, 1, 1)
    f.BackgroundTransparency = 1
    f.Size                   = UDim2.new(0, 0, 0, 0)
    f.Parent                 = ScreenGui

    local sk             = Instance.new("UIStroke")
    sk.Thickness         = 1
    sk.Color             = Color3.new(1, 1, 1)
    sk.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    sk.Enabled           = true
    sk.Parent            = f

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
            -- false = inherit Color for stroke; set to a Color3 to override
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
    l.Size                   = UDim2.new(0, 200, 0, 20)
    l.TextXAlignment         = Enum.TextXAlignment.Left
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
    f.BackgroundColor3       = Color3.new(1, 1, 1)
    f.BackgroundTransparency = 1
    f.AnchorPoint            = Vector2.new(0.5, 0.5)
    f.Size                   = UDim2.new(0, 0, 0, 0)
    f.Parent                 = ScreenGui

    local corner            = Instance.new("UICorner")
    corner.CornerRadius     = UDim.new(1, 0)
    corner.Parent           = f

    local sk                = Instance.new("UIStroke")
    sk.Thickness            = 1
    sk.Color                = Color3.new(1, 1, 1)
    sk.ApplyStrokeMode      = Enum.ApplyStrokeMode.Border
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
            NumSides     = 0,   -- unused; kept for API parity
        },
    }
end

-- Shared factory for multi-segment outlines (Quad, Triangle)
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
    return newPoly(TAG.Quad, { "PointA", "PointB", "PointC", "PointD" }, 4)
end

local function newTriangle()
    return newPoly(TAG.Triangle, { "PointA", "PointB", "PointC" }, 3)
end

local function newImage()
    local i              = Instance.new("ImageLabel")
    i.Name               = "Draw_Image"
    i.BackgroundTransparency = 1
    i.BorderSizePixel    = 0
    i.Image              = ""
    i.Size               = UDim2.new(0, 32, 0, 32)
    i.Parent             = ScreenGui

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

----------------------------------------------------------------------
-- Dispatch tables
----------------------------------------------------------------------
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
        if obj._frame  then obj._frame:Destroy()  end
        obj._frame = nil; obj._stroke = nil; obj._props = nil
    end,
    [TAG.Text] = function(obj)
        if obj._label  then obj._label:Destroy()  end
        obj._label = nil; obj._props = nil
    end,
    [TAG.Line] = function(obj)
        if obj._frame  then obj._frame:Destroy()  end
        obj._frame = nil; obj._props = nil
    end,
    [TAG.Circle] = function(obj)
        if obj._frame  then obj._frame:Destroy()  end
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
        if obj._img    then obj._img:Destroy()    end
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

----------------------------------------------------------------------
-- Draw.new(kind)  →  user-facing proxy
-- The proxy is the only thing the caller ever holds.  It routes
-- property reads/writes through _props so every change immediately
-- re-renders the underlying Roblox instances.
----------------------------------------------------------------------
function Draw.new(kind)
    local ctor = CONSTRUCTORS[kind]
    assert(ctor, "drawlib: unsupported type '" .. tostring(kind) .. "'")

    local obj     = ctor()
    local applier = APPLIERS[obj._tag]
    local remover = REMOVERS[obj._tag]

    return setmetatable({}, {

        -- FIX: replaced "and/or" ternary with explicit nil-check.
        -- Old code: "props[k] ~= nil and props[k] or v" returned v (nil)
        -- whenever props[k] was false, breaking any boolean property read.
        __index = function(_, k)
            -- Destroy / Remove (not in _props; handled specially)
            if k == "Remove" or k == "Destroy" then
                return function()
                    if remover then remover(obj) end
                end
            end

            -- Read-only computed property: TextBounds (Text only)
            if k == "TextBounds" and obj._label then
                return obj._label.TextBounds
            end

            -- _props lookup  — works correctly for false / 0 / ""
            local props = obj._props
            if props then
                local v = props[k]
                if v ~= nil then return v end
            end
            return nil
        end,

        __newindex = function(_, k, v)
            local props = obj._props
            -- Only known _props keys are routed through the applier.
            -- Unknown keys are silently dropped (no accidental rawset
            -- on the internal obj table which could corrupt _frame etc.)
            if props and props[k] ~= nil then
                props[k] = v
                if applier then applier(obj) end
            end
        end,
    })
end

----------------------------------------------------------------------
-- Draw.Clear()  –  destroy every active drawing
----------------------------------------------------------------------
function Draw.Clear()
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
end

return Draw
