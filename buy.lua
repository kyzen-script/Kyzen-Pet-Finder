-- File: buy.lua (GAG Hub Optimized)
local Modules = {}
Modules.AutoBuyPet = {}

local Buy = Modules.AutoBuyPet
local Players = game:GetService("Players")

-- Bộ đếm thống kê giống hệt GAG Hub
Buy._stats = { bought = 0, errors = 0, scanned = 0 }
Buy._running = false

-- Hàm tương tác siêu an toàn (Sử dụng pcall)
function Buy.interact(petModel)
    local root = petModel:FindFirstChild("RootPart")
    if not root then 
        Buy._stats.errors += 1
        return false 
    end
    
    local prompt = root:FindFirstChild("BuyPrompt") or root:FindFirstChildOfClass("ProximityPrompt")
    if not prompt or not prompt.Enabled then 
        Buy._stats.errors += 1
        return false 
    end
    
    local pName = petModel:GetAttribute("PetName") or "Unknown"
    local successAction = false
    
    -- Vòng lặp Spam mua an toàn (Timeout 2 giây)
    local attempts = 0
    while petModel.Parent and prompt.Enabled and attempts < 20 do
        local ok, err = pcall(function()
            fireproximityprompt(prompt)
        end)
        
        if not ok then
            warn("[Kyzen Hub] Lỗi bấm nút mua:", err)
        end
        
        attempts += 1
        task.wait(0.1)
    end
    
    -- Kiểm tra kết quả (Nếu con Pet biến mất khỏi map hoặc Prompt tắt -> Đã mua)
    if not petModel.Parent or not prompt.Enabled then
        Buy._stats.bought += 1
        print("[Kyzen Hub] Mua thành công:", pName)
        successAction = true
    else
        Buy._stats.errors += 1
        print("[Kyzen Hub] Mua thất bại (Kẹt mạng):", pName)
    end
    
    return successAction
end

-- Trả về bảng thống kê để UI lấy dữ liệu
function Buy.getStats()
    return Buy._stats
end

return Buy
