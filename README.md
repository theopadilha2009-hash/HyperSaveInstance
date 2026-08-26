> [!IMPORTANT]
> HyperSaveInstance is an independent, unofficial project. It is not affiliated with, endorsed by, or officially connected to Roblox Corporation. Roblox and Luau are trademarks of Roblox Corporation.

<p align="center">
  <img src="assets/hypersave-emblem.jpg" alt="HyperSaveInstance ram skull emblem" width="620">
</p>

# HyperSaveInstance

A modular Luau serialization and reverse-engineering toolkit for preserving Roblox experience structures, assets, scripts, interfaces, lighting, terrain, and metadata.

[![Build](https://img.shields.io/github/actions/workflow/status/theopadilha2009-hash/HyperSaveInstance/build.yml?branch=main&label=build)](https://github.com/theopadilha2009-hash/HyperSaveInstance/actions/workflows/build.yml)
[![Version](https://img.shields.io/badge/version-2.0.0-6f42c1)](https://github.com/theopadilha2009-hash/HyperSaveInstance)
[![Luau](https://img.shields.io/badge/language-Luau-335fff)](https://luau.org/)
[![License](https://img.shields.io/badge/license-MIT-2f81f7)](LICENSE)

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
```

Use the loader only in environments where you have permission to inspect and export the content involved.

## Overview

HyperSaveInstance provides a single interface for full-place serialization, isolated model export, script processing, asset discovery, terrain preservation, interface extraction, lighting capture, network inspection, and Studio-side import workflows.

The project contains:

- A bundled Luau distribution in `dist/HyperSaveInstance.luau`
- Modular source code under `src/`
- A Roblox Studio importer under `plugin/`
- Build and diagnostic scripts under `scripts/`
- API and usage documentation under `docs/`

## Feature matrix

| Capability | Legacy Synapse | USSI | UltraSmart | HyperSaveInstance 2.0 |
| --- | ---: | ---: | ---: | ---: |
| In-game control interface | No | No | Basic | Full dashboard |
| Visual fidelity | 6/10 | 9/10 | 9/10 | 10/10 |
| Script decompiler engine | Slow | Single worker | Basic | Worker pool with retry |
| Raw asset downloader | No | No | No | Included |
| Audio browser and exporter | No | No | No | Included |
| Lighting and skybox export | No | No | No | Included |
| GUI and HUD export | No | No | No | Included |
| Roblox Studio importer | No | No | No | Included |
| Network traffic inspection | No | No | No | Included |
| Wavefront export | No | No | No | OBJ and MTL |
| Multi-place universe discovery | No | No | No | Included |
| Anti-idle handling | No | No | No | Included |
| StreamingEnabled traversal | No | No | Partial | Spatial grid traversal |
| Interface toggle | No | No | No | RightShift |
| Output formats | RBXLX | RBXLX | RBXLX | RBXLX, RBXL, Lua, OBJ |
| Platforms | Windows | Windows | Windows | macOS, Windows, mobile |

## Core capabilities

### Full-place serialization

Exports terrain, models, lighting, scripts, user interfaces, attributes, tags, and supported instance metadata to an RBXLX representation.

### Asset handling

Discovers referenced images, audio, meshes, textures, and related content. The asset subsystem can produce local manifests and supported file outputs.

### Script processing

Uses a worker-oriented decompilation pipeline with timeout handling, retries, and configurable fallbacks.

### Lighting and interface extraction

Captures Lighting services, atmospheric effects, post-processing configuration, skyboxes, ScreenGuis, menus, inventories, shops, and HUD structures.

### Isolated model export

Allows a target model, folder, vehicle, tool, map section, or interface hierarchy to be serialized separately.

### Network inspection

Records observable RemoteEvent and RemoteFunction traffic and can export captured information as JSON for debugging and protocol analysis.

### Wavefront export

Produces OBJ and MTL output for supported geometry workflows involving Blender, Cinema 4D, Unity, or Unreal Engine.

### Studio importer

`plugin/HyperSaveImporter.server.luau` provides a Studio-side workflow for rebuilding exports and reconnecting supported local assets.

## Controls

| Action | Control |
| --- | --- |
| Show or hide the interface | `RightShift` or the floating `HYPERSAVE` button |
| Export the complete place | Open `Clone All` and select the primary action |
| Browse audio | Open `Music and Sounds` |
| Export lighting | Open `Lighting` and select `Save Preset` |
| Export interfaces | Open `Interfaces` and select `Save All GUIs` |

## Compatibility

Compatibility depends on the capabilities exposed by the execution environment, especially `writefile`, HTTP access, hidden-property access, and decompilation support.

| Environment | Platform | File system | Decompiler | Declared status |
| --- | --- | ---: | ---: | --- |
| MacSploit | macOS | Yes | Yes | Fully supported |
| Hydrogen | macOS | Yes | Yes | Fully supported |
| Wave | Windows | Yes | Yes | Fully supported |
| Synapse Z | Windows | Yes | Yes | Fully supported |
| Solara | Windows | Yes | Bytecode | Supported |
| Celery | Windows | Yes | Bytecode | Supported |
| Hydrogen | Mobile | Yes | Yes | Fully supported |
| Delta | Mobile | Yes | Yes | Fully supported |
| Codex | Mobile | Yes | Yes | Fully supported |
| Arceus X | Mobile | Yes | Yes | Fully supported |

## Documentation

- [Usage guide](docs/HOW_TO_USE.md)
- [Feature reference](docs/FEATURES.md)
- [API reference](docs/API.md)
- [Studio importer](plugin/HyperSaveImporter.server.luau)

## Responsible use

HyperSaveInstance is intended for development, debugging, interoperability research, archival work, and backups of experiences or assets you own or are authorized to inspect.

Do not use it to redistribute protected content, bypass access controls, impersonate another creator, or violate Roblox rules or applicable law. You are responsible for obtaining permission and validating how exported content may be used.

## Support the project

- [GitHub Sponsors](https://github.com/sponsors/theopadilha2009-hash)
- [Patreon](https://www.patreon.com/c/TheoPadilha)
- Pix support is available on request through the maintainer's GitHub profile.

## Acknowledgments

HyperSaveInstance was informed by public research, specifications, and prior open-source work in the Roblox serialization ecosystem. These projects remain independent and retain their own authorship and licenses.

- [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) for prior saveinstance research, compatibility behavior, and documentation. Credit: `UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw`
- [UltraSmartSaveInstance](https://github.com/RiseBlox/UltraSmartSaveInstance) for its fidelity-oriented saveinstance approach and prepass work
- [Roblox format specifications](https://github.com/RobloxAPI/spec) maintained from work by Anaminus and contributors
- [rbx-dom](https://github.com/rojo-rbx/rbx-dom) for its Roblox DOM and serialization implementation
- [rbx-instance-serializer](https://github.com/Dekkonot/rbx-instance-serializer) by Dekkonot for instance-serialization research

No affiliation or endorsement by these projects is implied. HyperSaveInstance does not claim authorship of third-party source code.

## License

HyperSaveInstance is distributed under the [MIT License](LICENSE). Referenced third-party projects and specifications are governed by their respective licenses.
