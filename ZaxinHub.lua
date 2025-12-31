--// Serviços
local Players = game:GetService("Players")
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

--// Variáveis de Controle
local flySpeed = 50
local flying = false
local noclip = false
local espEnabled = false

--// --- SISTEMA DE ESP (Boxes e Nomes) ---
local function createESP(player)
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.fromRGB(255, 0, 0); box.Thickness = 1
    local name = Drawing.new("Text"); name.Visible = false; name.Color = Color3.new(1, 1, 1); name.Size = 14; name.Outline = true

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer and espEnabled then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2); box.Visible = true
                name.Position = Vector2.new(pos.X, pos.Y - 25); name.Text = player.Name; name.Visible = true
            else box.Visible = false; name.Visible = false end
        else box.Visible = false; name.Visible = false end
    end)
end
for _,p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--// --- FUNÇÃO FLING (Para Brookhaven) ---
local function BrookhavenFling(targetPlayer)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetChar = targetPlayer.Character
    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

    if hrp and targetHrp then
        local velocity = hrp.Velocity
        hrp.Velocity = Vector3.new(500000, 500000, 500000) -- Força física para jogar longe
        hrp.CFrame = targetHrp.CFrame
        task.wait(0.1)
        hrp.Velocity = velocity
    end
end

--// --- NOCLIP ---
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--// --- INTERFACE WINDUI ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({ Title = "Zaxin Hub | Brookhaven", Author = "by: ZaxinX", Size = UDim2.fromOffset(580, 460) })

    -- Botão "Z" para Minimizar
    local MiniButton = Instance.new("ScreenGui", game.CoreGui); local Btn = Instance.new("TextButton", MiniButton)
    Btn.Size = UDim2.new(0, 45, 0, 45); Btn.Position = UDim2.new(0, 15, 0.5, 0); Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = "Z"; Btn.TextColor3 = Color3.new(1,1,1); Btn.TextSize = 20; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    Btn.MouseButton1Click:Connect(function() Window:Toggle() end)

    -- ABA SELF
    local TabSelf = Window:Tab({ Title = "Self", Icon = "user" })
    TabSelf:Toggle({ Title = "Fly", Callback = function(s) 
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
    TabSelf:Toggle({ Title = "Noclip", Callback = function(s) noclip = s end })
    TabSelf:Input({ Title = "Velocidade Fly", Callback = function(v) flySpeed = tonumber(v) or 50 end })

    -- ABA VISUAL
    local TabVis = Window:Tab({ Title = "Visual", Icon = "eye" })
    TabVis:Toggle({ Title = "Ativar ESP", Callback = function(s) espEnabled = s end })

    -- ABA ADMIN (BROOKHAVEN)
    local TabAdm = Window:Tab({ Title = "Admin", Icon = "shield" })
    local Alvo = ""
    TabAdm:Dropdown({ Title = "Alvo", Values = (function() local t={}; for _,p in pairs(Players:GetPlayers()) do table.insert(t,p.Name) end; return t end)(), Callback = function(v) Alvo = v end })
    
    TabAdm:Button({ Title = "FLING (Jogar Longe)", Callback = function() 
        local p = Players:FindFirstChild(Alvo)
        if p then BrookhavenFling(p) end
    end })
    
    TabAdm:Button({ Title = "VIEW PLAYER", Callback = function() if Alvo ~= "" then Camera.CameraSubject = Players[Alvo].Character.Humanoid end end })
    TabAdm:Button({ Title = "UNVIEW", Callback = function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end })
    
    TabAdm:Button({ Title = "GOTO (Teleportar)", Callback = function() 
        local p = Players:FindFirstChild(Alvo)
        if p and p.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end
    end })
end
