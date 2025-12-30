

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

--// Variáveis de Controle
local flying = false
local flySpeed = 50
local noclip = false
local noclipConnection
local espEnabled = false
local espSettings = { boxes = false, names = false, tracers = false }

--// --- SISTEMA DE ESP (VISUAL) ---
local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.new(1, 0, 0); box.Thickness = 1; box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false; name.Color = Color3.new(1, 1, 1); name.Size = 16; name.Center = true; name.Outline = true

    local tracer = Drawing.new("Line")
    tracer.Visible = false; tracer.Color = Color3.new(1, 0, 0); tracer.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer and espEnabled then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                -- Logica das Boxes
                if espSettings.boxes then
                    box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Visible = true
                else box.Visible = false end

                -- Logica dos Nomes
                if espSettings.names then
                    name.Position = Vector2.new(pos.X, pos.Y - (3500 / pos.Z) / 2 - 20)
                    name.Text = player.Name .. " [" .. math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    name.Visible = true
                else name.Visible = false end

                -- Logica dos Tracers
                if espSettings.tracers then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                else tracer.Visible = false end
            else
                box.Visible = false; name.Visible = false; tracer.Visible = false
            end
        else
            box.Visible = false; name.Visible = false; tracer.Visible = false
            if not player.Parent then connection:Disconnect(); box:Remove(); name:Remove(); tracer:Remove() end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--// --- FUNÇÕES DE MOVIMENTAÇÃO ---
local function toggleNoclip(state)
    noclip = state
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if noclip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else if noclipConnection then noclipConnection:Disconnect() end end
end

--// --- INTERFACE WINDUI ---
if Autorizados[LocalPlayer.Name] then
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Zaxin Hub | Premium",
        Author = "by: ZaxinX",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true
    })

    -- ABA SELF
    local MainTab = Window:Tab({ Title = "Self", Icon = "user" })
    local SectionMov = MainTab:Section({ Title = "Movimentação", Opened = true })
    SectionMov:Toggle({ Title = "Noclip", Callback = function(s) toggleNoclip(s) end })
    SectionMov:Slider({ Title = "Velocidade Fly", Min = 10, Max = 500, Callback = function(v) flySpeed = v end })

    -- ABA VISUAL (ESP)
    local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
    local SectionESP = VisualTab:Section({ Title = "ESP (Wallhack)", Opened = true })
    
    SectionESP:Toggle({ Title = "Ativar ESP Geral", Callback = function(s) espEnabled = s end })
    SectionESP:Toggle({ Title = "Mostrar Boxes", Callback = function(s) espSettings.boxes = s end })
    SectionESP:Toggle({ Title = "Mostrar Nomes", Callback = function(s) espSettings.names = s end })
    SectionESP:Toggle({ Title = "Mostrar Tracers", Callback = function(s) espSettings.tracers = s end })

    -- ABA ADMIN
    local AdminTab = Window:Tab({ Title = "Admin", Icon = "shield" })
    local SectionAdmin = AdminTab:Section({ Title = "Comandos", Opened = true })
    local Target = ""
    SectionAdmin:Dropdown({
        Title = "Alvo",
        Values = (function() local t = {} for _,p in pairs(Players:GetPlayers()) do table.insert(t, p.Name) end return t end)(),
        Callback = function(v) Target = v end
    })
    SectionAdmin:Button({ Title = "VIEW", Callback = function() 
        local p = Players:FindFirstChild(Target)
        if p and p.Character then Camera.CameraSubject = p.Character.Humanoid end
    end })
end
