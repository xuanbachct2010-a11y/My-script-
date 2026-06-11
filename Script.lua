--[[
    PREMIUM HITBOX EXPANDER & DRAWING + HIGHLIGHT ESP INTEGRATED SYSTEM
    Phiên bản nâng cấp: 
    - Tách biệt nút bật/tắt Viền phát quang (Highlight) riêng biệt.
    - Cơ chế Auto-Fix chống lỗi: Tự động phát hiện và áp lại Hitbox/Highlight.
    - Tích hợp tùy chọn Màu thường (TeamColor) và Rainbow (Cầu vồng) cho ESP + Highlight.
    - Điều chỉnh vị trí Nhãn Tên & Khoảng cách thấp xuống, gọn gàng hơn.
    Tác giả UI: !vcsk0#1516
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- === ĐỒNG BỘ TOÀN BỘ BIẾN TOÀN CỤC (GETGENV) ===
getgenv().HitboxSize = 15
getgenv().HitboxTransparency = 0.5 
getgenv().HitboxStatus = false
getgenv().TeamCheck = false -- Team Check của Hitbox

getgenv().Walkspeed = 16
getgenv().Jumppower = 50
getgenv().loopW = false
getgenv().loopJ = false

getgenv().TPSpeed = 3
getgenv().TPWalk = false
getgenv().Noclip = false
getgenv().InfJ = false

-- Biến cấu hình ESP nâng cao
getgenv().EspEnabled = false -- Cầu dao chính cho ESP Drawing
getgenv().EspGlow = false    -- Tách riêng nút Viền Phát Quang (Highlight)
getgenv().EspRainbow = false -- Nút tùy chọn Màu Rainbow cho toàn bộ hệ thống ESP
getgenv().EspNames = false   
getgenv().EspDistance = false
getgenv().EspBoxes = false
getgenv().EspLines = false
getgenv().EspTeamCheck = false -- Nút Team Check riêng dành cho hệ thống ESP

local ESPCache = {}

-- Biến ngầm tính toán màu cầu vồng theo thời gian
local RainbowColor = Color3.fromRGB(255, 0, 0)
RunService.RenderStepped:Connect(function()
    if getgenv().EspRainbow then
        local tickTime = tick()
        local r = math.sin(tickTime * 3) * 0.5 + 0.5
        local g = math.sin(tickTime * 3 + 2) * 0.5 + 0.5
        local b = math.sin(tickTime * 3 + 4) * 0.5 + 0.5
        RainbowColor = Color3.new(r, g, b)
    end
end)

-- === KHỞI TẠO MENU CHUẨN HITBOX EXPANDER ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/UI-Library/main/Source/MyUILib(Unamed).lua"))();
local Window = Library:Create("Hitbox Expander")

-- Nút bấm MENU tròn nhỏ (~10mm) di chuyển tự do được trên điện thoại
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

-- Tạo cấu trúc 3 Tab chuẩn
local HomeTab = Window:Tab("Home", "rbxassetid://10888331510")
local PlayerTab = Window:Tab("Players", "rbxassetid://12296135476")
local VisualTab = Window:Tab("Visuals", "rbxassetid://12308581351")

-- --- TAB 1: HOME (CÀI ĐẶT HITBOX) ---
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

-- --- TAB 2: PLAYERS (GIAN LẬN DI CHUYỂN) ---
PlayerTab:TextBox("WalkSpeed", function(value)
    getgenv().Walkspeed = tonumber(value) or 16
    pcall(function() Player.Character.Humanoid.WalkSpeed = getgenv().Walkspeed end)
end)

PlayerTab:Toggle("Loop WalkSpeed", function(state)
    getgenv().loopW = state
end)

PlayerTab:TextBox("JumpPower", function(value)
    getgenv().Jumppower = tonumber(value) or 50
    pcall(function() Player.Character.Humanoid.JumpPower = getgenv().Jumppower end)
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
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

-- --- TAB 3: VISUALS (HỆ THỐNG DRAWING ESP PHÂN CẤP + TEAM CHECK) ---
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


-- === LOGIC 1: ĐIỀU CHỈNH ĐỘ ĐẬM NHẠT VÀ KÍCH CỠ HITBOX (TÍCH HỢP AUTO-FIX) ===
RunService.RenderStepped:Connect(function()
    for _, v in next, Players:GetPlayers() do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            local isTeammate = (Player.Team == v.Team)
            
            if getgenv().HitboxStatus == true then
                -- Kiểm tra Team Check của Hitbox
                if (getgenv().TeamCheck == false) or (getgenv().TeamCheck == true and not isTeammate) then
                    -- Cơ chế quét lỗi: Nếu kích thước hoặc thuộc tính không khớp chuẩn -> Ép kích thước ngay lập tức
                    if root.Size ~= Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize) or root.Transparency ~= getgenv().HitboxTransparency then
                        pcall(function()
                            root.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                            root.Transparency = math.clamp(getgenv().HitboxTransparency, 0, 1) 
                            root.BrickColor = BrickColor.new("Really black") 
                            root.Material = Enum.Material.SmoothPlastic      
                            root.CanCollide = false
                        end)
                    end
                else
                    -- Nếu cùng team mà bật TeamCheck -> Trả lại kích thước gốc để tránh lỗi
                    if root.Size ~= Vector3.new(2, 2, 1) then
                        pcall(function()
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end)
                    end
                end
            else
                -- Khi tắt trạng thái Hitbox: Quét xem có ai chưa được trả lại gốc không để khôi phục nhanh
                if root.Size ~= Vector3.new(2, 2, 1) or root.Transparency ~= 1 then
                    pcall(function()
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                        root.BrickColor = BrickColor.new("Medium stone grey")
                        root.Material = Enum.Material.Plastic
                        root.CanCollide = false
                    end)
                end
            end
        end
    end
end)


-- === LOGIC 2: ĐỒNG BỘ TOÀN BỘ CƠ CHẾ DI CHUYỂN, NOCLIP, INF JUMP ===
RunService.Heartbeat:Connect(function()
    pcall(function()
        if getgenv().loopW and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = getgenv().Walkspeed
        end
        if getgenv().loopJ and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = getgenv().Jumppower
        end
        if getgenv().Noclip and Player.Character then
            for _, part in ipairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        pcall(function()
            if getgenv().TPWalk and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                local hum = Player.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then
                    local tpSpeed = getgenv().TPSpeed and tonumber(getgenv().TPSpeed) or 3
                    Player.Character:TranslateBy(hum.MoveDirection * tpSpeed)
                end
            end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if getgenv().InfJ and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)


-- === LOGIC 3: HỆ THỐNG DRAWING ESP PHÂN CẤP + HIGHLIGHT (TÍCH HỢP ĐIỀU KHIỂN RIÊNG & RAINBOW) ===
local function ApplyDrawingESP(targetPlayer)
    if ESPCache[targetPlayer] then return end

    local esp = {
        Highlight = Instance.new("Highlight"), -- Khởi tạo Highlight phát quang
        NameLabel = Drawing.new("Text"),
        DistanceLabel = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"), 
        Connection = nil
    }

    -- Cấu hình mặc định cho Highlight phát quang
    esp.Highlight.FillTransparency = 1
    esp.Highlight.OutlineTransparency = 1
    esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Xử lý an toàn khi nhân vật chưa load xong hoàn toàn
    if targetPlayer.Character then
        esp.Highlight.Parent = targetPlayer.Character
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

    esp.Connection = RunService.RenderStepped:Connect(function()
        local char = targetPlayer.Character
        
        -- Cơ chế kiểm tra và tự sửa lỗi: Đảm bảo Highlight luôn được gắn chặt vào Character kể cả khi hồi sinh
        if char and esp.Highlight.Parent ~= char then
            pcall(function() esp.Highlight.Parent = char end)
        end

        -- Xác định điều kiện lọc Team Check của ESP
        local isTeammate = (targetPlayer.Team == Player.Team)
        local isEspAllowed = getgenv().EspEnabled and not (getgenv().EspTeamCheck and isTeammate)
        local isGlowAllowed = getgenv().EspGlow and not (getgenv().EspTeamCheck and isTeammate)

        -- Hệ thống gán màu linh hoạt: Nếu bật Rainbow thì dùng màu Rainbow, ngược lại dùng TeamColor gốc
        local currentEspColor = getgenv().EspRainbow and RainbowColor or targetPlayer.TeamColor.Color

        -- Điều khiển Độc lập Viền phát quang (Highlight)
        if isGlowAllowed and char and char:FindFirstChild("HumanoidRootPart") then
            esp.Highlight.Enabled = true
            esp.Highlight.OutlineColor = currentEspColor
            esp.Highlight.FillColor = currentEspColor
            esp.Highlight.OutlineTransparency = 0  -- Viền sáng rõ nét
            esp.Highlight.FillTransparency = 0.6    -- Thân mờ nhẹ xuyên tường
        else
            esp.Highlight.Enabled = false
        end

        -- Nếu không bật ESP Tổng hoặc đối tượng không hợp lệ -> Ẩn toàn bộ giao diện vẽ Drawing
        if not isEspAllowed or not char or not Player.Character then
            esp.NameLabel.Visible = false
            esp.DistanceLabel.Visible = false
            esp.Box.Visible = false
            esp.Line.Visible = false
            return
        end

        local head = char:FindFirstChild("Head")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local myRoot = Player.Character:FindFirstChild("HumanoidRootPart")

        if head and rootPart and myRoot then
            local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position)
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)

            local distance = math.floor((rootPart.Position - myRoot.Position).Magnitude)

            -- 1. Điều kiện hiện Tên (Đã hạ thấp Y xuống -6 cho bám sát đầu hơn)
            if getgenv().EspNames and headOnScreen then
                esp.NameLabel.Visible = true
                esp.NameLabel.Position = Vector2.new(headPos.X, headPos.Y - 6)
                esp.NameLabel.Text = targetPlayer.Name
                esp.NameLabel.Color = currentEspColor
            else
                esp.NameLabel.Visible = false
            end

            -- 2. Điều kiện hiện Khoảng Cách (Đã hạ thấp Y xuống +10 cho gọn gàng ngay dưới tên/đầu)
            if getgenv().EspDistance and headOnScreen then
                esp.DistanceLabel.Visible = true
                esp.DistanceLabel.Position = Vector2.new(headPos.X, headPos.Y + 10)
                esp.DistanceLabel.Text = string.format("[%d studs]", distance)
                esp.DistanceLabel.Color = getgenv().EspRainbow and RainbowColor or Color3.fromRGB(255, 255, 255)
            else
                esp.DistanceLabel.Visible = false
            end

            -- 3. Điều kiện hiện Hộp vuông định vị
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

            -- 4. Điều kiện hiện Tia chỉ đường xuống chân mục tiêu
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
    end)
end

-- Quản lý người chơi mới vào hoặc hồi sinh trong server phòng game
Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function(char)
        if ESPCache[p] then
            pcall(function() ESPCache[p].Highlight.Parent = char end)
        end
    end)
    ApplyDrawingESP(p) 
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        if ESPCache[p].Connection then ESPCache[p].Connection:Disconnect() end
        pcall(function() ESPCache[p].Highlight:Destroy() end)
        pcall(function() ESPCache[p].NameLabel:Remove() end)
        pcall(function() ESPCache[p].DistanceLabel:Remove() end)
        pcall(function() ESPCache[p].Box:Remove() end)
        pcall(function() ESPCache[p].Line:Remove() end)
        ESPCache[p] = nil
    end
end)

-- Chạy vòng lặp kích hoạt ban đầu cho tất cả mọi người có sẵn
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then 
        p.CharacterAdded:Connect(function(char)
            if ESPCache[p] then
                pcall(function() ESPCache[p].Highlight.Parent = char end)
            end
        end)
        ApplyDrawingESP(p) 
    end
end
