--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Tabelas de Configuração
local Autorizados = {
    ["fh_user1"] = true,
    ["Zelaojg"] = true,
    ["joaoluizzx"] = true,
    ["ZaxinX"] = true, -- Adicione seu nome aqui
    [LocalPlayer.Name] = true -- Remove essa linha se quiser testar a permissão real
}

local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Usuário-Admin",
    ["tiai200"] = "Usuário-Admin",
    ["nao"] = "Staff",
}

local JUMPSCARES = {
    { Name = ";jumps1", ImageId = "rbxassetid://126754882337711", AudioId = "rbxassetid://138873214826309" },
    { Name = ";jumps2", ImageId = "rbxassetid://86379969987314", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps3", ImageId = "rbxassetid://127382022168206", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps4", ImageId = "rbxassetid://95973611964555", AudioId = "rbxassetid://138873214826309" },
}

--// Variáveis Globais de Controle
local runningLoops = {}
local playerOriginalSpeed = {}
local jaulas = {}
local jailConnections = {}

--// --- FUNÇÕES DE UTILIDADE ---

local function createBillboard(playerName, displayText, guiName)
    local target = workspace:FindFirstChild(playerName)
    if not target then return end
    local head = target:FindFirstChild("Head")
    if not head or head:FindFirstChild(guiName) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = guiName
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 80
    billboard.Parent = head

    local textBackground = Instance.new("Frame", billboard)
    textBackground.Size = UDim2.new(1, 0, 0.5, 0)
    textBackground.Position = UDim2.new(0, 0, 0.5, 0)
    textBackground.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    textBackground.BackgroundTransparency = 0.3
    Instance.new("UICorner", textBackground).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", textBackground)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = displayText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
end

local function startGuiWatcher(playerName, displayText, guiName)
    if runningLoops[guiName] then return end
    runningLoops[guiName] = true
    task.spawn(function()
        while runningLoops[guiName] do
            createBillboard(playerName, displayText, guiName)
            task.wait(1)
        end
    end)
end

local function EnviarComando(comando, alvo)
    local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:GetChildren()[1]
    if canal and alvo then
        canal:SendAsync(";" .. comando .. " " .. alvo)
    end
end

local function MostrarJumpscare(imageId, audioId)
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = imageId
    img.ImageTransparency = 1

    local sound = Instance.new("Sound", workspace)
    sound.SoundId = audioId
    sound.Volume = 5
    sound:Play()
    
    TweenService:Create(img, TweenInfo.new(0.5), { ImageTransparency = 0 }):Play()
    task.wait(2.5)
    TweenService:Create(img, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
    task.delay(0.5, function() gui:Destroy() sound:Destroy() end)
end

--// --- SISTEMA DE COMANDOS ---

local function ExecutarComandoLocal(comando, autor)
    local playerName = LocalPlayer.Name:lower()
    local cmd = comando:lower()

    for _, js in ipairs(JUMPSCARES) do
        if cmd:match(js.Name .. "%s+" .. playerName) then
            MostrarJumpscare(js.ImageId, js.AudioId)
        end
    end

    if cmd:match(";kick%s+" .. playerName) then
        LocalPlayer:Kick("Você foi expulso por Zaxin Hub")
    end

    if cmd:match(";kill%s+" .. playerName) then
        if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
    end

    if cmd:match(";freeze%s+" .. playerName) then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 0 end
    end

    if cmd:match(";unfreeze%s+" .. playerName) then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    
    -- Comando de Verificação (Resposta Automática)
    if cmd:match(";verifique%s+" .. playerName) then
        local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if canal then canal:SendAsync("Zaxin_Hub_User_" .. math.random(1000, 9999)) end
    end
end

--// Conexão do Chat
TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then
        ExecutarComandoLocal(msg.Text, msg.TextSource.Name)
    end
end)

--// Inicialização de Tags
for name, tag in pairs(WhiteList) do
    if Players:FindFirstChild(name) then startGuiWatcher(name, tag, "Tag_"..name) end
end
Players.PlayerAdded:Connect(function(p)
    if WhiteList[p.Name] then startGuiWatcher(p.Name, WhiteList[p.Name], "Tag_"..p.Name) end
end)

--// --- INTERFACE (WindUI) ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Painel Admin",
        Icon = "shield",
        Author = "by: ZaxinX",
        Folder = "ZaxinHub",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true
    })

    local TabComandos = Window:Tab({ Title = "Comandos", Icon = "terminal" })
    local SectionAdmin = TabComandos:Section({ Title = "Controle de Jogador", Opened = true })

    local TargetName = ""
    local function getPlayers()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
        return t
    end

    local Dropdown = SectionAdmin:Dropdown({
        Title = "Selecionar Jogador",
        Values = getPlayers(),
        Callback = function(v) TargetName = v end
    })

    -- Atualiza dropdown automaticamente
    spawn(function()
        while task.wait(5) do Dropdown:SetValues(getPlayers()) end
    end)

    local cmds = {"kick", "kill", "freeze", "unfreeze", "bring", "jail", "unjail", "verifique"}
    for _, c in ipairs(cmds) do
        SectionAdmin:Button({
            Title = c:upper(),
            Callback = function() EnviarComando(c, TargetName) end
        })
    end

    local TabEfeitos = Window:Tab({ Title = "Efeitos", Icon = "zap" })
    local SectionJS = TabEfeitos:Section({ Title = "Jumpscares", Opened = true })

    for i = 1, 4 do
        SectionJS:Button({
            Title = "Jumpscare " .. i,
            Callback = function() EnviarComando("jumps"..i, TargetName) end
        })
    end
end

-- Som de Sucesso
local s = Instance.new("Sound", workspace)
s.SoundId = "rbxassetid://8486683243"
s:Play()
game.Debris:AddItem(s, 3)
