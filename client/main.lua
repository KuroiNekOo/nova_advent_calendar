local calendarOpen = false
local giftAnimationOpen = false
local calendarData = {}
local lastOpenedDay = nil -- Stocker le jour ouvert pour donner la récompense à la fermeture

-- Commande pour ouvrir le calendrier
RegisterCommand(Config.Command, function()
    OpenCalendar()
end, false)

-- Fonction pour ouvrir le calendrier
function OpenCalendar()
    if calendarOpen then return end

    ESX.TriggerServerCallback('esx_advent_calendar:getCalendarData', function(data)
        if not data.valid then
            lib.notify({
                title = 'Calendrier de l\'Avent',
                description = data.message,
                type = 'error',
                duration = 5000
            })
            return
        end

        calendarData = data
        calendarOpen = true

        -- Envoyer les données au NUI du calendrier
        SendNUIMessage({
            action = 'openCalendar',
            openedDays = data.openedDays,
            currentDay = data.currentDay,
            currentMonth = data.currentMonth,
            catchupRange = data.catchupRange,
            debugMode = Config.DebugMode
        })

        SetNuiFocus(true, true)
    end)
end

-- Fonction pour fermer le calendrier
function CloseCalendar()
    calendarOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'closeCalendar'
    })

    -- Donner la récompense si un jour a été ouvert
    if lastOpenedDay then
        TriggerServerEvent('esx_advent_calendar:giveReward', lastOpenedDay)

        -- Jouer un son de succès (son de récompense)
        if (Config.Sounds.RewardGiven) then
            PlaySoundFrontend(-1, Config.Sounds.RewardGiven.sound, Config.Sounds.RewardGiven.soundset, true)
        end

        lastOpenedDay = nil
    end
end

-- Fonction pour fermer l'animation du cadeau
function CloseGiftAnimation()
    giftAnimationOpen = false

    SendNUIMessage({
        action = 'closeGift'
    })
end

-- NUI Callback pour fermer le calendrier
RegisterNUICallback('closeCalendar', function(data, cb)
    CloseCalendar()
    cb('ok')
end)

-- NUI Callback pour ouvrir une case
RegisterNUICallback('openDay', function(data, cb)
    local day = data.day

    ESX.TriggerServerCallback('esx_advent_calendar:canOpenDay', function(canOpen, reason)
        if canOpen then
            -- Notifier le serveur
            TriggerServerEvent('esx_advent_calendar:openDay', day)

            -- Afficher l'animation du cadeau en superposition
            giftAnimationOpen = true
            SendNUIMessage({
                action = 'showGift'
            })

            -- Le CloseDelay sera déclenché quand le joueur clique et que le cadeau est ouvert
            -- Voir le callback 'giftFullyOpened' ci-dessous

            cb({success = true})
        else
            lib.notify({
                title = 'Calendrier de l\'Avent',
                description = reason,
                type = 'error',
                duration = 5000
            })
            cb({success = false, reason = reason})
        end
    end, day)
end)

-- NUI Callback quand le cadeau est complètement ouvert
RegisterNUICallback('giftFullyOpened', function(data, cb)
    -- Jouer un son festif pour les confettis
    if (Config.Sounds.GiftOpened) then
        PlaySoundFrontend(-1, Config.Sounds.GiftOpened.sound, Config.Sounds.GiftOpened.soundset, true)
    end

    -- Le cadeau est maintenant complètement ouvert, démarrer le CloseDelay
    SetTimeout(Config.CloseDelay * 1000, function()
        CloseGiftAnimation()
        CloseCalendar()
    end)

    cb('ok')
end)

-- Event quand un jour est ouvert avec succès
RegisterNetEvent('esx_advent_calendar:dayOpened', function(day)
    -- Stocker le jour pour donner la récompense à la fermeture
    lastOpenedDay = day

    -- Mettre à jour la liste des jours ouverts
    table.insert(calendarData.openedDays, day)

    -- Mettre à jour l'affichage du calendrier
    SendNUIMessage({
        action = 'updateDay',
        day = day,
        state = 'opened'
    })
end)

-- Désactiver ESC natif et gérer la fermeture via NUI
CreateThread(function()
    while true do
        Wait(5)
        if calendarOpen and not giftAnimationOpen then
            -- Désactiver les contrôles du jeu pendant que le calendrier est ouvert
            -- Mais autoriser ESC depuis le NUI sauf pendant l'animation du cadeau
            DisableControlAction(0, 200, true) -- ESC
            DisableControlAction(0, 322, true) -- ESC
        else
            Wait(500)
        end
    end
end)
