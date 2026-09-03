# HyperSaveInstance - Documentação da API

O HyperSaveInstance pode ser executado como interface interativa (HUD) ou programaticamente dentro de scripts de automação.

---

## Execução Rápida

### Interface Interativa (HUD)
```lua
local HyperSaveInstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
HyperSaveInstance.OpenUI()
```

---

## API Programática

### `HyperSaveInstance.Save(options: table?): (boolean, string)`
Executa o processo de salvamento com opções customizadas.

#### Exemplo:
```lua
local HyperSaveInstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()

local success, message = HyperSaveInstance.Save({
    Format = "rbxlx",                   -- "rbxlx" | "rbxl" | "lua"
    Mode = "Full",                      -- "Full" | "Fast" | "VisualsOnly" | "ScriptsOnly" | "Ghost"
    DecompileScripts = true,            -- Descompilar LocalScripts & ModuleScripts
    SaveTerrainVoxels = true,           -- Extrair voxels 3D do SmoothTerrain
    SaveLighting = true,                -- Capturar Atmosphere, Sky e Pós-processamento
    SaveNilInstances = true,            -- Capturar instâncias isoladas em nil
    SafeAssetDownload = true,           -- Throttling inteligente de rede por Ping & FPS
    FilePath = "MyGameClone.rbxlx"      -- Nome do arquivo de saída
})

if success then
    print("Jogo salvo com sucesso em:", message)
else
    warn("Falha ao salvar:", message)
end
```

---

## Métodos de Presets Rápidos

### `HyperSaveInstance.SaveFast(options: table?)`
Salva elementos visuais e modelos rapidamente sem aguardar a descompilação de scripts.

### `HyperSaveInstance.SaveVisuals(options: table?)`
Salva geometria, texturas, propriedades de terreno, iluminação, sons e interfaces gráficas.

### `HyperSaveInstance.SaveScripts(options: table?)`
Focado exclusivamente na extração e descompilação de scripts locais e replicados.

### `HyperSaveInstance.SaveSilent(options: table?)` / `HyperSaveInstance.SaveGhost(options: table?)`
Executa o salvamento em segundo plano sem abrir interface gráfica, sem reproduzir sons e com proteção de evasão ativa.

### `HyperSaveInstance.ExportWeb3D(targetRoot: Instance?, options: table?): (boolean, string)`
Exporta a geometria 3D para um arquivo HTML interativo autônomo com visualizador WebGL (Three.js).

### `HyperSaveInstance.Snapshot(name: string?, root: Instance?): (boolean, string)`
Registra um snapshot das instâncias para acompanhamento de atualizações do mapa (Place Diff Tracker).

---

## Referência de Configurações

| Opção | Tipo | Padrão | Descrição |
| :--- | :---: | :---: | :--- |
| `Format` | `string` | `"rbxlx"` | Formato de saída: `"rbxlx"` (XML), `"rbxl"` (Binário) ou `"lua"` |
| `Mode` | `string` | `"Full"` | Modo de operação: `"Full"`, `"Fast"`, `"VisualsOnly"`, `"ScriptsOnly"`, `"Ghost"` |
| `FilePath` | `string` | `""` | Caminho de destino (gerado automaticamente se vazio) |
| `ShowUI` | `boolean` | `true` | Abre o HUD interativo na inicialização |
| `AutoAntiAFK` | `boolean` | `true` | Proteção automática contra desconexão por inatividade (20 min) |
| `AutoExploreStreaming` | `boolean` | `true` | Varredura de chunks por câmera para jogos com StreamingEnabled |
| `StealthMode` | `boolean` | `true` | Proteções de evasão e anonimização contra anti-cheats de jogos |
| `SafeAssetDownload` | `boolean` | `true` | Pausa downloads de assets se o Ping > 160ms ou FPS < 35 |
| `DownloadRawAssets` | `boolean` | `false` | Salva arquivos brutos (.mp3, .png, .mesh) em pasta local |
| `SaveTerrain` | `boolean` | `true` | Preserva propriedades, cores e materiais do terreno |
| `SaveTerrainVoxels` | `boolean` | `true` | Extrai matrizes de ocupação e material em 3D |
| `SaveLighting` | `boolean` | `true` | Preserva Atmosphere, Sky, Bloom, SunRays e ColorCorrection |
| `SaveSounds` | `boolean` | `true` | Preserva sons, SoundGroups e efeitos acústicos |
| `SaveUnions` | `boolean` | `true` | Preserva uniões CSG e operações de negação |
| `SaveSurfaceAppearance` | `boolean` | `true` | Preserva mapas PBR (Color, Normal, Metalness, Roughness) |
| `SaveAttributes` | `boolean` | `true` | Salva atributos customizados de instâncias |
| `SaveTags` | `boolean` | `true` | Salva tags do CollectionService |
| `DecompileScripts` | `boolean` | `true` | Descompila LocalScripts e ModuleScripts |
| `DecompileTimeout` | `number` | `12` | Tempo máximo (segundos) por script |
| `DecompileParallelWorkers`| `number` | `8` | Quantidade de threads simultâneas no descompilador |
| `SaveNilInstances` | `boolean` | `true` | Captura instâncias isoladas em nil via `getnilinstances()` |
