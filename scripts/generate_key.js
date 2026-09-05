/**
 * HyperSaveInstance - Official CLI License Key Generator
 * Usage: node scripts/generate_key.js [enterprise|pro] [client_name]
 * Example: node scripts/generate_key.js enterprise "Lucas_VIP"
 */

function generateLicenseKey(tier = 'enterprise', clientName = 'VIP Client') {
    const cleanTier = tier.toLowerCase();
    const seed = Date.now() + Math.floor(Math.random() * 100000);
    
    const n1 = (seed % 60000) + 1000;
    const n2 = ((seed * 17) % 60000) + 1000;

    let key = '';
    let tierName = 'Enterprise Lifetime ($570 / R$ 2.900)';

    if (cleanTier === 'enterprise' || cleanTier === 'ent') {
        const n3 = (n1 * 3 + n2 * 7) % 65535;
        const p1 = n1.toString(16).toUpperCase().padStart(4, '0');
        const p2 = n2.toString(16).toUpperCase().padStart(4, '0');
        const p3 = n3.toString(16).toUpperCase().padStart(4, '0');
        key = `THEO-ENT-${p1}-${p2}-${p3}`;
        tierName = '👑 Enterprise Edition (Lifetime VIP)';
    } else if (cleanTier === 'pro') {
        const k2 = (n1 * 13) % 65535;
        const p1 = n1.toString(16).toUpperCase().padStart(4, '0');
        const p2 = k2.toString(16).toUpperCase().padStart(4, '0');
        key = `THEO-PRO-${p1}-${p2}`;
        tierName = '⚡ Pro Personal Edition (Lifetime)';
    } else {
        console.error('[!] Invalid tier. Use: "enterprise" or "pro"');
        process.exit(1);
    }

    const dateStr = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');

    const deliveryCard = `
================================================================================
 👑 THEO DEV HUB // OFFICIAL LICENSE DELIVERY CARD
================================================================================
 Customer Name: ${clientName}
 License Tier:  ${tierName}
 Issued At:     ${dateStr} UTC
 License Key:   👉 ${key} 👈

--------------------------------------------------------------------------------
 ⚡ INSTRUCTIONS FOR THE CLIENT (HOW TO ACTIVATE):
 1. Execute HyperSaveInstance in your Roblox executor (Delta / Codex):
    loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/Loader.luau", true))()

 2. Click the [ 🔑 FREE // UNLOCK VIP ] badge at the top-right of the window.
 3. Paste your key: ${key}
 4. Click [ ⚡ ACTIVATE KEY ]!
 
 All enterprise features (unthrottled decompiler, raw asset ripper, 
 AST mock engine, and Web 3D exporter) are now permanently unlocked!
================================================================================
`;

    console.log(deliveryCard);
    return key;
}

const args = process.argv.slice(2);
const tier = args[0] || 'enterprise';
const client = args[1] || 'VIP Member';

generateLicenseKey(tier, client);
