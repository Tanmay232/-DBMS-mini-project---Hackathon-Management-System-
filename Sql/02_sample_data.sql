USE hackathon_db;

-- Users: 1 admin, 15 participants, 3 mentors, 3 judges
INSERT INTO Users (user_id, username, password_hash, role) VALUES
(1,'admin','temp','admin'),
(2,'p1','temp','participant'),(3,'p2','temp','participant'),(4,'p3','temp','participant'),
(5,'p4','temp','participant'),(6,'p5','temp','participant'),(7,'p6','temp','participant'),
(8,'p7','temp','participant'),(9,'p8','temp','participant'),(10,'p9','temp','participant'),
(11,'p10','temp','participant'),(12,'p11','temp','participant'),(13,'p12','temp','participant'),
(14,'p13','temp','participant'),(15,'p14','temp','participant'),(16,'p15','temp','participant'),
(17,'m1','temp','mentor'),(18,'m2','temp','mentor'),(19,'m3','temp','mentor'),
(20,'j1','temp','judge'),(21,'j2','temp','judge'),(22,'j3','temp','judge');

INSERT INTO Participant (participant_id, user_id, name, email, college, skills) VALUES
(1,2,'Aarav Sharma','aarav@example.com','IIT Bombay','Python, ML'),
(2,3,'Diya Patel','diya@example.com','IIT Bombay','React, UI design'),
(3,4,'Rohan Mehta','rohan@example.com','VJTI','MySQL, Flask'),
(4,5,'Sneha Iyer','sneha@example.com','VJTI','Java, Android'),
(5,6,'Kabir Singh','kabir@example.com','NMIMS','Node.js, MongoDB'),
(6,7,'Ananya Rao','ananya@example.com','NMIMS','Data analysis'),
(7,8,'Vikram Joshi','vikram@example.com','DJ Sanghvi','C++, IoT'),
(8,9,'Meera Nair','meera@example.com','DJ Sanghvi','Python, Django'),
(9,10,'Arjun Desai','arjun@example.com','SPIT','Cloud, DevOps'),
(10,11,'Priya Kulkarni','priya@example.com','SPIT','UI/UX, Figma'),
(11,12,'Nikhil Verma','nikhil@example.com','KJ Somaiya','Java, Spring'),
(12,13,'Isha Gupta','isha@example.com','KJ Somaiya','ML, NLP'),
(13,14,'Rahul Shetty','rahul@example.com','Thadomal','Web dev'),
(14,15,'Tanvi Bhatt','tanvi@example.com','Thadomal','SQL, Power BI'),
(15,16,'Yash Malhotra','yash@example.com','Xavier','Blockchain');

INSERT INTO Team (team_id, team_name, leader_id) VALUES
(1,'Code Crushers',1),(2,'Byte Builders',4),(3,'Data Dynamos',7),
(4,'Pixel Pioneers',10),(5,'Logic Lords',13);

-- Participant 15 stays without a team; team 5 has only 2 members
INSERT INTO TeamMember (team_id, participant_id) VALUES
(1,1),(1,2),(1,3),
(2,4),(2,5),(2,6),
(3,7),(3,8),(3,9),
(4,10),(4,11),(4,12),
(5,13),(5,14);

INSERT INTO ProblemStatement (problem_id, title, description, domain) VALUES
(1,'Smart Campus Assistant','Chatbot for campus queries','AI'),
(2,'Waste Segregation Tracker','Track and reward waste segregation','Sustainability'),
(3,'Telemedicine Platform','Remote consultation for rural areas','Healthcare'),
(4,'Student Budget Planner','Expense tracking for students','FinTech'),
(5,'Traffic Flow Predictor','Predict congestion using open data','Smart City'),
(6,'Local Skills Marketplace','Connect local freelancers with clients','Social Impact');

-- Team 5 deliberately has no project (useful for a "teams without projects" query)
INSERT INTO Project (project_id, team_id, problem_id, title, description, repo_link) VALUES
(1,1,1,'CampusBot','AI assistant for students','https://github.com/example/campusbot'),
(2,2,2,'GreenTrack','Waste tracking app','https://github.com/example/greentrack'),
(3,3,3,'MediConnect','Telemedicine web app','https://github.com/example/mediconnect'),
(4,4,4,'SpendWise','Budget planner','https://github.com/example/spendwise');

INSERT INTO Mentor (mentor_id, user_id, name, expertise) VALUES
(1,17,'Dr. Suresh Kumar','AI/ML'),
(2,18,'Ms. Neha Kapoor','Web Development'),
(3,19,'Mr. Ajay Menon','Databases');

INSERT INTO MentorAssignment (mentor_id, team_id) VALUES
(1,1),(1,3),(2,2),(2,4),(3,5);

INSERT INTO Judge (judge_id, user_id, name) VALUES
(1,20,'Prof. Anita Deshmukh'),
(2,21,'Mr. Rajiv Khanna'),
(3,22,'Dr. Farah Sheikh');

INSERT INTO Score (project_id, judge_id, innovation, technical, presentation, total) VALUES
(1,1,8,9,7,24),(1,2,9,8,8,25),(1,3,8,8,9,25),
(2,1,7,8,8,23),(2,2,8,7,7,22),(2,3,7,7,8,22),
(3,1,9,9,9,27),(3,2,10,9,8,27),(3,3,9,10,9,28),
(4,1,6,7,6,19),(4,2,7,6,7,20),(4,3,6,6,7,19);