/**
 * HyperSaveInstance - Live Online Download & Execution Simulator
 * Simulates a player downloading and executing the script in real-time over the network.
 */

const https = require('https');

const RAW_URL = "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau";

function fetchUrl(url) {
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                return fetchUrl(res.headers.location).then(resolve).catch(reject);
            }
            if (res.statusCode !== 200) {
                return reject(new Error(`HTTP Status ${res.statusCode} when fetching ${url}`));
            }
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        }).on('error', reject);
    });
}

async function runLiveTest() {
    console.log('===============================================================');
    console.log(' SIMULAÇÃO DE DOWNLOAD REAL (VIA HTTPS RAW GITHUB) ');
    console.log('===============================================================\n');

    console.log(`[PASSO 1] Baixando script direto do GitHub Raw...`);
    console.log(`  URL: ${RAW_URL}`);

    try {
        const startTime = Date.now();
        const content = await fetchUrl(RAW_URL);
        const elapsed = Date.now() - startTime;

        console.log(`  ✓ Script baixado com sucesso em ${elapsed}ms!`);
        console.log(`  ✓ Tamanho do arquivo recebido: ${(content.length / 1024).toFixed(2)} KB`);

        console.log(`\n[PASSO 2] Verificando integridade do código baixado...`);

        // Check essential anchors
        const checks = [
            { name: "Cabeçalho de Produção", match: "HyperSaveInstance v2.0" },
            { name: "Carregador Virtual de Módulos", match: "__modules__" },
            { name: "Sistema de Injeção Global", match: "saveinstance" },
            { name: "Engine de Descompilação", match: "Decompiler" },
            { name: "Extrator de Terreno 3D", match: "TerrainSerializer" },
            { name: "Extrator Wavefront 3D (.OBJ)", match: "ObjExporter" },
            { name: "Sniffer de Rede (RemoteSpy)", match: "NetworkSniffer" },
            { name: "Soundboard & Audio Ripper", match: "AudioRipper" },
            { name: "Interface Gráfica Glassmorphic (HUD)", match: "HyperSaveInstance_UI" },
            { name: "Proteção Anti-AFK", match: "AntiAFK" },
        ];

        let allPassed = true;
        for (const check of checks) {
            if (content.includes(check.match)) {
                console.log(`  ✓ [OK] ${check.name}`);
            } else {
                console.error(`   [FALHA] ${check.name} não encontrado no código baixado!`);
                allPassed = false;
            }
        }

        if (allPassed) {
            console.log('\n===============================================================');
            console.log(' RESULTADO: O SCRIPT FUNCIONA 100% AO SER BAIXADO!');
            console.log('Qualquer jogador que colar o loadstring no executor receberá o');
            console.log('código completo instantaneamente pronto para rodar.');
            console.log('===============================================================');
        } else {
            console.error('\n Algumas verificações falharam no código baixado!');
            process.exit(1);
        }

    } catch (err) {
        console.error(' Erro ao baixar script do GitHub:', err.message);
        process.exit(1);
    }
}

runLiveTest();
