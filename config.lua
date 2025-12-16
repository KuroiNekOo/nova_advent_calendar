Config = {}

-- Mode debug (permet de tester hors décembre)
Config.DebugMode = false

-- Jour simulé en mode debug (1-24)
Config.DebugDay = 4

-- =============================================================================
-- MODE RATTRAPAGE
-- Permet aux joueurs de récupérer les récompenses des jours passés
-- pendant une période limitée (ex: jours 1-6 jusqu'au 17/12/2025 à 5h00)
-- =============================================================================
Config.CatchupMode = {
    -- Activer le mode rattrapage
    enabled = true,

    -- Jour maximum récupérable pendant la période de rattrapage (1-24)
    -- Ex: 6 = les joueurs peuvent récupérer les jours 1, 2, 3, 4, 5, 6
    maxDay = 6,

    -- Date/heure de fin de la période de rattrapage
    -- Après cette date, les jours non récupérés seront marqués comme "manqués"
    endDate = {
        year = 2025,
        month = 12,
        day = 17,
        hour = 5,
        minute = 0
    }
}

-- Commande pour ouvrir le calendrier
Config.Command = 'calendar'

-- Mois du calendrier de l'avent (12 = Décembre)
Config.Month = 12

-- Délai avant fermeture automatique des NUI après ouverture du cadeau (en secondes)
Config.CloseDelay = 3

-- Sons joués lors de l'ouverture
-- Voir la liste complète : https://wiki.rage.mp/index.php?title=Sounds
Config.Sounds = {
    -- Son joué quand le cadeau s'ouvre (animation confettis)
    GiftOpened = {
        sound = "CHECKPOINT_PERFECT",
        soundset = "HUD_MINI_GAME_SOUNDSET"
    },
    -- Son joué à la fermeture du calendrier (récompense donnée)
    RewardGiven = {
        sound = "PICK_UP",
        soundset = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    }
}

-- ATTENTION: Reset automatique de la base de données au démarrage du script
-- Si activé, TOUTES les données du calendrier seront supprimées à chaque restart/start/ensure
-- Utile pour les tests, DÉSACTIVER EN PRODUCTION !
Config.ResetDatabaseOnStart = true

-- Types disponibles :
-- {type = 'item', name = 'bread', count = 5}
-- {type = 'money', account = 'money', amount = 1000}  -- Argent liquide
-- {type = 'money', account = 'bank', amount = 2500}   -- Argent en banque
--
-- Exemple avec plusieurs récompenses :
-- [1] = {
--     {type = 'item', name = 'bread', count = 5},
--     {type = 'item', name = 'water', count = 3},
--     {type = 'money', account = 'money', amount = 500},
-- },
Config.Rewards = {
    [1] = {
        {type = 'item', name = 'bread', count = 5},
        {type = 'item', name = 'water', count = 5},
        {type = 'money', account = 'money', amount = 500},
        {type = 'money', account = 'bank', amount = 1000},
    },
    [2] = {
        {type = 'money', account = 'money', amount = 1000},
    },
    [3] = {
        {type = 'item', name = 'water', count = 3},
    },
    [4] = {
        {type = 'money', account = 'bank', amount = 2500},
    },
    [5] = {
        {type = 'item', name = 'bread', count = 10},
    },
    [6] = {
        {type = 'money', account = 'money', amount = 1500},
    },
    [7] = {
        {type = 'item', name = 'water', count = 5},
    },
    [8] = {
        {type = 'money', account = 'bank', amount = 3000},
    },
    [9] = {
        {type = 'item', name = 'bread', count = 15},
    },
    [10] = {
        {type = 'money', account = 'money', amount = 2000},
    },
    [11] = {
        {type = 'item', name = 'water', count = 8},
    },
    [12] = {
        {type = 'money', account = 'bank', amount = 5000},
    },
    [13] = {
        {type = 'item', name = 'bread', count = 20},
    },
    [14] = {
        {type = 'money', account = 'money', amount = 3000},
    },
    [15] = {
        {type = 'item', name = 'water', count = 10},
    },
    [16] = {
        {type = 'money', account = 'bank', amount = 7500},
    },
    [17] = {
        {type = 'item', name = 'bread', count = 25},
    },
    [18] = {
        {type = 'money', account = 'money', amount = 4000},
    },
    [19] = {
        {type = 'item', name = 'water', count = 15},
    },
    [20] = {
        {type = 'money', account = 'bank', amount = 10000},
    },
    [21] = {
        {type = 'item', name = 'bread', count = 30},
    },
    [22] = {
        {type = 'money', account = 'money', amount = 5000},
    },
    [23] = {
        {type = 'item', name = 'water', count = 20},
    },
    [24] = {
        {type = 'money', account = 'bank', amount = 25000},
    },
}
