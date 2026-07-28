-- File: PetFinder/ui.lua
local UI = {}
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ⚙️ CONFIG UI
local IMAGE_ID = "rbxassetid://105468345186897" -- Sửa ID ảnh của ông ở đây!
local BORDER_COLOR = Color3.fromRGB(255, 105, 180) -- Màu hồng (Hot Pink)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local BG_COLOR = Color3.fromRGB(20, 20, 20)

-- Khởi tạo biến lưu trữ
UI.InventoryData = {}

function UI.Init()
    -- Xóa UI cũ nếu có (chống trùng lặp khi chạy lại)
    local oldUi = CoreGui:FindFirstChild("KyzenPetFinderUI")
    if oldUi then oldUi:Destroy() end

    local screen = Instance.new("ScreenGui")
    screen.Name = "KyzenPetFinderUI"
    screen.Parent = (gethui and gethui()) or CoreGui

    -- 🔲 KHUNG CHÍNH
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = BG_COLOR
    mainFrame.Parent = screen
    mainFrame.Active = true
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = BORDER_COLOR
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame

    -- 🖼️ ẢNH NỀN CHỦ ĐỀ
    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = IMAGE_ID
    bgImage.ImageTransparency = 0.8 -- Làm mờ ảnh để không che mất chữ
    bgImage.Parent = mainFrame
    bgImage.ZIndex = 0

    -- Chức năng Kéo Thả (Draggable)
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

    -- HÀM TẠO CHỮ NHANH
    local function createText(name, text, pos, size, font, align, parent)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Text = text
        lbl.Position = pos
        lbl.Size = size
        lbl.Font = font
        lbl.TextColor3 = TEXT_COLOR
        lbl.TextXAlignment = align
        lbl.BackgroundTransparency = 1
        lbl.Parent = parent
        lbl.ZIndex = 2
        return lbl
    end

    -- HÀM TẠO DÒNG KẺ (DIVIDER)
    local function createDivider(pos)
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, 0, 0, 1)
        div.Position = pos
        div.BackgroundColor3 = BORDER_COLOR
        div.BorderSizePixel = 0
        div.Parent = mainFrame
        div.ZIndex = 2
    end

    -- 1. TITLE
    createText("Title", "🐾 Kyzen Pet Finder Premium", UDim2.new(0, 10, 0, 10), UDim2.new(1, -20, 0, 20), Enum.Font.GothamBold, Enum.TextXAlignment.Center, mainFrame)
    createDivider(UDim2.new(0, 0, 0, 40))

    -- 2. INFO SECTION
    UI.StatusLbl = createText("Status", "Status: 🟢 Running", UDim2.new(0, 15, 0, 45), UDim2.new(1, -30, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, mainFrame)
    UI.ServerLbl = createText("Server", "Server: --/--", UDim2.new(0, 15, 0, 65), UDim2.new(1, -30, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, mainFrame)
    UI.LastPetLbl = createText("LastPet", "Last Pet: None", UDim2.new(0, 15, 0, 85), UDim2.new(1, -30, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, mainFrame)
    UI.TargetLbl = createText("Target", "Target: All Pets", UDim2.new(0, 15, 0, 105), UDim2.new(1, -30, 0, 20), Enum.Font.Gotham, Enum.TextXAlignment.Left, mainFrame)
    createDivider(UDim2.new(0, 0, 0, 130))

    -- 3. INVENTORY SECTION
    createText("InvTitle", "📦 Inventory", UDim2.new(0, 15, 0, 135), UDim2.new(1, -30, 0, 20), Enum.Font.GothamBold, Enum.TextXAlignment.Left, mainFrame)
    
    UI.InvList = Instance.new("ScrollingFrame")
    UI.InvList.Size = UDim2.new(1, -20, 0, 180)
    UI.InvList.Position = UDim2.new(0, 10, 0, 160)
    UI.InvList.BackgroundTransparency = 1
    UI.InvList.ScrollBarThickness = 4
    UI.InvList.ScrollBarImageColor3 = BORDER_COLOR
    UI.InvList.Parent = mainFrame
    UI.InvList.ZIndex = 2
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = UI.InvList

    createDivider(UDim2.new(0, 0, 0, 350))

    -- 4. BOTTOM STATUS ANIMATION
    UI.ActionLbl = createText("Action", ". Đang hoạt động Finder pet .", UDim2.new(0, 10, 0, 365), UDim2.new(1, -20, 0, 20), Enum.Font.GothamItalic, Enum.TextXAlignment.Center, mainFrame)
    
    -- Hiệu ứng chớp tắt cho dòng Bottom Status
    task.spawn(function()
        local dots = {".", "..", "..."}
        local i = 1
        while UI.ActionLbl and UI.ActionLbl.Parent do
            UI.ActionLbl.Text = dots[i] .. " Đang hoạt động Finder pet " .. dots[i]
            i = i % 3 + 1
            task.wait(0.5)
        end
    end)
end

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
    
    -- Tăng số lượng pet
    UI.InventoryData[petName] = (UI.InventoryData[petName] or 0) + 1
    
    -- Vẽ lại danh sách Inventory
    if UI.InvList then
        -- Xóa các item cũ
        for _, child in ipairs(UI.InvList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        -- Tạo lại danh sách
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
            countLbl.TextColor3 = BORDER_COLOR
            countLbl.TextXAlignment = Enum.TextXAlignment.Right
            countLbl.BackgroundTransparency = 1
            countLbl.Parent = itemFrame
        end
        
        -- Cập nhật kích thước cuộn
        UI.InvList.CanvasSize = UDim2.new(0, 0, 0, #UI.InvList:GetChildren() * 30)
    end
end

return UI
