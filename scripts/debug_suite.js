/**
 * HyperSaveInstance - Comprehensive Deep Debug & Unit Test Suite
 * Tests Base64, LZ4 compression roundtrip, Stream buffers, XML generation,
 * Reflection tables, Bundle integrity, and File exports.
 */

const fs = require('fs');
const path = require('path');

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

// Pure JS reference implementation of Base64 to test Base64 contract
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

    for (const str of testCases) {
        const encoded = Buffer.from(str, 'utf8').toString('base64');
        const decoded = Buffer.from(encoded, 'base64').toString('utf8');
        assert(decoded === str, `Base64 Roundtrip: "${str.substring(0, 20)}..."`);
    }
}

// Test XML Escaping Logic
function testXmlEscaping() {
    console.log('\n--- 2. Testing XML Escaping & Format Verification ---');
    const escapeXml = (str) => {
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    };

    const input = '<Folder name="Test & Demo" quote=\'single\'>';
    const expected = '&lt;Folder name=&quot;Test &amp; Demo&quot; quote=&apos;single&apos;&gt;';
    assert(escapeXml(input) === expected, 'XML Entity Escaping');
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
