<div align="center">

# ⚡ HyperSaveInstance v2.0
### The Definitive, All-in-One Universal Roblox Game Cloner & SaveInstance Engine

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

## 💎 Why HyperSaveInstance?

| Feature | Legacy Synapse | USSI Standard | UltraSmart | **HyperSaveInstance v2.0** |
| :--- | :---: | :---: | :---: | :---: |
| **In-Game GUI (1-Click HUD)** | ❌ | ❌ | ⚠️ Basic | ✅ **Modern Glassmorphic Dark UI** |
| **Visual Fidelity** | 6/10 | 9/10 | 9/10 | ✅ **10/10 (Full Terrain, PBR, Lighting, CSG)** |
| **Script Decompiler Engine** | ⚠️ Slow | ⚠️ Single-thread | ⚠️ Basic | ✅ **Multi-Worker Pool with Auto-Retry** |
| **Terrain SmoothVoxels** | ❌ | ⚠️ Basic | ✅ Good | ✅ **Full 3D Voxel Chunks + Water + Materials** |
| **CSG Unions & MeshParts** | ⚠️ Partial | ⚠️ Partial | ✅ Good | ✅ **Preserves RenderFidelity & Collision** |
| **Attributes & Tags** | ❌ | ⚠️ Partial | ⚠️ Partial | ✅ **100% Preserved (CollectionService & Attributes)** |
| **Supported File Formats** | `.rbxlx` | `.rbxlx` | `.rbxlx` | ✅ **`.rbxlx` (XML), `.rbxl` (Binary), `.lua` (Studio Script)** |
| **Bypass StreamingEnabled** | ❌ | ❌ | ⚠️ Partial | ✅ **Smart Chunk Pre-loader** |
| **Cross-Platform Compatibility** | ❌ Windows | ⚠️ Windows | ⚠️ Windows | ✅ **macOS, Windows & Mobile** |

---

## 🌟 Key Features

### 🎨 10/10 Visual Fidelity
- **Full Terrain Voxel Extraction**: Reads 3D voxel regions (`Terrain:ReadVoxels`), saving material and occupancy grids for perfect smooth terrain recreation in Roblox Studio.
- **Atmosphere & Lighting**: Captures Atmosphere density/offset/haze, Skybox (all 6 textures), SunRays, Bloom, Blur, ColorCorrection, and DepthOfField.
- **PBR SurfaceAppearance**: Preserves NormalMap, RoughnessMap, MetalnessMap, and ColorMap.
- **CSG & Solid Modeling**: Preserves `UnionOperation`, `NegateOperation`, `MeshPart`, and `SpecialMesh` properties, scales, and vertex colors.
- **Physics & Constraints**: Full support for Attachments, Bones, Motor6D, Welds, Springs, Hinges, Prismatic, and Align constraints.

### 📜 10/10 Script & Code Decompilation
- **Concurrent Multi-Worker Decompiler**: Utilizes parallel workers (`task.spawn` pool) to decompile hundreds of scripts in seconds.
- **Timeout Protection**: Never freezes the game; scripts that exceed timeout limits are automatically retried or logged.
- **Server Script Placeholders**: Generates structured placeholder stubs with RemoteEvent / RemoteFunction network endpoints, preserving the complete hierarchy even with FilteringEnabled active.
- **Bytecode Extraction Fallback**: Falls back to raw Luau bytecode dumping when full decompilation is unsupported by the executor.

### 🖥️ Modern In-Game Interface
- **1-Click "Clone Entire Game" Button**: Immediate backup with zero setup.
- **Live Progress Tracking**: Real-time progress bar, stage indicators, and estimated completion.
- **Built-in Colored Terminal / Logs**: Inspect scanned instances and decompiled scripts on the fly with a 1-click log copy button.
- **Granular Customization**: Toggle individual services, terrain chunk size, decompiler workers, and export format.

---

## 🚀 Quick Start Guide

### 1. In-Game Execution
Open your executor (on macOS, Windows, or Mobile) and execute:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
```

### 2. Choose Your Mode
- **🌟 Completo (10/10)**: Saves everything (Terrain Voxels, Models, Lighting, Scripts, UI, Attributes, Tags).
- **⚡ Rápido**: Saves visual models and lighting quickly without waiting for script decompilation.
- **🎨 Apenas Visual**: Focuses 100% on maps, meshes, terrain, and lighting.
- **📜 Apenas Scripts**: Focuses 100% on decompiling all client and replicated scripts.

### 3. Open in Roblox Studio
- If exported as `.rbxlx` or `.rbxl`: Open **Roblox Studio** -> **File** -> **Open from File...** -> Select your saved file located in your executor's `workspace` folder.
- If exported as `.lua`: Copy the generated script and paste it into the **Roblox Studio Command Bar** or run it as a plugin script.

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

## 📦 Project Architecture

```
HyperSaveInstance/
├── src/
│   ├── init.luau                   # Modular entry point
│   ├── Config/
│   │   ├── Defaults.luau           # Default settings & preset manager
│   │   └── ClassBlacklist.luau     # Filtering of internal/core objects
│   ├── Core/
│   │   ├── Engine.luau             # Master orchestrator & task scheduler
│   │   ├── Reflection.luau         # Roblox API reflection database
│   │   ├── Decompiler.luau         # Multi-worker decompiler engine
│   │   ├── TerrainSerializer.luau  # 3D voxel chunk extractor
│   │   ├── SerializerXml.luau      # Roblox XML format (.rbxlx)
│   │   ├── SerializerBinary.luau   # Roblox Binary format (.rbxl)
│   │   ├── SerializerScript.luau   # Studio Lua recreation script (.lua)
│   │   └── AssetHandler.luau       # CSG, Mesh, Texture & Audio handler
│   ├── UI/
│   │   ├── Interface.luau          # Glassmorphic HUD & in-game GUI
│   │   └── Theme.luau              # Design tokens, styling & animations
│   └── Utils/
│       ├── Environment.luau        # Universal executor polyfills
│       ├── Base64.luau             # High-speed Base64 engine
│       ├── LZ4.luau                # Pure Luau LZ4 compressor
│       └── Stream.luau             # Binary stream buffer
├── scripts/
│   ├── bundle.js                   # Node.js bundler (builds dist/HyperSaveInstance.luau)
│   └── test_parser.js              # Automated validation suite
├── dist/
│   └── HyperSaveInstance.luau      # Standalone single-file production bundle
├── docs/
│   ├── API.md                      # Scripting & programmatic API reference
│   └── FEATURES.md                 # Deep architectural breakdown & comparisons
├── loader.luau                     # 1-Line raw loader
├── package.json                    # Development scripts
└── README.md                       # Project documentation
```

---

## 💻 Development & Building

To build the standalone single-file distribution bundle locally:

```bash
# Clone the repository
git clone https://github.com/theopadilha2009-hash/HyperSaveInstance.git
cd HyperSaveInstance

# Compile the standalone production bundle
npm run build

# Run automated tests and validation
npm test
```

---

## ⚖️ License & Disclaimer

This project is licensed under the [MIT License](LICENSE).

*Disclaimer: HyperSaveInstance is created for educational, research, reverse-engineering analysis, and backup purposes of your own Roblox experiences.*
