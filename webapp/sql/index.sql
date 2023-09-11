ALTER TABLE visit_history
	ADD INDEX idx_all_cover (tenant_id, competition_id, player_id, created_at);
