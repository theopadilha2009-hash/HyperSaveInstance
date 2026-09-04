/**
 * Pins loader.luau to the currently committed dist/HyperSaveInstance.luau and
 * copies the result to dist/Loader.luau.
 *
 * Run this AFTER committing the bundle, because the pin has to name a commit
 * that already contains it:
 *
 *   npm run build
 *   git add dist/HyperSaveInstance.luau && git commit -m "build: bundle"
 *   npm run pin:loader
 *   git add loader.luau dist/Loader.luau && git commit -m "build: pin loader"
 *
 * Usage: node scripts/update_loader_pin.js [--check]
 *   --check  exits non-zero if the pin is stale, without writing (for CI)
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const LOADER = path.join(ROOT, 'loader.luau');
const DIST_LOADER = path.join(ROOT, 'dist', 'Loader.luau');
const BUNDLE = path.join(ROOT, 'dist', 'HyperSaveInstance.luau');

const checkOnly = process.argv.includes('--check');

// Returns the two 16-bit halves separately; see the note in loader.luau.
function adler32(buf) {
    let a = 1;
    let b = 0;
    for (let i = 0; i < buf.length; i++) {
        a = (a + buf[i]) % 65521;
        b = (b + a) % 65521;
    }
    return { a, b };
}

function git(...args) {
    return execFileSync('git', args, { cwd: ROOT, encoding: 'utf8' }).trim();
}

function fail(message) {
    console.error(`[pin-loader] ${message}`);
    process.exit(1);
}

if (!fs.existsSync(BUNDLE)) {
    fail('dist/HyperSaveInstance.luau not found. Run `npm run build` first.');
}

// The pin must point at a commit whose dist matches the working tree, otherwise
// users would download a bundle different from the one that was tested.
let status;
try {
    status = git('status', '--porcelain', '--', 'dist/HyperSaveInstance.luau');
} catch (err) {
    fail(`git is required: ${err.message}`);
}
if (status) {
    fail('dist/HyperSaveInstance.luau has uncommitted changes. Commit the bundle before pinning.');
}

const commit = git('rev-parse', 'HEAD');
const bundle = fs.readFileSync(BUNDLE);
const { a: adlerA, b: adlerB } = adler32(bundle);
const bytes = bundle.length;

const current = fs.readFileSync(LOADER, 'utf8');
const pinned = current
    .replace(/local PINNED_COMMIT = "[^"]*"/, `local PINNED_COMMIT = "${commit}"`)
    .replace(/local EXPECTED_ADLER_A = \d+/, `local EXPECTED_ADLER_A = ${adlerA}`)
    .replace(/local EXPECTED_ADLER_B = \d+/, `local EXPECTED_ADLER_B = ${adlerB}`)
    .replace(/local EXPECTED_BYTES = \d+/, `local EXPECTED_BYTES = ${bytes}`);

if (!pinned.includes(commit) || !pinned.includes(`EXPECTED_ADLER_B = ${adlerB}`)) {
    fail('loader.luau does not contain the expected pin declarations.');
}

if (checkOnly) {
    const distLoader = fs.existsSync(DIST_LOADER) ? fs.readFileSync(DIST_LOADER, 'utf8') : '';
    if (current !== pinned) {
        fail(`loader.luau pin is stale. Expected commit ${commit.slice(0, 7)}, ${bytes} bytes, adler32 ${adlerA}/${adlerB}. Run \`npm run pin:loader\`.`);
    }
    if (distLoader !== pinned) {
        fail('dist/Loader.luau differs from loader.luau. Run `npm run pin:loader`.');
    }
    console.log(`[pin-loader] up to date (${commit.slice(0, 7)}, ${bytes} bytes, adler32 ${adlerA}/${adlerB})`);
    process.exit(0);
}

fs.writeFileSync(LOADER, pinned);
fs.writeFileSync(DIST_LOADER, pinned);

console.log(`[pin-loader] commit   ${commit}`);
console.log(`[pin-loader] bytes    ${bytes}`);
console.log(`[pin-loader] adler32  ${adlerA}/${adlerB}`);
console.log('[pin-loader] wrote loader.luau and dist/Loader.luau');
