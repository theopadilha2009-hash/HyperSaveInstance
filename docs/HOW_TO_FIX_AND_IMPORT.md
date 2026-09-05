# Como Resolver Problemas e Importar no Roblox Studio

Este guia ensina como utilizar o plugin oficial **HyperSave Studio Suite** para corrigir restrições e preparar o mapa exportado para execução completa no **Roblox Studio**.

---

## Por que alguns jogos precisam de ajuste ao abrir no Studio?

Ao exportar uma experiência do Roblox:
1. **Backend do Servidor (ServerScriptService)**: Por segurança da arquitetura FilteringEnabled, os scripts de servidor residem exclusivamente nos servidores da Roblox e não são baixados pelo cliente. Ao clicar em botões no Studio, o jogo tenta chamar o servidor via `InvokeServer()` e pode ficar esperando caso não haja um despachante configurado.
2. **Áudios de Criadores Privados (Erro HTTP 403)**: Sons protegidos por permissão privada emitem avisos vermelhos no console.
3. **Scripts com falha de descompilação**: Scripts que contenham erros de sintaxe decorrentes do executor podem interromper rotinas locais.

O **HyperSave Studio Suite** resolve essas situações de forma automatizada com 1 clique.

---

## 1. Como Instalar o Plugin no Roblox Studio

1. Abra o **Roblox Studio**.
2. Abra qualquer projeto ou crie um lugar em branco.
3. Na barra superior do Studio, acesse a aba **Plugins** e clique no botão **Plugins Folder** (Pasta de Plugins locais).
4. Copie o arquivo `plugin/HyperSaveImporter.server.luau` (na raiz do repositório) para dentro dessa pasta.
5. O botão **"HyperSave Studio Suite"** aparecerá na barra de ferramentas do Studio.

---

## 2. Como Abrir o Jogo Salvo

1. No seu executor, o arquivo salvo é gerado na pasta `workspace/` com o nome `HyperSave_Place_<PlaceId>.rbxlx`.
2. No Roblox Studio, vá em **File (Arquivo)** -> **Open from File... (Abrir do Arquivo...)** e selecione o arquivo `.rbxlx`.
3. Todo o mapa, iluminação, interfaces e modelos carregarão na tela do Studio.

---

## 3. Como Executar o Reparo Mestre

Com o mapa aberto no Roblox Studio:

1. Clique no botão **"Reparo Mestre"** na barra de ferramentas do Studio.
2. A janela do **HyperSave Studio Suite** será exibida.
3. Clique no botão principal: **"Executar Reparo Mestre Total"**.
   - O plugin desvincula PackageLinks de terceiros.
   - Desbloqueia peças travadas para edição livre.
   - Substitui áudios privados com erro 403 por sons públicos funcionais.
   - Blinda scripts locais com stubs seguros.
   - Cria o despachante de servidor (`ServerDispatcher`) com suporte a **DataStores em memória**, **desbloqueio de GamePasses/VIP** e compatibilidade com frameworks populares (**Knit** e **ReplicaService**).

---

## 4. Testar o Jogo

Pressione **F5** ou clique no botão **Play** no Roblox Studio para testar a experiência com interfaces e rotinas ativas.
