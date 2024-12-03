Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60 * 1000)

        local playerPed = PlayerPedId()
        if (not IsEntityDead(playerPed)) or (not GetEntityHealth(playerPed) <= 0)  then
            local coords = GetEntityCoords(playerPed)
            local x, y, z = table.unpack(coords)
        end
    end
end)