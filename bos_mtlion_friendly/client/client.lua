local Config = {
    Debug = true,

    -- Wie oft nach neuen Löwen gesucht wird
    CacheUpdate = 15000,

    -- Wie oft vorhandene Löwen geprüft werden
    CheckInterval = 1000,

    -- Reichweite
    CheckDistance = 100.0
}


local lionHash = `a_c_mtlion`

local lionCache = {}


local function DebugPrint(message)
    if Config.Debug then
        print("^3[bos_anti_mtlion]^7 " .. message)
    end
end


local function RefreshLionCache()

    DebugPrint("Starte Lion Cache Update")

    local newCache = {}
    local found = 0

    for _, ped in ipairs(GetGamePool("CPed")) do

        if DoesEntityExist(ped)
        and not IsPedAPlayer(ped)
        and GetEntityModel(ped) == lionHash then

            found = found + 1

            table.insert(newCache, ped)

            DebugPrint("Doofe böse Mitzekatze gespeichert | Entity: "..ped)
        end
    end


    lionCache = newCache


    DebugPrint(
        ("Cache fertig | Gefundene böße Mitzekatzen: %s")
        :format(found)
    )
end



-- Cache aktualisieren
CreateThread(function()

    DebugPrint("Cache Thread gestartet")

    while true do

        RefreshLionCache()

        Wait(Config.CacheUpdate)

    end

end)



-- Löwen kontrollieren
CreateThread(function()

    DebugPrint("Control Thread gestartet")


    while true do

        local playerPed = PlayerPedId()


        if DoesEntityExist(playerPed) then

            local playerCoords = GetEntityCoords(playerPed)

            local removed = 0


            for i = #lionCache, 1, -1 do

                local ped = lionCache[i]


                -- Prüfen ob Ped noch existiert
                if not DoesEntityExist(ped) then

                    table.remove(lionCache, i)

                    removed = removed + 1


                else

                    local pedCoords = GetEntityCoords(ped)

                    local distance = #(playerCoords - pedCoords)


                    if distance <= Config.CheckDistance then


                        DebugPrint(
                            ("Böße Mitzekatze gefunden. | Distanz %.2f")
                            :format(distance)
                        )


                        local relation = GetPedRelationshipGroupHash(ped)


                        SetRelationshipBetweenGroups(
                            1,
                            relation,
                            `PLAYER`
                        )

                        SetRelationshipBetweenGroups(
                            1,
                            `PLAYER`,
                            relation
                        )


                        SetPedCombatAttributes(
                            ped,
                            46,
                            false
                        )


                        SetPedCombatAttributes(
                            ped,
                            5,
                            false
                        )


                        SetPedFleeAttributes(
                            ped,
                            0,
                            false
                        )


                        if IsPedInCombat(ped, playerPed) then

                            DebugPrint("Angriff erkannt - breche ab")


                            ClearPedTasks(ped)
                            ClearPedSecondaryTask(ped)


                            TaskWanderStandard(
                                ped,
                                10.0,
                                10
                            )

                        end

                    end
                end
            end


            if removed > 0 then

                DebugPrint(
                    ("Entfernte tote Cache Einträge: %s")
                    :format(removed)
                )

            end

        end


        Wait(Config.CheckInterval)

    end

end)