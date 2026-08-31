--[[
    HyperSaveInstance - Standalone Web 3D (HTML / Three.js) Exporter
    Exports any 3D Model, Map or Weapon into a single standalone interactive HTML file
    with WebGL, OrbitControls, studio lighting, wireframe view, and Theo Lorentz glassmorphic HUD.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)
local ObjExporter = require(script.Parent.ObjExporter)

local Web3DExporter = {}

function Web3DExporter.ExportModelToHTML(targetRoot: Instance?, options: table?): (boolean, string)
    local root = targetRoot or workspace
    local opts = options or {}
    local placeId = game.PlaceId or 0
    local safeName = string.gsub(root.Name, "[^%w_%-]", "_")
    local fileName = string.format("HyperSave_Web3D_%s_%d.html", safeName, placeId)

    -- Export raw OBJ/MTL geometry first
    local success, objStr, mtlStr = pcall(function()
        return ObjExporter.GenerateObj(root, opts)
    end)

    if not success then
        return false, "Erro ao gerar geometria 3D: " .. tostring(objStr)
    end
    if not objStr or #objStr < 10 then
        return false, "Nenhuma peça 3D encontrada no modelo para exportar."
    end

    local escapedObj = string.gsub(objStr, "\\", "\\\\")
    escapedObj = string.gsub(escapedObj, "`", "\\`")
    escapedObj = string.gsub(escapedObj, "%$", "\\$")

    local htmlParts = {
        [==[<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>💀 HyperSaveInstance 3D Web Viewer - ]==], safeName, [==[</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: #07050d;
            color: #ffffff;
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
        }
        #webgl-canvas { width: 100%; height: 100%; display: block; }
        .glass-panel {
            position: absolute;
            background: rgba(16, 12, 28, 0.75);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(168, 85, 247, 0.3);
            border-radius: 14px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
            padding: 16px 20px;
            z-index: 100;
        }
        #header-card {
            top: 20px;
            left: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .title {
            font-size: 16px;
            font-weight: 700;
            color: #f3e8ff;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .badge {
            background: rgba(139, 92, 246, 0.2);
            border: 1px solid #8b5cf6;
            color: #d8b4fe;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 20px;
            font-weight: 600;
        }
        .subtitle { font-size: 11px; color: #a78bfa; }
        #controls-card {
            bottom: 24px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .btn {
            background: rgba(30, 22, 52, 0.8);
            color: #ffffff;
            border: 1px solid rgba(168, 85, 247, 0.4);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn:hover {
            background: #8b5cf6;
            border-color: #c084fc;
            box-shadow: 0 0 12px rgba(168, 85, 247, 0.6);
        }
        .btn.active {
            background: #a855f7;
            border-color: #f0abfc;
        }
        #stats-card {
            top: 20px;
            right: 20px;
            font-size: 11px;
            line-height: 1.6;
            color: #e9d5ff;
        }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 15px;
            font-weight: 600;
            color: #d8b4fe;
            background: rgba(16, 12, 28, 0.85);
            padding: 16px 28px;
            border-radius: 12px;
            border: 1px solid #8b5cf6;
            pointer-events: none;
            transition: opacity 0.3s ease;
        }
    </style>
    <!-- Three.js and OBJLoader CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/OBJLoader.js"></script>
</head>
<body>
    <div id="header-card" class="glass-panel">
        <div class="title">
            <span>💀 HYPERSAVE 3D</span>
            <span class="badge">]==], safeName, [==[</span>
        </div>
        <div class="subtitle">Extraído por Theo Lorentz Padilha • WebGL 3D Viewer</div>
    </div>

    <div id="stats-card" class="glass-panel">
        <div><strong>Status:</strong> <span style="color:#4ade80">Carregado</span></div>
        <div><strong>Place ID:</strong> ]==], tostring(placeId), [==[</div>
        <div><strong>Controles:</strong> Botão esquerdo (Girar) | Direito (Pan) | Scroll (Zoom)</div>
    </div>

    <div id="controls-card" class="glass-panel">
        <button id="btn-wireframe" class="btn">Linhas (Wireframe)</button>
        <button id="btn-rotate" class="btn active">Auto-Rotação: ON</button>
        <button id="btn-reset" class="btn">Resetar Câmera</button>
    </div>

    <div id="loading">⚡ Renderizando Geometria 3D...</div>
    <div id="webgl-canvas"></div>

    <script>
        const rawObjData = `]==], escapedObj, [==[`;

        let scene, camera, renderer, controls, currentMeshGroup;
        let isWireframe = false;
        let isAutoRotate = true;

        function init() {
            const container = document.getElementById('webgl-canvas');
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x07050d);
            scene.fog = new THREE.FogExp2(0x07050d, 0.005);

            camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 5000);
            camera.position.set(25, 20, 35);

            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.2;
            container.appendChild(renderer.domElement);

            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;

            // Lights
            const ambient = new THREE.AmbientLight(0xd8b4fe, 0.7);
            scene.add(ambient);

            const sunLight = new THREE.DirectionalLight(0xffffff, 1.4);
            sunLight.position.set(50, 80, 50);
            scene.add(sunLight);

            const fillLight = new THREE.DirectionalLight(0x8b5cf6, 0.8);
            fillLight.position.set(-50, -20, -50);
            scene.add(fillLight);

            const grid = new THREE.GridHelper(200, 50, 0x8b5cf6, 0x1e1634);
            grid.position.y = -0.01;
            scene.add(grid);

            // Load OBJ from embedded string
            const loader = new THREE.OBJLoader();
            try {
                const object = loader.parse(rawObjData);
                currentMeshGroup = object;

                // Center object
                const box = new THREE.Box3().setFromObject(object);
                const center = box.getCenter(new THREE.Vector3());
                const size = box.getSize(new THREE.Vector3());
                object.position.sub(center);

                // Default material
                const purpleMat = new THREE.MeshStandardMaterial({
                    color: 0xa855f7,
                    roughness: 0.35,
                    metalness: 0.2
                });

                object.traverse(child => {
                    if (child.isMesh) {
                        child.material = purpleMat;
                    }
                });

                scene.add(object);

                // Adjust camera distance
                const maxDim = Math.max(size.x, size.y, size.z);
                camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.8);
                controls.target.set(0, 0, 0);

                document.getElementById('loading').style.display = 'none';
            } catch (err) {
                console.error("Erro ao processar OBJ:", err);
                document.getElementById('loading').innerText = "Erro ao renderizar modelo: " + err.message;
            }

            // Events
            window.addEventListener('resize', onWindowResize);
            document.getElementById('btn-wireframe').addEventListener('click', toggleWireframe);
            document.getElementById('btn-rotate').addEventListener('click', toggleAutoRotate);
            document.getElementById('btn-reset').addEventListener('click', resetCamera);

            animate();
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        function toggleWireframe() {
            isWireframe = !isWireframe;
            const btn = document.getElementById('btn-wireframe');
            btn.classList.toggle('active', isWireframe);
            if (currentMeshGroup) {
                currentMeshGroup.traverse(child => {
                    if (child.isMesh && child.material) {
                        child.material.wireframe = isWireframe;
                    }
                });
            }
        }

        function toggleAutoRotate() {
            isAutoRotate = !isAutoRotate;
            const btn = document.getElementById('btn-rotate');
            btn.innerText = isAutoRotate ? "Auto-Rotação: ON" : "Auto-Rotação: OFF";
            btn.classList.toggle('active', isAutoRotate);
        }

        function resetCamera() {
            if (currentMeshGroup) {
                const box = new THREE.Box3().setFromObject(currentMeshGroup);
                const size = box.getSize(new THREE.Vector3());
                const maxDim = Math.max(size.x, size.y, size.z) || 20;
                camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.8);
                controls.target.set(0, 0, 0);
            }
        }

        function animate() {
            requestAnimationFrame(animate);
            if (isAutoRotate && currentMeshGroup) {
                currentMeshGroup.rotation.y += 0.005;
            }
            controls.update();
            renderer.render(scene, camera);
        }

        init();
    </script>
</body>
</html>]==]
    }

    local htmlContent = table.concat(htmlParts, "")
    local wrote = Environment.WriteFile(fileName, htmlContent)
    if wrote then
        return true, fileName
    end
    return false, "Falha ao gravar arquivo Web 3D (.html)."
end

return Web3DExporter
