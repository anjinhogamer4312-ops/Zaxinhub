--// Serviços
local Players = game:GetService("Players")
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
    ["jumps1"] = {img = "rbxassetid://126754882337711", snd = "rbxassetid://138873214826309"},
    ["jumps2"] = {img = "rbxassetid://86379969987314", snd = "rbxassetid://143942090"},
    ["jumps3"] = {img = "rbxassetid://127382022168206", snd = "rbxassetid://143942090"},
    ["jumps4"] = {img = "rbxassetid://95973611964555", snd = "rbxassetid://138873214826309"},
}

--// Variáveis de Controle
local flySpeed = 50
local flying = false
local noclip = false
local currentAudio = nil

--// --- LÓGICA DE EXECUÇÃO LOCAL ---
local function AplicarEfeito(cmd, alvoNome)
    if alvoNome:lower() ~= LocalPlayer.Name:lower() then return end
    
    if cmd == "kill" then LocalPlayer.Character:BreakJoints()
    elseif cmd == "freeze" then LocalPlayer.Character.HumanoidRootPart.Anchored = true
    elseif cmd == "unfreeze" then LocalPlayer.Character.HumanoidRootPart.Anchored = false
    elseif cmd:find("jumps") then
        local data = JUMPSCARES[cmd]
        if data then
            local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
            gui.IgnoreGuiInset = true; gui.DisplayOrder = 999
            local img = Instance.new("ImageLabel", gui)
            img.Size = UDim2.new(1,0,1,0); img.Image = data.img; img.BackgroundTransparency = 1; img.ZIndex = 999
            local s = Instance.new("Sound", workspace)
            s.SoundId = data.snd; s.Volume = 10; s:Play()
            task.wait(2.5); gui:Destroy(); s:Destroy()
        end
    end
end

--// --- RECEBIMENTO DE MENSAGENS ---
TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource and Autorizados[msg.TextSource.Name] then
        local m = msg.Text:lower()
        -- Identifica o comando e o alvo dentro da string camuflada
        local cmd = m:match("{(%w+)}")
        local alvo = m:match("target:(%w+)")
        
        if cmd and alvo then
            AplicarEfeito(cmd, alvo)
        end
        
        -- Lógica especial para Áudio (burlar tag)
        if m:find("aud:") then
            local id = m:match("%d+")
            if id then
                if currentAudio then currentAudio:Destroy() end
                currentAudio = Instance.new("Sound", workspace)
                currentAudio.SoundId = "rbxassetid://"..id; currentAudio.Volume = 5; currentAudio:Play()
            end
        end
    end
end)

--// --- NOCLIP PERMANENTE ---
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--// --- INTERFACE ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ Title = "Zaxin Hub", Author = "by: ZaxinX", Size = UDim2.fromOffset(580, 460) })

    -- Botão "Z" para Minimizar
    local MiniButton = Instance.new("ScreenGui", game.CoreGui); local Btn = Instance.new("TextButton", MiniButton)
    Btn.Size = UDim2.new(0, 45, 0, 45); Btn.Position = UDim2.new(0, 15, 0.5, 0); Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = "Z"; Btn.TextColor3 = Color3.new(1,1,1); Btn.TextSize = 20; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    Btn.MouseButton1Click:Connect(function() Window:Toggle() end)

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecS = TabSelf:Section({ Title = "Movimentação", Opened = true })
    SecS:Toggle({ Title = "Fly", Callback = function(s) 
        flying = s
        if flying then
            task.spawn(function()
                local char = LocalPlayer.Character; local root = char.HumanoidRootPart
                local bg = Instance.new("BodyGyro", root); bg.maxTorque = Vector3.new(9e9,9e9,9e9)
                local bv = Instance.new("BodyVelocity", root); bv.maxForce = Vector3.new(9e9,9e9,9e9)
                while flying do
                    bg.cframe = Camera.CFrame
                    bv.velocity = (char.Humanoid.MoveDirection.Magnitude > 0) and (Camera.CFrame.LookVector * flySpeed) or Vector3.new(0,0,0)
                    task.wait()
                end
                bg:Destroy(); bv:Destroy()
            end)
        end
    end })
    SecS:Toggle({ Title = "Noclip", Callback = function(s) noclip = s end })
    SecS:Input({ Title = "Velocidade Fly", Callback = function(v) flySpeed = tonumber(v) or 50 end })

    -- ABA ÁUDIO (SEM TAGS)
    local TabAud = Window:Tab({ Title = "Áudio", Icon = "music" })
    local audID = ""
    TabAud:Input({ Title = "ID do Áudio", Callback = function(v) audID = v end })
    TabAud:Button({ Title = "AUDIO ALL", Callback = function() 
        if audID ~= "" then
            -- Camuflagem absoluta: mistura letras e números
            local disguised = "aud:" .. audID:gsub("(%d)", "%1-")
            TextChatService.TextChannels.RBXGeneral:SendAsync(disguised)
        end
    end })
    TabAud:Button({ Title = "STOP ALL", Callback = function() if currentAudio then currentAudio:Stop() end end })

    -- ABA ADMIN
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local Alvo = ""
    TabAdm:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Alvo = v end })
    
    local function Mandar(c)
        if Alvo ~= "" then
            TextChatService.TextChannels.RBXGeneral:SendAsync("command:{"..c.."} target:"..Alvo)
        end
    end

    TabAdm:Button({ Title = "KILL", Callback = function() Mandar("kill") end })
    TabAdm:Button({ Title = "FREEZE", Callback = function() Mandar("freeze") end })
    TabAdm:Button({ Title = "UNFREEZE", Callback = function() Mandar("unfreeze") end })
    TabAdm:Button({ Title = "VIEW", Callback = function() Camera.CameraSubject = Players[Alvo].Character.Humanoid end })
    TabAdm:Button({ Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end })

    -- ABA JUMPSCARES
    local TabJ = Window:Tab({ Title = "Jumpscares", Icon = "zap" })
    for i=1,4 do
        TabJ:Button({ Title = "Jumpscare "..i, Callback = function() Mandar("jumps"..i) end })
    end
end
