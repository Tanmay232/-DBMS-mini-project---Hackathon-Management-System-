from flask import Flask, render_template, request, redirect, url_for, session, flash
from db import get_connection
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = "some_secret_key_change_later"

@app.route('/')
def home():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':

        username = request.form['username']
        password = request.form['password']

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        print("DEBUG - typed password:", repr(password))
        print("DEBUG - stored hash:", repr(user['password_hash']) if user else "NO USER FOUND")

        if user and check_password_hash(user['password_hash'], password):
            session['user_id'] = user['user_id']
            session['role'] = user['role']
            session['username'] = user['username']
            flash(f"Welcome, {username}!")
            return redirect(url_for('dashboard'))
        else:
            flash("Invalid username or password")
            return redirect(url_for('login'))

    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT COUNT(*) AS count FROM Participant")
    participant_count = cursor.fetchone()['count']

    cursor.execute("SELECT COUNT(*) AS count FROM Team")
    team_count = cursor.fetchone()['count']

    cursor.execute("SELECT COUNT(*) AS count FROM Project")
    project_count = cursor.fetchone()['count']

    cursor.execute("SELECT COUNT(*) AS count FROM ProblemStatement")
    problem_count = cursor.fetchone()['count']

    cursor.close()
    conn.close()

    return render_template('dashboard.html',
                            participant_count=participant_count,
                            team_count=team_count,
                            project_count=project_count,
                            problem_count=problem_count)

@app.route('/leaderboard')
def leaderboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Leaderboard ORDER BY `rank`")
    results = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('leaderboard.html', results=results)

@app.route('/admin/problems', methods=['GET', 'POST'])
def manage_problems():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        domain = request.form['domain']
        cursor.execute(
            "INSERT INTO ProblemStatement (title, description, domain) VALUES (%s, %s, %s)",
            (title, description, domain)
        )
        conn.commit()
        flash("Problem statement added!")

    cursor.execute("SELECT * FROM ProblemStatement")
    problems = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('problems.html', problems=problems)


@app.route('/admin/teams')
def manage_teams():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM TeamSummary")
    teams = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('teams.html', teams=teams)

@app.route('/admin/participants')
def manage_participants():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT p.participant_id, p.name, p.email, p.college, p.skills,
               t.team_name
        FROM Participant p
        LEFT JOIN TeamMember tm ON p.participant_id = tm.participant_id
        LEFT JOIN Team t ON tm.team_id = t.team_id
    """)
    participants = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('participants.html', participants=participants)

@app.route('/admin/projects')
def manage_projects():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT pr.project_id, pr.title, pr.repo_link, pr.submitted_at,
               t.team_name, ps.title AS problem_title
        FROM Project pr
        JOIN Team t ON pr.team_id = t.team_id
        JOIN ProblemStatement ps ON pr.problem_id = ps.problem_id
    """)
    projects = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('projects.html', projects=projects)

@app.route('/admin/judging', methods=['GET', 'POST'])
def judging():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        project_id = request.form['project_id']
        judge_id = request.form['judge_id']
        innovation = request.form['innovation']
        technical = request.form['technical']
        presentation = request.form['presentation']

        try:
            cursor.execute("""
                INSERT INTO Score (project_id, judge_id, innovation, technical, presentation)
                VALUES (%s, %s, %s, %s, %s)
            """, (project_id, judge_id, innovation, technical, presentation))
            conn.commit()
            flash("Score submitted successfully!")
        except Exception as e:
            conn.rollback()
            flash(f"Error: this judge may have already scored this project. ({e})")

    cursor.execute("SELECT project_id, title FROM Project")
    projects = cursor.fetchall()

    cursor.execute("SELECT judge_id, name FROM Judge")
    judges = cursor.fetchall()

    cursor.execute("""
        SELECT s.score_id, p.title AS project_title, j.name AS judge_name,
               s.innovation, s.technical, s.presentation, s.total
        FROM Score s
        JOIN Project p ON s.project_id = p.project_id
        JOIN Judge j ON s.judge_id = j.judge_id
        ORDER BY s.score_id DESC
    """)
    scores = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('judging.html', projects=projects, judges=judges, scores=scores)

@app.route('/admin/results')
def results():
    if 'user_id' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.callproc('DeclareResults')

    top3 = []
    for result in cursor.stored_results():
        top3 = result.fetchall()

    cursor.close()
    conn.close()

    return render_template('results.html', top3=top3)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)