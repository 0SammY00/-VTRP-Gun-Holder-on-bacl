local attachedProps = {}

-- pripojÌ prop na chrb·t
function AttachWeapon(playerPed, weaponHash, model)
    if attachedProps[weaponHash] then return end

    local bone = GetPedBoneIndex(playerPed, Config.Bone)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local coords = GetEntityCoords(playerPed)
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z + 0.2, true, true, false)
    AttachEntityToEntity(
        obj, playerPed, bone,
        Config.xPos, Config.yPos, Config.zPos,
        Config.xRot, Config.yRot, Config.zRot,
        true, true, false, true, 1, true
    )

    attachedProps[weaponHash] = obj
end

-- odstr·ni prop zo chrbta
function RemoveWeapon(weaponHash)
    if attachedProps[weaponHash] then
        DeleteEntity(attachedProps[weaponHash])
        attachedProps[weaponHash] = nil
    end
end

-- hlavn˝ loop
CreateThread(function()
    while true do
        Wait(1000)

        local playerPed = PlayerPedId()
        local selected = GetSelectedPedWeapon(playerPed)

        for weaponName, model in pairs(Config.LongWeapons) do
            local weaponHash = GetHashKey(weaponName)

            -- ox_inventory check õ hr·Ë m· t˙to zbraÚ v invent·ri?
            local count = exports.ox_inventory:GetItemCount(weaponName, false, true)

            if count > 0 then
                if selected ~= weaponHash then
                    -- m· zbraÚ v invent·ri, ale nedrûÌ ju õ na chrb·t
                    AttachWeapon(playerPed, weaponHash, model)
                else
                    -- drûÌ ju õ odstr·niù zo chrbta
                    RemoveWeapon(weaponHash)
                end
            else
                -- zbraÚ v invent·ri uû nem· õ odstr·niù
                RemoveWeapon(weaponHash)
            end
        end
    end
end)

-- smrù õ vyËistiù vöetky props
AddEventHandler('esx:onPlayerDeath', function()
    for _, obj in pairs(attachedProps) do
        DeleteEntity(obj)
    end
    attachedProps = {}
end)
