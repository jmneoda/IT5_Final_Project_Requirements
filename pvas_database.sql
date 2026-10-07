-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 11, 2026 at 02:01 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pvas_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `pet_id` bigint(20) UNSIGNED NOT NULL,
  `veterinarian_id` bigint(20) UNSIGNED NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_time` time NOT NULL,
  `reason_for_visit` text DEFAULT NULL,
  `type` enum('Checkup','Vaccination','Surgery','Grooming') DEFAULT NULL,
  `status` enum('scheduled','confirmed','completed','no_show','canceled') NOT NULL DEFAULT 'scheduled',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `customer_id`, `pet_id`, `veterinarian_id`, `scheduled_date`, `scheduled_time`, `reason_for_visit`, `type`, `status`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 4, '2023-08-03', '09:00:00', 'For Vaccination', NULL, 'completed', 3, 1, '2026-05-03 13:15:55', '2026-05-08 01:11:49'),
(2, 1, 2, 4, '2026-05-11', '08:00:00', 'For vaccine', NULL, 'completed', 3, 1, '2026-05-04 07:20:32', '2026-05-07 03:24:06'),
(3, 2, 3, 4, '2026-05-08', '09:00:00', 'For vaccination', NULL, 'completed', 3, 3, '2026-05-06 00:46:36', '2026-05-07 12:34:04'),
(4, 2, 5, 4, '2026-05-10', '09:00:00', 'For making my pet looks beautiful', NULL, 'completed', 3, 3, '2026-05-07 09:10:07', '2026-05-08 07:14:20'),
(5, 3, 6, 4, '2026-05-10', '09:00:00', 'For anti rabbies', NULL, 'completed', 3, 3, '2026-05-07 10:14:58', '2026-05-07 12:33:48'),
(6, 3, 7, 4, '2026-05-12', '09:00:00', 'For checking their situation', 'Checkup', 'completed', 3, 1, '2026-05-07 10:32:49', '2026-05-08 01:11:07'),
(7, 2, 8, 4, '2026-05-12', '09:00:00', 'Muscle disalign', 'Surgery', 'completed', 1, 1, '2026-05-07 18:47:15', '2026-05-07 19:48:28'),
(8, 1, 9, 4, '2026-05-12', '09:00:00', 'Basta', 'Grooming', 'completed', 3, 1, '2026-05-07 19:36:08', '2026-05-07 20:08:16'),
(9, 4, 10, 4, '2026-05-11', '09:00:00', 'Ear problem', 'Surgery', 'canceled', 3, 1, '2026-05-08 06:38:22', '2026-05-10 14:00:22'),
(10, 5, 11, 5, '2026-05-13', '09:00:00', 'For following check ups', 'Checkup', 'completed', 1, 1, '2026-05-10 05:41:32', '2026-05-10 13:57:15'),
(11, 4, 12, 5, '2026-05-15', '09:00:00', 'Nothing', 'Checkup', 'scheduled', 3, 3, '2026-05-10 07:16:39', '2026-05-10 07:16:39'),
(12, 3, 13, 5, '2026-05-20', '09:00:00', 'Wala ragud', 'Grooming', 'scheduled', 3, 3, '2026-05-10 07:51:06', '2026-05-10 07:51:06'),
(13, 5, 14, 4, '2026-05-15', '09:00:00', 'As if', 'Vaccination', 'confirmed', 1, 4, '2026-05-10 14:52:10', '2026-05-10 15:49:52');

-- --------------------------------------------------------

--
-- Table structure for table `appointment_status_histories`
--

CREATE TABLE `appointment_status_histories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `appointment_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(255) NOT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointment_status_histories`
--

INSERT INTO `appointment_status_histories` (`id`, `appointment_id`, `status`, `changed_by`, `changed_at`) VALUES
(1, 2, 'confirmed', 1, '2026-05-07 03:16:14'),
(2, 3, 'no_show', 1, '2026-05-07 03:18:37'),
(3, 3, 'no_show', 1, '2026-05-07 03:18:40'),
(4, 2, 'completed', 1, '2026-05-07 03:24:06'),
(5, 4, 'confirmed', 3, '2026-05-07 11:27:06'),
(6, 3, 'confirmed', 3, '2026-05-07 12:22:48'),
(7, 4, 'no_show', 3, '2026-05-07 12:23:24'),
(8, 1, 'no_show', 1, '2026-05-07 12:25:37'),
(9, 6, 'no_show', 1, '2026-05-07 12:31:47'),
(10, 5, 'confirmed', 1, '2026-05-07 12:31:57'),
(11, 6, 'scheduled', 3, '2026-05-07 12:33:17'),
(12, 5, 'completed', 3, '2026-05-07 12:33:48'),
(13, 3, 'completed', 3, '2026-05-07 12:34:04'),
(14, 6, 'no_show', 1, '2026-05-07 12:43:49'),
(15, 7, 'scheduled', 1, '2026-05-07 18:47:15'),
(16, 8, 'scheduled', 3, '2026-05-07 19:36:08'),
(17, 7, 'completed', 1, '2026-05-07 19:48:28'),
(18, 8, 'completed', 1, '2026-05-07 20:08:16'),
(19, 6, 'scheduled', 1, '2026-05-07 20:09:15'),
(20, 6, 'confirmed', 1, '2026-05-07 20:15:02'),
(21, 6, 'scheduled', 3, '2026-05-08 01:08:42'),
(22, 6, 'completed', 1, '2026-05-08 01:11:07'),
(23, 4, 'scheduled', 1, '2026-05-08 01:11:37'),
(24, 1, 'completed', 1, '2026-05-08 01:11:49'),
(25, 4, 'canceled', 1, '2026-05-08 01:25:20'),
(26, 4, 'no_show', 3, '2026-05-08 01:57:31'),
(27, 4, 'canceled', 3, '2026-05-08 02:27:09'),
(28, 9, 'scheduled', 3, '2026-05-08 06:38:22'),
(29, 9, 'confirmed', 1, '2026-05-08 06:54:41'),
(30, 4, 'completed', 3, '2026-05-08 07:14:20'),
(31, 9, 'no_show', 4, '2026-05-10 00:52:29'),
(32, 10, 'scheduled', 1, '2026-05-10 05:41:32'),
(33, 10, 'confirmed', 3, '2026-05-10 05:42:44'),
(34, 11, 'scheduled', 3, '2026-05-10 07:16:39'),
(35, 12, 'scheduled', 3, '2026-05-10 07:51:06'),
(36, 10, 'completed', 1, '2026-05-10 13:57:15'),
(37, 9, 'canceled', 1, '2026-05-10 14:00:22'),
(38, 13, 'scheduled', 1, '2026-05-10 14:52:10'),
(39, 13, 'confirmed', 4, '2026-05-10 15:49:52');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `registered_by` bigint(20) UNSIGNED DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `contact_number` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `registered_by`, `first_name`, `last_name`, `email`, `contact_number`, `address`, `created_at`, `updated_at`) VALUES
(1, 3, 'Amethyst', 'Nioda', 'thyst@gmail.com', '09674823800', 'Libungan Cotabato', '2026-05-03 10:16:42', '2026-05-03 10:16:42'),
(2, 3, 'Irish', 'Pelayo', 'irish@gmail.com', '09631008080', 'San Agustin Davao Occidental', '2026-05-03 12:32:28', '2026-05-03 12:32:28'),
(3, 3, 'Jesierie', 'Pait', 'jes@gmail.com', '09674823096', 'Tadazi, TADS', '2026-05-07 10:14:03', '2026-05-07 10:14:03'),
(4, 1, 'Sab', 'Nioda', 'sab@gmail.com', '09107637400', 'Davao City', '2026-05-07 20:47:48', '2026-05-07 20:47:48'),
(5, 1, 'Bebiana', 'Nioda', 'bebz@gmail.com', '09673008202', 'Sta. Maria TADS', '2026-05-10 05:38:58', '2026-05-10 05:38:58');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_05_02_063526_create_customers_table', 1),
(5, '2026_05_02_063604_create_pets_table', 1),
(6, '2026_05_02_063650_create_appointments_table', 1),
(9, '2026_05_07_111149_create_appointment_status_histories_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pets`
--

CREATE TABLE `pets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `pet_name` varchar(255) NOT NULL,
  `species` enum('Dog','Cat','Bird','Rabbit','Hamster','Other') NOT NULL,
  `breed` varchar(255) DEFAULT NULL,
  `gender` enum('Male','Female') DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `medical_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pets`
--

INSERT INTO `pets` (`id`, `customer_id`, `pet_name`, `species`, `breed`, `gender`, `birthdate`, `color`, `weight`, `medical_notes`, `created_at`, `updated_at`) VALUES
(1, 1, 'Petpet', 'Dog', 'Golden Retriever', 'Male', NULL, 'Brown', 20.00, NULL, '2026-05-03 13:15:55', '2026-05-03 13:15:55'),
(2, 1, 'Catcat', 'Cat', 'Persian', 'Female', NULL, 'White', 5.00, NULL, '2026-05-04 07:20:32', '2026-05-04 07:20:32'),
(3, 2, 'Browny', 'Dog', 'Golden Retriever', 'Male', NULL, 'White', 15.00, NULL, '2026-05-06 00:46:36', '2026-05-06 00:46:36'),
(4, 2, 'Whitey', 'Dog', 'Golden Retriever', NULL, NULL, 'Brown', 15.00, NULL, '2026-05-07 08:35:40', '2026-05-07 08:35:40'),
(5, 2, 'Whitey', 'Dog', 'Golden Retriever', 'Male', NULL, 'Brown', 15.00, NULL, '2026-05-07 09:10:07', '2026-05-07 09:10:07'),
(6, 3, 'Piola', 'Dog', 'Aspin (Mixed Breed)', 'Female', NULL, 'Black', 10.00, NULL, '2026-05-07 10:14:58', '2026-05-07 10:14:58'),
(7, 3, 'Buday', 'Cat', 'Persian', NULL, NULL, 'White', 3.00, NULL, '2026-05-07 10:32:49', '2026-05-07 10:32:49'),
(8, 2, 'Blacky', 'Dog', 'Golden Retriever', 'Male', NULL, 'White', 15.00, NULL, '2026-05-07 18:47:15', '2026-05-07 18:47:15'),
(9, 1, 'Petpet', 'Dog', 'Golden Retriever', 'Male', NULL, 'Brown', 14.00, NULL, '2026-05-07 19:36:08', '2026-05-07 19:36:08'),
(10, 4, 'Bunsoy', 'Dog', 'Golden Retriever', 'Male', NULL, 'Brown', 15.00, NULL, '2026-05-08 06:38:22', '2026-05-08 06:38:22'),
(11, 5, 'Kulot', 'Dog', 'Labrador Retriever', 'Female', NULL, 'Brown', 15.00, NULL, '2026-05-10 05:41:32', '2026-05-10 05:41:32'),
(12, 4, 'Putot', 'Dog', 'Aspin (Mixed Breed)', 'Female', NULL, 'Black', 7.00, NULL, '2026-05-10 07:16:39', '2026-05-10 07:16:39'),
(13, 3, 'jm', 'Dog', 'Golden Retriever', 'Male', NULL, 'White', 60.00, NULL, '2026-05-10 07:51:06', '2026-05-10 07:51:06'),
(14, 5, 'Kulot', 'Cat', 'Persian', 'Male', NULL, 'Orange', 5.00, NULL, '2026-05-10 14:52:10', '2026-05-10 14:52:10');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('TFsQwuPP9AesolkTbxzStRKc1s5BWRD7XKqhyWzD', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOUdJSzBNaWpQdk9rVWtSbU9qMDlwZkFpeUF0elFyZUE4OWdDU21xUyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fX0=', 1778457691);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','veterinarian','receptionist','vet_nurse','vet_assistant','groomer','staff') NOT NULL DEFAULT 'staff',
  `phone_number` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `phone_number`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'McCoy Neoda', 'mccoy@gmail.com', NULL, '$2y$12$gd7D..7CnULMThcJJ4LdqudZOq7DlssgeWUJ7oF/4C7AxZtOgmoJi', 'admin', NULL, 1, NULL, '2026-05-03 08:14:48', '2026-05-03 08:14:48'),
(3, 'Nessiah Presores', 'siah@gmail.com', NULL, '$2y$12$YmXafhUeLU1hiWJA4Z8Mme5IQDY7/3djJwgv0lm8Lidk1h6RoeuaK', 'receptionist', '09678080202', 1, NULL, '2026-05-03 09:04:39', '2026-05-03 09:04:39'),
(4, 'Bella Samantha', 'bella@gmail.com', NULL, '$2y$12$7zRqnpITpajaw9AExqPv7eFvl5/Zcmzs0IKEatrmolvapfQyPVtl2', 'veterinarian', '09678080202', 1, NULL, '2026-05-03 13:14:18', '2026-05-03 13:14:18'),
(5, 'Sally Nioda', 'sally@gmail.com', NULL, '$2y$12$cxrj8HybQGYvAXdwzbr.feqMAWj1TIN8QRNk2mSByb2wkHsS0mPaW', 'vet_nurse', '09630380020', 1, NULL, '2026-05-08 00:41:40', '2026-05-08 00:41:40'),
(6, 'Sam Nioda', 'sam@gmail.com', NULL, '$2y$12$AnXwyJBIP.iIXoLaWh.uKe.EhDPErsO/iuWNiZoigmnQpW1xRQ.vK', 'groomer', '09108040600', 1, NULL, '2026-05-10 14:55:23', '2026-05-10 14:55:23'),
(7, 'Annabelle', 'belle@gmail.com', NULL, '$2y$12$NUghzyTvOZ3J2XPwAm3uquVyfBBzhdKxpuKtIythCb2DXRgjmnyGy', 'vet_assistant', '09638002332', 1, NULL, '2026-05-10 14:56:27', '2026-05-10 14:56:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `appointments_customer_id_foreign` (`customer_id`),
  ADD KEY `appointments_pet_id_foreign` (`pet_id`),
  ADD KEY `appointments_veterinarian_id_foreign` (`veterinarian_id`),
  ADD KEY `appointments_created_by_foreign` (`created_by`);

--
-- Indexes for table `appointment_status_histories`
--
ALTER TABLE `appointment_status_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `appointment_status_histories_changed_by_foreign` (`changed_by`),
  ADD KEY `appointment_status_histories_appointment_id_changed_at_index` (`appointment_id`,`changed_at`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `customers_email_unique` (`email`),
  ADD KEY `customers_registered_by_foreign` (`registered_by`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pets`
--
ALTER TABLE `pets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pets_customer_id_foreign` (`customer_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `appointment_status_histories`
--
ALTER TABLE `appointment_status_histories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `pets`
--
ALTER TABLE `pets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `appointments_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_pet_id_foreign` FOREIGN KEY (`pet_id`) REFERENCES `pets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_veterinarian_id_foreign` FOREIGN KEY (`veterinarian_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `appointment_status_histories`
--
ALTER TABLE `appointment_status_histories`
  ADD CONSTRAINT `appointment_status_histories_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_status_histories_changed_by_foreign` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_registered_by_foreign` FOREIGN KEY (`registered_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pets`
--
ALTER TABLE `pets`
  ADD CONSTRAINT `pets_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
