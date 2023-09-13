CREATE TABLE `visit_history_tmp` (
	`player_id` VARCHAR(255) NOT NULL,
	`tenant_id` BIGINT UNSIGNED NOT NULL,
	`competition_id` VARCHAR(255) NOT NULL,
	`created_at` BIGINT NOT NULL,
	`updated_at` BIGINT NOT NULL,
	INDEX `tenant_id_idx` (`tenant_id`)) ENGINE = InnoDB DEFAULT CHARACTER
SET = utf8mb4;

INSERT INTO visit_history_tmp
SELECT
	*
FROM
	visit_history;

TRUNCATE visit_history;

INSERT INTO visit_history
SELECT
	player_id,
	tenant_id,
	competition_id,
	min(created_at) AS created_at,
	min(updated_at) AS updated_at
FROM
	visit_history_tmp
GROUP BY
	player_id,
	tenant_id,
	competition_id;
