-- Fonction helper pour vérifier si on est dans la période de rattrapage
local function isCatchupPeriodActive()
    if not Config.CatchupMode or not Config.CatchupMode.enabled then
        return false
    end

    local endDate = Config.CatchupMode.endDate
    local currentTime = os.time()
    local endTime = os.time({
        year = endDate.year,
        month = endDate.month,
        day = endDate.day,
        hour = endDate.hour,
        min = endDate.minute,
        sec = 0
    })

    return currentTime < endTime
end

-- Créer la table automatiquement au démarrage
MySQL.query([[
    CREATE TABLE IF NOT EXISTS `advent_calendar` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `identifier` VARCHAR(50) NOT NULL,
        `day` TINYINT NOT NULL,
        `year` SMALLINT NOT NULL,
        `opened_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY `unique_player_day` (`identifier`, `day`, `year`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
]], {}, function(result)
    print('^2[ESX Advent Calendar]^7 Table SQL créée ou déjà existante')

    -- Reset de la base de données si activé dans la config
    if Config.ResetDatabaseOnStart then
        MySQL.query('DELETE FROM advent_calendar', {}, function(deleteResult)
            print('^3[ESX Advent Calendar]^7 ^1RESET DATABASE ACTIVÉ^7 - Toutes les données ont été supprimées!')
            print('^3[ESX Advent Calendar]^7 ^1ATTENTION: Désactivez Config.ResetDatabaseOnStart en production!^7')
        end)
    end
end)

-- Callback pour obtenir les données du calendrier du joueur
ESX.RegisterServerCallback('esx_advent_calendar:getCalendarData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    local identifier = xPlayer.identifier
    local currentYear = tonumber(os.date('%Y'))
    local currentMonth = tonumber(os.date('%m'))
    local currentDay = tonumber(os.date('%d'))

    -- Vérifier le mois (sauf en mode debug)
    if not Config.DebugMode and currentMonth ~= Config.Month then
        return cb({
            valid = false,
            message = 'Le calendrier de l\'avent n\'est pas disponible ce mois ci !'
        })
    end

    -- En mode debug, simuler le jour configuré
    if Config.DebugMode then
        currentMonth = Config.Month
        currentDay = Config.DebugDay
    end

    -- Mode rattrapage : simuler le jour maxDay si la période est active
    if isCatchupPeriodActive() then
        currentMonth = Config.Month
        currentDay = Config.CatchupMode.maxDay
    end

    -- Récupérer les jours ouverts de la base de données
    MySQL.query('SELECT day FROM advent_calendar WHERE identifier = ? AND year = ?', {
        identifier, currentYear
    }, function(result)
        local openedDays = {}
        for _, row in ipairs(result) do
            table.insert(openedDays, row.day)
        end

        cb({
            valid = true,
            openedDays = openedDays,
            currentDay = currentDay,
            currentMonth = currentMonth,
            currentYear = currentYear
        })
    end)
end)

-- Callback pour vérifier si le joueur peut ouvrir un jour
ESX.RegisterServerCallback('esx_advent_calendar:canOpenDay', function(source, cb, day)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false, 'Erreur joueur') end

    local identifier = xPlayer.identifier
    local currentYear = tonumber(os.date('%Y'))
    local currentMonth = tonumber(os.date('%m'))
    local currentDay = tonumber(os.date('%d'))

    -- En mode debug, simuler la date
    if Config.DebugMode then
        currentMonth = Config.Month
        currentDay = Config.DebugDay
    end

    -- Mode rattrapage : simuler le jour maxDay si la période est active
    if isCatchupPeriodActive() then
        currentMonth = Config.Month
        currentDay = Config.CatchupMode.maxDay
    end

    -- Vérifier le mois
    if not Config.DebugMode and not isCatchupPeriodActive() and currentMonth ~= Config.Month then
        return cb(false, 'Le calendrier de l\'avent n\'est pas disponible ce mois ci !')
    end

    -- On ne peut ouvrir QUE le jour actuel
    if day ~= currentDay then
        if day > currentDay then
            return cb(false, 'Ce jour n\'est pas encore arrivé!')
        else
            return cb(false, 'Ce jour est passé, vous l\'avez loupé!')
        end
    end

    -- Vérifier si le jour est déjà ouvert dans la base de données
    MySQL.query('SELECT id FROM advent_calendar WHERE identifier = ? AND day = ? AND year = ?', {
        identifier, day, currentYear
    }, function(result)
        if result and #result > 0 then
            return cb(false, 'Vous avez déjà ouvert cette case aujourd\'hui!')
        end

        cb(true)
    end)
end)

-- Event pour ouvrir un jour
RegisterServerEvent('esx_advent_calendar:openDay', function(day)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local currentYear = tonumber(os.date('%Y'))
    local currentMonth = tonumber(os.date('%m'))
    local currentDay = tonumber(os.date('%d'))

    -- En mode debug, simuler la date
    if Config.DebugMode then
        currentMonth = Config.Month
        currentDay = Config.DebugDay
    end

    -- Mode rattrapage : simuler le jour maxDay si la période est active
    if isCatchupPeriodActive() then
        currentMonth = Config.Month
        currentDay = Config.CatchupMode.maxDay
    end

    -- Double vérification côté serveur
    if not Config.DebugMode and not isCatchupPeriodActive() and currentMonth ~= Config.Month then
        TriggerClientEvent('ox_lib:notify', _source, {
            title = 'Calendrier de l\'Avent',
            description = 'Le calendrier de l\'avent n\'est disponible qu\'en décembre!',
            type = 'error',
            duration = 5000
        })
        return
    end

    if day ~= currentDay then
        if day > currentDay then
            TriggerClientEvent('ox_lib:notify', _source, {
                title = 'Calendrier de l\'Avent',
                description = 'Ce jour n\'est pas encore arrivé!',
                type = 'error',
                duration = 5000
            })
        else
            TriggerClientEvent('ox_lib:notify', _source, {
                title = 'Calendrier de l\'Avent',
                description = 'Ce jour est passé, vous l\'avez loupé!',
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    -- Vérifier si le jour est déjà ouvert dans la base de données
    MySQL.query('SELECT id FROM advent_calendar WHERE identifier = ? AND day = ? AND year = ?', {
        identifier, day, currentYear
    }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('ox_lib:notify', _source, {
                title = 'Calendrier de l\'Avent',
                description = 'Vous avez déjà ouvert cette case aujourd\'hui!',
                type = 'error',
                duration = 5000
            })
            return
        end

        -- Insérer dans la base de données avec gestion d'erreur améliorée
        local success, insertId = pcall(function()
            return MySQL.insert.await('INSERT INTO advent_calendar (identifier, day, year) VALUES (?, ?, ?)', {
                identifier, day, currentYear
            })
        end)

        if success and insertId then
            print('[CALENDRIER] ' .. xPlayer.getName() .. ' a ouvert le jour ' .. day)

            -- Notifier le client que l'ouverture a réussi (la récompense sera donnée à la fermeture)
            TriggerClientEvent('esx_advent_calendar:dayOpened', _source, day)
        else
            -- Erreur silencieuse si duplicate entry (double-clic)
            -- L'utilisateur ne verra rien car la case est déjà marquée comme ouverte
            if not success then
                print('[CALENDRIER] Tentative de double ouverture bloquée pour ' .. xPlayer.getName() .. ' - jour ' .. day)
            end

            TriggerClientEvent('ox_lib:notify', _source, {
                title = 'Calendrier de l\'Avent',
                description = 'Cette case a déjà été ouverte',
                type = 'error',
                duration = 5000
            })
        end
    end)
end)

-- Event pour donner la récompense à la fermeture du NUI
RegisterServerEvent('esx_advent_calendar:giveReward', function(day)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    -- Donner les récompenses (maintenant un tableau)
    local rewards = Config.Rewards[day]
    if rewards then
        for _, reward in ipairs(rewards) do
            if reward.type == 'item' then
                -- Utiliser ox_inventory
                local success = exports.ox_inventory:AddItem(_source, reward.name, reward.count)
                if success then
                    TriggerClientEvent('ox_lib:notify', _source, {
                        title = 'Calendrier de l\'Avent',
                        description = 'Vous avez reçu ' .. reward.count .. 'x ' .. reward.name,
                        type = 'success',
                        duration = 5000
                    })
                end
            elseif reward.type == 'money' then
                if reward.account == 'money' then
                    xPlayer.addMoney(reward.amount)
                    TriggerClientEvent('ox_lib:notify', _source, {
                        title = 'Calendrier de l\'Avent',
                        description = 'Vous avez reçu $' .. reward.amount,
                        type = 'success',
                        duration = 5000
                    })
                elseif reward.account == 'bank' then
                    xPlayer.addAccountMoney('bank', reward.amount)
                    TriggerClientEvent('ox_lib:notify', _source, {
                        title = 'Calendrier de l\'Avent',
                        description = 'Vous avez reçu $' .. reward.amount .. ' sur votre compte en banque',
                        type = 'success',
                        duration = 5000
                    })
                end
            end
        end
    end
end)
