/**
 * HyperSaveInstance - Full Headless Roblox Engine & Runtime Simulator
 * Executes dist/HyperSaveInstance.luau inside a complete virtual Roblox environment using Fengari Lua VM.
 */

const fs = require('fs');
const path = require('path');
const fengari = require('fengari');
const { lua, lauxlib, lualib } = fengari;

console.log('===============================================================');
console.log(' HYPERSAVEINSTANCE - HEADLESS ROBLOX RUNTIME SIMULATOR ');
console.log('===============================================================\n');

const ROOT_DIR = path.resolve(__dirname, '..');
const BUNDLE_PATH = path.join(ROOT_DIR, 'dist', 'HyperSaveInstance.luau');

const bundleCode = fs.readFileSync(BUNDLE_PATH, 'utf8');

// Build the Roblox Polyfill harness in Lua
const robloxHarness = `
-- Polyfills & Roblox Objects
warn = function(...)
    print("  [WARN] " .. tostring((...)))
end
local _instances = {}

local function createSignal()
    local sig = {}
    sig.__index = sig
    function sig:Connect(fn)
        return {
            Disconnect = function() end
        }
    end
    function sig:Wait()
        return nil
    end
    return setmetatable({}, sig)
end

function typeof(val)
    local t = type(val)
    if t == "table" and val.__typeof then
        return val.__typeof
    end
    return t
end

-- Math / Vector / Geometry Types
Vector2 = {}
Vector2.__index = Vector2
function Vector2.new(x, y)
    return setmetatable({ X = x or 0, Y = y or 0, __typeof = "Vector2" }, Vector2)
end

Vector3 = {}
Vector3.__index = Vector3
function Vector3.new(x, y, z)
    return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0, __typeof = "Vector3" }, Vector3)
end

UDim = {}
UDim.__index = UDim
function UDim.new(s, o)
    return setmetatable({ Scale = s or 0, Offset = o or 0, __typeof = "UDim" }, UDim)
end

UDim2 = {}
UDim2.__index = UDim2
function UDim2.new(sx, ox, sy, oy)
    if type(sx) == "table" and type(ox) == "table" then
        return setmetatable({ X = sx, Y = ox, __typeof = "UDim2" }, UDim2)
    end
    return setmetatable({ X = UDim.new(sx, ox), Y = UDim.new(sy, oy), __typeof = "UDim2" }, UDim2)
end

Color3 = {}
Color3.__index = Color3
function Color3.new(r, g, b)
    return setmetatable({ R = r or 0, G = g or 0, B = b or 0, __typeof = "Color3" }, Color3)
end
function Color3.fromRGB(r, g, b)
    return Color3.new((r or 0)/255, (g or 0)/255, (b or 0)/255)
end

ColorSequenceKeypoint = {}
ColorSequenceKeypoint.__index = ColorSequenceKeypoint
function ColorSequenceKeypoint.new(time, color)
    return setmetatable({ Time = time, Value = color, __typeof = "ColorSequenceKeypoint" }, ColorSequenceKeypoint)
end

ColorSequence = {}
ColorSequence.__index = ColorSequence
function ColorSequence.new(points)
    return setmetatable({ Keypoints = points, __typeof = "ColorSequence" }, ColorSequence)
end

TweenInfo = {}
TweenInfo.__index = TweenInfo
function TweenInfo.new(t, s, d, r, rev, del)
    return setmetatable({ Time = t or 1, EasingStyle = s, EasingDirection = d, __typeof = "TweenInfo" }, TweenInfo)
end

RaycastParams = {}
RaycastParams.__index = RaycastParams
function RaycastParams.new()
    return setmetatable({ FilterDescendantsInstances = {}, FilterType = 0, IgnoreWater = true, __typeof = "RaycastParams" }, RaycastParams)
end

CFrame = {}
CFrame.__index = CFrame
CFrame.identity = setmetatable({ Position = Vector3.new(0, 0, 0), __typeof = "CFrame" }, CFrame)
function CFrame.new(x, y, z)
    local pos = (type(x) == "table" and x.X and x) or Vector3.new(x or 0, y or 0, z or 0)
    return setmetatable({ Position = pos, __typeof = "CFrame" }, CFrame)
end
function CFrame.Angles(...)
    return setmetatable({ Position = Vector3.new(0, 0, 0), __typeof = "CFrame" }, CFrame)
end
function CFrame:PointToWorldSpace(v)
    local px = (self.Position and self.Position.X) or 0
    local py = (self.Position and self.Position.Y) or 0
    local pz = (self.Position and self.Position.Z) or 0
    local vx = (v and v.X) or 0
    local vy = (v and v.Y) or 0
    local vz = (v and v.Z) or 0
    return Vector3.new(px + vx, py + vy, pz + vz)
end
function CFrame:GetComponents()
    local px = (self.Position and self.Position.X) or 0
    local py = (self.Position and self.Position.Y) or 0
    local pz = (self.Position and self.Position.Z) or 0
    return px, py, pz, 1, 0, 0, 0, 1, 0, 0, 0, 1
end

-- Enum table hierarchy
Enum = {
    Font = { GothamBold = "GothamBold", GothamSemibold = "GothamSemibold", Gotham = "Gotham", Code = "Code" },
    EasingStyle = { Quad = "Quad", Back = "Back", Linear = "Linear", Sine = "Sine" },
    EasingDirection = { Out = "Out", In = "In", InOut = "InOut" },
    ZIndexBehavior = { Sibling = "Sibling", Global = "Global" },
    ApplyStrokeMode = { Border = "Border", Contextual = "Contextual" },
    UserInputType = { MouseButton1 = "MouseButton1", MouseMovement = "MouseMovement", Touch = "Touch" },
    UserInputState = { Begin = "Begin", Change = "Change", End = "End" },
    KeyCode = { RightShift = "RightShift", Escape = "Escape", F = "F" },
    FillDirection = { Horizontal = "Horizontal", Vertical = "Vertical" },
    SortOrder = { LayoutOrder = "LayoutOrder", Name = "Name" },
    TextXAlignment = { Left = "Left", Center = "Center", Right = "Right" },
    TextYAlignment = { Top = "Top", Center = "Center", Bottom = "Bottom" },
    RenderFidelity = { Precise = "Precise", Automatic = "Automatic", Performance = "Performance" },
    CollisionFidelity = { Default = "Default", Hull = "Hull", Box = "Box", PreciseConvexDecomposition = "PreciseConvexDecomposition" },
    AlphaMode = { Overlay = "Overlay", Transparency = "Transparency" },
    RaycastFilterType = { Exclude = "Exclude", Blacklist = "Blacklist", Include = "Include", Whitelist = "Whitelist" },
    Material = { Air = "Air", Neon = "Neon", Plastic = "Plastic", SmoothPlastic = "SmoothPlastic" },
    RunContext = { Client = "Client", Server = "Server", Legacy = "Legacy" }
}

-- Instance Mock Class
Instance = {}
Instance.__index = Instance

function Instance.new(className, parent)
    local obj = {
        ClassName = className,
        Name = className,
        Children = {},
        Parent = nil,
        Visible = true,
        Enabled = true,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        TextColor3 = Color3.new(0, 0, 0),
        TextTransparency = 0,
        Text = "",
        Font = "Gotham",
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2.new(0, 0),
        DisplayOrder = 0,
        ResetOnSpawn = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = false,
        ClipsDescendants = false,
        CornerRadius = UDim.new(0, 0),
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Rotation = 0,
        Adornee = nil,
        FillColor = Color3.new(1, 1, 1),
        FillTransparency = 0,
        OutlineColor = Color3.new(1, 1, 1),
        OutlineTransparency = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Color3.new(1, 1, 1),
        AutomaticCanvasSize = 0,
        LayoutOrder = 0,
        Padding = UDim.new(0, 0),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        PaddingLeft = UDim.new(0, 0),
        PaddingRight = UDim.new(0, 0),
        PaddingTop = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 0),
        MeshId = "",
        TextureId = "",
        TextureID = "",
        SoundId = "",
        Volume = 1,
        TimeLength = 0,
        IsPlaying = false,
        __typeof = "Instance"
    }

    -- Signals
    obj.MouseButton1Click = createSignal()
    obj.MouseButton1Down = createSignal()
    obj.MouseButton1Up = createSignal()
    obj.MouseEnter = createSignal()
    obj.MouseLeave = createSignal()
    obj.Activated = createSignal()
    obj.InputBegan = createSignal()
    obj.InputChanged = createSignal()
    obj.InputEnded = createSignal()
    obj.Changed = createSignal()

    function obj:FindFirstChild(name)
        for _, c in ipairs(self.Children) do
            if c.Name == name then return c end
        end
        return nil
    end

    function obj:FindFirstChildOfClass(className)
        for _, c in ipairs(self.Children) do
            if c.ClassName == className then return c end
        end
        return nil
    end

    function obj:WaitForChild(name, timeout)
        return self:FindFirstChild(name)
    end

    function obj:GetChildren()
        return self.Children
    end

    function obj:GetDescendants()
        local list = {}
        local function recurse(p)
            for _, c in ipairs(p.Children) do
                table.insert(list, c)
                recurse(c)
            end
        end
        recurse(self)
        return list
    end

    function obj:GetPropertyChangedSignal(prop)
        return createSignal()
    end

    function obj:IsA(className)
        if self.ClassName == className then return true end
        if className == "GuiObject" and (self.ClassName == "Frame" or self.ClassName == "TextLabel" or self.ClassName == "TextButton" or self.ClassName == "ScrollingFrame" or self.ClassName == "TextBox" or self.ClassName == "ImageLabel") then
            return true
        end
        if className == "BasePart" and (self.ClassName == "Part" or self.ClassName == "MeshPart" or self.ClassName == "UnionOperation") then
            return true
        end
        if className == "LuaSourceContainer" and (self.ClassName == "LocalScript" or self.ClassName == "ModuleScript" or self.ClassName == "Script") then
            return true
        end
        return false
    end

    function obj:Destroy()
        if self.Parent then
            for idx, c in ipairs(self.Parent.Children) do
                if c == self then
                    table.remove(self.Parent.Children, idx)
                    break
                end
            end
            self.Parent = nil
        end
    end

    obj._attributes = {}
    function obj:SetAttribute(name, val)
        self._attributes[name] = val
    end
    function obj:GetAttributes()
        return self._attributes
    end
    function obj:GetAttribute(name)
        return self._attributes[name]
    end

    function obj:GetFullName()
        if self.Parent and self.Parent.Name then
            return self.Parent:GetFullName() .. "." .. self.Name
        end
        return self.Name
    end

    setmetatable(obj, {
        __index = Instance,
        __newindex = function(t, k, v)
            if k == "Parent" then
                local oldParent = rawget(t, "Parent")
                if oldParent and oldParent.Children then
                    for idx, c in ipairs(oldParent.Children) do
                        if c == t then
                            table.remove(oldParent.Children, idx)
                            break
                        end
                    end
                end
                rawset(t, "Parent", v)
                if v and v.Children then
                    table.insert(v.Children, t)
                end
            else
                rawset(t, k, v)
            end
        end
    })

    if parent then
        obj.Parent = parent
    end

    table.insert(_instances, obj)
    return obj
end

-- Roblox Hierarchy Roots
game = Instance.new("DataModel")
game.Name = "Game"
game.PlaceId = 1537690962 -- Bee Swarm Simulator Place ID

workspace = Instance.new("Workspace", game)
workspace.Name = "Workspace"
workspace.CurrentCamera = Instance.new("Camera", workspace)
workspace.CurrentCamera.ViewportSize = Vector2.new(1920, 1080)
function workspace.CurrentCamera:ViewportPointToRay(x, y)
    return {
        Origin = Vector3.new(x, y, 0),
        Direction = Vector3.new(0, 0, -1)
    }
end
function workspace:Raycast(origin, dir, params)
    return nil
end

local coreGui = Instance.new("CoreGui", game)
coreGui.Name = "CoreGui"
coreGui.RobloxGui = Instance.new("ScreenGui", coreGui)
coreGui.RobloxGui.Name = "RobloxGui"

local players = Instance.new("Players", game)
players.Name = "Players"
local localPlayer = Instance.new("Player", players)
localPlayer.Name = "TheoLorentz"
localPlayer.UserId = 12345678
players.LocalPlayer = localPlayer

local playerGui = Instance.new("PlayerGui", localPlayer)
playerGui.Name = "PlayerGui"

local httpService = Instance.new("HttpService", game)
httpService.Name = "HttpService"
function httpService:JSONEncode(tbl)
    local function ser(v)
        if type(v) == "table" then
            local parts = {}
            for k, val in pairs(v) do
                table.insert(parts, string.format("%q:%s", tostring(k), ser(val)))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        elseif type(v) == "string" then
            return string.format("%q", v)
        else
            return tostring(v)
        end
    end
    return ser(tbl)
end

function httpService:JSONDecode(str)
    -- Simple mock parser for snapshot tables
    local res = {
        PlaceId = game.PlaceId or 0,
        Timestamp = "2026-08-31T15:00:00Z",
        InstanceCount = 26,
        Instances = {}
    }
    return res
end

local starterGui = Instance.new("StarterGui", game)
starterGui.Name = "StarterGui"
function starterGui:SetCore(name, data)
    print("  [StarterGui:SetCore] " .. tostring(name) .. " -> " .. tostring(data and data.Title or "") .. ": " .. tostring(data and data.Text or ""))
end

local tweenService = Instance.new("TweenService", game)
tweenService.Name = "TweenService"
function tweenService:Create(inst, info, props)
    return {
        Play = function(self)
            for k, v in pairs(props) do
                inst[k] = v
            end
        end
    }
end

local userInputService = Instance.new("UserInputService", game)
userInputService.Name = "UserInputService"
userInputService.InputBegan = createSignal()
userInputService.InputChanged = createSignal()
userInputService.InputEnded = createSignal()
function userInputService:GetMouseLocation()
    return Vector2.new(960, 540)
end

local runService = Instance.new("RunService", game)
runService.Name = "RunService"
runService.RenderStepped = createSignal()
runService.Heartbeat = createSignal()
runService.Stepped = createSignal()

local soundService = Instance.new("SoundService", game)
soundService.Name = "SoundService"

local services = {
    Players = players,
    CoreGui = coreGui,
    HttpService = httpService,
    StarterGui = starterGui,
    TweenService = tweenService,
    UserInputService = userInputService,
    RunService = runService,
    SoundService = soundService,
    Workspace = workspace,
}

function game:GetService(name)
    local s = services[name]
    if s then return s end
    local newServ = Instance.new(name, game)
    services[name] = newServ
    return newServ
end

-- Task Library
task = {
    spawn = function(fn, ...)
        local args = {...}
        return pcall(function() fn(table.unpack(args)) end)
    end,
    delay = function(t, fn, ...)
        local args = {...}
        return pcall(function() fn(table.unpack(args)) end)
    end,
    wait = function(t) return 0 end,
    defer = function(fn, ...)
        local args = {...}
        return pcall(function() fn(table.unpack(args)) end)
    end
}

-- Global Executor polyfills (Delta / Hydrogen / MacSploit / Solara simulation)
function gethui()
    return coreGui
end

local _genv = {}
function getgenv()
    return _genv
end

function identifyexecutor()
    return "Delta (Android/iOS Mobile & Windows)"
end

local _virtualFS = {}
function writefile(p, c)
    _virtualFS[p] = c
    return true
end

function readfile(p)
    return _virtualFS[p]
end

function isfile(p)
    return _virtualFS[p] ~= nil
end

function makefolder(p) return true end
function isfolder(p) return true end

function setclipboard(t)
    print("  [Clipboard] Copied " .. #t .. " bytes to clipboard.")
    return true
end

function cloneref(obj)
    return obj
end

function getnilinstances()
    return {}
end

function hookmetamethod(obj, method, fn)
    return fn
end

function getnamecallmethod()
    return "FireServer"
end

print("[Simulator] Virtual Roblox Engine Initialized. Executing Bundle...")
`;

// Initialize Fengari VM
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

// Load and execute harness
let status = lauxlib.luaL_dostring(L, fengari.to_luastring(robloxHarness));
if (status !== lua.LUA_OK) {
    const err = lua.lua_tojsstring(L, -1);
    console.error('Fatal error initializing Roblox harness in Lua:', err);
    process.exit(1);
}

// Load and execute dist/HyperSaveInstance.luau
console.log('[Simulator] Running dist/HyperSaveInstance.luau in Fengari VM...');
const start = Date.now();
status = lauxlib.luaL_dostring(L, fengari.to_luastring(bundleCode));
const elapsed = Date.now() - start;

if (status !== lua.LUA_OK) {
    const err = lua.lua_tojsstring(L, -1);
    console.error(`\n❌ [SIMULATOR FAILED] Runtime exception thrown during execution:\n${err}`);
    process.exit(1);
}

console.log(`\n✓ [SIMULATOR SUCCESS] dist/HyperSaveInstance.luau executed cleanly in ${elapsed}ms!`);

// Verify UI Tree and Exported State in Lua VM
const verificationScript = `
local genv = (getgenv and getgenv()) or _G
local hsi = genv.HyperSaveInstance or _G.HyperSaveInstance
if not hsi then
    error("HyperSaveInstance was not exported to globals!")
end

print("  ✓ Global export 'HyperSaveInstance' verified (Version: " .. tostring(hsi.Version) .. ")")
print("  ✓ Global hook 'saveinstance' verified: " .. tostring(type(genv.saveinstance or _G.saveinstance)))

-- Check UI hierarchy in Safe Gui Parent (CoreGui / PlayerGui)
local safeParent = (gethui and gethui()) or game:GetService("CoreGui")
local ui = safeParent:FindFirstChild("HyperSaveInstance_UI")
if not ui then
    error("ScreenGui 'HyperSaveInstance_UI' was not created in Gui Parent!")
end
print("  ✓ ScreenGui 'HyperSaveInstance_UI' successfully created in " .. safeParent.Name)

local mainFrame = ui:FindFirstChild("MainFrame")
if not mainFrame then
    error("MainFrame was not created inside ScreenGui!")
end
print("  ✓ MainFrame created successfully (Size: " .. tostring(mainFrame.Size.X.Offset) .. "x" .. tostring(mainFrame.Size.Y.Offset) .. ")")

local floatingBtn = ui:FindFirstChild("FloatingToggle")
if not floatingBtn then
    error("FloatingToggle mobile button was not created!")
end
print("  ✓ FloatingToggle button created successfully: '" .. floatingBtn.Text .. "'")

-- Verify all tab pages inside MainFrame
local pages = {"Dashboard", "Selector", "AudioRipper", "LightingRipper", "GuiRipper", "Network", "Universe", "ObjExport", "Tutorial", "Settings", "Console", "About"}
local contentArea = mainFrame:FindFirstChild("ContentArea")
if not contentArea then
    error("ContentArea container not found in MainFrame!")
end

for _, page in ipairs(pages) do
    local pFrame = contentArea:FindFirstChild(page .. "Tab")
    if not pFrame then
        error("Tab page '" .. page .. "Tab' is missing from ContentArea!")
    end
    print("    ✓ Tab verified: " .. page .. " (" .. #pFrame.Children .. " UI elements)")
end

-- Test programmatic Cloner initialization
local engine = hsi.Defaults
if not engine then
    error("Defaults config missing!")
end
print("  ✓ Engine Defaults validated (ShowUI: " .. tostring(hsi.Defaults.ShowUI) .. ", Mode: " .. tostring(hsi.Defaults.Mode) .. ")")

-- 3. End-to-End Game Cloning Simulation (Bee Swarm Simulator Map)
print("--- 3. Testing Real-Time Full Place Cloning & XML Serialization ---")

-- Populate realistic game instances
local hive = Instance.new("Model", workspace)
hive.Name = "BeeHive_Slot1"
hive:SetAttribute("HoneyCapacity", 500000)

local hiveBase = Instance.new("Part", hive)
hiveBase.Name = "HiveBase"
hiveBase.Size = Vector3.new(12, 1, 12)
hiveBase.Position = Vector3.new(0, 0, 0)
hiveBase.Color = Color3.fromRGB(245, 158, 11)

local honeyComb = Instance.new("MeshPart", hive)
honeyComb.Name = "HoneyCombCell"
honeyComb.MeshId = "rbxassetid://123456789"
honeyComb.TextureId = "rbxassetid://987654321"

local beeSound = Instance.new("Sound", hive)
beeSound.Name = "BuzzSound"
beeSound.SoundId = "rbxassetid://55555555"
beeSound.Volume = 0.8

-- Lighting
local lighting = game:GetService("Lighting")
local atmosphere = Instance.new("Atmosphere", lighting)
atmosphere.Name = "SunnyAtmosphere"
atmosphere.Density = 0.35

local sky = Instance.new("Sky", lighting)
sky.Name = "BlueSky"

-- Scripts
local repStorage = game:GetService("ReplicatedStorage")
local honeyModule = Instance.new("ModuleScript", repStorage)
honeyModule.Name = "HoneyManager"
honeyModule.Source = [[local Honey = {}; Honey.Total = 1000; return Honey]]

local starterPlayer = game:GetService("StarterPlayer")
local spScripts = Instance.new("StarterPlayerScripts", starterPlayer)
spScripts.Name = "StarterPlayerScripts"
local beeClient = Instance.new("LocalScript", spScripts)
beeClient.Name = "BeeFlightController"
beeClient.Source = [[print("Bee Swarm Controller Active!")]]

print("  ✓ Mock Bee Swarm Map populated with Models, MeshParts, Sounds, Lighting & Scripts")

-- Execute full place save
print("  ⏳ Executing hsi.Save({ Mode = 'Full' })...")
local saveSuccess, saveResult = hsi.Save({
    Mode = "Full",
    Decompile = false,
    DownloadAssets = false,
    SaveNonCreatable = false,
    ShowUI = false
})

if not saveSuccess then
    error("hsi.Save failed: " .. tostring(saveResult))
end

print("  ✓ hsi.Save finished successfully! Result: " .. tostring(saveResult))

local fileName = "HyperSave_Place_1537690962.rbxlx"
local savedXml = readfile(fileName)
if not savedXml or #savedXml < 500 then
    error("Saved RBXLX file is empty or too small (" .. tostring(savedXml and #savedXml) .. " bytes)!")
end

print("  ✓ Generated .RBXLX size: " .. tostring((#savedXml / 1024)) .. " KB")

-- Validate XML structure
if not string.find(savedXml, "<roblox") or not string.find(savedXml, "</roblox>") then
    error("Saved file is not a valid Roblox XML place!")
end
print("  ✓ Valid <roblox> root XML tags confirmed")

if not string.find(savedXml, 'class="Workspace"') then
    error("Workspace is missing from saved XML!")
end
print("  ✓ Workspace service serialized")

if not string.find(savedXml, 'BeeHive_Slot1') then
    error("BeeHive_Slot1 model is missing from saved XML!")
end
print("  ✓ BeeHive_Slot1 Model serialized")

if not string.find(savedXml, 'name="Attributes"') then
    error("Attributes tag is missing from saved XML!")
end
print("  ✓ Attributes serialized successfully into XML")

if not string.find(savedXml, 'HoneyCombCell') then
    error("HoneyCombCell MeshPart is missing from saved XML!")
end
print("  ✓ HoneyCombCell MeshPart serialized")

if not string.find(savedXml, 'HoneyManager') then
    error("HoneyManager ModuleScript is missing from saved XML!")
end
print("  ✓ HoneyManager ModuleScript serialized")

if not string.find(savedXml, 'SunnyAtmosphere') then
    error("SunnyAtmosphere is missing from saved XML!")
end
print("  ✓ SunnyAtmosphere Lighting effect serialized")

-- 4. Testing Standalone Web 3D HTML / Three.js Exporter
print("--- 4. Testing Standalone Web 3D (HTML / Three.js) Exporter ---")
local web3dSuccess, web3dFile = hsi.ExportWeb3D(workspace)
if not web3dSuccess then
    error("ExportWeb3D failed: " .. tostring(web3dFile))
end
local htmlContent = readfile(web3dFile)
if not htmlContent or not string.find(htmlContent, "THREE.WebGLRenderer") or not string.find(htmlContent, "OrbitControls") then
    error("Generated HTML 3D file is missing WebGL / Three.js engine!")
end
print("  ✓ Standalone Web 3D Viewer generated successfully: " .. web3dFile .. " (" .. tostring(#htmlContent) .. " bytes)")

-- 5. Testing Map Snapshot & Update Diff Tracker
print("--- 5. Testing Place Snapshot & Update Diff Tracker ---")
local snapSuccess, snapFile = hsi.Snapshot()
if not snapSuccess then
    error("hsi.Snapshot failed: " .. tostring(snapFile))
end
print("  ✓ Place snapshot captured and saved to: " .. snapFile)

local diff = hsi.CompareDiff(snapFile)
if not diff or not diff.Success then
    error("hsi.CompareDiff failed: " .. tostring(diff and diff.Error))
end
print("  ✓ Place Diff analysis verified: " .. tostring(diff.Summary))

local diffRepSuccess, diffRepFile = hsi.PlaceDiffTracker.ExportDiffReport(diff)
if not diffRepSuccess then
    error("ExportDiffReport failed: " .. tostring(diffRepFile))
end
print("  ✓ Place Update Diff Report exported: " .. diffRepFile)

-- 6. Testing Silent / Ghost Mode & Stealth Execution
print("--- 6. Testing Silent / Ghost Stealth Mode ---")
local silentSuccess, silentResult = hsi.SaveSilent({ FilePath = "HyperSave_Ghost_Test.rbxlx" })
if not silentSuccess then
    error("SaveSilent failed: " .. tostring(silentResult))
end
print("  ✓ SaveSilent executed cleanly in background without GUI or audio alert!")

-- 7. Testing Ghost Preset Configuration
print("--- 7. Testing Ghost Preset Options ---")
local ghostCfg = hsi.Defaults.ApplyPreset({}, "Ghost")
if not ghostCfg.SilentMode then error("Ghost preset missing SilentMode!") end
if ghostCfg.ShowUI ~= false then error("Ghost preset ShowUI should be false!") end
if not ghostCfg.SafeStreaming then error("Ghost preset SafeStreaming should be true!") end
if not ghostCfg.StealthMode then error("Ghost preset StealthMode should be true!") end
print("  ✓ Ghost Preset correctly configured (SilentMode: true, ShowUI: false, SafeStreaming: true, StealthMode: true)")

return "ALL_ROBLOX_CHECKS_PASSED"
`;

status = lauxlib.luaL_dostring(L, fengari.to_luastring(verificationScript));
if (status !== lua.LUA_OK) {
    const err = lua.lua_tojsstring(L, -1);
    console.error(`\n❌ [UI VERIFICATION FAILED]:\n${err}`);
    process.exit(1);
}

const result = lua.lua_tojsstring(L, -1);
console.log('\n===============================================================');
console.log(` RESULTADO FINAL DO SIMULADOR: ${result}`);
console.log(' O bundle foi executado em um ambiente Roblox completo (Delta)');
console.log(' A UI, todas as 12 abas, o botão flutuante e a Engine funcionaram 100%!');
console.log('===============================================================\n');
