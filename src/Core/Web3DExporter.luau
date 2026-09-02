--[[
    HyperSaveInstance - Standalone Web 3D (HTML / Three.js) Exporter
    Exports any 3D Model, Map or Weapon into a single standalone interactive HTML file
    with WebGL, OrbitControls, studio lighting, wireframe view, and clean Dark Slate HUD.
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
    <title>HyperSave 3D Web Viewer - ]==], safeName, [==[</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: #0F1117;
            color: #FFFFFF;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
        }
        #webgl-canvas { width: 100%; height: 100%; display: block; }
        .panel {
            position: absolute;
            background: #181B24;
            border: 1px solid #303646;
            border-radius: 8px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
            padding: 14px 18px;
            z-index: 100;
        }
        #header-card {
            top: 16px;
            left: 16px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .title {
            font-size: 14px;
            font-weight: 700;
            color: #FFFFFF;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .badge {
            background: #2563EB;
            color: #FFFFFF;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        .subtitle { font-size: 11px; color: #94A3B8; }
        #controls-card {
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .btn {
            background: #232734;
            color: #FFFFFF;
            border: 1px solid #32394C;
            padding: 8px 14px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s ease;
        }
        .btn:hover {
            background: #2563EB;
            border-color: #3B82F6;
        }
        .btn.active {
            background: #2563EB;
            border-color: #3B82F6;
        }
        #stats-card {
            top: 16px;
            right: 16px;
            font-size: 11px;
            line-height: 1.6;
            color: #94A3B8;
        }
        #stats-card strong { color: #FFFFFF; }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 13px;
            font-weight: 600;
            color: #FFFFFF;
            background: #181B24;
            padding: 14px 24px;
            border-radius: 8px;
            border: 1px solid #303646;
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
    <div id="header-card" class="panel">
        <div class="title">
            <span>HyperSave 3D</span>
            <span class="badge">]==], safeName, [==[</span>
        </div>
        <div class="subtitle">Por Theo Lorentz Padilha • Visualizador WebGL</div>
    </div>

    <div id="stats-card" class="panel">
        <div><strong>Status:</strong> <span style="color:#10B981">Carregado</span></div>
        <div><strong>Place ID:</strong> ]==], tostring(placeId), [==[</div>
        <div><strong>Controles:</strong> Botão esquerdo (Girar) | Direito (Pan) | Scroll (Zoom)</div>
    </div>

    <div id="controls-card" class="panel">
        <button id="btn-wireframe" class="btn">Linhas (Wireframe)</button>
        <button id="btn-rotate" class="btn active">Auto-Rotação: ON</button>
        <button id="btn-reset" class="btn">Resetar Câmera</button>
    </div>

    <div id="loading">Renderizando geometria 3D...</div>
    <div id="webgl-canvas"></div>

    <script>
        const rawObjData = `]==], escapedObj, [==[`;

        let scene, camera, renderer, controls, currentMeshGroup;
        let isWireframe = false;
        let isAutoRotate = true;

        function init() {
            const container = document.getElementById('webgl-canvas');
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x0F1117);
            scene.fog = new THREE.FogExp2(0x0F1117, 0.005);

            camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 5000);
            camera.position.set(30, 25, 45);

            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.0;
            container.appendChild(renderer.domElement);

            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.autoRotate = true;
            controls.autoRotateSpeed = 1.2;

            // Studio Lighting Setup
            const ambient = new THREE.AmbientLight(0xffffff, 0.6);
            scene.add(ambient);

            const sun = new THREE.DirectionalLight(0xffffff, 1.2);
            sun.position.set(80, 150, 60);
            sun.castShadow = true;
            sun.shadow.mapSize.width = 2048;
            sun.shadow.mapSize.height = 2048;
            scene.add(sun);

            const fillLight = new THREE.DirectionalLight(0x94A3B8, 0.5);
            fillLight.position.set(-60, 40, -60);
            scene.add(fillLight);

            // Ground Grid
            const grid = new THREE.GridHelper(300, 60, 0x2563EB, 0x272A34);
            grid.position.y = -0.1;
            scene.add(grid);

            // Load parsed OBJ string
            const loader = new THREE.OBJLoader();
            try {
                const obj = loader.parse(rawObjData);
                currentMeshGroup = obj;

                // Center geometry and fit camera
                const box = new THREE.Box3().setFromObject(obj);
                const center = box.getCenter(new THREE.Vector3());
                const size = box.getSize(new THREE.Vector3());

                obj.position.x = -center.x;
                obj.position.y = -box.min.y;
                obj.position.z = -center.z;

                obj.traverse((child) => {
                    if (child.isMesh) {
                        child.castShadow = true;
                        child.receiveShadow = true;
                        if (!child.material) {
                            child.material = new THREE.MeshStandardMaterial({
                                color: 0x94A3B8,
                                roughness: 0.5,
                                metalness: 0.1
                            });
                        }
                    }
                });

                scene.add(obj);

                const maxDim = Math.max(size.x, size.y, size.z);
                const fov = camera.fov * (Math.PI / 180);
                let cameraZ = Math.abs(maxDim / 2 / Math.tan(fov / 2)) * 1.5;
                cameraZ = Math.max(cameraZ, 20);

                camera.position.set(cameraZ * 0.8, cameraZ * 0.6, cameraZ * 0.8);
                camera.lookAt(0, size.y * 0.4, 0);
                controls.target.set(0, size.y * 0.4, 0);
                controls.update();

                document.getElementById('loading').style.opacity = '0';
                setTimeout(() => { document.getElementById('loading').style.display = 'none'; }, 300);
            } catch (err) {
                console.error("Erro ao parsear OBJ:", err);
                document.getElementById('loading').innerText = "Erro ao renderizar 3D: " + err.message;
            }

            // Button Event Listeners
            document.getElementById('btn-wireframe').addEventListener('click', () => {
                isWireframe = !isWireframe;
                document.getElementById('btn-wireframe').classList.toggle('active', isWireframe);
                if (currentMeshGroup) {
                    currentMeshGroup.traverse((child) => {
                        if (child.isMesh && child.material) {
                            child.material.wireframe = isWireframe;
                        }
                    });
                }
            });

            document.getElementById('btn-rotate').addEventListener('click', () => {
                isAutoRotate = !isAutoRotate;
                controls.autoRotate = isAutoRotate;
                document.getElementById('btn-rotate').classList.toggle('active', isAutoRotate);
                document.getElementById('btn-rotate').innerText = isAutoRotate ? "Auto-Rotação: ON" : "Auto-Rotação: OFF";
            });

            document.getElementById('btn-reset').addEventListener('click', () => {
                if (currentMeshGroup) {
                    const box = new THREE.Box3().setFromObject(currentMeshGroup);
                    const size = box.getSize(new THREE.Vector3());
                    const maxDim = Math.max(size.x, size.y, size.z);
                    camera.position.set(maxDim * 1.2, maxDim * 0.8, maxDim * 1.2);
                    controls.target.set(0, size.y * 0.4, 0);
                    controls.update();
                }
            });

            window.addEventListener('resize', onWindowResize);
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        function animate() {
            requestAnimationFrame(animate);
            controls.update();
            renderer.render(scene, camera);
        }

        window.onload = () => {
            init();
            animate();
        };
    </script>
</body>
</html>]==]
    }

    local fullHtml = table.concat(htmlParts, "")

    if Environment.HasFileSystem() then
        local ok = Environment.WriteFile(fileName, fullHtml)
        if ok then
            return true, fileName
        else
            return false, "Falha ao gravar arquivo Web 3D."
        end
    end

    return false, "Função writefile indisponível no executor atual."
end

return Web3DExporter
