-- File: PetFinder/teleport.lua
local Teleport = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

function Teleport.SafeMove(targetCFrame, mode)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    if mode == "walk" then
        -- 1. Lưu lại tốc độ cũ để trả về sau khi chạy xong
        local originalWalkSpeed = humanoid.WalkSpeed
        
        -- 2. Bơm tốc độ chạy siêu tốc (150-200 là vừa đẹp, cao quá dễ văng)
        humanoid.WalkSpeed = 150 
        
        -- 3. Bật NoClip (Xuyên vật thể) để không bị kẹt hàng rào/cây cối trên đường đi
        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

        -- 4. Ép nhân vật chạy bộ đến vị trí con Pet
        humanoid:MoveTo(targetCFrame.Position)
        
        -- 5. Đợi nhân vật chạy đến nơi (có timeout 3 giây để chống kẹt vĩnh viễn)
        local reached = false
        local connection
        connection = humanoid.MoveToFinished:Connect(function()
            reached = true
        end)

        local startTime = os.clock()
        while not reached and (os.clock() - startTime) < 3 do
            task.wait(0.1)
        end

        -- 6. Dọn dẹp: Tắt NoClip, trả lại tốc độ cũ và ngắt kết nối
        if connection then connection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        humanoid.WalkSpeed = originalWalkSpeed
        
        -- Đảm bảo đứng đúng vị trí cuối cùng
        hrp.CFrame = targetCFrame
        hrp.Velocity = Vector3.new(0, 0, 0)
        
    elseif mode == "spam" then
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local steps = math.ceil(dist / 40) 
        
        for i = 1, steps do
            if not hrp or not hrp.Parent then break end
            hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, i / steps)
            hrp.Velocity = Vector3.new(0,0,0)
            task.wait(0.02)
        end
        hrp.CFrame = targetCFrame
    else
        -- Dịch chuyển cái vèo (mặc định)
        hrp.CFrame = targetCFrame
    end
end

return Teleport

