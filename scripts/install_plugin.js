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

// Possible Roblox Studio Plugins directory paths for macOS & Windows
const candidateDirs = [
  path.join(homeDir, "Documents", "Roblox", "Plugins"),
  path.join(homeDir, "Library", "Application Support", "Roblox", "Plugins"),
  path.join(homeDir, "AppData", "Local", "Roblox", "Plugins"),
  process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, "Roblox", "Plugins") : null,
].filter(Boolean);

let installedCount = 0;

console.log("\n=======================================================");
console.log("  ⚡ INSTALADOR DO PLUGIN HYPERSAVE SUITE (ROBLOX STUDIO)");
console.log("=======================================================");

for (const dir of candidateDirs) {
  try {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    const targetFile = path.join(dir, "HyperSaveImporter.server.luau");
    fs.copyFileSync(pluginSource, targetFile);
    console.log(`  ✓ Instalado em: ${targetFile}`);
    installedCount++;
  } catch (err) {
    // Ignore permissions on non-matching platform paths
  }
}

if (installedCount > 0) {
  console.log("\n✨ SUCESSO! O Plugin foi instalado.");
  console.log("👉 Abra o Roblox Studio e clique na aba 'Plugins' para usá-lo.\n");
} else {
  console.error("❌ Não foi possível instalar o plugin automaticamente.");
  process.exit(1);
}
