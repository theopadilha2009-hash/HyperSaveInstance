--[[
    ================================================================================
    💀 HyperSaveInstance v2.0 - Universal Master Loader
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Supported: Delta (Mobile & Windows), Hydrogen, MacSploit, Solara, Wave, Codex, Arceus X
    ================================================================================
]]

local function __launch__()
    local rawUrl = "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"
    local cacheBustedUrl = rawUrl .. "?t=" .. tostring(os.time())
    
    local content = nil
    local getSuccess, getErr = pcall(function()
        content = game:HttpGet(cacheBustedUrl)
    end)
    
    if not getSuccess or not content or #content == 0 then
        -- Fallback to direct raw url without query param if executor has strict HttpGet
        local fbSuccess, fbContent = pcall(function()
            return game:HttpGet(rawUrl)
        end)
        if fbSuccess and fbContent and #fbContent > 0 then
            content = fbContent
        else
            error("Falha ao baixar HyperSaveInstance do GitHub: " .. tostring(getErr))
        end
    end

    local execFn, syntaxErr = loadstring(content)
    if not execFn then
        error("Erro ao compilar HyperSaveInstance: " .. tostring(syntaxErr))
    end

    return execFn()
end

local ok, err = pcall(__launch__)
if not ok then
    warn("[💀 HyperSaveInstance Fatal] " .. tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ HyperSaveInstance Erro",
            Text = tostring(err):sub(1, 120),
            Duration = 10
        })
    end)
end
