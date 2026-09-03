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

## 3. Como Abrir no Roblox Studio

1. Abra o **Roblox Studio**.
2. Vá em **File (Arquivo)** -> **Open from File... (Abrir do Arquivo...)**.
3. Navegue até a pasta `workspace/` do seu executor.
4. Selecione o arquivo `.rbxlx` e clique em **Abrir**.
5. O mapa completo estará carregado no Studio, pronto para edição.
