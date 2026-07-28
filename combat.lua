-- File: PetFinder/combat.lua
local Combat = {}
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- Móc vào hệ thống Mạng của game để lấy lệnh HitPlayer
local NetworkModule
pcall(function()
    local SharedModules = RS:WaitForChild("SharedModules", 5)
    NetworkModule = require(SharedModules:WaitForChild("Networking"))
end)

-- Hàm tự động lôi xẻng ra cầm
function Combat.EquipShovel()
    local char = LP.Character
    local backpack = LP:FindFirstChild("Backpack")
    if not char or not backpack then return false end
    
    -- Kiểm tra xem đang cầm sẵn xẻng chưa
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool:GetAttribute("Shovel") or currentTool.Name:lower():match("shovel")) then
        return true
    end

    -- Nếu chưa cầm, lục trong balo lấy ra
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:GetAttribute("Shovel") or tool.Name:lower():match("shovel") then
            tool.Parent = char
            return true
        end
    end
    return false
end

-- Hàm quét và đánh người xung quanh (Bypass Anti-Cheat khoảng cách & góc nhìn)
function Combat.DefendPet()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not NetworkModule or not NetworkModule.Shovel then return end

    -- Quét tất cả người chơi trong Server
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LP and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local dist = (targetRoot.Position - root.Position).Magnitude
            
            -- Dev note: Server requires dist <= 12
            if dist <= 11 then
                -- Fake góc nhìn: Ép nhân vật của mình quay mặt về phía mục tiêu cực nhanh để đạt chuẩn dot >= 0.3
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                
                -- Bắn lệnh sát thương lên Server
                NetworkModule.Shovel.HitPlayer:Fire(target.UserId)
                print("💥 [Combat] Bẻ cổ thằng KS: " .. target.Name)
            end
        end
    end
end

return Combat
