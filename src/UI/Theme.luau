--[[
    HyperSaveInstance - Clean Minimalist Dark Theme
    Design: Modern Solid Dark (Inspired by VS Code, Linear, Raycast)
    Focus: High contrast, crystal-clear readability, zero visual noise
]]

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Theme = {
    -- Backgrounds & Surfaces (Solid Dark Slate, High Contrast)
    Background = Color3.fromRGB(18, 20, 26),          -- #12141A Base window
    BackgroundTransparency = 0.0,                    -- Completely solid, no blur
    CardBg = Color3.fromRGB(26, 30, 40),              -- #1A1E28 Elevated container
    CardTransparency = 0.0,
    CardHover = Color3.fromRGB(36, 42, 56),          -- #242A38 Hover state
    CardActive = Color3.fromRGB(42, 48, 64),         -- #2A3040 Active state
    InputBg = Color3.fromRGB(14, 16, 22),             -- #0E1016 Textbox background
    
    -- Clean 1px Borders
    Border = Color3.fromRGB(44, 50, 66),             -- #2C3242 Subtle edge
    BorderTransparency = 0.0,
    BorderLight = Color3.fromRGB(59, 130, 246),      -- #3B82F6 Active blue border
    BorderNeon = Color3.fromRGB(59, 130, 246),       -- Clean blue border
    BorderCyber = Color3.fromRGB(59, 130, 246),
    
    -- Accents (Clean, non-clashing)
    AccentPrimary = Color3.fromRGB(37, 99, 235),    -- #2563EB Royal Blue (Action)
    AccentSecondary = Color3.fromRGB(79, 70, 229),  -- #4F46E5 Indigo
    AccentSuccess = Color3.fromRGB(16, 185, 129),    -- #10B981 Emerald
    AccentWarning = Color3.fromRGB(245, 158, 11),    -- #F59E0B Amber
    AccentDanger = Color3.fromRGB(220, 38, 38),      -- #DC2626 Coral Red
    AccentCyan = Color3.fromRGB(14, 165, 233),       -- #0EA5E9 Sky Blue
    AccentAcid = Color3.fromRGB(16, 185, 129),       -- Clean Green
    AccentSkull = Color3.fromRGB(255, 255, 255),
    AccentGothic = Color3.fromRGB(255, 255, 255),
    AccentTheo = Color3.fromRGB(59, 130, 246),
    AccentDark = Color3.fromRGB(14, 16, 22),
 
    -- Crystal-Clear Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- Pure White (#FFFFFF)
    TextSecondary = Color3.fromRGB(160, 174, 192),   -- Clean Light Gray (#A0AEC0)
    TextMuted = Color3.fromRGB(113, 128, 150),       -- Muted Slate (#718096)
    TextAccent = Color3.fromRGB(59, 130, 246),       -- Blue text highlight
    TextTheo = Color3.fromRGB(59, 130, 246),
    TextAcid = Color3.fromRGB(16, 185, 129),
 
    -- Fonts (Gotham Family for crisp native rendering)
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamMedium,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Gotham,
 
    -- Subtle Radii (Modern software standard 6-8px)
    CornerLarge = UDim.new(0, 8),
    CornerMedium = UDim.new(0, 6),
    CornerSmall = UDim.new(0, 4),
    CornerPill = UDim.new(0, 16),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.12, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
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

-- Create subtle gradient
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
        s.Volume = 0.15
        s.Pitch = 1.3
        s.Parent = SoundService
        s:Play()
        task.delay(0.6, function() s:Destroy() end)
    end)
end

function Theme.PlayGlitch()
    -- Silent for clean UI experience
end

-- Interactive Button Animation Helper
function Theme.AnimateButton(btn: TextButton, onClick: (() -> ())?)
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
    end)

    if onClick then
        if btn.Activated then
            btn.Activated:Connect(onClick)
        else
            btn.MouseButton1Click:Connect(onClick)
        end
    end
end

function Theme.StartNeonPulse(stroke: UIStroke, baseColor: Color3?, neonColor: Color3?, speed: number?)
    if stroke then
        stroke.Color = baseColor or Theme.Border
        stroke.Thickness = 1
    end
    return nil
end

function Theme.GenerateHexStream(length: number?): string
    return "Ativo"
end

function Theme.GenerateActivityGraph(): string
    return "Online"
end

function Theme.ScrambleText(label: TextLabel, targetText: string, duration: number?)
    pcall(function() label.Text = targetText end)
end

return Theme
