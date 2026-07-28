-- File: teleport.lua (GAG Hub Optimized)
local Modules = {}
Modules.Teleport = {}

local Teleport = Modules.Teleport
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

Teleport._running = false
Teleport._connections = {}

function Teleport.flyTo(targetCFrame, speed)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Tính toán thời gian bay để không bị Anti-Cheat văng (Tốc độ chuẩn: 150-200 studs/s)
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToTravel = dist / (speed or 150)
    
    -- Tránh lỗi bay quá nhanh nếu ở quá gần
    if timeToTravel < 0.1 then timeToTravel = 0.1 end

    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})

    -- Bật NoClip (Tàng hình vật lý) trong lúc bay
    local noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            -- Đóng băng gia tốc để không bị rớt do trọng lực
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)

    -- Thực thi chuyến bay
    tween:Play()
    
    -- Đợi bay tới nơi hoặc bị hủy
    local completed = false
    local finishConn
    finishConn = tween.Completed:Connect(function()
        completed = true
    end)

    -- Timeout an toàn (Chống kẹt vòng lặp)
    local start = os.clock()
    while not completed and (os.clock() - start) < (timeToTravel + 1) do
        task.wait(0.05)
    end

    -- Dọn dẹp rác (Garbage Collection)
    if noclipConn then noclipConn:Disconnect() end
    if finishConn then finishConn:Disconnect() end
    if tween.PlaybackState ~= Enum.PlaybackState.Completed then
        tween:Cancel()
    end
    
    -- Chốt lại vị trí cuối
    hrp.CFrame = targetCFrame
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    return true
end

return Teleport
