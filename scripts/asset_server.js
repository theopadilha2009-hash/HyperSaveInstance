/**
 * HyperSaveInstance - Local Asset WebServer
 * Serves downloaded assets (textures, audio, meshes, manifests) over a local HTTP server
 * with full CORS headers so Roblox Studio plugins and standalone HTML 3D viewers can load them.
 * 
 * Usage:
 *   node scripts/asset_server.js [port] [assets_dir]
 * 
 * Example:
 *   node scripts/asset_server.js 8080 ./HyperSave_Assets
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = parseInt(process.argv[2] || '8080', 10);
const ASSETS_DIR = path.resolve(process.argv[3] || './HyperSave_Assets');

const MIME_TYPES = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.webp': 'image/webp',
    '.mp3': 'audio/mpeg',
    '.ogg': 'audio/ogg',
    '.wav': 'audio/wav',
    '.obj': 'text/plain',
    '.mtl': 'text/plain',
    '.json': 'application/json',
    '.html': 'text/html',
    '.rbxm': 'application/octet-stream',
    '.rbxlx': 'application/xml',
    '.txt': 'text/plain'
};

if (!fs.existsSync(ASSETS_DIR)) {
    try {
        fs.mkdirSync(ASSETS_DIR, { recursive: true });
    } catch (err) {
        console.error(`[AssetServer] Could not create directory: ${ASSETS_DIR}`, err.message);
    }
}

const server = http.createServer((req, res) => {
    // CORS headers to permit Roblox Studio, Three.js viewers & web browsers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Range');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const parsedUrl = new URL(req.url, `http://localhost:${PORT}`);
    let pathname = decodeURIComponent(parsedUrl.pathname);

    // Root index listing
    if (pathname === '/' || pathname === '') {
        fs.readdir(ASSETS_DIR, (err, files) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('Error reading asset directory: ' + err.message);
                return;
            }

            const fileListHtml = (files || [])
                .map(f => `<li><a href="/${encodeURIComponent(f)}">${f}</a></li>`)
                .join('\n');

            const html = `<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>HyperSaveInstance - Local Asset Server</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0F1117; color: #FFFFFF; padding: 24px; }
        h1 { color: #3B82F6; font-size: 20px; }
        p { color: #94A3B8; font-size: 13px; }
        ul { list-style: none; padding: 0; }
        li { padding: 8px 12px; margin: 4px 0; background: #181B24; border: 1px solid #303646; border-radius: 6px; }
        a { color: #60A5FA; text-decoration: none; font-family: monospace; }
        a:hover { text-decoration: underline; color: #93C5FD; }
    </style>
</head>
<body>
    <h1>⚡ HyperSaveInstance - Servidor Local de Assets</h1>
    <p>Diretório: <code>${ASSETS_DIR}</code> | Porta: <code>${PORT}</code></p>
    <p>Total de arquivos disponíveis: <strong>${(files || []).length}</strong></p>
    <ul>
        ${fileListHtml || '<li><em>Nenhum arquivo no diretório ainda.</em></li>'}
    </ul>
</body>
</html>`;
            res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
            res.end(html);
        });
        return;
    }

    const safePath = path.normalize(pathname).replace(/^(\.\.[\/\\])+/, '');
    const filePath = path.join(ASSETS_DIR, safePath);

    fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Asset not found: ' + pathname);
            return;
        }

        const ext = path.extname(filePath).toLowerCase();
        const contentType = MIME_TYPES[ext] || 'application/octet-stream';

        res.writeHead(200, {
            'Content-Type': contentType,
            'Content-Length': stats.size,
            'Cache-Control': 'public, max-age=3600'
        });

        const readStream = fs.createReadStream(filePath);
        readStream.pipe(res);
    });
});

server.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(` ⚡ HYPERSAVEINSTANCE - LOCAL ASSET SERVER ACTIVE `);
    console.log(`=======================================================`);
    console.log(` Local URL : http://localhost:${PORT}/`);
    console.log(` Assets Dir: ${ASSETS_DIR}`);
    console.log(` Status    : Pronto para servir texturas, áudios e meshes.`);
    console.log(`=======================================================`);
});
