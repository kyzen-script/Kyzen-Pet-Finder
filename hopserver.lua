-- File: hopserver.lua (Vòng Lặp Nhảy Vĩnh Cửu)
local Hop = {}
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

function Hop.Execute()
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if not req then return end

    print("[Kyzen Hub] Bắt đầu tìm Server mới...")
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

    -- Tạo vòng lặp nhảy (Nếu kẹt nó tự nhảy lại)
    while true do
        local success, res = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)

        if success and res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            
            for _, server in ipairs(data.data) do
                if server.id ~= CurrentJobId and server.playing < (server.maxPlayers - 1) then
                    print("[Kyzen Hub] Bay qua: " .. tostring(server.id))
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                    end)
                    task.wait(3) -- Đợi 3 giây xem có bay được không
                end
            end
        end
        -- Nếu chạy hết list mà chưa bay được -> Blind Hop (Nhảy mù)
        pcall(function()
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        end)
        task.wait(5) -- Đợi 5 giây rồi quét tiếp nếu vẫn chưa văng sang server mới
    end
end

return Hop
