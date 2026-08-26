#  HyperSaveInstance - Feature Architecture & Comparison

HyperSaveInstance was designed from the ground up by analyzing and combining the best qualities of the leading Roblox reverse-engineering and serialization projects:
- **UniversalSynSaveInstance (USSI)**: Robust traversal, service coverage, and file structuring.
- **UltraSmartSaveInstance**: 10/10 visual fidelity, terrain voxel extraction, CSG preservation, and surface appearances.
- **rbx-dom**: Strict adherence to official Roblox `.rbxlx` XML and `.rbxl` binary chunk specifications.
- **rbx-instance-serializer**: Clean, modular instance property reconstruction.

---

##  Comprehensive Comparison

| Feature | Legacy Synapse (2019) | USSI Standard | UltraSmart | **HyperSaveInstance v2.0** |
| :--- | :---: | :---: | :---: | :---: |
| **In-Game GUI (1-Click)** |  None |  None |  Basic UI |  **Modern Glassmorphic HUD** |
| **Multi-Worker Decompiler** |  Single Thread |  Slow / Blocking |  Basic |  **Multi-Worker Pool (8+ Workers)** |
| **Timeout & Auto-Retry** |  Hangs forever |  Partial |  Partial |  **Safe Timeout + Auto-Retry** |
| **SmoothTerrain Voxel Extraction** |  No |  Basic |  Good |  **Full 3D Voxel Chunks + Water + Materials** |
| **CSG Unions & MeshParts** |  Partial |  Partial |  Good |  **Full AssetId & RenderFidelity Preservation** |
| **PBR SurfaceAppearance** |  No |  Partial |  Good |  **ColorMap, NormalMap, Metalness, Roughness** |
| **Lighting & Atmosphere** |  Basic |  Good |  Good |  **Atmosphere, Sky, SunRays, PostEffects** |
| **Audio & SoundGroups** |  Basic |  Basic |  Basic |  **Equalizer, Reverb, Distortion, PitchShift** |
| **Constraints & Bones** |  Partial |  Partial |  Partial |  **Attachments, Bones, Motors, Welds, Align** |
| **CollectionService Tags** |  No |  Partial |  Partial |  **100% Preserved via CollectionService** |
| **Modern Attributes** |  No |  Partial |  Partial |  **100% Preserved via GetAttributes()** |
| **Export: Roblox XML (.rbxlx)** |  Yes |  Yes |  Yes |  **Standard Compliant v4 XML** |
| **Export: Roblox Binary (.rbxl)** |  No |  No |  No |  **LZ4-Compressed Binary Format** |
| **Export: Studio Lua Script (.lua)** |  No |  No |  No |  **Standalone Recreation Script** |
| **Bypass StreamingEnabled** |  No |  No |  Partial |  **Pre-loader Simulation** |
| **Cross-Platform Support** |  Windows only |  Windows |  Windows |  **macOS, Windows & Mobile** |

---

##  Visual Fidelity Engine (10/10)

1. **Terrain Engine**:
   - Reads 3D regions using `Terrain:ReadVoxels(Region3int16)`.
   - Preserves exact Material & Occupancy matrices encoded in Base64 streams.
   - Saves WaterWaveSize, WaterWaveSpeed, WaterColor, WaterReflectance, WaterTransparency, and custom MaterialColors.

2. **CSG & MeshPart Engine**:
   - Preserves `MeshId`, `TextureID`, `RenderFidelity`, `CollisionFidelity`, and `DoubleSided`.
   - Handles `UnionOperation` asset references and solid modeling smoothing angles.

3. **Lighting & Environment**:
   - Preserves exact global lighting values (`Ambient`, `OutdoorAmbient`, `Brightness`, `ClockTime`, `ExposureCompensation`, `Technology`).
   - Atmosphere settings (`Density`, `Offset`, `Color`, `Decay`, `Glare`, `Haze`).
   - Skybox textures (`SkyboxBk`, `SkyboxDn`, `SkyboxFt`, `SkyboxLf`, `SkyboxRt`, `SkyboxUp`, `SunTextureId`, `MoonTextureId`).
   - Full post-processing effects (`BloomEffect`, `BlurEffect`, `ColorCorrectionEffect`, `SunRaysEffect`, `DepthOfFieldEffect`).

---

##  Script Decompiler Engine (10/10)

1. **LocalScripts & ModuleScripts**:
   - Decompiled in parallel using configurable worker pools.
   - Includes metadata headers with hierarchy path, execution timestamp, and executor identifier.
   - Automatic fallback to raw Luau bytecode dump if the executor lacks a full decompiler.

2. **Server Scripts (`Script`)**:
   - In Roblox FilteringEnabled, server script bytecode resides exclusively on the Roblox servers and is inaccessible to client execution.
   - HyperSaveInstance preserves the entire instance hierarchy, properties, attributes, and tags, creating formatted placeholder stubs with RemoteEvent / RemoteFunction network endpoints.
