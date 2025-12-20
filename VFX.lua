-- ═══════════════════════════════════════════════════════════
-- VFX REGISTRY - Host this on GitHub
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
            
            -- Attachment: Main
            local attach = Instance.new("Attachment")
            attach.Name = "PurpleFloorVFX"
            attach.CFrame = CFrame.new(0, -3, 0)
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
            attach.CFrame = CFrame.new(0, -3, 0)
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
            emitter1.LightEmission = 1
            emitter1.LightInfluence = 0
            emitter1.Brightness = 5
            emitter1.Enabled = true
            emitter1.Parent = attach

            table.insert(createdInstances, attach)
            return createdInstances
        end
    },
    
    -- Add more VFX here easily!
}

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

function VFXRegistry:GetEffectNames()
    local names = {"None"}
    for name, _ in pairs(self.Effects) do
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
