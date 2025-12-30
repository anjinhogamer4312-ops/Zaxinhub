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

--// VARIÁVEIS DO FLY
local flying = false
local flySpeed = 50
local flyConn
local bodyVelocity
local bodyGyro

--// FUNÇÃO FLY (REFEITA PARA NÃO TRAVAR)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly() -- Limpa qualquer fly anterior
    flying = true
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame

    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root or not hum then return end
        hum.PlatformStand = true
        
        local lookVec = Camera.CFrame.LookVector
        local rightVec = Camera.CFrame.RightVector
        local moveDir = Vector3.new(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVec end

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
        if LocalPlayer.Character then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end

--// PROCESSAR COMANDOS VIA CHAT
local function ProcessarComando(msg, autorNome)
    if not WhiteList[autorNome] then return end
    local args = msg:lower():split(" ")
    local cmd = args[1]
    local alvo = args[2]

    if alvo == LocalPlayer.Name:lower() or alvo == "all" then
        if cmd == ";fly" then StartFly()
        elseif cmd == ";unfly" then StopFly()
        elseif cmd == ";kill" then LocalPlayer.Character:BreakJoints()
        elseif cmd == ";kick" then LocalPlayer:Kick("Zaxin Hub Admin: " .. autorNome)
        elseif cmd == ";view" then ViewPlayer(autorNome)
        elseif cmd == ";unview" then ViewPlayer(LocalPlayer.Name)
        end
    end
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then ProcessarComando(msg.Text, msg.TextSource.Name) end
end)

--// INTERFACE WINDUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Zaxin Hub | V6 Fixed",
    Author = "ZaxinX",
    Size = UDim2.fromOffset(550, 480)
})

-- ABA SELF
local TabSelf = Window:Tab({Title = "Self", Icon = "user"})
local SecFly = TabSelf:Section({Title = "Movimentação", Opened = true})

SecFly:Toggle({
    Title = "Ativar Fly (Voo)",
    Value = false,
    Callback = function(state) if state then StartFly() else StopFly() end end
})

SecFly:Slider({
    Title = "Velocidade",
    Min = 10, Max = 300, Default = 50,
    Callback = function(v) flySpeed = v end
})

-- ABA ADMIN
local TabAdmin = Window:Tab({Title = "Admin", Icon = "shield"})
local SecAdmin = TabAdmin:Section({Title = "Gerenciar Jogadores", Opened = true})

local selecionado
local function GetPlayersList()
    local t = {}
    for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end
    return t
end

local Dropdown = SecAdmin:Dropdown({
    Title = "Selecionar Alvo",
    Values = GetPlayersList(),
    Callback = function(v) selecionado = v end
})

Players.PlayerAdded:Connect(function() Dropdown:SetValues(GetPlayersList()) end)
Players.PlayerRemoving:Connect(function() Dropdown:SetValues(GetPlayersList()) end)

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

print("Zaxin Hub: Fly corrigido e pronto!")
