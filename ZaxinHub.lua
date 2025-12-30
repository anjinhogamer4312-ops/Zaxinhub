--// SERVIÇOS
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// WHITELIST (Acesso Total: 10pereirazzk)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner/Developer/Admin",
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS DE CONTROLE
local flySpeed = 50
local flying = false
local selecionado = nil
local flyConn

--// FUNÇÃO FLY CORRIGIDA (NÃO TRAVA AO MOVER)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
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

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flying or not root then return end
        hum.PlatformStand = true
        
        local moveDir = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0,-1,0) end
        
        if moveDir.Magnitude > 0 then
            root.CFrame = root.CFrame + (moveDir.Unit * flySpeed * dt)
        end
        root.Velocity = Vector3.new(0,0,0) -- Impede gravidade de puxar ou travar
    end)
end

--// FUNÇÃO FLING (ARREMESSA O ALVO, NÃO VOCÊ)
local function FlingTarget(targetName)
    local target = Players:FindFirstChild(targetName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local oldCF = root.CFrame
        
        -- Cria uma força invisível de giro
        local bva = Instance.new("BodyAngularVelocity", root)
        bva.AngularVelocity = Vector3.new(0, 999999, 0)
        bva.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        local start = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if tick() - start > 1.2 or not tRoot then
                conn:Disconnect()
                bva:Destroy()
                root.CFrame = oldCF
                return
            end
            -- Colide com o alvo em alta velocidade para arremessar
            root.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
        end)
    end
end

--// INTERFACE WINDUI V19
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Zaxin Hub | V19 FINAL FIX",
    Author = "ZaxinX",
    Size = UDim2.fromOffset(550, 560)
})

local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
local SecDigit = TabSelf:Section({Title = "Configurações Numéricas"})

-- INPUTS PARA NÚMEROS (VELOCIDADE E GRAVIDADE)
SecDigit:Input({
    Title = "Velocidade Fly (Digite número)",
    Placeholder = "Ex: 100",
    Callback = function(t) flySpeed = tonumber(t) or flySpeed end
})

SecDigit:Input({
    Title = "Gravidade (Digite número)",
    Placeholder = "Normal: 196",
    Callback = function(t) workspace.Gravity = tonumber(t) or workspace.Gravity end
})

TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})
TabSelf:Toggle({Title = "Invisibilidade FE", Value = false, Callback = function(s)
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end
    end
end})

-- ABA ADMIN
local TabAdmin = Window:Tab({Title = "Admin & TP", Icon = "shield"})
local SecAd = TabAdmin:Section({Title = "Ações no Alvo Selecionado"})

SecAd:Dropdown({
    Title = "Selecionar Jogador",
    Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
    Callback = function(v) selecionado = v end
})

-- OPÇÕES DE COMBATE E ADMIN
SecAd:Button({Title = "FLING (ARREMESSAR ALVO)", Callback = function() if selecionado then FlingTarget(selecionado) end end})

SecAd:Button({Title = "KILL (MATAR)", Callback = function()
    if selecionado then 
        -- Método Kill via Chat ou Fling Rápido
        FlingTarget(selecionado)
        TextChatService.TextChannels.RBXGeneral:SendAsync(";kill " .. selecionado) 
    end
end})

SecAd:Button({Title = "KICK (EXPULSAR)", Callback = function()
    if selecionado then TextChatService.TextChannels.RBXGeneral:SendAsync(";kick " .. selecionado) end
end})

SecAd:Button({Title = "TP ATÉ ELE", Callback = function()
    if selecionado and Players:FindFirstChild(selecionado) then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Players[selecionado].Character.HumanoidRootPart.CFrame
    end
end})

SecAd:Button({Title = "VIEW", Callback = function() if selecionado then Camera.CameraSubject = Players[selecionado].Character.Humanoid end end})
SecAd:Button({Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

print("Zaxin Hub V19: Fly estável e Fling por alvo pronto!")
