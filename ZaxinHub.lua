--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// WHITELIST ATUALIZADA (10pereirazzk com todos os cargos)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner/Developer/Admin", -- Cargos totais atribuídos
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS DE CONTROLE
local flying = false
local flySpeed = 50
local flyConn, bodyVelocity, bodyGyro
local invisivel = false

--// FUNÇÃO FLY (SISTEMA DINÂMICO)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(0,0,0) end
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
    bodyGyro.CFrame = root.CFrame

    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root or not hum then return end
        hum.PlatformStand = true
        
        local moveDir = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        
        bodyGyro.CFrame = camCF
        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

--// INVISIBILIDADE FE
local function ToggleInvis(state)
    invisivel = state
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = state and 1 or 0
            if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
        end
        if part:IsA("Accessory") and state then part.Handle.Transparency = 1 end
    end
end

--// COMANDOS DE CHAT
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() or alvo == "all" then
        if cmd == ";fly" then StartFly()
        elseif cmd == ";unfly" then StopFly()
        elseif cmd == ";kill" then LocalPlayer.Character:BreakJoints()
        elseif cmd == ";kick" then LocalPlayer:Kick("Admin Command: " .. autorNome)
        elseif cmd == ";view" then Camera.CameraSubject = Players:FindFirstChild(autorNome).Character.Humanoid
        elseif cmd == ";unview" then Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// INTERFACE WINDUI (UNIFICADA)
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Premium V9",
        Author = "ZaxinX",
        Size = UDim2.fromOffset(550, 500)
    })

    -- ABA SELF
    local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
    TabSelf:Section({Title = "Movimentação & Física"})
    
    TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})
    TabSelf:Slider({Title = "Velocidade do Voo", Min = 10, Max = 500, Default = 50, Callback = function(v) flySpeed = v end})
    TabSelf:Slider({Title = "Gravidade do Mundo", Min = 0, Max = 196, Default = 196, Callback = function(v) workspace.Gravity = v end})
    TabSelf:Toggle({Title = "Invisibilidade (FE)", Value = false, Callback = function(s) ToggleInvis(s) end})

    -- ABA ADMIN
    local TabAdmin = Window:Tab({Title = "Admin", Icon = "shield"})
    local SecAdmin = TabAdmin:Section({Title = "Gerenciar Jogadores", Opened = true})

    local selecionado
    local Dropdown = SecAdmin:Dropdown({
        Title = "Selecionar Alvo",
        Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
        Callback = function(v) selecionado = v end
    })
    
    Players.PlayerAdded:Connect(function() 
        local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end
        Dropdown:SetValues(t)
    end)

    local function SendCmd(cmd)
        if selecionado then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(cmd .. " " .. selecionado) end
        end
    end

    SecAdmin:Button({Title = "KILL", Callback = function() SendCmd(";kill") end})
    SecAdmin:Button({Title = "KICK", Callback = function() SendCmd(";kick") end})
    SecAdmin:Button({Title = "VIEW", Callback = function() 
        local target = Players:FindFirstChild(selecionado)
        if target then Camera.CameraSubject = target.Character.Humanoid end
    end})
    SecAdmin:Button({Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})
end

print("Zaxin Hub V9: Whitelist Atualizada para 10pereirazzk e Fly Corrigido!")
