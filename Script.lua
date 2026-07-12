if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().HitboxSize = 15
getgenv().HitboxTransparency = 0.5 
getgenv().HitboxStatus = false
getgenv().TeamCheck = false

getgenv().Walkspeed = 16
getgenv().Jumppower = 50
getgenv().loopW = false
getgenv().loopJ = false

getgenv().TPSpeed = 3
getgenv().TPWalk = false
getgenv().Noclip = false
getgenv().InfJ = false

getgenv().EspEnabled = false 
getgenv().EspGlow = false    
getgenv().EspRainbow = false 
getgenv().EspNames = false   
getgenv().EspDistance = false
getgenv().EspBoxes = false
getgenv().EspLines = false
getgenv().EspTeamCheck = false 

local ESPCache = {}
local RainbowColor = Color3.fromRGB(255, 0, 0)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/UI-Library/main/Source/MyUILib(Unamed).lua"))();
local Window = Library:Create("Hitbox Expander")

local ToggleGui = Instance.new("ScreenGui", game.CoreGui)
local Toggle = Instance.new("TextButton", ToggleGui)

Toggle.Name = "Toggle"
Toggle.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Toggle.BackgroundTransparency = 0.4
Toggle.Position = UDim2.new(0.5, -22, 0.05, 0)
Toggle.Size = UDim2.new(0, 45, 0, 45)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "MENU"
Toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
Toggle.TextSize = 10
Toggle.Active = true
Toggle.Draggable = true

local uiCorner = Instance.new("UICorner", Toggle)
uiCorner.CornerRadius = UDim.new(0, 8)

Toggle.MouseButton1Click:connect(function()
    Library:ToggleUI()
end)

local HomeTab = Window:Tab("Home", "rbxassetid://10888331510")
local PlayerTab = Window:Tab("Players", "rbxassetid://12296135476")
local VisualTab = Window:Tab("Visuals", "rbxassetid://12308581351")
local MiscTab = Window:Tab("Misc", "rbxassetid://10888331510")

HomeTab:InfoLabel("Chỉnh kích cỡ & Độ đậm nhạt bằng cách nhập số")
HomeTab:Section("Settings")

HomeTab:TextBox("Hitbox Size", function(value)
    getgenv().HitboxSize = tonumber(value) or 15
end)

HomeTab:TextBox("Hitbox Transparency (0 -> 1)", function(number)
    getgenv().HitboxTransparency = tonumber(number) or 0.5
end)

HomeTab:Section("Main Logic")

HomeTab:Toggle("Bật Hitbox Rộng", function(state)
    getgenv().HitboxStatus = state
end)

HomeTab:Toggle("Team Check Hitbox", function(state)
    getgenv().TeamCheck = state
end)

HomeTab:Keybind("Phím ẩn nhanh UI (PC)", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)

PlayerTab:TextBox("WalkSpeed", function(value)
    getgenv().Walkspeed = tonumber(value) or 16
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = getgenv().Walkspeed
        end
    end
end)

PlayerTab:Toggle("Loop WalkSpeed", function(state)
    getgenv().loopW = state
end)

PlayerTab:TextBox("JumpPower", function(value)
    getgenv().Jumppower = tonumber(value) or 50
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = getgenv().Jumppower
        end
    end
end)

PlayerTab:Toggle("Loop JumpPower", function(state)
    getgenv().loopJ = state
end)

PlayerTab:TextBox("TP Speed", function(value)
    getgenv().TPSpeed = tonumber(value) or 3
end)

PlayerTab:Toggle("TP Walk", function(s)
    getgenv().TPWalk = s
end)

PlayerTab:Toggle("Noclip", function(s)
    getgenv().Noclip = s
end)

PlayerTab:Toggle("Infinite Jump", function(s)
    getgenv().InfJ = s
end)

PlayerTab:Button("Rejoin", function()
    local ts = game:GetService("TeleportService")
    pcall(function()
        ts:Teleport(game.PlaceId, Player)
    end)
end)

VisualTab:InfoLabel("Bật công cụ tổng trước, sau đó chọn nút con bên dưới")
VisualTab:Section("Cầu dao chính")
VisualTab:Toggle("Kích hoạt ESP Tổng (Master)", function(state) getgenv().EspEnabled = state end)
VisualTab:Toggle("Bật Viền Phát Quang (Glow Highlight)", function(state) getgenv().EspGlow = state end)
VisualTab:Toggle("Chế độ Màu Cầu Vồng (Rainbow)", function(state) getgenv().EspRainbow = state end)
VisualTab:Toggle("Team Check ESP (Chỉ hiện địch)", function(state) getgenv().EspTeamCheck = state end)

VisualTab:Section("Tùy chọn hiển thị")
VisualTab:Toggle("Hiện Tên (Name)", function(state) getgenv().EspNames = state end)
VisualTab:Toggle("Hiện Khoảng Cách (Distance)", function(state) getgenv().EspDistance = state end)
VisualTab:Toggle("Hiện Khung Hộp (Box)", function(state) getgenv().EspBoxes = state end)
VisualTab:Toggle("Hiện Tia Chỉ Đường (Lines)", function(state) getgenv().EspLines = state end)

MiscTab:Section("Utilities")
MiscTab:Button("Get Click TP Tool", function()
    local mouse = Player:GetMouse()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "Equip to Click TP"
    
    tool.Activated:connect(function()
        local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
        pos = CFrame.new(pos.X, pos.Y, pos.Z)
        local char = Player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = pos
            end
        end
    end)
    
    tool.Parent = Player.Backpack
end)

local function ApplyDrawingESP(targetPlayer)
    if ESPCache[targetPlayer] then return end

    local esp = {
        Highlight = Instance.new("Highlight"),
        NameLabel = Drawing.new("Text"),
        DistanceLabel = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line")
    }

    esp.Highlight.FillTransparency = 1
    esp.Highlight.OutlineTransparency = 1
    esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local char = targetPlayer.Character
    if char then
        esp.Highlight.Parent = char
    end

    esp.NameLabel.Center = true
    esp.NameLabel.Outline = true
    esp.NameLabel.Size = 14
    
    esp.DistanceLabel.Center = true
    esp.DistanceLabel.Outline = true
    esp.DistanceLabel.Size = 12
    
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false

    esp.Line.Thickness = 1

    ESPCache[targetPlayer] = esp
end

local function RemoveESP(targetPlayer)
    local esp = ESPCache[targetPlayer]
    if esp then
        if esp.Highlight then
            pcall(function() esp.Highlight:Destroy() end)
        end
        if esp.NameLabel then esp.NameLabel:Remove() end
        if esp.DistanceLabel then esp.DistanceLabel:Remove() end
        if esp.Box then esp.Box:Remove() end
        if esp.Line then esp.Line:Remove() end
        ESPCache[targetPlayer] = nil
    end
end

Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function(char)
        local esp = ESPCache[p]
        if esp and esp.Highlight then
            pcall(function() esp.Highlight.Parent = char end)
        end
    end)
    ApplyDrawingESP(p) 
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then 
        p.CharacterAdded:Connect(function(char)
            local esp = ESPCache[p]
            if esp and esp.Highlight then
                pcall(function() esp.Highlight.Parent = char end)
            end
        end)
        ApplyDrawingESP(p) 
    end
end

RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    if getgenv().EspRainbow then
        local r = math.sin(tickTime * 3) * 0.5 + 0.5
        local g = math.sin(tickTime * 3 + 2) * 0.5 + 0.5
        local b = math.sin(tickTime * 3 + 4) * 0.5 + 0.5
        RainbowColor = Color3.new(r, g, b)
    end

    local myChar = Player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Player then
            local vChar = v.Character
            local vRoot = vChar and vChar:FindFirstChild("HumanoidRootPart")
            
            if vRoot then
                local isTeammate = (Player.Team == v.Team)
                
                if getgenv().HitboxStatus == true then
                    if (getgenv().TeamCheck == false) or (getgenv().TeamCheck == true and not isTeammate) then
                        if vRoot.Size ~= Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize) or vRoot.Transparency ~= getgenv().HitboxTransparency then
                            vRoot.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                            vRoot.Transparency = math.clamp(getgenv().HitboxTransparency, 0, 1) 
                            vRoot.BrickColor = BrickColor.new("Really black") 
                            vRoot.Material = Enum.Material.SmoothPlastic      
                            vRoot.CanCollide = false
                        end
                    else
                        if vRoot.Size ~= Vector3.new(2, 2, 1) then
                            vRoot.Size = Vector3.new(2, 2, 1)
                            vRoot.Transparency = 1
                        end
                    end
                else
                    if vRoot.Size ~= Vector3.new(2, 2, 1) or vRoot.Transparency ~= 1 then
                        vRoot.Size = Vector3.new(2, 2, 1)
                        vRoot.Transparency = 1
                        vRoot.BrickColor = BrickColor.new("Medium stone grey")
                        vRoot.Material = Enum.Material.Plastic
                        vRoot.CanCollide = false
                    end
                end
            end

            local esp = ESPCache[v]
            if esp then
                if vChar and esp.Highlight and esp.Highlight.Parent ~= vChar then
                    pcall(function() esp.Highlight.Parent = vChar end)
                end

                local isTeammate = (v.Team == Player.Team)
                local isEspAllowed = getgenv().EspEnabled and not (getgenv().EspTeamCheck and isTeammate)
                local isGlowAllowed = getgenv().EspGlow and not (getgenv().EspTeamCheck and isTeammate)
                local currentEspColor = getgenv().EspRainbow and RainbowColor or v.TeamColor.Color

                if isGlowAllowed and vChar and vRoot then
                    esp.Highlight.Enabled = true
                    esp.Highlight.OutlineColor = currentEspColor
                    esp.Highlight.FillColor = currentEspColor
                    esp.Highlight.OutlineTransparency = 0  
                    esp.Highlight.FillTransparency = 0.6    
                else
                    esp.Highlight.Enabled = false
                end

                if not isEspAllowed or not vChar or not myChar then
                    esp.NameLabel.Visible = false
                    esp.DistanceLabel.Visible = false
                    esp.Box.Visible = false
                    esp.Line.Visible = false
                else
                    local head = vChar:FindFirstChild("Head")
                    if head and vRoot and myRoot then
                        local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position)
                        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(vRoot.Position)
                        local distance = math.floor((vRoot.Position - myRoot.Position).Magnitude)

                        if getgenv().EspNames and headOnScreen then
                            esp.NameLabel.Visible = true
                            esp.NameLabel.Position = Vector2.new(headPos.X, headPos.Y - 6)
                            esp.NameLabel.Text = v.Name
                            esp.NameLabel.Color = currentEspColor
                        else
                            esp.NameLabel.Visible = false
                        end

                        if getgenv().EspDistance and headOnScreen then
                            esp.DistanceLabel.Visible = true
                            esp.DistanceLabel.Position = Vector2.new(headPos.X, headPos.Y + 10)
                            esp.DistanceLabel.Text = string.format("[%d studs]", distance)
                            esp.DistanceLabel.Color = getgenv().EspRainbow and RainbowColor or Color3.fromRGB(255, 255, 255)
                        else
                            esp.DistanceLabel.Visible = false
                        end

                        if getgenv().EspBoxes and rootOnScreen then
                            esp.Box.Visible = true
                            local sizeX = 2000 / rootPos.Z
                            local sizeY = 3000 / rootPos.Z
                            esp.Box.Size = Vector2.new(sizeX, sizeY)
                            esp.Box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                            esp.Box.Color = currentEspColor
                        else
                            esp.Box.Visible = false
                        end

                        if getgenv().EspLines and rootOnScreen and rootPos.Z > 0 then
                            esp.Line.Visible = true
                            esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            esp.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                            esp.Line.Color = currentEspColor
                        else
                            esp.Line.Visible = false
                        end
                    else
                        esp.NameLabel.Visible = false
                        esp.DistanceLabel.Visible = false
                        esp.Box.Visible = false
                        esp.Line.Visible = false
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if getgenv().loopW then
                hum.WalkSpeed = getgenv().Walkspeed
            end
            if getgenv().loopJ then
                hum.JumpPower = getgenv().Jumppower
            end
        end
        if getgenv().Noclip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if getgenv().TPWalk then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.MoveDirection.Magnitude > 0 then
                    local tpSpeed = getgenv().TPSpeed and tonumber(getgenv().TPSpeed) or 3
                    char:TranslateBy(hum.MoveDirection * tpSpeed)
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if getgenv().InfJ then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState("Jumping")
            end
        end
    end
end)
