local QBCore = exports['qb-core']:GetCoreObject()

local started = false


CreateThread(function()
    
    RequestModel(`a_m_m_soucent_03`)
    while not HasModelLoaded(`a_m_m_soucent_03`) do
    Wait(1)
  end
    gokart = CreatePed(2, `a_m_m_soucent_03`, Config.StartPedLoc.x, Config.StartPedLoc.y, Config.StartPedLoc.z-1, Config.StartPedLoc.w, false, false) -- change here the cords for the ped 
    SetPedFleeAttributes(gokart, 0, 0)
    SetPedDiesWhenInjured(gokart, false)
    TaskStartScenarioInPlace(gokart, Config.StartPedAnimation, 0, true)
    SetPedKeepTask(gokart, true)
    SetBlockingOfNonTemporaryEvents(gokart, true)
    SetEntityInvincible(gokart, true)
    FreezeEntityPosition(gokart, true)

    Wait(100)

    exports['qb-target']:AddEntityZone("gokartped", gokart, {
		name = "gokartped",
		heading= 90.5,
		debugPoly=false,
	}, {
		options = {
			{
				action = function()
					if not started then
						TriggerServerEvent("mad-gokarting:server:attemptbuy")
					else
						QBCore.Functions.Notify("Já alugas-te um veículo!", "error")
					end
				end,
				icon = "fas fa-car",
				label = "Alugar Kart",
			},
		},
		distance = 2
	})
  
end)

RegisterNetEvent("mad-gokarting:client:spawnkart")
AddEventHandler("mad-gokarting:client:spawnkart", function()
    local SpawnPoint = getVehicleSpawnPoint()
    local spawns = nil

    spawns = Config.locations
        
    if SpawnPoint then
        local coords = vector3(spawns[SpawnPoint].x, spawns[SpawnPoint].y, spawns[SpawnPoint].z)
        local CanSpawn = IsSpawnPointClear(coords, 2.0)
        if CanSpawn then
            
			local ModelHash = `veto2` -- Use Compile-time hashes to get the hash of this model
			if not IsModelInCdimage(ModelHash) then return end
				RequestModel(ModelHash) -- Request the model
			while not HasModelLoaded(ModelHash) do -- Waits for the model to load
  				Wait(0)
			end
			Vehicle = CreateVehicle(ModelHash, coords, spawns[SpawnPoint].w, true, true) 
			SetModelAsNoLongerNeeded(ModelHash) 
			exports[Config.Fuel]:SetFuel(Vehicle, 100.0)
			TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Vehicle))
			TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
			SetVehicleEngineOn(Vehicle, true, true)
			TriggerServerEvent("mad-gokarting:server:purchase")
			started = true
			timer = Config.Timer * 60 * 1000
			
			timerFdd()
        else
            QBCore.Functions.Notify("Todos os lugares estão ocupados", "error")
        end
    else
        QBCore.Functions.Notify("Todos os lugares estão ocupados", 'error')
        return
    end
end)

function timerFdd()
	while started do
		
		--print(tonumber(string.format("%.2f", (timer/1000)/60)))
		if timer <= 0 then
			started = false
			DoScreenFadeOut(1000)
			Wait(250)
			SetEntityCoords(PlayerPedId(), Config.ReturnPos.x ,Config.ReturnPos.y, Config.ReturnPos.z)
			DeleteEntity(Vehicle)
			Wait(250)
			DoScreenFadeIn(1500)
			return
		end
		exports['qb-core']:DrawText("Time left: "..tonumber(string.format("%.2f", (timer/1000)/60)), 'left')
		Wait(3000)
		exports['qb-core']:HideText()
		Wait(15000)
		timer = timer - 18000
	end
end


function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end
    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))
        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end
    return nearbyEntities
end

function GetVehiclesInArea(coords, maxDistance)
    -- Vehicle inspection in designated area
    return EnumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance)
end

function IsSpawnPointClear(coords, maxDistance)
    -- Check the spawn point to see if it's empty or not:
    return #GetVehiclesInArea(coords, maxDistance) == 0
end

function getVehicleSpawnPoint()

    local spawns = nil
    spawns = Config.locations
    
    local near = nil
    local distance = 10000
    for k, v in pairs(spawns) do
        if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local cur_distance = #(pos - vector3(v.x, v.y, v.z))
            if cur_distance < distance then
                distance = cur_distance
                near = k
            end
        end
    end

    return near
end