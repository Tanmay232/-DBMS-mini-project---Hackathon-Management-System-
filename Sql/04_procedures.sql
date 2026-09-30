USE hackathon_db;

DELIMITER $$

CREATE PROCEDURE DeclareResults()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT project_title, team_name, avg_score, `rank`
    FROM Leaderboard
    WHERE `rank` <= 3
    ORDER BY `rank`;

    COMMIT;
END$$

CREATE PROCEDURE RegisterTeam(
    IN p_team_name VARCHAR(100),
    IN p_leader_id INT
)
BEGIN
    DECLARE new_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO Team (team_name, leader_id) VALUES (p_team_name, p_leader_id);
    SET new_team_id = LAST_INSERT_ID();
    INSERT INTO TeamMember (team_id, participant_id) VALUES (new_team_id, p_leader_id);

    COMMIT;
END$$

DELIMITER ;