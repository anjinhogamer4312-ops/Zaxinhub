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
local selecionado = nil

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

--// FUNÇÃO FLING TARGET (ARREMESSAR PLAYER SELECIONADO)
local function FlingPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            -- Armazena posição original
            local oldCF = root.CFrame
            -- Ativa força de giro
            local bva = Instance.new("BodyAngularVelocity", root)
            bva.AngularVelocity = Vector3.new(0, 99999, 0)
            bva.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            
            -- Teleporta para o alvo repetidamente para garantir o fling
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not target.Character or not bva.Parent then connection:Disconnect() return end
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1)
            end)
            
            task.wait(0.5) -- Tempo do ataque
            connection:Disconnect()
            bva:Destroy()
            root.CFrame = oldCF -- Volta para onde estava
        end
    end
end

--// INTERFACE WINDUI V15
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Zaxin Hub | V15 Fling Player",
    Author = "ZaxinX",
    Size = UDim2.fromOffset(550, 550)
})

-- ABA SELF (CONFIGURAÇÕES)
local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
local SecDigit = TabSelf:Section({Title = "Configurações (Clique e Digite)"})

SecDigit:Input({
    Title = "Definir Velocidade Fly",
    Placeholder = "Ex: 150",
    Callback = function(t) flySpeed = tonumber(t) or flySpeed end
})

SecDigit:Input({
    Title = "Definir Gravidade",
    Placeholder = "Ex: 50",
    Callback = function(t) workspace.Gravity = tonumber(t) or workspace.Gravity end
})

TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})
TabSelf:Toggle({Title = "Invisibilidade FE", Value = false, Callback = function(s)
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end
    end
end})

-- ABA ADMIN (AÇÕES NO ALVO)
local TabAdmin = Window:Tab({Title = "Admin & TP", Icon = "shield"})
local SecAdmin = TabAdmin:Section({Title = "Gerenciar Jogador"})

SecAdmin:Dropdown({
    Title = "Selecionar Alvo",
    Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
    Callback = function(v) selecionado = v end
})

SecAdmin:Button({
    Title = "FLING (ARREMESSAR ALVO)",
    Callback = function() if selecionado then FlingPlayer(selecionado) end end
})

SecAdmin:Button({
    Title = "KICK (EXPULSAR)",
    Callback = function() if selecionado then TextChatService.TextChannels.RBXGeneral:SendAsync(";kick " .. selecionado) end end
})

SecAdmin:Button({
    Title = "KILL (MATAR)",
    Callback = function() if selecionado then TextChatService.TextChannels.RBXGeneral:SendAsync(";kill " .. selecionado) end end
})

SecAdmin:Button({
    Title = "TP ATÉ ELE",
    Callback = function() 
        local t = Players:FindFirstChild(selecionado)
        if t then LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end 
    end
})

SecAdmin:Button({Title = "VIEW", Callback = function() Camera.CameraSubject = Players[selecionado].Character.Humanoid end})
SecAdmin:Button({Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

print("Zaxin Hub V15: Fling por seleção e Inputs numéricos prontos!")
