-- =======================================================
-- 🚀 KYZEN PET FINDER PREMIUM (WHITELIST & DISTANCE FOCUS)
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
        garden:Destroy()
        count = count + 1
    end
    print("💥 BÙM! Đã xoá sổ thành công " .. count .. " khu vườn khỏi bản đồ!")
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

-- 📦 NẠP MODULES (ĐÃ BỎ COMBAT)
local Repo = "https://raw.githubusercontent.com/kyzen-script/Kyzen-Pet-Finder/refs/heads/main/"
local function LoadModule(fileName)
    local code = game:HttpGet(Repo .. fileName)
    local func, err = loadstring(code)
    if not func then warn("❌ LỖI FILE: " .. fileName) return nil end
    return func()
end

local Buy      = LoadModule("buy.lua")
local Hop      = LoadModule("hopserver.lua")
local Teleport = LoadModule("teleport.lua")
local UI       = LoadModule("ui.lua")

local Config = { WalkSpeed = 20 }
local Finder = { _running = false }

-- 📋 DANH SÁCH WHITELIST PET CẦN BẮT
local WantedPets = {
    ["Raccoon"] = true,
    ["Monkey"] = true,
    ["Butterfly"] = true,
    ["Unicorn"] = true,
    ["Dragonfly"] = true,
    ["Turtle"] = true,
}

-- 🧠 TRÍ TUỆ NHÂN TẠO: QUÉT & CHỌN MỤC TIÊU (ƯU TIÊN KHOẢNG CÁCH)
function Finder.ScanAndProcess()
    local map = workspace:FindFirstChild("Map")
    local petSpawns = map and map:FindFirstChild("WildPetSpawns")
    
    if not petSpawns then return false end
    local pets = petSpawns:GetChildren()
    if #pets == 0 then return false end -- Hết Pet -> Hop
    
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end -- Đợi nhân vật load xong

    -- BƯỚC 1: QUÉT TOÀN MAP -> LỌC THEO WHITELIST
    local targetList = {}
    for _, pet in ipairs(pets) do
        if pet:IsA("Model") and pet:FindFirstChild("RootPart") then
            local pName = pet:GetAttribute("PetName") or "Ẩn Danh"
            
            -- Chỉ húp những con có tên trong Whitelist
            if WantedPets[pName] then
                local root = pet.RootPart
                local dist = (root.Position - hrp.Position).Magnitude
                
                table.insert(targetList, {
                    Model = pet,
                    Name = pName,
                    Root = root,
                    Distance = dist
                })
            end
        end
    end

    if #targetList == 0 then return false end

    -- BƯỚC 2: SẮP XẾP TỐI ƯU (Gần nhất húp trước)
    table.sort(targetList, function(a, b)
        return a.Distance < b.Distance 
    end)

    -- BƯỚC 3: CHỐT ĐƠN CON GẦN NHẤT VÀ LAO VÀO
    local bestTarget = targetList[1]
    local pet = bestTarget.Model
    local pName = bestTarget.Name
    local root = bestTarget.Root

    UI.UpdateStatus("🏃 Đang lướt tới: " .. pName)
    Teleport.walkTo(root.Position, Config.WalkSpeed)

    -- BƯỚC 4: MUA PET VÀ BÁM THEO NHƯ ĐỈA ĐÓI CHỜ HÀNG VỀ
    local success = Buy.interact(pet)
    
    if success then
        UI.AddInventory(pName)
        UI.UpdateStatus("🎯 Đang bám đuôi " .. pName .. " chờ nhặt...")
        
        while pet.Parent do
            pcall(function()
                Teleport.follow(pet)
                Buy.interact(pet)
            end)
            task.wait(0.05)
        end
        UI.UpdateStatus("✅ Đã đút túi thành công!")
    end

    -- TRẢ VỀ TRUE ĐỂ QUÉT LẠI NGAY LẬP TỨC
    return true 
end

function Finder.Start()
    Finder._running = true
    UI.Init()
    UI.UpdateTarget("Whitelist & Distance Targeting")
    pcall(function() UI.UpdateServer(#Players:GetPlayers(), Players.MaxPlayers) end)

    task.spawn(function()
        print("==================================")
        print("🚀 KYZEN FINDER (WHITELIST MODE) ACTIVE!")
        print("==================================")
        
        while Finder._running do
            local hasPets = Finder.ScanAndProcess()
            
            -- HẾT PET TRONG DANH SÁCH -> TỰ ĐỘNG HOP (CÓ DELAY 5 GIÂY)
            if not hasPets and Finder._running then
                -- Đếm ngược 5 giây, có check an toàn lỡ ông tắt tool giữa chừng
                for i = 5, 1, -1 do
                    if not Finder._running then break end 
                    UI.UpdateStatus("🔄 Vét sạch map! Nhảy Server sau " .. i .. " giây...")
                    task.wait(1)
                end
                
                -- Đếm xong thì bay
                if Finder._running then
                    UI.UpdateStatus("🚀 Tiến hành bay sang Server mới!!!")
                    task.wait(0.5)
                    Hop.Execute()
                end
                break
            end
            
            task.wait(0.2) -- Loop lại tức thì để quét mục tiêu tiếp theo
        end
    end)
end

Finder.Start()
