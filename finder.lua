-- =======================================================
-- 🚀 KYZEN PET FINDER PREMIUM PRO MAX (24/7 AFK)
-- =======================================================
repeat task.wait() until game:IsLoaded()

-- 🛡️ SKILL 0: AUTO BYPASS LOADING SCREEN (Tự động bấm Play/Skip)
task.spawn(function()
    local LP = game:GetService("Players").LocalPlayer
    local PlayerGui = LP:WaitForChild("PlayerGui")
    
    print("[Kyzen Hub] Đang dò tìm nút Loading để bấm bỏ qua...")
    
    -- Cho nó lặp liên tục trong 15 giây đầu khi vừa vào server
    local startTime = os.clock()
    while (os.clock() - startTime) < 15 do
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local name = string.lower(gui.Name)
                local text = gui:IsA("TextButton") and string.lower(gui.Text) or ""
                
                -- Nhận diện các nút mang ý nghĩa "Bỏ qua" hoặc "Vào game"
                if string.find(name, "play") or string.find(text, "play") or 
                   string.find(name, "skip") or string.find(text, "skip") or
                   string.find(name, "continue") or string.find(text, "continue") or
                   string.find(name, "close") or string.find(text, "close") then
                    
                    pcall(function()
                        -- Dùng quyền năng của Executor ép nút đó phải chạy
                        if getconnections then
                            for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do
                                conn:Function() -- Hoặc conn:Fire()
                            end
                            for _, conn in ipairs(getconnections(gui.MouseButton1Down)) do
                                conn:Function()
                            end
                        end
                    end)
                end
            end
        end
        task.wait(1) -- Mỗi 1 giây quét 1 lần
    end
    print("[Kyzen Hub] Đã qua vòng gửi xe (Loading Screen)!")
end)

-- 🛡️ SKILL 1: ANTI-AFK (CHỐNG KICK 20 PHÚT CỦA ROBLOX)
-- ... (Giữ nguyên toàn bộ phần code NẠP MODULES và Finder ở dưới của ông) ...


-- 🛡️ SKILL 1: ANTI-AFK (CHỐNG KICK 20 PHÚT CỦA ROBLOX)
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    print("[Kyzen Hub] Đã bypass AFK 20 phút!")
end)

-- NẠP MODULES
local Repo = "https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/"
local Buy      = loadstring(game:HttpGet(Repo .. "buy.lua"))()
local Combat   = loadstring(game:HttpGet(Repo .. "combat.lua"))()
local Hop      = loadstring(game:HttpGet(Repo .. "hopserver.lua"))()
local Teleport = loadstring(game:HttpGet(Repo .. "teleport.lua"))()
local UI       = loadstring(game:HttpGet(Repo .. "ui.lua"))()

local Config = {
    WalkSpeed = 45,    
}

-- BẢNG XẾP HẠNG PET (Để chọn con VIP nhất đứng bảo vệ)
local RarityScore = {
    ["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3,
    ["Epic"] = 4, ["Legendary"] = 5, ["Mythic"] = 6, ["Super"] = 7
}

local Finder = { _running = false }

-- HÀM TÌM ĐỘ HIẾM TỪ TÊN
local function GetPetScore(petName)
    -- Giả lập: Nếu không có API lấy độ hiếm, ta ưu tiên theo tên hoặc gán ngẫu nhiên
    -- Bạn có thể bổ sung thêm tên các con pet siêu hiếm vào đây để nó ưu tiên (ví dụ: IceSerpent = 6)
    if string.match(petName, "Dragon") or string.match(petName, "Serpent") then return 6 end
    if string.match(petName, "Unicorn") then return 5 end
    return math.random(1, 3) -- Rác thì random
end

function Finder.ScanAndProcess()
    local map = workspace:FindFirstChild("Map")
    local petSpawns = map and map:FindFirstChild("WildPetSpawns")
    
    if not petSpawns then return false end
    
    local pets = petSpawns:GetChildren()
    -- QUÉT THÔNG MINH: Map trống không 1 bóng Pet -> Báo False để nhảy Server
    if #pets == 0 then return false end 

    local bestPetModel = nil
    local highestScore = 0

    -- PHA 1: CHẠY BỘ ĐI MUA SẠCH BÁCH TẤT CẢ PET TRONG MAP
    for _, pet in ipairs(pets) do
        if not Finder._running then break end
        if pet:IsA("Model") then
            local pName = pet:GetAttribute("PetName") or "Ẩn Danh"
            local root = pet:FindFirstChild("RootPart")
            
            if root then
                UI.UpdateStatus("🏃 Đang chạy tới cướp: " .. pName)
                -- Gọi chạy bộ (walkTo) thay vì bay
                Teleport.walkTo(root.Position, Config.WalkSpeed)
                task.wait(0.2)
                
                -- Vừa spam E cướp vừa oánh nhau
                Combat.EquipShovel()
                Combat.DefendPet()
                local success = Buy.interact(pet)
                
                if success then
                    UI.AddInventory(pName)
                    
                    -- Chấm điểm xem con này có xịn không
                    local score = GetPetScore(pName)
                    if score > highestScore and pet.Parent then
                        highestScore = score
                        bestPetModel = pet
                    end
                end
            end
        end
    end

    -- PHA 2: CHẾ ĐỘ VỆ SĨ VIP (Đứng bảo vệ con Pet xịn nhất)
    if bestPetModel and bestPetModel.Parent then
        local vipName = bestPetModel:GetAttribute("PetName") or "Pet VIP"
        UI.UpdateStatus("🛡️ Đang bảo vệ VIP: " .. vipName)
        print("[Kyzen Hub] Kích hoạt Vệ Sĩ cho " .. vipName)
        
        local root = bestPetModel:FindFirstChild("RootPart")
        if root then
            -- Trèo lên đầu nó (Y + 3)
            Teleport.walkTo(root.Position + Vector3.new(0, 3, 0), Config.WalkSpeed)
            
            -- Đứng quạt xẻng liên tục cho đến khi Server vứt con Pet vào vườn (Model biến mất)
            local timeout = 0
            while bestPetModel.Parent and timeout < 100 do -- max 10s chờ
                Combat.DefendPet()
                task.wait(0.1)
                timeout = timeout + 1
            end
        end
        UI.UpdateStatus("✅ Hàng đã về vườn an toàn!")
    end

    return true -- Trả về true vì vẫn vừa cướp xong, vòng sau sẽ check lại xem còn sót con nào không
end

function Finder.Start()
    Finder._running = true
    UI.Init()
    UI.UpdateTarget("All Pets - VIP Protect")
    pcall(function() UI.UpdateServer(#game:GetService("Players"):GetPlayers(), game.Players.MaxPlayers) end)

    task.spawn(function()
        print("==================================")
        print("🚀 KYZEN FINDER (PRO MAX 24/7) ACTIVE!")
        print("==================================")
        
        while Finder._running do
            local hasPets = Finder.ScanAndProcess()
            
            -- CHỈ NHẢY KHI MAP TRỐNG TRƠN (#pets == 0)
            if not hasPets and Finder._running then
                UI.UpdateStatus("🔄 Map đã sạch bóng! Đang đổi Server...")
                task.wait(2)
                Hop.Execute()
                break
            end
            task.wait(1.5)
        end
    end)
end

Finder.Start()
