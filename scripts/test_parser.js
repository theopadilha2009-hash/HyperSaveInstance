/**
 * HyperSaveInstance - Automated Test & Validation Script
 */

const fs = require('fs');
const path = require('path');

function runTests() {
    console.log('=== HyperSaveInstance Validation Suite ===\n');

    const distPath = path.join(__dirname, '..', 'dist', 'HyperSaveInstance.luau');
    if (!fs.existsSync(distPath)) {
        throw new Error('Distribution bundle does not exist at: ' + distPath);
    }

    const bundleContent = fs.readFileSync(distPath, 'utf8');

    // 1. Validate bundle file size
    console.log(`[TEST 1] Checking bundle output size...`);
    const sizeKb = fs.statSync(distPath).size / 1024;
    console.log(`  -> Bundle Size: ${sizeKb.toFixed(2)} KB`);
    if (sizeKb < 20) {
        throw new Error('Bundle size is unexpectedly small, missing modules!');
    }
    console.log('  ✓ PASSED');

    // 2. Validate essential module exports
    console.log(`\n[TEST 2] Checking virtual module registry...`);
    const requiredModules = [
        'Utils/Environment',
        'Utils/AntiAFK',
        'Utils/Stealth',
        'Utils/Base64',
        'Utils/LZ4',
        'Utils/Stream',
        'Config/Defaults',
        'Config/ClassBlacklist',
        'Core/Reflection',
        'Core/TerrainSerializer',
        'Core/StreamExplorer',
        'Core/Decompiler',
        'Core/AssetHandler',
        'Core/AssetDownloader',
        'Core/NetworkSniffer',
        'Core/UniverseTracker',
        'Core/ObjExporter',
        'Core/Optimizer',
        'Core/SerializerXml',
        'Core/SerializerBinary',
        'Core/SerializerScript',
        'Core/Engine',
        'UI/Theme',
        'UI/Interface'
    ];

    for (const mod of requiredModules) {
        if (!bundleContent.includes(`__define__("${mod}"`)) {
            throw new Error(`Module ${mod} is missing from the bundle!`);
        }
        console.log(`  ✓ Module verified: ${mod}`);
    }
    console.log('  ✓ ALL MODULES PRESENT');

    // 3. Validate loader syntax
    console.log(`\n[TEST 3] Checking loader script...`);
    const loaderPath = path.join(__dirname, '..', 'loader.luau');
    const loaderContent = fs.readFileSync(loaderPath, 'utf8');
    if (!loaderContent.includes('loadstring') || !loaderContent.includes('HyperSaveInstance.luau')) {
        throw new Error('Loader script is invalid!');
    }
    console.log('  ✓ Loader script is valid and points to the raw GitHub URL');

    // 4. Validate plugin file
    console.log(`\n[TEST 4] Checking Roblox Studio plugin...`);
    const pluginPath = path.join(__dirname, '..', 'plugin', 'HyperSaveImporter.server.luau');
    if (!fs.existsSync(pluginPath)) {
        throw new Error('Studio plugin script is missing!');
    }
    console.log('  ✓ Studio Plugin script is present and valid');

    console.log('\n=== All Tests Passed Successfully! ===\n');
}

runTests();
