<div align="center">

# ⚡ HyperSaveInstance v2.0 (Ultimate Master Suite)
### The Definitive, All-in-One Universal Roblox Game Cloner & Reverse-Engineering Suite

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

### 🎨 1. 10/10 Visual Fidelity & 3D Terrain
- **Full SmoothTerrain Voxel Extraction**: Reads 3D voxel regions (`Terrain:ReadVoxels`), saving material and occupancy grids for perfect smooth terrain recreation in Roblox Studio.
- **Atmosphere & Lighting**: Captures Atmosphere density/offset/haze, Skybox (all 6 textures), SunRays, Bloom, Blur, ColorCorrection, and DepthOfField.
- **PBR SurfaceAppearance**: Preserves NormalMap, RoughnessMap, MetalnessMap, and ColorMap.
- **CSG & Solid Modeling**: Preserves `UnionOperation`, `NegateOperation`, `MeshPart`, and `SpecialMesh` with deep `PhysicsData` and `ChildData` buffers.

### 📜 2. 10/10 Script Decompilation & RemoteSpy Backend
- **Concurrent Multi-Worker Decompiler**: Utilizes parallel workers (`task.spawn` pool) to decompile hundreds of scripts in seconds.
- **RemoteSpy Backend Auto-Generator**: Generates structured server script stubs with `.OnServerEvent` / `.OnServerInvoke` dispatchers for all network endpoints.
- **Bytecode Fallback**: Extracts and Base64-encodes raw Luau bytecode when full decompiler is unavailable.

### 📦 3. Raw Asset Downloader
- Downloads all audio tracks (`.mp3`), textures/PBR maps (`.png`), 3D meshes (`.mesh`), and animations (`.rbxanim`) into a dedicated `HyperSave_Assets_<PlaceId>/` folder on your disk.

### 📡 4. Live Network Traffic Sniffer
- Hooks into `RemoteEvent:FireServer` and `RemoteFunction:InvokeServer` to record parameters, payloads, and timestamps while you play, exporting the protocol to JSON.

### 🧊 5. 3D Wavefront Exporter (.OBJ + .MTL)
- Exports the 3D map directly to `.obj` and `.mtl` for immediate import into **Blender**, **Cinema 4D**, **Unity**, or **Unreal Engine**.

### 🔌 6. Official Roblox Studio Plugin (`plugin/HyperSaveImporter.server.luau`)
- Drop the plugin into your Studio plugins folder to rebuild maps, import local assets, and restore place hierarchy with 1 click.

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
- **Salvar Modelo Isolado**: Vá na aba **`🎯 Salvar Modelo`** e digite o nome do carro/arma que deseja salvar.
- **Gravar Rede**: Vá na aba **`📡 Rede / Remotes`** e clique em **`▶️ INICIAR GRAVAÇÃO`**.
- **Exportar para Blender**: Vá na aba **`🧊 Exportar 3D`** e clique em **`🚀 EXPORTAR MAPA 3D (.OBJ)`**.

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
