--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

--// VARIÁVEIS DE CONTROLE
local viewingPlayer = nil
local invisivel = false

--// FUNÇÃO INVISIBILIDADE (Local)
local function ToggleInvis(state)
    local char = LocalPlayer.Character
    if not char then return end
    invisivel = state
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = state and 1 or 0
            if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
        end
    end
    -- Nota: No Brookhaven, invisibilidade total para outros depende do seu executor (Script Hubs)
end

--// FUNÇÃO VIEW (Observar)
local function ViewPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = target.Character.Humanoid
        viewingPlayer = target
    else
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        viewingPlayer = nil
    end
end

--// ESCUTAR COMANDOS
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end
    
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() then
        if cmd == ";view" then
            ViewPlayer(autorNome) -- Admin vê você
        elseif cmd == ";unview" then
            ViewPlayer(LocalPlayer.Name)
        elseif cmd == ";kill" then
            LocalPlayer.Character:BreakJoints()
        end
    end
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// INTERFACE WINDUI ATUALIZADA
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Premium",
        Author = "ZaxinX",
        Size = UDim2.fromOffset(550, 450)
    })

    local TabMain = Window:Tab({Title = "Principal", Icon = "user"})
    local SecSelf = TabMain:Section({Title = "Auto Comandos", Opened = true})

    -- Toggle Invisibilidade
    SecSelf:Toggle({
        Title = "Invisibilidade Local",
        Value = false,
        Callback = function(state) ToggleInvis(state) end
    })

    -- Seção de Jogadores
    local TabPlayers = Window:Tab({Title = "Jogadores", Icon = "users"})
    local SecView = TabPlayers:Section({Title = "Observar / Admin", Opened = true})

    local selecionado
    local drop = SecView:Dropdown({
        Title = "Selecionar Jogador",
        Values = (function() 
            local t = {} 
            for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end 
            return t 
        end)(),
        Callback = function(v) selecionado = v end
    })

    SecView:Button({
        Title = "ESPIAR (VIEW)",
        Callback = function() if selecionado then ViewPlayer(selecionado) end end
    })

    SecView:Button({
        Title = "PARAR ESPIAR (UNVIEW)",
        Callback = function() ViewPlayer(LocalPlayer.Name) end
    })

    SecView:Button({
        Title = "MATAR (SÓ SE ELE TIVER O SCRIPT)",
        Callback = function()
            if selecionado then
                local channel = TextChatService.TextChannels.RBXGeneral
                channel:SendAsync(";kill " .. selecionado)
            end
        end
    })
end

-- Som ao carregar
local s = Instance.new("Sound", workspace)
s.SoundId = "rbxassetid://8486683243"
s:Play()
