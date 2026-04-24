/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: admins
# ------------------------------------------------------------

DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `company_name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `profile_pic` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE = InnoDB AUTO_INCREMENT = 42 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: announcement_seen
# ------------------------------------------------------------

DROP TABLE IF EXISTS `announcement_seen`;
CREATE TABLE `announcement_seen` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `announcement_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT 0,
  `role` varchar(20) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `seen_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1207 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: announcements
# ------------------------------------------------------------

DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `added_by` int(11) NOT NULL,
  `who_added` enum('ADMIN', 'USER', 'OWNER') NOT NULL,
  `role_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 74 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: member_requests
# ------------------------------------------------------------

DROP TABLE IF EXISTS `member_requests`;
CREATE TABLE `member_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `profile_pic` varchar(255) DEFAULT NULL,
  `created_by` varchar(11) DEFAULT NULL,
  `status` enum('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `request_type` enum('ADD', 'DELETE') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  KEY `role_id` (`role_id`),
  KEY `requested_by` (`requested_by`),
  CONSTRAINT `member_requests_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_requests_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_requests_ibfk_3` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 87 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: roles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `team_id` int(11) DEFAULT NULL,
  `role_name` varchar(100) NOT NULL,
  `control_type` enum('ADMIN', 'PARTIAL', 'NONE', 'OWNER') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  KEY `fk_role_team` (`team_id`),
  CONSTRAINT `fk_role_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `roles_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 65 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: sessions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tasks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tasks`;
CREATE TABLE `tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `priority` enum('HIGH', 'MEDIUM', 'LOW') NOT NULL,
  `due_date` datetime DEFAULT NULL,
  `assigned_to` int(11) NOT NULL,
  `assigned_by` int(11) NOT NULL,
  `who_assigned` varchar(11) NOT NULL,
  `section` enum('TASK', 'CHANGES', 'UPDATE', 'OTHERS') DEFAULT 'TASK',
  `status` enum('OPEN', 'COMPLETED') DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `assigned_by` (`assigned_by`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1488 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: teams
# ------------------------------------------------------------

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `teams_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 18 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `profile_pic` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `status` enum('ACTIVE', 'PENDING', 'SUSPEND', '') DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `admin_id` (`admin_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE,
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 228 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: admins
# ------------------------------------------------------------

INSERT INTO
  `admins` (
    `id`,
    `name`,
    `company_name`,
    `email`,
    `phone`,
    `profile_pic`,
    `password`,
    `created_at`
  )
VALUES
  (
    34,
    'Jay',
    'yantra',
    'jay24632463@gmail.com',
    '1234567890',
    NULL,
    '$2b$10$cA6BN6njH/kZhUW435lNKug.TZCXtpkbNv5ZF1p.JgDU4c5oUeBLy',
    '2026-03-10 11:11:09'
  );
INSERT INTO
  `admins` (
    `id`,
    `name`,
    `company_name`,
    `email`,
    `phone`,
    `profile_pic`,
    `password`,
    `created_at`
  )
VALUES
  (
    35,
    'Dilip',
    'The Designs Live',
    'Social.Designs.live@gmail.com',
    '9624472763',
    NULL,
    '$2b$10$PskrxZdGDxTDpsS4X0wmmuaIWaA.NKALpX6iN/tP1uzHs1r.cbtHS',
    '2026-03-11 03:31:27'
  );
INSERT INTO
  `admins` (
    `id`,
    `name`,
    `company_name`,
    `email`,
    `phone`,
    `profile_pic`,
    `password`,
    `created_at`
  )
VALUES
  (
    36,
    'Kanzariya Rajdeep',
    'demo',
    'rajdeepkanzariya054@gmail.com',
    '1234567890',
    '1773290955398_a7736522e110615d7e917b5de7a3890a.jpg',
    '$2b$10$UWO8TfIcE4dnOkastE6BnOKxSjUBLCpCgnapC8Ex.hikvKDESMMcW',
    '2026-03-11 09:14:59'
  );
INSERT INTO
  `admins` (
    `id`,
    `name`,
    `company_name`,
    `email`,
    `phone`,
    `profile_pic`,
    `password`,
    `created_at`
  )
VALUES
  (
    37,
    'Sweta Dhanani',
    'DigiRivera',
    'swetadhanani28@gmail.com',
    '6354174710',
    '1776661745890.JPG',
    '$2b$10$zLAeGtP1FO5544uug5nnSeKT3m6EQEDgxOUWPdpo4hohjMhnE4TA.',
    '2026-04-20 05:09:06'
  );
INSERT INTO
  `admins` (
    `id`,
    `name`,
    `company_name`,
    `email`,
    `phone`,
    `profile_pic`,
    `password`,
    `created_at`
  )
VALUES
  (
    39,
    'Sweta Dhanani',
    'DigiRivera',
    'digiriverainfo@gmail.com',
    '6354174710',
    '1776661861645.JPG',
    '$2b$10$betRMHi9T2y7lZw4xb9E1OFI3ENfmrMMTJfY4UvaF8UHaY73Fddgi',
    '2026-04-20 05:11:01'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: announcement_seen
# ------------------------------------------------------------

INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1, 54, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (2, 55, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (3, 56, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (4, 53, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (5, 50, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (6, 51, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (7, 52, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (8, 49, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (9, 48, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (10, 47, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (11, 46, 0, 'admin', 34, '2026-03-16 05:46:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (12, 57, 64, 'user', 34, '2026-03-16 05:47:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (13, 57, 0, 'admin', 34, '2026-03-16 05:47:37');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (14, 57, 64, 'user', 34, '2026-03-16 05:47:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (15, 58, 0, 'admin', 34, '2026-03-16 06:13:27');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (16, 57, 0, 'admin', 34, '2026-03-16 06:13:27');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (17, 58, 63, 'user', 34, '2026-03-16 06:13:41');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (18, 57, 63, 'user', 34, '2026-03-16 06:13:41');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (19, 58, 0, 'admin', 34, '2026-03-16 06:14:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (20, 57, 0, 'admin', 34, '2026-03-16 06:14:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (21, 58, 0, 'admin', 34, '2026-03-16 06:14:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (22, 57, 0, 'admin', 34, '2026-03-16 06:14:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (23, 58, 0, 'admin', 34, '2026-03-16 06:14:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (24, 57, 0, 'admin', 34, '2026-03-16 06:14:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (25, 58, 0, 'admin', 34, '2026-03-16 06:14:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (26, 57, 0, 'admin', 34, '2026-03-16 06:14:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (27, 59, 0, 'admin', 34, '2026-03-16 06:15:09');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (28, 59, 63, 'user', 34, '2026-03-16 06:15:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (29, 58, 63, 'user', 34, '2026-03-16 06:15:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (30, 57, 63, 'user', 34, '2026-03-16 06:15:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (31, 59, 63, 'user', 34, '2026-03-16 06:15:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (32, 58, 63, 'user', 34, '2026-03-16 06:15:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (33, 57, 63, 'user', 34, '2026-03-16 06:15:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (34, 60, 0, 'admin', 34, '2026-03-16 06:15:27');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (35, 60, 63, 'user', 34, '2026-03-16 06:15:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (36, 59, 63, 'user', 34, '2026-03-16 06:15:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (37, 58, 63, 'user', 34, '2026-03-16 06:15:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (38, 57, 63, 'user', 34, '2026-03-16 06:15:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (39, 61, 0, 'admin', 34, '2026-03-16 06:15:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (40, 61, 63, 'user', 34, '2026-03-16 06:16:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (41, 60, 63, 'user', 34, '2026-03-16 06:16:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (42, 59, 63, 'user', 34, '2026-03-16 06:16:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (43, 58, 63, 'user', 34, '2026-03-16 06:16:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (44, 57, 63, 'user', 34, '2026-03-16 06:16:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (45, 44, 79, 'user', 35, '2026-03-16 06:41:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (46, 44, 75, 'user', 35, '2026-03-16 07:00:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (47, 61, 64, 'user', 34, '2026-03-16 07:01:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (48, 60, 64, 'user', 34, '2026-03-16 07:01:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (49, 59, 64, 'user', 34, '2026-03-16 07:01:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (50, 58, 64, 'user', 34, '2026-03-16 07:01:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (51, 57, 64, 'user', 34, '2026-03-16 07:01:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (52, 44, 75, 'user', 35, '2026-03-16 07:03:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (53, 61, 0, 'admin', 34, '2026-03-16 07:55:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (54, 60, 0, 'admin', 34, '2026-03-16 07:55:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (55, 59, 0, 'admin', 34, '2026-03-16 07:55:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (56, 58, 0, 'admin', 34, '2026-03-16 07:55:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (57, 57, 0, 'admin', 34, '2026-03-16 07:55:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (58, 61, 63, 'user', 34, '2026-03-16 07:55:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (59, 60, 63, 'user', 34, '2026-03-16 07:55:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (60, 59, 63, 'user', 34, '2026-03-16 07:55:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (61, 58, 63, 'user', 34, '2026-03-16 07:55:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (62, 57, 63, 'user', 34, '2026-03-16 07:55:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (63, 61, 63, 'user', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (64, 60, 63, 'user', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (65, 59, 63, 'user', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (66, 58, 63, 'user', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (67, 57, 63, 'user', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (68, 61, 0, 'admin', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (69, 60, 0, 'admin', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (70, 59, 0, 'admin', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (71, 58, 0, 'admin', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (72, 57, 0, 'admin', 34, '2026-03-16 07:55:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (73, 61, 0, 'admin', 34, '2026-03-16 07:56:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (74, 60, 0, 'admin', 34, '2026-03-16 07:56:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (75, 59, 0, 'admin', 34, '2026-03-16 07:56:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (76, 58, 0, 'admin', 34, '2026-03-16 07:56:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (77, 57, 0, 'admin', 34, '2026-03-16 07:56:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (78, 61, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (79, 60, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (80, 59, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (81, 58, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (82, 57, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (83, 61, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (84, 60, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (85, 59, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (86, 58, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (87, 57, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (88, 61, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (89, 60, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (90, 59, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (91, 58, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (92, 57, 63, 'user', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (93, 61, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (94, 60, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (95, 59, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (96, 58, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (97, 57, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (98, 61, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (99, 60, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (100, 59, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (101, 58, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (102, 57, 0, 'admin', 34, '2026-03-16 07:56:22');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (103, 61, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (104, 60, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (105, 59, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (106, 58, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (107, 57, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (108, 61, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (109, 60, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (110, 59, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (111, 58, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (112, 57, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (113, 61, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (114, 60, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (115, 59, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (116, 58, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (117, 57, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (118, 61, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (119, 60, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (120, 59, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (121, 58, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (122, 57, 0, 'admin', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (123, 61, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (124, 60, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (125, 59, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (126, 58, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (127, 57, 63, 'user', 34, '2026-03-16 07:56:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (128, 61, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (129, 61, 63, 'user', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (130, 60, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (131, 60, 63, 'user', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (132, 59, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (133, 59, 63, 'user', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (134, 58, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (135, 58, 63, 'user', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (136, 57, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (137, 57, 63, 'user', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (138, 61, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (139, 60, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (140, 59, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (141, 58, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (142, 57, 0, 'admin', 34, '2026-03-16 07:56:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (143, 61, 0, 'admin', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (144, 60, 0, 'admin', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (145, 59, 0, 'admin', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (146, 58, 0, 'admin', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (147, 57, 0, 'admin', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (148, 61, 63, 'user', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (149, 60, 63, 'user', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (150, 59, 63, 'user', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (151, 58, 63, 'user', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (152, 57, 63, 'user', 34, '2026-03-16 07:56:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (153, 61, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (154, 60, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (155, 59, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (156, 58, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (157, 57, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (158, 61, 63, 'user', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (159, 60, 63, 'user', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (160, 59, 63, 'user', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (161, 58, 63, 'user', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (162, 57, 63, 'user', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (163, 61, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (164, 60, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (165, 59, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (166, 58, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (167, 57, 0, 'admin', 34, '2026-03-16 07:56:58');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (168, 61, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (169, 60, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (170, 59, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (171, 58, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (172, 61, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (173, 57, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (174, 60, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (175, 59, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (176, 58, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (177, 57, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (178, 61, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (179, 60, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (180, 59, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (181, 58, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (182, 57, 63, 'user', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (183, 61, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (184, 60, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (185, 59, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (186, 58, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (187, 57, 0, 'admin', 34, '2026-03-16 07:57:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (188, 61, 63, 'user', 34, '2026-03-16 07:57:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (189, 60, 63, 'user', 34, '2026-03-16 07:57:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (190, 59, 63, 'user', 34, '2026-03-16 07:57:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (191, 58, 63, 'user', 34, '2026-03-16 07:57:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (192, 57, 63, 'user', 34, '2026-03-16 07:57:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (193, 61, 63, 'user', 34, '2026-03-16 08:07:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (194, 60, 63, 'user', 34, '2026-03-16 08:07:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (195, 59, 63, 'user', 34, '2026-03-16 08:07:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (196, 58, 63, 'user', 34, '2026-03-16 08:07:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (197, 57, 63, 'user', 34, '2026-03-16 08:07:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (198, 61, 0, 'admin', 34, '2026-03-16 08:28:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (199, 60, 0, 'admin', 34, '2026-03-16 08:28:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (200, 59, 0, 'admin', 34, '2026-03-16 08:28:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (201, 58, 0, 'admin', 34, '2026-03-16 08:28:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (202, 57, 0, 'admin', 34, '2026-03-16 08:28:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (203, 61, 0, 'admin', 34, '2026-03-16 09:52:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (204, 60, 0, 'admin', 34, '2026-03-16 09:52:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (205, 59, 0, 'admin', 34, '2026-03-16 09:52:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (206, 58, 0, 'admin', 34, '2026-03-16 09:52:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (207, 57, 0, 'admin', 34, '2026-03-16 09:52:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (208, 61, 0, 'admin', 34, '2026-03-16 09:52:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (209, 60, 0, 'admin', 34, '2026-03-16 09:52:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (210, 59, 0, 'admin', 34, '2026-03-16 09:52:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (211, 58, 0, 'admin', 34, '2026-03-16 09:52:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (212, 57, 0, 'admin', 34, '2026-03-16 09:52:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (213, 61, 64, 'user', 34, '2026-03-16 09:52:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (214, 60, 64, 'user', 34, '2026-03-16 09:52:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (215, 59, 64, 'user', 34, '2026-03-16 09:52:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (216, 58, 64, 'user', 34, '2026-03-16 09:52:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (217, 57, 64, 'user', 34, '2026-03-16 09:52:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (218, 62, 64, 'user', 34, '2026-03-16 09:52:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (219, 62, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (220, 61, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (221, 60, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (222, 59, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (223, 58, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (224, 57, 0, 'admin', 34, '2026-03-16 09:52:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (225, 63, 64, 'user', 34, '2026-03-16 09:53:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (226, 63, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (227, 62, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (228, 61, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (229, 60, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (230, 59, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (231, 58, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (232, 57, 0, 'admin', 34, '2026-03-16 09:53:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (233, 64, 64, 'user', 34, '2026-03-16 09:53:24');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (234, 64, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (235, 63, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (236, 62, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (237, 61, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (238, 60, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (239, 59, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (240, 58, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (241, 57, 0, 'admin', 34, '2026-03-16 09:53:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (242, 65, 64, 'user', 34, '2026-03-16 09:53:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (243, 65, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (244, 64, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (245, 63, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (246, 62, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (247, 61, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (248, 60, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (249, 59, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (250, 58, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (251, 57, 0, 'admin', 34, '2026-03-16 09:53:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (252, 44, 65, 'user', 35, '2026-03-16 10:28:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (253, 44, 65, 'user', 35, '2026-03-16 10:52:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (254, 44, 70, 'user', 35, '2026-03-16 12:32:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (255, 44, 65, 'user', 35, '2026-03-17 03:19:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (256, 44, 69, 'user', 35, '2026-03-17 03:47:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (257, 44, 66, 'user', 35, '2026-03-17 03:48:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (258, 44, 71, 'user', 35, '2026-03-17 03:49:26');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (259, 44, 75, 'user', 35, '2026-03-17 05:46:27');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (260, 44, 0, 'admin', 35, '2026-03-17 06:00:41');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (261, 44, 0, 'admin', 35, '2026-03-17 06:01:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (262, 44, 67, 'user', 35, '2026-03-17 06:49:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (263, 44, 67, 'user', 35, '2026-03-17 06:50:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (264, 65, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (265, 64, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (266, 63, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (267, 62, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (268, 61, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (269, 60, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (270, 59, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (271, 58, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (272, 57, 0, 'admin', 34, '2026-03-17 09:42:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (273, 65, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (274, 64, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (275, 63, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (276, 62, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (277, 61, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (278, 60, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (279, 59, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (280, 58, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (281, 57, 0, 'admin', 34, '2026-03-17 10:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (282, 66, 0, 'admin', 34, '2026-03-17 10:10:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (283, 67, 0, 'admin', 34, '2026-03-17 10:10:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (284, 68, 0, 'admin', 34, '2026-03-17 10:10:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (285, 68, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (286, 67, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (287, 66, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (288, 65, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (289, 64, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (290, 63, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (291, 62, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (292, 61, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (293, 60, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (294, 59, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (295, 58, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (296, 57, 0, 'admin', 34, '2026-03-17 10:10:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (297, 68, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (298, 67, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (299, 66, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (300, 65, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (301, 64, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (302, 63, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (303, 62, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (304, 61, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (305, 58, 0, 'admin', 34, '2026-03-17 10:11:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (306, 57, 0, 'admin', 34, '2026-03-17 10:11:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (307, 69, 0, 'admin', 34, '2026-03-17 10:11:25');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (308, 70, 0, 'admin', 34, '2026-03-17 10:11:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (309, 70, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (310, 69, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (311, 68, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (312, 67, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (313, 66, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (314, 65, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (315, 64, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (316, 63, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (317, 62, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (318, 61, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (319, 58, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (320, 57, 0, 'admin', 34, '2026-03-17 10:11:33');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (321, 70, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (322, 69, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (323, 68, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (324, 67, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (325, 66, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (326, 65, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (327, 64, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (328, 63, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (329, 62, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (330, 61, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (331, 58, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (332, 57, 0, 'admin', 34, '2026-03-17 10:39:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (333, 44, 71, 'user', 35, '2026-03-18 03:31:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (334, 44, 66, 'user', 35, '2026-03-18 04:10:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (335, 44, 66, 'user', 35, '2026-03-18 04:14:36');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (336, 44, 70, 'user', 35, '2026-03-18 06:09:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (337, 44, 73, 'user', 35, '2026-03-18 06:23:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (338, 44, 70, 'user', 35, '2026-03-18 06:38:09');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (339, 70, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (340, 69, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (341, 68, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (342, 67, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (343, 66, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (344, 65, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (345, 64, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (346, 63, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (347, 62, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (348, 61, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (349, 58, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (350, 57, 64, 'user', 34, '2026-03-18 07:02:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (351, 70, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (352, 69, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (353, 68, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (354, 67, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (355, 66, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (356, 65, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (357, 64, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (358, 63, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (359, 62, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (360, 61, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (361, 58, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (362, 57, 64, 'user', 34, '2026-03-18 07:06:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (363, 44, 68, 'user', 35, '2026-03-18 08:29:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (364, 44, 0, 'admin', 35, '2026-03-18 10:39:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (365, 44, 0, 'admin', 35, '2026-03-18 12:10:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (366, 71, 0, 'admin', 35, '2026-03-18 12:10:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (367, 71, 67, 'user', 35, '2026-03-18 12:39:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (368, 44, 67, 'user', 35, '2026-03-18 12:39:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (369, 71, 67, 'user', 35, '2026-03-18 12:39:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (370, 44, 67, 'user', 35, '2026-03-18 12:39:51');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (371, 71, 66, 'user', 35, '2026-03-18 13:17:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (372, 44, 66, 'user', 35, '2026-03-18 13:17:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (373, 70, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (374, 69, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (375, 68, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (376, 67, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (377, 66, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (378, 65, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (379, 64, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (380, 63, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (381, 62, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (382, 61, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (383, 58, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (384, 57, 0, 'admin', 34, '2026-03-18 17:59:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (385, 70, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (386, 69, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (387, 68, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (388, 67, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (389, 66, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (390, 65, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (391, 64, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (392, 63, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (393, 62, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (394, 57, 0, 'admin', 34, '2026-03-18 18:00:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (395, 70, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (396, 69, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (397, 68, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (398, 67, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (399, 66, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (400, 65, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (401, 64, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (402, 63, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (403, 62, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (404, 57, 0, 'admin', 34, '2026-03-18 18:00:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (405, 71, 66, 'user', 35, '2026-03-19 03:31:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (406, 44, 66, 'user', 35, '2026-03-19 03:31:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (407, 71, 67, 'user', 35, '2026-03-19 04:30:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (408, 44, 67, 'user', 35, '2026-03-19 04:30:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (409, 71, 65, 'user', 35, '2026-03-19 04:40:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (410, 44, 65, 'user', 35, '2026-03-19 04:40:44');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (411, 71, 69, 'user', 35, '2026-03-19 04:51:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (412, 44, 69, 'user', 35, '2026-03-19 04:51:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (413, 71, 75, 'user', 35, '2026-03-19 05:13:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (414, 44, 75, 'user', 35, '2026-03-19 05:13:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (415, 71, 69, 'user', 35, '2026-03-19 05:15:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (416, 44, 69, 'user', 35, '2026-03-19 05:15:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (417, 71, 0, 'admin', 35, '2026-03-19 05:19:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (418, 44, 0, 'admin', 35, '2026-03-19 05:19:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (419, 70, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (420, 69, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (421, 68, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (422, 67, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (423, 66, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (424, 65, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (425, 64, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (426, 63, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (427, 62, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (428, 57, 0, 'admin', 34, '2026-03-19 06:59:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (429, 70, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (430, 69, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (431, 68, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (432, 67, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (433, 66, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (434, 65, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (435, 64, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (436, 63, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (437, 62, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (438, 57, 62, 'user', 34, '2026-03-19 08:06:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (439, 70, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (440, 69, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (441, 68, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (442, 67, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (443, 66, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (444, 65, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (445, 64, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (446, 63, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (447, 62, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (448, 57, 62, 'user', 34, '2026-03-19 08:06:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (449, 71, 0, 'admin', 35, '2026-03-19 08:09:05');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (450, 44, 0, 'admin', 35, '2026-03-19 08:09:05');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (451, 70, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (452, 69, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (453, 68, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (454, 67, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (455, 66, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (456, 65, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (457, 64, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (458, 63, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (459, 62, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (460, 57, 62, 'user', 34, '2026-03-19 09:10:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (461, 71, 70, 'user', 35, '2026-03-19 09:44:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (462, 44, 70, 'user', 35, '2026-03-19 09:44:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (463, 71, 71, 'user', 35, '2026-03-20 06:22:36');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (464, 44, 71, 'user', 35, '2026-03-20 06:22:36');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (465, 70, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (466, 69, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (467, 68, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (468, 67, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (469, 66, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (470, 65, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (471, 64, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (472, 63, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (473, 62, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (474, 57, 62, 'user', 34, '2026-03-21 03:39:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (475, 70, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (476, 69, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (477, 68, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (478, 67, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (479, 66, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (480, 65, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (481, 64, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (482, 63, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (483, 62, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (484, 57, 0, 'admin', 34, '2026-03-21 08:28:20');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (485, 70, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (486, 69, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (487, 68, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (488, 67, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (489, 66, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (490, 65, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (491, 64, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (492, 63, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (493, 62, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (494, 57, 0, 'admin', 34, '2026-03-21 08:28:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (495, 71, 75, 'user', 35, '2026-03-21 09:14:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (496, 44, 75, 'user', 35, '2026-03-21 09:14:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (497, 71, 73, 'user', 35, '2026-03-23 04:31:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (498, 44, 73, 'user', 35, '2026-03-23 04:31:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (499, 71, 70, 'user', 35, '2026-03-23 04:32:36');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (500, 44, 70, 'user', 35, '2026-03-23 04:32:36');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (501, 71, 0, 'admin', 35, '2026-03-23 04:33:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (502, 44, 0, 'admin', 35, '2026-03-23 04:33:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (503, 72, 0, 'admin', 35, '2026-04-02 06:35:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (504, 72, 68, 'user', 35, '2026-04-02 06:35:05');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (505, 72, 65, 'user', 35, '2026-04-02 06:35:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (506, 72, 66, 'user', 35, '2026-04-02 06:54:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (507, 72, 66, 'user', 35, '2026-04-02 06:54:43');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (508, 72, 66, 'user', 35, '2026-04-03 03:41:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (509, 72, 71, 'user', 35, '2026-04-03 10:51:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (510, 72, 71, 'user', 35, '2026-04-03 10:52:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (511, 72, 69, 'user', 35, '2026-04-03 11:21:28');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (512, 72, 0, 'admin', 35, '2026-04-04 04:52:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (513, 72, 68, 'user', 35, '2026-04-04 04:53:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (514, 70, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (515, 69, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (516, 68, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (517, 67, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (518, 66, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (519, 65, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (520, 64, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (521, 63, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (522, 62, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (523, 57, 63, 'user', 34, '2026-04-10 06:09:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (524, 70, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (525, 69, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (526, 68, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (527, 67, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (528, 66, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (529, 65, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (530, 64, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (531, 63, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (532, 62, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (533, 57, 63, 'user', 34, '2026-04-10 06:14:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (534, 70, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (535, 69, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (536, 68, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (537, 67, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (538, 66, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (539, 65, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (540, 64, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (541, 63, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (542, 62, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (543, 57, 63, 'user', 34, '2026-04-10 06:28:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (544, 70, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (545, 69, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (546, 68, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (547, 67, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (548, 66, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (549, 65, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (550, 64, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (551, 63, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (552, 62, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (553, 57, 82, 'user', 34, '2026-04-11 04:24:53');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (554, 70, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (555, 69, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (556, 68, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (557, 67, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (558, 66, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (559, 65, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (560, 64, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (561, 63, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (562, 62, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (563, 57, 0, 'admin', 34, '2026-04-11 04:32:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (564, 70, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (565, 69, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (566, 68, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (567, 67, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (568, 66, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (569, 65, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (570, 64, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (571, 63, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (572, 62, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (573, 57, 0, 'admin', 34, '2026-04-11 04:34:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (574, 70, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (575, 69, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (576, 68, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (577, 67, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (578, 66, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (579, 65, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (580, 64, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (581, 63, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (582, 62, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (583, 57, 0, 'admin', 34, '2026-04-11 04:36:07');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (584, 70, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (585, 69, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (586, 68, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (587, 67, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (588, 66, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (589, 65, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (590, 64, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (591, 63, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (592, 62, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (593, 57, 0, 'admin', 34, '2026-04-11 04:36:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (594, 70, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (595, 69, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (596, 68, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (597, 67, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (598, 66, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (599, 65, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (600, 64, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (601, 63, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (602, 62, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (603, 57, 0, 'admin', 34, '2026-04-11 04:44:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (604, 70, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (605, 69, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (606, 68, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (607, 67, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (608, 66, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (609, 65, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (610, 64, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (611, 63, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (612, 62, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (613, 57, 0, 'admin', 34, '2026-04-11 06:05:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (614, 70, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (615, 69, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (616, 68, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (617, 67, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (618, 66, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (619, 65, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (620, 64, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (621, 63, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (622, 62, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (623, 57, 0, 'admin', 34, '2026-04-11 06:11:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (624, 70, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (625, 69, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (626, 68, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (627, 67, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (628, 66, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (629, 65, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (630, 64, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (631, 63, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (632, 62, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (633, 57, 0, 'admin', 34, '2026-04-11 06:11:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (634, 70, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (635, 69, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (636, 68, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (637, 67, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (638, 66, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (639, 65, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (640, 64, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (641, 63, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (642, 62, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (643, 57, 0, 'admin', 34, '2026-04-12 05:04:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (644, 70, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (645, 69, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (646, 68, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (647, 67, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (648, 66, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (649, 65, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (650, 64, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (651, 63, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (652, 62, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (653, 57, 0, 'owner', 34, '2026-04-13 04:15:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (654, 70, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (655, 69, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (656, 68, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (657, 67, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (658, 66, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (659, 65, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (660, 64, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (661, 63, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (662, 62, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (663, 57, 0, 'owner', 34, '2026-04-13 04:15:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (664, 70, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (665, 69, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (666, 68, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (667, 67, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (668, 66, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (669, 65, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (670, 64, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (671, 63, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (672, 62, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (673, 57, 0, 'admin', 34, '2026-04-13 04:20:46');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (674, 70, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (675, 69, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (676, 68, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (677, 67, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (678, 66, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (679, 65, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (680, 64, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (681, 63, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (682, 62, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (683, 57, 0, 'owner', 34, '2026-04-13 04:20:55');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (684, 70, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (685, 69, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (686, 68, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (687, 67, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (688, 66, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (689, 65, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (690, 64, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (691, 63, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (692, 62, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (693, 57, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (694, 70, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (695, 69, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (696, 68, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (697, 67, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (698, 66, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (699, 65, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (700, 64, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (701, 63, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (702, 62, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (703, 57, 0, 'admin', 34, '2026-04-13 04:20:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (704, 70, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (705, 69, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (706, 68, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (707, 67, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (708, 66, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (709, 65, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (710, 64, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (711, 63, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (712, 62, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (713, 57, 0, 'owner', 34, '2026-04-13 04:21:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (714, 70, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (715, 69, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (716, 68, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (717, 67, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (718, 66, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (719, 65, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (720, 64, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (721, 63, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (722, 62, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (723, 57, 0, 'admin', 34, '2026-04-13 04:21:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (724, 70, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (725, 69, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (726, 68, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (727, 67, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (728, 66, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (729, 65, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (730, 64, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (731, 63, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (732, 62, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (733, 57, 0, 'owner', 34, '2026-04-13 04:22:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (734, 70, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (735, 69, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (736, 68, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (737, 67, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (738, 66, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (739, 65, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (740, 64, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (741, 63, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (742, 62, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (743, 57, 0, 'owner', 34, '2026-04-13 04:25:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (744, 70, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (745, 69, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (746, 68, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (747, 67, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (748, 66, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (749, 65, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (750, 64, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (751, 63, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (752, 62, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (753, 57, 0, 'admin', 34, '2026-04-13 04:26:08');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (754, 70, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (755, 69, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (756, 68, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (757, 67, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (758, 66, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (759, 65, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (760, 64, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (761, 63, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (762, 62, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (763, 57, 83, 'user', 34, '2026-04-13 04:26:30');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (764, 70, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (765, 69, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (766, 68, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (767, 67, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (768, 66, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (769, 65, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (770, 64, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (771, 63, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (772, 62, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (773, 57, 0, 'owner', 34, '2026-04-13 04:30:38');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (774, 70, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (775, 69, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (776, 68, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (777, 67, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (778, 66, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (779, 65, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (780, 64, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (781, 63, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (782, 62, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (783, 57, 83, 'user', 34, '2026-04-13 04:39:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (784, 70, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (785, 69, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (786, 68, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (787, 67, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (788, 66, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (789, 65, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (790, 64, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (791, 63, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (792, 62, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (793, 57, 0, 'owner', 34, '2026-04-13 04:50:03');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (794, 70, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (795, 69, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (796, 68, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (797, 67, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (798, 66, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (799, 65, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (800, 64, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (801, 63, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (802, 62, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (803, 57, 0, 'owner', 34, '2026-04-13 04:51:47');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (804, 70, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (805, 69, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (806, 68, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (807, 67, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (808, 66, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (809, 65, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (810, 64, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (811, 63, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (812, 62, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (813, 57, 0, 'owner', 34, '2026-04-13 05:08:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (814, 70, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (815, 69, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (816, 68, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (817, 67, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (818, 66, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (819, 65, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (820, 64, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (821, 63, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (822, 62, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (823, 57, 0, 'admin', 34, '2026-04-13 05:13:14');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (824, 70, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (825, 69, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (826, 68, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (827, 67, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (828, 66, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (829, 65, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (830, 64, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (831, 63, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (832, 62, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (833, 57, 0, 'owner', 34, '2026-04-13 05:23:57');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (834, 70, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (835, 69, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (836, 68, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (837, 67, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (838, 66, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (839, 65, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (840, 64, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (841, 63, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (842, 62, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (843, 57, 0, 'admin', 34, '2026-04-13 05:24:48');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (844, 70, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (845, 69, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (846, 68, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (847, 67, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (848, 66, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (849, 65, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (850, 64, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (851, 63, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (852, 62, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (853, 57, 0, 'admin', 34, '2026-04-13 05:42:29');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (854, 70, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (855, 69, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (856, 68, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (857, 67, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (858, 66, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (859, 65, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (860, 64, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (861, 63, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (862, 62, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (863, 57, 0, 'admin', 34, '2026-04-13 08:44:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (864, 70, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (865, 69, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (866, 68, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (867, 67, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (868, 66, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (869, 65, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (870, 64, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (871, 63, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (872, 62, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (873, 57, 0, 'admin', 34, '2026-04-13 08:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (874, 70, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (875, 69, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (876, 68, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (877, 67, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (878, 66, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (879, 65, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (880, 64, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (881, 63, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (882, 62, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (883, 57, 0, 'admin', 34, '2026-04-13 08:45:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (884, 70, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (885, 69, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (886, 68, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (887, 67, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (888, 66, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (889, 65, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (890, 64, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (891, 63, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (892, 62, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (893, 57, 0, 'admin', 34, '2026-04-13 08:45:45');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (894, 70, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (895, 69, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (896, 68, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (897, 67, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (898, 66, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (899, 65, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (900, 64, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (901, 63, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (902, 62, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (903, 57, 0, 'admin', 34, '2026-04-13 08:45:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (904, 70, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (905, 69, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (906, 68, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (907, 67, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (908, 66, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (909, 65, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (910, 64, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (911, 63, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (912, 62, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (913, 57, 0, 'admin', 34, '2026-04-13 08:46:13');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (914, 70, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (915, 69, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (916, 68, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (917, 67, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (918, 66, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (919, 65, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (920, 64, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (921, 63, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (922, 62, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (923, 57, 0, 'admin', 34, '2026-04-15 05:44:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (924, 70, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (925, 69, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (926, 68, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (927, 67, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (928, 66, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (929, 65, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (930, 64, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (931, 63, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (932, 62, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (933, 57, 0, 'admin', 34, '2026-04-15 05:44:56');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (934, 70, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (935, 69, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (936, 68, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (937, 67, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (938, 66, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (939, 65, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (940, 64, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (941, 63, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (942, 62, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (943, 57, 0, 'admin', 34, '2026-04-15 05:45:10');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (944, 70, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (945, 69, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (946, 68, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (947, 67, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (948, 66, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (949, 65, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (950, 64, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (951, 63, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (952, 62, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (953, 57, 0, 'admin', 34, '2026-04-15 05:58:32');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (954, 70, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (955, 69, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (956, 68, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (957, 67, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (958, 66, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (959, 65, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (960, 64, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (961, 63, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (962, 62, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (963, 57, 0, 'admin', 34, '2026-04-15 05:58:34');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (964, 70, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (965, 69, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (966, 68, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (967, 67, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (968, 66, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (969, 65, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (970, 64, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (971, 63, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (972, 62, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (973, 57, 0, 'admin', 34, '2026-04-15 05:58:35');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (974, 70, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (975, 69, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (976, 68, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (977, 67, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (978, 66, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (979, 65, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (980, 64, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (981, 63, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (982, 62, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (983, 57, 0, 'admin', 34, '2026-04-15 06:01:02');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (984, 70, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (985, 69, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (986, 68, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (987, 67, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (988, 66, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (989, 65, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (990, 64, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (991, 63, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (992, 62, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (993, 57, 0, 'admin', 34, '2026-04-16 08:44:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (994, 70, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (995, 69, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (996, 68, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (997, 67, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (998, 66, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (999, 65, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1000, 64, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1001, 63, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1002, 62, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1003, 57, 0, 'admin', 34, '2026-04-16 08:50:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1004, 70, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1005, 69, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1006, 68, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1007, 67, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1008, 66, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1009, 65, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1010, 64, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1011, 63, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1012, 62, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1013, 57, 0, 'admin', 34, '2026-04-16 09:27:31');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1014, 70, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1015, 69, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1016, 68, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1017, 67, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1018, 66, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1019, 65, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1020, 64, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1021, 63, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1022, 62, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1023, 57, 0, 'admin', 34, '2026-04-16 11:25:21');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1024, 70, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1025, 69, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1026, 68, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1027, 67, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1028, 66, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1029, 65, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1030, 64, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1031, 63, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1032, 62, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1033, 57, 0, 'admin', 34, '2026-04-17 05:15:12');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1034, 73, 0, 'admin', 35, '2026-04-17 07:02:52');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1035, 73, 213, 'user', 35, '2026-04-17 07:04:01');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1036, 70, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1037, 69, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1038, 68, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1039, 67, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1040, 66, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1041, 65, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1042, 64, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1043, 63, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1044, 62, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1045, 57, 0, 'admin', 34, '2026-04-17 10:18:49');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1046, 70, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1047, 69, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1048, 68, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1049, 67, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1050, 66, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1051, 65, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1052, 64, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1053, 63, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1054, 62, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1055, 57, 0, 'admin', 34, '2026-04-17 10:19:00');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1056, 70, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1057, 69, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1058, 68, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1059, 67, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1060, 66, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1061, 65, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1062, 64, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1063, 63, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1064, 62, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1065, 57, 0, 'admin', 34, '2026-04-17 10:24:17');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1066, 70, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1067, 69, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1068, 68, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1069, 67, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1070, 66, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1071, 65, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1072, 64, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1073, 63, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1074, 62, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1075, 57, 0, 'admin', 34, '2026-04-17 10:24:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1076, 70, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1077, 69, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1078, 68, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1079, 67, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1080, 66, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1081, 65, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1082, 64, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1083, 63, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1084, 62, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1085, 57, 0, 'admin', 34, '2026-04-17 10:37:39');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1086, 70, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1087, 69, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1088, 68, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1089, 67, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1090, 66, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1091, 65, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1092, 64, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1093, 63, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1094, 62, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1095, 57, 0, 'admin', 34, '2026-04-17 10:37:54');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1096, 70, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1097, 69, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1098, 68, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1099, 67, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1100, 66, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1101, 65, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1102, 64, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1103, 63, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1104, 62, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1105, 57, 0, 'admin', 34, '2026-04-17 10:38:40');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1106, 70, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1107, 69, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1108, 68, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1109, 67, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1110, 66, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1111, 65, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1112, 64, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1113, 63, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1114, 62, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1115, 57, 0, 'admin', 34, '2026-04-17 10:39:15');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1116, 70, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1117, 69, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1118, 68, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1119, 67, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1120, 66, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1121, 65, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1122, 64, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1123, 63, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1124, 62, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1125, 57, 0, 'admin', 34, '2026-04-17 10:50:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1126, 70, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1127, 69, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1128, 68, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1129, 67, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1130, 66, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1131, 65, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1132, 64, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1133, 63, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1134, 62, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1135, 57, 0, 'admin', 34, '2026-04-17 10:50:18');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1136, 70, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1137, 69, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1138, 68, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1139, 67, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1140, 66, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1141, 65, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1142, 64, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1143, 63, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1144, 62, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1145, 57, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1146, 70, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1147, 69, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1148, 68, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1149, 67, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1150, 66, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1151, 65, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1152, 64, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1153, 63, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1154, 62, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1155, 57, 0, 'admin', 34, '2026-04-17 10:50:19');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1156, 70, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1157, 69, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1158, 68, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1159, 67, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1160, 66, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1161, 65, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1162, 64, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1163, 63, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1164, 62, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1165, 57, 0, 'admin', 34, '2026-04-17 10:50:42');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1166, 70, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1167, 69, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1168, 68, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1169, 67, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1170, 66, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1171, 65, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1172, 64, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1173, 63, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1174, 62, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1175, 57, 85, 'user', 34, '2026-04-20 08:03:50');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1176, 70, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1177, 69, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1178, 68, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1179, 67, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1180, 66, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1181, 65, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1182, 64, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1183, 63, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1184, 62, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1185, 57, 0, 'admin', 34, '2026-04-20 08:06:16');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1186, 70, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1187, 69, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1188, 68, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1189, 67, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1190, 66, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1191, 65, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1192, 64, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1193, 63, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1194, 62, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1195, 57, 0, 'admin', 34, '2026-04-20 08:06:23');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1196, 70, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1197, 69, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1198, 68, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1199, 67, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1200, 66, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1201, 65, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1202, 64, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1203, 63, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1204, 62, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1205, 57, 0, 'admin', 34, '2026-04-22 04:19:06');
INSERT INTO
  `announcement_seen` (
    `id`,
    `announcement_id`,
    `user_id`,
    `role`,
    `admin_id`,
    `seen_at`
  )
VALUES
  (1206, 73, 0, 'admin', 35, '2026-04-23 04:02:37');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: announcements
# ------------------------------------------------------------

INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    57,
    34,
    64,
    'USER',
    0,
    'f sd',
    'sdv',
    NULL,
    '2026-03-16 05:47:35'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    62,
    34,
    64,
    'USER',
    0,
    'fv',
    '',
    NULL,
    '2026-03-16 09:52:53'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    63,
    34,
    64,
    'USER',
    0,
    'sdv',
    '',
    NULL,
    '2026-03-16 09:53:06'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    64,
    34,
    64,
    'USER',
    0,
    'sfv',
    '',
    NULL,
    '2026-03-16 09:53:24'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    65,
    34,
    64,
    'USER',
    0,
    'ABCD',
    '',
    NULL,
    '2026-03-16 09:53:40'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    66,
    34,
    34,
    'ADMIN',
    0,
    'afasfsrggfdf',
    '',
    NULL,
    '2026-03-17 10:10:49'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    67,
    34,
    34,
    'ADMIN',
    0,
    'wrgsdg',
    '',
    NULL,
    '2026-03-17 10:10:52'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    68,
    34,
    34,
    'ADMIN',
    0,
    'rgefgd',
    '',
    NULL,
    '2026-03-17 10:10:56'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    69,
    34,
    34,
    'ADMIN',
    0,
    'th',
    '',
    NULL,
    '2026-03-17 10:11:25'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    70,
    34,
    34,
    'ADMIN',
    0,
    'tght',
    '',
    NULL,
    '2026-03-17 10:11:30'
  );
INSERT INTO
  `announcements` (
    `id`,
    `admin_id`,
    `added_by`,
    `who_added`,
    `role_id`,
    `title`,
    `description`,
    `attachment`,
    `created_at`
  )
VALUES
  (
    73,
    35,
    35,
    'ADMIN',
    50,
    'Meetin - 18 Apr',
    'dsfgfd fg fgh fgh dfgh fgh dfgh fgh fh dfgh',
    NULL,
    '2026-04-17 07:02:52'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: member_requests
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: roles
# ------------------------------------------------------------

INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    39,
    35,
    7,
    'Head Designer',
    'ADMIN',
    '2026-03-11 04:08:49'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    40,
    35,
    7,
    'Designer',
    'PARTIAL',
    '2026-03-11 04:08:57'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (41, 36, 2, 'demo', 'ADMIN', '2026-03-11 09:15:11');
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    42,
    35,
    NULL,
    'Devloper',
    'ADMIN',
    '2026-03-12 08:17:41'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    43,
    35,
    7,
    'Trainee Designer',
    'NONE',
    '2026-04-04 04:52:26'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    44,
    34,
    6,
    'Team Lead',
    'ADMIN',
    '2026-04-11 04:15:21'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    45,
    34,
    6,
    'Designer',
    'PARTIAL',
    '2026-04-11 04:15:31'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    46,
    34,
    6,
    'Design Trainee',
    'NONE',
    '2026-04-11 04:15:44'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (47, 35, 9, 'Owner', 'ADMIN', '2026-04-11 09:02:20');
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (48, 34, 10, 'Owner', 'OWNER', '2026-04-13 04:14:27');
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    55,
    39,
    15,
    'Co-Founder',
    'OWNER',
    '2026-04-20 05:19:02'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    56,
    39,
    16,
    'Sales Executive',
    'PARTIAL',
    '2026-04-20 05:20:00'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    57,
    39,
    17,
    'Meta Ads Head',
    'ADMIN',
    '2026-04-20 05:29:23'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    58,
    39,
    17,
    'Meta Ads Executive',
    'PARTIAL',
    '2026-04-20 05:29:42'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    59,
    39,
    17,
    'Graphics Designer ',
    'PARTIAL',
    '2026-04-20 05:29:58'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    60,
    39,
    17,
    'Video Editor ',
    'PARTIAL',
    '2026-04-20 05:30:09'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    61,
    39,
    17,
    'Copy Writer ',
    'ADMIN',
    '2026-04-20 05:30:31'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    62,
    39,
    17,
    'Social Media Handler',
    'PARTIAL',
    '2026-04-20 05:31:20'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    63,
    39,
    17,
    'Social Media Strategist ',
    'ADMIN',
    '2026-04-20 05:31:42'
  );
INSERT INTO
  `roles` (
    `id`,
    `admin_id`,
    `team_id`,
    `role_name`,
    `control_type`,
    `created_at`
  )
VALUES
  (
    64,
    39,
    17,
    'Social Media Executive ',
    'ADMIN',
    '2026-04-20 05:33:31'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: sessions
# ------------------------------------------------------------

INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '--oPH58Tyn5CdguqVBFKKnDomgY8FLDC',
    1778912850,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:29.290Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-AlL43DHC0BcdSCCe4sgaJgmE7MPVCbi',
    1778912843,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:22.236Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-IbqnLqtx7FCB8eEiyEppLeM4XLjxGYT',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.110Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-P9lpak0F_Jyq9Utk5LQhloEqO4qZ5Sg',
    1778915567,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:46.332Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-UhyGe47-HXT1GTC2dWR3xVoTZicssdi',
    1778913412,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:51.605Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-YXHjXd6Wzdp52yRTIabeDTdzAYSMmfQ',
    1778909236,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-15T08:15:24.584Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-b2xUrxKgmy0IqCySmUlpwibgIoSphr8',
    1778914829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:27.852Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-d54jrNtUeicifrtoU_yOETYYNFxxvOw',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:20.878Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '-nuAF6M1y6Oa6Fp-T583bSUFysxoKvaR',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.248Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '00PaPDQJsqomWvxr5VBzniL37x21InBL',
    1778918984,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:43.397Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '00Q_riN7kGkSlKQOhmKDUTe35sPjRM0T',
    1778914827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:26.538Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '00aCEem7y-LL_22KnF7b7UYiZ-uHyzei',
    1778914806,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:04.875Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '04BICnTaH0QwZ8lGvmNday_uHuPw-4Uh',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.649Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '088eqkGHBACkHhDAle0A3y2ULJgRScBV',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.853Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0JfVmsOKkel_RJp5_y6EBKgUr6FUnH9K',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.916Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0NrorHZScv21NGOK-RRG7LF6_DtwgxYH',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:21.372Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0QG_9rc0fmKhAVC876G5Un-zxjTZQwIw',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.265Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0YdM-lmbVPfdszIKKDEMFtLdaTYoNdLJ',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:02.373Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0ZVuOpz_n0Knx4Oeo_gGNXNcuVqoI_MZ',
    1778914811,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.133Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0_wdgtvbWBI2wfjWBayP4qhHaaIKXVr9',
    1778912846,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:25.036Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0pAbSXI0IbfIIrJamB3TLz2jMMrf5glf',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.937Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0tFnLiAYbeDRHl8qZ3g-R3ZJ1a5z54BG',
    1778914805,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:04.199Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0xVvPEMy9ZZ-wxoy-rLs7iufyKaCQgtb',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.221Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '0ySnOSuDS8AHH2us67pqkD75YI_qtJ6Q',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:25.528Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '14_eXMsgTVSDONZidsXB929WR5foHLRp',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.808Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '172-4cW22MMspx8tIryRl5AJ-OMTS4pA',
    1778913419,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:58.117Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '18z9l_6xneupb8qASXxIERW_--61-_2l',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.860Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1AmzAsA9ToTc6776a1cq31uhtff43YyG',
    1778914820,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:19.119Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1O-Pygiorxx_fTzYF_6UW57m3zmLHI8E',
    1778913412,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:51.725Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1R4bwf0a2strcTONKKT8JiLcvS1g2beM',
    1778914805,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:04.492Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1UVQau43AoHPaDVyoFtqZ7krRwe9Tb2L',
    1779513878,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:40:56.028Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":70,\"role\":\"user\",\"email\":\"Hardip.designs.live@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Hardip\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1YFsRcZKnIWOUQhGXqaeDNFtN8X24cIU',
    1778912835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:13.506Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1dlrKGhuUqRWXieJw2dOOi9GQ0kK-1wI',
    1778912846,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:25.328Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1shj3qQUJtXHf3YooWf-erTL3LXP8LCA',
    1778918991,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:49.714Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1tyiugIXE5cC3C4Q9GDGG13lwVTUZJgN',
    1778914824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:23.145Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1wDrA7E2LeLWQ3vaipWYWDKwrPv1_LVI',
    1778912830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:09.258Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '1wiwwJnk_YYjjNKwr9ZvScr4t1WUg8wT',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:06.442Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '24SEVswlzzlcrNLRETF2PV2Gk_FVe1-N',
    1778912841,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.242Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2AQvxvTPpMErmlglh0E4y7E1ndQ_U5qT',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.839Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2BRx53y2Us5068rSF-xhcj7MdDtS8VvN',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:25.156Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2BuGcwwu4xcCg387l-gdP4WIk-TKE0yV',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.239Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2J2FA_PO0bw54y2PwiMFKISoypSaua-E',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:03.383Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2Jvr0KWR6k-j1O65JY7pjgUfrcZbP2ik',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.926Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2LrRUs0NOFdUMLNUP9wyPUR8yPN3SMO9',
    1778914802,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:01.103Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2Mibu6evDGmOLNdbiJB69cNDZ9F1X4uW',
    1778913433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:12.694Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2QDklXO40VCd1BYMfeaxuG2kAe5WG4eu',
    1778914830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:29.145Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2QybooWKiFqlbcWy-e30cSUW2UTuqAKg',
    1777643286,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:26.243Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2UKCmBxdkKU1L5MXhZdaRR8ROSbQQTVH',
    1778912834,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:13.034Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2fMzHvf-ZcyHeUDFVYOU3MLVJPc5qaqI',
    1778915570,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:49.262Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '2kuoJdisoqNUrfBddUTOHoI4Sfa3bU0s',
    1778912850,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:28.676Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '34v6Nfmod0wDfDQAONQzQSXU1RCyG8OD',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.632Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '35Ct8a-LFEASksEOriaQp51b_TwxIoSm',
    1778918986,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:44.573Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '38SJ2Lr8Cc33-4kxey7kIEd_4frrJM2l',
    1778913421,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.111Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3AC4rSQFAmmYN-dSC7EyvynM334MEBJC',
    1778912825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:04.353Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3EKXnQbaAnDj2Zt59F1S-kpyc_HqhV-C',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.226Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3LcAW_gzkZkQLNHKg76s0XyrqbpYwd8O',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.180Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3M3zw4AbOvLKp_hQaAtMs917o5WlgpGu',
    1778913430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.317Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3NzR0JBapVn_IzCeht_T01DaktoScy7D',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.648Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3dcqSkhIXTAAv2hPMHKbnJ2c7lfl73dz',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.551Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3fiy0bLki0wFSnD9Adkp4w_CMa5SVU8H',
    1778913418,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:57.361Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3pfzO4KlcV0n3DGKgOeD6IV1GY1MBK75',
    1778914809,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:08.371Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3r2X0rOKCYHc771Wz8usMEQQ3dJpmmmm',
    1778918984,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:42.654Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '3vyFN3oWfmE2CzWpLGufryiZCLPNOHjj',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.249Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '47RBftoH3QWJEtlaproZEpFi78p-fORN',
    1778912848,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:27.292Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '48ZvCiwb6eXeZ6P_tyaI8aj6ChF49Nwm',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.083Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4DHuuuZws0j4PzlzwTBRUYx7cN9M7Xgb',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.758Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4IhBGbjDaus4vPIvNQnjDUpuonjpYjgM',
    1779454605,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:57:15.706Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":71,\"role\":\"user\",\"email\":\"mohitdoriya2@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Mohit\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4WkvgVYBXtB-_Iyexq6jztjOWQd_WkVA',
    1778913428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:07.634Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4WqtzFfKauQUAFkwluzSTU4Z3FPRxc0N',
    1778912843,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:22.105Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4XkxuGYvKIAXvLDnxC7Ryf94MIq0oO6l',
    1778913434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:13.321Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4YjS-P_cQiBI_epDwRsQwohWB6YQ9mwl',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.158Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4_TCvsfU2YYrAuTcrk7OnhU0SJpa8DoY',
    1778914815,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:14.111Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4aWIf8WG0K8mpkO7uxUN0lHkfDxRcXct',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T07:12:48.743Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":217,\"role\":\"user\",\"email\":\"mobad799@gmail.com\",\"adminId\":39,\"role_id\":62,\"userName\":\"Neha \",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4ntHaDzpblr-HIlkv3tyznZoTlqDKvl5',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.246Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4oUfbsWRQBT6TYl5gXTb5-YfOE_7vUUG',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.554Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '4ooaMoPQ1iv0Cwn_v_77lHX69xepNNJr',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.245Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '54YegE74_bmn8hiJzqtlE06w0Any3dqN',
    1778913416,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:54.635Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '555zJzmgzN5p1lxM0iMkpax7-PxSZGIf',
    1778914802,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:01.520Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5Gz2VPIfEOsPF5BPmFMwfupicFh2Iu0P',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.711Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5LavwyeYMdmOBFvQ6vrs2xSBNL2cEk5c',
    1778914802,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:01.370Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5MOzG7SUhQM5XXJz6yBqx0vQVgAinr6-',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.856Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5UI851JYSP4Ww0Y9b0ZLkgNVnhJjAqV2',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:54.222Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5cizO69aGX8IlMCSA0Y8wvxhMVwIcJ2P',
    1778914827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:26.088Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5fLUhQEyZ3lVdxB4P6-_2PqAUD4qgogd',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.349Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5lVAx3C0aCKdiJr-hHUuSa-MCijF6E53',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.157Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5ngrk_BXEuhgdiElOTffJTO_gtl2cmU9',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.290Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5nw-F9rhwYiFIroafsIQGodwo-QgywDx',
    1778912846,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:25.327Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5sSwdEW6IbHi-H2dl4b_NLXuOse9o2_0',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:06.612Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5wlUVTEMDMV5avi9KfPjwu9nDZrRDV1H',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:10.206Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5x-BSeCA6eSkraDadLfeReqymA8Ty0Wu',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:26.260Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '5y3mSuZdCeVEJeK0aJ5I1mZ1veQj9mFZ',
    1778914827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:26.131Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '69r3aT1cO1lZZFDszJ26Ymd2n-cSlxMh',
    1778913425,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:04.492Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6EHIWRW2HWWv-ZgblGyGRwdKHRlXPQta',
    1778913420,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:59.311Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6FDiuEi7pN1FIAXMjE_Ohsi1YU2597KV',
    1778913419,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:58.716Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6KCkWnGAdnCNatMbye_krOkp7xvXURuT',
    1778914823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:22.183Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6KM7CBa_9d2qAuJRrGdzCJ2sEk5E0-tD',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:03.662Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6UNPzda3XxXWTVOBuU9zHpltfUtlvbTY',
    1778920440,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.546Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6Wjo3WsIOLFp91pEY0noN4kmRZy1fyf9',
    1778912836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:15.318Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6YKEAWH8XyhwXD0BTfpoSAfgZhT33OH-',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:57.503Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6eaeQfxL90_Dpav_BzU-Xq_JizZOAR1f',
    1778913418,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:57.108Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6lkd-M1lNT7EG6zhYDrAFV-eEPHtDwja',
    1778920444,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.691Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6woEyebPyHE9mW5JTBX1fk4RZw-8AkHi',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.128Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '6y6ZCBL2puOvDsxPQ5r15utjjnsrKete',
    1778913427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:06.099Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '74oKkg91wT2muzlKGzomUEPvcE4ZA54R',
    1778914823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:21.925Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7Cyk8DIgLJJkGQGJRDaNU4zeVh7qBO-o',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.783Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7E640VnYwWlPpdgukgxUEhseOOgPEDFs',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.128Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7G7pdtZb4MPwNVjeiEzEcE_ftquTU3tp',
    1779510921,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-23T04:35:21.165Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":216,\"role\":\"owner\",\"email\":\"swatihr206@gmail.com\",\"adminId\":39,\"role_id\":55,\"userName\":\"Swati\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7Gkmx0dRqayXL-hahFEggwWEHQQ689m3',
    1778912828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:07.543Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7IEcyBt5HHY1voItWa0uG3xiSx1U4JQ4',
    1779513902,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:09:51.387Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":220,\"role\":\"user\",\"email\":\"digiriveraads@gmail.com\",\"adminId\":39,\"role_id\":58,\"userName\":\"Nikita \",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7PogsNKNr1dMuHQRMMvFfPMAK9GEVmFG',
    1778915565,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:44.409Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7cAATeh8Op9B-VMLa-dwrgu28bqs49me',
    1778915574,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:53.416Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7cJWrA_qNLmNQM7-_sWcatPV1yxK962H',
    1779513905,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:53:10.019Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":69,\"role\":\"user\",\"email\":\"vimal.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Vimal\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7kbetO5ecEwGUFQojxw-pjt2Yg3N7GsE',
    1778914819,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:18.390Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7nd0_NX-cbBLglJurKG3EmPp8SWUxNTV',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7r-EYHsbG32KL3acBSlkd6A0LbhlhSEp',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7tdPmzSx1O3lv2JAqctnofDmzqbRnANA',
    1778914824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:23.543Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7z1S0VK1hvQeBIIcPfFZQaZhC9CIe7Em',
    1778912826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.278Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7z1xGNV9mgROa1L0EqA9WjO8Av8hxCQ8',
    1778913427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:06.614Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '7z9wMt5467GZl2xdCXHSlo_1i5kiRfKW',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.041Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8B-U99od_5TcFq8PLEqQYs1FxuNXb_k_',
    1778912843,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:22.507Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8F3JKYr9PTHePzHccOU8xkXYAExVhhDo',
    1778912833,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:12.023Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8NPvZptUB8XCZ2A2Kmjpg_TqQz4-s2nd',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.108Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8OGuv9dlgJtpcOzwvR6bIJHzosUkuGFf',
    1778914800,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:59:59.585Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8PEjakL4wyx0vBt03fLDVu2oRJjThqI3',
    1778914814,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:12.884Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8RDHjeMHeH5yVhJvve2zS6R2YLt7eSN0',
    1778912832,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:11.511Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8SAS81bE4YgPico1dVYc-gVt1RkgqqVG',
    1778914801,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:00.158Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8bsokOuEIF-USExgmjjNpEh-qdGK5m9i',
    1778914828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:26.869Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8dnSC5edyGapIGzRbBihphQN9H-Aq91W',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.997Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8j6bYKsn1zDiG6oFrLJK14VmZZRXbC9U',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.865Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8jL7Tocdbq4-6rR8m9rZ35A89O4Cg6TO',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.953Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8xYONwrUURXSrV69sW8WhwkQojP-Qvqp',
    1778914829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:28.106Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8yQP7AGuNOxxc49fpdYMwyboe6VTlAGD',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:02.253Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '8zBjkBQDs29L8lp8WLTsx5av8rx76C-T',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:56.408Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '95YPVLHleDh7JgDrXH6VqSUX6IgRe25l',
    1778913433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:12.121Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '9C6A7sZR9IZ2AE8P9pw22FjNzcboc2sl',
    1778914818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:16.909Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '9EZSkvscGkP73JGaEPWpdreiJHsdUe62',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.261Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '9guXzGx_AaNEwwd1UjH9zUQR7awQKmkD',
    1777619243,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:22.783Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '9k_bq5IxGFKcZ3iH1uj_3q-852lusF9R',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.520Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '9tf7TND8AZa6D0p0ZhPNLdPnT005eWMd',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.233Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'A5RkKytJRuTFwauWigOxjCZXCfmoxZxb',
    1777619247,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:26.214Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ADmCwCUFKsaNEWwn4tAMWjMXTy10e4GD',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.266Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'AGbVY_vmdwuI5PVoMVkl8ccr1Bm3tM5H',
    1778918992,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:51.719Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'AWlE72DhLQT4jsCfCYspCg5VIU3AFGWw',
    1778914818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:17.423Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'AX2AXvUZAucz7xbLbunE0sFTkUTGPMW1',
    1778914819,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:18.160Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'A_0Bn7H8vOdV_LTOxjB1p7GhYJmYvGNl',
    1778912825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:04.032Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'AmWrXlyJZtMo30HLhWLaco3ipJ6zQ6O4',
    1778913424,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:03.100Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ao1Megzgmnoh6eOu9FB8jK5PYiDhAFJl',
    1778913415,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:54.475Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'AsRVDTg_UdeaIau1AvsgptdOtFnTfGCt',
    1778914823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:22.408Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BAsJW7KRQhe1dO3EPnSUFQcdH5LlMGah',
    1778913420,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:59.697Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BCpNnM38iE56ltwsWnLIOnBYXOfmVKqI',
    1778913438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:17.378Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BHPYx2EcCkJCo4lM5tnaKxK2TKzC6YzI',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.977Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BXNSU1fapAk5boL7OBVnwjP3xrlp2ZKr',
    1778914824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:23.146Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BemE-MtQkgXeaglw0fzcGuPRYia5HtPI',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.409Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'BhGZokRgATvIAQq4OwlZaKHqEKSQ3v9c',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:09.538Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Bl90VZjY9JNOTluM4KWQQf9NiiKM4k74',
    1778912839,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.994Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Bn8aHOvviV0Mv81muoJ_BYU-VucYtpaO',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:16.628Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'C2eFwdCvGinz8nhToJd_1TRAZ1P4xuX8',
    1778912822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:01.018Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CHvrxITzGN8EiuGYZStPG85BYf7Dg0Nz',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:10.156Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'COgsSBIks05WLo9qjKkhe3sILjJS1iao',
    1778912826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.034Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CUjA0j5WWDri_pGzSQYWIHl7F91159gx',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.783Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CcCJqchhHx41XPskkwYN6K94-W8qlpWr',
    1778912833,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:12.337Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CeqguyzP0cz35NCr0PpYTFz55Qs7wZto',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2591999999,\"expires\":\"2026-05-16T08:34:00.689Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Cjg_hhvS8a12XdoofsDhLj-vvL_K1bJ0',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CkEc_iswUCKHfCAZsqIrrfuVS4I4KIfp',
    1778913439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:18.128Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ClpYqouzYAauvTKxcKjG8H9F2z5jLONi',
    1778914827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:25.863Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CtBJ_nbIYihNy_ssXCYVsG1_lxy6ZTei',
    1778912844,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:23.119Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'CxpHnESDvrmSRfrl7oLdXDD64-ko5B9T',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.988Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'D-6IYKDD0-Ps6_sDUunc06DxvsXNsPzn',
    1778929502,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:30:08.944Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'D-hCmn8YqgiXqAxMubCnoodMVekk2OiT',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.784Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'D6GDh5h621Hs8ByR8ksGsS7gDHuyfLXu',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.715Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DFfK6W4fuqx3XMVLDllFFJjdQkR6-vja',
    1778912833,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:12.331Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DGXj0wvCi89NN-aIoojABN62u7D2RlBC',
    1778912821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:00.704Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DNGrOehUa1t9xsD92JaZBerNCcP7Vztj',
    1778912829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:08.232Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DVP611bM6TCaZ9XlojAf9GE904IL9OzM',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.011Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DWJxcVQhCdqhyZjIIG7shqSqJMMtVnP2',
    1778912841,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.498Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DWaeIVOCH1Aa8fiG24mEw7Ylq7ISRuZB',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.248Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DhdWkceEZKv5g0vca-pNYVpAo3Mw2oIj',
    1778913424,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:03.579Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Drz-sLGoBYR9mzMFAygZq-gjvsKb3U8D',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:03.535Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DtP9v37TqzukZ1F-RSF75vwmH0UU4ojS',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:21.143Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Dw-NvxNwmQ-CzHISSSGv9RM3ijZIyInN',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:03.488Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DxIrY-eCqWtxoFGsjT8IIX76OiiLmgy_',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.521Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'DxfOvroV_LLQdLJZgFAdTFLgli70wS90',
    1778918988,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:46.573Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'E1iYlMkQyMqWcUgCnZTX2nCQYVI6cfbU',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.250Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'E7WQyG7iET9u1NPdQikJ5X9B_I2NlI_b',
    1778914814,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:13.510Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'E9ZuNsXyyjQWVuAtR7xiV5puyjMxpNkL',
    1778914810,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:09.347Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'EAouBGoqm2aqXHN6qJXZTirvtSowvRVM',
    1778915569,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:48.326Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'EEAN5LqwyBTjg6AijwtqPUNKIPobYWZg',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.505Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'EJFMAHux4ZnJ-WuJBgDZmwU55Q_oiQYA',
    1778912851,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:30.015Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'EK61Hky4w4AVDT5xzRNxnaNRuNkYeSgr',
    1778913416,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:55.141Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ELyP-F7459-p4OkLmaNKvRb3yvsOqERS',
    1778914823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:22.183Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'EgBzJZdskrnydmTIHNZRxcXYy7tnwmlL',
    1778912845,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:24.161Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Evf8PFtc-ef4QD2-FJEw2a-zyD1jqxuu',
    1778912826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.279Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'F0rqJOIcPjlRD_bimrZxzlJgtmHJsxF3',
    1778912830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:09.044Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'F2BbTAfTbkBeifGVUl-tTZVDyYVMapOX',
    1778914813,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:11.864Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FCqrbtAJcyj34LPJ3F7iICkZGUx8S3FL',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:46.680Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FHCt-R-F8ogtD8dKEe_Fc2D5K1ijJh6n',
    1778913413,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:52.203Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FHM7QcX5Ii2E2Oe8D6RkSU01QrcxzWtr',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:25.512Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FLyOt7bxsovmLqZha0eZzMisoHX-3m1H',
    1778913429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:08.089Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FiNlPSe4XSgYLj558ttJDMCU49TXgfuM',
    1778920426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:46.443Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'FknQ7AK6riSrhKBL7YiwTeVFpbgyLvuV',
    1778912836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:15.319Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'G2ichaTRW575xMJ_Va-RXy-XH-rtGFxQ',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.183Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'G4ZCJXfcO-oYk4_Z3ZNXOQd76w3Fy0Fq',
    1778915567,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:46.272Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'G7VQaBzU5p7gndc3HhK8hk8vjpVa48MY',
    1778914803,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.371Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'G7dX9nKMKfXnIixTUrJXa1UdT0sB-A5V',
    1778913426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:05.649Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'G906oX6l_gVqtvV8aj62WMukNydPbOGI',
    1778905458,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-16T04:25:01.222Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":67,\"role\":\"user\",\"email\":\"chirag.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Chirag\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GJVgqVTpG8Wq3e_4Wpjc-ALUFZIO4c-x',
    1778914823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:22.548Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GMeVCZjxXjDtA4M2Qa9lB4FFlqJ9v6of',
    1778915566,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:45.365Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GWGnQ8dQMiD0glRGK90FUqG0H2-tLa4m',
    1778914818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:17.192Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GYBszLHXO-aoYW8PQD3qLuDUUoiQIiqQ',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.238Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GZBMSYpXNJUn2US__6Ew_dIREstcuPfZ',
    1778914818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:17.569Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GbP10-rxIMBRwJYmYFr7Aa9hzY8OaP9r',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:05.170Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GfGkRwE9UleNeXcM-HCh5cNxla4BlDyb',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.854Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GjlK5X1gH2SLt6IxuT4cST8g7eW5xcwd',
    1778918987,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:45.771Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GlnaBkBrhsXDbpB6sy8v2uB9X3fVMZMd',
    1778913433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:12.234Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Gqfqezre3-CRsYuvB0iCadGvbDrvjGTG',
    1778912832,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:11.615Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GvN-HxoEy__GzCdXaQIABI6d6Svy1SRW',
    1778918985,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:43.687Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'GwuYh24wfwp5n7hAla2qtI82jdcBi7zx',
    1778914817,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:16.205Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'H4_H9hoeEgZLdCbx7UuiFG7WsA0Cg9JW',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.891Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'H9F4WgQmTsI2hUMcFj_JACoM7rAy7nTz',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.032Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'HPA-DkTBNB7Rr9QLC4UKv4GnjXkCZzHt',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.420Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'HPig0mBBOkaFMU6OsLbnBPbWMWLjVgLV',
    1778914816,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:15.464Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'H_K3DoTZgT4YAikRm27TFsHKoA9uEt8K',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.031Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'HjNvC7WnI1k3ilRQSObL_Zt9FxHgtSUa',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.135Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'I0X6P7ztN1lz_NhNIF5bXVxN8R5FM5oR',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.410Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'I1ttGDeoMaHH3_T8Oae2Eaq3oJ0Ui-k6',
    1778821569,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T05:05:58.087Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":70,\"role\":\"user\",\"email\":\"Hardip.designs.live@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Hardip\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'I6BJLFhaoPN66P6kbPh5AQqpO9BHrMss',
    1779513894,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T08:26:02.976Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":222,\"role\":\"user\",\"email\":\"digiriverasocial@gmail.com\",\"adminId\":39,\"role_id\":63,\"userName\":\"Meet\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'IGTH4-4wBb8TTaLfHSQg72vrgC3YddZP',
    1778914801,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:00.330Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'IHEdU8YiWy7yq6fiGl9a5bGwfG8-nd4L',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.052Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'INr-S6P5rOBYXJcTVJ56eiIdP_5KZB8f',
    1779513904,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-20T05:16:10.103Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":39,\"role\":\"admin\",\"email\":\"digiriverainfo@gmail.com\",\"adminName\":\"Sweta Dhanani\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'IU9uA1jajUknXPOmAlGy_GdK_CQjKSDo',
    1778914801,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:00.442Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'IVdOqrQOOxp_1gr5xSKOpLPciNN7pWch',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.629Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Id5Od7K4hztA3C7rcRrVVUt3tPjd1HpX',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:05.878Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'IfAm_ymTeB7PAGLDfCFo9Q8guGlb_Qra',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.378Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ImclOKzPsQUiLXuWXu1Q9mdJjEKAnvz6',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:56.409Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'It93vr17bC8PkO0Iglai9gBzyvg2vzPa',
    1778914806,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:05.505Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Iw39dyN1c_GDk9fpQwA4G0PTyu-8kRB3',
    1778903294,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-16T03:48:20.799Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":66,\"role\":\"user\",\"email\":\"farhan.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Farhan\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JEyqzf5gI1VSpC5yLWJ1cizs98VnBnTE',
    1778912835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:14.390Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JOIPqYyLQ6azMMJubW8WrdXkR-e0y_XH',
    1779339777,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T05:02:50.957Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JQArw3zJEyaRMHcm0ZjmFmWyFa9pEow-',
    1778914811,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.483Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JRUVuc_DlVhF4QlVH1ZhgSLL3hzj3DLL',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:10.180Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ja2AEwwlprGGauTfMglEOab7TaEFeYw4',
    1778914825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:24.418Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JeMsVE4GLj10Kqo-f9vQTorIm-M3-ZJ0',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:01.609Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JfRh6Ya--dfkaLr--LFHDTAV76fNIV3O',
    1778912848,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:27.001Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Jii_PhZgeCb1SWqFQBEimV5wV66oycuU',
    1778913435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:14.100Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JlWqkgFDdh7acNTUCBPo8VVnMH7-U6uQ',
    1778912840,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:19.320Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Jlv6vR8UlZQYyETqovLbxpWaWU76ppWb',
    1779256500,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-20T05:24:10.733Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":216,\"role\":\"owner\",\"email\":\"swatidigirivera@gmail.com\",\"adminId\":39,\"role_id\":55,\"userName\":\"Swati\",\"control_type\":\"OWNER\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JqTgPccdqWTmSpG2SMeLLCXUmKcEP0jR',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.925Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'JtHrwYh3w8xxXgS6NZxQsVbVd7K5qLaS',
    1778914816,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:14.898Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'K-A_laVXOfmlpfjpfigMuFICgSzF_xUv',
    1778914829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:28.369Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'K2cX38dBu6onaDz-PrHTlmuqIhhFRxja',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.584Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'K2jy32yEzwgEfsec7TyMTQI_T7TTj3ny',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:55.624Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'K6MICWuBdJczc0w__E7vIKRA1mKZ8v5f',
    1778913435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:14.584Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'K7DMS35nFB2to7vp_EkaF41UUsjlg5mR',
    1779264291,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-20T08:02:50.336Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":85,\"role\":\"user\",\"email\":\"john@gmail.com\",\"adminId\":34,\"role_id\":48,\"userName\":\"john\",\"control_type\":\"OWNER\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KM9P4gsQEwC-mCxHQabK2ipW0vNl_hvB',
    1778912833,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:12.332Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KO7H_jz5u7uUWbtbFGnH3xpIqryANyTx',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.983Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Kf-XyNuh0LDfRbem_3XFjpukM7_kTdLe',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:25.659Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KhQxTOJe6HcZrLr_Nd4oSQ59xPHei_Ht',
    1778914802,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:00.872Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KhZVk1fkQF9KXDs0kElbRmM-Tv9Rw6nZ',
    1778912850,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:29.338Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KjFtg_28NEFUjkPXe1OGy7ynHaJrEpH6',
    1778913435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:14.331Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KjML_leCPtJceRsHkd9okfjxgNW7E8NV',
    1778912851,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:29.540Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KpxmxxSmYqY2fuuiRVn6Rwe-GThLFADT',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.553Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Kx4l0w_mrW0OkLhVj1iqDV__i9Xn7NJH',
    1778912832,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:11.244Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'KxzcPXofBHKxscZhMHjdh9SSINT9qFX7',
    1778912849,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:28.020Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'L6w_HUpWHrHAFc3oJUA0O_Hzkl6DeLR1',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.013Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LJmqLo_6I8Tp9629rF9rih_wliJv3MlE',
    1779513878,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-15T08:18:00.524Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":75,\"role\":\"user\",\"email\":\"nehalmori470@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Nehal\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LMw4lwTIvPEVA2aRvB2yDzVjHGlkMpMN',
    1778915566,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:45.265Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LUtFjyza-58MotRJAY1PzmGr0_yL5SrN',
    1778830929,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T07:42:33.743Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":35,\"role\":\"admin\",\"email\":\"Social.Designs.live@gmail.com\",\"adminName\":\"Dilip\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LbuGz3XsNRD6CR35TTpLjaCKjamBHQZ0',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.746Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LdBDK6tIh7JePKAY_kaH33-t136WzuQe',
    1778914815,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:14.490Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'LffKRkgXdsfQeBBsEcc-k1Oo6kfbxCQG',
    1778913415,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:53.819Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ll-OQdrMw1b30nUjoPGRho16-uCo0N_d',
    1778913426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:05.415Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Lrev3hk0JcdAbqiw97tdi-iJhtH5L4Jx',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.410Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ls0sccEN2Bfrp1Q0-jBBPN5LTOav6lpW',
    1778913416,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:55.293Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'M0W3jHiFliHf72Hr1465uqn3cQzouEkD',
    1778912848,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:27.516Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'M0aXYAVr5wLwzBth_Z-fQFbek64qIWYZ',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.918Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'M4x6jrEWZ29fjaOym_g6O5afu1mpGcSV',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:10.263Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'M6Uj4fDPzzxYcPaXAZf1_Fo1j2CyxBxO',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:54.768Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'M6qGRwtA1_lHMkeYt-PjMXUcoOq8YGzv',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:02.099Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MJKfDX6PLOonsKbSJihPiQ0-sTvrF7Zv',
    1778914813,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:12.124Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MNQAv2u_2ObDQlPE_zqsEfKQyLKU9vKY',
    1778912825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:04.293Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MXtfuLvwWJiyJzDy1rpOFHTs0O_iIj2L',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.573Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MjZ8gDh491dWDYnmubkEEmOvk3NEPoSb',
    1778914828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:27.149Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MrAP1csrkq_5UT77xJhodoyl1aAg4WVF',
    1778913425,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:04.472Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MuybU-isFqjbblAUdAwAyvKYwl1LbIEN',
    1778914825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:24.150Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'MyK_ntFF77Qd0Xmiv__Us6ZLymtgx0E2',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.989Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NAWxYZhFLn6jdKNsk_ny2izt8sxVpK1Z',
    1778913414,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:53.101Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NAowJqy_MfZJ_UnlqapZfJsCQYvL9PIe',
    1777870569,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-04T04:44:05.953Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NBdojP0dcQUKXCJAAeVTmPMPFb0KY30g',
    1778914820,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:19.347Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NEdVochtjG8ChV35FFVmBMroPqDxK7Hf',
    1778903836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:57:15.698Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":71,\"role\":\"user\",\"email\":\"mohitdoriya2@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Mohit\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NFfnhXNTFfg5dPHl0ckmu6GoOYvwBT3X',
    1778913436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:15.140Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NG5jrQOgZQ5EMLWGYwK4KKovKrtweLeC',
    1778912844,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:23.229Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NHs1T5Dg4GOoFjSjHTcQSbHAl-kcsUu7',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.012Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NOtfWhI0E6kSdlnbugzow2s-LyBzFe41',
    1778912851,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:29.676Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NVQG25UgIFJ3odv2xR9ooZRR1ZrIMR7m',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.420Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NcVogfrgjJxtLX3UKi2OjCGXooKW7RAn',
    1778914821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:19.872Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NfdOqFXoyDirvb_k3mSB4v_EnRwA4-Ar',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:26.260Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ni9FUUDOnfua9ZBm10f6uL1rO132scZe',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.647Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NlSYoGjHrTu6blogLt1C1gdNfaOxbn4n',
    1778914828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:27.383Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Nw7cioFxIKPY2lhAl76_b0614PwR1lzN',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.059Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'NwOB4vMxk5ybJJ5EiGppp9BX13zfAPFo',
    1778912849,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:28.534Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'O0Ybfe4qUikYu6Wvzky2blbYLovXZVEW',
    1778912828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:07.055Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'O31gJ19HAYHrZ2AOF8hutCaw8U_pYRC1',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.720Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'O3V8beN_PhuYeei7MsAU_x8tVAJjH1zc',
    1778913425,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:04.706Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'OKvt7z51PeOVDR8yPwBtL4FgBh1ace9E',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.892Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'OUXQExd0yVPHRjaYovTiMpeTL-xjccdU',
    1779422991,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:09:51.221Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":220,\"role\":\"user\",\"email\":\"digiriveraads@gmail.com\",\"adminId\":39,\"role_id\":58,\"userName\":\"Nikita \"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'OYQdDZk80S0eQE0csKYEIXyGvdfcMVAd',
    1778826709,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T06:58:27.781Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":75,\"role\":\"user\",\"email\":\"nehalmori470@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Nehal\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'OcGz1RMmtWOfjvth8g1X5i2vazzJOKL3',
    1779513894,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:40:40.272Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":221,\"role\":\"user\",\"email\":\"digiriverasales1@gmail.com\",\"adminId\":39,\"role_id\":56,\"userName\":\"Hetal\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Oq2hMm3u88lwfnx9mCghq_4Lpj9H2UHf',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T07:10:44.026Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":219,\"role\":\"user\",\"email\":\"sarjudigirivera@gmail.com\",\"adminId\":39,\"role_id\":57,\"userName\":\"Herin\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Or04zoGNuaW5z6TONhk_LgFjpeag6FF2',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.636Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ou7O0Lp8F18mi6E8IOgNG30N6SRy5ZNk',
    1778920436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.209Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'P3AAtWQlAsDyaBFZTbYYcAmZ6IBhWDKd',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:54.769Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'P4dtFsJqXkTdBrGgkro_STku2g3beaFq',
    1778913410,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:48.721Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'P8cNg9HBtZ3b-6l24Tuk5Vw9nwKbQU1g',
    1778562330,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-17T17:59:32.386Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Manav\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'PF8lzuz3_khnJY1iXUpKcpO2hSUz8X_3',
    1778914806,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:05.374Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'PJoo0oPLETcQ9_zOpdFmXLRJ3vq5Telw',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:25.107Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'PWz97brczAFCToykULz_vfOS3WvVMDdu',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.746Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Pa8koNxgvYM-siDkGSOOAidPArhehNqr',
    1778914830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:28.890Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Pj4eRlF50KT-MPay3ze081mZHim8wi-L',
    1778913420,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:59.060Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'PkT6efA8_QAPv-MEiNStOVEwB9djKxwN',
    1778412328,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-10T11:23:27.171Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'PqKrVDO2yvNLFm4X9iuwXVWzTu87DFCr',
    1778914803,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.058Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Q1_yTkm_pN78RLvmaTUy_KPfSglhN8FJ',
    1778913426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:05.415Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Q1bzCVjftmqQpjXweov5FDmyuDIwf-SU',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.620Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Q6_Kqy6bA6J3J2HKRft1KJdEyVPNg-i_',
    1777619246,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:26.056Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Q8qxrMWzKtNs-X50cLGLgfGMX4wbaCDY',
    1778912843,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:22.632Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QAB42PQ_p6SibvA9VhG87N-MnoIIV_PQ',
    1778914809,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:08.064Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QEhzcigMEHT0WdQ68IDbFWiuMltrWt43',
    1778914810,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:09.144Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QFb8pw-n1Kx3pgHn5XqE_mlgIiRzBU45',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.421Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QHpiNW_QHIhxf9dAmDP5iENcu4-2HkCI',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.247Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QRzohyDUHFnZsbqNzb7YpYQ0ebLiqukS',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.782Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QeZd22Y3x7yDlU6nks2aKftNaZ_a67OF',
    1778835197,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T09:01:41.762Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":69,\"role\":\"user\",\"email\":\"vimal.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Vimal\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QvLNX5H7DlH93kfKrZ-xUdqCMv5ewArC',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.246Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'QwhqHuUimeDh0JiqBHohUsZo4MuIwmYu',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.571Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'R-XPkEKA9bsRjRQhj3CVT2mQaEmkPQYx',
    1778914818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:17.192Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'R7gem-jhGgw5tmjVZJolPNWv3Iek9b1g',
    1778914829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:28.480Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RD0MGyiUC9ByNR_XQmAlJzZV6qQLnFE6',
    1778918991,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:49.454Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RIOY5zSAgqihh-Z1nl6FnXpTKJIQCP0Z',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.927Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RYXiouWZhKCNR61K37Ee382PDSXFslEX',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:03.231Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RdLDoAkhN6sg9247c8OGykzheETUkTCK',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.932Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RmT4k4ST-n_33f8VLEjxbUwS838oeOuT',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:21.633Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'RnAtRMfDyIOtqcidHGygujjiezDpwBh6',
    1778912843,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:21.973Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'S7h5CkA76wdMAmOhKquSYTIu5mes_BaH',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:06.382Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SVXeVS43TM1FPVMMNoB4ifqpJb9nuIYD',
    1779019170,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:53:46.963Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":35,\"role\":\"admin\",\"email\":\"Social.Designs.live@gmail.com\",\"adminName\":\"Dilip\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SVoTc5Z9L7sUq9T8LjqQx4a-BOJUAqM_',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.989Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SWamAy7qZN0QeVWR59XDeztZOVpt_9wG',
    1778914829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:28.107Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SXD1D-Xa3tQscsIZXKdG7L7Y7L5AwFrG',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:03.225Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SXTNS_ZdbAnH9Acc-NIRm-G4HrQuPaFz',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.363Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Sgve6p9LzT2HZ8sCNv0C2X_FvUigb6rl',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:50.135Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SiP1Sg556FlcLOedDcC_xS1OwMN0QNzY',
    1779513155,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T07:10:29.728Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":225,\"role\":\"user\",\"email\":\"digiriveravideo2@gmail.com\",\"adminId\":39,\"role_id\":60,\"userName\":\"Khilav\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SlaDLkgEDAia7FRhJeo19E7nZsnOGNUY',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.713Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SolS6xe7rSNaBpckT10Y-DqKN7DBsJC1',
    1778913412,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:51.108Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ss0ygf5ltytXxPRK4w9SIuJLJsSmLxBY',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:24.865Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Stfu0hdaOtXUujMZSnoxH8888dNUhpt_',
    1778912839,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:18.216Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'SxKyq051DEg7x2vbvkOKVSPXa-pn2h3h',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:24.713Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'T7fa4ZX0CGG6r56RWQbUyVBmLc4w9yks',
    1778913428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:07.359Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'TMw-V1FVIlPLcHmXn6fD1MWgw2vqS4ju',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.483Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'TP-rjUjmqfTNxQTyzoD7VjDBQ0QVBShb',
    1778913425,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:04.233Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'TdwE5Qabm75EDCQUN1Zpr4PIYoV81cMf',
    1778913438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:17.146Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ThojmJhgtbx-150MhgxlpV97o_C2knv9',
    1778912834,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:13.143Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'TlZlQKCMjAH_3w03TeT2P1uAxNhcalkY',
    1778912836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:14.522Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'TwmEr15b3JkBqeeIXWFfSkvB0yGAmiU8',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:21.193Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'U3DIHv0fT5dXlv3_Gz1nZfPHioV-BX7y',
    1778912826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:04.567Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UD7FNngXW1R9hjCoPB_nF2io-7vLyX_c',
    1778914819,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:18.161Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UEl-ppK0LAMpn_JXq1w8N5nTDUAl_nqj',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.562Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UGxt2eyyhbZHMeJZAa9aZAoOAXPVdSBb',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.923Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UTkBdaf4aMJPXo1H8L9hzdkgpkNdlrNx',
    1778912822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:01.149Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UUk1D7IBeKRraFLqxXW2TjfgfTx_gV26',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:54.221Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UWWA574n94s5FWxQjbERVyqbf07IPDtf',
    1778914821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:20.133Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ud0hbN97GMwS6-J9gJUK3m-UgLZS8IMd',
    1778914828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:27.520Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UeMIAI0ueihhEBzulXcgWU2uSoePA4mL',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.013Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UhmzsM0-y9Tb0INFwMzmk-U4kXQCPdl0',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.421Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'UpCeTY_qV6G51L_EGEgC25JCLI6V_y23',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.983Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'V16ncbKXjgAYoQzVatWfTwEgK8rjPhre',
    1778912830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:09.259Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'V1S79CxyUdW-85Vm4lYLBTii2EEzqLd_',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.713Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VAO0D_ocxCY2y0gPSHmf1d0XZsoyxHUf',
    1779513882,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T05:16:29.975Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":73,\"role\":\"user\",\"email\":\"chauhan.manoj6866@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Manoj\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VC1HYjd7vtCZYu7W_bHXp9VXMzaQioJP',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:01.223Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VNQ61uhP4a4zhj9ZfVZLkJCcvxqq_-m4',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.504Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VPts9YEKIGkT8lgI8oHUp6GGF4M4wAgT',
    1778913438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:17.377Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VUq09k0ENyuoY03NvkOejpLqjKJDkQme',
    1778912837,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:16.346Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VbilU3iDqit0aVoO_9V29n2_5mRnEEAR',
    1778912845,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:23.722Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VizaVIGtlDhqU4BbFO3-IF2O7rBf11Mp',
    1778913419,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:58.593Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'VnUnRE9BvXv8SdZD_4ijjkeaIF4OZT9s',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.801Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W1oBPO0I8NBartT2r8zvSlKXgslkizGi',
    1778914815,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:13.852Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W2Y8dV8dF9vyNewyP19vY3wM8AhFr3DX',
    1778914817,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:16.206Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W74UyOFuUMAioiT5vgE8WP7YCeFlDL7q',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.513Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W7ETCJNK4XS066bOOv4TUxPfxbQtcXdf',
    1778913439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:18.368Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W918Dcs_0a39kpk13MjfSofIa1KYz2S3',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.109Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'WDhai6Y1iLS0tiAH5hzswF-JSVO66h9k',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.951Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'WGNDZz_Lgs9s1PAOERkhMGjhbr7dicws',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.059Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'WQA7JmUmb9QP1GdSdnpCftAQ-zD9W_ZV',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.691Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'W_oSX2kxbe8Te1zcwmPPtS3qXkTxWiGc',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.714Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'WbWR_DzPnENCrJbgfrtYZaxhnaotLVvn',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T07:09:17.753Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":224,\"role\":\"user\",\"email\":\"digiriveragraphics@gmail.com\",\"adminId\":39,\"role_id\":59,\"userName\":\"Dishita\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Wj3VI7t5pMfJzj4MKq4bI0gXHfJE9Xw4',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:06.896Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Wm7vHPrMqsvR9p83HPP2YhOKBdMTiMGs',
    1778914817,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:16.237Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Wnu2ouF4WyT_ibGoRW6ybcGViVNkcYQj',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:06.488Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X-o-K2FfG0IJCON2qr9vTIc_lMgx_tUs',
    1778913434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:13.752Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X1Vt-uRiMarqEfJz9eEePiPND5yuHPDc',
    1778913432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:11.602Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X4HR0W1GFa2LReJI8fVr6ftTmZMEIpQA',
    1778912846,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:24.523Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X8d_SH-OKtOsqRnsELurWiYi1q9fdR3e',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.251Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XDTeCm8ljEm-x0-hUr2CMvVOcVdssiBe',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:16.455Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XD_GXdlSyZ50EvZuOHrLTS9HcKDizOTk',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:02.706Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XHC7tdx1hz_3cY-w71975_LUbney9tSq',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.300Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XHiDVsRgSDVZm5eP_2YhzA4SjzbxbFGR',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:16.639Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XL7YE1_U4h93NRSoAdizaF9DtIDlhyTb',
    1778912846,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:24.653Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XOQy_ge_duxUjY7iw5NtTZuhu-I-XK1b',
    1778914827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:26.398Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XTB9p1RIUpEI9-3VW5P4lmajdOKRcT6X',
    1778914825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:23.885Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XUbH23I1_HTRwQBVBPHzQ5TdwnxIsF88',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:20.616Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'XZtqA31SRNHuKMJyjbVJZ5Aick6Wqq8T',
    1778913413,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:52.313Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X_WZg-b9k8VcFw7X4ufi5Jv9TKnTLjue',
    1778912834,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:13.271Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'X_dOg2NEshvj5_Vdex4ikpex9erPNgxr',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.239Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Xg1OfzE9Bcj0NpPc6LJJJAf5lYUfaxak',
    1778918992,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:50.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Xom58WYH5lV8B6rrauUH720H0sH4hfKw',
    1778495742,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-08T04:09:55.158Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Xu3qjvrgButwj1KKf80UlUYQKEzRt2Sk',
    1777619243,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:22.563Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Y3DR13usZ3gd27MLAEAJXV6HzdEQCBd8',
    1778903835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:57:15.456Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":71,\"role\":\"user\",\"email\":\"mohitdoriya2@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Mohit\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YCnNLKJP44etezAB4WvfdYINgnCKJRqw',
    1778912837,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:16.066Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YDSVG_Bc963FDCeXa_h9ngp98DeEV4Em',
    1778913420,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:59.285Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YFBsyfVj781K6EtZIwJorNNm87LUR7i_',
    1778755566,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-14T09:54:21.283Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":89,\"role\":\"user\",\"email\":\"tejaswini@gmail.com\",\"adminId\":35,\"role_id\":49,\"userName\":\"Tejaswini\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YNLoiXnoLT4SxlKfYRWS1atMcvVGEk5r',
    1778913426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:05.147Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Y_Gxh14atTl7rC9-FSNrHXSLMSZgQ14a',
    1778913413,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:52.100Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YaBL97_qrgHNcitqNjv_PvON4DLjuIrb',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.855Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YbM6KdnOgfvnHbXDT1pebEpg1NhMcfMs',
    1778914825,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:24.121Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YfQwCMKolWsM_NilEz3rY6SVJ5Ko5AW0',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.418Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YiNwHcd215WgsOEhoKWBCNsaYJJlhvxg',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:09.654Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YqPp-nPKTBblM_xzneC6lYi6JhuIP4VG',
    1778913428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:07.360Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YrFM69LvX8vqVJwLp4V3PNdrFYtppH94',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:06.177Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Ys7lAKIzGsceCJZyKb2ytD6U-OdLOZ73',
    1778915568,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:47.331Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'YtfqCw0z2rI786bvMHc6-4rb38mny4z7',
    1778913418,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:57.636Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Yvbf2bTXHmeabGTqsxFgMr2e6oIkPPRq',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.290Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZKUdTuHatzZD_JylSMempOR91sCEM2SM',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.179Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZPd0mG6k9ij_UDZSHRlV7uQUMTjfI6Rf',
    1778914814,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:13.175Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZSfB0TcvJkTcjuQ5lH3y_p0z_oVyiKs8',
    1778914811,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.360Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZVmKjDd7SpOnXgjWTgZQQr21G_o2DkPa',
    1778912832,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.988Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZVmMpRBesx8gWGXg7MVQ792D9mdHq0Xq',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.181Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZblsVRP7w5ALwiZwkQptBUFzOZhAHZdg',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:10.650Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZicoMXiuahCjICorZf4jZksz4AXMOAS1',
    1778914811,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:09.882Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'Zl8qK_jFCOouo3iJ-OCwaMnTjkHb51bE',
    1778915574,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:53.278Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZlSYH0k65SlcontF08fAL7bVi_3uebf-',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.167Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZnFRW0u4ZlCE4CzeDdjloxeQY3fMK5XD',
    1778914817,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:16.454Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZwdcxgplGi9qKJwkiK0lZMJ1FwxF8NVN',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.014Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ZzDLLEBYSg__GudC3sq0CmiRudI_GHRM',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.690Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_21WsE8fMpiHUEQDqUX0W_PQkSPlak-z',
    1778913433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:12.586Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_5ngv-pTPTGHySUbW05Yi7zmBwlX_bUB',
    1778914820,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:19.118Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_7Nq3cpY_hgbByT9P3fgqPZ-UF9nv1cA',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.250Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_8iJF4Sz8NiB2X1Aivh9El3LO3JaVLwk',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.226Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_BgHgDI2O5NnyuvT4UVTnNHxmJoJqoNH',
    1778912828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:07.665Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_EQsysD5z4vsHGk9poC6pEKCAg7_s4L7',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:02.372Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_NTP3nQ7zk_PfRYjb6gRg7dKJ5H1dvi_',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.031Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_V3xxuaPevKOWO7AwqrPPUqXzDb62gR1',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:01.280Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_Zn4IG3Y8kLyGxJl0nyCoP3R_ZrvfJIJ',
    1778915572,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:51.371Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    '_xDAvj3tp5XKh7hSbnpfwR4GwxwdVfUn',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:50.439Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'a2iVW9RVajtBE1SpXjRIn_cvzabL_DPz',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.866Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'a8mZXpAvTEleSiqocDpd5DGZtx_cw8AT',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.247Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'aCvK8n7jtiftgjHUZRwLf_4DgEbn0Boh',
    1778913414,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:53.645Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'aKVc2efCyeq8O7Nc2IWNg3L0vlHfzaV9',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.422Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'aikYYYfs0cIVom_JiJbBiusAu0xGBmMm',
    1778918986,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:44.443Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'amwrl9wD6yIU50mBcQa5rMlrirsviyjI',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.554Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'axkAX5Hf6jYad6cYsa5O3F5Wc8NvnmGs',
    1778918993,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:51.718Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bAuwDcO8XTCmjVjjz3n4BqrjknbXJYCP',
    1778912845,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:23.723Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bFFIkg6bPtAiWJOJeJP0B2Vd_2BWILdL',
    1778653177,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-13T05:25:02.435Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":83,\"role\":\"user\",\"email\":\"Designer02@1.1\",\"adminId\":34,\"role_id\":45,\"userName\":\"Designer 02\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bFnu3kEf0st0JtugXyFAIAjZ-UoMyeNT',
    1778914801,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:59:59.886Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bLyhGu6hMW2Qt9yCyIsKdZj8-OIDN7rP',
    1778912828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:07.176Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bPlMLm_2pMXw5Phfc0OtvqNTQp0Rnyr0',
    1778912848,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:26.653Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'b_e6amO3cFD5PBP2ADYrbKv4Zp-APiVW',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:49.610Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bcRIcThX-4a-cJoMwnuVG9-IHDJP1HOF',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.728Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bnUix7n-ECpln8r9uIErHQNeGKGkkaof',
    1778912829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:08.008Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'bwgLkFkhXT7u5s7r6UH52ixHQmAW8l2n',
    1778914815,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:14.112Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'c-4IRaxN5TwrtAHEnDH1fwH7iqK46Avy',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:17.300Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'c5a1Uw6Oy1gIqbggVGoSqv2pGhapAOEU',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:03.634Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'c9-UB9UR11Df6wDZPlIMG3SAC2yJLfBu',
    1778912851,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:30.239Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cA9SE9io62TVJEFM8iVMNTq2xHjzonef',
    1778913420,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:59.595Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cCZ2os0oCYagV_1t0wYlitfKkFipwVwx',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.222Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cLMox798MyANAxr-JGsAYSG7ChCt6j1S',
    1778914812,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:11.373Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cTfQdNUkqnm9FODARV6oXftZl9JJCp96',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:16.454Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cVqOp5BZJdhdbC9cyWtx9DeqBhsmk_uL',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:50.731Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cnZsRPvn8QlO6RwzLYoWoQ2x3bxGPlLL',
    1778913410,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:48.873Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cqfeTyWUrxnKbMzTs4ElHPm4iPiVYSv0',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.996Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cs-ncsE3XrD6Er8gH9M5eG9NW5EFyApS',
    1778914819,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:17.877Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'cy24crqv1XqgYq9p3PuUq5DB0SH9q7k_',
    1778490549,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-11T09:07:49.381Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'd07HTzbWcL39VUjkjsXvIFaWTZ6M8bta',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:16.115Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dMBNdgshNFoB2yd0l6bsvpZTtLIMx_Fo',
    1778743228,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-14T04:05:56.083Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dMjPFHsEm-CemKHyZyiiSCE5_RPXfnUW',
    1778913416,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:55.411Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dO5t-NcBVK0l8fR6GUnTEvae1CO6g9me',
    1779513905,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:11:54.191Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":226,\"role\":\"user\",\"email\":\"kevaldigirivera@gmail.com\",\"adminId\":39,\"role_id\":61,\"userName\":\"Mihir\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dWL3VctXxeE3o0RMqSuZyH23lihV8v4y',
    1778920450,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:09.952Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dYmL58KJSzwjMYIExVBa7NiBBtk6Sy5B',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.918Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dZOF4bIIW77ruPf5Kgv91_raZpJB7rPM',
    1778912829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:08.618Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dfh5FTq74Vj4l3NQj82jkpMV9xlUbiJj',
    1778912826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:04.686Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'doVQ8gPG4ZznWpUs8WYgaps2-kAXJpjN',
    1777035620,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-17T06:22:47.355Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dtn-GkAz_uuMIIY2luLGaL4GOdkWJ2An',
    1778914813,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:12.383Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'dw3ZtlKHKdGc01xTgRyu3umhg-pkiuGa',
    1778913428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:07.126Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'e0OP2xJV5HC9iO8MXvpd4PgpZvlhIglj',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.768Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'e5ZqAqHQeMCx1M3xDgBg9i7uHNX0bgwi',
    1778914810,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:09.145Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eDgSo3sT0Z9rzZ55qFIlonOVodgaFzKl',
    1778914805,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:03.928Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eMStdyU6EQH1SPUMDZMUV-yQIB4DzgHL',
    1778915572,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:51.524Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eRFL1k0qOD0yEQNFE6YToYLfZXFJuO8a',
    1778920448,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.011Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eVnsKKbtz-4omdpCBJp52zzxja3XDeh0',
    1778914809,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:08.483Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eZCZRl9FY-nTy5LnU0FpQuTtLsnNxtwZ',
    1778903588,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:53:07.600Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":69,\"role\":\"user\",\"email\":\"vimal.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Vimal\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ehX2DH_dxaO6HzEnOcVnL2a3CWcUKC76',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.520Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eiSjyqCRtE3ijvPgsvOo1_VUZP1H_0lI',
    1778913421,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.330Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'eiont2ZBfw-8CbqvkOczDJMMQVmG4mKg',
    1778914816,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:15.353Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ejpaMYb6VJWlr7XabZbu6xcRzAlR9wnk',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:02.569Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'f-lpR2vLOkgs0hVpM4DThtKcuUHGbFts',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:56.157Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'f62laYD1Md4tGZmQk7nQB_Ej3TlNJ3q9',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.505Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fG5bhMuBUMH-Btnv0ZE3ToC25eGRPx4V',
    1778912829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:08.502Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fJLcJQpskJSC69tQ-WwNrhYhNbUrSoN8',
    1778912835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:14.391Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fToJMlv89lvetLv7dGqpLYxh0dzdMIS1',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:50.891Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fYBMDLzAoapFEDgnVk7lqN-bFk_Zv2_K',
    1778913434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:13.633Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fZhLTsO-aXYOpFM9O4LrWn_5v8v5EYV0',
    1778912845,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:23.503Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'f_yLkr4KPUtuDqCui4XnoB1IpXiQKZiy',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:56.612Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fhGGfsKCNJvxa2go1ctRMC5TTDMDfIvG',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:21.076Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'flGf4twBeWWm3L1Xm2sv_T6XzLJX6FEh',
    1778913410,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:49.142Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fun9dWaLvflG18zQxbkKd354OY2C0Jt-',
    1779264385,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-20T08:05:18.430Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fwkJPzkdSRqY8M8Xesf9VWFRDOAJaQFR',
    1778913410,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:49.389Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fx47m_UWuLaflufNw3Rml9qkbggKnu_d',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.622Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'fxbupeosdcUUD0riMFpD8p-c3TH2c8C0',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:46.559Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'g-BSSybZuomZkSxVRLhj3ZAChFPvzvdT',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:10.756Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'g-mPvLCIxf7xceqOsyncKNkHZUMWboZ6',
    1778920440,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.069Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'g3Yotjo9zFtVYDVNedN3jY54TOdOW6ri',
    1778913427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:06.365Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'g75auRzZQ_7KBw_2eR7LUDFgcDUul-IO',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.853Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'g9zs0NuxuG1UDFnTT-rU9HfNS80Yzehl',
    1778918990,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:48.451Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gHP6kmLCIj71EFCIWxQT0CPLSYMU60y1',
    1778913415,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:54.756Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gJC4HbsIiUUfQt8X6ian7BUjEBH8_Yb4',
    1778913414,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:53.325Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gJCrezZgI-bOfvGCIUzebgyoRPLchOxQ',
    1778912840,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:19.319Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gK_0n_cl4_3BRSqsNEqNDP5fRcyK3i4B',
    1778913415,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:54.474Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gMuDuw3CWquEnel3DEPORo64s1j5CgZS',
    1778912835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:14.070Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gc3vCnKuWjeUjQcsPSMF0ieTXV4VrfZM',
    1778912850,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:29.044Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gc3w_hv6qEO2cYjIGgMw50izy29EwFw7',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.726Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'gpdseO6jlbZsWG5ibedzRCmJvvgm2QvN',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:39:28.533Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'guytpry_ieEs7qf6xJttdGBdOjjGo0Gr',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.918Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'h162yW-DY65lbMbJZlqi-KN4ZnyXA6fu',
    1778913434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:13.322Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hBowPvQDkB1XDFDLw5iNxLGb2qZ9_fA3',
    1778914824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:22.897Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hG1QDlA7o5lEeS9FITB7bJfxY-BEvhO4',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:03.198Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hOcXMBzljHnIbmFjQ9NTBI2AundvoAWJ',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.417Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hYyo2YAph37NgYONEPtOLMOaJAP_z2J7',
    1778914815,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:14.365Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hfkZ7h76Cn06GQA2IfhpvPdbxVkm_llr',
    1778914811,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.134Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'hhtGhF4-1Q5nWgeSpYxOlyjb6075YGTs',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.924Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iDj0zkshiwsA--0B2yQW0DnXrLihxfol',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.807Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iNKVVa2c5ZTNekWsPPmWSbwhh3P0B2e6',
    1778913434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:13.091Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iWTHMKfmyt6NuoSohpr2kW_NChWT-K99',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:26:33.921Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":66,\"role\":\"user\",\"email\":\"farhan.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Farhan\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ibBrkG4uPuySBj1OB02p-GMjIWzVSBbk',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.131Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ibE1Efp8HKLzMNVyQ3fp3mpx6722XI2Z',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.349Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ibWEteasW-AjilpfDsWLdnh_G2h16yUe',
    1778920431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.266Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ibaobtd-0JQl3X07pmaofwqJJFXHa3xM',
    1778914810,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:08.876Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ickaWt9aIuWTV3Mz4nDaHb3e1AMF-FRW',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:06.234Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iewC7bbv_v9OuE6Ei_TfESFLOWJe60Bp',
    1778914817,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:15.856Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ihNi2Ltk_7qhlGimiTQE6wGYnFQKHpVK',
    1778918989,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:47.716Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ihWyMURH8KrtetjZd6cxpkjTdyAqOAIS',
    1778913430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.317Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iitFDEfZWZnMcASg-sMIhnsNntcGBkNK',
    1778912833,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:12.572Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ilLbmUINifOCrlxPE9KIPEOQwldZOhpv',
    1778915573,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:52.300Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'im_OlY8PkwIzPBW5Fnrx5DJc90R0j1LT',
    1778914804,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.719Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'iqIl0XDM6Phdl6C1gq7zYeaHAdiHKxxB',
    1778912837,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:15.564Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'irGxAyfokqQrdEcpxg4xBu8s0FGr_eJc',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.110Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ixPiHRJZZtMsKXwp2LtjyYXypXjayzQA',
    1778913435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:14.435Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'j1asYSOXmty5MJ76VwB5bXDWGTyuzGot',
    1777202990,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-26T11:26:07.646Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'j1sLhUxOSWmTfXrY4LgbUbcGrrI0lQXi',
    1778914826,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:25.376Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'j5OuPuuFPUoX1V2Dd3_HptynfUym2Q8s',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.572Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'j77nqHhMY3jRIUozdUtb4VBs8db5oXHc',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.184Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jGJX_06LeRXhULUNwb3cO7MXY0p4v7lo',
    1778914805,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:04.198Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jSviYKZqEmPdRyOCc_GDIf1_VleIHgVN',
    1778902967,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-16T03:49:03.483Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":71,\"role\":\"user\",\"email\":\"mohitdoriya2@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Mohit\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jTXwMcAKAwbQQ8OTVPXrOLBDuf1HrALY',
    1778914830,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:29.201Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jTq04dg6F-oHHtAc8JGqvGzEHFeCdUfE',
    1778912840,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:19.524Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jW_2zGOdG3tNOzVxHC6E4rEObPoAQmVA',
    1778912836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:15.042Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jdd3efZDYkey8rmrU8tJi9Y4Eju374yj',
    1778914824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:23.389Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jk73IjVfKYqv4KQwWpk7U1_JOFRQC91d',
    1778914809,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.953Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'jpUPiMnRCrfIH7-Uu1Q0fkVlwXLTdEkN',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.976Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kNcvIEWYH8R-sRi7s6mEnVUvKXG9GTx3',
    1778914828,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:27.151Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kOOCkXRzSPoNqfNGMWcKGHKz-FxQy-Ep',
    1778914802,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:01.105Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kRiejbeEvqszkdQGZSyH75SStkHirwgG',
    1778912845,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:24.056Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kc1cSi5I-vQbgB45V8k2ZROhWEH1vdus',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.419Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kdSTjkQaCb_Bce6KuRS2R9jSwFDbDIJN',
    1778914803,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:02.372Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'keb4eGzOATGNZA5nayHtb6UlJyQ6rHZS',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.084Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kr56TRVqAuoZlf0i2hvU90OHaHYVXpNV',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:15.721Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kxtAoL14SmM2FSDykvzTlYkczAOXZZIB',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:01.107Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'kxzWhgFwmxSDgppJMN1qiK3H3r0qqEB2',
    1778913423,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:02.736Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'l6SW13gg_LQkNBjZdYycZEM_r2taLKfx',
    1778918989,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:47.717Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'lOKWYBKhT29vwlo_IWmBKvIGuRET_6i4',
    1778914819,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:18.513Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'lW94cooMi3LDSCD326uP_V6jxB_Y3PHZ',
    1778914812,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.970Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'lazHaTOnTDIDAzb5Lihr_QkUiKvCoboN',
    1778913419,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:58.338Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'loOJxZqr-NfsxhN72moLYzffBtfknzcz',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.482Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ly0UyOROs1VrD_x7akAR6hY1ZNIP7vPV',
    1778913421,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.331Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'lyaRteyCO7Wft7N6_iC9VnUaWT0bJ7AD',
    1778920430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.808Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'm2PWbCX9m_eiKn5SdAKxDqOx79i23oXU',
    1779015506,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-08T06:48:09.436Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'm2pS60hep0NLisCeDepNX77TlzQ5u5-K',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:49.733Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mB65jHP6_v5oYkkTP60NveCwOdi4S0Ad',
    1778913425,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:04.493Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mBAeNVnr-5Ol0qz-UE0ZjUSr2c52oFeh',
    1779513877,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-21T07:10:09.186Z\",\"httpOnly\":true,\"path\":\"/\"},\"contact\":\"digiriveravideo1@gmail.com\",\"userId\":223,\"role\":\"user\",\"email\":\"digiriveravideo1@gmail.com\",\"adminId\":39,\"role_id\":60,\"userName\":\"Harsh\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mCetLM1C-uqfFX01f_f_4-2w2wPn1mlj',
    1778913436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:15.374Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mE0JfDxcOl-5N2ujDGza8f65EPUlcphM',
    1778914816,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:15.148Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mLcRx_lMfNdxLAwH135dltjof18OaV7O',
    1778913424,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:03.360Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mLlKDLJaY55zWmZ8B_6SeMFPW_HuEeEj',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:01.626Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'm_NBe0pb5q-njUxpCBVW-90Ayew7XKPf',
    1778912851,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:30.238Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'maitGHfgkIFyNvgKHqPXWG77lN9ctpyM',
    1778912841,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.011Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mdvDYl6Pq4_cs6Fgn1yxKzA2uVajfzNp',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.185Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'me0CxasaxjckbZjGD51Y2N_r2Hx95KSA',
    1778308793,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-09T06:39:31.845Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":36,\"role\":\"admin\",\"email\":\"rajdeepkanzariya054@gmail.com\",\"adminName\":\"Kanzariya Rajdeep\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mm3hF-kkDS1fMmojc2_yNUnArd-CGAhe',
    1778912840,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:19.050Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mmzjyC1qt9AYWB9t9rLVoRX-aX0UQ5Or',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.756Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mn3D2vvQ6__72cDXHELQal9xVB9f880W',
    1778912836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:14.670Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'msXGvQM-BX2go28twq898j_1bHwG9wVh',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:50.418Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mtLBVG3NxXsKQz2iNpiSzNR4dKf4dj_y',
    1778912835,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:13.661Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mxzmtW4O3t4-C3va3mpLkk1bJQcCyo0c',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.647Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'mzA37uO6F4qaahvcXXRIbzjnHCioxINq',
    1778913427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:06.724Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'n6kDvYFTF1FRI6HeRa_2Pf_4zXG3IZk3',
    1778665498,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-13T04:13:39.833Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nArYaVJjaaZCTsG4SrkP7QS6vig_rkUv',
    1778914812,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:11.518Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nBzUujLcbz5VkP7JXe-3wZCvkaU0x7TW',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.727Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nIYZl_3RVMkZ2T5VVxP8PPkYWErwm-Yw',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.626Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nJXH0z-xrmqqOs12J135vCuAvgkJAGn0',
    1778915565,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:44.409Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nKccOgIKVwhr1qHcKK1fRRWqs2xd8Cep',
    1778912839,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:18.108Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nL2J9r7Bjycc_AWRoH_uqQ7gIHgmCFVI',
    1778915571,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:50.521Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nLz6EZxcYk7A3ATmutd1nttCr_DAV3VK',
    1777619246,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:26.172Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nM8fHxlJyvnaBVwbMNdnGXNxuj6SyyPV',
    1778913429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:08.688Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nTTq0M2G5QO5XRTL0WU01f2AkwVpMwGd',
    1778913419,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:58.339Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nXZDS87qagD1IzRu1VYgfYJE5DTOq5lE',
    1778832661,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-15T08:11:01.332Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nfHst9r_knW-o6y9sb9oTIQdICUGvwQS',
    1778914810,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:09.483Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'npmgGqMkgWMRJErf6F3IwVwkBi2B6DXi',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:15.246Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nrYREewA8BGFnSfS5mXbpHD0CWAKHlzF',
    1778914812,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:11.110Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nshfGLE8_kh6DirAQiWiQEFWaZB7R0Sw',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.745Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nuhFhU_LzV9zJ6oQhyvDCwZxq5hg0nDq',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.422Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'nvBV1dw_NADmp76vo_zq5Rd63xF0AHta',
    1778913412,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:51.333Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'o2XnScqvuvQQ_6vvk_1-xNANjPS9svV1',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.757Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'o9ALD1FEnXzpo3XnkEu4dB-YIpYYQLW1',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.058Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oEUdC0lY6-PqZ4xDojTIB7P4t61BJtPp',
    1778914822,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:21.505Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oGRQk6OptMZAdRFTTpKxHeQzBdkAnXqt',
    1779513898,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-15T08:32:45.241Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\",\"control_type\":\"ADMIN\",\"importOTP\":926487,\"importVerified\":false}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oIUyoPT6FYiYOBzJfOZacsr3mtqqLqRd',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.491Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oV-50C0QBkiIxSnf_5fYs1fnqrNY3bxP',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:55.730Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oVSLp3DEAZHBTJbWp9ytZ6Ue1KZZV16E',
    1778913426,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:05.766Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'obHv84UxjIH4Upyx8qXsgrJDZoLUXr4w',
    1778913439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:18.368Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ocNGQEZg0_XUk7PKCAvMo_Cq5XHplpJj',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.854Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ohC6me2YWO30rmsojCEaDusfceZlMp_6',
    1778913412,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:51.315Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'on5UzaZ0RXIWMAX0YKZ3rilwCv-yDFLE',
    1778915570,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:49.410Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'onKJT4PmzzbRsF9Xn9IW8Njs0IVq5oyS',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:05.999Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'opZoQKi3_84wBmMNx8_GuYXWL-Ck3gEw',
    1778918992,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:50.549Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'oyMv9f509FWuXYEtfwtA4Cgeha3hnO6s',
    1777871617,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T08:49:34.442Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":35,\"role\":\"admin\",\"email\":\"Social.Designs.live@gmail.com\",\"adminName\":\"Dilip\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'p5QtRxDA0rJ7HjNVzHvfLtuk7yYu_dKR',
    1779513818,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-23T04:35:21.181Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":216,\"role\":\"owner\",\"email\":\"swatihr206@gmail.com\",\"adminId\":39,\"role_id\":55,\"userName\":\"Swati\",\"control_type\":\"OWNER\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pD1ks_aZZ9kYjUhf9gh5yOEljmwdY22V',
    1778918987,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:45.808Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pEAdpOE8lcukiWFpQbn7j00Puv-6MSs9',
    1779452918,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T09:36:34.689Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":81,\"role\":\"user\",\"email\":\"janviparejiya@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Janvi\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pFKx84B1gqaMTL2vF_tfsUJffdHnJ-VT',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.854Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pGGXn3M-Tns2YsGrzN5Ki6CHitfnGsY-',
    1778820324,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-15T04:36:51.244Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":79,\"role\":\"user\",\"email\":\"rajdeepkanzariya054@gmail.com\",\"adminId\":35,\"role_id\":42,\"userName\":\"Rajdeep Kanzariya\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pQlsg9Lwd5tpX6FTXGZLrtOsGK_19ZNb',
    1778914820,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:19.466Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pffqumz7KhStx0vNLJAwb8rlZFaXiZfg',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.423Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'pl-k2HbIru45rnuvlFwUWkIuvNMmEhGl',
    1778920436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.209Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'q-1eOU0T0KbDc5pe1O3xSIhj0EQeKnJf',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.767Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qRAeJYEOVxX4SqE_4lmN9PUJ0jJ3SF5u',
    1778912839,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:18.595Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qTCb-L2sTGM0vcGLGTE25Prp84se0X3D',
    1778914813,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:12.125Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qYKCD497MbPrv6T5BGFtvBFiLC9YUWbs',
    1778903836,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T03:57:15.699Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":71,\"role\":\"user\",\"email\":\"mohitdoriya2@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Mohit\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qZ-pmBc6jf3kFDpA0aZwPDv_p_o2hvSf',
    1778913417,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:56.733Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qbJwuVNa7_BXoGvks8SgchcluCvE_xv-',
    1778912844,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:22.998Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qdQ3uQUOpIr9ItogB48GeLSOxutubHY1',
    1778913410,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:49.390Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qdVH6Ev-uEZsUNvu-FXmVjj132YM8HB4',
    1778915573,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:52.453Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'qgH0b-ioTfBnrBj_NroJGL-jF8H7-5E-',
    1778490429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-11T08:46:24.113Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'quasz0Gu4sVc68qwiV_AhkZjjpgfw1DG',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:26.030Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'r-9nzXEZLGZFYiNg4Sm5NqmIO5aNM2n9',
    1778912849,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:28.309Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rCiIDKV4EAc0DZGJHekfSmlO3oOLNmaB',
    1778913432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:11.708Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rFMl49CGp2W0-ue9nBA_hm8zonWYmvEw',
    1778912829,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:08.118Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rHZMqvyNOlvrJS8NDPpBTtD2ducvQWHL',
    1778914820,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:18.862Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rIKKtEekgh5M8a1rCoJe_SRkF4QAxv29',
    1778912837,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:16.347Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rLPwD29atCM73z66eWG5n6QgE5bGQ42E',
    1778913432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:11.076Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rPMatUm-PdDKHIrgKcVOvGLsdaP15wTZ',
    1778920436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.654Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rS4dgg8i6jlkC6PvLaqUvJKwftaH0-iw',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:21.217Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rieM4Qr1iwSepky3grThLjRmW2KtKwrx',
    1778913413,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:52.604Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rj-WHTt36N_8HtGdqkhSltxjtxDx6z7o',
    1779276942,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T04:50:22.819Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":67,\"role\":\"user\",\"email\":\"chirag.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Chirag\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rm_I_iDmCBjkuM_wys-TOi2G8MdXYtL_',
    1778913428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:07.771Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ruGMUCz2vxlgbAj9Kqw2E-detH1LOlEO',
    1778912841,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.273Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rwBpsBvpUBrNuNgeqB5xr8QcjqluoTKd',
    1778912824,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:03.355Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rwfTvkitlA3jjJCgYlirFOG292B770vJ',
    1778920436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.655Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'rx7SpHcUXDjV5P23snizl0ksZDqfwOhW',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.573Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    's2kwr0RFtJdEhGob8VZuuzP6stU2ObMj',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.714Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    's8O9iTa_kgCk267oz07xNVZe75hPqnLD',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:02.415Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sGlk59CJO2atbUnk8jyhTZg_coCHR9K9',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.883Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sJANwQ8d6nxtvFku35G1B8T3gT5X39fF',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.692Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sOgVQOtQ9GenKTLex_N7YYZHyRhX2uUN',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.238Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sRq8QZC7WkQA6jKBQcr20Y4J4EMdu6_s',
    1778912840,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:19.661Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sSPOvXLEXM6K6aVRfuQVBuCAn4q9zSzA',
    1778073987,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-06T12:55:32.833Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sZgQiX1a-lyFCv9hR8nhFdTMaJX6Gi1E',
    1778914814,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:13.176Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sa4s-VnEvn0nGJ7t07-5npTU-txVTRqv',
    1779441827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:09:39.316Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":68,\"role\":\"user\",\"email\":\"ravi.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ravi \",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'scMuItsCkqOzYpDVpgBLfKc8VHaNwibK',
    1778912838,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:16.511Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sq5ABIRdq6-mtPvu9j7c8R8-4Wb8t7ye',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.648Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'srjDlUookke-G5_Khsa6BMJ-qmoSEpQ9',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.926Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ss3vZ86sGEG23oMYUarP_sydrSAfkMoF',
    1778914800,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:59:59.621Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'swEZoXXs9xk1VFIX5I9WBlVsraD4zZqb',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.350Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'sxiOaXOpx-zN48OAtDTsg7X0-cNbwe1y',
    1778920447,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:07.132Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    't0GE3JUgvI7IdU0XJLiwXyv0mYy2by3b',
    1778914814,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:13.380Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    't3vYPXNmsYuFWIAmwfzuguq4cc_XrT1h',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:51.519Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    't4N5jKXEWcOhzvQxN6qJVLtIk8lTh-ma',
    1778920437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:56.572Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    't67lVKhPTIOlEYnh9a8Joj-eOikXZW5u',
    1778914816,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:15.193Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'tEctauzbHdzs8IjpnojQl11VwJqtsdBY',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:00.691Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'tLvF3eWi18cIiHfQ-jJq4DQAIBfT3AwB',
    1778915568,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:47.258Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    't_DkURM-ZG3xrvVuGKc-3e4T6iIKIqCG',
    1778918984,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:42.695Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'tlFcQ67ahYo2E8EDo8InHpVt6PSqPzB4',
    1778913429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:08.310Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'tsTK2MeBZFeRnUWNaBx6GpXEJF_AF6Io',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'tw64tCOZ19154BazxWXAOETj54GuKc2F',
    1778913424,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:03.680Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'txhpGjD7D7s6gdzlFUG890qmo7K9kM7Y',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.995Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'txiYShlWAPliFEvX76FD9LbDFxY-cH5S',
    1778920445,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:04.712Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'u-4Ca6-C_ubHe_p7MAn1yHUKSJ3UXLY4',
    1778913413,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:52.731Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'u4JP2QNwFhtUt8lYW7quv-SFcYylC-wF',
    1778913411,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:50.620Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'u7YKNWW4TEjD6KuwC7QlxtbmytnI3I96',
    1778913418,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:57.362Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uFmnsmu19_H0kN5YFZLT9GixMS1VvZf5',
    1778913414,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:53.209Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uIiXse_JE-KtEg9AHlDSCxDbYIW4THd-',
    1778920446,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:05.925Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uIukb6Vut9rrGWxRcy5OqK9I5nZ_7Na-',
    1778913429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:08.580Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uR5Tkkcm5jBI6LoVI0oXf_8wYzVTYOMF',
    1778998985,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-17T06:23:07.753Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":73,\"role\":\"user\",\"email\":\"chauhan.manoj6866@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Manoj\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uRjf71Id5e9yJk6BJIIZw1JO53d6B8RE',
    1778914821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:20.374Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uRzeD40nDz5Wy5FCvsU8PlMedcD0slTb',
    1778826738,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-15T10:28:43.544Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uWoB_prLamr-RLge6jz63tEDB_vsNMow',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:06.176Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ujUvvCJUCnbSHbagVfFF2ciHPK3lQGIX',
    1778920432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.348Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ulfohe1M9BDr2OhExy5IkMFd6hcavE4-',
    1778920433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:52.867Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'urBCzMx9s1pZH_yBZmrxKEZ_NI3LGh44',
    1777619243,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:23.349Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'usDrEBTOKdhVGQF7eeu4H-QVLPhG6gZw',
    1779513897,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:41:36.311Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":227,\"role\":\"user\",\"email\":\"niralidigirivera@gmail.com\",\"adminId\":39,\"role_id\":64,\"userName\":\"Nirali\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'usQjPpVLD3-Sgn5fKhJGC39DbiOc7zGv',
    1778914808,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:07.373Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'utssHYOzIYdZuBzF_4Mwojj-0wWxuO06',
    1778912839,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:18.488Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uyDvVKoKhSClka2o9S29U2rROCAmyyPc',
    1778920439,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:59.419Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'uyTVI-hQqrrFkm_DE-G7PmrRgqzu9H7E',
    1778912821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:00.570Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'v-ajqJ0hBzwiLpXYjlZMu0nwTPL2z5MG',
    1778912831,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:10.514Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'v-qoBTHp0LSfw0jpISyFy1SJZJtTiLG1',
    1778912849,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:28.310Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vC3KuoGx83obHC-CX-8Z8O-xfKXurz5n',
    1778913427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:06.364Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vDu3er375sR7whM5Q5dIhxjIduEIQxB9',
    1778913431,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.883Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vQW9zXq9IUWfiQiF08OurBRQqfgeGUsn',
    1778914813,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:12.539Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vSGlFi1yPlULmYrCCMMKduEM8zDx9Q5l',
    1778912848,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:27.252Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vXOCwJtWyxE1pAnds6vHMOx-XL62mggV',
    1778912827,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:06.235Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'va_Kd82ZMpHSL9BMsRaTQAVPBg1SmqWL',
    1778920438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:58.058Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'voMAceeAn-xB1yPVqrqxcrPYNr0iXuja',
    1778912849,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:27.637Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'vwXc7hV1NUMEdt_fKMuTTYP7Sbux6ma3',
    1779513880,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-23T04:02:29.582Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":35,\"role\":\"admin\",\"email\":\"Social.Designs.live@gmail.com\",\"adminName\":\"Dilip\",\"control_type\":\"ADMIN\",\"masterId\":39,\"userId\":null}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wFE2r2otRUVHu-MummG_U9aT7np_DGoI',
    1778913435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:14.330Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wG4IBa_VHm4-Qh_AmV4B_jmhrN6aQfpW',
    1778914805,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:04.351Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wSS7WmPNT8vB2mfd0pJrpjc6Ij5NoZPl',
    1778920442,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.917Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wXhz5Ny1UdUKqpRypr7hx5NfcdD4yCBS',
    1778915572,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:50.767Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wYkJ6K3b0pP0lXHIU5kg9_e11Hz752O9',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:21.497Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wZyVnHQCKNSmblMPvACBc7Pa3nl84OBB',
    1778913415,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:54.208Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wlXNUAPKpr90Q9eBbjQtYUDSFHE2PPVP',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.129Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wp5Sjbx3qr-qQ8PGb3FuwURPMZ80TGkY',
    1778913436,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:15.615Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wptbUH79ibZOjDB_1vAZAQmCIDe9Hi36',
    1778920428,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.801Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wsTjP4ZpFfrGAZtCEUrO3BRkgmVlRArr',
    1778913418,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:36:57.760Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'wtVvW8o3F4n7vK4x9Mh-V_ZO31w8zkTg',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:49.481Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'x3w2v_QB8vqLKUMtQJ3Lh4SYDoVV9BwO',
    1778915569,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:12:48.255Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'x8i7PgJTogmAB4BkbHl8aHwVUKJV_WuD',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.372Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xE9kVNoLFHm3nC4CHm5RcJl2pRnH6xdP',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.135Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xHbtAHjGuuc92mYKHBz3suGY38_Lww7F',
    1778912842,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:20.647Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xN5nx5_cCNIBOFSfid2p9LVKFyRosJsz',
    1778913429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:08.309Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xNDp3F8acC9NGl96PYYesof1jXPWl8Rz',
    1779274773,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-04-22T04:35:37.553Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":81,\"role\":\"user\",\"email\":\"janviparejiya@gmail.com\",\"adminId\":35,\"role_id\":40,\"userName\":\"Janvi\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xVTYqOiIkbR9i96O9PdzXB3o4EqJyEgl',
    1778913432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:11.288Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xYTvyCtI66Haki2beThcwCRGEsGZWMH3',
    1778920441,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:01.227Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xbnrP6Lo4OEA1GOikcfLKOb65Nwhkt1K',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.184Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xduU4tVC3egXOtPWnj531Flpkr9m8uYA',
    1778913438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:17.615Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xnMbueVxXTe8FyXILLeMFQNP2pJjgtN3',
    1778914821,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:20.009Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'xuC9lmkoL3Q31DaD_DlhNptoGmL5v5sL',
    1778913437,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:16.455Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'y11jSGhxsHDv7g1L4oh56sEx7kVI8e-t',
    1778912832,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:11.122Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'y1ufYjH2uRKUbdKNe0_CpEfEqg9lB0XL',
    1778918989,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:48.580Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'y67wDQcjtVrQBOLu08yZ6JiSOKtK5t9z',
    1778918987,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:09:46.438Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'y7gc1W19BmwFp90kBxMzjNJuB1Mg3sCv',
    1778920449,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:08.792Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yCMuZ8Lc6L11z6zAG_8al0WGc6LT8X3a',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:47.249Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yKN5QnCATvpcNJX5RXy4jFAnPtVRUYPz',
    1778920429,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:48.769Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yNn3DPOR-ylj1DkatcS7A7C2UJcyWfFQ',
    1778913422,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:00.861Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yVjKwaO5_xyFYe_6v9i5z13B4OHl08no',
    1778914807,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:06.508Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yWsX_rUU8wkgBBfcwIu6RawDuW5yJ40B',
    1778920427,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:46.903Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ycc8kTWYzUQc7GBRKTiLfkIt4qz7uFkX',
    1778913433,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:12.350Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yd-5RXwGq-sZzKIU16NhLjQwQLZuv5zp',
    1778913430,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:09.105Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yiQwj0SXMUpQqo3bgtPPGiZO4x9N_I3z',
    1778913438,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:17.723Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'ypOaN9VXlfoGoGiOLfaPjVMSS3Ltgd_9',
    1778913424,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:03.359Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'yu3Av1JDKi8azGSsGPUxPjOQPNTR2n8_',
    1778912823,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:01.797Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'z3Lze0dEcMq4fgD1HjmRVGkw_RPii5Bj',
    1778914806,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:05.027Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'z6LtkrKTs6MhCnHTCK4eK6T6r-TumNZx',
    1777619246,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-01T07:07:26.112Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":65,\"role\":\"user\",\"email\":\"ashish.designs.live@gmail.com\",\"adminId\":35,\"role_id\":39,\"userName\":\"Ashish\",\"control_type\":\"ADMIN\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zCOOIex18Yrjuc0bxGly478c1QwP6RZY',
    1778912837,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:15.718Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zCt5fdVKl7OVd14W7rZ3AYLyfUmpFVsC',
    1778912847,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:27:26.492Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zGUWT0l-lZcNcjLB4SN3BcTJK9wCBXfp',
    1778920435,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:55.185Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zLsHvN_fr-Ax8MmJAcX9jJSoiwT4w12K',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.729Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zcH0IvwMa8jYmikNCe0Dxr1nVuH9zJME',
    1778920434,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:33:53.728Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zjN551W8yc1lrIFDx_Hd-icCVPAZaU6b',
    1779513887,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-22T04:12:25.034Z\",\"httpOnly\":true,\"path\":\"/\"},\"userId\":218,\"role\":\"user\",\"email\":\"happydigirivera@gmail.com\",\"adminId\":39,\"role_id\":58,\"userName\":\"Nidhi\",\"control_type\":\"PARTIAL\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zmzvLrIAflR1VC9hdkwylgaaDXfA8hDX',
    1778913432,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T06:37:11.178Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zomNDR7f_CZOWssqqrXOCdelQBMXxDxN',
    1778920443,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T08:34:03.249Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zsQ59FiT60hk6vODrfNARbwOuy8SCgwM',
    1778914801,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:00.156Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );
INSERT INTO
  `sessions` (`session_id`, `expires`, `data`)
VALUES
  (
    'zyf47Wsuh-DJBg8Fn7-btQdnT3d0TpRL',
    1778914812,
    '{\"cookie\":{\"originalMaxAge\":2592000000,\"expires\":\"2026-05-16T07:00:10.839Z\",\"httpOnly\":true,\"path\":\"/\"},\"adminId\":34,\"role\":\"admin\",\"email\":\"jay24632463@gmail.com\",\"adminName\":\"Jay\"}'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tasks
# ------------------------------------------------------------

INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    455,
    35,
    'Agriwood Striker Lable 1000ml',
    '',
    'LOW',
    '2026-03-11 00:00:00',
    69,
    69,
    'user',
    'UPDATE',
    'OPEN',
    '2026-03-11 05:21:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    456,
    35,
    'Agriwood HD Graviti Lable 1000ml',
    '',
    'LOW',
    '2026-03-14 00:00:00',
    69,
    69,
    'user',
    'UPDATE',
    'OPEN',
    '2026-03-11 05:22:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    472,
    35,
    'Brilliant Sanitaryware Reel',
    NULL,
    'MEDIUM',
    '2026-03-15 00:00:00',
    68,
    73,
    'user',
    'TASK',
    'OPEN',
    '2026-03-11 05:43:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    478,
    35,
    'Sanddy air cooler Reel',
    NULL,
    'LOW',
    '2026-03-13 00:00:00',
    68,
    68,
    'user',
    'TASK',
    'OPEN',
    '2026-03-11 05:52:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    496,
    36,
    'dgfdyuvduvcdsz',
    NULL,
    'MEDIUM',
    '2026-03-11 00:00:00',
    76,
    36,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-03-11 09:16:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    498,
    36,
    'dvdjhvgcxb',
    NULL,
    'MEDIUM',
    '2026-03-11 00:00:00',
    76,
    77,
    'user',
    'CHANGES',
    'OPEN',
    '2026-03-11 09:17:13'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    499,
    36,
    'aaaaaaaaaaaaaaaaaa',
    NULL,
    'MEDIUM',
    '2026-03-11 00:00:00',
    76,
    77,
    'user',
    'CHANGES',
    'OPEN',
    '2026-03-11 09:17:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    500,
    36,
    'vvvvvvvvvvvvvvvvvvv',
    NULL,
    'MEDIUM',
    '2026-03-11 00:00:00',
    77,
    76,
    'user',
    'TASK',
    'OPEN',
    '2026-03-11 09:17:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    511,
    36,
    'sdgdcd',
    NULL,
    'MEDIUM',
    '2026-03-13 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-12 05:16:55'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    520,
    36,
    'ddd',
    NULL,
    'MEDIUM',
    '2026-03-13 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-12 05:17:02'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    521,
    36,
    'f',
    NULL,
    'MEDIUM',
    '2026-03-13 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-12 05:17:04'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    523,
    36,
    'csccscs',
    NULL,
    'MEDIUM',
    '2026-03-13 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-12 05:17:18'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    570,
    35,
    'Bhakti Yatra Logo',
    NULL,
    'MEDIUM',
    '2026-04-01 00:00:00',
    65,
    65,
    'user',
    'UPDATE',
    'OPEN',
    '2026-03-13 03:38:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    617,
    36,
    'edwsdweds',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    76,
    36,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-03-16 09:01:03'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    618,
    36,
    'scscs',
    NULL,
    'LOW',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:08'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    619,
    36,
    'sxwsxscsc',
    NULL,
    'LOW',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:13'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    620,
    36,
    'xsxsxsxsz',
    NULL,
    'HIGH',
    '2026-03-16 00:00:00',
    77,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:26'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    621,
    36,
    'csxsss',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    622,
    36,
    'csxsssc',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    623,
    36,
    'csdcsdc',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    624,
    36,
    'dc',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    625,
    36,
    'dcdcd',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    626,
    36,
    'c',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    627,
    36,
    'cdcdc',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    628,
    36,
    'c',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    629,
    36,
    'cdc',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    630,
    36,
    'd',
    NULL,
    'MEDIUM',
    '2026-03-16 00:00:00',
    0,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:01:38'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    631,
    36,
    'sdssd',
    NULL,
    'LOW',
    '2026-03-16 00:00:00',
    77,
    36,
    'admin',
    'TASK',
    'OPEN',
    '2026-03-16 09:02:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    743,
    35,
    'Cefone Catalogue',
    NULL,
    'MEDIUM',
    '2026-03-23 00:00:00',
    67,
    67,
    'user',
    'TASK',
    'OPEN',
    '2026-03-23 04:34:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    783,
    35,
    'Siya Letterhead Design - Visiting Card banayu tu ae j theme',
    NULL,
    'HIGH',
    '2026-03-31 00:00:00',
    81,
    65,
    'user',
    'OTHERS',
    'OPEN',
    '2026-03-31 10:00:38'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    808,
    35,
    'Paras Insta Post 02',
    NULL,
    'MEDIUM',
    '2026-04-03 00:00:00',
    81,
    65,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-03 03:53:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    809,
    35,
    'Paras Insta Post 03',
    NULL,
    'MEDIUM',
    '2026-04-03 00:00:00',
    75,
    65,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-03 03:53:54'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    818,
    35,
    'Task 05',
    'jklrjklgjfjg  jdkfkjg kdfjklg gjdfkjb fgb bgfb fgn',
    'MEDIUM',
    '2026-04-04 00:00:00',
    0,
    35,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-04 04:46:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    820,
    35,
    'Tasjk  0005',
    '',
    'HIGH',
    '2026-04-08 00:00:00',
    68,
    68,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-04 04:47:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    824,
    35,
    'Paras Insta Post Corretion - Janvi',
    NULL,
    'MEDIUM',
    '2026-04-06 00:00:00',
    65,
    65,
    'user',
    'CHANGES',
    'OPEN',
    '2026-04-06 03:53:14'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    833,
    35,
    'RV Wedding Invitation Insert Page 1:1 Ratio',
    '',
    'MEDIUM',
    '2026-04-06 00:00:00',
    81,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-06 07:00:31'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    834,
    35,
    'Event inside Simant sanskar Invitation Video',
    NULL,
    'MEDIUM',
    '2026-04-06 00:00:00',
    65,
    65,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-06 11:25:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    880,
    36,
    'ryty',
    NULL,
    'MEDIUM',
    '2026-04-08 00:00:00',
    76,
    36,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-07 05:44:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    881,
    36,
    '000000000000000000000',
    '',
    'MEDIUM',
    '2026-04-09 00:00:00',
    76,
    36,
    'admin',
    'UPDATE',
    'OPEN',
    '2026-04-07 05:45:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    888,
    35,
    'crystalvoxx reel design',
    NULL,
    'MEDIUM',
    '2026-04-13 00:00:00',
    67,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-09 05:52:15'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    889,
    35,
    'EKP Letter head',
    NULL,
    'MEDIUM',
    '2026-04-09 00:00:00',
    65,
    65,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-09 07:05:54'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    911,
    35,
    'AF Wedding Hastags - Khushi',
    '',
    'MEDIUM',
    '2026-04-11 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-11 08:15:11'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    912,
    35,
    'TDL Hiring Video Morbi Office',
    NULL,
    'MEDIUM',
    '2026-04-11 00:00:00',
    65,
    65,
    'user',
    'CHANGES',
    'OPEN',
    '2026-04-11 08:15:38'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    931,
    35,
    'Anupriya Wedding Invitation',
    NULL,
    'MEDIUM',
    '2026-04-13 00:00:00',
    67,
    67,
    'user',
    'TASK',
    'OPEN',
    '2026-04-13 04:40:54'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1009,
    35,
    'Pranshi Birthday Invite',
    NULL,
    'MEDIUM',
    '2026-04-14 00:00:00',
    67,
    67,
    'user',
    'TASK',
    'OPEN',
    '2026-04-14 04:00:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1023,
    35,
    'Pranshi invitation ',
    'Princess theme',
    'MEDIUM',
    '2026-04-14 00:00:00',
    67,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-14 06:54:13'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1031,
    35,
    'Brillinat nu start - Read Caption',
    'Jetlu baki chhe tya thi agad nu designing chalu karvanu chhe banayu tu ae skip karvanu chhe... jetlu baki chhe etlu aapde banavsu aa month ma and upload karvanu baki chhe ae upload kari desu... may be aenu approval baki hatu 1-2 post ma ... ane sanjay bhai list mokalse 3-4 month nu sathe em kidhu chhe...',
    'MEDIUM',
    '2026-04-15 00:00:00',
    67,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-14 10:56:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1036,
    35,
    'Ravi & Vishva wedding - Kaizen',
    '1. Itinerary\n2. Welcome Board\n3. Thank you note\n4. Luggage tags\n5. Washroom sign',
    'MEDIUM',
    '2026-04-15 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-15 03:44:04'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1047,
    35,
    'Logging Enable Disable',
    'Aapda web ma jyre bug aave tyre solve kari sakay ke kya problem aave chhe',
    'MEDIUM',
    '2026-04-16 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-15 07:34:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1048,
    35,
    'Multi Thread Design karvanu TMS ma',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-15 07:34:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1049,
    35,
    'Test Karvani chhe product',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-15 07:34:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1059,
    35,
    'Paras Pipe Insta Post 06',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    81,
    65,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-16 04:48:16'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1061,
    35,
    'fghjghjhgj',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    68,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-16 05:04:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1069,
    35,
    'learning photoshop',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    75,
    75,
    'user',
    'TASK',
    'OPEN',
    '2026-04-16 06:34:09'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1071,
    35,
    'Task 01 fhgfh g',
    '',
    'MEDIUM',
    '2026-04-17 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 06:36:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1072,
    35,
    'Payemnt Manji bhai',
    NULL,
    'MEDIUM',
    '2026-04-20 00:00:00',
    0,
    35,
    'admin',
    'UPDATE',
    'OPEN',
    '2026-04-16 06:37:10'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1075,
    35,
    'manji bhai katha banner ',
    'Call kari ne details lai levi',
    'HIGH',
    '2026-04-18 00:00:00',
    68,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-16 06:42:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1082,
    35,
    'Panama Earth Day',
    '',
    'MEDIUM',
    '2026-04-18 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-16 06:44:21'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1083,
    35,
    'ACP sheet order',
    NULL,
    'HIGH',
    '2026-04-17 00:00:00',
    68,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-16 06:45:19'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1084,
    35,
    'Honest Board - mahesh bhai',
    'call kari ne bhav aapi de 9989898989898',
    'MEDIUM',
    '2026-04-16 00:00:00',
    68,
    35,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-16 06:46:03'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1087,
    35,
    'Sukoon Dev logo Update',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 08:01:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1109,
    35,
    'Task 01',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 09:21:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1110,
    35,
    'Task 02',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 09:22:03'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1117,
    34,
    'Task 001',
    NULL,
    'HIGH',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 09:25:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1118,
    34,
    'Task 002',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-16 09:25:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1119,
    34,
    'Task 003',
    NULL,
    'LOW',
    '2026-04-20 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-16 09:25:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1120,
    35,
    'Task 11111',
    NULL,
    'HIGH',
    '2026-04-17 00:00:00',
    68,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-16 09:25:43'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1121,
    35,
    'Task 01',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    68,
    68,
    'user',
    'TASK',
    'OPEN',
    '2026-04-16 09:25:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1122,
    35,
    'Taks 02',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    68,
    68,
    'user',
    'TASK',
    'OPEN',
    '2026-04-16 09:25:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1123,
    35,
    'taskl 03',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    68,
    68,
    'user',
    'TASK',
    'OPEN',
    '2026-04-16 09:25:55'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1125,
    35,
    'Task 0.1',
    NULL,
    'HIGH',
    '2026-04-16 00:00:00',
    68,
    68,
    'user',
    'TASK',
    'OPEN',
    '2026-04-16 09:26:40'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1126,
    34,
    'sfv',
    NULL,
    'MEDIUM',
    '2026-04-20 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'COMPLETED',
    '2026-04-16 11:25:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1127,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-16 11:47:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1128,
    34,
    'sfv',
    NULL,
    'MEDIUM',
    '2026-04-16 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'COMPLETED',
    '2026-04-16 11:47:14'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1129,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-29 00:00:00',
    0,
    34,
    'admin',
    'UPDATE',
    'OPEN',
    '2026-04-16 11:47:44'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1130,
    34,
    'dc',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-16 11:47:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1142,
    35,
    'Wit Switch Catalogue',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-17 03:54:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1149,
    34,
    'other',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'UPDATE',
    'OPEN',
    '2026-04-17 05:02:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1151,
    35,
    'Wit Cooler Reel',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-17 05:21:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1152,
    34,
    'sfv',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-17 05:34:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1153,
    34,
    'sfv',
    NULL,
    'MEDIUM',
    '2026-04-30 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-17 05:34:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1154,
    35,
    'TAsk 01',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    0,
    35,
    'admin',
    'UPDATE',
    'OPEN',
    '2026-04-17 06:49:00'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1156,
    35,
    'DIGrivera',
    ' hsdhjhjdf hsdj hfjgh kjdfgh kdfhg dfkgh kdjfh gkdj jdfhgkjfh s dfghkjdfgkjdhfgkjdfgkjdhkjfghdkjfgkjdgkjdghkjdfgdgdfghkdfgh',
    'HIGH',
    '2026-04-23 00:00:00',
    0,
    35,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-17 06:49:40'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1158,
    35,
    'task',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    213,
    213,
    'user',
    'TASK',
    'OPEN',
    '2026-04-17 06:56:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1159,
    35,
    'rak 02',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    213,
    213,
    'user',
    'TASK',
    'OPEN',
    '2026-04-17 06:56:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1160,
    35,
    'task 02',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    213,
    213,
    'user',
    'TASK',
    'OPEN',
    '2026-04-17 06:56:38'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1161,
    35,
    'hdpl banner',
    NULL,
    'MEDIUM',
    '2026-04-17 00:00:00',
    213,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-17 07:03:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1162,
    34,
    'fv',
    NULL,
    'MEDIUM',
    '2026-04-30 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-17 10:07:21'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1178,
    34,
    'dfbf',
    NULL,
    'MEDIUM',
    '2026-04-30 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-18 04:33:22'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1179,
    35,
    '7.paras insta post april 26',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    75,
    75,
    'user',
    'TASK',
    'OPEN',
    '2026-04-18 04:44:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1180,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-18 05:11:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1181,
    34,
    'arg',
    NULL,
    'MEDIUM',
    '2026-04-30 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-18 05:11:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1185,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'UPDATE',
    'COMPLETED',
    '2026-04-18 05:45:11'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1186,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-18 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-18 05:58:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1194,
    35,
    'Learning advance coreldraw',
    NULL,
    'MEDIUM',
    '2026-04-20 00:00:00',
    81,
    81,
    'user',
    'TASK',
    'OPEN',
    '2026-04-20 03:58:38'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1200,
    34,
    'Fg',
    NULL,
    'MEDIUM',
    '2026-04-20 00:00:00',
    82,
    85,
    'user',
    'TASK',
    'OPEN',
    '2026-04-20 08:03:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1201,
    34,
    'TASK. 001',
    NULL,
    'HIGH',
    '2026-04-20 00:00:00',
    85,
    85,
    'user',
    'TASK',
    'OPEN',
    '2026-04-20 08:03:45'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1202,
    35,
    'Q bits Creative Reel Design',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-20 09:06:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1233,
    39,
    'GSS - 1000 Stitch',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    225,
    225,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-21 07:12:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1238,
    39,
    'green e tech no logey new indistrial work',
    NULL,
    'MEDIUM',
    '2026-04-21 00:00:00',
    219,
    219,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-21 07:13:22'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1239,
    39,
    'Hiring Ads for digirivera ',
    'ai video editor',
    'MEDIUM',
    '2026-04-21 00:00:00',
    219,
    39,
    'admin',
    'OTHERS',
    'COMPLETED',
    '2026-04-21 07:14:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1241,
    39,
    'hiring example sher',
    NULL,
    'MEDIUM',
    '2026-04-21 00:00:00',
    0,
    219,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-21 07:23:36'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1245,
    35,
    'Cefone Booster - Color Change & Table Add',
    NULL,
    'MEDIUM',
    '2026-04-21 00:00:00',
    65,
    69,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-21 09:47:52'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1254,
    34,
    'zdv',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-22 03:39:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1255,
    39,
    'Petlad Solar',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    223,
    223,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 03:42:40'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1256,
    39,
    'Petlad Solar',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    223,
    223,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 03:42:43'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1259,
    39,
    'hr salary report',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 03:50:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1260,
    39,
    'heaven solar cam',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 03:50:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1261,
    39,
    'solar sarthi cam error solve',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 03:50:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1262,
    35,
    '8. Expo Side Banner 10-8 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    73,
    66,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 03:50:43'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1263,
    39,
    'green e tch',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'CHANGES',
    'OPEN',
    '2026-04-22 03:51:08'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1264,
    39,
    'all access in digirivera page and sweta mam account',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 03:52:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1265,
    35,
    '4. Gajanand Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    73,
    66,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 03:55:22'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1266,
    35,
    '2. BJP Insta Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    70,
    66,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 04:00:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1269,
    35,
    'paras post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    71,
    71,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:06:00'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1270,
    35,
    'gajanand post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    71,
    71,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:06:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1273,
    39,
    'vecton solar reel',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:12:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1274,
    39,
    'All client facebook reporting',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:12:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1275,
    39,
    'All client facebook fund check',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:12:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1276,
    39,
    'Qbits video changes',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:13:04'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1277,
    39,
    'Solar edition new camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:13:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1278,
    39,
    'Vecton New camp (CR)',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:13:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1280,
    39,
    'HSepl CP 2 New camp',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:13:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1281,
    39,
    'HSepl Sambhajinagar New camp',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:14:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1282,
    39,
    'HSepl Solar sarthi New camp',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:14:15'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1283,
    39,
    'Radhe clinic new camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:14:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1284,
    39,
    'Suryance new camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:14:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1285,
    35,
    'Q bits Creative Reel Design',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:14:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1286,
    39,
    'Arun content  find',
    '',
    'LOW',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:14:39'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1287,
    35,
    'Cefone Booster - Color Change & Table Add',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'CHANGES',
    'OPEN',
    '2026-04-22 04:14:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1288,
    39,
    'Green e tech post verify',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:14:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1289,
    39,
    'Green e tech new camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:15:02'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1290,
    39,
    'Iconic new content  find',
    '',
    'LOW',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:15:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1291,
    39,
    'Sardar fund  add',
    '',
    'HIGH',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:15:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1292,
    39,
    'Green e tech facebook fund add',
    '',
    'HIGH',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:15:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1293,
    39,
    'Radhe fund add',
    '',
    'HIGH',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:15:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1294,
    39,
    'Iconic solar fund add',
    '',
    'HIGH',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:15:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1295,
    39,
    'Sahyog personal A/C fund add',
    '',
    'HIGH',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:15:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1296,
    39,
    'Shree tiles facebook fund add',
    '',
    'HIGH',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:17:54'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1297,
    39,
    'Reporting',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:18:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1298,
    39,
    'Fund check',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:18:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1299,
    39,
    'Radhe clinc post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:19:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1300,
    39,
    'Qbits page acess update for aagambhai',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:20:10'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1301,
    34,
    'sfv',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-22 04:28:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1302,
    34,
    'ad',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'CHANGES',
    'OPEN',
    '2026-04-22 04:28:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1303,
    35,
    '3. BJP Post',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 04:31:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1304,
    39,
    'Tatvamasi lab stall 2 banner Design and 1 standee',
    'As i guide you design banner for tatvamasi stall. content already shared with you',
    'HIGH',
    '2026-04-22 00:00:00',
    224,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:32:11'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1305,
    39,
    'Np Seatable 3 model reel script',
    NULL,
    'HIGH',
    '2026-04-22 00:00:00',
    226,
    222,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 04:33:45'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1308,
    39,
    'Sardar friend request send in instgram',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:39:10'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1309,
    39,
    'Vecton friend request send in instgram',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:39:44'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1310,
    39,
    'Petlad friend request send in instgram',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:39:52'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1311,
    39,
    'Today post share in group',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:40:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1312,
    39,
    'Qbits story upload',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:40:16'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1313,
    39,
    'Heaven dm reply',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:40:25'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1316,
    34,
    'sdv',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-22 04:45:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1317,
    35,
    'RV RING CEREMONY (MIRROR VINYL) 1.6-3.7 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:56:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1318,
    35,
    'RV DAYRO Welcome Board',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:56:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1319,
    35,
    'RV GANESH STHAPAN & MANDAP MUHURAT Welcome Board 2-3 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:56:40'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1320,
    35,
    'RV GRUHSHANTI Welcome Board 2-3 ft',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:56:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1321,
    35,
    'RV HALDI ( Blue Poetry Welcome Board ) 2-3 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:57:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1322,
    39,
    'I3d reel share in followers',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:57:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1323,
    35,
    'RV SHUBH VAIDIK VIVAH (MIRROR VINYL) Welcome Board 1.5-3.11 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:58:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1324,
    35,
    'HAWTHORN RESORT Layout Foam Sheet 3-2 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 04:58:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1325,
    39,
    'HSepl Indore New camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:13:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1326,
    39,
    'Hsepl CP New camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:14:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1327,
    39,
    'audit report explore for social media account audit plan try 1-2 client',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    39,
    'admin',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:15:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1328,
    35,
    'Anupriya MK Wedding Designs',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 05:17:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1330,
    35,
    'Death Anniversary Invite',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:19:09'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1331,
    35,
    'WIT Insta Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:19:26'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1332,
    35,
    'Cefone Print Files',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:19:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1333,
    35,
    '7. Panama Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    70,
    66,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:20:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1334,
    35,
    '8. Panama Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    70,
    66,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:20:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1335,
    35,
    '9. Panama Post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    70,
    66,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:21:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1336,
    35,
    '4. Campain Post',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 05:21:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1337,
    39,
    'Shree tiles mothers day 1 Cr (5) Slied post ',
    'https://docs.google.com/spreadsheets/d/1yyRUnG2jJSV1VqHxvMp4q5as4oi4Bpw0JPm7ScptmeA/edit?gid=1879540929#gid=1879540929',
    'MEDIUM',
    '2026-04-27 00:00:00',
    224,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 05:22:15'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1338,
    39,
    'Heaven design gmb 2 post upload',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:23:03'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1339,
    39,
    'Shree tiles 3 static post ',
    'https://docs.google.com/spreadsheets/d/1yyRUnG2jJSV1VqHxvMp4q5as4oi4Bpw0JPm7ScptmeA/edit?gid=1879540929#gid=1879540929',
    'MEDIUM',
    '2026-04-25 00:00:00',
    224,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 05:23:22'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1340,
    35,
    'Panama Insta Post 07',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'CHANGES',
    'OPEN',
    '2026-04-22 05:24:11'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1341,
    35,
    'Panama Insta Post 08',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 05:24:15'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1342,
    35,
    'Panama Insta Post 09',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 05:24:19'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1343,
    35,
    'Sanddy Insta Post 02',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    75,
    70,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:24:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1344,
    35,
    'Simron Insta Post 02',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    75,
    70,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 05:25:09'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1345,
    39,
    'Shree tiles reel 1',
    'https://docs.google.com/spreadsheets/d/1yyRUnG2jJSV1VqHxvMp4q5as4oi4Bpw0JPm7ScptmeA/edit?gid=1879540929#gid=1879540929\n\nNote : Ask to meet bhai before editing',
    'MEDIUM',
    '2026-04-29 00:00:00',
    223,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 05:27:43'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1347,
    39,
    'Shree tiles reel 2 ',
    'https://docs.google.com/spreadsheets/d/1yyRUnG2jJSV1VqHxvMp4q5as4oi4Bpw0JPm7ScptmeA/edit?gid=1879540929#gid=1879540929\n\nNote : Ask to meet bhai before editing',
    'MEDIUM',
    '2026-04-28 00:00:00',
    223,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 05:32:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1348,
    35,
    'LFE Changes',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:33:19'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1349,
    35,
    '1. LFE Pamphlate A4',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 05:33:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1350,
    39,
    'Tatvamasi Lab stall banner and standee design and content breif to designer',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:37:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1351,
    39,
    'Explore TMS Task tool and also call to dilip bhai for clear some doubts ',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:37:31'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1352,
    39,
    'Call to Mehulbhai for shoot schedule time',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:41:21'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1353,
    39,
    'Digirivera youtube 1 video upload and 3 schedule',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 05:55:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1354,
    39,
    'Iconic post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 06:00:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1355,
    39,
    'Whatshapp Grp profile photo update',
    NULL,
    'HIGH',
    '2026-04-22 00:00:00',
    217,
    227,
    'user',
    'OTHERS',
    'COMPLETED',
    '2026-04-22 06:01:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1356,
    35,
    'CVX Reel 03',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:08:18'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1357,
    35,
    'RV Hospitaity Desk Easel 2-3 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 06:14:31'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1358,
    35,
    'Cefone Back Wall - 9.6ft (W) x 8.0ft (H)',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:17:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1359,
    35,
    'Cefone Side 01 Wall - 9.5ft (W) x 8.0ft (H)',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:17:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1360,
    35,
    'Cefone Fecia - 9.6ft (W) x 0.8in (H)',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:18:03'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1361,
    35,
    'Cefone Side 02 Wall - 9.5ft (W) x 8.0ft (H)',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:18:44'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1362,
    35,
    'Cefone Table Design',
    'Size dhruvin pase levani chhe... khali logo content ma',
    'MEDIUM',
    '2026-04-23 00:00:00',
    69,
    69,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:19:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1363,
    39,
    'Qbits post',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 06:35:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1364,
    39,
    'Losurya energy 3 static post',
    'https://docs.google.com/spreadsheets/d/1pX9G_XBb-95CtZkrw-Nf4IXwZIqLJSErme4_sncii-E/edit?gid=0#gid=0',
    'MEDIUM',
    '2026-04-24 00:00:00',
    224,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 06:36:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1365,
    39,
    'Losurya energy 2 static post',
    'https://docs.google.com/spreadsheets/d/1pX9G_XBb-95CtZkrw-Nf4IXwZIqLJSErme4_sncii-E/edit?gid=0#gid=0',
    'MEDIUM',
    '2026-04-25 00:00:00',
    224,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 06:36:59'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1366,
    39,
    'Losurya reel 2',
    'https://docs.google.com/spreadsheets/d/1pX9G_XBb-95CtZkrw-Nf4IXwZIqLJSErme4_sncii-E/edit?gid=0#gid=0',
    'MEDIUM',
    '2026-04-24 00:00:00',
    225,
    227,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 06:38:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1367,
    39,
    'Losurya reel 3',
    'https://docs.google.com/spreadsheets/d/1pX9G_XBb-95CtZkrw-Nf4IXwZIqLJSErme4_sncii-E/edit?gid=0#gid=0',
    'MEDIUM',
    '2026-04-27 00:00:00',
    225,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 06:39:06'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1368,
    39,
    'Losurya reel 4',
    'https://docs.google.com/spreadsheets/d/1pX9G_XBb-95CtZkrw-Nf4IXwZIqLJSErme4_sncii-E/edit?gid=0#gid=0',
    'MEDIUM',
    '2026-04-28 00:00:00',
    225,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 06:39:30'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1369,
    39,
    'client update hetal mam',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 06:39:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1370,
    39,
    'KDCC Bank Model reel',
    NULL,
    'HIGH',
    '2026-04-27 00:00:00',
    225,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 06:44:13'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1371,
    35,
    'SM Sangeet Welcome Board 2-3 ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    65,
    65,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-22 08:19:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1372,
    39,
    'Content, Graphic, Video sheet update and new task added',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:38:08'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1373,
    39,
    'KDCC bank model shoot guide breif to vikas',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:38:34'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1374,
    39,
    'Explore and try Claude for social media audit report generate',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:54:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1375,
    39,
    'NP seatable reel script guide to content writer',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:54:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1376,
    39,
    'Np seatable chair model list for reels',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:55:04'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1377,
    39,
    'Heaven reel upload linkdin and youtube',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:59:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1378,
    39,
    'Qbits reel upload linkdin and youtube',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 08:59:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1379,
    34,
    'Tms',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-22 09:14:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1380,
    39,
    'Hsepl Surat new camp',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:31:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1381,
    35,
    'HM Engagement Invite',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    81,
    66,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 09:31:59'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1382,
    35,
    'Rv Wedding Map Banner 3-2ft',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    71,
    71,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 09:38:37'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1383,
    39,
    'Digirivera linkedin conection send',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:43:26'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1384,
    39,
    'Qbits inverter cp post create',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:43:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1385,
    39,
    'Heaven solar cp post create',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:44:44'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1386,
    39,
    'Sardar solar calander update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:44:54'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1387,
    39,
    'Graphics task sheet update',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:45:13'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1388,
    39,
    'video task sheet update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:45:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1389,
    39,
    'Petlad Sojitra calendar assigned to the designer team',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:46:55'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1390,
    39,
    'Shree Tiles gallary calendar assigned to the designer team',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:47:09'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1391,
    39,
    'KDCC Bank video assign',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:47:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1392,
    39,
    'Losurya solar calendar assigned to the designer team',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:47:59'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1393,
    39,
    'Gss video upload',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 09:54:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1394,
    35,
    'SM Sangeet Easel Stand 2-3 ft.',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    71,
    71,
    'user',
    'TASK',
    'OPEN',
    '2026-04-22 10:08:00'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1395,
    39,
    'aqua star camp publish',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:08:55'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1396,
    39,
    'heaven report data update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'UPDATE',
    'OPEN',
    '2026-04-22 10:10:07'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1397,
    39,
    'heaven hiring change upto 30k salary ne 1-2 year expirence',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    224,
    219,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 10:21:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1400,
    39,
    'Sardar gmb 1 post and 1 video upload',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:31:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1402,
    39,
    'Heaven design page access update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:32:49'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1403,
    39,
    'photonova ni script modal vali',
    NULL,
    'MEDIUM',
    '2026-04-24 00:00:00',
    226,
    219,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-22 10:34:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1405,
    39,
    'GSS editing cuts & QC',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:42:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1406,
    39,
    'petlad sojitra & KDCC shoot',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:43:20'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1407,
    39,
    'NP Seatable model Reel',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:44:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1410,
    39,
    'Radhe clinic post verify',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 10:52:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1413,
    39,
    'Arun solar 2 video uploaad gmb',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:04:16'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1414,
    39,
    'discussion with keyur bhai regarding Ai avtar shoot',
    '',
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:05:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1415,
    39,
    'Whatshapp grp profile photo update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:06:36'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1416,
    39,
    'Vecton CR verify',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:21:41'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1417,
    39,
    'Heaven design 2 post upload facebook',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:26:18'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1418,
    39,
    'Arun solar post and reel content verify and prepared excel sheet',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:35:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1419,
    39,
    'Shree Tiles Audit',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    223,
    223,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:36:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1420,
    39,
    'Heaven Audit',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    223,
    223,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:37:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1421,
    39,
    'Heaven design ad account and page access',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:43:46'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1422,
    39,
    'Iconic solar video script  send',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 11:49:39'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1423,
    39,
    'tatvamasi banner client side changes brief to designer and share design after changes',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 12:10:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1424,
    39,
    'Onboading sheet update',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 12:19:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1425,
    39,
    'tms explore team',
    NULL,
    'MEDIUM',
    '2026-04-22 00:00:00',
    219,
    219,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-22 12:25:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1426,
    39,
    'Hsepl JND new camp',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 03:27:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1427,
    39,
    'Hsepl sambhajinagar new camp',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 03:27:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1428,
    39,
    'Iconic solar new camp',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:27:39'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1430,
    39,
    'KDCC Bank',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    225,
    225,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:28:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1431,
    39,
    'Heaven',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    225,
    225,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:28:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1432,
    39,
    'GSS scripting',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:48:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1433,
    39,
    'vecton solar post',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:49:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1434,
    39,
    'petlad sojitra post & Reel',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:49:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1435,
    39,
    'photonova Reel',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:50:14'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1436,
    39,
    'Qbits Reel',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    226,
    226,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:50:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1437,
    39,
    'solcap ni website no map no photo update karavano che wp ma details mokali didhi che',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    224,
    219,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-23 03:50:31'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1438,
    39,
    'sparkle photo aje changes kari ne mokal jo',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    224,
    219,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-23 03:51:55'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1439,
    35,
    'Paras Insta Reel 02',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    65,
    65,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:53:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1440,
    39,
    'Gss Video upload in linkedin',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 03:54:25'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1441,
    35,
    'Sanddy Reel Video Generate',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:00:24'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1442,
    35,
    'Sanddy Post Schedule',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:00:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1443,
    35,
    'Simron Post Schedule',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:01:02'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1444,
    39,
    'Heygen shoot + Generation ',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    223,
    223,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:03:08'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1445,
    35,
    'Maharshi Nalanda 4 Banner',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    35,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-23 04:03:21'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1446,
    39,
    'video script for digirivera meta ads',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    226,
    39,
    'admin',
    'OTHERS',
    'OPEN',
    '2026-04-23 04:03:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1447,
    39,
    'solcap post changes',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    224,
    224,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:03:36'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1448,
    35,
    'Wit Scheme 05',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    70,
    70,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:05:31'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1449,
    39,
    'SURYANCE NEW CAMP',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:11:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1450,
    39,
    'Reporting',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:14:21'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1451,
    39,
    'Fund check',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:14:25'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1452,
    39,
    'Radhe Clinic video  assign',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:15:28'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1453,
    39,
    'All client facebook reporting',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:17:00'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1454,
    39,
    'Today post share in group',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:18:58'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1455,
    39,
    'Story put client page',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:19:14'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1456,
    35,
    '7. Campain Post',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:20:08'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1457,
    35,
    'BJP Ad Post',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    66,
    66,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:21:23'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1458,
    39,
    'heaven hiring new post banavani che wp ma details mokali didhi che',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    224,
    219,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-23 04:23:32'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1459,
    39,
    'Hsepl fund add',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:26:29'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1460,
    39,
    'I3d jewel highlight cover create and update',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    227,
    'user',
    'OTHERS',
    'OPEN',
    '2026-04-23 04:28:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1461,
    39,
    'All client facebook fund check',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:29:57'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1462,
    39,
    'Triwatt infra new camp commercial',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:30:16'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1463,
    39,
    'I3D New camp new Video',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:30:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1464,
    39,
    'Solar edition new camp video par',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:30:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1465,
    39,
    'Shree tiles psot verify',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:30:59'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1466,
    39,
    'Shree tiles new camp kitchen sink',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:31:14'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1467,
    39,
    'Heaven cp post',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:31:42'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1468,
    39,
    'sparkle post update',
    '',
    'MEDIUM',
    '2026-04-23 00:00:00',
    224,
    224,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:34:27'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1469,
    39,
    'wpa 3 video schedule',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    216,
    'owner',
    'OTHERS',
    'OPEN',
    '2026-04-23 04:36:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1470,
    39,
    'Tatvamasi standee design changes and design verify before share',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:39:11'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1471,
    39,
    'TMS task manager tool use breif to editor and designer team',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:39:43'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1472,
    39,
    'KDCC reel data and brief explain to editor',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:40:53'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1473,
    39,
    'Suryance solar fund add',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:45:48'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1474,
    39,
    'Petald fund add',
    NULL,
    'HIGH',
    '2026-04-24 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:50:33'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1475,
    39,
    'Spine 33 facebook fund add',
    NULL,
    'HIGH',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 04:51:05'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1476,
    39,
    'Vecton fund add',
    NULL,
    'HIGH',
    '2026-04-24 00:00:00',
    220,
    220,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 04:51:18'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1477,
    34,
    'sd',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-23 04:55:47'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1478,
    34,
    'sfdv',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-23 04:56:40'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1479,
    34,
    's v',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    0,
    34,
    'admin',
    'TASK',
    'OPEN',
    '2026-04-23 05:02:51'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1480,
    39,
    'Shree Tiles  ad post-1',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    224,
    224,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:05:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1481,
    39,
    'Shree tiles dm reply',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:10:56'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1482,
    39,
    'Digirivera reel upload',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:12:17'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1483,
    39,
    'Losurya instgarm page update',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    217,
    217,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:12:35'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1484,
    39,
    'Triwatt infra new video script',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    218,
    218,
    'user',
    'TASK',
    'COMPLETED',
    '2026-04-23 05:20:01'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1485,
    39,
    'Talk with Bhojraj regarding tatvamasi banner design change',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:20:50'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1486,
    39,
    'NP Seatable model reel script review and share to client',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    222,
    222,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:23:12'
  );
INSERT INTO
  `tasks` (
    `id`,
    `admin_id`,
    `title`,
    `description`,
    `priority`,
    `due_date`,
    `assigned_to`,
    `assigned_by`,
    `who_assigned`,
    `section`,
    `status`,
    `created_at`
  )
VALUES
  (
    1487,
    39,
    'Digirivera video upload in linkedin',
    NULL,
    'MEDIUM',
    '2026-04-23 00:00:00',
    227,
    227,
    'user',
    'TASK',
    'OPEN',
    '2026-04-23 05:24:37'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: teams
# ------------------------------------------------------------

INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    2,
    36,
    'DEVLOPER',
    '2026-04-10 05:17:48',
    '2026-04-10 05:17:48'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    3,
    36,
    'DESIGNERS',
    '2026-04-10 05:17:54',
    '2026-04-10 05:17:54'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    4,
    34,
    'Sales',
    '2026-04-11 04:12:18',
    '2026-04-11 04:12:18'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    5,
    34,
    'Account',
    '2026-04-11 04:12:34',
    '2026-04-11 04:12:34'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    6,
    34,
    'Designers',
    '2026-04-11 04:12:46',
    '2026-04-11 04:12:46'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    7,
    35,
    'Designing',
    '2026-04-11 08:39:59',
    '2026-04-11 08:39:59'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    8,
    35,
    'Sales',
    '2026-04-11 08:40:08',
    '2026-04-11 08:40:08'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    9,
    35,
    'Super Admin',
    '2026-04-11 08:41:10',
    '2026-04-11 08:59:14'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    10,
    34,
    'Owner',
    '2026-04-13 04:14:13',
    '2026-04-13 04:14:13'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    11,
    35,
    'Account',
    '2026-04-14 09:49:08',
    '2026-04-14 09:49:08'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    15,
    39,
    'Management',
    '2026-04-20 05:17:42',
    '2026-04-20 05:17:42'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    16,
    39,
    'Sales',
    '2026-04-20 05:17:48',
    '2026-04-20 05:17:48'
  );
INSERT INTO
  `teams` (`id`, `admin_id`, `name`, `created_at`, `updated_at`)
VALUES
  (
    17,
    39,
    'Execution',
    '2026-04-20 05:18:15',
    '2026-04-20 05:18:15'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: users
# ------------------------------------------------------------

INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    65,
    35,
    39,
    'Ashish',
    'ashish.designs.live@gmail.com',
    '1234567891',
    '$2b$10$1yN7EQcsMr8UtF8r.qXVbeQqnTEyY15xahoJFd4yoLf8CjMTjzw8a',
    NULL,
    35,
    'ACTIVE',
    '2026-03-11 04:14:41'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    66,
    35,
    39,
    'Farhan',
    'farhan.designs.live@gmail.com',
    '9624760413',
    '$2b$10$s1lhYJmcD31SXTo2kLWtXuCrbx2vyjcQVgJayRzxLxsi7eC44Swa2',
    NULL,
    35,
    'ACTIVE',
    '2026-03-11 04:15:58'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    67,
    35,
    39,
    'Chirag',
    'chirag.designs.live@gmail.com',
    '',
    '$2b$10$omzCHPCAUObqh3b1eVgriuPMZG4hlmDdWHC6eNOD55qTpRJLgpwEW',
    NULL,
    35,
    'ACTIVE',
    '2026-03-11 04:16:53'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    68,
    35,
    39,
    'Ravi ',
    'ravi.designs.live@gmail.com',
    '9154879584',
    '$2b$10$ZdSbaHoLqGlFesa1u2OkhOrHT/kxEWkq.n9nWbmTMzy782ybI6rNe',
    NULL,
    35,
    'ACTIVE',
    '2026-03-11 04:17:46'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    69,
    35,
    39,
    'Vimal',
    'vimal.designs.live@gmail.com',
    '4569823145',
    '$2b$10$w7x0dnvBoSlODbl/Neal6ejkB.ISnViPjzr9jY0pXmefaUSI/XXHa',
    NULL,
    67,
    'ACTIVE',
    '2026-03-11 05:15:32'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    70,
    35,
    40,
    'Hardip',
    'Hardip.designs.live@gmail.com',
    NULL,
    '$2b$10$xb0gh7X/0Yh7q7Buj1LFiuYxgTtPyYfxYzSNpTpESMEAvO89F31sS',
    NULL,
    67,
    'ACTIVE',
    '2026-03-11 05:17:11'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    71,
    35,
    40,
    'Mohit',
    'mohitdoriya2@gmail.com',
    '9316916047',
    '$2b$10$fjaiq0KTmvHI6/pwFfimSOa1BPmpi9dJvaa95Fac.HH5ybeG5SkBm',
    NULL,
    65,
    'ACTIVE',
    '2026-03-11 05:23:00'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    73,
    35,
    40,
    'Manoj',
    'chauhan.manoj6866@gmail.com',
    '4444444444',
    '$2b$10$o/EjAhDKMrZq6TqU9gZvn.PxUYofTD3.HCXTY.uJA30CQ1Bn6m6QG',
    NULL,
    68,
    'ACTIVE',
    '2026-03-11 05:24:19'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    75,
    35,
    40,
    'Nehal',
    'nehalmori470@gmail.com',
    NULL,
    '$2b$10$Btw2Im.ANTVoKy/BYbBobOOSs7pKsVM1wKvlL4/BzVGFkENgF5EkG',
    NULL,
    66,
    'ACTIVE',
    '2026-03-11 05:36:56'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    76,
    36,
    41,
    'jay',
    'jay@1.1',
    '1234567890',
    '$2b$10$JI02h8URZyynmvVL3xNCBOeHV2XlN3KgcgNB2VEQZ5jQ9vq12XsR.',
    NULL,
    36,
    'ACTIVE',
    '2026-03-11 09:15:31'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    77,
    36,
    41,
    'raj',
    'raj@1.1',
    '1234567890',
    '$2b$10$IK0VgkMdMy.ZUkP5kpZr8evK/4mL58yBY2ppw88tZeoEorZhZvjDO',
    NULL,
    36,
    'ACTIVE',
    '2026-03-11 09:16:52'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    79,
    35,
    42,
    'Rajdeep Kanzariya',
    'rajdeepkanzariya054@gmail.com',
    '',
    '$2b$10$RUnTSNw.gCeuRb2rCj2GyuKIuRWWjhElJyTCLnY99lZdvCs704Y92',
    '1776061315907_images.jpg',
    65,
    'ACTIVE',
    '2026-03-12 08:19:37'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    81,
    35,
    40,
    'Janvi',
    'janviparejiya@gmail.com',
    NULL,
    '$2b$10$erc/2rXdodETx.EhooViQO5dLMvUpZXdwJbHrbZtkZ0tjMgH5eKFq',
    NULL,
    65,
    'ACTIVE',
    '2026-03-23 04:33:47'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    82,
    34,
    44,
    'Designer 01',
    'Designer01@1.1',
    '1234567890',
    '$2b$10$Rhdfmt78LLIcRhj8g9jYBujnzl3WZGne2WGvrIH89WalhKOcJeDX6',
    NULL,
    34,
    'ACTIVE',
    '2026-04-11 04:17:14'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    83,
    34,
    45,
    'Designer 02',
    'Designer02@1.1',
    '1234567890',
    '$2b$10$jRrQWpdS0D7TlxUmGByDm.wk1AiR94I8/gkSEIVgfCmjwAo51T/qe',
    NULL,
    34,
    'ACTIVE',
    '2026-04-11 04:18:04'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    84,
    34,
    46,
    'Designer 03',
    'Designer03@1.1',
    '1234567890',
    '$2b$10$NCrfGciZVE0uwFwfBZIxju03U4YW7a2MV3oHOq1/ImpoP9bIrsOb6',
    NULL,
    34,
    'ACTIVE',
    '2026-04-11 04:19:08'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    85,
    34,
    48,
    'john',
    'john@gmail.com',
    '8523697410',
    '$2b$10$767yL7ZNj7QKIJO7jawUd.tIyRLWo0FiQDozRlDeQ7LJ7P2AOAItm',
    NULL,
    34,
    'ACTIVE',
    '2026-04-13 04:14:54'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    88,
    34,
    45,
    'sdv',
    '1@gmail.com',
    NULL,
    '$2b$10$htLYtvlfO6pD39R/6p3b2OmJpbZsPg1OpuNn4EIyCiU9TnV8DRBKa',
    NULL,
    83,
    'ACTIVE',
    '2026-04-13 04:20:56'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    216,
    39,
    55,
    'Swati',
    'swatihr206@gmail.com',
    '9429636561',
    '$2b$10$we071OXcQ6G2YhPc5TyG6e7Cmc3XxMa4JuIcfGOrherzKu5f1SpYW',
    '1776919199214.jpg',
    39,
    'ACTIVE',
    '2026-04-20 05:22:34'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    217,
    39,
    62,
    'Neha ',
    'mobad799@gmail.com',
    '',
    '$2b$10$qMyq8nWD5QlGoeBfn4wS0uVfKJgSU.3fuOKoyGrNx2IeI2Qb4BskC',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 06:56:32'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    218,
    39,
    58,
    'Nidhi',
    'happydigirivera@gmail.com',
    '',
    '$2b$10$plZi.9vMOY.kBOs/20ja7OMR/y8tAtw37gbhYnljADYWgb6ofYKJG',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 06:57:44'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    219,
    39,
    57,
    'Herin',
    'sarjudigirivera@gmail.com',
    '',
    '$2b$10$L4YZkKbugIN5LUWMueXRI.C4Cp1MuQ4QjsrWmZKv/UCT35Gq.5WCC',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 06:58:15'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    220,
    39,
    58,
    'Nikita ',
    'digiriveraads@gmail.com',
    '',
    '$2b$10$MAAnhtGQ29lSr5jocKaGmuqMIDPNbvdVgsgR78d4qw6haGNa2OzLa',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:01:38'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    221,
    39,
    56,
    'Hetal',
    'digiriverasales1@gmail.com',
    '9328138685',
    '$2b$10$45dRzvhlXQnp/V0pLUlrVekb.ZnQNyT6xRr6MtkTVIOjJo8m8c/C6',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:04:28'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    222,
    39,
    63,
    'Meet',
    'digiriverasocial@gmail.com',
    '',
    '$2b$10$MFcC72StDa5aIMViuY3fd.eWb5aYJq3HYSaqJOaGkVaa1B8Z5F6rK',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:04:59'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    223,
    39,
    60,
    'Harsh',
    'digiriveravideo1@gmail.com',
    '',
    '$2b$10$Nfh9Kitu5FamOQv.bqn1kuAjrgdpd9OyjFucU8o6J08Pz2IdvnLu2',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:05:28'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    224,
    39,
    59,
    'Dishita',
    'digiriveragraphics@gmail.com',
    '',
    '$2b$10$brIkf/xuB9ekToENcjUxAOL/u30eEGEkawi3W6b7ekRlyZi6GrmlW',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:05:58'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    225,
    39,
    60,
    'Khilav',
    'digiriveravideo2@gmail.com',
    '',
    '$2b$10$xN0Msak1lKJmLAFo1VPnv.jRCDg954SOK36/Odum3/42TqtKMJ.l6',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:07:01'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    226,
    39,
    61,
    'Mihir',
    'kevaldigirivera@gmail.com',
    '',
    '$2b$10$fN/8.Pq3G7ALikaMC3/mLuKorJ1H8T2R8eUfu.PKBpYJcC02ITqPS',
    NULL,
    39,
    'ACTIVE',
    '2026-04-21 07:09:27'
  );
INSERT INTO
  `users` (
    `id`,
    `admin_id`,
    `role_id`,
    `name`,
    `email`,
    `phone`,
    `password`,
    `profile_pic`,
    `created_by`,
    `status`,
    `created_at`
  )
VALUES
  (
    227,
    39,
    64,
    'Nirali',
    'niralidigirivera@gmail.com',
    '',
    '$2b$10$NcqWNXp1J/JLcaBpICZxDO9Nms70ux.SzvhS1Xl.l7m1HHKxBRIC6',
    NULL,
    39,
    'ACTIVE',
    '2026-04-22 04:41:20'
  );

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
