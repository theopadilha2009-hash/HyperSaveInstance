#!/usr/bin/env node

/**
 * HyperSaveInstance - Roblox Studio Plugin Auto-Installer for macOS & Windows
 * Automatically copies the plugin to the local Roblox Studio plugins folder.
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

// Possible Roblox Studio Plugins directory paths
const candidateDirs = [
  path.join(homeDir, "Documents", "Roblox", "Plugins"),
  path.join(homeDir, "Library", "Application Support", "Roblox", "Plugins"),
  path.join(homeDir, "AppData", "Local", "Roblox", "Plugins"),
];

let targetDir = candidateDirs[0]; // Default: ~/Documents/Roblox/Plugins

try {
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }

  const targetFile = path.join(targetDir, "HyperSaveImporter.server.luau");
  fs.copyFileSync(pluginSource, targetFile);

  console.log("\n=======================================================");
  console.log("  ⚡ PLUGIN HYPERSAVE SUITE INSTALADO COM SUCESSO!");
  console.log("=======================================================");
  console.log(`📁 Local de instalação: ${targetFile}`);
  console.log("👉 Agora basta abrir o Roblox Studio! O plugin já aparecerá na aba 'Plugins'.\n");
} catch (err) {
  console.error("❌ Falha ao instalar plugin:", err.message);
  process.exit(1);
}
