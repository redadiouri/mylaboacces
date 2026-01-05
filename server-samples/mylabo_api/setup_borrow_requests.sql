-- Création de la table borrow_requests
CREATE TABLE IF NOT EXISTS `borrow_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_email` VARCHAR(255) NOT NULL,
  `equipment_name` VARCHAR(255) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `status` VARCHAR(50) NOT NULL DEFAULT 'En attente',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_user_email` (`user_email`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exemple d'insertion de données de test (optionnel)
-- INSERT INTO borrow_requests (user_email, equipment_name, quantity, status) 
-- VALUES ('test@example.com', 'Écrans', 2, 'En attente');
