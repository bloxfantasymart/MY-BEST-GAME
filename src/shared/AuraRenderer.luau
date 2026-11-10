--!strict
-- Local-only attachments; no gameplay objects or inventory changes.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))
local AuraRenderer={}
function AuraRenderer.create(root,tier,reduced)
 local style=AuraStyle.get(tier)
 if not style then return nil end
 local color=Color3.fromRGB(style.rgb[1],style.rgb[2],style.rgb[3])
 local bottom=Instance.new("Attachment"); bottom.Name="LocalAuraBottom"; bottom.Position=Vector3.new(0,-2.5,0); bottom.Parent=root
 local top=Instance.new("Attachment"); top.Name="LocalAuraTop"; top.Position=Vector3.new(0,3,0); top.Parent=root
 local beam=Instance.new("Beam"); beam.Name="LocalAuraBeam"; beam.Attachment0=bottom; beam.Attachment1=top
 beam.Color=ColorSequence.new(color); beam.Transparency=NumberSequence.new(0.55); beam.Width0=1.1; beam.Width1=0.15
 beam.FaceCamera=true; beam.LightEmission=0.7; beam.Parent=root
 local light=Instance.new("PointLight"); light.Name="LocalAuraLight"; light.Color=color; light.Brightness=style.brightness
 light.Range=style.range; light.Shadows=false; light.Parent=root
 local sparkle=Instance.new("Sparkles"); sparkle.Name="LocalAuraSparkles"; sparkle.SparkleColor=color; sparkle.Enabled=not reduced; sparkle.Parent=root
 return {root=root,tier=tier,sparkle=sparkle,instances={beam,light,sparkle,bottom,top}}
end
function AuraRenderer.setReduced(record,reduced)
 if record.sparkle.Parent then record.sparkle.Enabled=not reduced end
end
function AuraRenderer.destroy(record)
 for _,instance in ipairs(record.instances) do instance:Destroy() end
end
return AuraRenderer
