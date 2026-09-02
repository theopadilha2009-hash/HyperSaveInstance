/**
 * HyperSaveInstance - Multi-Place Universe Discovery & Batch Exporter
 * Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
 * 
 * Fetches all sub-places belonging to a Roblox Universe using public APIs
 * and generates batch download manifests / scripts for every sub-place in the universe.
 * 
 * Usage:
 *   node scripts/batch_universe_cloner.js <UniverseId_or_PlaceId>
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const targetId = process.argv[2];

if (!targetId) {
    console.log(`
=============================================================================
 ⚡ HyperSaveInstance - Universe & Multi-Place Batch Crawler
 Author: Theo Lorentz Padilha
=============================================================================
Usage:
  node scripts/batch_universe_cloner.js <PlaceId_or_UniverseId>

Examples:
  node scripts/batch_universe_cloner.js 1537690962
=============================================================================
`);
    process.exit(0);
}

function fetchJson(url) {
    return new Promise((resolve, reject) => {
        https.get(url, {
            headers: {
                'User-Agent': 'Roblox/WinInet',
                'Accept': 'application/json'
            }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    reject(new Error(`Failed to parse JSON from ${url}: ${e.message}`));
                }
            });
        }).on('error', reject);
    });
}

async function resolveUniverseId(id) {
    try {
        const res = await fetchJson(`https://apis.roblox.com/universes/v1/places/${id}/universe`);
        if (res && res.universeId) {
            return res.universeId;
        }
    } catch (e) {}
    return id;
}

async function main() {
    console.log(`\n[HyperSave Universe] Resolving Universe ID for: ${targetId}...`);
    const universeId = await resolveUniverseId(targetId);
    console.log(`[HyperSave Universe] Universe ID identified: ${universeId}`);

    console.log(`[HyperSave Universe] Fetching place list from Roblox Universe API...`);
    let allPlaces = [];
    let cursor = '';

    do {
        const url = `https://develop.roblox.com/v1/universes/${universeId}/places?isUniverseCreation=false&limit=100${cursor ? `&cursor=${cursor}` : ''}`;
        try {
            const data = await fetchJson(url);
            if (data && data.data) {
                allPlaces = allPlaces.concat(data.data);
                cursor = data.nextPageCursor || '';
            } else {
                break;
            }
        } catch (e) {
            console.error(`[Error] API call failed: ${e.message}`);
            break;
        }
    } while (cursor);

    console.log(`\n=============================================================`);
    console.log(` UNIVERSE DISCOVERY COMPLETE`);
    console.log(` Total Sub-Places Found: ${allPlaces.length}`);
    console.log(`=============================================================\n`);

    allPlaces.forEach((p, idx) => {
        console.log(` [${idx + 1}] Place ID: ${p.id} | Name: "${p.name}"`);
    });

    const outputBatch = {
        UniverseId: universeId,
        RootId: targetId,
        TotalPlaces: allPlaces.length,
        ScannedAt: new Date().toISOString(),
        Places: allPlaces.map(p => ({
            Id: p.id,
            Name: p.name,
            Description: p.description || '',
            LoaderCommand: `getgenv().HyperSave_Silent=true; loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))().SaveOnlyMap()`
        }))
    };

    const outPath = path.join(process.cwd(), `HyperSave_Universe_${universeId}.json`);
    fs.writeFileSync(outPath, JSON.stringify(outputBatch, null, 2), 'utf8');
    console.log(`\n[✓ Saved] Batch Universe Job File saved to: ${outPath}\n`);
}

main().catch(err => {
    console.error(`[Fatal Error] ${err.message}`);
});
