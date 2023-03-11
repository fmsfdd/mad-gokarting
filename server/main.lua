local QBCore = exports['qb-core']:GetCoreObject()



RegisterServerEvent('mad-gokarting:server:attemptbuy')
AddEventHandler('mad-gokarting:server:attemptbuy', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local cash = Player.PlayerData.money.cash

    if cash >= Config.price then
        TriggerClientEvent('mad-gokarting:client:spawnkart', source)
		
    else
        TriggerClientEvent('QBCore:Notify', src, "Não tens dinheiro suficiente", "error")
    end
end)

RegisterServerEvent('mad-gokarting:server:purchase')
AddEventHandler('mad-gokarting:server:purchase', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney("cash", Config.price)
    
end)

