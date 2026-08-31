--[[
    HyperSaveInstance - High-End Dark Gothic Cyberpunk & Neon Design System
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Dark Gothic Cyberpunk Palette (Deep Obsidian, Pitch Black & Vivid Ultraviolet Neon)
    Background = Color3.fromRGB(5, 4, 9),             -- Ultra-deep Void Black (#050409)
    BackgroundTransparency = 0.04,                   -- Dense frosted dark glass
    CardBg = Color3.fromRGB(11, 9, 18),               -- Dark Obsidian Panel (#0b0912)
    CardTransparency = 0.1,                          -- High opacity solid glass
    CardHover = Color3.fromRGB(26, 18, 44),          -- Subtle Ultraviolet hover
    CardActive = Color3.fromRGB(46, 20, 80),         -- Active glowing violet
    Border = Color3.fromRGB(38, 26, 62),             -- Dark alloy border
    BorderTransparency = 0.2,
    BorderLight = Color3.fromRGB(147, 51, 234),      -- Vivid Purple Stroke (#9333ea)
    BorderNeon = Color3.fromRGB(168, 85, 247),       -- Ultra Neon Violet Glow (#a855f7)
    BorderCyber = Color3.fromRGB(192, 132, 252),     -- Electric Lavender (#c084fc)
    
    -- Accents
    AccentPrimary = Color3.fromRGB(126, 34, 206),    -- Deep Electric Purple (#7e22ce)
    AccentSecondary = Color3.fromRGB(168, 85, 247),  -- Neon Violet (#a855f7)
    AccentDark = Color3.fromRGB(59, 7, 100),         -- Midnight Amethyst (#3b0764)
    AccentGothic = Color3.fromRGB(248, 250, 252),    -- Razor Crisp Bone White (#f8fafc)
    AccentSuccess = Color3.fromRGB(168, 85, 247),    -- Neon Purple
    AccentWarning = Color3.fromRGB(232, 121, 249),   -- Vivid Magenta (#e879f9)
    AccentDanger = Color3.fromRGB(244, 63, 94),      -- Neon Crimson (#f43f5e)
    AccentTheo = Color3.fromRGB(216, 180, 254),      -- Glowing Cyber Lavender (#d8b4fe)
    AccentSkull = Color3.fromRGB(255, 255, 255),     -- Pure White

    -- High-Contrast Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- Crisp Bone White
    TextSecondary = Color3.fromRGB(203, 185, 235),   -- Muted Violet Silver
    TextMuted = Color3.fromRGB(130, 115, 160),       -- Shadow Violet
    TextAccent = Color3.fromRGB(192, 132, 252),      -- Cyber Violet
    TextTheo = Color3.fromRGB(233, 213, 255),        -- Pale Lavender

    -- Modern Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Sharp Geometric Radii (Sleek, High-Tech Gothic Curves)
    CornerLarge = UDim.new(0, 10),
    CornerMedium = UDim.new(0, 7),
    CornerSmall = UDim.new(0, 5),
    CornerPill = UDim.new(1, 0),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.18, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create rounded corner
function Theme.AddCorner(instance: Instance, radius: UDim?): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerMedium
    corner.Parent = instance
    return corner
end

-- Create stroke / border
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

-- Interactive Button Animation Helper
function Theme.AnimateButton(btn: TextButton, onClick: (() -> ())?)
    local origSize = btn.Size
    local origBg = btn.BackgroundColor3

    pcall(function()
        btn.MouseEnter:Connect(function()
            Theme.Tween(btn, 0.15, {
                BackgroundColor3 = (btn.BackgroundColor3 == Theme.CardBg) and Theme.CardHover or btn.BackgroundColor3
            })
        end)

        btn.MouseLeave:Connect(function()
            Theme.Tween(btn, 0.15, {
                BackgroundColor3 = origBg
            })
        end)

        btn.MouseButton1Down:Connect(function()
            Theme.Tween(btn, 0.06, {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
            })
        end)

        btn.MouseButton1Up:Connect(function()
            Theme.Tween(btn, 0.1, {
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

-- Animated Neon Pulse Glow for Hero Buttons
function Theme.StartNeonPulse(stroke: UIStroke, baseColor: Color3?, neonColor: Color3?, speed: number?)
    local RunService = game:GetService("RunService")
    local c1 = baseColor or Theme.BorderLight
    local c2 = neonColor or Theme.BorderNeon
    local spd = speed or 2.5
    
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
            stroke.Thickness = 1.2 + t * 0.8
        end)
    end)
    return conn
end

return Theme
