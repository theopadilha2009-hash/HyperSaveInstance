--[[
    HyperSaveInstance - Binary Stream / Buffer Reader & Writer
]]

local Stream = {}
Stream.__index = Stream

function Stream.new(initialData: string?)
    local self = setmetatable({}, Stream)
    self.Buffer = {}
    self.Position = 1
    if initialData then
        self.Source = initialData
        self.Length = #initialData
    else
        self.Source = ""
        self.Length = 0
    end
    return self
end

function Stream:WriteByte(val: number)
    table.insert(self.Buffer, string.char(val % 256))
    self.Length = self.Length + 1
end

function Stream:WriteBytes(bytes: string)
    table.insert(self.Buffer, bytes)
    self.Length = self.Length + #bytes
end

function Stream:WriteInt32LE(val: number)
    local bit = bit32 or bit
    local b1 = bit.band(val, 0xFF)
    local b2 = bit.band(bit.rshift(val, 8), 0xFF)
    local b3 = bit.band(bit.rshift(val, 16), 0xFF)
    local b4 = bit.band(bit.rshift(val, 24), 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteInt32BE(val: number)
    local bit = bit32 or bit
    local b1 = bit.band(bit.rshift(val, 24), 0xFF)
    local b2 = bit.band(bit.rshift(val, 16), 0xFF)
    local b3 = bit.band(bit.rshift(val, 8), 0xFF)
    local b4 = bit.band(val, 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteString(str: string)
    self:WriteInt32LE(#str)
    self:WriteBytes(str)
end

function Stream:ToString(): string
    return table.concat(self.Buffer)
end

-- Reader methods
function Stream:ReadByte(): number
    if self.Position > self.Length then
        return 0
    end
    local byte = string.byte(self.Source, self.Position)
    self.Position = self.Position + 1
    return byte
end

function Stream:ReadBytes(count: number): string
    if self.Position > self.Length then
        return ""
    end
    local chunk = string.sub(self.Source, self.Position, self.Position + count - 1)
    self.Position = self.Position + count
    return chunk
end

function Stream:ReadInt32LE(): number
    local bit = bit32 or bit
    local b1 = self:ReadByte()
    local b2 = self:ReadByte()
    local b3 = self:ReadByte()
    local b4 = self:ReadByte()
    return bit.bor(b1, bit.lshift(b2, 8), bit.lshift(b3, 16), bit.lshift(b4, 24))
end

function Stream:ReadString(): string
    local len = self:ReadInt32LE()
    return self:ReadBytes(len)
end

return Stream
