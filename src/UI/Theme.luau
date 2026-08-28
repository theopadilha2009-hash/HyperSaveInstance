--[[
    HyperSaveInstance - Bubble UI & Translucent Acrylic Design System
    Created by Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Pure Purple & Black Translucent Acrylic Palette
    Background = Color3.fromRGB(7, 5, 13),          -- Deep Obsidian Black
    BackgroundTransparency = 0.06,                  -- Frosted Glass Depth
    CardBg = Color3.fromRGB(16, 12, 28),            -- Translucent Purple-Black
    CardTransparency = 0.2,                         -- Acrylic Window Effect
    CardHover = Color3.fromRGB(30, 22, 52),         -- Smooth Violet Hover
    CardActive = Color3.fromRGB(48, 32, 82),        -- Solid Active Violet
    Border = Color3.fromRGB(56, 40, 88),            -- Subtle Purple Border
    BorderTransparency = 0.35,                      -- Soft Border Blend
    BorderLight = Color3.fromRGB(139, 92, 246),     -- Electric Violet Stroke
    BorderNeon = Color3.fromRGB(168, 85, 247),      -- Glowing Purple Neon
    
    -- Solid, Rich Accent Colors
    AccentPrimary = Color3.fromRGB(139, 92, 246),   -- Electric Royal Purple (#8b5cf6)
    AccentSecondary = Color3.fromRGB(168, 85, 247), -- Bright Radiant Violet (#a855f7)
    AccentDark = Color3.fromRGB(91, 33, 182),       -- Deep Amethyst (#5b21b6)
    AccentCyan = Color3.fromRGB(216, 180, 254),     -- Light Lavender (#d8b4fe)
    AccentSuccess = Color3.fromRGB(168, 85, 247),   -- Solid Purple (#a855f7)
    AccentWarning = Color3.fromRGB(232, 121, 249),   -- Vivid Magenta (#e879f9)
    AccentDanger = Color3.fromRGB(244, 63, 94),     -- Vivid Rose (#f43f5e)
    AccentTheo = Color3.fromRGB(240, 171, 252),     -- Hot Lavender (#f0abfc)
    AccentSkull = Color3.fromRGB(255, 255, 255),    -- Crisp Pure White (#ffffff)

    -- Modern Crisp Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),    -- Pure White
    TextSecondary = Color3.fromRGB(216, 180, 254),  -- Soft Lilac
    TextMuted = Color3.fromRGB(156, 140, 180),      -- Muted Ash Violet
    TextAccent = Color3.fromRGB(192, 132, 252),     -- Bright Violet
    TextCyan = Color3.fromRGB(233, 213, 255),       -- Pale Lavender
    TextTheo = Color3.fromRGB(245, 208, 254),       -- Glowing Lavender

    -- Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Smooth Bubble Radii ("Mais Bolha")
    CornerLarge = UDim.new(0, 16),
    CornerMedium = UDim.new(0, 12),
    CornerSmall = UDim.new(0, 8),
    CornerPill = UDim.new(1, 0),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create rounded bubble corner
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

-- Interactive Button Animation Helper (Hover Spring & Click Feedback)
function Theme.AnimateButton(btn: TextButton, onClick: (() -> ())?)
    local origSize = btn.Size
    local origBg = btn.BackgroundColor3
    
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
        Theme.Tween(btn, 0.08, {
            Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
        })
    end)

    btn.MouseButton1Up:Connect(function()
        Theme.Tween(btn, 0.12, {
            Size = origSize
        })
    end)

    if onClick then
        btn.MouseButton1Click:Connect(onClick)
    end
end

return Theme
