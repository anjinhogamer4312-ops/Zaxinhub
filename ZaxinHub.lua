--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// WHITELIST (Coloque seu nome EXATAMENTE como está no Roblox)
local Autorizados = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Admin",
    ["tiai200"] = "Admin",
    ["10pereirazzk"] = "Owner",
    [LocalPlayer.Name] = "Developer" -- Garante que você sempre tenha acesso
}

--// CONFIGURAÇÃO JUMPSCARES
local JUMPSCARES = {
    ["jumps1"] = {Img = "rbxassetid://126754882337711", Snd = "rbxassetid://138873214826309"},
    ["jumps2"] = {Img = "rbxassetid://86379969987314", Snd = "rbxassetid://143942090"},
    ["jumps3"] = {Img = "rbxassetid://127382022168206", Snd = "rbxassetid://143942090"},
    ["jumps4"] = {Img = "rbxassetid://95973611964555", Snd = "rbxassetid://138873214826309"},
}

--// FUNÇÃO CRIAR TAG (Visual apenas para você)
local function CriarTag(plr, cargo)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 10)
    
    if head and not head:FindFirstChild("RankTag") then
        local gui = Instance.new("BillboardGui", head)
        gui.Name = "RankTag"
        gui.Size = UDim2.new(0, 150, 0, 50)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true

        local lbl = Instance.new("TextLabel", gui)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "[" .. cargo .. "]"
        lbl.TextColor3 = Color3.fromRGB(170, 0, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextStrokeTransparency = 0
    end
end

--// FUNÇÃO JUMPSCARE
local function PlayJumpscare(id)
    local data = JUMPSCARES[id]
    if not data then return end

    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Image = data.Img
    img.BackgroundTransparency = 1
    
    local sfx = Instance.new("Sound", workspace)
    sfx.SoundId = data.Snd
    sfx.Volume = 10
    sfx:Play()

    task.delay(2.5, function()
        gui:Destroy()
        sfx:Destroy()
    end)
end

--// APLICAR TAGS NOS AUTORIZADOS
for _, plr in pairs(Players:GetPlayers()) do
    if Autorizados[plr.Name] then
        CriarTag(plr, Autorizados[plr.Name])
    end
end

--// EXECUTAR COMANDOS
LocalPlayer.Chatted:Connect(function(msg)
    local args = msg:lower():split(" ")
    if args[1] == ";kill" and args[2] == LocalPlayer.Name:lower() then
        LocalPlayer.Character:BreakJoints()
    elseif args[1] == ";kick" and args[2] == LocalPlayer.Name:lower() then
        LocalPlayer:Kick("Zaxin Hub - Auto Kick")
    elseif JUMPSCARES[args[1]:sub(2)] and args[2] == LocalPlayer.Name:lower() then
        PlayJumpscare(args[1]:sub(2))
    end
end)

--// CARREGAR UI (WIND UI)
if Autorizados[LocalPlayer.Name] then
    local success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)

    if success then
        local Window = WindUI:CreateWindow({
            Title = "Zaxin Hub | Brookhaven",
            Author = "ZaxinX",
            Size = UDim2.fromOffset(450, 350)
        })

        local Tab = Window:Tab({Title = "Comandos", Icon = "terminal"})
        
        Tab:Button({
            Title = "Matar-se",
            Callback = function() LocalPlayer.Character:BreakJoints() end
        })

        Tab:Button({
            Title = "Jumpscare Teste",
            Callback = function() PlayJumpscare("jumps1") end
        })
        
        WindUI:Notify({
            Title = "Zaxin Hub",
            Content = "Script carregado com sucesso!",
            Duration = 5
        })
    end
end
