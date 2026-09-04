/**
 * HyperSaveInstance - Debug & Audit Suite
 *
 * Tests Base64 and XML escaping by executing the actual Luau modules in a Lua
 * VM, plus static checks over the Reflection tables, the bundle and the plugin.
 */

const fs = require('fs');
const path = require('path');
const { lua, lauxlib, lualib, to_luastring } = require('fengari');

const ROOT_DIR = path.resolve(__dirname, '..');
const DIST_PATH = path.join(ROOT_DIR, 'dist', 'HyperSaveInstance.luau');
const PLUGIN_PATH = path.join(ROOT_DIR, 'plugin', 'HyperSaveImporter.server.luau');

let passedTests = 0;
let failedTests = 0;

function assert(condition, testName, details = '') {
    if (condition) {
        console.log(`  [PASS] ${testName}`);
        passedTests++;
    } else {
        console.error(`  [FAIL] ${testName} ${details ? '(' + details + ')' : ''}`);
        failedTests++;
    }
}


// Loads one src/ module into a Lua VM and returns a caller for its functions.
// The previous suite tested Node's Buffer and a JS-local escapeXml, so neither
// src/Utils/Base64.luau nor src/Core/SerializerXml.luau was ever executed.
function loadLuauModule(relPath) {
    const source = fs.readFileSync(path.join(ROOT_DIR, 'src', relPath), 'utf8');
    // The bundler strips Luau type annotations the same way before shipping.
    const stripped = source
        .replace(/^\s*(export\s+)?type\s+[\w<>,\s]+=[^\n]*(\n\s+[^\n]*)*/gm, '')
        .replace(/::\s*[\w.<>{}|?\s]+/g, '')
        .replace(/:\s*[\w.<>{}|?]+(\??)\s*(?=[,)=])/g, '')
        .replace(/\)\s*:\s*[\w.<>{}|?()\s,]+(?=\s*\n)/g, ')');

    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    if (lauxlib.luaL_dostring(L, to_luastring(stripped)) !== lua.LUA_OK) {
        throw new Error(`${relPath}: ${lua.lua_tojsstring(L, -1)}`);
    }
    return {
        call(fnName, ...args) {
            lua.lua_getfield(L, -1, to_luastring(fnName));
            if (!lua.lua_isfunction(L, -1)) {
                lua.lua_pop(L, 1);
                throw new Error(`${relPath}: ${fnName} is not a function`);
            }
            for (const a of args) {
                if (Buffer.isBuffer(a)) lua.lua_pushstring(L, a);
                else if (typeof a === 'string') lua.lua_pushstring(L, Buffer.from(a, 'binary'));
                else if (typeof a === 'number') lua.lua_pushnumber(L, a);
                else if (typeof a === 'boolean') lua.lua_pushboolean(L, a);
                else throw new Error('unsupported arg type');
            }
            if (lua.lua_pcall(L, args.length, 1, 0) !== lua.LUA_OK) {
                const err = lua.lua_tojsstring(L, -1);
                lua.lua_pop(L, 1);
                throw new Error(`${relPath}.${fnName}: ${err}`);
            }
            const raw = lua.lua_tostring(L, -1);
            lua.lua_pop(L, 1);
            return Buffer.from(raw);
        }
    };
}

function testBase64Logic() {
    console.log('\n--- 1. Testing Base64 Encoding / Decoding Logic ---');
    const testCases = [
        "",
        "f",
        "fo",
        "foo",
        "foob",
        "fooba",
        "foobar",
        "Roblox HyperSaveInstance 2026",
        "\x00\x01\x02\x03\xFF\xFE\xFD",
        JSON.stringify({ Terrain: "Voxels", Material: 1, Occupancy: 255 })
    ];

    let mod;
    try {
        mod = loadLuauModule(path.join('Utils', 'Base64.luau'));
    } catch (err) {
        assert(false, 'Load src/Utils/Base64.luau', err.message);
        return;
    }

    for (const str of testCases) {
        const label = `"${str.substring(0, 20)}..."`;
        try {
            const input = Buffer.from(str, 'binary');
            const encoded = mod.call('Encode', input).toString('binary');
            const expected = input.toString('base64');
            assert(encoded === expected, `Base64 Encode matches reference: ${label}`, `got ${encoded}, want ${expected}`);
            const decoded = mod.call('Decode', Buffer.from(encoded, 'binary'));
            assert(decoded.equals(input), `Base64 Roundtrip through Luau: ${label}`, `got ${JSON.stringify(decoded.toString('binary'))}`);
        } catch (err) {
            assert(false, `Base64 ${label}`, err.message);
        }
    }
}

// Test XML Escaping Logic
function testXmlEscaping() {
    console.log('\n--- 2. Testing XML Escaping & Format Verification ---');

    // escapeXml is a local inside SerializerXml.luau, so it is extracted and run
    // as-is rather than reimplemented here — a JS copy would pass even if the
    // Luau one broke.
    const src = fs.readFileSync(path.join(ROOT_DIR, 'src', 'Core', 'SerializerXml.luau'), 'utf8');
    const match = src.match(/local function escapeXml\(str: string\): string([\s\S]*?)\nend\n/);
    if (!match) {
        assert(false, 'Extract escapeXml from SerializerXml.luau');
        return;
    }

    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    const fnSrc = `local function escapeXml(str)${match[1]}\nend\nreturn escapeXml`;
    if (lauxlib.luaL_dostring(L, to_luastring(fnSrc)) !== lua.LUA_OK) {
        assert(false, 'Compile escapeXml', lua.lua_tojsstring(L, -1));
        return;
    }

    const escape = (input) => {
        lua.lua_pushvalue(L, -1);
        lua.lua_pushstring(L, to_luastring(input));
        if (lua.lua_pcall(L, 1, 1, 0) !== lua.LUA_OK) {
            const err = lua.lua_tojsstring(L, -1);
            lua.lua_pop(L, 1);
            throw new Error(err);
        }
        const out = lua.lua_tojsstring(L, -1);
        lua.lua_pop(L, 1);
        return out;
    };

    const cases = [
        ['<Folder name="Test & Demo" quote=\'single\'>', '&lt;Folder name=&quot;Test &amp; Demo&quot; quote=&apos;single&apos;&gt;'],
        ['plain text', 'plain text'],
        ['', ''],
        // Ampersand must be escaped first, or the entities it produces get
        // double-escaped into &amp;lt;.
        ['a & b < c', 'a &amp; b &lt; c'],
        ['&amp;', '&amp;amp;'],
        ['<<>>', '&lt;&lt;&gt;&gt;'],
    ];

    for (const [input, expected] of cases) {
        try {
            const got = escape(input);
            assert(got === expected, `XML escape: ${JSON.stringify(input)}`, `got ${JSON.stringify(got)}, want ${JSON.stringify(expected)}`);
        } catch (err) {
            assert(false, `XML escape: ${JSON.stringify(input)}`, err.message);
        }
    }
}

// Test Reflection database coverage
function testReflectionCoverage() {
    console.log('\n--- 3. Testing Reflection Database & Class Hierarchy ---');
    const reflectionFile = fs.readFileSync(path.join(ROOT_DIR, 'src', 'Core', 'Reflection.luau'), 'utf8');

    const essentialClasses = [
        'Instance', 'BasePart', 'Part', 'MeshPart', 'UnionOperation',
        'SpecialMesh', 'Decal', 'Texture', 'SurfaceAppearance', 'MaterialVariant',
        'Lighting', 'Atmosphere', 'Sky', 'Sound', 'ParticleEmitter', 'Beam',
        'Trail', 'Motor6D', 'Weld', 'ScreenGui', 'Frame', 'TextLabel', 'LocalScript',
        'ModuleScript', 'Script', 'Tool', 'Accessory', 'Humanoid'
    ];

    for (const cls of essentialClasses) {
        assert(reflectionFile.includes(`["${cls}"] =`), `Class definition: ${cls}`);
    }
}

// Test All Source Files Existence & Integrity
function testSourceFiles() {
    console.log('\n--- 4. Testing All Source Module Files ---');
    const modules = [
        'src/init.luau',
        'src/Config/Defaults.luau',
        'src/Config/ClassBlacklist.luau',
        'src/Core/Engine.luau',
        'src/Core/Reflection.luau',
        'src/Core/Decompiler.luau',
        'src/Core/TerrainSerializer.luau',
        'src/Core/StreamExplorer.luau',
        'src/Core/RaycastSelector.luau',
        'src/Core/AssetHandler.luau',
        'src/Core/AssetDownloader.luau',
        'src/Core/AudioRipper.luau',
        'src/Core/LightingRipper.luau',
        'src/Core/GuiRipper.luau',
        'src/Core/NetworkSniffer.luau',
        'src/Core/UniverseTracker.luau',
        'src/Core/ObjExporter.luau',
        'src/Core/Web3DExporter.luau',
        'src/Core/PlaceDiffTracker.luau',
        'src/Core/Optimizer.luau',
        'src/Core/SerializerXml.luau',
        'src/Core/SerializerBinary.luau',
        'src/Core/SerializerScript.luau',
        'src/UI/Interface.luau',
        'src/UI/Theme.luau',
        'src/Utils/Environment.luau',
        'src/Utils/AntiAFK.luau',
        'src/Utils/Stealth.luau',
        'src/Utils/Base64.luau',
        'src/Utils/LZ4.luau',
        'src/Utils/Stream.luau',
        'src/Utils/LicenseManager.luau',
    ];

    for (const relPath of modules) {
        const fullPath = path.join(ROOT_DIR, relPath);
        const exists = fs.existsSync(fullPath);
        const size = exists ? fs.statSync(fullPath).size : 0;
        assert(exists && size > 100, `Module File: ${relPath} (${size} bytes)`);
    }
}

// Test Bundled Output
function testBundle() {
    console.log('\n--- 5. Testing Standalone Production Bundle ---');
    assert(fs.existsSync(DIST_PATH), 'dist/HyperSaveInstance.luau exists');
    const content = fs.readFileSync(DIST_PATH, 'utf8');
    const sizeKb = fs.statSync(DIST_PATH).size / 1024;
    assert(sizeKb > 50, `Bundle size is healthy (${sizeKb.toFixed(2)} KB)`);
    assert(content.includes('__modules__') && content.includes('__require__'), 'Virtual Loader system active');
    assert(content.includes('HyperSaveInstance.Save'), 'Main Save API exported');
    assert(content.includes('HyperSaveInstance.OpenUI'), 'Main UI API exported');
    assert(content.includes('saveinstance'), 'Global saveinstance hook exported');

    // Cross-reference all defines and requires
    const definedModules = new Set();
    const defineRegex = /__define__\("([^"]+)"/g;
    let match;
    while ((match = defineRegex.exec(content)) !== null) {
        definedModules.add(match[1]);
    }

    assert(definedModules.size >= 25, `Virtual loader contains ${definedModules.size} defined modules`);

    const requireRegex = /__require__\("([^"]+)"\)/g;
    let allRequiresValid = true;
    const missingRequires = [];
    while ((match = requireRegex.exec(content)) !== null) {
        if (!definedModules.has(match[1])) {
            allRequiresValid = false;
            missingRequires.push(match[1]);
        }
    }

    assert(allRequiresValid, `All __require__() targets resolve to defined modules (Missing: ${missingRequires.join(', ') || 'none'})`);

    const leftoverRequires = content.match(/require\s*\(\s*script[^)]*\)/g);
    assert(!leftoverRequires, 'Zero leftover untransformed require() calls');

    // AST syntax validation
    const luaparse = require('luaparse');
    let astValid = false;
    let parseErr = '';
    try {
        luaparse.parse(content, { luaVersion: '5.1', extendedIdentifiers: true });
        astValid = true;
    } catch(err) {
        parseErr = `${err.line}:${err.column} -> ${err.message}`;
    }
    assert(astValid, 'Bundle AST Syntax Validation (Lua 5.1/LuaJIT VM)', parseErr);
}

// Test Plugin
function testPlugin() {
    console.log('\n--- 6. Testing Studio Plugin ---');
    assert(fs.existsSync(PLUGIN_PATH), 'plugin/HyperSaveImporter.server.luau exists');
    const content = fs.readFileSync(PLUGIN_PATH, 'utf8');
    assert(content.includes('CreateToolbar') && content.includes('DockWidgetPluginGui'), 'Plugin Toolbar & Widget UI declared');
}

function runAll() {
    console.log('=====================================================');
    console.log(' HYPERSAVEINSTANCE - MASTER DEBUG & AUDIT SUITE ');
    console.log('=====================================================');

    testBase64Logic();
    testXmlEscaping();
    testReflectionCoverage();
    testSourceFiles();
    testBundle();
    testPlugin();

    console.log('\n=====================================================');
    console.log(`TOTAL TESTS: ${passedTests + failedTests}`);
    console.log(`PASSED: ${passedTests}`);
    console.log(`FAILED: ${failedTests}`);
    console.log('=====================================================');

    if (failedTests > 0) {
        process.exit(1);
    }
}

runAll();
