------Main
-- =======================================================
-- 🚀 KYZEN PET FINDER PREMIUM PRO MAX (SMART TARGETING)
-- =======================================================
repeat task.wait() until game:IsLoaded()

-- 🛡️ SKILL 0: AUTO CLICK XUYÊN LOADING SCREEN
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    task.wait(3) 
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    for i = 1, 5 do
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        task.wait(1)
    end
end)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Gardens = workspace:FindFirstChild("Gardens")
local count = 0

if Gardens then
    for _, garden in ipairs(Gardens:GetChildren()) do
        -- Xoá toàn bộ các khu vườn có trong Map
        -- (Chỉ có tác dụng dọn dẹp hiển thị trên máy của ông)
        garden:Destroy()
        count = count + 1
    end
    
    -- In ra F9 (Console) để báo cáo thành tích
    print("💥 BÙM! Đã xoá sổ thành công " .. count .. " khu vườn khỏi bản đồ!")
    
    -- Tạo một cái thông báo nhỏ góc màn hình cho ngầu
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Phá Hoại Thành Công",
        Text = "Đã dọn dẹp sạch sẽ " .. count .. " khu vườn!",
        Duration = 3
    })
else
    warn("❌ Không tìm thấy khu vườn nào trên Map!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Lỗi Xoá Vườn",
        Text = "Không tìm thấy thư mục Gardens!",
        Duration = 3
    })
end
-- 🛡️ SKILL 1: ANTI-AFK (CHỐNG KICK 20 PHÚT)
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- 📦 NẠP MODULES
local Repo = "https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/"
local function LoadModule(fileName)
    local code = game:HttpGet(Repo .. fileName)
    local func, err = loadstring(code)
    if not func then warn("❌ LỖI FILE: " .. fileName) return nil end
    return func()
end

local Buy      = LoadModule("buy.lua")
local Combat   = LoadModule("combat.lua")
local Hop      = LoadModule("hopserver.lua")
local Teleport = LoadModule("teleport.lua")
local UI       = LoadModule("ui.lua")

local Config = { WalkSpeed = 45 }
local Finder = { _running = false }
local Players = game:GetService("Players")

-- 📊 HÀM TÌM ĐỘ HIẾM TỪ TÊN
local function GetPetScore(petName)
    if string.match(petName, "Dragon") or string.match(petName, "Serpent") then return 6 end
    if string.match(petName, "Unicorn") then return 5 end
    return math.random(1, 3) 
end

-- 📡 RADAR: QUÉT XEM CÓ THẰNG NÀO LẠI GẦN KHÔNG (Phạm vi 30 mét)
local function IsPlayerNear(pos, range)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - pos).Magnitude
            if dist <= range then return true end
        end
    end
    return false
end

-- 🧠 TRÍ TUỆ NHÂN TẠO: QUÉT & CHỌN MỤC TIÊU
function Finder.ScanAndProcess()
    local map = workspace:FindFirstChild("Map")
    local petSpawns = map and map:FindFirstChild("WildPetSpawns")
    
    if not petSpawns then return false end
    local pets = petSpawns:GetChildren()
    if #pets == 0 then return false end -- Hết Pet -> Hop
    
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end -- Đợi nhân vật load xong

    -- BƯỚC 1 & 2: QUÉT TOÀN MAP -> TẠO DANH SÁCH
    local targetList = {}
    for _, pet in ipairs(pets) do
        if pet:IsA("Model") and pet:FindFirstChild("RootPart") then
            local pName = pet:GetAttribute("PetName") or "Ẩn Danh"
            local root = pet.RootPart
            local score = GetPetScore(pName)
            local dist = (root.Position - hrp.Position).Magnitude
            
            table.insert(targetList, {
                Model = pet,
                Name = pName,
                Root = root,
                Score = score,
                Distance = dist
            })
        end
    end

    if #targetList == 0 then return false end

    -- BƯỚC 3 & 4: SẮP XẾP TỐI ƯU (Độ hiếm ưu tiên 1 -> Khoảng cách ưu tiên 2)
    table.sort(targetList, function(a, b)
        if a.Score == b.Score then
            return a.Distance < b.Distance -- Cùng độ hiếm -> Chọn con gần hơn
        end
        return a.Score > b.Score -- Chọn độ hiếm cao hơn
    end)

    -- BƯỚC 5: CHỐT ĐƠN CON VIP NHẤT VÀ LAO VÀO
    local bestTarget = targetList[1]
    local pet = bestTarget.Model
    local pName = bestTarget.Name
    local root = bestTarget.Root

    UI.UpdateStatus("🏃 Đang lướt tới cướp: " .. pName)
    Teleport.walkTo(root.Position, Config.WalkSpeed)
    
    -- BƯỚC 6: RADAR CẢNH BÁO KS -> KÍCH HOẠT COMBAT
    if IsPlayerNear(root.Position, 30) then
        UI.UpdateStatus("⚔️ Cảnh báo KS! Đang vung xẻng...")
        Combat.EquipShovel()
        Combat.DefendPet()
    end

    -- BƯỚC 7: MUA PET (CƯỚP)
    UI.UpdateStatus("💰 Đang thu phục: " .. pName)
    local success = Buy.interact(pet)
    
    if success then
        UI.AddInventory(pName)
        
        -- BƯỚC 8: BẢO VỆ 3 GIÂY CHỜ HÀNG VỀ (Đứng lên đầu nó)
        UI.UpdateStatus("🛡️ Bảo kê 3s chờ hàng về...")
        Teleport.walkTo(root.Position + Vector3.new(0, 3, 0), Config.WalkSpeed)
        
        local timeout = 0
        while pet.Parent and timeout < 30 do -- Chờ tối đa 3 giây
            -- Vừa chờ vừa soi Radar, thằng nào ló mặt ra là quạt xẻng
            if IsPlayerNear(root.Position, 30) then
                Combat.EquipShovel()
                Combat.DefendPet()
            end
            task.wait(0.1)
            timeout = timeout + 1
        end
        UI.UpdateStatus("✅ Đã đút túi thành công!")
    end

    -- BƯỚC 9: TRẢ VỀ TRUE ĐỂ QUÉT LẠI NGAY LẬP TỨC
    return true 
end

function Finder.Start()
    Finder._running = true
    UI.Init()
    UI.UpdateTarget("Smart Priority Targeting")
    pcall(function() UI.UpdateServer(#Players:GetPlayers(), Players.MaxPlayers) end)

    task.spawn(function()
        print("==================================")
        print("🚀 KYZEN FINDER (AI SMART TARGET) ACTIVE!")
        print("==================================")
        
        while Finder._running do
            local hasPets = Finder.ScanAndProcess()
            
            -- BƯỚC 10: HẾT PET -> HOP
            if not hasPets and Finder._running then
                UI.UpdateStatus("🔄 Map đã sạch bóng! Đang nhảy Server...")
                task.wait(1)
                Hop.Execute()
                break
            end
            
            task.wait(0.2) -- Loop lại tức thì để quét mục tiêu tiếp theo
        end
    end)
end

Finder.Start()
