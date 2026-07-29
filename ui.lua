-- =======================================================
-- 🎨 KYZEN PET FINDER - GIAO DIỆN PREMIUM (THEME HỒNG)
-- =======================================================
local UI = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ⚙️ CONFIG MÀU SẮC & HÌNH ẢNH
local IMAGE_ID = "rbxassetid://105468345186897" -- Ảnh nền của ông
local PINK = Color3.fromRGB(255, 105, 180)      -- Hồng Hot Pink
local LIGHT_PINK = Color3.fromRGB(255, 180, 210) -- Hồng phấn (Tiêu đề)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255) -- Trắng tuyết

UI.InventoryData = {}

function UI.Init()
    -- Xóa UI cũ nếu có
    local oldUi = CoreGui:FindFirstChild("KyzenPetFinderUI")
    if oldUi then oldUi:Destroy() end

    local screen = Instance.new("ScreenGui")
    screen.Name = "KyzenPetFinderUI"
    screen.ResetOnSpawn = false
    screen.Parent = (gethui and gethui()) or CoreGui

    -- 1. TẠO KHUNG NỀN CHÍNH (ẢNH NỀN)
    local mainFrame = Instance.new("ImageLabel")
    mainFrame.Size = UDim2.new(0, 340, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 1 
    mainFrame.Image = IMAGE_ID
    mainFrame.ScaleType = Enum.ScaleType.Crop
    mainFrame.ImageTransparency = 1 -- Bắt đầu vô hình để làm Animation
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Parent = screen

    local uiCorner = Instance.new("UICorner", mainFrame)
    uiCorner.CornerRadius = UDim.new(0, 10)

    local uiStroke = Instance.new("UIStroke", mainFrame)
    uiStroke.Color = PINK
    uiStroke.Thickness = 2
    uiStroke.Transparency = 1

    -- Kéo thả UI mượt mà
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Hàm hỗ trợ tạo Text
    local function createText(name, text, pos, size, font, align, color, parent)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Text = text
        lbl.Position = pos
        lbl.Size = size
        lbl.Font = font
        lbl.TextColor3 = color
        lbl.TextXAlignment = align
        lbl.BackgroundTransparency = 1
        lbl.TextTransparency = 1 
        lbl.Parent = parent
        lbl.ZIndex = 3
        
        -- Viền đen mỏng cho chữ dễ đọc trên nền ảnh
        local txtStroke = Instance.new("UIStroke", lbl)
        txtStroke.Transparency = 1
        txtStroke.Thickness = 1
        txtStroke.Color = Color3.fromRGB(0, 0, 0)
        
        return lbl, txtStroke
    end

    -- 2. TIÊU ĐỀ
    local Title, tStroke = createText("Title", "KYZEN HUB PREMIUM", UDim2.new(0, 10, 0, 10), UDim2.new(1, -20, 0, 30), Enum.Font.GothamBold, Enum.TextXAlignment.Center, LIGHT_PINK, mainFrame)
    Title.TextSize = 20

    -- 3. KHUNG THÔNG TIN STATUS (Nền đen mờ nhìn xuyên thấu)
    local infoBox = Instance.new("Frame", mainFrame)
    infoBox.Size = UDim2.new(1, -30, 0, 100)
    infoBox.Position = UDim2.new(0, 15, 0, 50)
    infoBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoBox.BackgroundTransparency = 1
    local infoCorner = Instance.new("UICorner", infoBox)
    infoCorner.CornerRadius = UDim.new(0, 8)
    local infoStroke = Instance.new("UIStroke", infoBox)
    infoStroke.Color = PINK
    infoStroke.Thickness = 1
    infoStroke.Transparency = 1

    local s1, ss1 = createText("Status", "Status: 🟢 Khởi động...", UDim2.new(0, 10, 0, 10), UDim2.new(1, -20, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, TEXT_COLOR, infoBox)
    local s2, ss2 = createText("Server", "Server: --/--", UDim2.new(0, 10, 0, 30), UDim2.new(1, -20, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, TEXT_COLOR, infoBox)
    local s3, ss3 = createText("LastPet", "Last Pet: None", UDim2.new(0, 10, 0, 50), UDim2.new(1, -20, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, TEXT_COLOR, infoBox)
    local s4, ss4 = createText("Target", "Target: Loading...", UDim2.new(0, 10, 0, 70), UDim2.new(1, -20, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, TEXT_COLOR, infoBox)
    
    UI.StatusLbl = s1
    UI.ServerLbl = s2
    UI.LastPetLbl = s3
    UI.TargetLbl = s4

    -- 4. INVENTORY (Bảng cuộn)
    local InvTitle, itStroke = createText("InvTitle", "📦 INVENTORY", UDim2.new(0, 15, 0, 160), UDim2.new(1, -30, 0, 25), Enum.Font.GothamBold, Enum.TextXAlignment.Left, PINK, mainFrame)
    
    UI.InvList = Instance.new("ScrollingFrame", mainFrame)
    UI.InvList.Size = UDim2.new(1, -30, 0, 210)
    UI.InvList.Position = UDim2.new(0, 15, 0, 190)
    UI.InvList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.InvList.BackgroundTransparency = 1 
    UI.InvList.ScrollBarThickness = 3
    UI.InvList.ScrollBarImageColor3 = PINK
    UI.InvList.BorderSizePixel = 0
    UI.InvList.ZIndex = 3
    
    local invCorner = Instance.new("UICorner", UI.InvList)
    invCorner.CornerRadius = UDim.new(0, 8)
    local invUIStroke = Instance.new("UIStroke", UI.InvList)
    invUIStroke.Color = PINK
    invUIStroke.Transparency = 1
    invUIStroke.Thickness = 1

    local listLayout = Instance.new("UIListLayout", UI.InvList)
    listLayout.Padding = UDim.new(0, 5)

    -- 5. CHỮ CHẠY NHẤP NHÁY DƯỚI CÙNG
    UI.ActionLbl, UI.ActionStroke = createText("Action", ". Kyzen System .", UDim2.new(0, 10, 0, 420), UDim2.new(1, -20, 0, 20), Enum.Font.GothamBold, Enum.TextXAlignment.Center, PINK, mainFrame)
    
    -- 🎬 KÍCH HOẠT HIỆU ỨNG ANIMATION (FADE-IN MƯỢT MÀ)
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    TweenService:Create(mainFrame, tweenInfo, {ImageTransparency = 0}):Play()
    TweenService:Create(uiStroke, tweenInfo, {Transparency = 0}):Play()
    
    TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(tStroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(InvTitle, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(itStroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(UI.ActionLbl, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(UI.ActionStroke, tweenInfo, {Transparency = 0}):Play()
    
    TweenService:Create(infoBox, tweenInfo, {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(infoStroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(UI.InvList, tweenInfo, {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(invUIStroke, tweenInfo, {Transparency = 0}):Play()

    -- Bật hiển thị chữ
    local texts = {{s1,ss1}, {s2,ss2}, {s3,ss3}, {s4,ss4}}
    for _, tbl in ipairs(texts) do
        TweenService:Create(tbl[1], tweenInfo, {TextTransparency = 0}):Play()
        TweenService:Create(tbl[2], tweenInfo, {Transparency = 0}):Play()
    end

    -- Hiệu ứng chữ chạy dưới cùng
    task.spawn(function()
        local dots = {".", "..", "..."}
        local i = 1
        while UI.ActionLbl and UI.ActionLbl.Parent do
            UI.ActionLbl.Text = dots[i] .. " Hệ thống đang quét Pet " .. dots[i]
            i = i % 3 + 1
            task.wait(0.5)
        end
    end)
end

-- CÁC HÀM CẬP NHẬT THÔNG TIN (Giữ nguyên logic cũ)
function UI.UpdateStatus(text)
    if UI.StatusLbl then UI.StatusLbl.Text = "Status: " .. text end
end

function UI.UpdateServer(current, max)
    if UI.ServerLbl then UI.ServerLbl.Text = "Server: " .. tostring(current) .. "/" .. tostring(max) end
end

function UI.UpdateTarget(text)
    if UI.TargetLbl then UI.TargetLbl.Text = "Target: " .. text end
end

function UI.AddInventory(petName)
    if UI.LastPetLbl then UI.LastPetLbl.Text = "Last Pet: " .. petName end
    UI.InventoryData[petName] = (UI.InventoryData[petName] or 0) + 1
    
    if UI.InvList then
        for _, child in ipairs(UI.InvList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for pName, count in pairs(UI.InventoryData) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 25)
            itemFrame.BackgroundTransparency = 1
            itemFrame.Parent = UI.InvList
            
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.7, 0, 1, 0)
            nameLbl.Position = UDim2.new(0, 5, 0, 0)
            nameLbl.Text = pName
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextColor3 = TEXT_COLOR
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.BackgroundTransparency = 1
            nameLbl.Parent = itemFrame
            
            local countLbl = Instance.new("TextLabel")
            countLbl.Size = UDim2.new(0.3, 0, 1, 0)
            countLbl.Position = UDim2.new(0.7, 0, 0, 0)
            countLbl.Text = "x" .. tostring(count)
            countLbl.Font = Enum.Font.GothamBold
            countLbl.TextColor3 = PINK
            countLbl.TextXAlignment = Enum.TextXAlignment.Right
            countLbl.BackgroundTransparency = 1
            countLbl.Parent = itemFrame
        end
        UI.InvList.CanvasSize = UDim2.new(0, 0, 0, #UI.InvList:GetChildren() * 30)
    end
end

return UI
