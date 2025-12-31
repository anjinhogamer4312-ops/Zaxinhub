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
    [";jumps1"] = {img = "rbxassetid://126754882337711", snd = "rbxassetid://138873214826309"},
    [";jumps2"] = {img = "rbxassetid://86379969987314", snd = "rbxassetid://143942090"},
    [";jumps3"] = {img = "rbxassetid://127382022168206", snd = "rbxassetid://143942090"},
    [";jumps4"] = {img = "rbxassetid://95973611964555", snd = "rbxassetid://138873214826309"},
}

--// Variáveis
local flySpeed = 50
local flying = false
local noclip = false
local currentAudio = nil
local noclipConnection

--// --- FUNÇÃO JUMPSCARE ---
local function AtivarJumpscare(data)
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1,0,1,0); img.Image = data.img; img.BackgroundTransparency = 1; img.ZIndex = 999
    local s = Instance.new("Sound", workspace)
    s.SoundId = data.snd; s.Volume = 10; s:Play()
    task.wait(2.5)
    gui:Destroy(); s:Destroy()
end

--// --- LÓGICA NOCLIP ---
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

--// --- RECEBIMENTO DE COMANDOS (Áudio sem Tags) ---
local function ExecutarComando(msg, autor)
    local texto = msg:lower(); local alvo = LocalPlayer.Name:lower()
    
    -- Jumpscares
    for cmd, data in pairs(JUMPSCARES) do if texto:find(cmd) and texto:find(alvo) then AtivarJumpscare(data) end end
    
    -- Áudio (Tenta ler o ID mesmo se houver caracteres em volta para evitar tags)
    if texto:find(";audioall") then
        local id = texto:match("%d+")
        if id then 
            if currentAudio then currentAudio:Destroy() end
            currentAudio = Instance.new("Sound", workspace); currentAudio.SoundId = "rbxassetid://"..id; currentAudio.Volume = 5; currentAudio:Play()
        end
    end
end
TextChatService.MessageReceived:Connect(function(msg) if msg.TextSource then ExecutarComando(msg.Text, msg.TextSource.Name) end end)

--// --- INTERFACE ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ Title = "Zaxin Hub", Author = "by: ZaxinX", Size = UDim2.fromOffset(580, 460) })

    -- Botão Minimizar "Z"
    local MiniButton = Instance.new("ScreenGui", game.CoreGui); local Btn = Instance.new("TextButton", MiniButton)
    Btn.Size = UDim2.new(0, 45, 0, 45); Btn.Position = UDim2.new(0, 15, 0.5, 0); Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.Text = "Z"; Btn.TextColor3 = Color3.new(1,1,1); Btn.TextSize = 20; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    Btn.MouseButton1Click:Connect(function() Window:Toggle() end)

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecMov = TabSelf:Section({ Title = "Movimentação", Opened = true })
    SecMov:Toggle({ Title = "Fly", Callback = function() 
        flying = not flying
        if flying then
            local char = LocalPlayer.Character; local root = char.HumanoidRootPart
            local bg = Instance.new("BodyGyro", root); bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            local bv = Instance.new("BodyVelocity", root); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            task.spawn(function()
                while flying do
                    bg.cframe = Camera.CFrame
                    bv.velocity = (char.Humanoid.MoveDirection.Magnitude > 0) and (Camera.CFrame.LookVector * flySpeed) or Vector3.new(0,0,0)
                    task.wait()
                end
                bg:Destroy(); bv:Destroy()
            end)
        end
    end })
    SecMov:Toggle({ Title = "Noclip", Callback = function(s) noclip = s end })
    SecMov:Input({ Title = "Fly Speed", Callback = function(v) flySpeed = tonumber(v) or 50 end })

    -- ABA ÁUDIO
    local TabAud = Window:Tab({ Title = "Áudio", Icon = "music" })
    local SecA = TabAud:Section({ Title = "Global", Opened = true })
    local audID = ""
    SecA:Input({ Title = "ID do Som", Callback = function(v) audID = v end })
    SecA:Button({ Title = "AUDIO ALL", Callback = function() 
        if audID ~= "" then 
            -- Envia o ID com um ponto para tentar burlar o filtro de números do chat
            TextChatService.TextChannels.RBXGeneral:SendAsync(";audioall ."..audID..".") 
        end 
    end })
    SecA:Button({ Title = "STOP ALL", Callback = function() if currentAudio then currentAudio:Stop() end end })

    -- ABA ADMIN
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local SecAd = TabAdm:Section({ Title = "Comandos de Troll", Opened = true })
    local Alvo = ""
    SecAd:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Alvo = v end })
    
    local function Cmd(c) if Alvo ~= "" then TextChatService.TextChannels.RBXGeneral:SendAsync(";"..c.." "..Alvo) end end
    
    SecAd:Button({ Title = "KILL", Callback = function() Cmd("kill") end })
    SecAd:Button({ Title = "FLING", Callback = function() Cmd("fling") end })
    SecAd:Button({ Title = "JAIL", Callback = function() Cmd("jail") end })
    SecAd:Button({ Title = "FREEZE", Callback = function() Cmd("freeze") end })
    SecAd:Button({ Title = "EXPLODE", Callback = function() Cmd("explode") end })
    
    -- ABA JUMPSCARES
    local TabJ = Window:Tab({ Title = "Jumpscares", Icon = "zap" })
    local SecJ = TabJ:Section({ Title = "Executar Jumpscare", Opened = true })
    for i=1,4 do SecJ:Button({ Title = "Jumpscare "..i, Callback = function() Cmd("jumps"..i) end }) end
end
