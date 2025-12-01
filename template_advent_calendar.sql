CREATE TABLE IF NOT EXISTS `advent_calendar` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `day` TINYINT NOT NULL,
    `year` SMALLINT NOT NULL,
    `opened_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_player_day` (`identifier`, `day`, `year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
