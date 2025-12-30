--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// WHITELIST
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner",
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS GLOBAIS DE VOO
local flying = false
local flySpeed = 50 -- Valor inicial
local bv, bg
local flyConn

--// FUNÇÃO FLY (Atualizada para ler flySpeed dinamicamente)
local function StartFly()
    if flying then return end
    flying = true
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    -- Configuração Física
    bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    
    bv = Instance.new("BodyVelocity", root)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    -- Loop de Voo
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not char or not root then return end
        
        humanoid.PlatformStand = true
        local frame = Camera.CFrame
        local direction = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + frame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - frame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - frame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + frame.RightVector end
        
        -- Aplica a velocidade atual da variável global flySpeed
        bv.Velocity = direction * flySpeed
        bg.CFrame = frame
    end)
end

local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

--// FUNÇÃO VIEW & INVIS
local function ViewPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character then
        Camera.CameraSubject = target.Character:FindFirstChild("Humanoid")
    else
        if LocalPlayer.Character then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
end

--// PROCESSAR COMANDOS VIA CHAT
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() or alvo == "all" then
        if cmd == ";fly" then StartFly()
        elseif cmd == ";unfly" then StopFly()
        elseif cmd == ";kick" then LocalPlayer:Kick("Expulso por Admin: " .. autorNome)
        elseif cmd == ";kill" then LocalPlayer.Character:BreakJoints()
        elseif cmd == ";view" then ViewPlayer(autorNome)
        elseif cmd == ";unview" then ViewPlayer(LocalPlayer.Name)
        end
    end
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// INTERFACE WINDUI
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Ultimate V5",
        Author = "ZaxinX",
        Size = UDim2.fromOffset(550, 480)
    })

    -- ABA SELF (Com Slider Arrumado)
    local TabMain = Window:Tab({Title = "Self", Icon = "user"})
    local SecFly = TabMain:Section({Title = "Movimentação", Opened = true})

    SecFly:Toggle({
        Title = "Ativar Fly (Voo)",
        Value = false,
        Callback = function(state) 
            if state then StartFly() else StopFly() end 
        end
    })

    SecFly:Slider({
        Title = "Velocidade do Fly",
        Min = 10,
        Max = 300,
        Default = 50,
        Step = 1, -- Adicionado Step para facilitar o movimento da barra
        Callback = function(v) 
            flySpeed = tonumber(v) -- Garante que o valor é atualizado globalmente
        end
    })

    -- ABA ADMIN (Com Kill, Kick, View, Unview)
    local TabAdmin = Window:Tab({Title = "Admin", Icon = "shield"})
    local SecPlayer = TabAdmin:Section({Title = "Gerenciar Jogadores", Opened = true})

    local selecionado
    local function GetPlayersList()
        local t = {}
        for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end
        return t
    end

    local Dropdown = SecPlayer:Dropdown({
        Title = "Selecionar Alvo",
        Values = GetPlayersList(),
        Callback = function(v) selecionado = v end
    })

    Players.PlayerAdded:Connect(function() Dropdown:SetValues(GetPlayersList()) end)
    Players.PlayerRemoving:Connect(function() Dropdown:SetValues(GetPlayersList()) end)

    local function SendCmd(cmd)
        if selecionado then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(cmd .. " " .. selecionado) end
        end
    end

    SecPlayer:Button({Title = "KILL (MATAR)", Callback = function() SendCmd(";kill") end})
    SecPlayer:Button({Title = "KICK (EXPULSAR)", Callback = function() SendCmd(";kick") end})
    SecPlayer:Button({Title = "VIEW (ESPIAR)", Callback = function() if selecionado then ViewPlayer(selecionado) end end})
    SecPlayer:Button({Title = "UNVIEW (PARAR ESPIAR)", Callback = function() ViewPlayer(LocalPlayer.Name) end})
end

-- Notificação
print("Zaxin Hub Carregado e Corrigido!")
