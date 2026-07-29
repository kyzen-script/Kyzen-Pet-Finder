-- File: hopserver.lua (Bản bọc giáp chống sập 100%)
local Modules = {}
local Hop = {}
Modules.HopServer = Hop

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

function Hop.Execute()
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    
    -- Gom toàn bộ tên hàm request của các loại Executor vào 1 mẻ
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if not req then 
        warn("❌ Executor của ông không hỗ trợ nhảy Server!")
        return 
    end

    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)
    print("[Kyzen Hub] Đang quét API tìm Server mới...")

    -- 🛡️ Khiên 1: Bọc pcall lúc gọi API (Chống sập do mất mạng/chặn API)
    local success, res = pcall(function()
        return req({ Url = url, Method = "GET" })
    end)

    if success and res and res.Body then
        -- 🛡️ Khiên 2: Bọc pcall lúc Decode (Chống sập do API trả về web rác)
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)
        
        if decodeSuccess and data and data.data then
            for _, server in ipairs(data.data) do
                -- Trừ đi 1-2 slot để đảm bảo lúc đang load qua server chưa bị full
                if server.id ~= CurrentJobId and server.playing < (server.maxPlayers - 1) then
                    print("[Kyzen Hub] Chốt kèo bay sang Server: " .. server.id)
                    
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                    end)
                    
                    task.wait(5) -- Đợi 5 giây cho game nó đá sang server kia
                    return -- Nhảy thành công thì ngắt hàm
                end
            end
        end
    end
    
    -- Nếu API lỗi hoặc không tìm được server, nhắm mắt nhảy đại bừa 1 server khác
    print("[Kyzen Hub] API lỗi hoặc hết server, kích hoạt Blind Hop...")
    pcall(function()
        TeleportService:Teleport(PlaceId, Players.LocalPlayer)
    end)
end

return Hop
