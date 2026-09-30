DROP DATABASE IF EXISTS hackathon_db;
CREATE DATABASE hackathon_db CHARACTER SET utf8mb4;
USE hackathon_db;

CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','participant','mentor','judge') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Participant (
  participant_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  college VARCHAR(100),
  skills VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Team (
  team_id INT AUTO_INCREMENT PRIMARY KEY,
  team_name VARCHAR(100) NOT NULL UNIQUE,
  leader_id INT NOT NULL,
  FOREIGN KEY (leader_id) REFERENCES Participant(participant_id)
) ENGINE=InnoDB;

CREATE TABLE TeamMember (
  team_id INT NOT NULL,
  participant_id INT NOT NULL UNIQUE,
  PRIMARY KEY (team_id, participant_id),
  FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE,
  FOREIGN KEY (participant_id) REFERENCES Participant(participant_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ProblemStatement (
  problem_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  domain VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE Project (
  project_id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL UNIQUE,
  problem_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  repo_link VARCHAR(255),
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE,
  FOREIGN KEY (problem_id) REFERENCES ProblemStatement(problem_id)
) ENGINE=InnoDB;

CREATE TABLE Mentor (
  mentor_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  expertise VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE MentorAssignment (
  mentor_id INT NOT NULL,
  team_id INT NOT NULL,
  PRIMARY KEY (mentor_id, team_id),
  FOREIGN KEY (mentor_id) REFERENCES Mentor(mentor_id) ON DELETE CASCADE,
  FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Judge (
  judge_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Score (
  score_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT NOT NULL,
  judge_id INT NOT NULL,
  innovation TINYINT NOT NULL CHECK (innovation BETWEEN 0 AND 10),
  technical TINYINT NOT NULL CHECK (technical BETWEEN 0 AND 10),
  presentation TINYINT NOT NULL CHECK (presentation BETWEEN 0 AND 10),
  total INT DEFAULT 0,
  UNIQUE (project_id, judge_id),
  FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE,
  FOREIGN KEY (judge_id) REFERENCES Judge(judge_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_project_problem ON Project(problem_id);
CREATE INDEX idx_score_project ON Score(project_id);  