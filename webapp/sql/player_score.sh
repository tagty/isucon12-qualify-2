for db in *.db; do sqlite3 $db < ../webapp/sql/player_score.sql; done
