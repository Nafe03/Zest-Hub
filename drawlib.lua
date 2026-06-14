--[[
    drawlib.lua
    ──────────────────────────────────────────────────────────────────────
    A small, game-agnostic "Drawing" library that mimics the executor
    Drawing API (Drawing.new("Square"/"Text"/"Line"/"Circle"/"Quad"))
    but is implemented entirely with ScreenGui + Frame/TextLabel/UIStroke,
    so it works on any exploit/executor and any game without relying on
    a native Drawing library.

    USAGE:
        local Draw = loadstring(game:HttpGetAsync(
            "https://raw.githubusercontent.com/<you>/<repo>/main/drawlib.lua"))()

        local box = Draw.new("Square")
        box.Size      = Vector2.new(100, 100)
        box.Position  = Vector2.new(50, 50)
        box.Color     = Color3.fromRGB(255,0,0)
        box.Thickness = 1
        box.Filled    = false
        box.Visible   = true

        local txt = Draw.new("Text")
        txt.Text     = "Hello"
        txt.Position = Vector2.new(100, 100)
        txt.Color    = Color3.new(1,1,1)
        txt.Size     = 14
        txt.Center   = true
        txt.Outline  = true
        txt.Visible  = true

        box:Remove()  -- or box:Destroy()

    SUPPORTED OBJECT TYPES:
        "Square"  - rectangle, optional fill, optional outline
        "Text"    - text label, optional outline / center / right align
        "Line"    - a line between two points (via rotated frame)
        "Circle"  - circle/ring, optional fill (via UICorner)
        "Quad"    - 4-point quadrilateral outline (approx via 4 lines)
        "Image"   - image label (ImageLabel)

    All objects share:
        .Visible  (bool)
        .ZIndex   (number)
        .Color    (Color3)
        .Transparency (0-1, 0 = opaque)
    and support :Remove() / :Destroy() (aliases).
--]]

local Draw = {}

----------------------------------------------------------------------
-- Root ScreenGui (shared canvas for all drawings)
----------------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DrawLibCanvas"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

Draw.ScreenGui = ScreenGui

----------------------------------------------------------------------
-- Base object (handles common props: Visible, ZIndex, Color, Transparency)
----------------------------------------------------------------------
local BaseObject = {}
BaseObject.__index = BaseObject

function BaseObject.new(rootInstance)
    local self = setmetatable({}, BaseObject)
    self._root  = rootInstance
    self._props = {
        Visible      = false,
        ZIndex       = 1,
        Color        = Color3.new(1,1,1),
        Transparency = 0,
    }
    rootInstance.Visible = false
    return self
end

function BaseObject:Remove()
    if self._root then
        self._root:Destroy()
        self._root = nil
    end
    setmetatable(self, nil)
end
BaseObject.Destroy = BaseObject.Remove

----------------------------------------------------------------------
-- helper: clamp 0..1
----------------------------------------------------------------------
local function clamp01(n)
    if n < 0 then return 0 elseif n > 1 then return 1 else return n end
end

----------------------------------------------------------------------
-- SQUARE
----------------------------------------------------------------------
local Square = setmetatable({}, { __index = BaseObject })
Square.__index = Square

local function newSquare()
    local frame = Instance.new("Frame")
    frame.Name = "Draw_Square"
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.BackgroundTransparency = 1 -- starts unfilled
    frame.Size = UDim2.new(0,0,0,0)
    frame.Position = UDim2.new(0,0,0,0)
    frame.Parent = ScreenGui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.new(1,1,1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Enabled = true
    stroke.Parent = frame

    local self = BaseObject.new(frame)
    setmetatable(self, Square)

    self._frame  = frame
    self._stroke = stroke

    self._props.Size      = Vector2.new(0,0)
    self._props.Position  = Vector2.new(0,0)
    self._props.Thickness = 1
    self._props.Filled    = false
    self._props.Rounding  = 0

    return self
end

local function applySquare(self)
    local p = self._props
    self._frame.Visible               = p.Visible
    self._frame.ZIndex                = p.ZIndex
    self._frame.Size                  = UDim2.new(0, p.Size.X, 0, p.Size.Y)
    self._frame.Position              = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    self._frame.BackgroundColor3      = p.Color
    self._frame.BackgroundTransparency = p.Filled and clamp01(p.Transparency) or 1

    self._stroke.Color     = p.Color
    self._stroke.Thickness = p.Thickness
    self._stroke.Enabled   = (p.Thickness or 0) > 0
    self._stroke.Transparency = clamp01(p.Transparency)

    local corner = self._frame:FindFirstChildOfClass("UICorner")
    if (p.Rounding or 0) > 0 then
        if not corner then
            corner = Instance.new("UICorner")
            corner.Parent = self._frame
        end
        corner.CornerRadius = UDim.new(0, p.Rounding)
    elseif corner then
        corner:Destroy()
    end
end

----------------------------------------------------------------------
-- TEXT
----------------------------------------------------------------------
local Text = setmetatable({}, { __index = BaseObject })
Text.__index = Text

local function newText()
    local label = Instance.new("TextLabel")
    label.Name = "Draw_Text"
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Code
    label.Text = ""
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 1
    label.AnchorPoint = Vector2.new(0,0)
    label.Size = UDim2.new(0,200,0,20)
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScreenGui

    local self = BaseObject.new(label)
    setmetatable(self, Text)

    self._label = label

    self._props.Text     = ""
    self._props.Size     = 14
    self._props.Position = Vector2.new(0,0)
    self._props.Center   = false
    self._props.Right    = false
    self._props.Outline  = false
    self._props.OutlineColor = Color3.new(0,0,0)
    self._props.Font     = Enum.Font.Code

    return self
end

local function applyText(self)
    local p = self._props
    self._label.Visible      = p.Visible
    self._label.ZIndex       = p.ZIndex
    self._label.Text         = p.Text
    self._label.TextSize     = p.Size
    self._label.TextColor3   = p.Color
    self._label.TextTransparency = clamp01(p.Transparency)
    self._label.Font          = p.Font

    self._label.Position = UDim2.new(0, p.Position.X, 0, p.Position.Y)

    if p.Center then
        self._label.TextXAlignment = Enum.TextXAlignment.Center
        self._label.AnchorPoint    = Vector2.new(0.5, 0)
    elseif p.Right then
        self._label.TextXAlignment = Enum.TextXAlignment.Right
        self._label.AnchorPoint    = Vector2.new(1, 0)
    else
        self._label.TextXAlignment = Enum.TextXAlignment.Left
        self._label.AnchorPoint    = Vector2.new(0, 0)
    end

    if p.Outline then
        self._label.TextStrokeTransparency = 0
        self._label.TextStrokeColor3       = p.OutlineColor
    else
        self._label.TextStrokeTransparency = 1
    end
end

----------------------------------------------------------------------
-- LINE  (rotated thin frame between two points)
----------------------------------------------------------------------
local Line = setmetatable({}, { __index = BaseObject })
Line.__index = Line

local function newLine()
    local frame = Instance.new("Frame")
    frame.Name = "Draw_Line"
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.AnchorPoint = Vector2.new(0, 0.5)
    frame.Size = UDim2.new(0,0,0,1)
    frame.Parent = ScreenGui

    local self = BaseObject.new(frame)
    setmetatable(self, Line)

    self._frame = frame

    self._props.From      = Vector2.new(0,0)
    self._props.To        = Vector2.new(0,0)
    self._props.Thickness = 1

    return self
end

local function applyLine(self)
    local p = self._props
    local from, to = p.From, p.To
    local delta = to - from
    local length = delta.Magnitude
    local angle  = math.atan2(delta.Y, delta.X)

    self._frame.Visible          = p.Visible
    self._frame.ZIndex           = p.ZIndex
    self._frame.BackgroundColor3 = p.Color
    self._frame.BackgroundTransparency = clamp01(p.Transparency)
    self._frame.Size     = UDim2.new(0, length, 0, math.max(p.Thickness or 1, 1))
    self._frame.Position = UDim2.new(0, from.X, 0, from.Y)
    self._frame.Rotation  = math.deg(angle)
end

----------------------------------------------------------------------
-- CIRCLE  (square frame + UICorner ring; Filled toggles background)
----------------------------------------------------------------------
local Circle = setmetatable({}, { __index = BaseObject })
Circle.__index = Circle

local function newCircle()
    local frame = Instance.new("Frame")
    frame.Name = "Draw_Circle"
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UDim2.new(0,0,0,0)
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.new(1,1,1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local self = BaseObject.new(frame)
    setmetatable(self, Circle)

    self._frame  = frame
    self._stroke = stroke

    self._props.Position  = Vector2.new(0,0) -- center
    self._props.Radius    = 0
    self._props.Thickness = 1
    self._props.Filled    = false
    self._props.NumSides  = 0 -- unused, kept for API parity

    return self
end

local function applyCircle(self)
    local p = self._props
    self._frame.Visible          = p.Visible
    self._frame.ZIndex           = p.ZIndex
    self._frame.Size              = UDim2.new(0, p.Radius * 2, 0, p.Radius * 2)
    self._frame.Position          = UDim2.new(0, p.Position.X, 0, p.Position.Y)
    self._frame.BackgroundColor3  = p.Color
    self._frame.BackgroundTransparency = p.Filled and clamp01(p.Transparency) or 1

    self._stroke.Color        = p.Color
    self._stroke.Thickness    = p.Thickness
    self._stroke.Enabled      = (p.Thickness or 0) > 0
    self._stroke.Transparency = clamp01(p.Transparency)
end

----------------------------------------------------------------------
-- QUAD  (4-point outline, drawn as 4 Lines)
----------------------------------------------------------------------
local Quad = setmetatable({}, { __index = BaseObject })
Quad.__index = Quad

local function newQuad()
    -- A quad is just a container that owns 4 internal Line objects
    local holder = Instance.new("Frame")
    holder.Name = "Draw_Quad_Holder"
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(0,0,0,0)
    holder.Visible = false
    holder.Parent = ScreenGui

    local self = BaseObject.new(holder)
    setmetatable(self, Quad)

    self._lines = {
        newLine(), newLine(), newLine(), newLine()
    }

    self._props.PointA    = Vector2.new(0,0)
    self._props.PointB    = Vector2.new(0,0)
    self._props.PointC    = Vector2.new(0,0)
    self._props.PointD    = Vector2.new(0,0)
    self._props.Thickness = 1
    self._props.Filled    = false -- not supported for outline-only quad

    return self
end

local function applyQuad(self)
    local p = self._props
    local pts = { p.PointA, p.PointB, p.PointC, p.PointD }
    for i = 1, 4 do
        local a = pts[i]
        local b = pts[(i % 4) + 1]
        local ln = self._lines[i]
        ln.Visible   = p.Visible
        ln.ZIndex    = p.ZIndex
        ln.Color     = p.Color
        ln.Transparency = p.Transparency
        ln.Thickness = p.Thickness
        ln.From      = a
        ln.To        = b
    end
end

function Quad:Remove()
    for _, ln in ipairs(self._lines) do ln:Remove() end
    if self._root then self._root:Destroy(); self._root = nil end
    setmetatable(self, nil)
end
Quad.Destroy = Quad.Remove

----------------------------------------------------------------------
-- IMAGE
----------------------------------------------------------------------
local Image = setmetatable({}, { __index = BaseObject })
Image.__index = Image

local function newImage()
    local img = Instance.new("ImageLabel")
    img.Name = "Draw_Image"
    img.BackgroundTransparency = 1
    img.BorderSizePixel = 0
    img.Image = ""
    img.Size = UDim2.new(0,32,0,32)
    img.Parent = ScreenGui

    local self = BaseObject.new(img)
    setmetatable(self, Image)

    self._img = img

    self._props.Position = Vector2.new(0,0)
    self._props.Size     = Vector2.new(32,32)
    self._props.Data     = "" -- image asset id / data

    return self
end

local function applyImage(self)
    local p = self._props
    self._img.Visible       = p.Visible
    self._img.ZIndex        = p.ZIndex
    self._img.Image         = p.Data
    self._img.ImageColor3   = p.Color
    self._img.ImageTransparency = clamp01(p.Transparency)
    self._img.Size          = UDim2.new(0, p.Size.X, 0, p.Size.Y)
    self._img.Position      = UDim2.new(0, p.Position.X, 0, p.Position.Y)
end

----------------------------------------------------------------------
-- Generic property dispatch (the "magic" __newindex / __index)
----------------------------------------------------------------------
local APPLIERS = {
    [Square] = applySquare,
    [Text]   = applyText,
    [Line]   = applyLine,
    [Circle] = applyCircle,
    [Quad]   = applyQuad,
    [Image]  = applyImage,
}

local function wrapClass(class)
    local mt = {}
    mt.__index = function(t, k)
        local raw = rawget(t, "_props")
        if raw and raw[k] ~= nil then return raw[k] end
        return class[k]
    end
    mt.__newindex = function(t, k, v)
        local raw = rawget(t, "_props")
        if raw and raw[k] ~= nil then
            raw[k] = v
            local applier = APPLIERS[class]
            if applier then applier(t) end
        else
            rawset(t, k, v)
        end
    end
    return setmetatable({}, mt)
end

----------------------------------------------------------------------
-- Draw.new(kind)
----------------------------------------------------------------------
local CONSTRUCTORS = {
    Square = newSquare,
    Text   = newText,
    Line   = newLine,
    Circle = newCircle,
    Quad   = newQuad,
    Image  = newImage,
}

function Draw.new(kind)
    local ctor = CONSTRUCTORS[kind]
    if not ctor then
        error("drawlib: unsupported Drawing type '" .. tostring(kind) .. "'")
    end
    local obj = ctor()
    -- proxy so `obj.Color = x` routes through _props + applier
    local class = getmetatable(obj)
    return setmetatable({ _impl = obj }, {
        __index = function(_, k)
            local v = obj[k]
            if type(v) == "function" then
                return function(_, ...) return v(obj, ...) end
            end
            return obj._props[k] ~= nil and obj._props[k] or v
        end,
        __newindex = function(_, k, v)
            if obj._props[k] ~= nil then
                obj._props[k] = v
                local applier = APPLIERS[class]
                if applier then applier(obj) end
            else
                obj[k] = v
            end
        end,
    })
end

----------------------------------------------------------------------
-- Utility: clear everything drawn so far
----------------------------------------------------------------------
function Draw.Clear()
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
end

return Draw
