/**
 * HyperSaveInstance - Production Bundler & AST Verifier
 * Compiles all modular Luau source files into a single standalone production script (dist/HyperSaveInstance.luau).
 */

const fs = require('fs');
const path = require('path');
const luaparse = require('luaparse');

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

function cleanLuauCode(code) {
    let result = code;

    // Remove BOM if present
    if (result.charCodeAt(0) === 0xFEFF) {
        result = result.slice(1);
    }

    // 1. Remove multiline export type / type declarations:
    // export type Name = { ... } or type Name = ...
    result = result.replace(/^(export\s+)?type\s+\w+(\s*<[^>]+>)?\s*=\s*\{[\s\S]*?\n\}/gm, '');
    result = result.replace(/^(export\s+)?type\s+\w+(\s*<[^>]+>)?\s*=\s*.*$/gm, '');

    // 2. Remove function signatures and return types with full balanced parenthesis/bracket matching
    let i = 0;
    let out = '';
    while (i < result.length) {
        if (result.startsWith('function', i) && (i === 0 || /[^a-zA-Z0-9_]/.test(result[i-1])) && (i + 8 >= result.length || /[^a-zA-Z0-9_]/.test(result[i+8]))) {
            out += 'function';
            i += 8;
            let fnName = '';
            while (i < result.length && result[i] !== '(') {
                if (result[i] === '\n' || result[i] === ';') break;
                fnName += result[i];
                i++;
            }
            if (i < result.length && result[i] === '(') {
                fnName = fnName.replace(/<[^>]+>/g, '');
                out += fnName + '(';
                i++; // skip '('
                
                let parenDepth = 1;
                let paramStr = '';
                let inStr = false;
                let strChar = '';
                while (i < result.length && parenDepth > 0) {
                    let c = result[i];
                    if (inStr) {
                        paramStr += c;
                        if (c === strChar && result[i-1] !== '\\') inStr = false;
                    } else {
                        if (c === '"' || c === "'") {
                            inStr = true;
                            strChar = c;
                            paramStr += c;
                        } else if (c === '(') {
                            parenDepth++;
                            paramStr += c;
                        } else if (c === ')') {
                            parenDepth--;
                            if (parenDepth > 0) paramStr += c;
                        } else {
                            paramStr += c;
                        }
                    }
                    i++;
                }

                let params = [];
                let currentParam = '';
                let pDepth = 0, bDepth = 0, brDepth = 0, gDepth = 0;
                for (let j = 0; j < paramStr.length; j++) {
                    let ch = paramStr[j];
                    if (ch === '(') pDepth++;
                    else if (ch === ')') pDepth--;
                    else if (ch === '[') bDepth++;
                    else if (ch === ']') bDepth--;
                    else if (ch === '{') brDepth++;
                    else if (ch === '}') brDepth--;
                    else if (ch === '<') gDepth++;
                    else if (ch === '>') gDepth--;
                    else if (ch === ',' && pDepth === 0 && bDepth === 0 && brDepth === 0 && gDepth === 0) {
                        params.push(currentParam.trim());
                        currentParam = '';
                        continue;
                    }
                    currentParam += ch;
                }
                if (currentParam.trim()) params.push(currentParam.trim());

                let cleanedParams = params.map(p => {
                    let colonIdx = -1;
                    let pd = 0, bd = 0, brd = 0, gd = 0;
                    for (let k = 0; k < p.length; k++) {
                        let c = p[k];
                        if (c === '(') pd++;
                        else if (c === ')') pd--;
                        else if (c === '[') bd++;
                        else if (c === ']') bd--;
                        else if (c === '{') brd++;
                        else if (c === '}') brd--;
                        else if (c === '<') gd++;
                        else if (c === '>') gd--;
                        else if (c === ':' && pd === 0 && bd === 0 && brd === 0 && gd === 0) {
                            colonIdx = k;
                            break;
                        }
                    }
                    if (colonIdx !== -1) {
                        return p.substring(0, colonIdx).trim();
                    }
                    return p.trim();
                }).filter(p => p.length > 0);

                out += cleanedParams.join(', ') + ')';

                let ws = '';
                while (i < result.length && (result[i] === ' ' || result[i] === '\t')) {
                    ws += result[i];
                    i++;
                }
                if (i < result.length && (result[i] === ':' || result.startsWith('->', i))) {
                    let retParen = 0, retBrace = 0, retBracket = 0;
                    while (i < result.length) {
                        let c = result[i];
                        if (c === '(') retParen++;
                        else if (c === ')') retParen--;
                        else if (c === '{') retBrace++;
                        else if (c === '}') retBrace--;
                        else if (c === '[') retBracket++;
                        else if (c === ']') retBracket--;
                        else if (retParen === 0 && retBrace === 0 && retBracket === 0) {
                            if (c === '\n' || c === '\r' || c === ';') break;
                            if (result.startsWith('do', i) && /[^a-zA-Z0-9_]/.test(result[i+2] || ' ')) break;
                            if (result.startsWith('then', i) && /[^a-zA-Z0-9_]/.test(result[i+4] || ' ')) break;
                            if (result.startsWith('end', i) && /[^a-zA-Z0-9_]/.test(result[i+3] || ' ')) break;
                        }
                        i++;
                    }
                } else {
                    out += ws;
                }
            } else {
                out += fnName;
            }
        } else {
            out += result[i];
            i++;
        }
    }

    result = out;

    // 3. Remove local variable type annotations: local a: Type = ... -> local a = ...
    result = result.replace(/\blocal\s+([a-zA-Z0-9_]+)\s*:\s*({[^}]*(?:{[^}]*}[^}]*)*}|\[[^\]]+\]|[a-zA-Z0-9_?|<>,.\s]+?)\s*(=|\n|\r|;|$)/g, (match, name, typeAnno, suffix) => {
        if (suffix === '=') {
            return 'local ' + name + ' =';
        } else {
            return 'local ' + name + suffix;
        }
    });

    // 4. Remove type assertions: :: any, :: Instance, etc.
    result = result.replace(/::\s*[a-zA-Z0-9_?{}|<>,.\s]+/g, '');

    // 5. Replace compound assignments (+=, -=, *=, /=, ..=) with standard lua syntax
    result = result.replace(/^(\s*)([a-zA-Z0-9_.\[\]'"\\]+)\s*\+=\s*(.+)$/gm, '$1$2 = $2 + ($3)');
    result = result.replace(/^(\s*)([a-zA-Z0-9_.\[\]'"\\]+)\s*-=\s*(.+)$/gm, '$1$2 = $2 - ($3)');
    result = result.replace(/^(\s*)([a-zA-Z0-9_.\[\]'"\\]+)\s*\*=\s*(.+)$/gm, '$1$2 = $2 * ($3)');
    result = result.replace(/^(\s*)([a-zA-Z0-9_.\[\]'"\\]+)\s*\/=\s*(.+)$/gm, '$1$2 = $2 / ($3)');
    result = result.replace(/^(\s*)([a-zA-Z0-9_.\[\]'"\\]+)\s*\.\.=\s*(.+)$/gm, '$1$2 = $2 .. ($3)');

    return result;
}

function transformRequires(code, modPath) {
    const modDir = path.dirname(modPath).replace(/\\/g, '/'); // "UI", "Core", "Utils", "Config" or "."
    let cleaned = cleanLuauCode(code);

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

    // Integrity Check 1: Verify that no untransformed require(script...) remains
    const leftoverRequires = bundledCode.match(/require\s*\(\s*script[^)]*\)/g);
    if (leftoverRequires) {
        console.error('[HyperSaveInstance Bundler ERROR] Untransformed requires found in bundle:', leftoverRequires);
        process.exit(1);
    }

    // Integrity Check 2: Parse entire bundle with luaparse to ensure 0 syntax errors!
    try {
        luaparse.parse(bundledCode, { luaVersion: '5.1', extendedIdentifiers: true });
        console.log('  ✓ [AST CHECK] Bundle passed Lua 5.1/LuaJIT syntax validation with 0 errors!');
    } catch(err) {
        console.error(`[HyperSaveInstance Bundler ERROR] Bundle has Lua syntax error at line ${err.line}:${err.column}: ${err.message}`);
        const lines = bundledCode.split('\n');
        for (let j = Math.max(0, err.line - 5); j <= Math.min(lines.length - 1, err.line + 5); j++) {
            console.error(`  ${j+1}: ${lines[j]}`);
        }
        process.exit(1);
    }

    fs.writeFileSync(OUTPUT_FILE, bundledCode, 'utf8');
    const stats = fs.statSync(OUTPUT_FILE);
    console.log(`[HyperSaveInstance Bundler] Successfully generated ${OUTPUT_FILE} (${(stats.size / 1024).toFixed(2)} KB)`);
}

bundle();
