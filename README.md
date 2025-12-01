# Nova Advent Calendar

Calendrier de l'avent pour serveur FiveM ESX Legacy avec interface 3D interactive.

## Fonctionnalités

- 24 cases interactives avec animation d'ouverture 3D
- Animation de cadeau avec confettis
- Effets de neige animés
- Récompenses configurables (items, argent liquide, argent en banque)
- Support multi-récompenses par jour
- Protection anti-triche (double validation serveur)
- Mode debug pour tester hors décembre
- Base de données persistante par année

## Dépendances

- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Placer le dossier `nova_advent_calendar` dans votre dossier `resources`
2. Ajouter `ensure nova_advent_calendar` dans votre `server.cfg`
3. Configurer les récompenses dans `config.lua`
4. Redémarrer le serveur

La table SQL est créée automatiquement au démarrage.

## Configuration

### Options principales

```lua
Config.DebugMode = false          -- Mode debug (teste hors décembre)
Config.DebugDay = 4               -- Jour simulé en mode debug (1-24)
Config.Command = 'calendar'       -- Commande pour ouvrir le calendrier
Config.Month = 12                 -- Mois actif (12 = Décembre)
Config.CloseDelay = 3             -- Délai avant fermeture auto (secondes)
Config.ResetDatabaseOnStart = false  -- Reset la DB au démarrage (DÉSACTIVER EN PROD)
```

### Configuration des sons

```lua
Config.Sounds = {
    GiftOpened = {
        sound = "CHECKPOINT_PERFECT",
        soundset = "HUD_MINI_GAME_SOUNDSET"
    },
    RewardGiven = {
        sound = "PICK_UP",
        soundset = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    }
}
```

Liste des sons : https://wiki.rage.mp/index.php?title=Sounds

### Configuration des récompenses

Trois types de récompenses disponibles :

```lua
-- Item (via ox_inventory)
{type = 'item', name = 'bread', count = 5}

-- Argent liquide
{type = 'money', account = 'money', amount = 1000}

-- Argent en banque
{type = 'money', account = 'bank', amount = 2500}
```

Exemple avec plusieurs récompenses pour un jour :

```lua
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
    -- ... jours 3 à 24
}
```

## Utilisation

| Commande | Description |
|----------|-------------|
| `/calendar` | Ouvre le calendrier de l'avent |

### Règles du calendrier

- Seul le jour actuel peut être ouvert
- Les jours passés sont marqués comme "loupés"
- Les jours futurs sont verrouillés
- Chaque case ne peut être ouverte qu'une seule fois par an

## Structure des fichiers

```
nova_advent_calendar/
├── fxmanifest.lua          # Manifest de la resource
├── config.lua              # Configuration
├── client/
│   └── main.lua            # Logique client (NUI, commandes)
├── server/
│   └── main.lua            # Logique serveur (DB, récompenses)
└── html/
    ├── index.html          # Interface du calendrier
    └── script.js           # Animations et interactions
```

## Base de données

Table `advent_calendar` :

| Colonne | Type | Description |
|---------|------|-------------|
| id | INT | Clé primaire |
| identifier | VARCHAR(50) | Identifiant du joueur |
| day | TINYINT | Jour ouvert (1-24) |
| year | SMALLINT | Année |
| opened_at | TIMESTAMP | Date d'ouverture |

## Auteur

**Xam42**

## Version

2.0.0
