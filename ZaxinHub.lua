--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Configurações Whitelist
local Autorizados = {
    ["10pereirazzk"] = true,
    ["fh_user1"] = true,
    ["Zelaojg"] = true,
    ["joaoluizzx"] = true,
    ["ZaxinX"] = true,
    [LocalPlayer.Name] = true
}

local JUMPSCARES = {
    { Name = ";jumps1", ImageId = "rbxassetid://126754882337711", AudioId = "rbxassetid://138873214826309" },
    { Name = ";jumps2", ImageId = "rbxassetid://86379969987314", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps3", ImageId = "rbxassetid://127382022168206", AudioId = "rbxassetid://143942090" },
    { Name = ";jumps4", ImageId = "rbxassetid://95973611964555", AudioId = "rbxassetid://138873214826309" },
}

--// Variáveis de Controle
local flying = false
local flySpeed = 50
local noclip = false
local espEnabled = false
local espSettings = { boxes = false, names = false, tracers = false }
local jaulas = {}
local jailConnections = {}
local currentAudio = nil
local noclipConnection

--// --- FUNÇÕES DE MOVIMENTAÇÃO (FLY / NOCLIP) ---
local function toggleFly()
    flying = not flying
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if flying then
        hum.PlatformStand = true
        local bg = Instance.new("BodyGyro", root)
        bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.Name = "ZaxinFly"
        local bv = Instance.new("BodyVelocity", root)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9); bv.Name = "ZaxinVel"
        task.spawn(function()
            while flying do
                bg.cframe = Camera.CFrame
                bv.velocity = (hum.MoveDirection.Magnitude > 0) and (Camera.CFrame.LookVector * flySpeed) or Vector3.new(0,0,0)
                task.wait()
            end
            bg:Destroy(); bv:Destroy(); hum.PlatformStand = false
        end)
    end
end

local function toggleNoclip(state)
    noclip = state
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if noclip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else if noclipConnection then noclipConnection:Disconnect() end end
end

--// --- SISTEMA DE VISUAL (ESP) ---
local function createESP(player)
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.new(1,0,0); box.Thickness = 1
    local name = Drawing.new("Text"); name.Visible = false; name.Color = Color3.new(1,1,1); name.Size = 16; name.Outline = true
    local tracer = Drawing.new("Line"); tracer.Visible = false; tracer.Color = Color3.new(1,0,0); tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer and espEnabled then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                if espSettings.boxes then
                    box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                    box.Visible = true
                else box.Visible = false end
                if espSettings.names then
                    name.Position = Vector2.new(pos.X, pos.Y - 20)
                    name.Text = player.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    name.Visible = true
                else name.Visible = false end
                if espSettings.tracers then
                    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); tracer.To = Vector2.new(pos.X, pos.Y); tracer.Visible = true
                else tracer.Visible = false end
            else box.Visible = false; name.Visible = false; tracer.Visible = false end
        else box.Visible = false; name.Visible = false; tracer.Visible = false end
    end)
end
for _,p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--// --- COMANDOS ADMIN ---
local function ExecutarComando(cmd, autor)
    local texto = cmd:lower()
    local meuNome = LocalPlayer.Name:lower()

    if texto:match(";view%s+"..meuNome) then Camera.CameraSubject = Players:FindFirstChild(autor).Character.Humanoid end
    if texto:match(";unview") then Camera.CameraSubject = LocalPlayer.Character.Humanoid end
    if texto:match(";hop") then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    if texto:match(";kill%s+"..meuNome) then LocalPlayer.Character:BreakJoints() end
    if texto:match(";kick%s+"..meuNome) then LocalPlayer:Kick("Zaxin Hub") end
end

TextChatService.MessageReceived:Connect(function(msg) if msg.TextSource then ExecutarComando(msg.Text, msg.TextSource.Name) end end)

--// --- INTERFACE WINDUI ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ Title = "Zaxin Hub | Premium", Author = "by: ZaxinX", Size = UDim2.fromOffset(580, 460) })

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecMov = TabSelf:Section({ Title = "Movimentação", Opened = true })
    SecMov:Toggle({ Title = "Fly", Callback = toggleFly })
    SecMov:Toggle({ Title = "Noclip", Callback = toggleNoclip })
    local fSlider = SecMov:Slider({ Title = "Fly Speed", Min = 10, Max = 500, Default = 50, Callback = function(v) flySpeed = v end })
    SecMov:Input({ Title = "Input Fly Speed", Placeholder = "Velocidade...", Callback = function(v) flySpeed = tonumber(v) or 50 fSlider:SetValue(flySpeed) end })
    SecMov:Button({ Title = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })

    -- ABA VISUAL
    local TabVis = Window:Tab({ Title = "Visual", Icon = "eye" })
    local SecESP = TabVis:Section({ Title = "ESP", Opened = true })
    SecESP:Toggle({ Title = "Ativar ESP", Callback = function(s) espEnabled = s end })
    SecESP:Toggle({ Title = "Boxes", Callback = function(s) espSettings.boxes = s end })
    SecESP:Toggle({ Title = "Names", Callback = function(s) espSettings.names = s end })
    SecESP:Toggle({ Title = "Tracers", Callback = function(s) espSettings.tracers = s end })

    -- ABA MÚSICAS
    local TabMus = Window:Tab({ Title = "Áudio", Icon = "music" })
    local function play(id) if currentAudio then currentAudio:Destroy() end currentAudio = Instance.new("Sound", workspace); currentAudio.SoundId = "rbxassetid://"..id; currentAudio.Volume = 2; currentAudio:Play() end
    TabMus:Section({ Title = "Funk" }):Button({ Title = "Funk MTG", Callback = function() play(17341315082) end })
    TabMus:Section({ Title = "Sertanejo" }):Button({ Title = "Sertanejo Mix", Callback = function() play(13360351322) end })
    TabMus:Section({ Title = "Rap" }):Button({ Title = "Rap Matuê", Callback = function() play(6441313543) end })
    local aSec = TabMus:Section({ Title = "Custom" })
    local cID = ""
    aSec:Input({ Title = "ID do Áudio", Callback = function(v) cID = v end })
    aSec:Button({ Title = "Play", Callback = function() play(cID) end })
    aSec:Button({ Title = "Audio All", Callback = function() TextChatService.TextChannels.RBXGeneral:SendAsync(";audioall "..cID) end })

    -- ABA ADMIN
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local Target = ""
    TabAdm:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Target = v end })
    TabAdm:Button({ Title = "VIEW", Callback = function() Camera.CameraSubject = Players[Target].Character.Humanoid end })
    TabAdm:Button({ Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end })
    for _,c in pairs({"kill", "kick", "fling", "jail", "unjail"}) do
        TabAdm:Button({ Title = c:upper(), Callback = function() TextChatService.TextChannels.RBXGeneral:SendAsync(";"..c.." "..Target) end })
    end
    
    -- ABA JUMPSCARES
    local TabJump = Window:Tab({ Title = "Jumpscares", Icon = "zap" })
    for i=1,4 do TabJump:Button({ Title = "Jumpscare "..i, Callback = function() TextChatService.TextChannels.RBXGeneral:SendAsync(";jumps"..i.." "..Target) end }) end
end
