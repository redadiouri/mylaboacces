-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : ven. 09 jan. 2026 à 13:43
-- Version du serveur : 8.0.30
-- Version de PHP : 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mylaboipi`
--

-- --------------------------------------------------------

--
-- Structure de la table `borrow_requests`
--

CREATE TABLE `borrow_requests` (
  `id` int NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `equipment_name` varchar(255) NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `purpose` text,
  `duration` varchar(100) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'En attente',
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `borrow_requests`
--

INSERT INTO `borrow_requests` (`id`, `user_email`, `equipment_name`, `quantity`, `purpose`, `duration`, `status`, `submitted_at`) VALUES
(9, 'admin@mylabo.com', 'Test', 1, 'test', '1j', 'En attente', '2026-01-05 13:08:50'),
(10, 'admin@mylabo.com', 'Test2', 3, 'test2', '2j', 'En attente', '2026-01-05 13:09:11'),
(11, 'admin@mylabo.com', 'TestFinal2', 2, 'test2', '2j', 'En attente', '2026-01-05 13:15:52'),
(12, 'admin@mylabo.com', 'Switches', 10, 'test', '1 semaine', 'En attente', '2026-01-05 13:17:31');

-- --------------------------------------------------------

--
-- Structure de la table `equipment`
--

CREATE TABLE `equipment` (
  `id` int NOT NULL,
  `nom` varchar(100) NOT NULL,
  `quantite_total` int DEFAULT '0',
  `quantite_emprunte` int DEFAULT '0',
  `etat` varchar(50) DEFAULT 'Bon',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `equipment`
--

INSERT INTO `equipment` (`id`, `nom`, `quantite_total`, `quantite_emprunte`, `etat`, `created_at`) VALUES
(1, 'Écrans', 10, 7, 'Bon', '2026-01-02 12:53:41'),
(2, 'Routeurs', 0, 3, 'Bon', '2026-01-02 12:53:41'),
(3, 'Switches', 12, 3, 'Moyen', '2026-01-02 12:53:41'),
(4, 'Serveurs', 4, 2, 'Bon', '2026-01-02 12:53:41'),
(5, 'Câbles réseau', 150, 30, 'Bon', '2026-01-05 12:22:29'),
(6, 'Points d\'accès WiFi', 6, 2, 'Bon', '2026-01-02 12:53:41');

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

CREATE TABLE `reports` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `equipment_name` varchar(255) DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `user_email` varchar(100) NOT NULL DEFAULT '',
  `status` varchar(50) DEFAULT 'En attente',
  `priority` varchar(50) DEFAULT 'Moyenne'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(255) NOT NULL,
  `nom` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('invite','utilisateur','admin') NOT NULL DEFAULT 'utilisateur',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `password` varchar(255) NOT NULL DEFAULT 'password123',
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `email`, `nom`, `password_hash`, `role`, `created_at`, `updated_at`, `password`, `active`) VALUES
(6, 'redadiouri6@gmail.com', 'B2_DIOURI.Reda', '$2y$10$B3xFepEzVx3jgIu7ko4rbObUYpis.c8rtRDxjxWBmFBZ3w36mcqzq', 'utilisateur', '2025-11-25 10:47:23', '2025-11-25 10:47:23', 'password123', 1),
(7, 'admin@mylabo.com', 'A_ADMIN.Admin', '$2y$10$ONLzI5VeMLx2f7hYoB8yTueHfnVZg9fcxHw2aea38JqmgPfiBsPuC', 'utilisateur', '2025-11-25 11:04:00', '2025-11-25 11:04:00', 'password123', 1),
(8, 'reda@gmail.com', 'B3_DIOURI.Imad', '$2y$10$LZOHtjl198NgJe.xNEkSYemN.dx3M6MbB2AiqwwjNqaJ9HwU5NrIG', 'utilisateur', '2026-01-02 12:37:18', '2026-01-02 12:37:18', 'password123', 1),
(10, 'reda@example.com', 'B2ipi_DIOURI.Reda', '', 'utilisateur', '2026-01-02 13:06:02', '2026-01-02 13:06:02', 'pass123', 1),
(11, 'sophie@example.com', 'B2ipi_MARTIN.Sophie', '', 'utilisateur', '2026-01-02 13:06:02', '2026-01-02 13:06:02', 'pass123', 1);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `borrow_requests`
--
ALTER TABLE `borrow_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_email` (`user_email`);

--
-- Index pour la table `equipment`
--
ALTER TABLE `equipment`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `borrow_requests`
--
ALTER TABLE `borrow_requests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `equipment`
--
ALTER TABLE `equipment`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT pour la table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `borrow_requests`
--
ALTER TABLE `borrow_requests`
  ADD CONSTRAINT `borrow_requests_ibfk_1` FOREIGN KEY (`user_email`) REFERENCES `users` (`email`) ON DELETE CASCADE;

--
-- Contraintes pour la table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

/*
CREATE TABLE user_token (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,

    CONSTRAINT fk_user_token_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
); */;
