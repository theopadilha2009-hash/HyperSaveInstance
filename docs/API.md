# 📖 HyperSaveInstance - API Documentation

HyperSaveInstance can be executed directly as an interactive In-Game GUI or used programmatically inside custom automation scripts.

---

## Quick Execution

### Interactive HUD (Default)
```lua
local HyperSaveInstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
HyperSaveInstance.OpenUI()
```

---

## Programmatic API

### `HyperSaveInstance.Save(options: table)`
Runs the full clone process with custom configuration options.

#### Example:
```lua
local HyperSaveInstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()

local success, message = HyperSaveInstance.Save({
    Format = "rbxlx",                   -- "rbxlx" | "rbxl" | "lua"
    DecompileScripts = true,            -- Decompile LocalScripts & ModuleScripts
    SaveTerrainVoxels = true,           -- Extract 3D smooth terrain voxels
    SaveLighting = true,                -- Atmosphere, Sky, Post-processing
    SaveNilInstances = true,            -- Capture isolated nil instances
    DecompileParallelWorkers = 8,       -- Multi-threaded decompiler
    FilePath = "MyCustomClone.rbxlx"   -- Target file name
})

if success then
    print("Game cloned successfully!", message)
else
    warn("Failed to clone game:", message)
end
```

---

## Preset Methods

### `HyperSaveInstance.SaveFast(options: table?)`
Saves all visual elements and models quickly without waiting for script decompilation or full voxel extraction.

### `HyperSaveInstance.SaveVisuals(options: table?)`
Saves 100% of visual elements, materials, terrain properties, lighting, sounds, and UI without decompiling scripts.

### `HyperSaveInstance.SaveScripts(options: table?)`
Focused exclusively on extracting and decompiling all client and replicated scripts in the game.

---

## Configuration Options Reference

| Option | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `Format` | `string` | `"rbxlx"` | Output format: `"rbxlx"` (Roblox XML), `"rbxl"` (Binary), or `"lua"` (Studio recreation script) |
| `Mode` | `string` | `"Full"` | Preset mode: `"Full"`, `"Fast"`, `"VisualsOnly"`, `"ScriptsOnly"` |
| `FilePath` | `string` | `""` | Destination file path (auto-generated if empty) |
| `ShowUI` | `boolean` | `true` | Opens the Glassmorphic HUD upon execution |
| `SaveTerrain` | `boolean` | `true` | Preserves Terrain water properties, decorations, and materials |
| `SaveTerrainVoxels` | `boolean` | `true` | Extracts 3D Voxel occupancy and material grid data |
| `TerrainVoxelStep` | `number` | `64` | Chunk step size for reading terrain voxels safely |
| `SaveLighting` | `boolean` | `true` | Captures Lighting, Skybox, Atmosphere, and Post-effects |
| `SaveSounds` | `boolean` | `true` | Preserves Sound instances, SoundGroups, and audio effects |
| `SaveUnions` | `boolean` | `true` | Preserves CSG UnionOperations and NegateOperations |
| `SaveSurfaceAppearance` | `boolean` | `true` | Preserves PBR Normal, Roughness, and Metalness maps |
| `SaveAttributes` | `boolean` | `true` | Saves all modern instance custom attributes |
| `SaveTags` | `boolean` | `true` | Saves all CollectionService tags |
| `DecompileScripts` | `boolean` | `true` | Decompiles LocalScripts and ModuleScripts |
| `DecompileTimeout` | `number` | `12` | Max time (seconds) to wait per script |
| `DecompileParallelWorkers` | `number` | `8` | Number of concurrent decompiler threads |
| `SaveServerScriptPlaceholders` | `boolean` | `true` | Creates structured stub scripts with network event listeners for server scripts |
| `SaveNilInstances` | `boolean` | `true` | Captures isolated nil instances via `getnilinstances()` |
| `PreloadStreaming` | `boolean` | `true` | Preloads map chunks when StreamingEnabled is active |
