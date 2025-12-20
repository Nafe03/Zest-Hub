-- ═══════════════════════════════════════════════════════════
-- VFX REGISTRY - FIXED VERSION
-- File: vfx_registry.lua
-- URL: https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/vfx_registry.lua
-- ═══════════════════════════════════════════════════════════

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
            
            local attach = Instance.new("Attachment")
            attach.Name = "PurpleFloorVFX"
            attach.CFrame = CFrame.new(0, -2.8, 0)
            attach.Parent = root

            -- Floor1
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Name = "Floor1"
            emitter1.Texture = "rbxassetid://16956569427"
            emitter1.Color = ColorSequence.new(Color3.new(0.819608, 0.454902, 1))
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
            emitter1.Brightness = 5
            emitter1.Enabled = true
            emitter1.Parent = attach

            -- Floor2
            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Name = "Floor2"
            emitter2.Texture = "rbxassetid://14591895021"
            emitter2.Color = ColorSequence.new(Color3.new(0.819608, 0.454902, 1))
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
            emitter2.EmissionDirection = Enum.NormalId.Top
            emitter2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter2.LightEmission = 1
            emitter2.Brightness = 5
            emitter2.Enabled = true
            emitter2.Parent = attach

            -- Floor3
            local emitter3 = Instance.new("ParticleEmitter")
            emitter3.Name = "Floor3"
            emitter3.Texture = "rbxassetid://16956497860"
            emitter3.Color = ColorSequence.new(Color3.new(0.819608, 0.454902, 1))
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
            emitter3.EmissionDirection = Enum.NormalId.Top
            emitter3.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter3.LightEmission = 1
            emitter3.Brightness = 5
            emitter3.Enabled = true
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
            emitter1.Color = ColorSequence.new(Color3.new(0.2, 0.6, 1))
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
            emitter1.Brightness = 5
            emitter1.Enabled = true
            emitter1.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },

    -- ✅ FIXED: Quake effect with proper structure
    ["Quake"] = {
        Name = "Quake",
        Description = "Quake effect with beams and particles",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}

            -- Attachment 1: Explosions
            local attach1 = Instance.new("Attachment")
            attach1.Name = "QuakeAttach1"
            attach1.CFrame = CFrame.new(-0.004150, 4.122253, 0.185486)
            attach1.Parent = root

            -- Explosion 2
            local exp2 = Instance.new("ParticleEmitter")
            exp2.Name = "Explosions 2"
            exp2.Texture = "rbxassetid://8214516794"
            exp2.Color = ColorSequence.new(Color3.new(0.431373, 1, 0.878431))
            exp2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(1, 11, 0)
            })
            exp2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.75, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            exp2.Lifetime = NumberRange.new(0.5)
            exp2.Rate = 6.25
            exp2.Speed = NumberRange.new(8)
            exp2.Acceleration = Vector3.new(0, 15, 0)
            exp2.Drag = 5
            exp2.Rotation = NumberRange.new(-100, -80)
            exp2.Orientation = Enum.ParticleOrientation.VelocityParallel
            exp2.LockedToPart = true
            exp2.LightEmission = 1
            exp2.ZOffset = -0.5
            exp2.Shape = Enum.ParticleEmitterShape.Box
            exp2.SpreadAngle = Vector2.new(360, 360)
            exp2.Parent = attach1

            -- Explosion 1
            local exp1 = Instance.new("ParticleEmitter")
            exp1.Name = "Explosions 1"
            exp1.Texture = "rbxassetid://8214516794"
            exp1.Color = ColorSequence.new(Color3.new(0.266667, 0.619608, 0.513726))
            exp1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(1, 11, 0)
            })
            exp1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.75, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            exp1.Lifetime = NumberRange.new(0.5)
            exp1.Rate = 6.25
            exp1.Speed = NumberRange.new(8)
            exp1.Acceleration = Vector3.new(0, 15, 0)
            exp1.Drag = 5
            exp1.Rotation = NumberRange.new(-100, -80)
            exp1.Orientation = Enum.ParticleOrientation.VelocityParallel
            exp1.LockedToPart = true
            exp1.LightEmission = 1
            exp1.ZOffset = -0.5
            exp1.Shape = Enum.ParticleEmitterShape.Box
            exp1.SpreadAngle = Vector2.new(360, 360)
            exp1.Parent = attach1

            table.insert(createdInstances, attach1)

            -- Attachment 2: Lightning
            local attach2 = Instance.new("Attachment")
            attach2.Name = "QuakeAttach2"
            attach2.CFrame = CFrame.new(0, -1.373575, 0)
            attach2.Parent = root

            -- Lightning 1
            local light1 = Instance.new("ParticleEmitter")
            light1.Name = "Lightning 1"
            light1.Texture = "rbxassetid://12072303767"
            light1.Color = ColorSequence.new(Color3.new(0.431373, 1, 0.878431))
            light1.Size = NumberSequence.new(6)
            light1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.05, 0, 0),
                NumberSequenceKeypoint.new(0.1, 1, 0),
                NumberSequenceKeypoint.new(0.15, 0, 0),
                NumberSequenceKeypoint.new(0.2, 1, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            light1.Lifetime = NumberRange.new(0.4)
            light1.Rate = 5
            light1.Speed = NumberRange.new(20)
            light1.Acceleration = Vector3.new(0, 15, 0)
            light1.Rotation = NumberRange.new(-360, 360)
            light1.RotSpeed = NumberRange.new(-100, 100)
            light1.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            light1.FlipbookFramerate = NumberRange.new(25)
            light1.LockedToPart = true
            light1.LightEmission = 1
            light1.ZOffset = -1
            light1.Shape = Enum.ParticleEmitterShape.Box
            light1.SpreadAngle = Vector2.new(360, 360)
            light1.Parent = attach2

            -- Lightning 2
            local light2 = Instance.new("ParticleEmitter")
            light2.Name = "Lightning 2"
            light2.Texture = "rbxassetid://12072303767"
            light2.Color = ColorSequence.new(Color3.new(0.266667, 0.619608, 0.513726))
            light2.Size = NumberSequence.new(6)
            light2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.05, 0, 0),
                NumberSequenceKeypoint.new(0.1, 1, 0),
                NumberSequenceKeypoint.new(0.15, 0, 0),
                NumberSequenceKeypoint.new(0.2, 1, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            light2.Lifetime = NumberRange.new(0.4)
            light2.Rate = 5
            light2.Speed = NumberRange.new(20)
            light2.Acceleration = Vector3.new(0, 15, 0)
            light2.Rotation = NumberRange.new(-360, 360)
            light2.RotSpeed = NumberRange.new(-100, 100)
            light2.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            light2.FlipbookFramerate = NumberRange.new(25)
            light2.LockedToPart = true
            light2.Brightness = 3
            light2.ZOffset = -1
            light2.Shape = Enum.ParticleEmitterShape.Box
            light2.SpreadAngle = Vector2.new(360, 360)
            light2.Parent = attach2

            table.insert(createdInstances, attach2)

            -- Attachment 3: Ground Quake
            local attach3 = Instance.new("Attachment")
            attach3.Name = "QuakeAttach3"
            attach3.CFrame = CFrame.new(-0.003998, -2.878001, 0.185120)
            attach3.Parent = root

            -- Quake 2
            local quake2 = Instance.new("ParticleEmitter")
            quake2.Name = "Quake 2"
            quake2.Texture = "rbxassetid://13516765561"
            quake2.Color = ColorSequence.new(Color3.new(0.431373, 1, 0.878431))
            quake2.Size = NumberSequence.new(10)
            quake2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.55, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            quake2.Lifetime = NumberRange.new(1.5)
            quake2.Rate = 1
            quake2.Speed = NumberRange.new(0.001)
            quake2.Rotation = NumberRange.new(-360, 360)
            quake2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            quake2.LockedToPart = true
            quake2.LightEmission = 1
            quake2.ZOffset = 0.25
            quake2.Shape = Enum.ParticleEmitterShape.Box
            quake2.Parent = attach3

            -- Quake 1
            local quake1 = Instance.new("ParticleEmitter")
            quake1.Name = "Quake 1"
            quake1.Texture = "rbxassetid://12102242479"
            quake1.Color = ColorSequence.new(Color3.new(0.266667, 0.619608, 0.513726))
            quake1.Size = NumberSequence.new(10)
            quake1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.55, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            quake1.Lifetime = NumberRange.new(1.5)
            quake1.Rate = 1
            quake1.Speed = NumberRange.new(0.001)
            quake1.Rotation = NumberRange.new(-360, 360)
            quake1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            quake1.LockedToPart = true
            quake1.Brightness = 3
            quake1.Shape = Enum.ParticleEmitterShape.Box
            quake1.Parent = attach3

            table.insert(createdInstances, attach3)

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

            local mainAttach = Instance.new("Attachment")
            mainAttach.Name = "WingsMainAttach"
            mainAttach.CFrame = CFrame.new(0, 0.75, 1)
            mainAttach.Parent = root

            local leftAttach = Instance.new("Attachment")
            leftAttach.Name = "LeftWingAttach"
            leftAttach.CFrame = CFrame.new(-2, 1, 0.5)
            leftAttach.Parent = root

            local rightAttach = Instance.new("Attachment")
            rightAttach.Name = "RightWingAttach"
            rightAttach.CFrame = CFrame.new(2, 1, 0.5)
            rightAttach.Parent = root

            local leftBeam = Instance.new("Beam")
            leftBeam.Name = "LeftWing"
            leftBeam.Texture = "rbxassetid://9544400688"
            leftBeam.Color = ColorSequence.new(Color3.new(1, 1, 1))
            leftBeam.Transparency = NumberSequence.new(0)
            leftBeam.Width0 = 4
            leftBeam.Width1 = 6
            leftBeam.CurveSize0 = -4
            leftBeam.CurveSize1 = 2
            leftBeam.LightEmission = 1
            leftBeam.Attachment0 = mainAttach
            leftBeam.Attachment1 = leftAttach
            leftBeam.Parent = root

            local rightBeam = Instance.new("Beam")
            rightBeam.Name = "RightWing"
            rightBeam.Texture = "rbxassetid://9544400688"
            rightBeam.Color = ColorSequence.new(Color3.new(1, 1, 1))
            rightBeam.Transparency = NumberSequence.new(0)
            rightBeam.Width0 = 4
            rightBeam.Width1 = 6
            rightBeam.CurveSize0 = 4
            rightBeam.CurveSize1 = -2
            rightBeam.LightEmission = 1
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
        Description = "Blue aura effect",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            
            local attach = Instance.new("Attachment")
            attach.Name = "Aura2Attach"
            attach.CFrame = CFrame.new(0, 0.25, 1)
            attach.Parent = root

            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Texture = "rbxassetid://11974968572"
            emitter1.Color = ColorSequence.new(Color3.new(0.431373, 0.647059, 0.780392))
            emitter1.Size = NumberSequence.new(3)
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.5, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter1.Lifetime = NumberRange.new(1.5)
            emitter1.Rate = 1.5
            emitter1.Speed = NumberRange.new(0.001)
            emitter1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter1.LockedToPart = true
            emitter1.LightEmission = 1
            emitter1.Shape = Enum.ParticleEmitterShape.Box
            emitter1.Parent = attach

            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Texture = "rbxassetid://11975024774"
            emitter2.Color = ColorSequence.new(Color3.new(0.431373, 0.647059, 0.780392))
            emitter2.Size = NumberSequence.new(4)
            emitter2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.5, 0.9, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter2.Lifetime = NumberRange.new(1.5)
            emitter2.Rate = 3
            emitter2.Speed = NumberRange.new(0.001)
            emitter2.Rotation = NumberRange.new(-360, 360)
            emitter2.RotSpeed = NumberRange.new(-100, 100)
            emitter2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
            emitter2.LockedToPart = true
            emitter2.LightEmission = 1
            emitter2.Shape = Enum.ParticleEmitterShape.Box
            emitter2.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },

    ["Aura"] = {
        Name = "Aura",
        Description = "Purple aura effect",
        Author = "ZestHub",
        Version = "1.0",
        Apply = function(root)
            local createdInstances = {}
            
            local attach = Instance.new("Attachment")
            attach.Name = "AuraAttach"
            attach.CFrame = CFrame.new(0, 0, 0)
            attach.Parent = root

            -- Main aura particles
            local emitter1 = Instance.new("ParticleEmitter")
            emitter1.Texture = "rbxassetid://104888060261813"
            emitter1.Color = ColorSequence.new(Color3.new(0.407843, 0.227451, 1))
            emitter1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.09, 1.83, 0),
                NumberSequenceKeypoint.new(0.24, 3.6, 0),
                NumberSequenceKeypoint.new(1, 5.79, 0)
            })
            emitter1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.03, 0.38, 0),
                NumberSequenceKeypoint.new(0.12, 0.15, 0),
                NumberSequenceKeypoint.new(0.48, 0, 0),
                NumberSequenceKeypoint.new(0.77, 0.25, 0),
                NumberSequenceKeypoint.new(0.91, 0.57, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter1.Lifetime = NumberRange.new(0.1, 0.5)
            emitter1.Rate = 10
            emitter1.Speed = NumberRange.new(12.44)
            emitter1.Rotation = NumberRange.new(-180, 180)
            emitter1.Orientation = Enum.ParticleOrientation.FacingCamera
            emitter1.LightEmission = 1
            emitter1.Brightness = 1
            emitter1.ZOffset = -0.7
            emitter1.Enabled = true
            emitter1.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },
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
