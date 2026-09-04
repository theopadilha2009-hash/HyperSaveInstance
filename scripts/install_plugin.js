#!/usr/bin/env node

/**
 * HyperSaveInstance - Roblox Studio Plugin Auto-Installer for macOS & Windows
 * Automatically detects and copies the plugin to the local Roblox Studio plugins folder.
 */

const fs = require("fs");
const path = require("path");
const os = require("os");

const homeDir = os.homedir();
const pluginSource = path.resolve(__dirname, "..", "plugin", "HyperSaveImporter.server.luau");

if (!fs.existsSync(pluginSource)) {
  console.error("❌ Arquivo do plugin não encontrado:", pluginSource);
  process.exit(1);
}

// Only the paths that belong to the current platform. Iterating over all of
// them used to create the Windows directory (~/AppData/Local/Roblox/Plugins) on
// macOS and then report a successful install into that empty folder.
function candidatePaths() {
  if (process.platform === "darwin") {
    return [
      path.join(homeDir, "Documents", "Roblox", "Plugins"),
      path.join(homeDir, "Library", "Application Support", "Roblox", "Plugins"),
    ];
  }
  if (process.platform === "win32") {
    return [
      process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, "Roblox", "Plugins") : null,
      path.join(homeDir, "AppData", "Local", "Roblox", "Plugins"),
      path.join(homeDir, "Documents", "Roblox", "Plugins"),
    ].filter(Boolean);
  }
  return [path.join(homeDir, "Documents", "Roblox", "Plugins")];
}

const candidateDirs = candidatePaths();

let installedCount = 0;

console.log("\n=======================================================");
console.log("  ⚡ INSTALADOR DO PLUGIN HYPERSAVE SUITE (ROBLOX STUDIO)");
console.log("=======================================================");

// Install only where Roblox Studio already keeps its plugins. Creating the
// directory ourselves would just scatter empty folders around the home dir.
const existingDirs = candidateDirs.filter((dir) => fs.existsSync(dir));

if (existingDirs.length === 0) {
  console.error("❌ Nenhuma pasta de plugins do Roblox Studio encontrada. Procurei em:");
  for (const dir of candidateDirs) console.error(`     ${dir}`);
  console.error("\n👉 Abra o Studio uma vez (aba Plugins > Plugins Folder) e rode de novo.");
  process.exit(1);
}

for (const dir of existingDirs) {
  const targetFile = path.join(dir, "HyperSaveImporter.server.luau");
  try {
    fs.copyFileSync(pluginSource, targetFile);
    console.log(`  ✓ Instalado em: ${targetFile}`);
    installedCount++;
  } catch (err) {
    console.error(`  ✗ Falhou em ${targetFile}: ${err.message}`);
  }
}

if (installedCount > 0) {
  console.log("\n✨ SUCESSO! O Plugin foi instalado.");
  console.log("👉 Abra o Roblox Studio e clique na aba 'Plugins' para usá-lo.\n");
} else {
  console.error("❌ Não foi possível instalar o plugin automaticamente.");
  process.exit(1);
}
