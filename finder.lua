-- =======================================================
-- 🚀 KYZEN PET FINDER PREMIUM (MAIN CORE)
-- =======================================================
repeat task.wait() until game:IsLoaded()

-- 1. NẠP VŨ KHÍ TỪ KHO (GITHUB)
local Repo = "https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/"
local Buy      = loadstring(game:HttpGet(Repo .. "buy.lua"))()
local Combat   = loadstring(game:HttpGet(Repo .. "combat.lua"))()
local Hop      = loadstring(game:HttpGet(Repo .. "hopserver.lua"))()
local Teleport = loadstring(game:HttpGet(Repo .. "teleport.lua"))()
local UI       = loadstring(game:HttpGet(Repo .. "ui.lua"))()

-- 2. TRUNG TÂM ĐIỀU KHIỂN (CONFIG)
local Config = {
    BuyAllPets = true, -- Bật chế độ "Càn quét mọi loại Pet"
    FlySpeed = 150,    -- Tốc độ bay (chuẩn an toàn)
    Targets = {        -- Danh sách VIP (chỉ dùng nếu BuyAllPets = false)
        ["IceSerpent"]      = true,
        ["Unicorn"]         = true,
        ["BlackDragon"]     = true,
        ["Firefly"]         = true,
        ["GoldenDragonfly"] = true,
        ["Raccoon"]         = true
    }
}

-- 3. KHỞI TẠO BỘ MÁY (FINDER ENGINE)
local Finder = {
    _running = false,
    _ignoredPets = {} -- Sổ đen: Lưu các pet bị lỗi/kẹt để bỏ qua
}

-- [HÀM CỐT LÕI]: Quét Map và Xử Lý
function Finder.ScanAndProcess()
    local map = workspace:FindFirstChild("Map")
    local petSpawns = map and map:FindFirstChild("WildPetSpawns")
    
    -- Nếu map không có thư mục chứa Pet -> Báo cáo hết hàng
    if not petSpawns then return false end

    local hasValidPet = false

    for _, pet in ipairs(petSpawns:GetChildren()) do
        if not Finder._running then break end
        
        -- Bỏ qua nếu không phải Model hoặc đã nằm trong sổ đen
        if not pet:IsA("Model") or Finder._ignoredPets[pet] then continue end

        local pName = pet:GetAttribute("PetName")
        
        -- Bộ lọc: Mua tất cả HOẶC Nằm trong danh sách Targets
        if Config.BuyAllPets or (pName and Config.Targets[pName]) then
            local root = pet:FindFirstChild("RootPart")
            if root then
                hasValidPet = true -- Xác nhận Map này VẪN CÒN hàng
                
                -- BƯỚC A: Bay tới
                UI.UpdateStatus("✈️ Đang lướt tới: " .. tostring(pName))
                Teleport.flyTo(root.CFrame * CFrame.new(0, 3, 0), Config.FlySpeed)
                task.wait(0.2)
                
                -- BƯỚC B: Trang bị vũ khí & Quạt tụi KS (Combat)
                Combat.EquipShovel()
                Combat.DefendPet()
                
                -- BƯỚC C: Cướp Pet
                UI.UpdateStatus("⚔️ Đang thu phục: " .. tostring(pName))
                local success = Buy.interact(pet)
                
                if success then
                    UI.AddInventory(pName)
                else
                    -- Lỗi cướp -> Ném vào sổ đen để lần quét sau lơ nó đi
                    print("[Kyzen Hub] Kẹt ở " .. tostring(pName) .. " -> Ném vào sổ đen!")
                    Finder._ignoredPets[pet] = true
                end
            end
        end
    end

    -- Trả về True nếu tìm thấy và xử lý pet, False nếu Map này toàn rác/sổ đen/trống trơn
    return hasValidPet 
end

-- [HÀM KÍCH HOẠT]: Vòng lặp vĩnh cửu
function Finder.Start()
    Finder._running = true
    
    -- Khởi động Giao diện
    UI.Init()
    if Config.BuyAllPets then UI.UpdateTarget("All Pets") else UI.UpdateTarget("VIP Whitelist") end
    pcall(function() UI.UpdateServer(#game:GetService("Players"):GetPlayers(), game.Players.MaxPlayers) end)

    task.spawn(function()
        print("==================================")
        print("🚀 KYZEN FINDER ĐÃ LÊN NÒNG!")
        print("==================================")
        
        while Finder._running do
            -- Gọi hàm quét
            local mapHasPets = Finder.ScanAndProcess()
            
            -- LOGIC VÀNG: Quét xong mà báo False -> Đổi Server ngay lập tức!
            if not mapHasPets and Finder._running then
                UI.UpdateStatus("🔄 Đã vét sạch Map! Đang bốc đầu qua Server mới...")
                print("[Kyzen Hub] Không còn Pet mục tiêu. Kích hoạt Hop Server!")
                Finder._running = false -- Dừng mọi hoạt động ở Server cũ
                task.wait(1)
                Hop.Execute()
                break
            end
            
            -- Nghỉ ngơi nhẹ trước vòng quét tiếp theo để chống crash
            task.wait(1)
        end
    end)
end

-- 4. BẤM NÚT START!
Finder.Start()
