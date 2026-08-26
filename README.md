<div align="center">

# ⚡ HyperSaveInstance v2.0 (Ultimate Master Suite)
### The Definitive, All-in-One Universal Roblox Game Cloner, Asset Ripper & Reverse-Engineering Suite

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg?style=for-the-badge)](https://github.com/theopadilha2009-hash/HyperSaveInstance)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg?style=for-the-badge)](https://github.com/theopadilha2009-hash/HyperSaveInstance)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Mobile-orange.svg?style=for-the-badge)](https://github.com/theopadilha2009-hash/HyperSaveInstance)
[![License](https://img.shields.io/badge/license-MIT-purple.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>HyperSaveInstance</b> combines the best architectures of <b>UniversalSynSaveInstance (USSI)</b>, <b>UltraSmartSaveInstance</b>, <b>rbx-dom</b>, and <b>rbx-instance-serializer</b> into a single, high-performance, cross-platform tool.
</p>

```lua
-- 🚀 1-Click Execution (Paste into any Roblox Executor):
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
```

</div>

---

## 💎 Master Suite Features

| Feature | Legacy Synapse | USSI Standard | UltraSmart | **HyperSaveInstance v2.0** |
| :--- | :---: | :---: | :---: | :---: |
| **In-Game GUI (1-Click HUD)** | ❌ | ❌ | ⚠️ Basic | ✅ **Modern Glassmorphic Dark UI** |
| **Visual Fidelity** | 6/10 | 9/10 | 9/10 | ✅ **10/10 (Full Terrain, PBR, Lighting, CSG)** |
| **Script Decompiler Engine** | ⚠️ Slow | ⚠️ Single-thread | ⚠️ Basic | ✅ **Multi-Worker Pool with Auto-Retry** |
| **Raw Asset Downloader** | ❌ No | ❌ No | ❌ No | ✅ **Downloads .mp3, .png, .mesh to local folder** |
| **In-Game Audio Player / Ripper** | ❌ No | ❌ No | ❌ No | ✅ **Soundboard preview + 1-Click ID Copy** |
| **Lighting & Skybox Ripper** | ❌ No | ❌ No | ❌ No | ✅ **Extracts Atmosphere & Sky to .rbxmx** |
| **GUI & HUD Ripper** | ❌ No | ❌ No | ❌ No | ✅ **Extracts all ScreenGuis / Menus to .rbxmx** |
| **Official Roblox Studio Plugin** | ❌ No | ❌ No | ❌ No | ✅ **1-Click Import & Rebuild Toolbar Plugin** |
| **Live Network Sniffer (RemoteSpy)** | ❌ No | ❌ No | ❌ No | ✅ **Logs RemoteEvents / Functions + Exports JSON** |
| **3D Wavefront Exporter (.OBJ / .MTL)** | ❌ No | ❌ No | ❌ No | ✅ **Export to Blender, Unity & Unreal** |
| **Multi-Place Universe Tracker** | ❌ No | ❌ No | ❌ No | ✅ **Lists & clones all sub-places in universe** |
| **Anti-AFK & Anti-Kick Protection** | ❌ No | ❌ No | ❌ No | ✅ **Prevents 20-min idle disconnection (268/273)** |
| **Bypass StreamingEnabled** | ❌ No | ❌ No | ⚠️ Partial | ✅ **Auto-Map Spatial Grid Sweeper** |
| **Keybind HUD Toggle** | ❌ No | ❌ No | ❌ No | ✅ **[RightShift] Instant Show / Hide** |
| **Supported File Formats** | `.rbxlx` | `.rbxlx` | `.rbxlx` | ✅ **`.rbxlx` (XML), `.rbxl` (Binary), `.lua`, `.obj`** |
| **Cross-Platform Compatibility** | ❌ Windows | ⚠️ Windows | ⚠️ Windows | ✅ **macOS, Windows & Mobile** |

---

## 🌟 Complete Feature Breakdown

### 🚀 1. 1-Click Game Cloner (Dashboard)
- Keep it dead simple! Open the menu and click **`🚀 CLONAR JOGO INTEIRO (1-CLIQUE)`** to save everything (Terrain Voxels, Models, Lighting, Scripts, UI, Attributes, Tags) to an `.rbxlx` file.

### 🎵 2. In-Game Soundboard & Audio Ripper
- Browse, listen to, and preview all sound effects, songs, and voice tracks with in-game Play/Stop buttons.
- Copy any Sound ID with 1 click or export the entire soundtrack list to `.txt`.

### 💡 3. Lighting & Atmosphere Ripper
- Extract 4K Skyboxes, Atmosphere density, SunRays, Bloom, Blur, DepthOfField, and ColorCorrection into a standalone `.rbxmx` preset for your own games.

### 📱 4. GUI & HUD Ripper
- Extract all ScreenGuis, Inventories, Shops, and HUDs with rounded corners (`UICorner`), gradients, and UI scripts into an isolated UI Pack.

### 🎯 5. Isolated Target Model Selector
- Type the name of any Model, Car, Gun, Map, or Folder (e.g. `"Car"`, `"Shop"`, `"Weapon"`) and export just that model to `.rbxm`.

### 📡 6. Live Network Traffic Sniffer (RemoteSpy)
- Monitor and record real-time `RemoteEvent` and `RemoteFunction` packets as you play, exporting the protocol to JSON.

### 🧊 7. 3D Wavefront Exporter (.OBJ + .MTL)
- Convert the 3D map into `.obj` and `.mtl` for immediate import into **Blender**, **Cinema 4D**, **Unity**, or **Unreal Engine**.

### 🔌 8. Official Roblox Studio Plugin (`plugin/HyperSaveImporter.server.luau`)
- Drop into Studio plugins for 1-click game rebuild and local asset linking.

---

## 🚀 Quick Start Guide

### 1. In-Game Execution
Open your executor (on macOS, Windows, or Mobile) and execute:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
```

### 2. Controls
- **Abrir / Esconder Menu**: Pressione **`RightShift`** ou toque no botão flutuante `[⚡ HYPERSAVE]`.
- **Clonar Jogo Inteiro**: Vá na aba **`🚀 Clonar Tudo`** e clique no botão roxo principal.
- **Ouvir Músicas**: Vá na aba **`🎵 Músicas & Sons`** e clique em **`▶️ Play`**.
- **Salvar Iluminação**: Vá na aba **`💡 Iluminação`** e clique em **`🚀 SALVAR PRESET`**.
- **Salvar Interfaces**: Vá na aba **`📱 Interfaces (UI)`** e clique em **`🚀 SALVAR TODAS AS GUIs`**.

---

## 🛠️ Executor Compatibility Matrix

| Executor | Platform | File System (`writefile`) | Script Decompiler | Status |
| :--- | :---: | :---: | :---: | :---: |
| **MacSploit** | macOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Hydrogen (Mac)** | macOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Wave** | Windows | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Synapse Z** | Windows | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Solara** | Windows | ✅ Yes | ⚠️ Bytecode | 🟢 **Supported** |
| **Celery** | Windows | ✅ Yes | ⚠️ Bytecode | 🟢 **Supported** |
| **Hydrogen (Mobile)** | Android / iOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Delta** | Android / iOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Codex** | Android / iOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |
| **Arceus X** | Android / iOS | ✅ Yes | ✅ Yes | 🟢 **100% Supported** |

---

## ⚖️ License & Disclaimer

This project is licensed under the [MIT License](LICENSE).

*Disclaimer: HyperSaveInstance is created for educational, research, reverse-engineering analysis, and backup purposes of your own Roblox experiences.*
