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

    -- Thiết lập tốc độ 60 chuẩn mượt
    local oldSpeed = hum.WalkSpeed
    hum.WalkSpeed = speed or 60 

    -- Bật NoClip (Xuyên vật thể) chống kẹt
    local noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    hum:MoveTo(targetPos)

    local reached = false
    local moveConn = hum.MoveToFinished:Connect(function()
        reached = true
    end)

    -- Vòng lặp theo dõi khoảng cách (Timeout 8s)
    local start = os.clock()
    while not reached and (os.clock() - start) < 8 do
        task.wait(0.1)
        hum:MoveTo(targetPos) 
        
        if hrp and (hrp.Position - targetPos).Magnitude < 5 then
            reached = true
        end
    end

    -- Dọn dẹp rác, trả lại trạng thái
    if noclipConn then noclipConn:Disconnect() end
    if moveConn then moveConn:Disconnect() end
    hum.WalkSpeed = oldSpeed
    
    -- Chốt vị trí cuối cùng chuẩn xác
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0,0,0)
    
    return true
end

return Teleport
