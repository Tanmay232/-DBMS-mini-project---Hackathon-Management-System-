USE hackathon_db;

DELIMITER $$

-- Trigger 1: block a 5th member from joining a team
CREATE TRIGGER trg_team_size_limit
BEFORE INSERT ON TeamMember
FOR EACH ROW
BEGIN
    DECLARE member_count INT;
    SELECT COUNT(*) INTO member_count
    FROM TeamMember
    WHERE team_id = NEW.team_id;

    IF member_count >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team already has the maximum of 4 members';
    END IF;
END$$

-- Trigger 2: auto-calculate total score on insert
CREATE TRIGGER trg_score_total_insert
BEFORE INSERT ON Score
FOR EACH ROW
BEGIN
    SET NEW.total = NEW.innovation + NEW.technical + NEW.presentation;
END$$

-- Trigger 3: auto-recalculate total score on update
CREATE TRIGGER trg_score_total_update
BEFORE UPDATE ON Score
FOR EACH ROW
BEGIN
    SET NEW.total = NEW.innovation + NEW.technical + NEW.presentation;
END$$

DELIMITER ;