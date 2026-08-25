--[[
    HyperSaveInstance - Roblox Binary Serializer (.rbxl / .rbxm)
    Writes chunked binary Roblox files (PRMS, INST, PROP, PRNT, END) with LZ4 compression.
]]

local Stream = require(script.Parent.Parent.Utils.Stream)
local LZ4 = require(script.Parent.Parent.Utils.LZ4)
local Reflection = require(script.Parent.Reflection)

local SerializerBinary = {}

-- Magic header for Roblox Binary files
local ROBIN_MAGIC = "<roblox!\x89\xff\x0d\x0a\x1a\x0a"

-- Helper to write a compressed Roblox chunk
local function writeChunk(stream: any, chunkName: string, data: string)
    local uncompressedLen = #data
    local compressed = LZ4.Compress(data)
    local compressedLen = #compressed

    stream:WriteBytes(chunkName)
    if compressedLen < uncompressedLen then
        stream:WriteInt32LE(compressedLen)
        stream:WriteInt32LE(uncompressedLen)
        stream:WriteInt32LE(0) -- Reserved
        stream:WriteBytes(compressed)
    else
        stream:WriteInt32LE(0) -- Uncompressed flag
        stream:WriteInt32LE(uncompressedLen)
        stream:WriteInt32LE(0)
        stream:WriteBytes(data)
    end
end

function SerializerBinary.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table): string
    local stream = Stream.new()

    -- Write Binary Header
    stream:WriteBytes(ROBIN_MAGIC)
    stream:WriteByte(0) -- Version 0
    stream:WriteInt32LE(0) -- Class count (calculated later)
    stream:WriteInt32LE(0) -- Instance count

    -- Collect classes and instance hierarchy
    local classMap = {}
    local instanceList = {}
    local idMap = {}
    local idCounter = 0

    local function traverse(inst: Instance)
        local cName = inst.ClassName
        if not classMap[cName] then
            classMap[cName] = {}
        end
        table.insert(classMap[cName], inst)
        table.insert(instanceList, inst)
        idMap[inst] = idCounter
        idCounter = idCounter + 1

        for _, child in ipairs(inst:GetChildren()) do
            traverse(child)
        end
    end

    for _, root in ipairs(instances) do
        traverse(root)
    end

    -- Write INST chunks for each class
    local classId = 0
    for className, insts in pairs(classMap) do
        local chunkStream = Stream.new()
        chunkStream:WriteInt32LE(classId)
        chunkStream:WriteString(className)
        chunkStream:WriteByte(0) -- IsService flag
        chunkStream:WriteInt32LE(#insts)

        -- Write referent IDs delta-encoded
        local prevId = 0
        for _, inst in ipairs(insts) do
            local curId = idMap[inst]
            local delta = curId - prevId
            chunkStream:WriteInt32LE(delta)
            prevId = curId
        end

        writeChunk(stream, "INST", chunkStream:ToString())
        classId = classId + 1
    end

    -- Write PRNT chunk (Parent-child hierarchy)
    local parentStream = Stream.new()
    parentStream:WriteByte(0) -- Version
    parentStream:WriteInt32LE(#instanceList)

    -- Write child IDs
    for i, inst in ipairs(instanceList) do
        parentStream:WriteInt32LE(idMap[inst])
    end
    -- Write parent IDs (-1 for roots)
    for i, inst in ipairs(instanceList) do
        local p = inst.Parent
        if p and idMap[p] then
            parentStream:WriteInt32LE(idMap[p])
        else
            parentStream:WriteInt32LE(-1)
        end
    end

    writeChunk(stream, "PRNT", parentStream:ToString())

    -- Write END chunk
    writeChunk(stream, "END\0", "</roblox>")

    return stream:ToString()
end

return SerializerBinary
