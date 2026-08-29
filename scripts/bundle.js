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

local function __define__(name, fn)
    __modules__[name] = fn
end

local function __require__(name)
    if __cache__[name] ~= nil then
        return __cache__[name]
    end
    local modFn = __modules__[name]
    if not modFn then
        error("[HyperSaveInstance] Module not found: " .. tostring(name))
    end
    local result = modFn()
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

    // Append main entry point
    const initCode = modules['init'] || '';
    const transformedInit = transformRequires(initCode, 'init');

    bundledCode += `\n-- Entry Point\n${transformedInit}\n`;

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

