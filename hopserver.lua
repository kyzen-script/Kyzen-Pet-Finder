-- File: PetFinder/hopserver.lua
local Hop = {}
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

function Hop.Execute()
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if not req then 
        warn("[HopServer] Executor không hỗ trợ HTTP request!")
        return 
    end

    print("[HopServer] Hết hàng! Đang tìm Server mới...")
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

    task.spawn(function()
        local success, res = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)

        if success and res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            
            for _, server in ipairs(data.data) do
                -- Trừ hao 1 slot để tránh server vừa full
                if server.id ~= CurrentJobId and server.playing < (server.maxPlayers - 1) then
                    print("[HopServer] Bay tới: " .. tostring(server.id) .. " (" .. server.playing .. "/" .. server.maxPlayers .. ")")
                    
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                    end)
                    break
                end
            end
        else
            print("[HopServer] Lỗi API, tự động Rejoin!")
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        end
    end)
end

return Hop
