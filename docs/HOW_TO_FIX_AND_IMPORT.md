# 🛠️ Como Resolver os Erros e Importar no Roblox Studio

Este guia ensina o passo a passo para corrigir os problemas comuns que acontecem ao abrir um jogo salvo pelo **HyperSaveInstance** no **Roblox Studio**.

---

## 🛑 Por que o jogo não funciona logo de cara?

Quando você clona um jogo do Roblox, **três coisas acontecem**:
1. **O Servidor está vazio:** O Roblox não envia os scripts da pasta `ServerScriptService` para o seu computador. Quando você clica em botões ou usa ferramentas, o jogo tenta chamar o servidor via `InvokeServer()` e fica **congelado para sempre** esperando uma resposta que não existe.
2. **Áudios bloqueados (Erro HTTP 403):** Sons enviados por outros criadores são bloqueados pela Roblox por direitos autorais.
3. **Scripts com falha de descompilação:** Se o script local tiver erros de sintaxe gerados pelo executor, a tela para de responder.

Para resolver tudo isso com **1 clique**, nós criamos o **HyperSave Studio Suite** (Plugin oficial).

---

## 📥 Passo 1: Como instalar o Plugin no Roblox Studio

1. Abra o **Roblox Studio**.
2. Abra qualquer lugar ou crie um jogo em branco.
3. Na barra superior do Studio, vá na aba **Plugins** e clique na pasta **Plugins Folder** (Pasta de Plugins locais).
4. Copie o arquivo `plugin/HyperSaveImporter.server.luau` para dentro dessa pasta.
5. Pronto! Um botão chamado **" HyperSave Suite"** vai aparecer na barra de ferramentas do seu Studio.

---

## 📂 Passo 2: Como abrir o jogo extraído

1. No seu executor (Mac, Windows ou Celular), ao terminar de salvar, ele cria um arquivo com terminação **`.rbxlx`** ou **`.rbxl`** na pasta `workspace/` do executor.
2. No seu computador, clique duas vezes no arquivo `.rbxlx` ou vá no Roblox Studio em **File -> Open from File...** e selecione o arquivo.
3. O mapa, iluminação, interfaces e modelos carregarão na tela!

---

## ⚡ Passo 3: Como consertar o jogo em 1 Clique

Com o mapa aberto no Roblox Studio:

1. Clique no botão **"Reparar & Reconstruir"** na aba Plugins do Studio.
2. A janela do **HyperSave Suite** se abrirá.
3. Execute as 3 ações na ordem abaixo:

### 1️⃣ Clique em "⚡ GERAR BACKEND DE SERVIDOR AUTOMÁTICO"
* O plugin vai vasculhar o jogo inteiro procurando todas as `RemoteEvent` e `RemoteFunction`.
* Ele cria automaticamente a pasta `ServerScriptService/HyperSave_ServerBackend/ServerDispatcher`.
* **O que isso resolve:** Ao dar "Play", qualquer botão da interface que chamar `InvokeServer()` receberá uma resposta imediata de sucesso, evitando que o jogo congele ou trave em telas de loading infinitas!

### 2️⃣ Clique em "🔊 REPARAR ÁUDIOS E ELIMINAR ERRO 403"
* O plugin encontra todos os sons que pertencem a criadores privados e troca por IDs públicos neutros verificados.
* **O que isso resolve:** Elimina os erros vermelhos `HTTP 403 (Forbidden)` do console do Studio e faz os botões e efeitos sonoros tocarem sem crashar os scripts.

### 3️⃣ Clique em "🛡️ BLINDAR SCRIPTS LOCAIS"
* O plugin analisa os scripts locais. Se algum tiver a mensagem `-- Failed to decompile`, ele substitui por uma função segura neutra.
* **O que isso resolve:** Impede que um script quebrado interrompa a execução dos outros scripts funcionais.

---

## 🎮 Passo 4: Testar o Jogo

* Pressione **F5** ou clique no botão **Play** no Roblox Studio.
* O seu personagem vai nascer no mapa, a interface vai responder aos cliques e o console estará limpo e funcional!
