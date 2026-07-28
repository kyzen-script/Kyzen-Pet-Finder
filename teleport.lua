-- File: teleport.lua (Chạy Bộ Xuyên Tường)
local Modules = {}
Modules.Teleport = {}

local Teleport = Modules.Teleport
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function Teleport.walkTo(targetPos, speed)
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return false end

    -- Bơm tốc độ chạy
    local oldSpeed = hum.WalkSpeed
    hum.WalkSpeed = speed or 120 

    -- Bật NoClip để không kẹt vô gốc cây, hàng rào
    local noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    -- Ép chạy bằng AI của game
    hum:MoveTo(targetPos)

    local reached = false
    local moveConn = hum.MoveToFinished:Connect(function()
        reached = true
    end)

    -- Vòng lặp kiểm tra khoảng cách (Timeout 8s chống kẹt)
    local start = os.clock()
    while not reached and (os.clock() - start) < 8 do
        task.wait(0.1)
        hum:MoveTo(targetPos) -- Ép chạy liên tục
        
        -- Nếu cách Pet 5 mét -> Đến nơi
        if hrp and (hrp.Position - targetPos).Magnitude < 5 then
            reached = true
        end
    end

    -- Dọn dẹp trả lại trạng thái cũ
    if noclipConn then noclipConn:Disconnect() end
    if moveConn then moveConn:Disconnect() end
    hum.WalkSpeed = oldSpeed
    
    -- Teleport nhẹ 1 nhịp cuối cùng cho chuẩn xác vị trí
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0,0,0)
    
    return true
end

return Teleport
print("lên rồi")
----- Update 
