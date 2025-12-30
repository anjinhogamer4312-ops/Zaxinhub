--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Tabelas de Configuração
local Autorizados = {
    ["10pereirazzk"] = true,
    ["Zelaojg"] = true,
    ["joaoluizzx"] = true,
    ["ZaxinX"] = true,
    [LocalPlayer.Name] = true -- Permissão para você usar o painel
}

local WhiteList = {
    ["10pereirazzk"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
}

--// Variáveis de Voo e Estado
local flying = false
local speed_multiplier = 1
local flySpeed = 50
local bodyGyro, bodyVelocity

--// --- FUNÇÕES DE MOVIMENTAÇÃO ---

local function toggleFly()
    if flying then
        flying = false
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    else
        flying = true
        local char = LocalPlayer.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if not root or not hum then return end
        hum.PlatformStand = true

        bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = root.CFrame

        bodyVelocity = Instance.new("BodyVelocity", root)
        bodyVelocity.velocity = Vector3.new(0, 0, 1)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            while flying do
                local camera = workspace.CurrentCamera
                local moveDir = hum.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    bodyVelocity.velocity = camera.CFrame.LookVector * flySpeed
                else
                    bodyVelocity.velocity = Vector3.new(0, 0, 0)
                end
                
                bodyGyro.cframe = camera.CFrame
                task.wait()
            end
        end)
    end
end

--// --- INTERFACE (WindUI) ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Premium",
        Icon = "shield-check",
        Author = "by: ZaxinX",
        Folder = "ZaxinHub",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true
    })

    local TabComandos = Window:Tab({ Title = "Comandos", Icon = "terminal" })
    
    -- Seção de Auto-Benefício
    local SectionSelf = TabComandos:Section({ Title = "Meu Personagem", Opened = true })

    SectionSelf:Slider({
        Title = "Velocidade (WalkSpeed)",
        Step = 1,
        Min = 16,
        Max = 250,
        Default = 16,
        Callback = function(v)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    })

    SectionSelf:Toggle({
        Title = "Voar (Fly)",
        Desc = "Ativa o modo de voo (Direção da Câmera)",
        Value = false,
        Callback = function(state)
            if state ~= flying then toggleFly() end
        end
    })

    -- Seção de Admin (Outros Jogadores)
    local SectionAdmin = TabComandos:Section({ Title = "Administrar Outros", Opened = false })

    local TargetName = ""
    local function getPlayers()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
        return t
    end

    local Dropdown = SectionAdmin:Dropdown({
        Title = "Selecionar Alvo",
        Values = getPlayers(),
        Callback = function(v) TargetName = v end
    })

    -- Comandos Rápidos
    local cmds = {"kick", "kill", "freeze", "unfreeze", "verifique"}
    for _, c in ipairs(cmds) do
        SectionAdmin:Button({
            Title = "Executar: " .. c:upper(),
            Callback = function() 
                local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if canal and TargetName ~= "" then
                    canal:SendAsync(";" .. c .. " " .. TargetName)
                end
            end
        })
    end

    -- Aba de Efeitos (Jumpscares)
    local TabEfeitos = Window:Tab({ Title = "Efeitos", Icon = "zap" })
    local SectionJS = TabEfeitos:Section({ Title = "Jumpscares", Opened = true })

    for i = 1, 4 do
        SectionJS:Button({
            Title = "Jumpscare " .. i,
            Callback = function() 
                local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if canal and TargetName ~= "" then
                    canal:SendAsync(";jumps" .. i .. " " .. TargetName)
                end
            end
        })
    end
end

--// Atalho de Teclado (Tecla E para Fly)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E and Autorizados[LocalPlayer.Name] then
        -- Opcional: Ativa o voo se apertar E
        -- toggleFly() 
    end
end)

-- Som de Sucesso ao Injetar
local s = Instance.new("Sound", workspace)
s.SoundId = "rbxassetid://8486683243"
s:Play()
game.Debris:AddItem(s, 2)
