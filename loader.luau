--[[
    ================================================================================
    💀 HyperSaveInstance v2.0 - Universal Master Loader
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Supported: Delta (Mobile & Windows), Hydrogen, MacSploit, Solara, Wave, Codex, Arceus X
    ================================================================================
]]

local function __launch__()
    local sources = {
        "https://cdn.jsdelivr.net/gh/theopadilha2009-hash/HyperSaveInstance@main/dist/HyperSaveInstance.luau",
        "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau",
        "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/e2d629c/dist/HyperSaveInstance.luau",
    }

    local code = nil
    local lastErr = nil

    for _, url in ipairs(sources) do
        local ok, res = pcall(function()
            return game:HttpGet(url .. "?t=" .. tostring(os.time()))
        end)
        if not ok or not res or #res == 0 then
            ok, res = pcall(function()
                return game:HttpGet(url)
            end)
        end
        if ok and res and #res > 1000 then
            local fn, syntaxErr = loadstring(res)
            if fn then
                code = fn
                break
            else
                lastErr = "Sintaxe: " .. tostring(syntaxErr)
            end
        else
            lastErr = "Download: " .. tostring(res)
        end
    end

    if not code then
        error(lastErr or "Não foi possível carregar HyperSaveInstance de nenhuma fonte.")
    end

    return code()
end

local ok, err = pcall(__launch__)
if not ok then
    local isSilent = false
    pcall(function()
        local genv = (getgenv and getgenv()) or _G
        if genv then
            isSilent = (genv.HyperSave_Silent == true) or (genv.SilentMode == true) or (genv.HyperSave_Ghost == true)
        end
    end)

    if not isSilent then
        warn("[💀 HyperSaveInstance Fatal] " .. tostring(err))
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ HyperSaveInstance Erro",
                Text = tostring(err):sub(1, 120),
                Duration = 10
            })
        end)
    end
end
