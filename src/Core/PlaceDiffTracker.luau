--[[
    HyperSaveInstance - Map & Update Diff Tracker
    Compares the current place hierarchy against a previous snapshot to identify
    newly added instances, modified scripts, and removed models in game updates.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = clonerefFn(game:GetService("HttpService"))
end)
local Environment = require(script.Parent.Parent.Utils.Environment)

local PlaceDiffTracker = {}

-- Create a lightweight signature dictionary of all instances in a target container
function PlaceDiffTracker.CreateSnapshot(root: Instance?): table
    local target = root or game
    local snapshot = {
        PlaceId = game.PlaceId or 0,
        Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        InstanceCount = 0,
        Instances = {},
    }

    local function scan(inst: Instance, path: string)
        local curPath = path .. "/" .. inst.Name
        local class = inst.ClassName
        local childrenCount = #inst:GetChildren()

        local info = {
            Class = class,
            Children = childrenCount,
        }

        if inst:IsA("LuaSourceContainer") then
            local s, src = pcall(function()
                return (inst :: any).Source
            end)
            if s and src then
                info.SourceLen = #src
            end
        end

        snapshot.Instances[curPath] = info
        snapshot.InstanceCount = snapshot.InstanceCount + 1

        for _, child in ipairs(inst:GetChildren()) do
            scan(child, curPath)
        end
    end

    for _, serv in ipairs(target:GetChildren()) do
        if not string.find(serv.ClassName, "Core") and not string.find(serv.Name, "Roblox") then
            pcall(function()
                scan(serv, "")
            end)
        end
    end

    return snapshot
end

-- Save snapshot to executor storage
function PlaceDiffTracker.SaveSnapshot(name: string?, root: Instance?): (boolean, string)
    local snapName = name or string.format("HyperSave_Snapshot_%d_%s.json", game.PlaceId or 0, os.date("%Y%m%d_%H%M%S"))
    local snapData = PlaceDiffTracker.CreateSnapshot(root)

    local s, json = pcall(function()
        return HttpService:JSONEncode(snapData)
    end)

    if not s or not json then
        return false, "Falha ao codificar snapshot JSON."
    end

    local wrote = Environment.WriteFile(snapName, json)
    if wrote then
        return true, snapName
    end
    return false, "Falha ao gravar arquivo de snapshot."
end

-- Compare two snapshots or compare current place against a saved snapshot file
function PlaceDiffTracker.Compare(prevSnapshotOrFile: any, curSnapshot: table?): table
    local prev = prevSnapshotOrFile
    if type(prev) == "string" then
        local content = Environment.ReadFile(prev)
        if not content then
            return { Success = false, Error = "Arquivo de snapshot anterior não encontrado." }
        end
        local s, parsed = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if not s or not parsed then
            return { Success = false, Error = "JSON de snapshot anterior inválido." }
        end
        prev = parsed
    end

    local curr = curSnapshot or PlaceDiffTracker.CreateSnapshot()

    local diff = {
        Success = true,
        PlaceId = curr.PlaceId,
        Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        PreviousTimestamp = prev.Timestamp or "Desconhecido",
        Added = {},
        Removed = {},
        Modified = {},
        Summary = "",
    }

    -- Detect added and modified
    for path, info in pairs(curr.Instances) do
        local old = prev.Instances[path]
        if not old then
            table.insert(diff.Added, { Path = path, Class = info.Class })
        else
            if old.Class ~= info.Class or (info.SourceLen and old.SourceLen ~= info.SourceLen) then
                table.insert(diff.Modified, { Path = path, Class = info.Class, OldClass = old.Class, Diff = "Script/Propriedade alterada" })
            end
        end
    end

    -- Detect removed
    for path, oldInfo in pairs(prev.Instances) do
        if not curr.Instances[path] then
            table.insert(diff.Removed, { Path = path, Class = oldInfo.Class })
        end
    end

    diff.Summary = string.format(
        "Diff: +%d adicionados, -%d removidos, ~%d modificados (Total Atual: %d)",
        #diff.Added,
        #diff.Removed,
        #diff.Modified,
        curr.InstanceCount
    )

    return diff
end

-- Export comparison report as human-readable markdown / text
function PlaceDiffTracker.ExportDiffReport(diff: table): (boolean, string)
    if not diff.Success then
        return false, diff.Error or "Erro desconhecido"
    end

    local fileName = string.format("HyperSave_DiffReport_%d.txt", diff.PlaceId or 0)
    local lines = {
        "================================================================================",
        "💀 HYPERSAVEINSTANCE - RELATÓRIO DE ATUALIZAÇÃO DO MAPA (PLACE DIFF)",
        "Desenvolvido por Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)",
        "================================================================================",
        string.format("Place ID: %d", diff.PlaceId or 0),
        string.format("Data da Comparação: %s", diff.Timestamp),
        string.format("Snapshot Anterior: %s", diff.PreviousTimestamp),
        string.format("Resumo: %s", diff.Summary),
        "================================================================================",
        "",
        string.format("--- [1] NOVAS INSTÂNCIAS ADICIONADAS (%d) ---", #diff.Added),
    }

    for i, item in ipairs(diff.Added) do
        if i <= 200 then
            table.insert(lines, string.format("  [+] (%s) %s", item.Class, item.Path))
        end
    end
    if #diff.Added > 200 then
        table.insert(lines, string.format("  ... e mais %d itens adicionados.", #diff.Added - 200))
    end

    table.insert(lines, "")
    table.insert(lines, string.format("--- [2] INSTÂNCIAS MODIFICADAS (%d) ---", #diff.Modified))
    for i, item in ipairs(diff.Modified) do
        if i <= 200 then
            table.insert(lines, string.format("  [~] (%s) %s -> %s", item.Class, item.Path, item.Diff))
        end
    end

    table.insert(lines, "")
    table.insert(lines, string.format("--- [3] INSTÂNCIAS REMOVIDAS (%d) ---", #diff.Removed))
    for i, item in ipairs(diff.Removed) do
        if i <= 200 then
            table.insert(lines, string.format("  [-] (%s) %s", item.Class, item.Path))
        end
    end

    local content = table.concat(lines, "\n")
    local success = Environment.WriteFile(fileName, content)
    if success then
        return true, fileName
    end
    return false, "Falha ao gravar relatório de diff."
end

return PlaceDiffTracker
