# HyperSaveInstance - Arquitetura de Recursos e Comparativo

O HyperSaveInstance foi desenvolvido combinando as melhores técnicas de serialização, engenharia reversa e otimização de memória do ecossistema Roblox:
- **UniversalSynSaveInstance (USSI)**: Ampla cobertura de serviços, propriedades e regras de compatibilidade.
- **UltraSmartSaveInstance**: Fidelidade visual 10/10, extração de voxels 3D, preservação de CSG e PBR.
- **rbx-dom**: Conformidade com as especificações oficiais de chunks XML e binários da Roblox.
- **Raycast 3D World Selector**: Isolamento e extração de modelos e áreas específicas do mapa via mira 3D.
- **Camera-Only Streaming Bypass**: Varredura espacial não-intrusiva sem movimentação física do personagem.

---

## Tabela Comparativa

| Recurso | Synapse Legado | USSI Standard | UltraSmart | **HyperSaveInstance v2.0** |
| :--- | :---: | :---: | :---: | :---: |
| **Interface no Jogo** | Não | Não | Básica | **Dashboard Dark Slate + Modo Pílula** |
| **Bypass de StreamingEnabled** | Não | Não | Teleporte físico | **Câmera Furtiva + Memory Accumulator** |
| **Throttling de Rede (Ping & FPS)** | Não | Não | Não | **Automático (Pausa se Ping > 160ms)** |
| **Descompilador Paralelo** | Thread única | Lento | Básico | **Pool de Workers com Fallback AST** |
| **Extração de Terreno 3D** | Não | Básica | Boa | **Voxels Completos + Propriedades de Água** |
| **Preservação de Uniões CSG** | Parcial | Parcial | Boa | **AssetId & RenderFidelity Preservados** |
| **Texturas PBR (SurfaceAppearance)** | Não | Parcial | Boa | **ColorMap, Normal, Metalness, Roughness** |
| **Iluminação & Efeitos Atmosféricos**| Básico | Bom | Bom | **Atmosphere, Sky, SunRays, Bloom, DoF** |
| **Sons & Grupos de Áudio** | Básico | Básico | Básico | **SoundGroups, Reverb, PitchShift, Distortion** |
| **CollectionService & Atributos** | Não | Parcial | Parcial | **100% Preservados via Reflection** |
| **Exportação: Roblox XML (.rbxlx)** | Sim | Sim | Sim | **Padrão Oficial Roblox Studio** |
| **Exportação: Roblox Binário (.rbxl)**| Não | Não | Não | **Formato Binário Comprimido LZ4** |
| **Exportador 3D WebGL (HTML)** | Não | Não | Não | **Visualizador 3D Three.js Autônomo** |
| **Rastreador de Atualizações (Diff)**| Não | Não | Não | **Snapshots & Relatório de Modificações** |
| **Plugin de Reparo para o Studio** | Não | Não | Não | **Reparo Mestre em 1-Clique (Knit/DataStore)** |
| **Suporte Multiplataforma** | Apenas Windows | Windows | Windows | **macOS, Windows e Mobile** |

---

## Módulos da Engine

1. **Motor de Terreno (SmoothVoxels)**:
   - Lê regiões 3D via `Terrain:ReadVoxels()`.
   - Preserva matrizes exatas de material e ocupação.
   - Salva propriedades customizadas de água e cores de materiais.

2. **Motor de CSG e Malhas**:
   - Preserva `MeshId`, `TextureID`, `RenderFidelity`, `CollisionFidelity` e `DoubleSided`.
   - Trata referências de `UnionOperation` e ângulos de suavização.

3. **Motor de Iluminação e Atmosfera**:
   - Preserva tecnologia de renderização (`Technology.Future`, `ShadowSoftness`, `GlobalShadows`).
   - Propriedades de `Atmosphere`, texturas de `Sky` e pós-processamento completo.

4. **Motor de Descompilação e Fallback**:
   - Processamento de `LocalScripts` e `ModuleScripts` em paralelo com limitação de taxa.
   - Fallback para bytecode Luau ou mocks de AST quando a descompilação não estiver disponível no executor.
