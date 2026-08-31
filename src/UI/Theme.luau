--[[
    HyperSaveInstance - Cyber-Tribal Rootkit & Underground Hacker Design System
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Aesthetic: Brutalist Industrial, Raw Memory Hex Dumps, Blood Crimson & Radioactive Ultraviolet Neon.
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Theme = {
    -- Void Carbon & Corrosive Dark Palettes
    Background = Color3.fromRGB(2, 2, 5),             -- Pure Void Carbon Pitch Black (#020205)
    BackgroundTransparency = 0.02,                   -- Solid, heavy terminal glass
    CardBg = Color3.fromRGB(8, 7, 14),                -- Brutalist Industrial Alloy (#08070e)
    CardTransparency = 0.05,                         -- High-density rootkit window
    CardHover = Color3.fromRGB(20, 14, 34),          -- Cyber-glitch hover
    CardActive = Color3.fromRGB(38, 12, 58),         -- High-voltage active core
    
    -- High-Voltage Neon Borders
    Border = Color3.fromRGB(44, 28, 70),             -- Dark alloy wireframe
    BorderTransparency = 0.1,
    BorderLight = Color3.fromRGB(180, 30, 255),      -- Toxic Ultraviolet Stroke (#b41eff)
    BorderNeon = Color3.fromRGB(255, 0, 75),         -- Corrosive Blood Crimson Glow (#ff004b)
    BorderCyber = Color3.fromRGB(0, 255, 170),       -- Radioactive Acid Teal (#00ffaa)
    
    -- Accents & Signal Flags
    AccentPrimary = Color3.fromRGB(180, 0, 255),     -- Ultraviolet Overdrive (#b000ff)
    AccentSecondary = Color3.fromRGB(255, 0, 60),    -- Blood Crimson Voltage (#ff003c)
    AccentAcid = Color3.fromRGB(0, 255, 128),        -- Terminal Acid Green (#00ff80)
    AccentDark = Color3.fromRGB(30, 5, 45),          -- Pitch Void Purple (#1e052d)
    AccentGothic = Color3.fromRGB(250, 250, 255),    -- Razor Sharp Bone White (#fafaff)
    AccentSuccess = Color3.fromRGB(0, 255, 150),     -- Terminal Green Signal
    AccentWarning = Color3.fromRGB(255, 170, 0),     -- Hazard Yellow
    AccentDanger = Color3.fromRGB(255, 0, 55),       -- Critical Kernel Red
    AccentTheo = Color3.fromRGB(255, 80, 140),       -- Cyber Blood Lavender
    AccentSkull = Color3.fromRGB(255, 255, 255),     -- Pure White
    AccentCyan = Color3.fromRGB(0, 230, 255),       -- Ice Hex Blue

    -- Monospace High-Contrast Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- Bone White Terminal
    TextSecondary = Color3.fromRGB(200, 185, 230),   -- Steel Silver Violet
    TextMuted = Color3.fromRGB(120, 105, 145),       -- Dim Matrix Shadow
    TextAccent = Color3.fromRGB(255, 0, 90),         -- Blood Alert Red
    TextTheo = Color3.fromRGB(240, 140, 255),        -- Glowing Root Signature
    TextAcid = Color3.fromRGB(0, 255, 140),          -- Acid Green Monospace

    -- Fonts
    FontTitle = Enum.Font.Code,
    FontSemiBold = Enum.Font.Code,
    FontRegular = Enum.Font.Code,
    FontCode = Enum.Font.Code,

    -- Brutalist Razor Radii (Zero Round Bubbles - Razor-Sharp Cyberpunk Edges)
    CornerLarge = UDim.new(0, 3),
    CornerMedium = UDim.new(0, 2),
    CornerSmall = UDim.new(0, 1),
    CornerPill = UDim.new(0, 2),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.12, easingStyle or Enum.EasingStyle.Linear, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create razor corner
function Theme.AddCorner(instance: Instance, radius: UDim?): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerMedium
    corner.Parent = instance
    return corner
end

-- Create sharp stroke / border
function Theme.AddStroke(instance: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- Create gradient
function Theme.AddGradient(instance: Instance, c1: Color3, c2: Color3, rotation: number?): UIGradient
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

-- Interactive Button Animation Helper with Glitch Micro-Snap
function Theme.AnimateButton(btn: TextButton, onClick: (() -> ())?)
    local origSize = btn.Size
    local origBg = btn.BackgroundColor3

    pcall(function()
        btn.MouseEnter:Connect(function()
            Theme.Tween(btn, 0.1, {
                BackgroundColor3 = (btn.BackgroundColor3 == Theme.CardBg) and Theme.CardHover or btn.BackgroundColor3
            })
        end)

        btn.MouseLeave:Connect(function()
            Theme.Tween(btn, 0.1, {
                BackgroundColor3 = origBg
            })
        end)

        btn.MouseButton1Down:Connect(function()
            Theme.Tween(btn, 0.04, {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
            })
        end)

        btn.MouseButton1Up:Connect(function()
            Theme.Tween(btn, 0.06, {
                Size = origSize
            })
        end)
    end)

    if onClick then
        if btn.Activated then
            btn.Activated:Connect(onClick)
        else
            btn.MouseButton1Click:Connect(onClick)
        end
    end
end

-- Dual-Color High-Voltage Neon Pulse (Blood Crimson <-> Radioactive Violet)
function Theme.StartNeonPulse(stroke: UIStroke, baseColor: Color3?, neonColor: Color3?, speed: number?)
    local c1 = baseColor or Theme.BorderLight
    local c2 = neonColor or Theme.BorderNeon
    local spd = speed or 3.2
    
    local conn
    pcall(function()
        conn = RunService.RenderStepped:Connect(function()
            if not stroke or not stroke.Parent then
                if conn then conn:Disconnect() end
                return
            end
            local t = (math.sin(os.clock() * spd) + 1) * 0.5
            stroke.Color = Color3.new(
                c1.R + (c2.R - c1.R) * t,
                c1.G + (c2.G - c1.G) * t,
                c1.B + (c2.B - c1.B) * t
            )
            stroke.Thickness = 1.2 + t * 0.9
        end)
    end)
    return conn
end

-- Random Hex Stream Generator for Live Kernel Aesthetic
local HEX_CHARS = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
function Theme.GenerateHexStream(length: number?): string
    local len = length or 8
    local out = {}
    for i = 1, len do
        table.insert(out, "0x" .. HEX_CHARS[math.random(1, 16)] .. HEX_CHARS[math.random(1, 16)])
    end
    return table.concat(out, " ")
end

return Theme
