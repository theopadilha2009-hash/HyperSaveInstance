--[[
    HyperSaveInstance - Professional High-Contrast Dark Theme
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Design: Clean, Crisp, High-Contrast Modern Dark UI (Inspired by VS Code, Raycast, Discord)
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Theme = {
    -- High-Contrast Professional Dark Palettes
    Background = Color3.fromRGB(15, 17, 23),          -- Crisp Modern Slate Dark (#0f1117)
    BackgroundTransparency = 0.02,                   -- Solid, high-readability background
    CardBg = Color3.fromRGB(24, 27, 36),              -- Clean Elevated Card (#181b24)
    CardTransparency = 0.0,                          -- Non-blurry, sharp solid surface
    CardHover = Color3.fromRGB(34, 38, 50),          -- Smooth Hover State
    CardActive = Color3.fromRGB(45, 51, 68),         -- Selected Active Core
    
    -- Crisp, Clean Borders (1px sharp strokes)
    Border = Color3.fromRGB(48, 54, 70),             -- Clean subtle border (#303646)
    BorderTransparency = 0.0,
    BorderLight = Color3.fromRGB(59, 130, 246),      -- High-visibility Blue (#3b82f6)
    BorderNeon = Color3.fromRGB(99, 102, 241),       -- Clean Indigo Accent (#6366f1)
    BorderCyber = Color3.fromRGB(14, 165, 233),      -- Sky Cyan Highlight (#0ea5e9)
    
    -- Vibrant Primary & Semantic Accents
    AccentPrimary = Color3.fromRGB(37, 99, 235),    -- Royal Blue (High Visibility)
    AccentSecondary = Color3.fromRGB(79, 70, 229),  -- Solid Indigo
    AccentAcid = Color3.fromRGB(16, 185, 129),       -- Emerald Green
    AccentDark = Color3.fromRGB(20, 23, 31),         -- Deep Background
    AccentGothic = Color3.fromRGB(255, 255, 255),    -- Pure White
    AccentSuccess = Color3.fromRGB(16, 185, 129),    -- Emerald Success
    AccentWarning = Color3.fromRGB(245, 158, 11),    -- Amber Warning
    AccentDanger = Color3.fromRGB(239, 68, 68),      -- Coral Red
    AccentTheo = Color3.fromRGB(99, 102, 241),       -- Clean Indigo Signature
    AccentSkull = Color3.fromRGB(255, 255, 255),     -- Pure White
    AccentCyan = Color3.fromRGB(14, 165, 233),       -- Sky Cyan
 
    -- Crystal-Clear High-Contrast Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- Pure High-Contrast White (#ffffff)
    TextSecondary = Color3.fromRGB(203, 213, 225),   -- Slate 300 (Clean & Easy to Read)
    TextMuted = Color3.fromRGB(148, 163, 184),       -- Slate 400 (Readable Secondary)
    TextAccent = Color3.fromRGB(59, 130, 246),       -- Blue Highlight
    TextTheo = Color3.fromRGB(99, 102, 241),         -- Indigo Highlight
    TextAcid = Color3.fromRGB(16, 185, 129),         -- Emerald Green
 
    -- Modern Clean Fonts (Gotham Family)
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamMedium,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Gotham,
 
    -- Clean Rounded Radii
    CornerLarge = UDim.new(0, 10),
    CornerMedium = UDim.new(0, 8),
    CornerSmall = UDim.new(0, 6),
    CornerPill = UDim.new(0, 18),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
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

-- Create clean solid stroke / border
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

-- Gentle Audio Click Feedback
function Theme.PlayClick()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://9069609200"
        s.Volume = 0.18
        s.Pitch = 1.4
        s.Parent = SoundService
        s:Play()
        task.delay(0.8, function() s:Destroy() end)
    end)
end

function Theme.PlayGlitch()
    -- Kept silent for clean professional experience
end

-- Interactive Button Animation Helper
function Theme.AnimateButton(btn: TextButton, onClick: (() -> ())?)
    local origSize = btn.Size
    local origBg = btn.BackgroundColor3

    pcall(function()
        btn.MouseEnter:Connect(function()
            Theme.Tween(btn, 0.12, {
                BackgroundColor3 = (btn.BackgroundColor3 == Theme.CardBg) and Theme.CardHover or btn.BackgroundColor3
            })
        end)

        btn.MouseLeave:Connect(function()
            Theme.Tween(btn, 0.12, {
                BackgroundColor3 = origBg
            })
        end)

        btn.MouseButton1Down:Connect(function()
            Theme.Tween(btn, 0.05, {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
            })
            Theme.PlayClick()
        end)

        btn.MouseButton1Up:Connect(function()
            Theme.Tween(btn, 0.08, {
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

-- Clean Static Border Accent
function Theme.StartNeonPulse(stroke: UIStroke, baseColor: Color3?, neonColor: Color3?, speed: number?)
    if stroke then
        stroke.Color = baseColor or Theme.BorderLight
        stroke.Thickness = 1
    end
    return nil
end

-- Formatted Metric String Helpers
function Theme.GenerateHexStream(length: number?): string
    return "STABLE"
end

function Theme.GenerateActivityGraph(): string
    return "ONLINE"
end

-- Instant text display without lagging or scrambling
function Theme.ScrambleText(label: TextLabel, targetText: string, duration: number?)
    pcall(function() label.Text = targetText end)
end

return Theme
