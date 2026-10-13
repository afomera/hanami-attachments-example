CREATE TABLE `schema_migrations`(`filename` varchar(255) NOT NULL PRIMARY KEY);
CREATE TABLE `users`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `email_address` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `updated_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `avatar_data` text
);
CREATE UNIQUE INDEX `users_email_address_index` ON `users`(`email_address`);
CREATE TABLE `sessions`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `token_digest` varchar(255) NOT NULL,
  `ip_address` varchar(255),
  `user_agent` varchar(255),
  `created_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `updated_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL
);
CREATE INDEX `sessions_user_id_index` ON `sessions`(`user_id`);
CREATE UNIQUE INDEX `sessions_token_digest_index` ON `sessions`(
  `token_digest`
);
CREATE TABLE `clips`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `video_data` text,
  `created_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `updated_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `title` varchar(255) DEFAULT('') NOT NULL
);
CREATE TABLE `photos`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `image_data` text,
  `created_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `updated_at` timestamp DEFAULT(datetime(CURRENT_TIMESTAMP, 'localtime')) NOT NULL,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `title` varchar(255) DEFAULT('') NOT NULL
);
CREATE INDEX `photos_user_id_index` ON `photos`(`user_id`);
CREATE INDEX `clips_user_id_index` ON `clips`(`user_id`);
INSERT INTO schema_migrations (filename) VALUES
('20261013014706_create_users.rb'),
('20261013014707_create_sessions.rb'),
('20261013014929_add_avatar_to_users.rb'),
('20261013014931_create_clips.rb'),
('20261013014932_create_photos.rb'),
('20261013020000_add_owners_to_photos_and_clips.rb');
