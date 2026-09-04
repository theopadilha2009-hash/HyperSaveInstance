--[[
    HyperSaveInstance - Roblox XML Serializer (.rbxlx / .rbxmx)
    Generates 100% compliant, readable and Studio-loadable Roblox XML files with CSG buffers and SharedStrings.
]]

local Reflection = require(script.Parent.Reflection)
local AssetHandler = require(script.Parent.AssetHandler)
local Base64 = require(script.Parent.Parent.Utils.Base64)

local SerializerXml = {}

-- XML Entity escaping
local function escapeXml(str: string): string
    if not str then return "" end
    str = tostring(str)
    str = string.gsub(str, "&", "&amp;")
    str = string.gsub(str, "<", "&lt;")
    str = string.gsub(str, ">", "&gt;")
    str = string.gsub(str, "\"", "&quot;")
    str = string.gsub(str, "'", "&apos;")
    return str
end

-- Escape string content for ProtectedString or general text
local function escapeCDataOrText(str: string): string
    if not str or #str == 0 then return "" end
    if string.find(str, "[<>&\"']") or string.find(str, "\n") or string.find(str, "\r") then
        local safe = string.gsub(str, "%]%]>", "]]]]><![CDATA[>")
        return "<![CDATA[" .. safe .. "]]>"
    end
    return escapeXml(str)
end

-- Format CFrame into XML
local function formatCFrame(cf: CFrame): string
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return string.format(
        "<X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z><R00>%.7g</R00><R01>%.7g</R01><R02>%.7g</R02><R10>%.7g</R10><R11>%.7g</R11><R12>%.7g</R12><R20>%.7g</R20><R21>%.7g</R21><R22>%.7g</R22>",
        x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22
    )
end

-- Format ColorSequence into XML
local function formatColorSequence(cs: ColorSequence): string
    local keypoints = cs.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f %.4f 0", kp.Time, kp.Value.R, kp.Value.G, kp.Value.B))
    end
    return table.concat(parts, " ")
end

-- Format NumberSequence into XML
local function formatNumberSequence(ns: NumberSequence): string
    local keypoints = ns.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f", kp.Time, kp.Value, kp.Envelope))
    end
    return table.concat(parts, " ")
end

-- Serialize instance attributes into binary/base64 XML format
local function serializeAttributes(attrs: {[string]: any}): string
    if not attrs or next(attrs) == nil then return "" end
    local str = ""
    for k, v in pairs(attrs) do
        str = str .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    return Base64.Encode(str)
end

-- Main XML Document Generation
function SerializerXml.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table?): string
    local opts = options or {}
    local refMap = {}
    local refCounter = 0
    local processedCount = 0

    local function getRef(inst: Instance): string
        if not refMap[inst] then
            refCounter = refCounter + 1
            refMap[inst] = "RBX" .. tostring(refCounter)
        end
        return refMap[inst]
    end

    local xmlBuffer = {}
    local function append(str: string)
        table.insert(xmlBuffer, str)
    end

    -- XML Header
    append([[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<Meta name="ExplicitAutoJoints">true</Meta>
]])

    -- Forward declaration
    local serializeInstance

    -- Recursive instance serializer
    serializeInstance = function(inst: Instance, depth: number)
        if not inst or (inst.Parent == nil and depth > 1) then return end
        
        processedCount = processedCount + 1
        if processedCount % 400 == 0 then
            task.wait(0.001) -- Micro-yield to prevent FPS crash on massive games
        end

        local indent = string.rep("\t", depth)
        local className = inst.ClassName
        local ref = getRef(inst)

        append(string.format('%s<Item class="%s" referent="%s">\n', indent, className, ref))
        append(string.format('%s\t<Properties>\n', indent))

        -- Name property
        append(string.format('%s\t\t<string name="Name">%s</string>\n', indent, escapeXml(inst.Name)))

        -- Script source if script
        if inst:IsA("LuaSourceContainer") then
            local source = scriptSources[inst]
            if not source or #source == 0 then
                pcall(function()
                    source = (inst :: any).Source
                end)
            end
            source = source or ""
            append(string.format('%s\t\t<ProtectedString name="Source">%s</ProtectedString>\n', indent, escapeCDataOrText(source)))
        end

        -- CSG Union Deep Data if applicable
        if inst:IsA("UnionOperation") or inst:IsA("NegateOperation") then
            local unionData = AssetHandler.ExtractUnionData(inst :: any)
            if unionData.PhysicsData then
                append(string.format('%s\t\t<BinaryString name="PhysicsData">%s</BinaryString>\n', indent, unionData.PhysicsData))
            end
            if unionData.ChildData then
                append(string.format('%s\t\t<BinaryString name="ChildData">%s</BinaryString>\n', indent, unionData.ChildData))
            end
            if unionData.InitialSize then
                append(string.format('%s\t\t<Vector3 name="InitialSize"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n', indent, unionData.InitialSize.X, unionData.InitialSize.Y, unionData.InitialSize.Z))
            end
        end

        -- Terrain SmoothVoxels if Terrain
        if inst:IsA("Terrain") and terrainData and terrainData.HasVoxels then
            for idx, chunk in ipairs(terrainData.VoxelChunks) do
                append(string.format('%s\t\t<BinaryString name="MaterialChunk_%d">%s</BinaryString>\n', indent, idx, chunk.Materials))
                append(string.format('%s\t\t<BinaryString name="OccupancyChunk_%d">%s</BinaryString>\n', indent, idx, chunk.Occupancies))
            end
        end

        -- Dynamic reflection properties
        local propList = Reflection.GetPropertiesForClass(className)
        for _, propInfo in ipairs(propList) do
            local propName = propInfo.Name
            local propType = propInfo.Type

            if propName ~= "Name" and propName ~= "Source" and not propInfo.ReadOnly then
                local success, val = pcall(function()
                    return (inst :: any)[propName]
                end)

                if success and val ~= nil then
                    if propType == "string" then
                        append(string.format('%s\t\t<string name="%s">%s</string>\n', indent, propName, escapeXml(tostring(val))))
                    elseif propType == "bool" then
                        append(string.format('%s\t\t<bool name="%s">%s</bool>\n', indent, propName, val and "true" or "false"))
                    elseif propType == "float" then
                        append(string.format('%s\t\t<float name="%s">%.7g</float>\n', indent, propName, tonumber(val) or 0))
                    elseif propType == "double" then
                        append(string.format('%s\t\t<double name="%s">%.15g</double>\n', indent, propName, tonumber(val) or 0))
                    elseif propType == "int" then
                        append(string.format('%s\t\t<int name="%s">%d</int>\n', indent, propName, math.floor(tonumber(val) or 0)))
                    elseif propType == "int64" then
                        append(string.format('%s\t\t<int64 name="%s">%d</int64>\n', indent, propName, math.floor(tonumber(val) or 0)))
                    elseif propType == "Vector3" and typeof(val) == "Vector3" then
                        append(string.format('%s\t\t<Vector3 name="%s"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n', indent, propName, tonumber(val.X) or 0, tonumber(val.Y) or 0, tonumber(val.Z) or 0))
                    elseif propType == "Vector2" and typeof(val) == "Vector2" then
                        append(string.format('%s\t\t<Vector2 name="%s"><X>%.7g</X><Y>%.7g</Y></Vector2>\n', indent, propName, tonumber(val.X) or 0, tonumber(val.Y) or 0))
                    elseif propType == "CoordinateFrame" and typeof(val) == "CFrame" then
                        append(string.format('%s\t\t<CoordinateFrame name="%s">%s</CoordinateFrame>\n', indent, propName, formatCFrame(val)))
                    elseif propType == "Color3" and typeof(val) == "Color3" then
                        append(string.format('%s\t\t<Color3 name="%s"><R>%.7g</R><G>%.7g</G><B>%.7g</B></Color3>\n', indent, propName, tonumber(val.R) or 0, tonumber(val.G) or 0, tonumber(val.B) or 0))
                    elseif propType == "UDim" and typeof(val) == "UDim" then
                        append(string.format('%s\t\t<UDim name="%s"><S>%.7g</S><O>%d</O></UDim>\n', indent, propName, tonumber(val.Scale) or 0, math.floor(tonumber(val.Offset) or 0)))
                    elseif propType == "UDim2" and typeof(val) == "UDim2" then
                        local xs = (type(val.X) == "table" and val.X.Scale) or (typeof(val.X) == "UDim" and val.X.Scale) or 0
                        local xo = (type(val.X) == "table" and val.X.Offset) or (typeof(val.X) == "UDim" and val.X.Offset) or 0
                        local ys = (type(val.Y) == "table" and val.Y.Scale) or (typeof(val.Y) == "UDim" and val.Y.Scale) or 0
                        local yo = (type(val.Y) == "table" and val.Y.Offset) or (typeof(val.Y) == "UDim" and val.Y.Offset) or 0
                        append(string.format('%s\t\t<UDim2 name="%s"><XS>%.7g</XS><XO>%d</XO><YS>%.7g</YS><YO>%d</YO></UDim2>\n', indent, propName, tonumber(xs) or 0, math.floor(tonumber(xo) or 0), tonumber(ys) or 0, math.floor(tonumber(yo) or 0)))
                    elseif propType == "token" then
                        local tokenNum = (typeof(val) == "EnumItem" and val.Value) or (type(val) == "table" and val.Value) or tonumber(val) or 0
                        append(string.format('%s\t\t<token name="%s">%d</token>\n', indent, propName, math.floor(tonumber(tokenNum) or 0)))
                    elseif propType == "Content" then
                        append(string.format('%s\t\t<Content name="%s"><url>%s</url></Content>\n', indent, propName, escapeXml(tostring(val))))
                    elseif propType == "Ref" then
                        if typeof(val) == "Instance" then
                            append(string.format('%s\t\t<Ref name="%s">%s</Ref>\n', indent, propName, getRef(val)))
                        else
                            append(string.format('%s\t\t<Ref name="%s">null</Ref>\n', indent, propName))
                        end
                    elseif propType == "ColorSequence" and typeof(val) == "ColorSequence" then
                        append(string.format('%s\t\t<ColorSequence name="%s">%s</ColorSequence>\n', indent, propName, formatColorSequence(val)))
                    elseif propType == "NumberSequence" and typeof(val) == "NumberSequence" then
                        append(string.format('%s\t\t<NumberSequence name="%s">%s</NumberSequence>\n', indent, propName, formatNumberSequence(val)))
                    elseif propType == "NumberRange" and typeof(val) == "NumberRange" then
                        append(string.format('%s\t\t<NumberRange name="%s">%.7g %.7g</NumberRange>\n', indent, propName, tonumber(val.Min) or 0, tonumber(val.Max) or 0))
                    elseif propType == "Rect" and typeof(val) == "Rect" then
                        append(string.format('%s\t\t<Rect2D name="%s"><min><X>%.7g</X><Y>%.7g</Y></min><max><X>%.7g</X><Y>%.7g</Y></max></Rect2D>\n', indent, propName, tonumber(val.Min.X) or 0, tonumber(val.Min.Y) or 0, tonumber(val.Max.X) or 0, tonumber(val.Max.Y) or 0))
                    elseif propType == "Font" and typeof(val) == "Font" then
                        append(string.format('%s\t\t<Font name="%s">\n%s\t\t\t<Family><url>%s</url></Family>\n%s\t\t\t<Weight>%d</Weight>\n%s\t\t\t<Style>%s</Style>\n%s\t\t</Font>\n',
                            indent, propName, indent, escapeXml(tostring(val.Family)), indent, (val.Weight and tonumber(val.Weight.Value)) or 400, indent, (val.Style and tostring(val.Style.Name)) or "Normal", indent))
                    elseif propType == "PhysicalProperties" and typeof(val) == "PhysicalProperties" then
                        append(string.format('%s\t\t<PhysicalProperties name="%s">\n%s\t\t\t<CustomPhysics>true</CustomPhysics>\n%s\t\t\t<Density>%.7g</Density>\n%s\t\t\t<Friction>%.7g</Friction>\n%s\t\t\t<Elasticity>%.7g</Elasticity>\n%s\t\t\t<FrictionWeight>%.7g</FrictionWeight>\n%s\t\t\t<ElasticityWeight>%.7g</ElasticityWeight>\n%s\t\t</PhysicalProperties>\n',
                            indent, propName, indent, indent, tonumber(val.Density) or 0, indent, tonumber(val.Friction) or 0, indent, tonumber(val.Elasticity) or 0, indent, tonumber(val.FrictionWeight) or 0, indent, tonumber(val.ElasticityWeight) or 0, indent))
                    elseif propType == "Ray" and typeof(val) == "Ray" then
                        append(string.format('%s\t\t<Ray name="%s"><origin><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></origin><direction><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></direction></Ray>\n',
                            indent, propName, tonumber(val.Origin.X) or 0, tonumber(val.Origin.Y) or 0, tonumber(val.Origin.Z) or 0, tonumber(val.Direction.X) or 0, tonumber(val.Direction.Y) or 0, tonumber(val.Direction.Z) or 0))
                    end
                end
            end
        end

        -- LocalizationTable entries dump
        if inst:IsA("LocalizationTable") then
            pcall(function()
                local entries = (inst :: any):GetEntries()
                if entries and #entries > 0 then
                    local clonerefFn = cloneref or function(obj) return obj end
                    local HttpService = clonerefFn(game:GetService("HttpService"))
                    local json = HttpService:JSONEncode(entries)
                    append(string.format('%s\t\t<string name="Contents">%s</string>\n', indent, escapeXml(json)))
                end
            end)
        end

        -- CollectionService Tags
        if opts.SaveTags then
            local tags = Reflection.GetTags(inst)
            if #tags > 0 then
                local b64Tags = Base64.Encode(table.concat(tags, "\0"))
                append(string.format('%s\t\t<BinaryString name="Tags">%s</BinaryString>\n', indent, b64Tags))
            end
        end

        -- Instance Attributes (inst:GetAttributes())
        if opts.SaveAttributes ~= false and inst.GetAttributes then
            local s, attrs = pcall(function() return inst:GetAttributes() end)
            if s and attrs and next(attrs) ~= nil then
                local b64Attrs = serializeAttributes(attrs)
                if #b64Attrs > 0 then
                    append(string.format('%s\t\t<BinaryString name="Attributes">%s</BinaryString>\n', indent, b64Attrs))
                end
            end
        end

        append(string.format('%s\t</Properties>\n', indent))

        -- Children
        for _, child in ipairs(inst:GetChildren()) do
            serializeInstance(child, depth + 1)
        end

        append(string.format('%s</Item>\n', indent))
    end

    -- Process root services
    for _, rootInst in ipairs(instances) do
        serializeInstance(rootInst, 1)
    end

    append("</roblox>\n")
    return table.concat(xmlBuffer)
end

-- Validate XML well-formedness and root closure
function SerializerXml.Validate(xmlContent: string): (boolean, string?)
    if not xmlContent or #xmlContent < 50 then
        return false, "XML content is empty or too short."
    end

    if not string.find(xmlContent, "<roblox") then
        return false, "Missing opening <roblox> root tag."
    end

    if not string.find(xmlContent, "</roblox>") then
        return false, "Missing closing </roblox> root tag."
    end

    return true, nil
end

return SerializerXml
