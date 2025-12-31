--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
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

--// --- SISTEMA DE ESP ---
local function createESP(player)
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.new(1,0,0); box.Thickness = 1
    local name = Drawing.new("Text"); name.Visible = false; name.Color = Color3.new(1,1,1); name.Size = 16; name.Outline = true
    local tracer = Drawing.new("Line"); tracer.Visible = false; tracer.Color = Color3.new(1,0,0); tracer.Thickness = 1
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer and espEnabled then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                if espSettings.boxes then box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z); box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2); box.Visible = true else box.Visible = false end
                if espSettings.names then name.Position = Vector2.new(pos.X, pos.Y - 20); name.Text = player.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"; name.Visible = true else name.Visible = false end
                if espSettings.tracers then tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); tracer.To = Vector2.new(pos.X, pos.Y); tracer.Visible = true else tracer.Visible = false end
            else box.Visible = false; name.Visible = false; tracer.Visible = false end
        else box.Visible = false; name.Visible = false; tracer.Visible = false end
    end)
end
for _,p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--// --- INTERFACE WINDUI ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ 
        Title = "Zaxin Hub | Premium", 
        Author = "by: ZaxinX", 
        Size = UDim2.fromOffset(580, 460) 
    })

    -- BOTÃO PERSONALIZADO PARA MINIMIZAR (SEM BUGAR O PAINEL)
    local MiniButton = Instance.new("ScreenGui", game.CoreGui)
    local Btn = Instance.new("TextButton", MiniButton)
    Btn.Size = UDim2.new(0, 50, 0, 50)
    Btn.Position = UDim2.new(0.05, 0, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = "Z"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextSize = 25
    Btn.Font = Enum.Font.SourceSansBold
    
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(1, 0) -- Deixa redondo

    Btn.MouseButton1Click:Connect(function()
        Window:Toggle() -- Abre/Fecha o painel
    end)

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    local SecMov = TabSelf:Section({ Title = "Movimentação", Opened = true })
    SecMov:Toggle({ Title = "Fly", Callback = function() 
        flying = not flying
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if flying and root then
            local bg = Instance.new("BodyGyro", root); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
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

    -- ABA VISUAL
    local TabVis = Window:Tab({ Title = "Visual", Icon = "eye" })
    local SecESP = TabVis:Section({ Title = "ESP Settings", Opened = true })
    SecESP:Toggle({ Title = "ESP Geral", Callback = function(s) espEnabled = s end })
    SecESP:Toggle({ Title = "Boxes", Callback = function(s) espSettings.boxes = s end })
    SecESP:Toggle({ Title = "Names", Callback = function(s) espSettings.names = s end })
    SecESP:Toggle({ Title = "Tracers", Callback = function(s) espSettings.tracers = s end })

    -- ABA ÁUDIO
    local TabMus = Window:Tab({ Title = "Áudio", Icon = "music" })
    local SecAud = TabMus:Section({ Title = "Global Audio", Opened = true })
    local cID = ""
    SecAud:Input({ Title = "ID do Áudio", Callback = function(v) cID = v end })
    SecAud:Button({ Title = "AUDIO ALL", Callback = function() if cID ~= "" then TextChatService.TextChannels.RBXGeneral:SendAsync(";audioall "..cID) end end })

    -- ABA ADMIN
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local SecAdm = TabAdm:Section({ Title = "Comandos Admin", Opened = true })
    local Target = ""
    SecAdm:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Target = v end })
    
    local cmds = {"kill", "kick", "fling", "jail", "unjail", "view", "unview"}
    for _, c in ipairs(cmds) do 
        SecAdm:Button({ Title = c:upper(), Callback = function() 
            if c == "view" then Camera.CameraSubject = Players[Target].Character.Humanoid
            elseif c == "unview" then Camera.CameraSubject = LocalPlayer.Character.Humanoid
            else TextChatService.TextChannels.RBXGeneral:SendAsync(";"..c.." "..Target) end
        end }) 
    end
    
    -- ABA JUMPSCARES
    local TabJump = Window:Tab({ Title = "Jumpscares", Icon = "zap" })
    local SecJ = TabJump:Section({ Title = "Executar Jumpscare", Opened = true })
    for i=1,4 do 
        SecJ:Button({ Title = "Jumpscare "..i, Callback = function() 
            TextChatService.TextChannels.RBXGeneral:SendAsync(";jumps"..i.." "..Target) 
        end }) 
    end
end
