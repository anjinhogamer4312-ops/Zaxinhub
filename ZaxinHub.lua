--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

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

--// VARIÁVEIS GLOBAIS
local flying = false
local flySpeed = 50
local flyConn, bodyVelocity, bodyGyro
local invisivel = false

--// FUNÇÃO INVISIBILIDADE (FE - NINGUÉM VÊ)
local function ToggleInvis(state)
    invisivel = state
    local char = LocalPlayer.Character
    if not char then return end
    
    -- No Brookhaven, para ser 100% invisível para os outros:
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = state and 1 or 0
            if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
        end
        if part:IsA("Accessory") and state then
            part.Handle.Transparency = 1
        end
    end
    
    -- Notificação visual
    if state then
        print("Invisibilidade Ativada - Você está oculto para os outros.")
    else
        print("Invisibilidade Desativada.")
    end
end

--// FUNÇÃO FLY (SISTEMA FLUIDO)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly()
    flying = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame

    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        hum.PlatformStand = true
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        
        bodyGyro.CFrame = Camera.CFrame
        bodyVelocity.Velocity = moveDir * flySpeed
    end)
end

--// FUNÇÃO VIEW
local function ViewPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character then
        Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
    else
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end

--// COMANDOS DE CHAT
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() or alvo == "all" then
        if cmd == ";fly" then StartFly()
        elseif cmd == ";unfly" then StopFly()
        elseif cmd == ";kill" then LocalPlayer.Character:BreakJoints()
        elseif cmd == ";kick" then LocalPlayer:Kick("Expulso por Admin")
        elseif cmd == ";view" then ViewPlayer(autorNome)
        elseif cmd == ";unview" then ViewPlayer(LocalPlayer.Name)
        elseif cmd == ";invis" then ToggleInvis(true)
        elseif cmd == ";vis" then ToggleInvis(false)
        end
    end
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// INTERFACE WINDUI
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | V7 Ultimate",
        Author = "ZaxinX",
        Size = UDim2.fromOffset(550, 500)
    })

    -- ABA SELF
    local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
    
    TabSelf:Section({Title = "Voo"})
    TabSelf:Toggle({Title = "Ativar Fly", Value = false, Callback = function(s) if s then StartFly() else StopFly() end end})
    TabSelf:Slider({Title = "Velocidade", Min = 10, Max = 500, Default = 50, Callback = function(v) flySpeed = v end})

    TabSelf:Section({Title = "Física e Invisibilidade"})
    TabSelf:Toggle({Title = "Ficar Invisível (Ninguém vê)", Value = false, Callback = function(s) ToggleInvis(s) end})
    TabSelf:Slider({
        Title = "Gravidade do Mundo",
        Min = 0, Max = 196, Default = 196,
        Callback = function(v) workspace.Gravity = v end
    })

    -- ABA ADMIN
    local TabAdmin = Window:Tab({Title = "Admin", Icon = "shield"})
    local SecAdmin = TabAdmin:Section({Title = "Gerenciar Jogadores", Opened = true})

    local selecionado
    local Dropdown = SecAdmin:Dropdown({
        Title = "Selecionar Alvo",
        Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
        Callback = function(v) selecionado = v end
    })

    local function SendCmd(cmd)
        if selecionado then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(cmd .. " " .. selecionado) end
        end
    end

    SecAdmin:Button({Title = "KILL", Callback = function() SendCmd(";kill") end})
    SecAdmin:Button({Title = "KICK", Callback = function() SendCmd(";kick") end})
    SecAdmin:Button({Title = "VIEW", Callback = function() if selecionado then ViewPlayer(selecionado) end end})
    SecAdmin:Button({Title = "UNVIEW", Callback = function() ViewPlayer(LocalPlayer.Name) end})
end

print("Zaxin Hub V7: Gravidade, Invisibilidade e Fly Prontos!")
