--// SERVIÇOS
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// WHITELIST (10pereirazzk com acesso total)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner/Developer/Admin",
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS
local flying = false
local flySpeed = 50
local flyConn, bodyVelocity, bodyGyro
local flingEnabled = false
local flingAnim

--// FUNÇÃO FLING BALL (GIRAR E ARREMESSAR)
local function ToggleFling(state)
    flingEnabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if state and root then
        -- Cria a força de rotação extrema
        local angularVelocity = Instance.new("BodyAngularVelocity")
        angularVelocity.Name = "FlingForce"
        angularVelocity.Parent = root
        angularVelocity.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        angularVelocity.AngularVelocity = Vector3.new(0, 99999, 0) -- Velocidade do giro
        
        -- Deixa o personagem "escorregadio" para não travar nos outros
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
    else
        if root and root:FindFirstChild("FlingForce") then
            root.FlingForce:Destroy()
        end
    end
end

--// FUNÇÃO TELEPORTE
local function TeleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

--// FUNÇÃO INVISIBILIDADE (FE)
local function ToggleInvis(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = state and 1 or (v.Name == "HumanoidRootPart" and 1 or 0)
        end
        if v:IsA("Accessory") then
            v.Handle.Transparency = state and 1 or 0
        end
    end
end

--// FUNÇÃO FLY
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly()
    flying = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root then return end
        hum.PlatformStand = true
        local moveDir = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        
        bodyGyro.CFrame = camCF
        bodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.new(0,0,0)
    end)
end

--// INTERFACE WINDUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Zaxin Hub | V13 Fling",
    Author = "ZaxinX",
    Size = UDim2.fromOffset(550, 550)
})

local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
TabSelf:Section({Title = "Combate & Movimentação"})

-- Novo Botão Fling Ball
TabSelf:Toggle({
    Title = "Ativar Fling Ball (Girar)",
    Value = false,
    Callback = function(s) ToggleFling(s) end
})

TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})

TabSelf:Slider({
    Title = "Velocidade Voo",
    Min = 1, Max = 1000, Default = 50,
    Callback = function(v) flySpeed = v end
})

TabSelf:Slider({
    Title = "Gravidade",
    Min = 0, Max = 500, Default = 196,
    Callback = function(v) workspace.Gravity = v end
})

TabSelf:Toggle({Title = "Invisível (FE)", Value = false, Callback = function(s) ToggleInvis(s) end})

local TabAdmin = Window:Tab({Title = "Admin & TP", Icon = "shield"})
local SecAdmin = TabAdmin:Section({Title = "Alvos"})

local selecionado
local Dropdown = SecAdmin:Dropdown({
    Title = "Selecionar Alvo",
    Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
    Callback = function(v) selecionado = v end
})

SecAdmin:Button({Title = "TP ATÉ ELE", Callback = function() if selecionado then TeleportToPlayer(selecionado) end end})
SecAdmin:Button({Title = "KILL", Callback = function() if selecionado then TextChatService.TextChannels.RBXGeneral:SendAsync(";kill " .. selecionado) end end})
SecAdmin:Button({Title = "VIEW", Callback = function() if selecionado then Camera.CameraSubject = Players[selecionado].Character.Humanoid end end})
SecAdmin:Button({Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

print("Zaxin Hub V13: Fling Ball adicionado e Sliders com digitação!")
