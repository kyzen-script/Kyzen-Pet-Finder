-- File: buy.lua (Đã fix lỗi gọi file nội bộ)
local Buy = {}

-- SỬA Ở ĐÂY: Gọi module Combat từ GitHub thay vì bộ nhớ máy!
local Combat = loadstring(game:HttpGet("https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/combat.lua"))()

function Buy.Interact(petModel)
    local root = petModel:FindFirstChild("RootPart")
    if not root then return false end
    
    local prompt = root:FindFirstChild("BuyPrompt") or root:FindFirstChildOfClass("ProximityPrompt")
    if not prompt or not prompt.Enabled then return false end
    
    local pName = petModel:GetAttribute("PetName") or "Ẩn Danh"
    print("[Buy] Đang chiếm đóng: " .. pName .. " | Kích hoạt Vòng Tròn Tử Thần!")
    
    -- Tự động cầm xẻng lên trước khi húp Pet
    Combat.EquipShovel()
    
    local attempts = 0
    -- Trong lúc chờ mua (Timeout 1.5s), vừa spam E vừa vung xẻng
    while petModel.Parent and prompt.Enabled and attempts < 15 do
        -- Đánh tụi KS
        Combat.DefendPet()
        
        -- Spam mua
        fireproximityprompt(prompt)
        
        attempts = attempts + 1
        task.wait(0.1)
    end
    
    if not petModel.Parent or not prompt.Enabled then
        print("[Buy] ✅ Bỏ túi thành công: " .. pName)
        return true
    end
    
    return false
end

return Buy
