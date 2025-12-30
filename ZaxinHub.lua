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

--// VARIÁVEIS
local flying = false
local flySpeed = 50
local flyConn, bv, bg
local selecionado = nil

--// FUNÇÃO FLY (REVISADA - SEM TRAVAR)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(0,0,0) end
    end
end

local function StartFly()
    StopFly()
    flying = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root then return end
        hum.PlatformStand = true
        local moveDir = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        bg.CFrame = camCF
        bv.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.new(0,0,0)
    end)
end

--// FUNÇÃO FLING (PARA TIRAR QUEM NÃO USA SCRIPT)
local function FlingPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            local oldCF = root.CFrame
            local bva = Instance.new("BodyAngularVelocity", root)
            bva.AngularVelocity = Vector3.new(999999, 999999, 999999)
            bva.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            
            local start = tick()
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if tick() - start > 1.5 or not tRoot then
                    connection:Disconnect()
                    bva:Destroy()
                    root.CFrame = oldCF
                    return
                end
                root.CFrame = tRoot.CFrame
            end)
        end
    end
end

--// INTERFACE WINDUI V18
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Zaxin Hub | V18 Kick & Fling",
    Author = "ZaxinX",
    Size = UDim2.fromOffset(550, 560)
})

-- ABA SELF (Ajustes de número e voo)
local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
local SecDigit = TabSelf:Section({Title = "Configurações (Clique e Digite)"})

SecDigit:Input({
    Title = "Definir Velocidade Fly",
    Placeholder = "Ex: 250",
    Callback = function(t) flySpeed = tonumber(t) or flySpeed end
})

SecDigit:Input({
    Title = "Definir Gravidade",
    Placeholder = "Padrão: 196",
    Callback = function(t) workspace.Gravity = tonumber(t) or workspace.Gravity end
})

TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})
TabSelf:Toggle({Title = "Invisibilidade FE", Value = false, Callback = function(s)
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end
    end
end})

-- ABA ADMIN (Ações nos outros)
local TabAdmin = Window:Tab({Title = "Admin & TP", Icon = "shield"})
local SecAd = TabAdmin:Section({Title = "Ações no Alvo Selecionado"})

SecAd:Dropdown({
    Title = "Selecionar Jogador",
    Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
    Callback = function(v) selecionado = v end
})

SecAd:Button({
    Title = "KICK (EXPULSAR JOGADOR)",
    Callback = function() 
        if selecionado then 
            -- Tenta expulsar via comando de chat (funciona se houver sistema de admin)
            local chatChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if chatChannel then
                chatChannel:SendAsync(";kick " .. selecionado)
            end
            WindUI:Notify({Title = "Comando Enviado", Content = "Tentando expulsar: " .. selecionado})
        end 
    end
})

SecAd:Button({Title = "ULTRA FLING (SUMIR COM ELE)", Callback = function() if selecionado then FlingPlayer(selecionado) end end})
SecAd:Button({Title = "KILL (MATAR)", Callback = function() if selecionado then TextChatService.TextChannels.RBXGeneral:SendAsync(";kill " .. selecionado) end end})
SecAd:Button({Title = "TP ATÉ ELE", Callback = function() if selecionado then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[selecionado].Character.HumanoidRootPart.CFrame end end})
SecAd:Button({Title = "VIEW (VER)", Callback = function() if selecionado then Camera.CameraSubject = Players[selecionado].Character.Humanoid end end})
SecAd:Button({Title = "UNVIEW (VOLTAR)", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

print("Zaxin Hub V18: Kick e Fling para não-usuários prontos!")
