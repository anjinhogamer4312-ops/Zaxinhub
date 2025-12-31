--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Configurações Whitelist
local Autorizados = {
    ["10pereirazzk"] = true,
    ["fh_user1"] = true,
    ["ZaxinX"] = true,
    [LocalPlayer.Name] = true
}

local JUMPSCARES = {
    [";jumps1"] = {img = "rbxassetid://126754882337711", snd = "rbxassetid://138873214826309"},
    [";jumps2"] = {img = "rbxassetid://86379969987314", snd = "rbxassetid://143942090"},
    [";jumps3"] = {img = "rbxassetid://127382022168206", snd = "rbxassetid://143942090"},
    [";jumps4"] = {img = "rbxassetid://95973611964555", snd = "rbxassetid://138873214826309"},
}

--// Variáveis de Controle
local flying = false
local flySpeed = 50
local noclip = false
local espEnabled = false
local espSettings = { boxes = false, names = false, tracers = false }
local currentAudio = nil

--// --- FUNÇÃO JUMPSCARE ---
local function AtivarJumpscare(data)
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    gui.IgnoreGuiInset = true
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1,0,1,0); img.Image = data.img; img.BackgroundTransparency = 1
    local s = Instance.new("Sound", workspace)
    s.SoundId = data.snd; s.Volume = 10; s:Play()
    task.wait(2.5)
    gui:Destroy(); s:Destroy()
end

--// --- FUNÇÃO FLY ---
local function toggleFly()
    flying = not flying
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if flying then
        hum.PlatformStand = true
        local bg = Instance.new("BodyGyro", root); bg.Name = "ZaxinFlyBG"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        local bv = Instance.new("BodyVelocity", root); bv.Name = "ZaxinFlyBV"; bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while flying do
                bg.cframe = Camera.CFrame
                bv.velocity = (hum.MoveDirection.Magnitude > 0) and (Camera.CFrame.LookVector * flySpeed) or Vector3.new(0,0,0)
                RunService.RenderStepped:Wait()
            end
            bg:Destroy(); bv:Destroy(); hum.PlatformStand = false
        end)
    end
end

--// --- COMANDOS DE CHAT ---
local function ExecutarComando(msg, autor)
    local texto = msg:lower(); local alvo = LocalPlayer.Name:lower()
    for cmd, data in pairs(JUMPSCARES) do if texto:find(cmd) and texto:find(alvo) then AtivarJumpscare(data) end end
    if texto:find(";audioall") then
        local id = texto:match("%d+")
        if id then 
            if currentAudio then currentAudio:Destroy() end
            currentAudio = Instance.new("Sound", workspace); currentAudio.SoundId = "rbxassetid://"..id; currentAudio.Volume = 5; currentAudio:Play()
        end
    end
    if texto:find(";view") and texto:find(alvo) then Camera.CameraSubject = Players:FindFirstChild(autor).Character.Humanoid end
    if texto:find(";unview") and texto:find(alvo) then Camera.CameraSubject = LocalPlayer.Character.Humanoid end
    if texto:find(";kill") and texto:find(alvo) then LocalPlayer.Character:BreakJoints() end
end
TextChatService.MessageReceived:Connect(function(msg) if msg.TextSource then ExecutarComando(msg.Text, msg.TextSource.Name) end end)

--// --- INTERFACE WINDUI ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ Title = "Zaxin Hub | Premium", Author = "by: ZaxinX", Size = UDim2.fromOffset(580, 460) })
    
    -- BOTÃO PARA ABRIR/FECHAR
    Window:EditOpenButton({
        Title = "Zaxin Hub",
        Icon = "shield", -- Ícone de escudo
        Color = Color3.fromRGB(0, 255, 127)
    })

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecMov = TabSelf:Section({ Title = "Movimentação", Opened = true })
    SecMov:Toggle({ Title = "Fly", Callback = toggleFly })
    SecMov:Toggle({ Title = "Noclip", Callback = function(s) noclip = s end })
    SecMov:Input({ Title = "Fly Speed", Placeholder = "Velocidade...", Callback = function(v) flySpeed = tonumber(v) or 50 end })

    -- ABA VISUAL (ESP)
    local TabVis = Window:Tab({ Title = "Visual", Icon = "eye" })
    local SecESP = TabVis:Section({ Title = "ESP Settings", Opened = true })
    SecESP:Toggle({ Title = "ESP Geral", Callback = function(s) espEnabled = s end })
    SecESP:Toggle({ Title = "Boxes", Callback = function(s) espSettings.boxes = s end })
    SecESP:Toggle({ Title = "Names", Callback = function(s) espSettings.names = s end })
    SecESP:Toggle({ Title = "Tracers", Callback = function(s) espSettings.tracers = s end })

    -- ABA ÁUDIO
    local TabMus = Window:Tab({ Title = "Áudio", Icon = "music" })
    local cID = ""
    local SecAud = TabMus:Section({ Title = "Global Audio", Opened = true })
    SecAud:Input({ Title = "ID do Áudio", Callback = function(v) cID = v end })
    SecAud:Button({ Title = "AUDIO ALL", Callback = function() if cID ~= "" then TextChatService.TextChannels.RBXGeneral:SendAsync(";audioall "..cID) end end })
    SecAud:Button({ Title = "Stop", Callback = function() if currentAudio then currentAudio:Stop() end end })

    -- ABA ADMIN
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local Target = ""
    TabAdm:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Target = v end })
    
    local function Enviar(cmd) 
        local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if canal and Target ~= "" then canal:SendAsync(";"..cmd.." "..Target) end
    end

    TabAdm:Button({ Title = "VIEW", Callback = function() Camera.CameraSubject = Players[Target].Character.Humanoid end })
    TabAdm:Button({ Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end })
    
    local cmds = {"kill", "kick", "fling", "jail", "unjail"}
    for _, c in ipairs(cmds) do TabAdm:Button({ Title = c:upper(), Callback = function() Enviar(c) end }) end
    
    -- ABA JUMPSCARES (ARRUMADA)
    local TabJump = Window:Tab({ Title = "Jumpscares", Icon = "zap" })
    local SecJ = TabJump:Section({ Title = "Executar Jumpscare", Opened = true })
    
    SecJ:Button({ Title = "Jumpscare 1", Callback = function() Enviar("jumps1") end })
    SecJ:Button({ Title = "Jumpscare 2", Callback = function() Enviar("jumps2") end })
    SecJ:Button({ Title = "Jumpscare 3", Callback = function() Enviar("jumps3") end })
    SecJ:Button({ Title = "Jumpscare 4", Callback = function() Enviar("jumps4") end })
end
