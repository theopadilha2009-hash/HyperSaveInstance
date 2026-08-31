--[[
    HyperSaveInstance - Wavefront 3D OBJ & MTL Exporter
    Converts Roblox 3D workspace models and parts into .obj / .mtl for Blender, Unity and Unreal Engine.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)

local ObjExporter = {}

-- Generate standard cube vertices & faces for BasePart
local function getBoxGeometry(cf: any, size: any, vertOffset: number): (string, string, number)
    local hx = ((size and tonumber(size.X)) or 2) / 2
    local hy = ((size and tonumber(size.Y)) or 2) / 2
    local hz = ((size and tonumber(size.Z)) or 2) / 2

    local corners = {}
    if cf and type(cf.PointToWorldSpace) == "function" then
        local s, c = pcall(function()
            return {
                cf:PointToWorldSpace(Vector3.new(-hx, -hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(hx, -hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(hx, hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, -hy, hz)),
                cf:PointToWorldSpace(Vector3.new(hx, -hy, hz)),
                cf:PointToWorldSpace(Vector3.new(hx, hy, hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
            }
        end)
        if s and c then corners = c end
    end

    if #corners == 0 then
        local px = (cf and cf.Position and tonumber(cf.Position.X)) or (cf and tonumber(cf.X)) or 0
        local py = (cf and cf.Position and tonumber(cf.Position.Y)) or (cf and tonumber(cf.Y)) or 0
        local pz = (cf and cf.Position and tonumber(cf.Position.Z)) or (cf and tonumber(cf.Z)) or 0
        corners = {
            Vector3.new(px - hx, py - hy, pz - hz),
            Vector3.new(px + hx, py - hy, pz - hz),
            Vector3.new(px + hx, py + hy, pz - hz),
            Vector3.new(px - hx, py + hy, pz - hz),
            Vector3.new(px - hx, py - hy, pz + hz),
            Vector3.new(px + hx, py - hy, pz + hz),
            Vector3.new(px + hx, py + hy, pz + hz),
            Vector3.new(px - hx, py + hy, pz + hz),
        }
    end

    local vLines = {}
    for _, pt in ipairs(corners) do
        local vx = (pt and tonumber(pt.X)) or 0
        local vy = (pt and tonumber(pt.Y)) or 0
        local vz = (pt and tonumber(pt.Z)) or 0
        table.insert(vLines, string.format("v %.4f %.4f %.4f", vx, vy, vz))
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

-- Generate raw OBJ and MTL string representations in-memory
function ObjExporter.GenerateObj(targetRoot: Instance?, options: table?): (string, string)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objLines = {
        "# HyperSaveInstance - Wavefront 3D OBJ Export",
        "# Exported by Theo Lorentz Padilha",
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
            local color = inst.Color or Color3.fromRGB(168, 85, 247)
            local cr = math.floor(((color and tonumber(color.R)) or 0.5) * 255)
            local cg = math.floor(((color and tonumber(color.G)) or 0.5) * 255)
            local cb = math.floor(((color and tonumber(color.B)) or 0.5) * 255)
            local matName = string.format("mat_%d_%d_%d", cr, cg, cb)

            if not materialsSeen[matName] then
                materialsSeen[matName] = true
                local r = (color and tonumber(color.R)) or 0.5
                local g = (color and tonumber(color.G)) or 0.5
                local b = (color and tonumber(color.B)) or 0.5
                local trans = tonumber(inst.Transparency) or 0
                table.insert(mtlLines, string.format("newmtl %s", matName))
                table.insert(mtlLines, string.format("Kd %.4f %.4f %.4f", r, g, b))
                table.insert(mtlLines, string.format("d %.4f", 1 - trans))
                table.insert(mtlLines, "")
            end

            table.insert(objLines, string.format("o %s_%d", string.gsub(inst.Name or "Part", "[^%w_]", "_"), partCount))
            table.insert(objLines, "usemtl " .. matName)

            local cf = inst.CFrame or CFrame.new()
            local sz = inst.Size or Vector3.new(2, 2, 2)
            local vStr, fStr, newOffset = getBoxGeometry(cf, sz, vertOffset)
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

    return table.concat(objLines, "\n"), table.concat(mtlLines, "\n")
end

-- Export entire workspace or model to .obj + .mtl files
function ObjExporter.Export(targetRoot: Instance?, options: table?): (boolean, string)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objContent, mtlContent = ObjExporter.GenerateObj(root, options)
    local objPath = baseName .. ".obj"
    local mtlPath = baseName .. ".mtl"

    Environment.WriteFile(objPath, objContent)
    Environment.WriteFile(mtlPath, mtlContent)

    return true, objPath
end

function ObjExporter.ExportWorkspaceToObj(): (boolean, string)
    return ObjExporter.Export(workspace)
end

return ObjExporter
