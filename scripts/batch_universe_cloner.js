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

function fetchJson(url, timeoutMs = 12000) {
    return new Promise((resolve, reject) => {
        const req = https.get(url, {
            headers: { 'Accept': 'application/json' }
        }, (res) => {
            // Without this, a 403/429/HTML error page was parsed as if it were a
            // successful response and the caller treated the failure as "0 results".
            if (res.statusCode < 200 || res.statusCode >= 300) {
                res.resume();
                reject(new Error(`HTTP ${res.statusCode} from ${url}`));
                return;
            }
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    reject(new Error(`Failed to parse JSON from ${url}: ${e.message}`));
                }
            });
        });
        req.setTimeout(timeoutMs, () => {
            req.destroy(new Error(`Timed out after ${timeoutMs}ms: ${url}`));
        });
        req.on('error', reject);
    });
}

// Returns { universeId, resolved } so the caller can tell a real lookup from
// the fallback. The empty catch used to make an unresolved id look identical to
// a resolved one in the output.
async function resolveUniverseId(id) {
    try {
        const res = await fetchJson(`https://apis.roblox.com/universes/v1/places/${id}/universe`);
        if (res && res.universeId) {
            return { universeId: res.universeId, resolved: true };
        }
        return { universeId: id, resolved: false, reason: 'response had no universeId' };
    } catch (e) {
        return { universeId: id, resolved: false, reason: e.message };
    }
}

async function main() {
    console.log(`\n[HyperSave Universe] Resolving Universe ID for: ${targetId}...`);
    const { universeId, resolved, reason } = await resolveUniverseId(targetId);
    if (resolved) {
        console.log(`[HyperSave Universe] Universe ID identified: ${universeId}`);
    } else {
        console.warn(`[HyperSave Universe] Could not resolve a universe for ${targetId} (${reason}); trying it as a universe id directly.`);
    }

    console.log(`[HyperSave Universe] Fetching place list from Roblox Universe API...`);
    let allPlaces = [];
    let cursor = '';
    let incomplete = false;

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
            // Failing on the first page means we have nothing; failing later
            // means the list is incomplete. Reporting either as success is how
            // "0 sub-places" used to look identical to a genuinely empty universe.
            if (allPlaces.length === 0) {
                throw new Error(`Could not list places for universe ${universeId}: ${e.message}`);
            }
            console.error(`[Warning] Page fetch failed after ${allPlaces.length} places, list is incomplete: ${e.message}`);
            incomplete = true;
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

    if (allPlaces.length === 0) {
        throw new Error(`No places found for ${targetId}. Nothing was written.`);
    }

    if (incomplete) {
        outputBatch.Incomplete = true;
    }

    const outPath = path.join(process.cwd(), `HyperSave_Universe_${universeId}.json`);
    fs.writeFileSync(outPath, JSON.stringify(outputBatch, null, 2), 'utf8');
    console.log(`\n[✓ Saved] Batch Universe Job File saved to: ${outPath}\n`);
}

main().catch(err => {
    console.error(`[Fatal Error] ${err.message}`);
    process.exit(1);
});
