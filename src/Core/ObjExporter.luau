--[[
    HyperSaveInstance - Wavefront 3D OBJ & MTL Exporter
    Converts Roblox 3D workspace models and parts into .obj / .mtl for Blender, Unity and Unreal Engine.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)

local ObjExporter = {}

-- Generate standard cube vertices & faces for BasePart
local function getBoxGeometry(cf: CFrame, size: Vector3, vertOffset: number): (string, string, number)
    local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-hx, -hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(hx, -hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(hx, hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, -hy, hz)),
        cf:PointToWorldSpace(Vector3.new(hx, -hy, hz)),
        cf:PointToWorldSpace(Vector3.new(hx, hy, hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
    }

    local vLines = {}
    for _, pt in ipairs(corners) do
        table.insert(vLines, string.format("v %.4f %.4f %.4f", pt.X, pt.Y, pt.Z))
    end

    local o = vertOffset
    local fLines = {
        string.format("f %d %d %d", o + 1, o + 3, o + 2),
        string.format("f %d %d %d", o + 1, o + 4, o + 3),
        string.format("f %d %d %d", o + 5, o + 6, o + 7),
        string.format("f %d %d %d", o + 5, o + 7, o + 8),
        string.format("f %d %d %d", o + 1, o + 2, o + 6),
        string.format("f %d %d %d", o + 1, o + 6, o + 5),
        string.format("f %d %d %d", o + 4, o + 7, o + 3),
        string.format("f %d %d %d", o + 4, o + 8, o + 7),
        string.format("f %d %d %d", o + 2, o + 3, o + 7),
        string.format("f %d %d %d", o + 2, o + 7, o + 6),
        string.format("f %d %d %d", o + 1, o + 5, o + 8),
        string.format("f %d %d %d", o + 1, o + 8, o + 4),
    }

    return table.concat(vLines, "\n"), table.concat(fLines, "\n"), vertOffset + 8
end

-- Export entire workspace or model to .obj + .mtl
function ObjExporter.Export(targetRoot: Instance?, options: table?): (boolean, string)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objLines = {
        "# HyperSaveInstance - Wavefront 3D OBJ Export",
        "# Exported from Roblox Experience",
        "mtllib " .. baseName .. ".mtl",
        ""
    }

    local mtlLines = {
        "# HyperSaveInstance - Material Library (.mtl)",
        ""
    }

    local materialsSeen = {}
    local vertOffset = 0
    local partCount = 0

    local function processInstance(inst: Instance)
        if inst:IsA("BasePart") and not inst:IsA("Terrain") then
            local color = inst.Color
            local matName = string.format("mat_%d_%d_%d", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))

            if not materialsSeen[matName] then
                materialsSeen[matName] = true
                table.insert(mtlLines, string.format("newmtl %s", matName))
                table.insert(mtlLines, string.format("Kd %.4f %.4f %.4f", color.R, color.G, color.B))
                table.insert(mtlLines, string.format("d %.4f", 1 - inst.Transparency))
                table.insert(mtlLines, "")
            end

            table.insert(objLines, string.format("o %s_%d", string.gsub(inst.Name, "[^%w_]", "_"), partCount))
            table.insert(objLines, "usemtl " .. matName)

            local vStr, fStr, newOffset = getBoxGeometry(inst.CFrame, inst.Size, vertOffset)
            table.insert(objLines, vStr)
            table.insert(objLines, fStr)
            table.insert(objLines, "")

            vertOffset = newOffset
            partCount = partCount + 1
        end

        for _, child in ipairs(inst:GetChildren()) do
            processInstance(child)
        end
    end

    processInstance(root)

    -- Write files
    local objContent = table.concat(objLines, "\n")
    local mtlContent = table.concat(mtlLines, "\n")

    local objPath = baseName .. ".obj"
    local mtlPath = baseName .. ".mtl"

    Environment.WriteFile(objPath, objContent)
    Environment.WriteFile(mtlPath, mtlContent)

    return true, objPath
end

return ObjExporter
