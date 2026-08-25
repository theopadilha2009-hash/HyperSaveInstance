# 🕹️ Como Usar o HyperSaveInstance (Guia Passo a Passo para Iniciantes)

Este guia explica exatamente como clonar qualquer jogo do Roblox usando o **HyperSaveInstance**, seja no **Mac**, **Windows** ou **Celular**.

---

## ❓ Como funciona a clonagem do Roblox? (Entenda em 1 Minuto)

> [!NOTE]
> Você **não** usa o F12 do navegador nem cola o link da web.
> O Roblox carrega todo o mapa 3D, texturas, terreno, sons e scripts na **memória RAM do seu computador** assim que você entra na partida.
> O **HyperSaveInstance** roda dentro do jogo e extrai tudo o que está na memória diretamente para um arquivo `.rbxlx` (arquivo editável do Roblox Studio).

---

## 🖥️ 1. Qual programa você precisa no seu Computador?

Para rodar o script dentro do Roblox, você precisa de um **Executor de Scripts** compatível com o seu sistema:

### No macOS (Mac):
- **MacSploit** (Recomendado para Mac)
- **Hydrogen macOS**

### No Windows:
- **Wave**
- **Synapse Z**
- **Solara**
- **Celery**

### No Celular / Android:
- **Delta**
- **Codex**
- **Arceus X**
- **Hydrogen Mobile**

---

## 🚀 2. Passo a Passo para Clonar um Jogo

### Passo 1: Abrir o Executor
Abra o seu executor instalado no Mac ou Windows.

### Passo 2: Entrar no Jogo do Roblox
Abra o Roblox normalmente pelo aplicativo e entre no jogo que você quer copiar.

### Passo 3: Colar o Comando
No executor, cole o comando de 1-linha:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()
```

### Passo 4: Clicar em "Executar" / "Execute"
Clique no botão de executar no seu executor.

### Passo 5: A Janela do HyperSaveInstance vai aparecer na sua tela!
Uma interface moderna (HUD escuro) vai abrir dentro do próprio jogo com:
- O botão principal: **"CLONAR JOGO INTEIRO (1-CLIQUE)"**
- Barra de progresso ao vivo
- Console mostrando cada script e parte sendo salva

### Passo 6: Clicar em "CLONAR JOGO INTEIRO"
Basta dar 1 clique! O HyperSaveInstance vai:
1. Varrer todo o mapa e modelos 3D
2. Extrair o Terreno e Voxels de água
3. Descompilar todos os Scripts (LocalScripts e ModuleScripts)
4. Salvar tudo em um arquivo `.rbxlx` dentro da pasta `workspace` do seu executor.

---

## 📂 3. Como abrir o jogo clonado no Roblox Studio

1. Abra o **Roblox Studio** no seu computador.
2. No menu superior, clique em **File (Arquivo)** -> **Open from File... (Abrir do Arquivo...)**.
3. Vá até a pasta `workspace` do seu executor (onde o arquivo foi salvo com o nome `HyperSave_<NomeDoJogo>_<ID>.rbxlx`).
4. Selecione o arquivo e clique em **Abrir**.
5. **Pronto!** O mapa inteiro, peças, terreno, iluminação, interface e scripts estarão abertos no Studio para você editar ou publicar no seu perfil!
