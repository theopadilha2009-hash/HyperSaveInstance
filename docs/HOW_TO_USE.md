# Como Usar o HyperSaveInstance (Guia Passo a Passo)

Este guia explica como utilizar o **HyperSaveInstance** para salvar experiências, modelos, interfaces, áudios e terrenos no **macOS**, **Windows** e **Mobile**.

---

## Como funciona a extração?

O cliente do Roblox carrega a geometria 3D, texturas, iluminação, terreno, sons e scripts na memória RAM do seu dispositivo durante a partida. O **HyperSaveInstance** serializa esses dados em memória diretamente para um arquivo `.rbxlx` compatível com o Roblox Studio.

---

## 1. Ambientes e Executores Suportados

Para executar o script dentro do Roblox, utilize um executor compatível com o seu sistema operacional:

### No macOS:
- **MacSploit**
- **Hydrogen macOS**

### No Windows:
- **Wave**
- **Synapse Z**
- **Solara**
- **Celery**

### No Mobile / Android:
- **Delta**
- **Codex**
- **Arceus X**
- **Hydrogen Mobile**

---

## 2. Passo a Passo para Salvar o Mapa

### Passo 1: Iniciar o Jogo
Abra o Roblox e entre no mapa que deseja inspecionar ou clonar.

### Passo 2: Executar o Loader
No seu executor, execute o comando oficial:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/Loader.luau", true))()
```

### Passo 3: Interagir com a Interface
A interface gráfica do HyperSaveInstance será aberta na tela:
- **Salvar Mapa Completo (.rbxlx)**: Botão principal em destaque para salvar o jogo inteiro.
- **Barra de Progresso & Telemetria**: Exibe a etapa atual, contagem de instâncias, FPS, Ping e uso de RAM.
- **Abas Especializadas**: Acesse ferramentas para seleção individual de modelos via Raycast 3D, extração de áudios, iluminação PBR, interfaces gráficas e exportação 3D (OBJ / WebGL).
- **Atalho do Teclado**: Pressione `RightShift` para ocultar ou exibir a interface a qualquer momento.

### Passo 4: Localizar o Arquivo Salvo
O arquivo `.rbxlx` será gerado dentro da pasta `workspace/` do seu executor com o nome `HyperSave_Place_<PlaceId>.rbxlx`.

---

## 3. Presets Especiais

Você pode acionar modos otimizados programaticamente:

```luau
-- O chunk do bundle devolve nil (o return fica dentro do pcall do bundler);
-- a tabela publica vem de getgenv().
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/Loader.luau", true))()
local HyperSave = getgenv().HyperSaveInstance or _G.HyperSaveInstance

-- 1. Preset Bee Swarm Simulator (Anti-teleport + filtro de flores e tokens)
HyperSave.SaveBeeSwarm()

-- 2. Preset Blox Fruits (Filtro de VFX de combate, ilhas e slashes)
HyperSave.SaveBloxFruits()

-- 3. Preset Pet Simulator 99 (Filtro de moedas, baús e pets ativos)
HyperSave.SavePetSimulator()

-- 4. Preset Arsenal (Filtro de ragdolls, tracers e viewmodels)
HyperSave.SaveArsenal()

-- 5. Preset Doors (Filtro de efeitos de susto e glitch temporários)
HyperSave.SaveDoors()

-- 6. Preset Tower Defense Simulator (Filtro de spawners de mobs e projéteis)
HyperSave.SaveTowerDefense()

-- 7. Preset Ghost / Silencioso (Sem UI, sem prints, 100% stealth)
HyperSave.SaveGhost()

-- 8. Preset Rápido (Apenas mapa e scripts sem assets pesados)
HyperSave.SaveFast()
```

---

## 4. Download de Assets Offline (Node.js)

Se o mapa possuir muitas texturas ou áudios, você pode baixar o manifesto de assets instantaneamente pelo terminal sem travar seu jogo:

```bash
node scripts/download_manifest.js path/to/HyperSave_Manifest_<PlaceId>.json
```

---

## 5. Como Abrir no Roblox Studio

1. Abra o **Roblox Studio**.
2. Vá em **File (Arquivo)** -> **Open from File... (Abrir do Arquivo...)**.
3. Navegue até a pasta `workspace/` do seu executor.
4. Selecione o arquivo `.rbxlx` e clique em **Abrir**.
5. O mapa completo estará carregado no Studio, pronto para edição.
