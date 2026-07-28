-- File: buy.lua (Bản chốt hạ độ trễ)
local Modules = {}
Modules.AutoBuyPet = {}

local Buy = Modules.AutoBuyPet
local Players = game:GetService("Players")

Buy._stats = { bought = 0, errors = 0, scanned = 0 }
Buy._running = false

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
    
    -- Tăng số lần thử lên 35 (Tương đương 3.5 giây chờ)
    local attempts = 0
    while petModel.Parent and prompt.Enabled and attempts < 35 do
        local ok, err = pcall(function()
            fireproximityprompt(prompt)
        end)
        attempts += 1
        task.wait(0.1)
    end
    
    if not petModel.Parent or not prompt.Enabled then
        Buy._stats.bought += 1
        successAction = true
    else
        Buy._stats.errors += 1
    end
    
    return successAction
end

function Buy.getStats()
    return Buy._stats
end

return Buy
