-- File: teleport.lua (Bypass Anti-Cheat / Fake Walk)
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

    -- Bật NoClip để lướt xuyên cây cối, bờ rào không bị kẹt
    local noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    -- Tính toán quãng đường và thời gian bay (Tốc độ 45 là chống giật lùi tốt nhất)
    local safeSpeed = speed or 45
    local dist = (hrp.Position - targetPos).Magnitude
    local duration = dist / safeSpeed

    local startCFrame = hrp.CFrame
    local targetCFrame = CFrame.new(targetPos)
    local startTime = os.clock()

    -- Bơm lệnh MoveTo để game tự động chạy Animation nhún nhảy đôi chân
    hum:MoveTo(targetPos)

    -- Vòng lặp nhích CFrame liên tục (Bypass máy chủ)
    while (os.clock() - startTime) < duration do
        local alpha = (os.clock() - startTime) / duration
        hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        hrp.Velocity = Vector3.new(0, 0, 0) -- Đóng băng trọng lực để không bị rớt
        task.wait()
    end

    -- Dọn dẹp rác bộ nhớ
    if noclipConn then noclipConn:Disconnect() end

    -- Ép sát vị trí cuối cùng
    hrp.CFrame = targetCFrame
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    return true
end

return Teleport
