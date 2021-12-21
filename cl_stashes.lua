local QBCore = exports['qb-core']:GetCoreObject()


Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    local text = '<b>[E] Open Stash</b>'
    while true do
    wait = 5
    local ped = PlayerPedId()
    local inZone = false

    for k, v in pairs(Config.Stashes) do

        local dist = #(GetEntityCoords(ped)-vector3(Config.Stashes[k].coords.x, Config.Stashes[k].coords.y, Config.Stashes[k].coords.z))
        if dist <= 3.0 then
        wait = 5
        inZone  = true

        if IsControlJustReleased(0, 38) then
            TriggerEvent('qb-business:client:openStash', k, Config.Stashes[k].stashName)
        end
        break
        else
        wait = 2000
        end
    end

    if inZone and not alreadyEnteredZone then
        alreadyEnteredZone = true
        TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
    end

    if not inZone and alreadyEnteredZone then
        alreadyEnteredZone = false
        TriggerEvent('cd_drawtextui:HideUI')
    end
    Citizen.Wait(wait)
    end
end)

RegisterNetEvent('qb-business:client:openStash', function(currentstash, stash)

    local PlayerData = QBCore.Functions.GetPlayerData()
    local PlayerJob = PlayerData.job.name
    local PlayerGang = PlayerData.gang.name
    local canOpen = false

    if Config.PoliceOpen then 
        if PlayerJob == "police" then
            canOpen = true
        end
    end

    if Config.Stashes[currentstash].jobrequired then 
        if PlayerJob == Config.Stashes[currentstash].job then
            canOpen = true
        end
    end

    if Config.Stashes[currentstash].requirecid then
        for k, v in pairs (Config.Stashes[currentstash].cid) do 
            if QBCore.Functions.GetPlayerData().citizenid == v then
                canOpen = true
            end
        end
    end

    if Config.Stashes[currentstash].gangrequired then
        if PlayerGang == Config.Stashes[currentstash].gang then
            canOpen = true
        end
    end

    if canOpen then 
        TriggerServerEvent("inventory:server:OpenInventory", "stash", Config.Stashes[currentstash].stashName, {maxweight = Config.Stashes[currentstash].stashSize, slots = Config.Stashes[currentstash].stashSlots})
        TriggerEvent("inventory:client:SetCurrentStash", Config.Stashes[currentstash].stashName)
    else
        QBCore.Functions.Notify('You cannot open this', 'error')
    end

end)