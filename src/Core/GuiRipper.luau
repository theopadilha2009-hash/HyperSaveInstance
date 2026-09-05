--[[
    HyperSaveInstance - GUI & HUD Ripper
    Extracts all ScreenGuis, Menus, Inventories, Health Bars, and HUDs to a standalone UI Pack or pure Luau code.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)
local StarterGui = nil
pcall(function()
    StarterGui = clonerefFn(game:GetService("StarterGui"))
end)
local Environment = require(script.Parent.Parent.Utils.Environment)
local SerializerXml = require(script.Parent.SerializerXml)
local Decompiler = require(script.Parent.Decompiler)

local GuiRipper = {}

-- Check if a GUI belongs to CoreGui / internal toolbars
local function isInternalGui(gui: Instance): boolean
    local name = gui.Name
    if
        name == "RobloxGui"
        or name == "CoreScripts"
        or name == "HyperSaveInstance_UI"
        or name == "TopBarApp"
        or name == "PurchasePrompt"
        or name == "InGameMenu"
    then
        return true
    end
    return false
end

-- Export all active GUIs to .rbxmx XML package
function GuiRipper.ExportAllGuis(options: table?): (boolean, string)
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_UIPack_%d.rbxmx", placeId)

    local folder = Instance.new("Folder")
    folder.Name = "Extracted_UIPack"

    local allGuis = {}
    local scriptInstances = {}

    -- Scan StarterGui
    if StarterGui then
        for _, gui in ipairs(StarterGui:GetChildren()) do
            if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and not isInternalGui(gui) then
                pcall(function()
                    local cl = gui:Clone()
                    if cl then
                        cl.Parent = folder
                    end
                end)
            end
        end
    end

    -- Scan PlayerGui if available
    local player = Players and Players.LocalPlayer
    if player then
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, gui in ipairs(pGui:GetChildren()) do
                if
                    (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui"))
                    and not isInternalGui(gui)
                    and not folder:FindFirstChild(gui.Name)
                then
                    pcall(function()
                        local cl = gui:Clone()
                        if cl then
                            cl.Parent = folder
                        end
                    end)
                end
            end
        end
    end

    local function scanScripts(inst: Instance)
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do
            scanScripts(child)
        end
    end
    scanScripts(folder)

    local scriptSources = {}
    if #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, options or { DecompileScripts = true })
    end

    local xml = SerializerXml.Serialize({ folder }, scriptSources, nil, { SaveAttributes = true, SaveTags = true })
    local writeOk = Environment.WriteFile(fileName, xml)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write UI pack file."
end

-- Convert any GUI instance into an executable, pure Luau script
function GuiRipper.ExportGuiToLuaScript(targetGui: Instance): (boolean, string)
    if not targetGui then
        return false, "No GUI instance specified for Luau code generator"
    end

    local lines = {
        "--[[",
        "    ================================================================================",
        "    [HyperSaveInstance - Auto-Generated Luau GUI Script]",
        "    Target: " .. targetGui.Name .. " (" .. targetGui.ClassName .. ")",
        "    Generated automatically by HyperSaveInstance GuiRipper.",
        "    ================================================================================",
        "--]]",
        "",
        'local CoreGui = game:GetService("CoreGui")',
        'local Players = game:GetService("Players")',
        "local LocalPlayer = Players.LocalPlayer",
        'local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")',
        "",
        "local function CreateUI()",
    }

    local varCounter = 0
    local instToVar = {}

    local function getVar(inst: Instance): string
        if not instToVar[inst] then
            varCounter = varCounter + 1
            local cleanName = string.gsub(inst.Name, "[^%w_]", "")
            if #cleanName == 0 then
                cleanName = "inst"
            end
            instToVar[inst] = string.format("%s_%d", cleanName, varCounter)
        end
        return instToVar[inst]
    end

    local function serializeInst(inst: Instance, parentVar: string?)
        local vName = getVar(inst)
        table.insert(lines, string.format("    local %s = Instance.new(%q)", vName, inst.ClassName))
        table.insert(lines, string.format("    %s.Name = %q", vName, inst.Name))

        pcall(function()
            if inst:IsA("GuiObject") then
                table.insert(
                    lines,
                    string.format(
                        "    %s.Size = UDim2.new(%s, %s, %s, %s)",
                        vName,
                        inst.Size.X.Scale,
                        inst.Size.X.Offset,
                        inst.Size.Y.Scale,
                        inst.Size.Y.Offset
                    )
                )
                table.insert(
                    lines,
                    string.format(
                        "    %s.Position = UDim2.new(%s, %s, %s, %s)",
                        vName,
                        inst.Position.X.Scale,
                        inst.Position.X.Offset,
                        inst.Position.Y.Scale,
                        inst.Position.Y.Offset
                    )
                )
                table.insert(
                    lines,
                    string.format(
                        "    %s.BackgroundColor3 = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor(inst.BackgroundColor3.R * 255),
                        math.floor(inst.BackgroundColor3.G * 255),
                        math.floor(inst.BackgroundColor3.B * 255)
                    )
                )
                table.insert(lines, string.format("    %s.BackgroundTransparency = %s", vName, tostring(inst.BackgroundTransparency)))
            end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                table.insert(lines, string.format("    %s.Text = %q", vName, (inst :: any).Text))
                table.insert(lines, string.format("    %s.TextSize = %d", vName, (inst :: any).TextSize))
                table.insert(
                    lines,
                    string.format(
                        "    %s.TextColor3 = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor((inst :: any).TextColor3.R * 255),
                        math.floor((inst :: any).TextColor3.G * 255),
                        math.floor((inst :: any).TextColor3.B * 255)
                    )
                )
            end
            if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                table.insert(lines, string.format("    %s.Image = %q", vName, (inst :: any).Image))
            end
            if inst:IsA("UICorner") then
                table.insert(
                    lines,
                    string.format("    %s.CornerRadius = UDim.new(%s, %s)", vName, inst.CornerRadius.Scale, inst.CornerRadius.Offset)
                )
            end
            if inst:IsA("UIStroke") then
                table.insert(
                    lines,
                    string.format(
                        "    %s.Color = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor(inst.Color.R * 255),
                        math.floor(inst.Color.G * 255),
                        math.floor(inst.Color.B * 255)
                    )
                )
                table.insert(lines, string.format("    %s.Thickness = %s", vName, tostring(inst.Thickness)))
            end
        end)

        if parentVar then
            table.insert(lines, string.format("    %s.Parent = %s", vName, parentVar))
        else
            table.insert(lines, string.format("    %s.Parent = (gethui and gethui()) or PlayerGui or CoreGui", vName))
        end
        table.insert(lines, "")

        for _, child in ipairs(inst:GetChildren()) do
            serializeInst(child, vName)
        end
    end

    serializeInst(targetGui, nil)
    table.insert(lines, "    return " .. getVar(targetGui))
    table.insert(lines, "end")
    table.insert(lines, "")
    table.insert(lines, "return CreateUI()")

    local code = table.concat(lines, "\n")
    local fileName = string.format("HyperSave_GuiScript_%s_%d.lua", string.gsub(targetGui.Name, "[^%w_]", ""), os.time())
    local writeOk = Environment.WriteFile(fileName, code)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write Luau GUI script"
end

return GuiRipper
