/**
 * HyperSaveInstance - Offline Asset Manifest Downloader (Node.js)
 * Downloads all extracted assets from a HyperSave_Manifest JSON file outside of the Roblox client.
 * Safe, fast, multi-threaded, with zero in-game network packets or rate limit risk.
 *
 * Usage:
 *   node scripts/download_manifest.js path/to/HyperSave_Manifest_12345.json [outputFolder]
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const manifestPath = process.argv[2];
const customOutputDir = process.argv[3];

if (!manifestPath) {
    console.log('Usage: node scripts/download_manifest.js <manifest.json> [output_dir]');
    process.exit(0);
}

if (!fs.existsSync(manifestPath)) {
    console.error(`Error: Manifest file not found at: ${manifestPath}`);
    process.exit(1);
}

const rawData = fs.readFileSync(manifestPath, 'utf8');
let manifest;
try {
    manifest = JSON.parse(rawData);
} catch (e) {
    console.error(`Error: Invalid JSON in manifest: ${e.message}`);
    process.exit(1);
}

const baseDir = customOutputDir || path.join(path.dirname(manifestPath), `HyperSave_Assets_${manifest.PlaceId || 'Offline'}`);

const dirs = ['audios', 'textures', 'meshes', 'animations'];
dirs.forEach(d => {
    const fullDir = path.join(baseDir, d);
    if (!fs.existsSync(fullDir)) {
        fs.mkdirSync(fullDir, { recursive: true });
    }
});

const assets = manifest.Assets || [];
console.log(`\n=============================================================`);
console.log(` HyperSaveInstance - Offline Asset Downloader`);
console.log(` Place ID: ${manifest.PlaceId || 'N/A'} | Total Assets: ${assets.length}`);
console.log(` Output Directory: ${baseDir}`);
console.log(`=============================================================\n`);

function resolveAssetUrl(rawUrl, id) {
    if (!rawUrl || rawUrl.length === 0) {
        if (id) return `https://assetdelivery.roblox.com/v1/asset/?id=${id}`;
        return null;
    }
    if (rawUrl.startsWith('rbxassetid://')) {
        const numId = rawUrl.replace('rbxassetid://', '');
        return `https://assetdelivery.roblox.com/v1/asset/?id=${numId}`;
    }
    if (/^\d+$/.test(rawUrl)) {
        return `https://assetdelivery.roblox.com/v1/asset/?id=${rawUrl}`;
    }
    return rawUrl;
}

function downloadFile(url, dest, retries = 2) {
    return new Promise((resolve) => {
        if (fs.existsSync(dest) && fs.statSync(dest).size > 0) {
            return resolve({ success: true, skipped: true });
        }

        const effectiveUrl = resolveAssetUrl(url);
        if (!effectiveUrl) {
            return resolve({ success: false, error: 'Invalid URL' });
        }

        const file = fs.createWriteStream(dest);
        const req = https.get(effectiveUrl, {
            headers: {
                'User-Agent': 'Roblox/WinInet',
            }
        }, (res) => {
            if (res.statusCode === 200) {
                res.pipe(file);
                file.on('finish', () => {
                    file.close();
                    resolve({ success: true });
                });
            } else if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                file.close();
                if (fs.existsSync(dest)) fs.unlinkSync(dest);
                downloadFile(res.headers.location, dest, retries).then(resolve);
            } else {
                file.close();
                if (fs.existsSync(dest)) fs.unlinkSync(dest);
                if (retries > 0) {
                    setTimeout(() => {
                        downloadFile(url, dest, retries - 1).then(resolve);
                    }, 500);
                } else {
                    resolve({ success: false, status: res.statusCode });
                }
            }
        });

        req.on('error', (err) => {
            file.close();
            if (fs.existsSync(dest)) fs.unlinkSync(dest);
            if (retries > 0) {
                setTimeout(() => {
                    downloadFile(url, dest, retries - 1).then(resolve);
                }, 500);
            } else {
                resolve({ success: false, error: err.message });
            }
        });

        req.setTimeout(12000, () => {
            req.destroy();
            file.close();
            if (fs.existsSync(dest)) fs.unlinkSync(dest);
            if (retries > 0) {
                setTimeout(() => {
                    downloadFile(url, dest, retries - 1).then(resolve);
                }, 500);
            } else {
                resolve({ success: false, error: 'Timeout' });
            }
        });
    });
}

async function runPool(concurrency = 8) {
    let completed = 0;
    let failed = 0;
    let index = 0;

    async function worker() {
        while (index < assets.length) {
            const item = assets[index++];
            let ext = '.dat';
            let sub = 'textures';

            if (item.Type === 'Audio') { ext = '.mp3'; sub = 'audios'; }
            else if (item.Type === 'Texture') { ext = '.png'; sub = 'textures'; }
            else if (item.Type === 'Mesh') { ext = '.mesh'; sub = 'meshes'; }
            else if (item.Type === 'Animation') { ext = '.rbxanim'; sub = 'animations'; }

            const cleanName = (item.SourceName || 'asset').replace(/[^a-zA-Z0-9_\-]/g, '_');
            const dest = path.join(baseDir, sub, `${item.Id}_${cleanName}${ext}`);

            const targetUrl = item.Url || resolveAssetUrl(null, item.Id);
            const res = await downloadFile(targetUrl, dest);
            if (res.success) {
                completed++;
            } else {
                failed++;
            }

            const pct = Math.floor(((completed + failed) / assets.length) * 100);
            process.stdout.write(`\r[Download Progress] ${completed + failed}/${assets.length} (${pct}%) | Baixados: ${completed} | Falhas: ${failed}`);
        }
    }

    const workers = Array(concurrency).fill(null).map(() => worker());
    await Promise.all(workers);

    console.log(`\n\n[✓ Done] Concluído download de ${completed} assets (${failed} falhas) para: ${baseDir}\n`);
}

runPool(8);
