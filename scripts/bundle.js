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
    https://github.com/theopadilha2009-hash/HyperSaveInstance
    ================================================================================
]]

local __modules__ = {}
local __cache__ = {}

local function __define__(name, fn)
    __modules__[name] = fn
end

local function __require__(name)
    if __cache__[name] then
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

        // Transform requires inside module to use virtual require
        let transformed = modCode
            .replace(/require\(script\.Parent\.Parent\.Utils\.(\w+)\)/g, '__require__("Utils/$1")')
            .replace(/require\(script\.Parent\.Parent\.Config\.(\w+)\)/g, '__require__("Config/$1")')
            .replace(/require\(script\.Parent\.(\w+)\)/g, '__require__("Core/$1")')
            .replace(/require\(script\.Core\.(\w+)\)/g, '__require__("Core/$1")')
            .replace(/require\(script\.UI\.(\w+)\)/g, '__require__("UI/$1")')
            .replace(/require\(script\.Config\.(\w+)\)/g, '__require__("Config/$1")')
            .replace(/require\(script\.Utils\.(\w+)\)/g, '__require__("Utils/$1")');

        bundledCode += `\n__define__("${modName}", function()\n${transformed}\nend)\n`;
    }

    // Append main entry point
    const initCode = modules['init'] || '';
    const transformedInit = initCode
        .replace(/require\(script\.Core\.(\w+)\)/g, '__require__("Core/$1")')
        .replace(/require\(script\.UI\.(\w+)\)/g, '__require__("UI/$1")')
        .replace(/require\(script\.Config\.(\w+)\)/g, '__require__("Config/$1")')
        .replace(/require\(script\.Utils\.(\w+)\)/g, '__require__("Utils/$1")');

    bundledCode += `\n-- Entry Point\n${transformedInit}\n`;

    fs.writeFileSync(OUTPUT_FILE, bundledCode, 'utf8');
    const stats = fs.statSync(OUTPUT_FILE);
    console.log(`[HyperSaveInstance Bundler] Successfully generated ${OUTPUT_FILE} (${(stats.size / 1024).toFixed(2)} KB)`);
}

bundle();
