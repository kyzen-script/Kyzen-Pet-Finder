-- =======================================================
-- 🚀 KYZEN PET FINDER PREMIUM (SMART SCAN CORE)
-- =======================================================
repeat task.wait() until game:IsLoaded()

local Repo = "https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/"
local Buy      = loadstring(game:HttpGet(Repo .. "buy.lua"))()
local Combat   = loadstring(game:HttpGet(Repo .. "combat.lua"))()
local Hop      = loadstring(game:HttpGet(Repo .. "hopserver.lua"))()
local Teleport = loadstring(game:HttpGet(Repo .. "teleport.lua"))()
local UI       = loadstring(game:HttpGet(Repo .. "ui.lua"))()

local Config = {
    BuyAllPets = true, 
    FlySpeed = 150,    
    Targets = {        
        ["IceSerpent"]      = true,
        ["Unicorn"]         = true,
        ["BlackDragon"]     = true,
        ["Firefly"]         = true,
        ["GoldenDragonfly"] = true,
        ["Raccoon"]         = true
    }
}

local Finder = {
    _running = false,
    _failedAttempts = {} -- Sổ đếm lỗi: Cho cơ hội thử lại 3 lần
}

function Finder.ScanAndProcess()
    local map = workspace:FindFirstChild("Map")
    local petSpawns = map and map:FindFirstChild("WildPetSpawns")
    
    if not petSpawns then return false end

    local hasValidPet = false

    for _, pet in ipairs(petSpawns:GetChildren()) do
        if not Finder._running then break end
        
        local failCount = Finder._failedAttempts[pet] or 0
        
        -- Nếu không phải Pet hoặc đã cướp hụt QUÁ 3 LẦN thì mới bỏ qua
        if not pet:IsA("Model") or failCount >= 3 then continue end

        local pName = pet:GetAttribute("PetName")
        
        if Config.BuyAllPets or (pName and Config.Targets[pName]) then
            local root = pet:FindFirstChild("RootPart")
            if root then
                hasValidPet = true -- Vẫn còn mục tiêu để làm việc
                
                -- BAY TỚI
                UI.UpdateStatus("✈️ Đang lướt tới: " .. tostring(pName))
                Teleport.flyTo(root.CFrame * CFrame.new(0, 3, 0), Config.FlySpeed)
                task.wait(0.5) -- Đợi nhân vật chạm đất đứng vững
                
                -- ĐÁNH KS
                Combat.EquipShovel()
                Combat.DefendPet()
                
                -- CƯỚP
                UI.UpdateStatus("⚔️ Đang thu phục: " .. tostring(pName))
                local success = Buy.interact(pet)
                
                if success then
                    UI.AddInventory(pName)
                    -- ĐIỂM SÁNG: ĐỨNG CHỜ SERVER TRẢ PET VỀ VƯỜN
                    UI.UpdateStatus("⏳ Thành công! Đang đợi Pet về vườn (4s)...")
                    task.wait(4)
                else
                    -- Cướp hụt thì cộng điểm tội lỗi, chưa blacklist ngay
                    Finder._failedAttempts[pet] = failCount + 1
                    UI.UpdateStatus("⚠️ Kẹt mạng! Sẽ thử lại vòng sau...")
                    print("[Kyzen Hub] Cướp hụt " .. tostring(pName) .. " lần " .. (failCount + 1))
                    task.wait(1)
                end
            end
        end
    end

    return hasValidPet 
end

function Finder.Start()
    Finder._running = true
    
    UI.Init()
    if Config.BuyAllPets then UI.UpdateTarget("All Pets") else UI.UpdateTarget("VIP Whitelist") end
    pcall(function() UI.UpdateServer(#game:GetService("Players"):GetPlayers(), game.Players.MaxPlayers) end)

    task.spawn(function()
        print("==================================")
        print("🚀 KYZEN FINDER (SMART) ĐÃ LÊN NÒNG!")
        print("==================================")
        
        while Finder._running do
            local mapHasPets = Finder.ScanAndProcess()
            
            -- HẾT PET HOẶC TOÀN PET BỊ LỖI
            if not mapHasPets and Finder._running then
                -- BƯỚC CHỐT SỔ AN TOÀN TRƯỚC KHI BAY
                UI.UpdateStatus("⏳ Hết Pet! Đứng chờ 6s chốt sổ trước khi nhảy...")
                task.wait(6) 
                
                UI.UpdateStatus("🔄 Đã vét sạch sành sanh! Nhảy Server...")
                Finder._running = false
                task.wait(1)
                Hop.Execute()
                break
            end
            
            task.wait(1.5)
        end
    end)
end

Finder.Start()
