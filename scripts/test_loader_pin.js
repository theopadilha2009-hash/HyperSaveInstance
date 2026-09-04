/**
 * Verifies the loader integrity check actually works.
 *
 * The checksum in loader.luau is computed in Luau at load time and in JS at
 * pin time. If those two implementations ever disagree, the loader rejects
 * every valid bundle and nobody can run the tool — and nothing else in the
 * suite would catch it, because the two halves live in different languages.
 */

const fs = require('fs');
const path = require('path');
const { lua, lauxlib, lualib, to_luastring } = require('fengari');

function adler32JS(buf) {
    let a = 1, b = 0;
    for (let i = 0; i < buf.length; i++) { a = (a + buf[i]) % 65521; b = (b + a) % 65521; }
    return { a, b };
}

const loaderSrc = fs.readFileSync(path.join(__dirname, '..', 'loader.luau'), 'utf8');
const m = loaderSrc.match(/local function adler32\(data: string\): \(number, number\)([\s\S]*?)\nend\n/);
if (!m) { console.error('FALHA: nao achei adler32 no loader.luau'); process.exit(1); }
const luaFn = ('local function adler32(data)' + m[1] + '\nend\nreturn adler32');

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
if (lauxlib.luaL_dostring(L, to_luastring(luaFn)) !== lua.LUA_OK) {
    console.error('FALHA ao compilar:', lua.lua_tojsstring(L, -1)); process.exit(1);
}

const cases = [
    ['vazio', Buffer.from('')], ['1 char', Buffer.from('a')], ['abc', Buffer.from('abc')],
    ['borda 255', Buffer.from('x'.repeat(255))],
    ['borda 256', Buffer.from('y'.repeat(256))],
    ['borda 257', Buffer.from('z'.repeat(257))],
    ['5000 bytes', Buffer.from('bloco'.repeat(1000))],
    ['bytes altos', Buffer.from(Array.from({length: 1000}, (_, i) => i % 256))],
    ['bundle real', fs.readFileSync(path.join(__dirname, '..', 'dist', 'HyperSaveInstance.luau'))],
];

let allMatch = true;
for (const [label, buf] of cases) {
    lua.lua_pushvalue(L, -1);
    lua.lua_pushstring(L, buf);
    if (lua.lua_pcall(L, 1, 2, 0) !== lua.LUA_OK) {
        console.error('erro:', lua.lua_tojsstring(L, -1)); process.exit(1);
    }
    const luaB = lua.lua_tonumber(L, -1), luaA = lua.lua_tonumber(L, -2);
    lua.lua_pop(L, 2);
    const js = adler32JS(buf);
    const ok = luaA === js.a && luaB === js.b;
    if (!ok) allMatch = false;
    console.log(`  ${ok ? 'OK  ' : 'DIVERGE'} ${label.padEnd(14)} luau=${luaA}/${luaB}  js=${js.a}/${js.b}`);
}

// truncamento de 1 byte tem que ser detectado
const full = fs.readFileSync(path.join(__dirname, '..', 'dist', 'HyperSaveInstance.luau'));
const trunc = adler32JS(full.subarray(0, full.length - 1));
const fullSum = adler32JS(full);
const detects = trunc.a !== fullSum.a || trunc.b !== fullSum.b;
console.log(`  ${detects ? 'OK  ' : 'FALHA '} truncamento de 1 byte e detectado`);

console.log(allMatch && detects ? '\nRESULTADO: paridade Luau/JS confirmada em todos os casos' : '\nRESULTADO: FALHOU');
process.exit(allMatch && detects ? 0 : 1);
