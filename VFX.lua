local VFXRegistry = {}

-- ═══════════════════════════════════════════════════════════
-- VFX DEFINITIONS
-- ═══════════════════════════════════════════════════════════

VFXRegistry.Effects = {
    ["Purple Floor"] = {
        Name = "Purple Floor",
        Description = "Purple particle floor effect with 3 layers",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            
            -- Attachment: Main
            local attach = Instance.new("Attachment")
            attach.Name = "PurpleFloorVFX"
            attach.CFrame = CFrame.new(0, -2.8, 0)
            attach.Parent = root

            -- ParticleEmitter: Floor1
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "Floor1"
            emitter1.Texture = "rbxassetid://16956569427"
            emitter1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.819608, 0.454902, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.819608, 0.454902, 1))
            })
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(1, 3.15534, 0)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.29302, 0, 0),
                NumberSequenceKeypoint.new(0.49689, 0, 0),
                NumberSequenceKeypoint.new(0.70076, 0, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter1.Lifetime = NumberRange.new(1)
            emitter1.Rate = 1.5
            emitter1.Speed = NumberRange.new(0.001)
            emitter1.Acceleration = Vector3.new(0, 0, 0)
            emitter1.Drag = 0
            emitter1.VelocityInheritance = 0
            emitter1.EmissionDirection = Enum.NormalId.Top
            emitter1.Rotation = NumberRange.new(0)
            emitter1.RotSpeed = NumberRange.new(0)
            emitter1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter1.LightEmission = 1
            emitter1.LightInfluence = 0
            emitter1.Brightness = 5
            emitter1.ZOffset = 0
            emitter1.Enabled = true
            emitter1.TimeScale = 1
            emitter1.Parent = attach

            -- ParticleEmitter: Floor2
            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Name = "Floor2"
            emitter2.Texture = "rbxassetid://14591895021"
            emitter2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.819608, 0.454902, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.819608, 0.454902, 1))
            })
            emitter2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 4.2, 0),
                NumberSequenceKeypoint.new(1, 4.2, 0)
            })
            emitter2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.49689, 0, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter2.Lifetime = NumberRange.new(1)
            emitter2.Rate = 1.5
            emitter2.Speed = NumberRange.new(0.001)
            emitter2.Acceleration = Vector3.new(0, 0, 0)
            emitter2.Drag = 0
            emitter2.VelocityInheritance = 0
            emitter2.EmissionDirection = Enum.NormalId.Top
            emitter2.Rotation = NumberRange.new(0)
            emitter2.RotSpeed = NumberRange.new(0)
            emitter2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter2.LightEmission = 1
            emitter2.LightInfluence = 0
            emitter2.Brightness = 5
            emitter2.ZOffset = 0
            emitter2.Enabled = true
            emitter2.TimeScale = 1
            emitter2.Parent = attach

            -- ParticleEmitter: Floor3
            local emitter3 = Instance.new("ParticleEmitter")
            emitter3.Name = "Floor3"
            emitter3.Texture = "rbxassetid://16956497860"
            emitter3.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.819608, 0.454902, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.819608, 0.454902, 1))
            })
            emitter3.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 3.5, 0),
                NumberSequenceKeypoint.new(1, 3.5, 0)
            })
            emitter3.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.49689, 0, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter3.Lifetime = NumberRange.new(1)
            emitter3.Rate = 1.5
            emitter3.Speed = NumberRange.new(0.001)
            emitter3.Acceleration = Vector3.new(0, 0, 0)
            emitter3.Drag = 0
            emitter3.VelocityInheritance = 0
            emitter3.EmissionDirection = Enum.NormalId.Top
            emitter3.Rotation = NumberRange.new(0)
            emitter3.RotSpeed = NumberRange.new(0)
            emitter3.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter3.LightEmission = 1
            emitter3.LightInfluence = 0
            emitter3.Brightness = 5
            emitter3.ZOffset = 0
            emitter3.Enabled = true
            emitter3.TimeScale = 1
            emitter3.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },
    
    ["Blue Floor"] = {
        Name = "Blue Floor",
        Description = "Cool blue particle floor effect",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            
            local attach = Instance.new("Attachment")
            attach.Name = "BlueFloorVFX"
            attach.CFrame = CFrame.new(0, -2.8, 0)
            attach.Parent = root

            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "Floor1"
            emitter1.Texture = "rbxassetid://16956569427"
            emitter1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.2, 0.6, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.2, 0.6, 1))
            })
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(1, 3.15534, 0)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.29302, 0, 0),
                NumberSequenceKeypoint.new(0.49689, 0, 0),
                NumberSequenceKeypoint.new(0.70076, 0, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter1.Lifetime = NumberRange.new(1)
            emitter1.Rate = 1.5
            emitter1.Speed = NumberRange.new(0.001)
            emitter1.EmissionDirection = Enum.NormalId.Top
            emitter1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter1.LightEmission = 1
            emitter1.LightInfluence = 0
            emitter1.Brightness = 5
            emitter1.Enabled = true
            emitter1.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },

    ["Quake"] = {
        Name = "Quake",
        Description = "Quake",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}

            -- Attachment: 1
            local attach1 = Instance.new("Attachment")
            attach1.Name = "1"
            attach1.CFrame = CFrame.new(-0.004150, 4.122253, 0.185486, 1.000000, 0.000000, 0.000000, 0.000000, -1.000000, 0.000000, 0.000000, 0.000000, -1.000000)
            attach1.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach1.SecondaryAxis = Vector3.new(0.000000, -1.000000, 0.000000)
            attach1.Parent = root
            
            -- ParticleEmitter: Explosions 2
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "Explosions 2"
            emitter1.Texture = "rbxassetid://8214516794"
            emitter1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 11.000000, 0.000000)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.499180, 0.750000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter1.Lifetime = NumberRange.new(0.500000)
            emitter1.Rate = 6.250000
            emitter1.Rotation = NumberRange.new(-100.000000, -80.000000)
            emitter1.RotSpeed = NumberRange.new(0.000000)
            emitter1.Orientation = Enum.ParticleOrientation.VelocityParallel
            emitter1.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter1.FlipbookFramerate = NumberRange.new(1.000000)
            emitter1.LockedToPart = true
            emitter1.LightEmission = 1.000000
            emitter1.ZOffset = -0.500000
            emitter1.Shape = Enum.ParticleEmitterShape.Box
            emitter1.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter1.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter1.ShapePartial = 1.000000
            emitter1.Speed = NumberRange.new(8.000000)
            emitter1.Acceleration = Vector3.new(0.000000, 15.000000, 0.000000)
            emitter1.Drag = 5.000000
            emitter1.SpreadAngle = Vector2.new(360.000000, 360.000000)
            emitter1.VelocitySpread = 360.000000
            emitter1.Parent = attach1
            
            -- ParticleEmitter: Explosions 1
            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Name = "Explosions 1"
            emitter2.Texture = "rbxassetid://8214516794"
            emitter2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            emitter2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 11.000000, 0.000000)
            })
            emitter2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.499180, 0.750000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter2.Lifetime = NumberRange.new(0.500000)
            emitter2.Rate = 6.250000
            emitter2.Rotation = NumberRange.new(-100.000000, -80.000000)
            emitter2.RotSpeed = NumberRange.new(0.000000)
            emitter2.Orientation = Enum.ParticleOrientation.VelocityParallel
            emitter2.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter2.FlipbookFramerate = NumberRange.new(1.000000)
            emitter2.LockedToPart = true
            emitter2.LightEmission = 1.000000
            emitter2.ZOffset = -0.500000
            emitter2.Shape = Enum.ParticleEmitterShape.Box
            emitter2.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter2.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter2.ShapePartial = 1.000000
            emitter2.Speed = NumberRange.new(8.000000)
            emitter2.Acceleration = Vector3.new(0.000000, 15.000000, 0.000000)
            emitter2.Drag = 5.000000
            emitter2.SpreadAngle = Vector2.new(360.000000, 360.000000)
            emitter2.VelocitySpread = 360.000000
            emitter2.Parent = attach1

            table.insert(createdInstances, attach1)

            -- Attachment: T2
            local attach2 = Instance.new("Attachment")
            attach2.Name = "T2"
            attach2.CFrame = CFrame.new(0.004150, -17.245850, 0.000000, 0.000000, 1.000000, -0.000000, -1.000000, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            attach2.Axis = Vector3.new(0.000000, -1.000000, 0.000000)
            attach2.SecondaryAxis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach2.Parent = root
            
            -- Beam: Beam 2
            local beam1 = Instance.new("Beam")
            beam1.Name = "Beam 2"
            beam1.Texture = "rbxassetid://12414458390"
            beam1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            beam1.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                ColorSequenceKeypoint.new(0.900000, 0.350000, 0.000000),
                ColorSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            beam1.Width0 = 11.000000
            beam1.Width1 = 11.000000
            beam1.CurveSize0 = 0.000000
            beam1.CurveSize1 = 0.000000
            beam1.LightEmission = 1.000000
            beam1.LightInfluence = 1.000000
            beam1.Segments = 10.000000
            beam1.TextureMode = Enum.TextureMode.Stretch
            beam1.TextureLength = 0.350000
            beam1.TextureSpeed = -1.000000
            beam1.ZOffset = 1.000000
            beam1.Enabled = true
            beam1.FaceCamera = true
            beam1.Brightness = 1.000000
            beam1.Parent = attach2
            
            -- Beam: Beam 4
            local beam2 = Instance.new("Beam")
            beam2.Name = "Beam 4"
            beam2.Texture = "rbxassetid://13712010201"
            beam2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            beam2.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                ColorSequenceKeypoint.new(0.900000, 0.750000, 0.000000),
                ColorSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            beam2.Width0 = 10.000000
            beam2.Width1 = 10.000000
            beam2.CurveSize0 = 0.000000
            beam2.CurveSize1 = 0.000000
            beam2.LightEmission = 1.000000
            beam2.LightInfluence = 1.000000
            beam2.Segments = 10.000000
            beam2.TextureMode = Enum.TextureMode.Stretch
            beam2.TextureLength = 0.750000
            beam2.TextureSpeed = -3.000000
            beam2.ZOffset = 1.000000
            beam2.Enabled = true
            beam2.FaceCamera = true
            beam2.Brightness = 1.000000
            beam2.Parent = attach2
            
            -- Beam: Beam 3
            local beam3 = Instance.new("Beam")
            beam3.Name = "Beam 3"
            beam3.Texture = "rbxassetid://13370272316"
            beam3.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            beam3.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                ColorSequenceKeypoint.new(0.900000, 0.350000, 0.000000),
                ColorSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            beam3.Width0 = 8.000000
            beam3.Width1 = 8.000000
            beam3.CurveSize0 = 0.000000
            beam3.CurveSize1 = 0.000000
            beam3.LightEmission = 1.000000
            beam3.LightInfluence = 1.000000
            beam3.Segments = 10.000000
            beam3.TextureMode = Enum.TextureMode.Stretch
            beam3.TextureLength = 0.250000
            beam3.TextureSpeed = -1.000000
            beam3.ZOffset = -1.000000
            beam3.Enabled = true
            beam3.FaceCamera = true
            beam3.Brightness = 1.000000
            beam3.Parent = attach2
            
            -- Beam: Beam 1
            local beam4 = Instance.new("Beam")
            beam4.Name = "Beam 1"
            beam4.Texture = "rbxassetid://13712011229"
            beam4.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            beam4.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                ColorSequenceKeypoint.new(0.900000, 0.757000, 0.000000),
                ColorSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            beam4.Width0 = 8.500000
            beam4.Width1 = 8.500000
            beam4.CurveSize0 = 0.000000
            beam4.CurveSize1 = 0.000000
            beam4.LightEmission = 1.000000
            beam4.LightInfluence = 1.000000
            beam4.Segments = 10.000000
            beam4.TextureMode = Enum.TextureMode.Stretch
            beam4.TextureLength = 0.250000
            beam4.TextureSpeed = -1.500000
            beam4.ZOffset = 1.000000
            beam4.Enabled = true
            beam4.FaceCamera = true
            beam4.Brightness = 1.000000
            beam4.Parent = attach2

            table.insert(createdInstances, attach2)

            -- Attachment: 2
            local attach3 = Instance.new("Attachment")
            attach3.Name = "2"
            attach3.CFrame = CFrame.new(0.000000, -1.373575, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            attach3.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach3.SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000)
            attach3.Parent = root
            
            -- ParticleEmitter: Lightning 1
            local emitter3 = Instance.new("ParticleEmitter")
            emitter3.Name = "Lightning 1"
            emitter3.Texture = "http://www.roblox.com/asset/?id=12072303767"
            emitter3.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            emitter3.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 6.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 6.000000, 0.000000)
            })
            emitter3.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.050000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.100000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.150000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.200000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.250000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.300000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.350000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.400000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.450000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.501000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.550000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.600000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.650000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.700000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.750000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.800000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.850000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.900000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter3.Lifetime = NumberRange.new(0.400000)
            emitter3.Rate = 5.000000
            emitter3.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter3.RotSpeed = NumberRange.new(-100.000000, 100.000000)
            emitter3.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            emitter3.FlipbookFramerate = NumberRange.new(25.000000)
            emitter3.LockedToPart = true
            emitter3.LightEmission = 1.000000
            emitter3.ZOffset = -1.000000
            emitter3.Shape = Enum.ParticleEmitterShape.Box
            emitter3.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter3.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter3.ShapePartial = 1.000000
            emitter3.Speed = NumberRange.new(20.000000)
            emitter3.Acceleration = Vector3.new(0.000000, 15.000000, 0.000000)
            emitter3.SpreadAngle = Vector2.new(360.000000, 360.000000)
            emitter3.VelocitySpread = 360.000000
            emitter3.Parent = attach3
            
            -- ParticleEmitter: Lightning 2
            local emitter4 = Instance.new("ParticleEmitter")
            emitter4.Name = "Lightning 2"
            emitter4.Texture = "http://www.roblox.com/asset/?id=12072303767"
            emitter4.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            emitter4.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 6.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 6.000000, 0.000000)
            })
            emitter4.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.050000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.100000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.150000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.200000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.250000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.300000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.350000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.400000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.450000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.501000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.550000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.600000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.650000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.700000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.750000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.800000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.850000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(0.900000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter4.Lifetime = NumberRange.new(0.400000)
            emitter4.Rate = 5.000000
            emitter4.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter4.RotSpeed = NumberRange.new(-100.000000, 100.000000)
            emitter4.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            emitter4.FlipbookFramerate = NumberRange.new(25.000000)
            emitter4.LockedToPart = true
            emitter4.LightInfluence = 0.000000
            emitter4.Brightness = 3.000000
            emitter4.ZOffset = -1.000000
            emitter4.Shape = Enum.ParticleEmitterShape.Box
            emitter4.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter4.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter4.ShapePartial = 1.000000
            emitter4.Speed = NumberRange.new(20.000000)
            emitter4.Acceleration = Vector3.new(0.000000, 15.000000, 0.000000)
            emitter4.SpreadAngle = Vector2.new(360.000000, 360.000000)
            emitter4.VelocitySpread = 360.000000
            emitter4.Parent = attach3

            table.insert(createdInstances, attach3)

            -- Attachment: B (Quake)
            local attach4 = Instance.new("Attachment")
            attach4.Name = "B"
            attach4.CFrame = CFrame.new(-0.003998, -2.878001, 0.185120, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            attach4.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach4.SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000)
            attach4.Parent = root
            
            -- ParticleEmitter: Quake 2
            local emitter5 = Instance.new("ParticleEmitter")
            emitter5.Name = "Quake 2"
            emitter5.Texture = "rbxassetid://13516765561"
            emitter5.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            emitter5.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 10.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 10.000000, 0.000000)
            })
            emitter5.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.500000, 0.550000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter5.Lifetime = NumberRange.new(1.500000)
            emitter5.Rate = 1.000000
            emitter5.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter5.RotSpeed = NumberRange.new(0.000000)
            emitter5.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter5.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter5.FlipbookFramerate = NumberRange.new(5.000000)
            emitter5.LockedToPart = true
            emitter5.LightEmission = 1.000000
            emitter5.ZOffset = 0.250000
            emitter5.Shape = Enum.ParticleEmitterShape.Box
            emitter5.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter5.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter5.ShapePartial = 1.000000
            emitter5.Speed = NumberRange.new(0.001000)
            emitter5.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter5.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter5.VelocitySpread = 0.000000
            emitter5.Parent = attach4
            
            -- ParticleEmitter: Quake 1
            local emitter6 = Instance.new("ParticleEmitter")
            emitter6.Name = "Quake 1"
            emitter6.Texture = "rbxassetid://12102242479"
            emitter6.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            emitter6.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 10.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 10.000000, 0.000000)
            })
            emitter6.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.500000, 0.550000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter6.Lifetime = NumberRange.new(1.500000)
            emitter6.Rate = 1.000000
            emitter6.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter6.RotSpeed = NumberRange.new(0.000000)
            emitter6.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter6.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter6.FlipbookFramerate = NumberRange.new(5.000000)
            emitter6.LockedToPart = true
            emitter6.LightInfluence = 0.000000
            emitter6.Brightness = 3.000000
            emitter6.Shape = Enum.ParticleEmitterShape.Box
            emitter6.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter6.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter6.ShapePartial = 1.000000
            emitter6.Speed = NumberRange.new(0.001000)
            emitter6.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter6.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter6.VelocitySpread = 0.000000
            emitter6.Parent = attach4

            table.insert(createdInstances, attach4)

            -- Attachment: B (Beam)
            local attach5 = Instance.new("Attachment")
            attach5.Name = "B"
            attach5.CFrame = CFrame.new(0.004150, 6.004150, 0.000000, 0.000000, 1.000000, -0.000000, -1.000000, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            attach5.Axis = Vector3.new(0.000000, -1.000000, 0.000000)
            attach5.SecondaryAxis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach5.Parent = root
            
            -- ParticleEmitter: Explosion 2
            local emitter7 = Instance.new("ParticleEmitter")
            emitter7.Name = "Explosion 2"
            emitter7.Texture = "rbxassetid://13370283312"
            emitter7.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 1.000000, 0.878431)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 1.000000, 0.878431))
            })
            emitter7.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 10.000000, 0.000000)
            })
            emitter7.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.510000, 0.350000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter7.Lifetime = NumberRange.new(0.500000)
            emitter7.Rate = 7.500000
            emitter7.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter7.RotSpeed = NumberRange.new(-100.000000, 100.000000)
            emitter7.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter7.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid2x2
            emitter7.FlipbookFramerate = NumberRange.new(5.000000)
            emitter7.LockedToPart = true
            emitter7.LightEmission = 1.000000
            emitter7.Shape = Enum.ParticleEmitterShape.Box
            emitter7.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter7.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter7.ShapePartial = 1.000000
            emitter7.Speed = NumberRange.new(0.001000)
            emitter7.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter7.EmissionDirection = Enum.NormalId.Left
            emitter7.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter7.VelocitySpread = 0.000000
            emitter7.Parent = attach5
            
            -- ParticleEmitter: Explosion 1
            local emitter8 = Instance.new("ParticleEmitter")
            emitter8.Name = "Explosion 1"
            emitter8.Texture = "rbxassetid://13370283312"
            emitter8.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.266667, 0.619608, 0.513726)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.266667, 0.619608, 0.513726))
            })
            emitter8.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 10.000000, 0.000000)
            })
            emitter8.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.510000, 0.350000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter8.Lifetime = NumberRange.new(0.500000)
            emitter8.Rate = 7.500000
            emitter8.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter8.RotSpeed = NumberRange.new(-100.000000, 100.000000)
            emitter8.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter8.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid2x2
            emitter8.FlipbookFramerate = NumberRange.new(5.000000)
            emitter8.LockedToPart = true
            emitter8.LightEmission = 1.000000
            emitter8.Shape = Enum.ParticleEmitterShape.Box
            emitter8.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter8.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter8.ShapePartial = 1.000000
            emitter8.Speed = NumberRange.new(0.001000)
            emitter8.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter8.EmissionDirection = Enum.NormalId.Left
            emitter8.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter8.VelocitySpread = 0.000000
            emitter8.Parent = attach5

            table.insert(createdInstances, attach5)

            return createdInstances
        end
    },

    ["Wings"] = {
        Name = "Wings",
        Description = "Angel wings",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}

            -- Main attachment on torso/back
            local mainAttach = Instance.new("Attachment")
            mainAttach.Name = "WingsMainAttach"
            mainAttach.CFrame = CFrame.new(0, 0.75, 1)
            mainAttach.Parent = root

            -- Left wing attachment
            local leftAttach = Instance.new("Attachment")
            leftAttach.Name = "LeftWingAttach"
            leftAttach.CFrame = CFrame.new(-2, 1, 0.5)
            leftAttach.Parent = root

            -- Right wing attachment
            local rightAttach = Instance.new("Attachment")
            rightAttach.Name = "RightWingAttach"
            rightAttach.CFrame = CFrame.new(2, 1, 0.5)
            rightAttach.Parent = root

            -- Left Wing Beam
            local leftBeam = Instance.new("Beam")
            leftBeam.Name = "LeftWing"
            leftBeam.Texture = "rbxassetid://9544400688"
            leftBeam.Color = ColorSequence.new(Color3.new(1, 1, 1))
            leftBeam.Transparency = NumberSequence.new(0)
            leftBeam.TextureSpeed = 0
            leftBeam.Width0 = 4
            leftBeam.Width1 = 6
            leftBeam.CurveSize0 = -4
            leftBeam.CurveSize1 = 2
            leftBeam.LightEmission = 1
            leftBeam.LightInfluence = 1
            leftBeam.Attachment0 = mainAttach
            leftBeam.Attachment1 = leftAttach
            leftBeam.Parent = root

            -- Right Wing Beam
            local rightBeam = Instance.new("Beam")
            rightBeam.Name = "RightWing"
            rightBeam.Texture = "rbxassetid://9544400688"
            rightBeam.Color = ColorSequence.new(Color3.new(1, 1, 1))
            rightBeam.Transparency = NumberSequence.new(0)
            rightBeam.TextureSpeed = 0
            rightBeam.Width0 = 4
            rightBeam.Width1 = 6
            rightBeam.CurveSize0 = 4
            rightBeam.CurveSize1 = -2
            rightBeam.LightEmission = 1
            rightBeam.LightInfluence = 1
            rightBeam.Attachment0 = mainAttach
            rightBeam.Attachment1 = rightAttach
            rightBeam.Parent = root

            table.insert(createdInstances, mainAttach)
            table.insert(createdInstances, leftAttach)
            table.insert(createdInstances, rightAttach)
            table.insert(createdInstances, leftBeam)
            table.insert(createdInstances, rightBeam)

            return createdInstances
        end
    },

    ["Aura2"] = {
        Name = "Aura2",
        Description = "Aura2",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            
            local attach = Instance.new("Attachment")
            attach.Name = "Attachment"
            attach.CFrame = CFrame.new(0.000000, 0.250006, 1.000000, 1.000000, 0.000000, -0.000000, 0.000000, 0.000000, 1.000000, 0.000000, -1.000000, 0.000000)
            attach.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            attach.SecondaryAxis = Vector3.new(0.000000, 0.000000, -1.000000)
            attach.Parent = root
            
            -- ParticleEmitter 1
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "ParticleEmitter"
            emitter1.Texture = "rbxassetid://11974968572"
            emitter1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 0.647059, 0.780392)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 0.647059, 0.780392))
            })
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 3.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 3.000000, 0.000000)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.500000, 0.500000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter1.Lifetime = NumberRange.new(1.500000)
            emitter1.Rate = 1.500000
            emitter1.Rotation = NumberRange.new(0.000000)
            emitter1.RotSpeed = NumberRange.new(0.000000)
            emitter1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter1.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter1.FlipbookFramerate = NumberRange.new(1.000000)
            emitter1.LockedToPart = true
            emitter1.LightEmission = 1.000000
            emitter1.Shape = Enum.ParticleEmitterShape.Box
            emitter1.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter1.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter1.ShapePartial = 1.000000
            emitter1.Speed = NumberRange.new(0.001000)
            emitter1.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter1.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter1.VelocitySpread = 0.000000
            emitter1.Parent = attach
            
            -- ParticleEmitter 2
            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Name = "ParticleEmitter"
            emitter2.Texture = "rbxassetid://11975024774"
            emitter2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000000, Color3.new(0.431373, 0.647059, 0.780392)),
                ColorSequenceKeypoint.new(1.000000, Color3.new(0.431373, 0.647059, 0.780392))
            })
            emitter2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 4.000000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 4.000000, 0.000000)
            })
            emitter2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
                NumberSequenceKeypoint.new(0.500000, 0.900000, 0.000000),
                NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            })
            emitter2.Lifetime = NumberRange.new(1.500000)
            emitter2.Rate = 3.000000
            emitter2.Rotation = NumberRange.new(-360.000000, 360.000000)
            emitter2.RotSpeed = NumberRange.new(-100.000000, 100.000000)
            emitter2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter2.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            emitter2.FlipbookFramerate = NumberRange.new(1.000000)
            emitter2.LockedToPart = true
            emitter2.LightEmission = 1.000000
            emitter2.Shape = Enum.ParticleEmitterShape.Box
            emitter2.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            emitter2.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            emitter2.ShapePartial = 1.000000
            emitter2.Speed = NumberRange.new(0.001000)
            emitter2.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            emitter2.SpreadAngle = Vector2.new(0.000000, 0.000000)
            emitter2.VelocitySpread = 0.000000
            emitter2.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },

    ["Aura"] = {
        Name = "Aura",
        Description = "Nice Aura",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            local attach = Instance.new("Attachment")
            attach.Name = "Attachment"
            attach.CFrame = CFrame.new(0, 0, 0)
            attach.Parent = root

            -- ParticleEmitter 1: Chromatic Water Fog
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "Chromatic Water Fog"
            emitter1.Texture = "rbxassetid://104888060261813"
            emitter1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.407843, 0.227451, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.407843, 0.227451, 1))
            })
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.091487, 1.834641, 0),
                NumberSequenceKeypoint.new(0.235070, 3.598719, 0),
                NumberSequenceKeypoint.new(1, 5.786176, 0)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.029605, 0.382514, 0),
                NumberSequenceKeypoint.new(0.119518, 0.147541, 0),
                NumberSequenceKeypoint.new(0.484649, 0, 0),
                NumberSequenceKeypoint.new(0.770833, 0.251366, 0),
                NumberSequenceKeypoint.new(0.906798, 0.573771, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter1.Lifetime = NumberRange.new(0.1, 0.5)
            emitter1.Rate = 10
            emitter1.Speed = NumberRange.new(12.441599)
            emitter1.Acceleration = Vector3.new(0, 0, 0)
            emitter1.Drag = 0
            emitter1.VelocityInheritance = 0
            emitter1.EmissionDirection = Enum.NormalId.Top
            emitter1.SpreadAngle = Vector2.new(0, 0)
            emitter1.Rotation = NumberRange.new(-180, 180)
            emitter1.RotSpeed = NumberRange.new(0)
            emitter1.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter1.LightEmission = 1
            emitter1.LightInfluence = 0
            emitter1.Brightness = 1
            emitter1.ZOffset = -0.7
            emitter1.Enabled = true
            emitter1.TimeScale = 1
            emitter1.Parent = attach

            -- ParticleEmitter 2
            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Name = "ParticleEmitter"
            emitter2.Texture = "rbxassetid://17006172452"
            emitter2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.431373, 0.290196, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.431373, 0.290196, 1))
            })
            emitter2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.068664, 2.901510, 0),
                NumberSequenceKeypoint.new(1, 5.319438, 0)
            })
            emitter2.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0, 0, 0),
                ColorSequenceKeypoint.new(1, 0, 0)
            })
            emitter2.Lifetime = NumberRange.new(0.5, 1)
            emitter2.Rate = 5
            emitter2.Speed = NumberRange.new(0.073525)
            emitter2.Acceleration = Vector3.new(0, 0, 0)
            emitter2.Drag = 0
            emitter2.VelocityInheritance = 0
            emitter2.EmissionDirection = Enum.NormalId.Top
            emitter2.SpreadAngle = Vector2.new(0, 0)
            emitter2.Rotation = NumberRange.new(-180, 180)
            emitter2.RotSpeed = NumberRange.new(0)
            emitter2.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter2.LightEmission = 0
            emitter2.LightInfluence = 0
            emitter2.Brightness = 5
            emitter2.ZOffset = 1
            emitter2.Enabled = true
            emitter2.TimeScale = 1
            emitter2.Parent = attach

            -- ParticleEmitter 3
            local emitter3 = Instance.new("ParticleEmitter")
            emitter3.Name = "ParticleEmitter"
            emitter3.Texture = "rbxassetid://124359042766194"
            emitter3.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.431373, 0.290196, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.431373, 0.290196, 1))
            })
            emitter3.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.068664, 5.803020, 0),
                NumberSequenceKeypoint.new(1, 10.638875, 0)
            })
            emitter3.Transparency = NumberSequence.new({
                ColorSequenceKeypoint.new(0, 0, 0),
                ColorSequenceKeypoint.new(1, 0, 0)
            })
            emitter3.Lifetime = NumberRange.new(0.5, 1)
            emitter3.Rate = 5
            emitter3.Speed = NumberRange.new(0.147050)
            emitter3.Acceleration = Vector3.new(0, 0, 0)
            emitter3.Drag = 0
            emitter3.VelocityInheritance = 0
            emitter3.EmissionDirection = Enum.NormalId.Top
            emitter3.SpreadAngle = Vector2.new(0, 0)
            emitter3.Rotation = NumberRange.new(0)
            emitter3.RotSpeed = NumberRange.new(0)
            emitter3.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter3.LightEmission = 0
            emitter3.LightInfluence = 0
            emitter3.Brightness = 5
            emitter3.ZOffset = 1
            emitter3.Enabled = true
            emitter3.TimeScale = 1
            emitter3.Parent = attach

            -- ParticleEmitter 4
            local emitter4 = Instance.new("ParticleEmitter")
            emitter4.Name = "ParticleEmitter"
            emitter4.Texture = "rbxassetid://13145063652"
            emitter4.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            })
            emitter4.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.047808, 0),
                NumberSequenceKeypoint.new(1, 5.402326, 0.677608)
            })
            emitter4.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.063591, 0.212500, 0),
                NumberSequenceKeypoint.new(0.500732, 0, 0),
                NumberSequenceKeypoint.new(0.962594, 0.668750, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter4.Lifetime = NumberRange.new(0.5, 1)
            emitter4.Rate = 15
            emitter4.Speed = NumberRange.new(10.367999)
            emitter4.Acceleration = Vector3.new(0, 0, 0)
            emitter4.Drag = 0
            emitter4.VelocityInheritance = 0
            emitter4.EmissionDirection = Enum.NormalId.Top
            emitter4.SpreadAngle = Vector2.new(0, 0)
            emitter4.Rotation = NumberRange.new(-360, 360)
            emitter4.RotSpeed = NumberRange.new(0)
            emitter4.Orientation = Enum.ParticleOrientation.VelocityParallel
            emitter4.LightEmission = 0
            emitter4.LightInfluence = 0
            emitter4.Brightness = 25
            emitter4.ZOffset = -1
            emitter4.Enabled = true
            emitter4.TimeScale = 1
            emitter4.Parent = attach

            -- ParticleEmitter 5
            local emitter5 = Instance.new("ParticleEmitter")
            emitter5.Name = "ParticleEmitter"
            emitter5.Texture = "rbxassetid://15333825012"
            emitter5.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0.407843, 0.227451, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.407843, 0.227451, 1))
            })
            emitter5.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.091487, 1.834641, 0),
                NumberSequenceKeypoint.new(0.235070, 3.598719, 0),
                NumberSequenceKeypoint.new(1, 5.786176, 0)
            })
            emitter5.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.029605, 0.382514, 0),
                NumberSequenceKeypoint.new(0.119518, 0.147541, 0),
                NumberSequenceKeypoint.new(0.484649, 0, 0),
                NumberSequenceKeypoint.new(0.770833, 0.251366, 0),
                NumberSequenceKeypoint.new(0.906798, 0.573771, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter5.Lifetime = NumberRange.new(0.1, 0.5)
            emitter5.Rate = 10
            emitter5.Speed = NumberRange.new(12.441599)
            emitter5.Acceleration = Vector3.new(0, 0, 0)
            emitter5.Drag = 0
            emitter5.VelocityInheritance = 0
            emitter5.EmissionDirection = Enum.NormalId.Top
            emitter5.SpreadAngle = Vector2.new(0, 0)
            emitter5.Rotation = NumberRange.new(-180, 180)
            emitter5.RotSpeed = NumberRange.new(0)
            emitter5.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter5.LightEmission = 0
            emitter5.LightInfluence = 0
            emitter5.Brightness = 60
            emitter5.ZOffset = -0.7
            emitter5.Enabled = true
            emitter5.TimeScale = 1
            emitter5.Parent = attach

            -- ParticleEmitter 6
            local emitter6 = Instance.new("ParticleEmitter")
            emitter6.Name = "ParticleEmitter"
            emitter6.Texture = "rbxassetid://13013256540"
            emitter6.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            })
            emitter6.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.091487, 2.751962, 0),
                NumberSequenceKeypoint.new(0.235070, 5.398077, 0),
                NumberSequenceKeypoint.new(1, 8.679261, 0)
            })
            emitter6.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.029605, 0.382514, 0),
                NumberSequenceKeypoint.new(0.119518, 0.147541, 0),
                NumberSequenceKeypoint.new(0.484649, 0, 0),
                NumberSequenceKeypoint.new(0.770833, 0.251366, 0),
                NumberSequenceKeypoint.new(0.906798, 0.573771, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter6.Lifetime = NumberRange.new(0.1, 0.8)
            emitter6.Rate = 10
            emitter6.Speed = NumberRange.new(10.367999)
            emitter6.Acceleration = Vector3.new(0, 0, 0)
            emitter6.Drag = 0
            emitter6.VelocityInheritance = 0
            emitter6.EmissionDirection = Enum.NormalId.Top
            emitter6.SpreadAngle = Vector2.new(0, 0)
            emitter6.Rotation = NumberRange.new(-180, 180)
            emitter6.RotSpeed = NumberRange.new(0)
            emitter6.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter6.LightEmission = 0
            emitter6.LightInfluence = 0
            emitter6.Brightness = 5
            emitter6.ZOffset = -1
            emitter6.Enabled = true
            emitter6.TimeScale = 1
            emitter6.Parent = attach

            -- ParticleEmitter 7
            local emitter7 = Instance.new("ParticleEmitter")
            emitter7.Name = "ParticleEmitter"
            emitter7.Texture = "rbxassetid://11163763158"
            emitter7.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            })
            emitter7.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1.312189, 0),
                NumberSequenceKeypoint.new(1, 2.384176, 0.564673)
            })
            emitter7.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.063591, 0.212500, 0),
                NumberSequenceKeypoint.new(0.500732, 0, 0),
                NumberSequenceKeypoint.new(0.962594, 0.668750, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter7.Lifetime = NumberRange.new(0.5, 1)
            emitter7.Rate = 15
            emitter7.Speed = NumberRange.new(10.367999)
            emitter7.Acceleration = Vector3.new(0, 0, 0)
            emitter7.Drag = 0
            emitter7.VelocityInheritance = 0
            emitter7.EmissionDirection = Enum.NormalId.Top
            emitter7.SpreadAngle = Vector2.new(0, 0)
            emitter7.Rotation = NumberRange.new(-360, 360)
            emitter7.RotSpeed = NumberRange.new(0)
            emitter7.Orientation = Enum.ParticleOrientation.VelocityParallel
            emitter7.LightEmission = 0
            emitter7.LightInfluence = 0
            emitter7.Brightness = 10
            emitter7.ZOffset = -1
            emitter7.Enabled = true
            emitter7.TimeScale = 1
            emitter7.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },

        ["Energy"] = {
        Name = "Energy",
        Description = "Energy",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}

            	-- Attachment: Attachment (Path: Workspace → Model → Pack3 → aura → HumanoidRootPart → Attachment)
            	do
            		local attach = Instance.new("Attachment")
            		attach.Name = "Attachment"
            		attach.CFrame = CFrame.new(0.000000, -2.340648, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            		attach.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            		attach.SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000)
            		attach.Parent = root
            		-- ParticleEmitter: Energy Flare2
            		local emitter = Instance.new("ParticleEmitter")
            		emitter.Name = "Energy Flare2"
            		-- Core
            		emitter.Texture = "rbxassetid://8047533775"
            		emitter.Color = ColorSequence.new({
            		ColorSequenceKeypoint.new(0.000000, Color3.new(1.000000, 0.278431, 0.278431)),
            		ColorSequenceKeypoint.new(1.000000, Color3.new(1.000000, 0.278431, 0.278431))
            	})
            		emitter.Size = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 2.000000, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 0.000000, 0.000000)
            	})
            		emitter.Transparency = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.400000, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.452632, 0.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.607368, 0.000000, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            	})
            		emitter.Lifetime = NumberRange.new(0.400000, 0.500000)
            		-- Rotation
            		emitter.Rotation = NumberRange.new(180.000000)
            		emitter.RotSpeed = NumberRange.new(0.000000)
            		emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
            		-- Flipbook
            		emitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            		emitter.FlipbookFramerate = NumberRange.new(1.000000)
            		-- Behavior
            		emitter.LockedToPart = true
            		-- Visual
            		emitter.LightInfluence = 0.000000
            		emitter.Brightness = 6.000000
            		emitter.ZOffset = -0.100000
            		-- Shape
            		emitter.Shape = Enum.ParticleEmitterShape.Box
            		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            		emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            		emitter.ShapePartial = 1.000000
            		-- Motion
            		emitter.Speed = NumberRange.new(10.000000, 15.000000)
            		emitter.Acceleration = Vector3.new(0.000000, 70.000000, 0.000000)
            		emitter.Drag = 1.000000
            		emitter.EmissionDirection = Enum.NormalId.Left
            		emitter.SpreadAngle = Vector2.new(0.000000, 180.000000)
            		emitter.VelocitySpread = 0.000000
            		emitter.Parent = attach
            		-- ParticleEmitter: Energy Flare
            		local emitter = Instance.new("ParticleEmitter")
            		emitter.Name = "Energy Flare"
            		-- Core
            		emitter.Texture = "rbxassetid://10435576555"
            		emitter.Color = ColorSequence.new({
            		ColorSequenceKeypoint.new(0.000000, Color3.new(1.000000, 0.278431, 0.278431)),
            		ColorSequenceKeypoint.new(1.000000, Color3.new(1.000000, 0.278431, 0.278431))
            	})
            		emitter.Size = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 2.000000, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 0.375000, 0.000000)
            	})
            		emitter.Transparency = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.123158, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.265263, 0.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.571579, 0.000000, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            	})
            		emitter.Lifetime = NumberRange.new(0.400000, 0.500000)
            		emitter.Rate = 45.000000
            		-- Rotation
            		emitter.Rotation = NumberRange.new(180.000000)
            		emitter.RotSpeed = NumberRange.new(0.000000)
            		emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
            		-- Flipbook
            		emitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            		emitter.FlipbookFramerate = NumberRange.new(1.000000)
            		-- Behavior
            		emitter.LockedToPart = true
            		-- Visual
            		emitter.LightInfluence = 0.000000
            		emitter.Brightness = 4.000000
            		-- Shape
            		emitter.Shape = Enum.ParticleEmitterShape.Box
            		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            		emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            		emitter.ShapePartial = 1.000000
            		-- Motion
            		emitter.Speed = NumberRange.new(5.000000, 10.000000)
            		emitter.Acceleration = Vector3.new(0.000000, 100.000000, 0.000000)
            		emitter.Drag = 1.000000
            		emitter.EmissionDirection = Enum.NormalId.Left
            		emitter.SpreadAngle = Vector2.new(0.000000, 180.000000)
            		emitter.VelocitySpread = 0.000000
            		emitter.Parent = attach
            	end

            table.insert(createdInstances, attach)

            	-- Attachment: Attachment (Path: Workspace → Model → Pack3 → aura → Torso → Attachment)
            	do
            		local attach = Instance.new("Attachment")
            		attach.Name = "Attachment"
            		attach.CFrame = CFrame.new(0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000)
            		attach.Axis = Vector3.new(1.000000, 0.000000, 0.000000)
            		attach.SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000)
            		attach.Parent = root
            		-- ParticleEmitter: AwakeningL
            		local emitter = Instance.new("ParticleEmitter")
            		emitter.Name = "AwakeningL"
            		-- Core
            		emitter.Texture = "rbxassetid://7857596636"
            		emitter.Color = ColorSequence.new({
            		ColorSequenceKeypoint.new(0.000000, Color3.new(1.000000, 0.450980, 0.450980)),
            		ColorSequenceKeypoint.new(1.000000, Color3.new(1.000000, 0.450980, 0.450980))
            	})
            		emitter.Size = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 4.187500, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 5.500000, 0.000000)
            	})
            		emitter.Transparency = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.501071, 0.356250, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            	})
            		emitter.Lifetime = NumberRange.new(0.250000)
            		emitter.Rate = 12.000000
            		-- Rotation
            		emitter.Rotation = NumberRange.new(-5.000000, 5.000000)
            		emitter.RotSpeed = NumberRange.new(0.000000)
            		emitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
            		-- Flipbook
            		emitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            		emitter.FlipbookFramerate = NumberRange.new(1.000000)
            		-- Behavior
            		emitter.LockedToPart = true
            		-- Visual
            		emitter.LightEmission = 1.000000
            		emitter.LightInfluence = 0.000000
            		emitter.ZOffset = 1.000000
            		-- Shape
            		emitter.Shape = Enum.ParticleEmitterShape.Box
            		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            		emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            		emitter.ShapePartial = 1.000000
            		-- Motion
            		emitter.Speed = NumberRange.new(5.000000)
            		emitter.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            		emitter.SpreadAngle = Vector2.new(10.000000, 10.000000)
            		emitter.VelocitySpread = 10.000000
            		emitter.Parent = attach
            		-- ParticleEmitter: AwakeningD
            		local emitter = Instance.new("ParticleEmitter")
            		emitter.Name = "AwakeningD"
            		-- Core
            		emitter.Texture = "rbxassetid://7857596636"
            		emitter.Color = ColorSequence.new({
            		ColorSequenceKeypoint.new(0.000000, Color3.new(0.839216, 0.000000, 0.000000)),
            		ColorSequenceKeypoint.new(1.000000, Color3.new(0.839216, 0.000000, 0.000000))
            	})
            		emitter.Size = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 5.312500, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 5.375000, 0.000000)
            	})
            		emitter.Transparency = NumberSequence.new({
            		NumberSequenceKeypoint.new(0.000000, 1.000000, 0.000000),
            		NumberSequenceKeypoint.new(0.680942, 0.562500, 0.000000),
            		NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)
            	})
            		emitter.Lifetime = NumberRange.new(0.250000)
            		emitter.Rate = 12.000000
            		-- Rotation
            		emitter.Rotation = NumberRange.new(-5.000000, 5.000000)
            		emitter.RotSpeed = NumberRange.new(0.000000)
            		emitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
            		-- Flipbook
            		emitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            		emitter.FlipbookFramerate = NumberRange.new(1.000000)
            		-- Behavior
            		emitter.LockedToPart = true
            		-- Visual
            		emitter.LightInfluence = 0.000000
            		emitter.ZOffset = 0.800000
            		-- Shape
            		emitter.Shape = Enum.ParticleEmitterShape.Box
            		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            		emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
            		emitter.ShapePartial = 1.000000
            		-- Motion
            		emitter.Speed = NumberRange.new(6.000000)
            		emitter.Acceleration = Vector3.new(0.000000, 0.000000, 0.000000)
            		emitter.SpreadAngle = Vector2.new(10.000000, 10.000000)
            		emitter.VelocitySpread = 10.000000
            		emitter.Parent = attach
            	end

            table.insert(createdInstances, attach)

            return createdInstances
        end
    },

-- ✅ READY TO PASTE INTO VFX_REGISTRY.LUA!
-- Add this to the VFXRegistry.Effects table
-- Then add "NewEffect" to your dropdown in the script
}

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

function VFXRegistry:GetEffectNames()
    local names = {"None"}
    local effectNames = {}
    for name, _ in pairs(self.Effects) do
        table.insert(effectNames, name)
    end
    table.sort(effectNames)
    for _, name in ipairs(effectNames) do
        table.insert(names, name)
    end
    return names
end

function VFXRegistry:GetEffect(name)
    return self.Effects[name]
end

function VFXRegistry:ApplyEffect(name, root)
    local effect = self:GetEffect(name)
    if effect and effect.Apply then
        return effect.Apply(root)
    end
    return nil
end

return VFXRegistry
