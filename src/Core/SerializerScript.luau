--[[
    HyperSaveInstance - Studio Lua Script Serializer (.lua)
    Generates a single standalone Luau script to recreate the entire game hierarchy inside Roblox Studio Command Bar.
]]

local Reflection = require(script.Parent.Reflection)

local SerializerScript = {}

local function formatValueLua(val: any, propType: string): string
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "Vector3" then
        return string.format("Vector3.new(%.4f, %.4f, %.4f)", val.X, val.Y, val.Z)
    elseif t == "Vector2" then
        return string.format("Vector2.new(%.4f, %.4f)", val.X, val.Y)
    elseif t == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()
        return string.format("CFrame.new(%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)",
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    elseif t == "Color3" then
        return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(val.R * 255), math.floor(val.G * 255), math.floor(val.B * 255))
    elseif t == "UDim" then
        return string.format("UDim.new(%.4f, %d)", val.Scale, val.Offset)
    elseif t == "UDim2" then
        return string.format("UDim2.new(%.4f, %d, %.4f, %d)", val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
    elseif t == "EnumItem" then
        return tostring(val)
    elseif t == "NumberRange" then
        return string.format("NumberRange.new(%.4f, %.4f)", val.Min, val.Max)
    end
    return "nil"
end

function SerializerScript.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table?): string
    local opts = options or {}
    local out = {}
    local function append(str: string)
        table.insert(out, str)
    end

    append([=[
--[[
    ===================================================================
    HyperSaveInstance - Studio Place Recreation Script
    Run this script inside Roblox Studio Command Bar to build the game!
    ===================================================================
]]

local CollectionService = game:GetService("CollectionService")

local function buildGame()
    print("[HyperSaveInstance] Rebuilding place hierarchy...")
    local instMap = {}

]=])

    local instCounter = 0
    local function serializeTree(inst: Instance, parentVar: string)
        instCounter = instCounter + 1
        local varName = "inst_" .. tostring(instCounter)
        local className = inst.ClassName

        if inst.Parent == game then
            append(string.format('    local %s = game:GetService(%q)\n', varName, className))
        else
            append(string.format('    local %s = Instance.new(%q)\n', varName, className))
            append(string.format('    %s.Name = %q\n', varName, inst.Name))

            -- Properties
            local propList = Reflection.GetPropertiesForClass(className)
            for _, propInfo in ipairs(propList) do
                local propName = propInfo.Name
                local propType = propInfo.Type

                if propName ~= "Name" and propName ~= "Source" and not propInfo.ReadOnly then
                    local s, val = pcall(function() return (inst :: any)[propName] end)
                    if s and val ~= nil then
                        local luaVal = formatValueLua(val, propType)
                        if luaVal ~= "nil" then
                            append(string.format('    pcall(function() %s.%s = %s end)\n', varName, propName, luaVal))
                        end
                    end
                end
            end

            -- Script source
            if inst:IsA("LuaSourceContainer") and scriptSources[inst] then
                local src = scriptSources[inst]
                if #src > 0 then
                    -- Safely escape any matching closing bracket if present
                    local safeSrc = string.gsub(src, "%]%===%]", "]=== ]")
                    append(string.format('    pcall(function() %s.Source = [===[%s]===] end)\n', varName, safeSrc))
                end
            end

            -- Attributes
            if options.SaveAttributes then
                local attrs = Reflection.GetAttributes(inst)
                for k, v in pairs(attrs) do
                    local luaV = formatValueLua(v, typeof(v))
                    if luaV ~= "nil" then
                        append(string.format('    pcall(function() %s:SetAttribute(%q, %s) end)\n', varName, k, luaV))
                    end
                end
            end

            -- Tags
            if options.SaveTags then
                local tags = Reflection.GetTags(inst)
                for _, tag in ipairs(tags) do
                    append(string.format('    pcall(function() CollectionService:AddTag(%s, %q) end)\n', varName, tag))
                end
            end

            append(string.format('    %s.Parent = %s\n\n', varName, parentVar))
        end

        for _, child in ipairs(inst:GetChildren()) do
            serializeTree(child, varName)
        end
    end

    for _, root in ipairs(instances) do
        serializeTree(root, "game")
    end

    append([=[
    print("[HyperSaveInstance] Place rebuilt successfully!")
end

buildGame()
]=])

    return table.concat(out)
end

return SerializerScript
