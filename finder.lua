-- File: finder.lua (Phiên Bản Kyzen Script Đã Gắn Link Mạng)
repeat task.wait() until game:IsLoaded()

-- 1. NẠP CÁC MODULE TỪ KHO VŨ KHÍ CỦA KYZEN
local Buy      = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/buy.lua"))()
local Combat   = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/combat.lua"))()
local Hop      = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/hopserver.lua"))()
local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/teleport.lua"))()
local UI       = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/ui.lua"))()

-- 2. BẢNG CÀI ĐẶT (CONFIG)
local Config = {
    MoveMode = "walk",
    StopOnFound = false,
    BuyAllPets = true, 
    Targets = {
        ["IceSerpent"]      = true,
        ["Unicorn"]         = true,
        ["BlackDragon"]     = true,
        ["Firefly"]         = true,
        ["GoldenDragonfly"] = true,
        ["Raccoon"]         = true
    }
}

-- 3. VÒNG LẶP HOẠT ĐỘNG CHÍNH
task.spawn(function()
    -- Bật UI lên màn hình
    UI.Init()
    
    if Config.BuyAllPets then
        UI.UpdateTarget("All Pets")
    else
        UI.UpdateTarget("VIP Whitelist")
    end
    
    -- Cập nhật sĩ số Server
    pcall(function()
        UI.UpdateServer(#game:GetService("Players"):GetPlayers(), game.Players.MaxPlayers)
    end)
    
    local scriptActive = true
    
    while scriptActive do
        local map = workspace:FindFirstChild("Map")
        local petSpawns = map and map:FindFirstChild("WildPetSpawns")
        local foundWantedPet = false
        
        if petSpawns then
            for _, pet in ipairs(petSpawns:GetChildren()) do
                if pet:IsA("Model") then
                    local pName = pet:GetAttribute("PetName")
                    
                    if Config.BuyAllPets or (pName and Config.Targets[pName]) then
                        foundWantedPet = true
                        local root = pet:FindFirstChild("RootPart")
                        
                        if root then
                            -- Chạy bộ tàng hình tới chỗ Pet
                            UI.StatusLbl.Text = "Status: 🏃 Đang rượt " .. pName
                            Teleport.SafeMove(root.CFrame * CFrame.new(0, 3, 0), Config.MoveMode)
                            task.wait(0.2)
                            
                            -- Múa xẻng + Spam cướp Pet
                            UI.StatusLbl.Text = "Status: ⚔️ Đang cướp " .. pName
                            local success = Buy.Interact(pet)
                            
                            if success then
                                -- Nhét vào túi đồ trên UI
                                UI.AddInventory(pName)
                                
                                if Config.StopOnFound then
                                    UI.UpdateStatus("🔴 Đã đạt chỉ tiêu, tắt Script.")
                                    scriptActive = false
                                    break
                                end
                            end
                        end
                    end
                end
                if not scriptActive then break end
            end
        end
        
        if not scriptActive then break end
        
        -- Quét sạch map rồi thì lượn sang map khác
        if not foundWantedPet then
            UI.UpdateStatus("🔄 Đang nhảy Server...")
            task.wait(1)
            Hop.Execute()
            break 
        end
        
        task.wait(1.5)
    end
end)
