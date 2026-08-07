--=========================================
-- KYZEN PET FINDER V2
-- Tween Movement
--=========================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer

local noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

local Teleport = {}

Teleport.Speed = 55
Teleport.Height = 2.5

local currentTween

local function GetHRP()
    local char = LP.Character
    if not char then
        return nil
    end

    return char:FindFirstChild("HumanoidRootPart")
end

function Teleport.Stop()

    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end

end

function Teleport.walkTo(position,speed)

    speed = speed or Teleport.Speed

    local hrp = GetHRP()

    if not hrp then
        return false
    end

    Teleport.Stop()

    local targetPos = Vector3.new(
        position.X,
        position.Y + Teleport.Height,
        position.Z
    )

    local distance = (targetPos - hrp.Position).Magnitude

    if distance <= 2 then
        return true
    end

    local travelTime = distance / speed

    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(
            travelTime,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = CFrame.new(targetPos)
        }
    )

    currentTween:Play()

    currentTween.Completed:Wait()

    currentTween = nil

    return true

end

function Teleport.follow(model)

    local root = model and model:FindFirstChild("RootPart")

    if not root then
        return
    end

    while model.Parent do

        Teleport.walkTo(root.Position)

        task.wait(0.05)

    end

end

return Teleport
