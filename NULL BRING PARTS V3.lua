-- NULL BRING PARTS v3 

local Gui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinimizeBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")
local Box = Instance.new("TextBox")
local Button = Instance.new("TextButton")

-- Configuración de la GUI (Estética Original)
Gui.Name = "NULL_BRING_PARTS_V3"
Gui.Parent = gethui()
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Ventana Principal
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Position = UDim2.new(0.35, 0, 0.4, 0)
Main.Size = UDim2.new(0, 300, 0, 160)
Main.Active = true
Main.Draggable = true

-- Barra de Título
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 28)

local TitleSeparator = Instance.new("Frame", TitleBar)
TitleSeparator.Size = UDim2.new(1, 0, 0, 1)
TitleSeparator.Position = UDim2.new(0, 0, 1, 0)
TitleSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleSeparator.BorderSizePixel = 0

TitleLabel.Name = "Title"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "NULL BRING PARTS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botón Cerrar (X)
CloseBtn.Name = "Close"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -28, 0, 0)
CloseBtn.Size = UDim2.new(0, 28, 1, 0)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18

-- Botón Minimizar (-)
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -56, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 28, 1, 0)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 20

-- Cuerpo
ContentFrame.Name = "Content"
ContentFrame.Parent = Main
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 28)
ContentFrame.Size = UDim2.new(1, 0, 1, -28)

-- Input Box
Box.Name = "PlayerBox"
Box.Parent = ContentFrame
Box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Box.BorderColor3 = Color3.fromRGB(255, 255, 255)
Box.BorderSizePixel = 1
Box.Position = UDim2.new(0.05, 0, 0.2, 0)
Box.Size = UDim2.new(0.9, 0, 0, 35)
Box.Font = Enum.Font.SourceSans
Box.PlaceholderText = "Escribe el nombre..."
Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.TextSize = 16

-- Botón BRING
Button.Name = "BringButton"
Button.Parent = ContentFrame
Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(0.05, 0, 0.6, 0)
Button.Size = UDim2.new(0.9, 0, 0, 40)
Button.Font = Enum.Font.SourceSansBold
Button.Text = "BRING: OFF"
Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Button.TextSize = 18

-----------------------------------------------------------
-- LÓGICA DE RED Y ATRACCIÓN (Integrada)
-----------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local selectedPlayer = nil
local blackHoleActive = false
local DescendantAddedConnection

-- Punto de atracción
local Folder = Instance.new("Folder", Workspace)
local PartTarget = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", PartTarget)
PartTarget.Anchored = true
PartTarget.CanCollide = false
PartTarget.Transparency = 1

-- Network & Simulation Radius
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.4626, 14.4626, 14.4626)
    }
    
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        if blackHoleActive then
            for _, p in pairs(getgenv().Network.BaseParts) do
                if p:IsDescendantOf(Workspace) and not p.Anchored then
                    p.Velocity = getgenv().Network.Velocity
                end
            end
        end
    end)
end

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        
        -- Limpiar fuerzas previas para evitar conflictos
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("Torque") then
                x:Destroy()
            end
        end

        v.CanCollide = false
        v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        table.insert(getgenv().Network.BaseParts, v)

        local Attachment2 = v:FindFirstChild("Attachment") or Instance.new("Attachment", v)
        
        -- Torque (Fuerza del segundo script para evitar giros locos)
        local Torque = Instance.new("Torque", v)
        Torque.Attachment0 = Attachment2
        Torque.Torque = Vector3.new(100000, 100000, 100000)

        -- AlignPosition (Atracción máxima)
        local AlignPos = Instance.new("AlignPosition", v)
        AlignPos.MaxForce = math.huge
        AlignPos.MaxVelocity = math.huge
        AlignPos.Responsiveness = 200
        AlignPos.Attachment0 = Attachment2
        AlignPos.Attachment1 = Attachment1
    end
end

local function getPlayer(name)
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
    return nil
end

-- Funciones de la Ventana
CloseBtn.MouseButton1Click:Connect(function()
    blackHoleActive = false
    if DescendantAddedConnection then DescendantAddedConnection:Disconnect() end
    Gui:Destroy()
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 300, 0, 28) or UDim2.new(0, 300, 0, 160)
end)

Box.FocusLost:Connect(function(enter)
    if enter then
        selectedPlayer = getPlayer(Box.Text)
        if selectedPlayer then
            Box.Text = selectedPlayer.Name
        else
            Box.Text = "Jugador no encontrado"
            task.delay(1, function() Box.Text = "" end)
        end
    end
end)

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        Button.Text = "BRING: ON"
        
        -- Aplicar a todo lo existente
        for _, v in ipairs(Workspace:GetDescendants()) do 
            ForcePart(v) 
        end
        
        -- Detectar partes nuevas
        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then 
                task.wait(0.1)
                ForcePart(v) 
            end
        end)

        -- Bucle de posición y traspaso de bloques (Nocollide)
        task.spawn(function()
            while blackHoleActive do
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    PartTarget.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
                    Attachment1.WorldCFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
                end
                
                -- Forzar que atraviesen bloques constantemente
                for _, p in pairs(getgenv().Network.BaseParts) do
                    if p:IsDescendantOf(Workspace) then
                        p.CanCollide = false
                    end
                end
                
                RunService.Heartbeat:Wait()
            end
        end)
    else
        Button.Text = "BRING: OFF"
        if DescendantAddedConnection then DescendantAddedConnection:Disconnect() end
        getgenv().Network.BaseParts = {}
    end
end

Button.MouseButton1Click:Connect(function()
    if selectedPlayer then
        toggleBlackHole()
    else
        Box.Text = "Selecciona un jugador"
        task.delay(1, function() Box.Text = "" end)
    end
end)
