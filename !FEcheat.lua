--[[
    Чит-меню v11 (Обновлено)
    - ShiftLock: возвращена и улучшена.
    - Moonwalk: сохранена.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Цвета и настройки дизайна
local colors = {
    background = Color3.fromRGB(35, 38, 46),
    primary = Color3.fromRGB(44, 48, 58),
    accent = Color3.fromRGB(114, 137, 218),
    text = Color3.fromRGB(255, 255, 255),
    enabled = Color3.fromRGB(88, 101, 242),
    red = Color3.fromRGB(255, 80, 80)
}
local cornerRadius = UDim.new(0, 8)

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = colors.background
MainFrame.BorderColor3 = colors.accent
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.015, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 250)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = cornerRadius

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = colors.background
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "FEcheat"
TitleLabel.TextColor3 = colors.text
TitleLabel.TextSize = 20
local titleCorner = Instance.new("UICorner", TitleLabel)
titleCorner.CornerRadius = UDim.new(0, 8)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = TitleLabel
ToggleButton.BackgroundColor3 = colors.background
ToggleButton.BackgroundTransparency = 1
ToggleButton.Position = UDim2.new(1, -35, 0.5, -15)
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "-"
ToggleButton.TextColor3 = colors.text
ToggleButton.TextSize = 30

local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.BackgroundColor3 = colors.background
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 0, 0, 40)
ButtonContainer.Size = UDim2.new(1, 0, 1, -40)
ButtonContainer.BorderSizePixel = 0
ButtonContainer.ScrollBarThickness = 4

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Parent = ButtonContainer
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Padding = UDim.new(0, 8)
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Вспомогательные функции
local function animateHover(button)
    button.MouseEnter:Connect(function()
        if not button:GetAttribute("Enabled") then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if not button:GetAttribute("Enabled") then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.primary}):Play()
        end
    end)
end

local function createButton(name, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = ButtonContainer
    button.BackgroundColor3 = colors.primary
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.TextColor3 = colors.text
    button.TextSize = 16
    button:SetAttribute("Enabled", false)
    Instance.new("UICorner", button).CornerRadius = cornerRadius
    animateHover(button)
    return button
end

local function createSlider(name, text, min, max, default)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name
    sliderFrame.Parent = ButtonContainer
    sliderFrame.BackgroundColor3 = colors.background
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.Visible = false
    local label = Instance.new("TextLabel")
    label.Parent = sliderFrame
    label.BackgroundColor3 = colors.background
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Font = Enum.Font.SourceSans
    label.TextColor3 = colors.text
    label.TextSize = 16
    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = sliderFrame
    sliderBar.BackgroundColor3 = colors.primary
    sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 5)
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBar
    sliderFill.BackgroundColor3 = colors.accent
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 5)
    local value = default
    local function updateSlider(x)
        local percentage = math.clamp((x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * percentage
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        label.Text = text .. ": " .. string.format("%.1f", value)
    end
    updateSlider(sliderBar.AbsolutePosition.X + ((default - min) / (max - min)) * sliderBar.AbsoluteSize.X)
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position.X)
            local moveConn, releaseConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(moveInput.Position.X)
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    moveConn:Disconnect() releaseConn:Disconnect()
                end
            end)
        end
    end)
    return sliderFrame, function() return value end
end

-- Создание элементов
local ESPButton = createButton("ESPButton", "ESP"); ESPButton.LayoutOrder = 1
local ChamsButton = createButton("ChamsButton", "Chams"); ChamsButton.LayoutOrder = 2
local NoclipButton = createButton("NoclipButton", "Noclip"); NoclipButton.LayoutOrder = 3
local BunnyHopButton = createButton("BunnyHopButton", "BunnyHop"); BunnyHopButton.LayoutOrder = 4
local InfiniteJumpButton = createButton("InfiniteJumpButton", "Беск. Прыжок"); InfiniteJumpButton.LayoutOrder = 5
local ShiftLockButton = createButton("ShiftLockButton", "Shift Lock"); ShiftLockButton.LayoutOrder = 6
local MoonwalkButton = createButton("MoonwalkButton", "Лунная походка"); MoonwalkButton.LayoutOrder = 7
local FullbrightButton = createButton("FullbrightButton", "Fullbright"); FullbrightButton.LayoutOrder = 8
local EnableSpeedButton = createButton("EnableSpeedButton", "Скорость"); EnableSpeedButton.LayoutOrder = 9
local SpeedSlider, getSpeed = createSlider("SpeedSlider", "Скорость", 16, 200, 16); SpeedSlider.LayoutOrder = 10
local EnableJumpButton = createButton("JumpPowerButton", "Сила прыжка"); EnableJumpButton.LayoutOrder = 11
local JumpSlider, getJumpPower = createSlider("JumpSlider", "Сила прыжка", 50, 500, 50); JumpSlider.LayoutOrder = 12
local EnableZoomButton = createButton("EnableZoomButton", "Zoom"); EnableZoomButton.LayoutOrder = 13
local ZoomSlider, getZoom = createSlider("ZoomSlider", "Zoom", -100, 100, 0); ZoomSlider.LayoutOrder = 14
local SpinButton = createButton("SpinButton", "Spin Bot"); SpinButton.LayoutOrder = 15
local SpinSpeedSlider, getSpinSpeed = createSlider("SpinSpeedSlider", "Скорость", 1, 100, 10); SpinSpeedSlider.LayoutOrder = 16
local AimbotButton = createButton("AimbotButton", "Aimbot"); AimbotButton.LayoutOrder = 17
local TPButton = createButton("TPButton", "TP to Player"); TPButton.LayoutOrder = 18
local HitboxButton = createButton("HitboxButton", "Hitbox"); HitboxButton.LayoutOrder = 19
local HitboxSlider, getHitboxSize = createSlider("HitboxSlider", "Размер хитбокса", 1, 10, 1); HitboxSlider.LayoutOrder = 20
local EnableGravityButton = createButton("EnableGravityButton", "Гравитация"); EnableGravityButton.LayoutOrder = 21
local GravitySlider, getGravity = createSlider("GravitySlider", "Сила", 0, 250, 196.2); GravitySlider.LayoutOrder = 22

-- Переменные состояния
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local defaultGravity = Workspace.Gravity
local defaultFogEnd = game.Lighting.FogEnd
local defaultFogStart = game.Lighting.FogStart
local hitboxVisuals = {}
local originalAutoRotate = humanoid.AutoRotate

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    if hitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                createHitboxForPlayer(p)
            end
        end
    end
end)

local function toggleFeature(button, enabled)
    button:SetAttribute("Enabled", enabled)
    if enabled then
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.enabled}):Play()
    else
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.primary}):Play()
    end
end

-- ESP
local espEnabled = false
local drawings = {}
local skeletonConnectionsR15 = {
	["Head"] = "UpperTorso", ["UpperTorso"] = "LowerTorso", ["UpperTorso"] = "LeftUpperArm", ["UpperTorso"] = "RightUpperArm",
	["LeftUpperArm"] = "LeftLowerArm", ["RightUpperArm"] = "RightLowerArm", ["LeftLowerArm"] = "LeftHand", ["RightLowerArm"] = "RightHand",
	["LowerTorso"] = "LeftUpperLeg", ["LowerTorso"] = "RightUpperLeg", ["LeftUpperLeg"] = "LeftLowerLeg", ["RightUpperLeg"] = "RightLowerLeg",
	["LeftLowerLeg"] = "LeftFoot", ["RightLowerLeg"] = "RightFoot",
}
local skeletonConnectionsR6 = {
    ["Head"] = "Torso", ["Torso"] = "Left Arm", ["Torso"] = "Right Arm", ["Torso"] = "Left Leg", ["Torso"] = "Right Leg",
}
local function clearDrawings()
    for _, v in pairs(drawings) do v:Remove() end; drawings = {}
end
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled; toggleFeature(ESPButton, espEnabled)
    if not espEnabled then clearDrawings() end
end)

-- Chams
local chamsEnabled = false
local chamsHighlights = {}
ChamsButton.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled; toggleFeature(ChamsButton, chamsEnabled)
    if not chamsEnabled then
        for _, h in pairs(chamsHighlights) do h:Destroy() end; chamsHighlights = {}
    end
end)

-- Noclip
local noclipEnabled = false
local noclipConnection = nil
NoclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled; toggleFeature(NoclipButton, noclipEnabled)
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if humanoid and humanoid.Health > 0 then
                humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if humanoid and humanoid.Health > 0 then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)

-- BunnyHop
local bhopEnabled = false
local bhopConnection = nil
BunnyHopButton.MouseButton1Click:Connect(function()
    bhopEnabled = not bhopEnabled; toggleFeature(BunnyHopButton, bhopEnabled)
    if bhopEnabled then
        bhopConnection = RunService.Stepped:Connect(function()
            if humanoid and humanoid.Health > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid.Jump = true
            end
        end)
    else
        if bhopConnection then bhopConnection:Disconnect(); bhopConnection = nil end
    end
end)

-- Shift Lock
local shiftlockEnabled = false
local cameraType = 1 -- 1 = Normal, 2 = Lateral
local defaultCameraOffset = Vector3.new(0, 0, 0)
local lateralCameraOffset = Vector3.new(0, 0, -5)

ShiftLockButton.MouseButton1Click:Connect(function()
    shiftlockEnabled = not shiftlockEnabled
    toggleFeature(ShiftLockButton, shiftlockEnabled)

    if shiftlockEnabled then
        -- Включаем боковой вид камеры
        cameraType = 2
        
        -- Переключаем камеру в скриптовый режим
        Players.LocalPlayer.CameraMode = Enum.CameraMode.Scriptable
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        -- Привязываем камеру к персонажу
        local camera = Workspace.CurrentCamera
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            camera.CFrame = CFrame.new(hrp.Position + lateralCameraOffset)
            
        end
    else
        -- Возвращаем нормальный вид камеры
        cameraType = 1
        
        -- Возвращаем стандартный режим камеры
        Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- Лунная походка
local moonwalkEnabled = false
MoonwalkButton.MouseButton1Click:Connect(function()
    moonwalkEnabled = not moonwalkEnabled
    toggleFeature(MoonwalkButton, moonwalkEnabled)
    
    if moonwalkEnabled then
        -- Выключаем автоматический поворот, чтобы персонаж не крутился
        humanoid.AutoRotate = false
    else
        -- Возвращаем стандартный поворот
        humanoid.AutoRotate = originalAutoRotate
    end
end)

-- Speed/Jump/Gravity/Spin Toggles
local speedEnabled = false
EnableSpeedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled; toggleFeature(EnableSpeedButton, speedEnabled); SpeedSlider.Visible = speedEnabled
    if not speedEnabled and humanoid then humanoid.WalkSpeed = 16 end
end)
local jumpEnabled = false
EnableJumpButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled; toggleFeature(EnableJumpButton, jumpEnabled); JumpSlider.Visible = jumpEnabled
    if not jumpEnabled and humanoid then humanoid.JumpPower = 50 end
end)
local spinEnabled = false
SpinButton.MouseButton1Click:Connect(function()
    spinEnabled = not spinEnabled; toggleFeature(SpinButton, spinEnabled); SpinSpeedSlider.Visible = spinEnabled
end)
local gravityEnabled = false
EnableGravityButton.MouseButton1Click:Connect(function()
    gravityEnabled = not gravityEnabled; toggleFeature(EnableGravityButton, gravityEnabled); GravitySlider.Visible = gravityEnabled
    if not gravityEnabled then Workspace.Gravity = defaultGravity end
end)

-- Zoom
local zoomEnabled = false
local defaultFOV = 70
EnableZoomButton.MouseButton1Click:Connect(function()
    zoomEnabled = not zoomEnabled
    toggleFeature(EnableZoomButton, zoomEnabled)
    ZoomSlider.Visible = zoomEnabled
    if not zoomEnabled and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = defaultFOV
    end
end)

-- Aimbot
local aimbotEnabled = false
local aimbotConnection = nil
AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleFeature(AimbotButton, aimbotEnabled)
    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local closestPlayer = nil
            local closestDistance = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = p
                    end
                end
            end
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = closestPlayer.Character.HumanoidRootPart
                local camera = Workspace.CurrentCamera
                local newCFrame = CFrame.new(camera.CFrame.Position, targetHRP.Position)
                camera.CFrame = newCFrame
            end
        end)
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
    end
end)

-- TP to Player
local tpConnection = nil
TPButton.MouseButton1Click:Connect(function()
    if tpConnection then
        tpConnection:Disconnect()
        tpConnection = nil
        toggleFeature(TPButton, false)
    else
        toggleFeature(TPButton, true)
        local target = nil
        tpConnection = RunService.Heartbeat:Connect(function()
            local closestDist = math.huge
            local closestPlayer = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = p
                    end
                end
            end
            target = closestPlayer
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = target.Character.HumanoidRootPart
                local newCFrame = targetHRP.CFrame * CFrame.new(0, 5, -5)
                character.HumanoidRootPart.CFrame = newCFrame
            end
        end)
    end
end)

-- Hitbox (Оптимизировано и изменено отображение)
local hitboxEnabled = false
local function createHitboxForPlayer(p)
    if not p or not p.Character then return end
    local existingVisual = hitboxVisuals[p]
    if existingVisual then return end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "HitboxVisual"
    hitbox.Transparency = 0.5
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.Parent = Workspace
    hitboxVisuals[p] = hitbox
end

local function destroyHitboxForPlayer(p)
    if hitboxVisuals[p] then
        hitboxVisuals[p]:Destroy()
        hitboxVisuals[p] = nil
    end
end

HitboxButton.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    toggleFeature(HitboxButton, hitboxEnabled)
    HitboxSlider.Visible = hitboxEnabled
    if hitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                createHitboxForPlayer(p)
            end
        end
        Players.PlayerAdded:Connect(function(p) createHitboxForPlayer(p) end)
        Players.PlayerRemoving:Connect(function(p) destroyHitboxForPlayer(p) end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            destroyHitboxForPlayer(p)
        end
    end
end)

-- Fullbright
local fullbrightEnabled = false
local originalAmbient, originalBrightness = game.Lighting.Ambient, game.Lighting.Brightness
local originalFogStart, originalFogEnd = game.Lighting.FogStart, game.Lighting.FogEnd
FullbrightButton.MouseButton1Click:Connect(function()
    fullbrightEnabled = not fullbrightEnabled; toggleFeature(FullbrightButton, fullbrightEnabled)
    if fullbrightEnabled then
        game.Lighting.Ambient = Color3.fromHSV(0, 0, 1); game.Lighting.Brightness = 1
        game.Lighting.FogStart = 10000; game.Lighting.FogEnd = 100000
    else
        game.Lighting.Ambient = originalAmbient; game.Lighting.Brightness = originalBrightness
        game.Lighting.FogStart = originalFogStart; game.Lighting.FogEnd = originalFogEnd
    end
end)

-- Other Toggles
local infiniteJumpEnabled = false
InfiniteJumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled; toggleFeature(InfiniteJumpButton, infiniteJumpEnabled)
end)
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Main Render/Update Loops
RunService.RenderStepped:Connect(function()
    if espEnabled then
        clearDrawings()
        local camera = Workspace.CurrentCamera
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                local targetChar, targetHum = targetPlayer.Character, targetPlayer.Character.Humanoid
                local connections = targetHum.RigType == Enum.HumanoidRigType.R15 and skeletonConnectionsR15 or skeletonConnectionsR6
                
                local head = targetChar:FindFirstChild("Head")
                if not head then continue end
                local headPos, vis = camera:WorldToViewportPoint(head.Position)
                if not vis or headPos.Z <= 0 then continue end
                
                for p1Name, p2Name in pairs(connections) do
                    local p1, p2 = targetChar:FindFirstChild(p1Name), targetChar:FindFirstChild(p2Name)
                    if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                        local pos1 = camera:WorldToViewportPoint(p1.Position)
                        local pos2 = camera:WorldToViewportPoint(p2.Position)
                        
                        local line = Drawing.new("Line")
                        line.Visible, line.From, line.To, line.Color, line.Thickness = true, Vector2.new(pos1.X, pos1.Y), Vector2.new(pos2.X, pos2.Y), colors.accent, 1
                        table.insert(drawings, line)
                    end
                end
                
                local root = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = character and character:FindFirstChild("HumanoidRootPart")
                if root and localRoot then
                    local dist = (localRoot.Position - root.Position).Magnitude
                    
                    local text = Drawing.new("Text")
                    text.Visible, text.Text, text.Color, text.Center, text.Size, text.Position = true, string.format("[%dм]", dist), colors.red, true, math.clamp(1000/dist, 12, 20), Vector2.new(headPos.X, headPos.Y - 25)
                    table.insert(drawings, text)
                end
            end
        end
    end
    
    if zoomEnabled and Workspace.CurrentCamera then
        local zoomValue = getZoom()
        Workspace.CurrentCamera.FieldOfView = defaultFOV - (zoomValue * 0.7)
    end
    
    if hitboxEnabled and HitboxSlider.Visible then
        local scale = getHitboxSize()
        for _, p in ipairs(Players:GetPlayers()) do
            local visual = hitboxVisuals[p]
            if visual and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                visual.Size = Vector3.new(3, 7, 3) * scale
                visual.CFrame = hrp.CFrame
            end
        end
    end
    
    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, buttonLayout.AbsoluteContentSize.Y + 20)
    
    -- Обновление камеры при включенном Shift Lock
    if shiftlockEnabled then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera
        if hrp then
            if cameraType == 2 then -- Боковой вид
                local lateralCFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(90), 0)
                camera.CFrame = CFrame.new(lateralCFrame.Position + lateralCFrame.LookVector * lateralCameraOffset.Z)
                camera.Focus = lateralCFrame
            end
        end
    end
end)


RunService.Heartbeat:Connect(function(dt)
    if chamsEnabled then
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not chamsHighlights[part] then
                            local h = Instance.new("Highlight")
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.FillTransparency = 0.5
                            h.OutlineTransparency = 1
                            h.Parent = part
                            chamsHighlights[part] = h
                        end
                        chamsHighlights[part].FillColor = color
                    end
                end
            end
        end
    end
    if not humanoid or humanoid.Health <= 0 then return end
    if speedEnabled then humanoid.WalkSpeed = getSpeed() end
    if jumpEnabled then humanoid.JumpPower = getJumpPower() end
    if gravityEnabled then Workspace.Gravity = getGravity() end
    if spinEnabled and humanoid.RootPart then
        humanoid.RootPart.CFrame *= CFrame.Angles(0, math.rad(getSpinSpeed()), 0)
    end
    
    -- Логика лунной походки
    if moonwalkEnabled and humanoid.MoveDirection.Magnitude > 0 then
        local direction = humanoid.MoveDirection
        -- Меняем направление движения на противоположное
        humanoid.MoveDirection = Vector3.new(-direction.X, 0, -direction.Z)
    end
end)

-- Menu Toggle
local menuOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    local goalSize = menuOpen and UDim2.new(0, 240, 0, 250) or UDim2.new(0, 240, 0, 40)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = goalSize}):Play()
    ToggleButton.Text = menuOpen and "-" or "+"
end)

