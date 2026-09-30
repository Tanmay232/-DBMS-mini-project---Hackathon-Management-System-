USE hackathon_db;

CREATE OR REPLACE VIEW Leaderboard AS
SELECT
    p.project_id,
    p.title AS project_title,
    t.team_name,
    ROUND(AVG(s.total), 2) AS avg_score,
    RANK() OVER (ORDER BY AVG(s.total) DESC) AS `rank`
FROM Project p
JOIN Team t ON p.team_id = t.team_id
JOIN Score s ON p.project_id = s.project_id
GROUP BY p.project_id, p.title, t.team_name;

CREATE OR REPLACE VIEW TeamSummary AS
SELECT
    t.team_id,
    t.team_name,
    pl.name AS leader_name,
    COUNT(tm.participant_id) AS member_count,
    m.name AS mentor_name,
    pr.title AS project_title
FROM Team t
JOIN Participant pl ON t.leader_id = pl.participant_id
LEFT JOIN TeamMember tm ON t.team_id = tm.team_id
LEFT JOIN MentorAssignment ma ON t.team_id = ma.team_id
LEFT JOIN Mentor m ON ma.mentor_id = m.mentor_id
LEFT JOIN Project pr ON t.team_id = pr.team_id
GROUP BY t.team_id, t.team_name, pl.name, m.name, pr.title;