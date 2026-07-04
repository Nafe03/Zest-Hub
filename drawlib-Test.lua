local Draw = {}

local CoreGui    = game:GetService("CoreGui")
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ── CANVAS SETUP ──────────────────────────────────────────────────
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

-- ── CAMERA CONNECTIONS ──────────────────────────────────────────────
local Camera = workspace.CurrentCamera
Draw.ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)

local viewportConnection
local function updateViewport()
	Draw.ViewportSize = Camera.ViewportSize
end

local function setupCamera()
	if viewportConnection then viewportConnection:Disconnect() end
	if Camera then
		viewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateViewport)
		updateViewport()
	end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
	setupCamera()
end)
setupCamera()

function Draw.GetCenter()
	return Vector2.new(Draw.ViewportSize.X * 0.5, Draw.ViewportSize.Y * 0.5)
end

local function c01(n) return math.clamp(n, 0, 1) end

-- ── TAGS & DEFAULTS ─────────────────────────────────────────────────
local TAG = {
	Square   = "Square",
	Text     = "Text",
	Line     = "Line",
	Circle   = "Circle",
	Quad     = "Quad",
	Triangle = "Triangle",
	Image    = "Image",
}

local DEFAULTS = {
	Square = {
		Visible=false, ZIndex=1, Color=Color3.new(1,1,1), Transparency=0,
		Size=Vector2.new(0,0), Position=Vector2.new(0,0),
		Thickness=1, Filled=false, Rounding=0, OutlineColor=false,
		FillColor=false, FillTransparency=0, GradientRotation=0,
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
		FillColor=false, FillTransparency=0, GradientRotation=0,
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

local VALID_KEYS = {}
for name, defaults in pairs(DEFAULTS) do
	VALID_KEYS[name] = { Gradient = true, GradientTransparency = true }
	for k in pairs(defaults) do
		VALID_KEYS[name][k] = true
	end
end

local function shallowCopy(t)
	local o = {}
	for k, v in pairs(t) do o[k] = v end
	return o
end

-- ── POOLS & DIRTY MANAGEMENT ───────────────────────────────────────
local Pool = {
	[TAG.Square] = {}, [TAG.Text] = {}, [TAG.Line] = {},
	[TAG.Circle] = {}, [TAG.Quad] = {}, [TAG.Triangle] = {},
	[TAG.Image] = {}, ["Segment"] = {}
}

local ActiveObjects = setmetatable({}, { __mode = "k" }) -- Weak table!
local DirtyQueue = {}
local IsQueued = {}

local function MarkDirty(obj)
	if not IsQueued[obj] then
		IsQueued[obj] = true
		table.insert(DirtyQueue, obj)
	end
end

-- ── SHARED LOGIC ───────────────────────────────────────────────────
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

local function updateCorner(obj, rounding, parent)
	if obj._lastRounding ~= rounding then
		obj._lastRounding = rounding
		local corner = obj._corner
		if rounding and rounding > 0 then
			if not corner then
				corner = Instance.new("UICorner")
				corner.Parent = parent
				obj._corner = corner
			end
			corner.CornerRadius = UDim.new(0, rounding)
		elseif corner then
			corner.Parent = nil
			table.insert(Pool.Segment, corner) -- reuse UICorner secretly
			obj._corner = nil
		end
	end
end

-- ── APPLIERS ───────────────────────────────────────────────────────
local applyLine

local function applySquare(obj)
	local p, f, sk, grad = obj._props, obj._frame, obj._stroke, obj._gradient
	if f.Visible ~= p.Visible then f.Visible = p.Visible end
	if not p.Visible then return end

	if f.ZIndex  ~= p.ZIndex  then f.ZIndex  = p.ZIndex  end
	local size = UDim2.new(0, p.Size.X, 0, p.Size.Y)
	if f.Size ~= size then f.Size = size end
	local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
	if f.Position ~= pos then f.Position = pos end

	local fillColor = p.FillColor or p.Color
	if f.BackgroundColor3 ~= fillColor then f.BackgroundColor3 = fillColor end
	local bgTrans = p.Filled and c01(p.FillTransparency) or 1
	if f.BackgroundTransparency ~= bgTrans then f.BackgroundTransparency = bgTrans end

	local outlineColor = p.OutlineColor or p.Color
	if sk.Color ~= outlineColor then sk.Color = outlineColor end
	if sk.Thickness ~= p.Thickness then sk.Thickness = p.Thickness end
	local skEnabled = p.Thickness > 0
	if sk.Enabled ~= skEnabled then sk.Enabled = skEnabled end
	local skTrans = c01(p.Transparency)
	if sk.Transparency ~= skTrans then sk.Transparency = skTrans end

	applyGradient(grad, p)
	updateCorner(obj, p.Rounding, f)
end

local function applyText(obj)
	local p, l = obj._props, obj._label
	if l.Visible ~= p.Visible then l.Visible = p.Visible end
	if not p.Visible then return end

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
			l.TextXAlignment, l.AnchorPoint = Enum.TextXAlignment.Center, Vector2.new(0.5, 0)
		elseif mode == "right" then
			l.TextXAlignment, l.AnchorPoint = Enum.TextXAlignment.Right, Vector2.new(1, 0)
		else
			l.TextXAlignment, l.AnchorPoint = Enum.TextXAlignment.Left, Vector2.new(0, 0)
		end
	end

	local strokeTrans = p.Outline and trans or 1
	if l.TextStrokeTransparency ~= strokeTrans then l.TextStrokeTransparency = strokeTrans end
	if l.TextStrokeColor3 ~= p.OutlineColor then l.TextStrokeColor3 = p.OutlineColor end
end

applyLine = function(obj)
	local p, f = obj._props, obj._frame
	local delta = p.To - p.From
	local len = delta.Magnitude

	if len == 0 or not p.Visible then
		if f.Visible then f.Visible = false end
		return
	end

	local thick = p.Thickness > 1 and p.Thickness or 1
	local angle = math.deg(math.atan2(delta.Y, delta.X))
	local midX  = (p.From.X + p.To.X) * 0.5
	local midY  = (p.From.Y + p.To.Y) * 0.5

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
	local p, f, sk, grad = obj._props, obj._frame, obj._stroke, obj._gradient
	if f.Visible ~= p.Visible then f.Visible = p.Visible end
	if not p.Visible then return end

	local d = p.Radius * 2
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

local _scratchPts = {}
local function applySegments(obj, pts, n)
	local p = obj._props
	if not p.Visible then
		for i = 1, n do
			local sf = obj._segments[i]._frame
			if sf.Visible then sf.Visible = false end
		end
		return
	end
	
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
	_scratchPts[1], _scratchPts[2], _scratchPts[3], _scratchPts[4] = p.PointA, p.PointB, p.PointC, p.PointD
	applySegments(obj, _scratchPts, 4)
end

local function applyTriangle(obj)
	local p = obj._props
	_scratchPts[1], _scratchPts[2], _scratchPts[3] = p.PointA, p.PointB, p.PointC
	applySegments(obj, _scratchPts, 3)
end

local function applyImage(obj)
	local p, i = obj._props, obj._img
	if i.Visible ~= p.Visible then i.Visible = p.Visible end
	if not p.Visible then return end

	if i.ZIndex  ~= p.ZIndex  then i.ZIndex  = p.ZIndex  end
	if i.Image   ~= p.Data    then i.Image   = p.Data    end
	if i.ImageColor3 ~= p.Color then i.ImageColor3 = p.Color end

	local trans = c01(p.Transparency)
	if i.ImageTransparency ~= trans then i.ImageTransparency = trans end
	local size = UDim2.new(0, p.Size.X, 0, p.Size.Y)
	if i.Size ~= size then i.Size = size end
	local pos = UDim2.new(0, p.Position.X, 0, p.Position.Y)
	if i.Position ~= pos then i.Position = pos end

	updateCorner(obj, p.Rounding, i)
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

RunService.RenderStepped:Connect(function()
	if #DirtyQueue == 0 then return end
	for i = 1, #DirtyQueue do
		local obj = DirtyQueue[i]
		if obj._props then
			APPLIERS[obj._tag](obj)
		end
		IsQueued[obj] = nil
	end
	table.clear(DirtyQueue)
end)

-- ── CONSTRUCTORS ────────────────────────────────────────────────────
local function getSegment()
	local seg = table.remove(Pool.Segment)
	if not seg then
		local f = Instance.new("Frame")
		f.Name = "Draw_Seg"; f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = UDim2.new(0,0,0,1); f.Visible = false
		f.Parent = ScreenGui
		seg = { _frame = f, _props = {} }
	end
	return seg
end

local function newSquare()
	local obj = table.remove(Pool[TAG.Square])
	if not obj then
		local f = Instance.new("Frame")
		f.Name = "Draw_Square"; f.BorderSizePixel = 0
		f.BackgroundTransparency = 1; f.Visible = false
		f.Parent = ScreenGui
		
		local sk = Instance.new("UIStroke")
		sk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; sk.Parent = f
		
		local grad = Instance.new("UIGradient")
		grad.Enabled = false; grad.Parent = f
		
		obj = { _tag = TAG.Square, _frame = f, _stroke = sk, _gradient = grad, _corner = nil, _lastRounding = 0 }
	end
	return obj
end

local function newText()
	local obj = table.remove(Pool[TAG.Text])
	if not obj then
		local l = Instance.new("TextLabel")
		l.Name = "Draw_Text"; l.BackgroundTransparency = 1; l.BorderSizePixel = 0
		l.AnchorPoint = Vector2.new(0,0); l.AutomaticSize = Enum.AutomaticSize.None
		l.Visible = false; l.Parent = ScreenGui
		obj = { _tag = TAG.Text, _label = l, _lastAlign = "left" }
	end
	return obj
end

local function newLine()
	local obj = table.remove(Pool[TAG.Line])
	if not obj then
		local f = Instance.new("Frame")
		f.Name = "Draw_Line"; f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5); f.Visible = false; f.Parent = ScreenGui
		obj = { _tag = TAG.Line, _frame = f }
	end
	return obj
end

local function newCircle()
	local obj = table.remove(Pool[TAG.Circle])
	if not obj then
		local f = Instance.new("Frame")
		f.Name = "Draw_Circle"; f.BorderSizePixel = 0
		f.BackgroundTransparency = 1; f.AnchorPoint = Vector2.new(0.5,0.5)
		f.Visible = false; f.Parent = ScreenGui
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1,0); corner.Parent = f
		
		local sk = Instance.new("UIStroke")
		sk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; sk.Parent = f
		
		local grad = Instance.new("UIGradient")
		grad.Enabled = false; grad.Parent = f
		
		obj = { _tag = TAG.Circle, _frame = f, _stroke = sk, _gradient = grad }
	end
	return obj
end

local function newPoly(tag, nSegs)
	local obj = table.remove(Pool[tag])
	if not obj then
		obj = { _tag = tag, _segments = {} }
	end
	for i = 1, nSegs do obj._segments[i] = getSegment() end
	return obj
end

local function newImage()
	local obj = table.remove(Pool[TAG.Image])
	if not obj then
		local i = Instance.new("ImageLabel")
		i.Name = "Draw_Image"; i.BackgroundTransparency = 1
		i.BorderSizePixel = 0; i.Visible = false; i.Parent = ScreenGui
		obj = { _tag = TAG.Image, _img = i, _corner = nil, _lastRounding = 0 }
	end
	return obj
end

local CONSTRUCTORS = {
	Square=newSquare, Text=newText, Line=newLine, Circle=newCircle,
	Quad=function() return newPoly(TAG.Quad, 4) end,
	Triangle=function() return newPoly(TAG.Triangle, 3) end,
	Image=newImage,
}

-- ── PUBLIC API ──────────────────────────────────────────────────────

function Draw.new(kind)
	local ctor = CONSTRUCTORS[kind]
	assert(ctor, "drawlib: unsupported type '" .. tostring(kind) .. "'")
	
	local obj = ctor()
	obj._props = shallowCopy(DEFAULTS[kind])
	obj._validKeys = VALID_KEYS[kind]
	
	local removed = false

	local handle = setmetatable({}, {
		__index = function(_, k)
			if k == "Remove" or k == "Destroy" then
				return function()
					if removed then return end
					removed = true
					ActiveObjects[obj] = nil
					
					-- Hide GUI elements and pool them
					if obj._frame then obj._frame.Visible = false end
					if obj._label then obj._label.Visible = false end
					if obj._img then obj._img.Visible = false end
					
					if obj._segments then
						for _, seg in ipairs(obj._segments) do
							seg._frame.Visible = false
							table.insert(Pool.Segment, seg)
						end
						table.clear(obj._segments)
					end
					
					obj._props = nil
					table.insert(Pool[obj._tag], obj)
				end
			end
			
			if k == "Set" then
				return function(self, newProps)
					if removed then return end
					for pk, pv in pairs(newProps) do
						if obj._validKeys[pk] and obj._props[pk] ~= pv then
							obj._props[pk] = pv
						end
					end
					MarkDirty(obj)
				end
			end
			
			if k == "TextBounds" and obj._label then return obj._label.TextBounds end
			
			local props = obj._props
			if props and props[k] ~= nil then return props[k] end
			if obj._validKeys[k] then return props[k] end
			return nil
		end,
		__newindex = function(_, k, v)
			if removed or not obj._props then return end
			if obj._validKeys[k] and obj._props[k] ~= v then
				obj._props[k] = v
				MarkDirty(obj)
			end
		end,
	})

	ActiveObjects[obj] = handle
	MarkDirty(obj)
	return handle
end

function Draw.Clear()
	for obj, handle in pairs(ActiveObjects) do
		handle.Remove()
	end
end

return Draw
