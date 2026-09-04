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

## Métodos de Presets Rápidos & Jogos Específicos

### `HyperSaveInstance.SaveBeeSwarm(options: table?)`
Preset otimizado para **Bee Swarm Simulator** com streaming seguro e filtros de flores, pólen e coletáveis voláteis.

### `HyperSaveInstance.SaveBloxFruits(options: table?)`
Preset otimizado para **Blox Fruits** com filtros para efeitos visuais de combate, slashes de espadas, indicadores de dano e ilhas distantes.

### `HyperSaveInstance.SavePetSimulator(options: table?)`
Preset otimizado para **Pet Simulator 99 / PSX** com filtros para moedas transitórias, efeitos de quebra e pets ativos.

### `HyperSaveInstance.SaveArsenal(options: table?)`
Preset otimizado para **Arsenal / FPS** com filtros para buracos de bala, projéteis, ragdolls e viewmodels de armas.

### `HyperSaveInstance.SaveDoors(options: table?)`
Preset otimizado para **Doors / Jogos de Terror** com preservação de iluminação atmosférica PBR e filtros de partículas de jumpscare.

### `HyperSaveInstance.SaveTowerDefense(options: table?)`
Preset otimizado para **Tower Defense Simulator** com filtros para spawners de inimigos em tempo real e anéis de alcance de torres.

### `HyperSaveInstance.SaveFast(options: table?)`
Salva elementos visuais e modelos rapidamente sem aguardar a descompilação de scripts.

### `HyperSaveInstance.SaveVisuals(options: table?)`
Salva geometria, texturas, propriedades de terreno, iluminação, sons e interfaces gráficas.

### `HyperSaveInstance.SaveScripts(options: table?)`
Focado exclusivamente na extração e descompilação de scripts locais e replicados.

### `HyperSaveInstance.SaveSilent(options: table?)` / `HyperSaveInstance.SaveGhost(options: table?)`
Executa o salvamento em segundo plano sem abrir interface gráfica, sem reproduzir sons e com proteção de evasão ativa.

---

## Métodos de Modelos e Pacotes (.rbxm)

### `HyperSaveInstance.SaveModelToRbxm(targetInstance: Instance, options: table?): (boolean, string)`
Serializa um modelo ou pasta isolada diretamente no formato `.rbxm` (XML Model) para importação direta no Roblox Studio (*Insert from File*).

### `HyperSaveInstance.SaveBatchToRbxm(targetsList: {Instance}, options: table?): (boolean, string)`
Empacota múltiplos modelos ou pastas selecionadas em um único arquivo `.rbxm`.

---

## Ferramentas & Rippers Especializados

### `HyperSaveInstance.ExportWeb3D(targetRoot: Instance?, options: table?): (boolean, string)`
Exporta a geometria 3D para um arquivo HTML interativo autônomo com visualizador WebGL (Three.js) com órbita 3D e wireframe.

### `HyperSaveInstance.Snapshot(name: string?, root: Instance?): (boolean, string)`
Registra um snapshot das instâncias para acompanhamento de atualizações do mapa (Place Diff Tracker).

### `HyperSaveInstance.RipAudio(): string`
Gera a trilha sonora completa e lista de IDs de todos os sons do jogo em um arquivo `.txt`.

### `HyperSaveInstance.RipLighting(): (boolean, string)`
Exporta um arquivo `.rbxm` contendo Atmosphere, Sky, Bloom, SunRays e ColorCorrection.

### `HyperSaveInstance.RipGuis(options: table?): (boolean, string)`
Exporta todas as interfaces gráficas ativas em `StarterGui` e `PlayerGui` para um pacote `.rbxmx`.

---

## Referência de Configurações

| Opção | Tipo | Padrão | Descrição |
| :--- | :---: | :---: | :--- |
| `Format` | `string` | `"rbxlx"` | Formato de saída: `"rbxlx"` (XML), `"rbxl"` (Binário) ou `"lua"` |
| `Mode` | `string` | `"Full"` | Modo de operação: `"Full"`, `"Fast"`, `"VisualsOnly"`, `"ScriptsOnly"`, `"Ghost"`, `"BeeSwarm"`, `"BloxFruits"`, `"PetSimulator99"`, `"Arsenal"`, `"Doors"`, `"TowerDefense"` |
| `FilePath` | `string` | `""` | Caminho de destino (gerado automaticamente se vazio) |
| `ShowUI` | `boolean` | `true` | Abre o HUD interativo na inicialização |
| `AutoAntiAFK` | `boolean` | `true` | Proteção automática contra desconexão por inatividade (20 min) |
| `SafeStreaming` | `boolean` | `true` | Replicação sem teleporte físico para jogos com StreamingEnabled |
| `StealthMode` | `boolean` | `true` | Proteções de evasão e anonimização de closures com `newcclosure` |
| `SafeAssetDownload` | `boolean` | `true` | Pausa downloads de assets se o Ping > 160ms ou FPS < 35 |
| `DownloadRawAssets` | `boolean` | `false` | Salva arquivos brutos (.mp3, .png, .mesh) em pasta local |
| `DiscordWebhookUrl` | `string` | `""` | URL de Webhook do Discord para notificações de salvamento com telemetria |
| `SaveTerrain` | `boolean` | `true` | Preserva propriedades, cores e materiais do terreno |
| `SaveTerrainVoxels` | `boolean` | `true` | Extrai matrizes de ocupação e material em 3D |
| `SaveLighting` | `boolean` | `true` | Preserva Atmosphere, Sky, Bloom, SunRays e ColorCorrection |
| `SaveSounds` | `boolean` | `true` | Preserva sons, SoundGroups e efeitos acústicos |
| `SaveUnions` | `boolean` | `true` | Preserva uniões CSG e operações de negação |
| `SaveSurfaceAppearance` | `boolean` | `true` | Preserva mapas PBR (Color, Normal, Metalness, Roughness) |
| `SaveAttributes` | `boolean` | `true` | Salva atributos customizados de instâncias |
| `SaveTags` | `boolean` | `true` | Salva tags do CollectionService |
| `DecompileScripts` | `boolean` | `true` | Descompila LocalScripts e ModuleScripts com desofuscação de strings |
| `DecompileTimeout` | `number` | `12` | Tempo máximo (segundos) por script |
| `DecompileParallelWorkers`| `number` | `8` | Quantidade de threads simultâneas no descompilador |
| `SaveNilInstances` | `boolean` | `true` | Captura instâncias isoladas em nil via `getnilinstances()` |
