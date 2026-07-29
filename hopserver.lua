-- =======================================================
-- 🚀 KYZEN HOP SERVER PREMIUM (CHỐNG LỖI 277, 279)
-- =======================================================
local Modules = {}
local Hop = {}
Modules.HopServer = Hop

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

-- Kho đạn dự trữ Server
local ServerCache = {}
local HopAttempt = 0
local isHopping = false

-- Lấy quyền Request của Executor
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 📡 BƯỚC 1: QUÉT RADAR VÀ LỌC SERVER VIP
function Hop.FetchServers()
    if not req then return false end
    
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)
    local success, res = pcall(function() return req({ Url = url, Method = "GET" }) end)
    
    if success and res and res.Body then
        local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        
        if decodeSuccess and data and data.data then
            ServerCache = {} -- Dọn kho cũ
            for _, server in ipairs(data.data) do
                -- 🛡️ KHIÊN 1: CHỐNG LỖI 279 (Chỉ lấy Server trống từ 3 slot trở lên)
                if server.id ~= CurrentJobId and server.playing < (server.maxPlayers - 2) then
                    table.insert(ServerCache, server.id)
                end
            end
            
            -- Xáo trộn danh sách để không nhảy trùng với người khác xài chung Script
            for i = #ServerCache, 2, -1 do
                local j = math.random(i)
                ServerCache[i], ServerCache[j] = ServerCache[j], ServerCache[i]
            end
            
            return #ServerCache > 0
        end
    end
    return false
end

-- 🚀 BƯỚC 2: TIẾN HÀNH BƯỚC NHẢY KHÔNG GIAN
function Hop.Jump()
    HopAttempt = HopAttempt + 1
    local currentAttempt = HopAttempt

    -- 🛡️ KHIÊN 4: GỌI API THÔNG MINH (Hết đạn mới gọi thêm)
    if #ServerCache == 0 then
        print("[Kyzen Premium] Kho Server cạn. Đang quét Radar lô mới...")
        local gotData = Hop.FetchServers()
        if not gotData then
            warn("[Kyzen Premium] API kẹt! Đợi 5s rồi nhắm mắt nhảy bừa (Blind Hop)...")
            task.wait(5)
            pcall(function() TeleportService:Teleport(PlaceId, Players.LocalPlayer) end)
            return
        end
    end

    -- Rút 1 Server xịn nhất trong kho ra để bay
    local targetServer = table.remove(ServerCache, 1)
    print("[Kyzen Premium] 🛫 Chốt đơn hạ cánh Server ID: " .. tostring(targetServer))
    
    pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, Players.LocalPlayer)
    end)

    -- 🛡️ KHIÊN 3: TIMEOUT TỰ CỨU (Chống kẹt màn hình đen vĩnh viễn)
    task.spawn(function()
        task.wait(12) -- Đợi 12 giây
        -- Nếu kịch bản vẫn còn chạy sau 12 giây -> Nhảy xịt
        if isHopping and HopAttempt == currentAttempt then
            warn("[Kyzen Premium] ⏳ Quá 12s không qua được cổng! Ép nhảy Server dự phòng...")
            Hop.Jump()
        end
    end)
end

-- ⚙️ HÀM KÍCH HOẠT CHÍNH
function Hop.Execute()
    if isHopping then return end
    isHopping = true
    
    print("==================================")
    print("🔄 KÍCH HOẠT HỆ THỐNG HOP PREMIUM")
    print("==================================")

    -- 🛡️ KHIÊN 2: ĐÁNH CHẶN THÔNG BÁO LỖI 277/279 CỦA ROBLOX
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == Players.LocalPlayer then
            warn("[Kyzen Premium] 🛑 Server kia sập cửa rồi (Lỗi: " .. tostring(teleportResult.Name) .. "). Đang bẻ lái lập tức!")
            Hop.Jump() -- Quay xe nhảy server khác ngay và luôn!
        end
    end)

    -- Kích hoạt phát bắn đầu tiên
    Hop.Jump()
end

return Hop
