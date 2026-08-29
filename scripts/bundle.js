/**
 * HyperSaveInstance - Production Bundler
 * Compiles all modular Luau source files into a single standalone production script (dist/HyperSaveInstance.luau).
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const SRC_DIR = path.join(ROOT_DIR, 'src');
const DIST_DIR = path.join(ROOT_DIR, 'dist');
const OUTPUT_FILE = path.join(DIST_DIR, 'HyperSaveInstance.luau');

function getAllFiles(dir, fileList = []) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            getAllFiles(fullPath, fileList);
        } else if (file.endsWith('.luau') || file.endsWith('.lua')) {
            fileList.push(fullPath);
        }
    }
    return fileList;
}

function stripTypes(code) {
    let result = code;

    // 1. Remove export type and type declarations
    result = result.replace(/^(export\s+)?type\s+\w+(\s*<[^>]+>)?\s*=\s*.*$/gm, '');

    // 2. Remove return types from function headers (handling nested tuples, tables, and generics)
    result = result.replace(/(\bfunction\s+[a-zA-Z0-9_.:]*\s*\([^)]*\))\s*:\s*(\([^)]*\)|{[^}]*(?:{[^}]*}[^}]*)*}|\[[^\]]+\]|[a-zA-Z0-9_?|<>,\s]+)(?=\s*(?:\n|\r|do|then|end|$))/g, '$1');

    // 3. Remove parameter types inside function signatures: e.g. (a: number, b: string?) -> (a, b)
    result = result.replace(/function\s*([a-zA-Z0-9_.:]*)\s*\(([^)]*)\)/g, (match, fnName, params) => {
        if (!params.trim()) return `function ${fnName}()`;
        const cleanedParams = params.split(',').map(p => {
            const trimmed = p.trim();
            const colonIdx = trimmed.indexOf(':');
            if (colonIdx !== -1) {
                return trimmed.substring(0, colonIdx).trim();
            }
            return trimmed;
        }).join(', ');
        return `function ${fnName}(${cleanedParams})`;
    });

    // 4. Remove local variable typed annotations (including nested tables e.g. {[type]: type})
    result = result.replace(/\blocal\s+([a-zA-Z0-9_]+)\s*:\s*({[^}]*(?:{[^}]*}[^}]*)*}|\[[^\]]+\]|[a-zA-Z0-9_?|<>,.\s]+?)\s*(=|\n|\r|;|$)/g, (match, name, typeAnno, suffix) => {
        if (suffix === '=') {
            return `local ${name} =`;
        } else {
            return `local ${name}${suffix}`;
        }
    });

    // 5. Remove type assertions: :: any, :: Instance, etc.
    result = result.replace(/::\s*[a-zA-Z0-9_?{}|<>,.\s]+/g, '');

    return result;
}

function transformRequires(code, modPath) {
    const modDir = path.dirname(modPath).replace(/\\/g, '/'); // "UI", "Core", "Utils", "Config" or "."
    let cleaned = stripTypes(code);

    return cleaned
        // Triple parent / across domain
        .replace(/require\(script\.Parent\.Parent\.Core\.(\w+)\)/g, '__require__("Core/$1")')
        .replace(/require\(script\.Parent\.Parent\.UI\.(\w+)\)/g, '__require__("UI/$1")')
        .replace(/require\(script\.Parent\.Parent\.Utils\.(\w+)\)/g, '__require__("Utils/$1")')
        .replace(/require\(script\.Parent\.Parent\.Config\.(\w+)\)/g, '__require__("Config/$1")')
        // Sibling in current directory (script.Parent.Module)
        .replace(/require\(script\.Parent\.(\w+)\)/g, (match, p1) => {
            const targetDir = (modDir === '.' || !modDir) ? 'Core' : modDir;
            return `__require__("${targetDir}/${p1}")`;
        })
        // Submodules from root (script.Domain.Module)
        .replace(/require\(script\.Core\.(\w+)\)/g, '__require__("Core/$1")')
        .replace(/require\(script\.UI\.(\w+)\)/g, '__require__("UI/$1")')
        .replace(/require\(script\.Config\.(\w+)\)/g, '__require__("Config/$1")')
        .replace(/require\(script\.Utils\.(\w+)\)/g, '__require__("Utils/$1")');
}

function bundle() {
    console.log('[HyperSaveInstance Bundler] Starting build...');

    if (!fs.existsSync(DIST_DIR)) {
        fs.mkdirSync(DIST_DIR, { recursive: true });
    }

    const files = getAllFiles(SRC_DIR);
    const modules = {};

    for (const file of files) {
        const relPath = path.relative(SRC_DIR, file).replace(/\\/g, '/').replace(/\.luau$|\.lua$/, '');
        const content = fs.readFileSync(file, 'utf8');
        modules[relPath] = content;
        console.log(`  + Bundled module: ${relPath}`);
    }

    // Build the standalone Luau virtual loader
    let bundledCode = `--[[
    ================================================================================
    HyperSaveInstance v2.0 - Standalone Production Bundle
    Universal Roblox Game Cloner & SaveInstance Engine
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    ================================================================================
]]

local __modules__ = {}
local __cache__ = {}

local function __showErrorGui__(errTitle, errDesc)
    pcall(function()
        local parent = (gethui and gethui()) or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")) or game:GetService("CoreGui")
        if not parent then return end

        local sg = Instance.new("ScreenGui")
        sg.Name = "HyperSave_ErrorAlert"
        sg.DisplayOrder = 9999999
        sg.ResetOnSpawn = false

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 440, 0, 240)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(0.5, 0, 0.5, 0)
        f.BackgroundColor3 = Color3.fromRGB(20, 8, 16)
        f.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = f

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(244, 63, 94)
        stroke.Thickness = 2
        stroke.Parent = f

        local title = Instance.new("TextLabel")
        title.Text = "⚠️ " .. tostring(errTitle or "HYPERSAVE - ERRO")
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextColor3 = Color3.fromRGB(244, 63, 94)
        title.Size = UDim2.new(1, -24, 0, 26)
        title.Position = UDim2.new(0, 12, 0, 10)
        title.BackgroundTransparency = 1
        title.Parent = f

        local desc = Instance.new("TextLabel")
        desc.Text = tostring(errDesc or "Erro desconhecido")
        desc.Font = Enum.Font.Code
        desc.TextSize = 10
        desc.TextColor3 = Color3.fromRGB(255, 230, 235)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Size = UDim2.new(1, -24, 1, -84)
        desc.Position = UDim2.new(0, 12, 0, 38)
        desc.BackgroundTransparency = 1
        desc.Parent = f

        local btn = Instance.new("TextButton")
        btn.Text = "FECHAR AVISO"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(244, 63, 94)
        btn.Size = UDim2.new(1, -24, 0, 32)
        btn.Position = UDim2.new(0, 12, 1, -40)
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.Parent = f
        btn.MouseButton1Click:Connect(function() sg:Destroy() end)

        f.Parent = sg
        sg.Parent = parent
    end)
end

local function __define__(name, fn)
    __modules__[name] = fn
end

local function __require__(name)
    if __cache__[name] ~= nil then
        return __cache__[name]
    end
    local modFn = __modules__[name]
    if not modFn then
        local msg = "[HyperSaveInstance] Modulo nao encontrado: " .. tostring(name)
        warn(msg)
        __showErrorGui__("Modulo Faltando", msg)
        error(msg)
    end
    local success, result = pcall(modFn)
    if not success then
        local msg = "[HyperSaveInstance] Erro ao carregar modulo " .. tostring(name) .. ": " .. tostring(result)
        warn(msg)
        __showErrorGui__("Falha no Modulo: " .. tostring(name), tostring(result))
        error(msg)
    end
    __cache__[name] = result
    return result
end

-- Virtual Module Definitions
`;

    for (const [modName, modCode] of Object.entries(modules)) {
        if (modName === 'init') continue;
        const transformed = transformRequires(modCode, modName);
        bundledCode += `\n__define__("${modName}", function()\n${transformed}\nend)\n`;
    }

    // Append main entry point with top-level error protection
    const initCode = modules['init'] || '';
    const transformedInit = transformRequires(initCode, 'init');

    bundledCode += `\n-- Entry Point\nlocal __mainSuccess__, __mainErr__ = pcall(function()\n${transformedInit}\nend)\nif not __mainSuccess__ then\n    warn("[HyperSaveInstance Fatal Error] " .. tostring(__mainErr__))\n    __showErrorGui__("Erro Fatal na Execucao", tostring(__mainErr__))\nend\n`;

    // Integrity Check: Verify that no untransformed require(script...) remains
    const leftoverRequires = bundledCode.match(/require\s*\(\s*script[^)]*\)/g);
    if (leftoverRequires) {
        console.error('[HyperSaveInstance Bundler ERROR] Untransformed requires found in bundle:', leftoverRequires);
        process.exit(1);
    }

    fs.writeFileSync(OUTPUT_FILE, bundledCode, 'utf8');
    const stats = fs.statSync(OUTPUT_FILE);
    console.log(`[HyperSaveInstance Bundler] Successfully generated ${OUTPUT_FILE} (${(stats.size / 1024).toFixed(2)} KB)`);
}

bundle();

