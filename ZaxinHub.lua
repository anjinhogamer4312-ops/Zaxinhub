--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// WHITELIST (Ranks)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner",
    [LocalPlayer.Name] = "Developer" -- Você sempre autorizado
}

--// JUMPSCARES
local JUMPSCARES = {
    [";jumps1"] = {Img = "rbxassetid://126754882337711", Snd = "rbxassetid://138873214826309"},
    [";jumps2"] = {Img = "rbxassetid://86379969987314", Snd = "rbxassetid://143942090"},
    [";jumps3"] = {Img = "rbxassetid://127382022168206", Snd = "rbxassetid://143942090"},
    [";jumps4"] = {Img = "rbxassetid://95973611964555", Snd = "rbxassetid://138873214826309"},
}

--// FUNÇÃO TAG (Visual)
local function CriarTag(player, texto)
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if not head or head:FindFirstChild("RankTag") then return end

    local gui = Instance.new("BillboardGui", head)
    gui.Name = "RankTag"
    gui.Size = UDim2.new(0, 100, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
    frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", frame)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
end

--// MOSTRAR JUMPSCARE
local function MostrarJumpscare(data)
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Image = data.Img
    img.BackgroundTransparency = 1
    
    local sound = Instance.new("Sound", workspace)
    sound.SoundId = data.Snd
    sound.Volume = 5
    sound:Play()

    TweenService:Create(img, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
    task.delay(3, function()
        gui:Destroy()
        sound:Destroy()
    end)
end

--// ESCUTAR COMANDOS (Compatível com Brookhaven)
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end -- Só aceita comando de quem é Whitelist
    
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() or alvo == "all" then
        if JUMPSCARES[cmd] then
            MostrarJumpscare(JUMPSCARES[cmd])
        elseif cmd == ";kill" then
            LocalPlayer.Character:BreakJoints()
        elseif cmd == ";kick" then
            LocalPlayer:Kick("Expulso por: " .. autorNome)
        elseif cmd == ";freeze" then
            LocalPlayer.Character.Humanoid.WalkSpeed = 0
        elseif cmd == ";unfreeze" then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end

--// CONEXÃO CHAT NOVO
TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then
        ProcessarComando(msg.Text, msg.TextSource.Name)
    end
end)

--// INTERFACE WINDUI
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = Window or WindUI:CreateWindow({
        Title = "Zaxin Hub | Admin",
        Author = "ZaxinX",
        Size = UDim2.fromOffset(500, 400)
    })

    local Tab = Window:Tab({Title = "Comandos", Icon = "terminal"})
    local Sec = Tab:Section({Title = "Ações", Opened = true})

    local selecionado
    local drop = Sec:Dropdown({
        Title = "Selecionar Alvo",
        Values = (function() 
            local t = {} 
            for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end 
            return t 
        end)(),
        Callback = function(v) selecionado = v end
    })

    local cmds = {";kill", ";kick", ";jumps1", ";jumps2", ";freeze", ";unfreeze"}
    for _, c in ipairs(cmds) do
        Sec:Button({
            Title = c:upper(),
            Callback = function()
                if selecionado then
                    -- No Roblox, você só "fala" o comando. 
                    -- Se o alvo estiver com o script aberto, ele vai obedecer.
                    local channel = TextChatService.TextChannels.RBXGeneral
                    channel:SendAsync(c .. " " .. selecionado)
                end
            end
        })
    end
end

-- Iniciar tags para quem já está no jogo
for _, p in pairs(Players:GetPlayers()) do
    if WhiteList[p.Name] then CriarTag(p, WhiteList[p.Name]) end
end
