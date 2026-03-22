<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.dao.CourseDAO, com.cms.model.Course, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"student".equals(currentUser.getRole())) {
        response.sendRedirect("/CourseManagementSystem/pages/login.jsp");
        return;
    }
    CourseDAO courseDAO = new CourseDAO();
    List<Course> allCourses = courseDAO.getAllCourses();
    List<Course> enrolledCourses = courseDAO.getEnrolledCourses(currentUser.getUserId());
    int enrolledCount = enrolledCourses != null ? enrolledCourses.size() : 0;
    int totalCredits = 0;
    if (enrolledCourses != null) {
        for (Course c : enrolledCourses) totalCredits += c.getCredits();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard — CMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --navy:    #0f1e3d;
            --navy2:   #1a2f5e;
            --navy3:   #243f7a;
            --gold:    #c9a84c;
            --gold2:   #e8c96a;
            --cream:   #f9f6ef;
            --white:   #ffffff;
            --text:    #1a1a2e;
            --muted:   #6b7280;
            --border:  #e5e0d5;
            --green:   #15803d;
            --sidebar: 260px;
        }

        html, body {
            height: 100%;
            font-family: 'DM Sans', sans-serif;
            background: var(--cream);
            color: var(--text);
        }

        .shell { display: flex; min-height: 100vh; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: var(--sidebar);
            background: var(--navy);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            position: fixed;
            top: 0; left: 0;
            height: 100vh;
            overflow-y: auto;
            z-index: 100;
        }

        .sidebar-brand {
            padding: 1.75rem 1.5rem 1.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }

        .brand-crest {
            width: 40px; height: 40px;
            background: var(--gold);
            border-radius: 4px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Playfair Display', serif;
            font-size: 18px;
            font-weight: 600;
            color: var(--navy);
            margin-bottom: 10px;
        }

        .brand-name {
            font-family: 'Playfair Display', serif;
            font-size: 15px;
            font-weight: 500;
            color: var(--white);
            line-height: 1.3;
        }
        .brand-sub {
            font-size: 11px;
            color: rgba(255,255,255,0.4);
            letter-spacing: 0.06em;
            text-transform: uppercase;
            margin-top: 2px;
        }

        .sidebar-section {
            padding: 1.5rem 1rem 0.5rem;
        }

        .sidebar-section-label {
            font-size: 10px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: rgba(255,255,255,0.3);
            padding: 0 0.5rem;
            margin-bottom: 6px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 400;
            color: rgba(255,255,255,0.65);
            transition: background 0.15s, color 0.15s;
            margin-bottom: 2px;
        }
        .nav-item:hover { background: rgba(255,255,255,0.07); color: var(--white); }
        .nav-item.active { background: rgba(201,168,76,0.15); color: var(--gold2); }

        .nav-icon { width: 18px; height: 18px; opacity: 0.7; flex-shrink: 0; }
        .nav-item.active .nav-icon { opacity: 1; }

        .sidebar-footer {
            margin-top: auto;
            padding: 1.25rem 1rem;
            border-top: 1px solid rgba(255,255,255,0.08);
        }

        .user-chip { display: flex; align-items: center; gap: 10px; }

        .user-avatar {
            width: 34px; height: 34px;
            background: rgba(201,168,76,0.2);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px;
            font-weight: 500;
            color: var(--gold2);
            flex-shrink: 0;
        }

        .user-info strong { display: block; font-size: 13px; font-weight: 500; color: var(--white); }
        .user-info span { font-size: 11px; color: rgba(255,255,255,0.4); }

        .logout-btn {
            margin-left: auto;
            background: none; border: none;
            cursor: pointer;
            color: rgba(255,255,255,0.35);
            padding: 4px;
            transition: color 0.15s;
            text-decoration: none;
            display: flex;
        }
        .logout-btn:hover { color: rgba(255,255,255,0.7); }

        /* ── MAIN ── */
        .main {
            margin-left: var(--sidebar);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* ── TOPBAR ── */
        .topbar {
            background: var(--white);
            border-bottom: 1px solid var(--border);
            padding: 0 2rem;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0; z-index: 50;
        }

        .topbar-left h1 {
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 500;
            color: var(--navy);
        }
        .topbar-left p { font-size: 12px; color: var(--muted); }

        .badge-student {
            background: #f5f3ff;
            color: #5b21b6;
            font-size: 11px;
            font-weight: 500;
            padding: 3px 10px;
            border-radius: 20px;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        /* ── CONTENT ── */
        .content { padding: 2rem; flex: 1; }

        /* ── WELCOME BANNER ── */
        .welcome-banner {
            background: var(--navy);
            border-radius: 12px;
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
        }
        .welcome-banner::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 200px; height: 200px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.15);
        }

        .welcome-text h2 {
            font-family: 'Playfair Display', serif;
            font-size: 22px;
            font-weight: 500;
            color: var(--white);
            margin-bottom: 4px;
        }
        .welcome-text p { font-size: 14px; color: rgba(255,255,255,0.55); }

        .welcome-stats {
            display: flex;
            gap: 2rem;
            position: relative;
            z-index: 1;
        }
        .w-stat strong {
            display: block;
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            font-weight: 500;
            color: var(--gold2);
        }
        .w-stat span { font-size: 12px; color: rgba(255,255,255,0.45); }

        /* ── STATS GRID ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 1.25rem 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .stat-label {
            font-size: 11px;
            letter-spacing: 0.07em;
            text-transform: uppercase;
            color: var(--muted);
            font-weight: 500;
        }

        .stat-value {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            font-weight: 500;
            color: var(--navy);
            line-height: 1;
        }

        .stat-sub { font-size: 12px; color: var(--muted); }

        /* ── CONTENT GRID ── */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 1.5rem;
        }

        /* ── PANEL ── */
        .panel {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 10px;
            overflow: hidden;
        }

        .panel-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .panel-title {
            font-family: 'Playfair Display', serif;
            font-size: 16px;
            font-weight: 500;
            color: var(--navy);
        }

        /* ── ENROLLED COURSES ── */
        .course-list { padding: 1rem 1.5rem; display: flex; flex-direction: column; gap: 12px; }

        .course-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem 1.25rem;
            border: 1px solid var(--border);
            border-radius: 8px;
            transition: background 0.15s;
        }
        .course-row:hover { background: var(--cream); }

        .course-code {
            background: var(--navy);
            color: var(--gold2);
            font-size: 11px;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 4px;
            letter-spacing: 0.04em;
            flex-shrink: 0;
            min-width: 80px;
            text-align: center;
        }

        .course-details { flex: 1; }
        .course-details strong { display: block; font-size: 14px; font-weight: 500; color: var(--navy); }
        .course-details span { font-size: 12px; color: var(--muted); }

        .enrolled-badge {
            background: #f0fdf4;
            color: var(--green);
            font-size: 11px;
            font-weight: 500;
            padding: 3px 10px;
            border-radius: 20px;
        }

        .empty-state {
            padding: 3rem;
            text-align: center;
            color: var(--muted);
            font-size: 14px;
        }

        /* ── AVAILABLE COURSES ── */
        .available-list { padding: 1rem 1.5rem; display: flex; flex-direction: column; gap: 10px; }

        .avail-card {
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 0.9rem 1.1rem;
        }

        .avail-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 6px;
        }

        .avail-code {
            font-size: 11px;
            font-weight: 500;
            color: var(--navy2);
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        .avail-credits {
            font-size: 11px;
            color: var(--muted);
        }

        .avail-name {
            font-size: 14px;
            font-weight: 500;
            color: var(--navy);
            margin-bottom: 8px;
        }

        .enrol-btn {
            width: 100%;
            padding: 7px;
            background: var(--navy);
            color: var(--white);
            border: none;
            border-radius: 5px;
            font-family: 'DM Sans', sans-serif;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.15s;
        }
        .enrol-btn:hover { background: var(--navy2); }

        .enrol-btn.enrolled-already {
            background: #f0fdf4;
            color: var(--green);
            border: 1px solid #bbf7d0;
            cursor: default;
        }

        @media (max-width: 1100px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .content-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main { margin-left: 0; }
            .welcome-stats { display: none; }
        }
    </style>
</head>
<body>
<div class="shell">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-crest">U</div>
            <div class="brand-name">University CMS</div>
            <div class="brand-sub">Student Portal</div>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-section-label">My Studies</div>
            <a href="/CourseManagementSystem/pages/student/dashboard.jsp" class="nav-item active">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                My Dashboard
            </a>
            <a href="#my-courses" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                My Courses
            </a>
            <a href="#browse" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                Browse Courses
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-chip">
                <div class="user-avatar">
                    <%= currentUser.getFirstName() != null ? currentUser.getFirstName().substring(0,1).toUpperCase() : "S" %>
                </div>
                <div class="user-info">
                    <strong><%= currentUser.getFirstName() %> <%= currentUser.getLastName() %></strong>
                    <span>Student</span>
                </div>
                <form action="/CourseManagementSystem/auth" method="post" style="margin-left:auto;">
                    <input type="hidden" name="action" value="logout">
                    <button type="submit" class="logout-btn" title="Sign out">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <!-- MAIN -->
    <div class="main">
        <header class="topbar">
            <div class="topbar-left">
                <h1>Honours Student Portal</h1>
                <p>BSc Honours Computer Science — 2026 cohort</p>
            </div>
            <div><span class="badge-student">Honours Student</span></div>
        </header>

        <div class="content">
            <%
                String enrollMsg = (String) session.getAttribute("enrollMessage");
                String enrollErr = (String) session.getAttribute("enrollError");
                if (enrollMsg != null) session.removeAttribute("enrollMessage");
                if (enrollErr != null) session.removeAttribute("enrollError");
            %>
            <% if (enrollMsg != null) { %>
            <div style="background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;font-size:13px;padding:10px 16px;border-radius:8px;margin-bottom:1.25rem;">
                <%= enrollMsg %>
            </div>
            <% } %>
            <% if (enrollErr != null) { %>
            <div style="background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;font-size:13px;padding:10px 16px;border-radius:8px;margin-bottom:1.25rem;">
                <%= enrollErr %>
            </div>
            <% } %>

            <!-- WELCOME BANNER -->
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Welcome, <%= currentUser.getFirstName() != null ? currentUser.getFirstName() : currentUser.getUsername() %></h2>
                    <p>BSc Honours Computer Science — track your modules and supervision progress.</p>
                </div>
                <div class="welcome-stats">
                    <div class="w-stat">
                        <strong><%= enrolledCount %></strong>
                        <span>Modules</span>
                    </div>
                    <div class="w-stat">
                        <strong><%= totalCredits %></strong>
                        <span>Credits</span>
                    </div>
                </div>
            </div>

            <!-- STATS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Enrolled Courses</div>
                    <div class="stat-value"><%= enrolledCount %></div>
                    <div class="stat-sub">Active this semester</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Credits</div>
                    <div class="stat-value"><%= totalCredits %></div>
                    <div class="stat-sub">Credit hours</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Available Courses</div>
                    <div class="stat-value"><%= allCourses != null ? allCourses.size() : 0 %></div>
                    <div class="stat-sub">Open for enrolment</div>
                </div>
            </div>

            <!-- CONTENT GRID -->
            <div class="content-grid">

                <!-- MY COURSES -->
                <div class="panel" id="my-courses">
                    <div class="panel-header">
                        <div class="panel-title">My Enrolled Courses</div>
                    </div>
                    <div class="course-list">
                        <% if (enrolledCourses != null && !enrolledCourses.isEmpty()) {
                            for (Course c : enrolledCourses) { %>
                        <div class="course-row">
                            <div class="course-code"><%= c.getCourseCode() %></div>
                            <div class="course-details">
                                <strong><%= c.getCourseName() %></strong>
                                <span><%= c.getCredits() %> credits</span>
                            </div>
                            <span class="enrolled-badge">Enrolled</span>
                        </div>
                        <% } } else { %>
                        <div class="empty-state">
                            <p>You haven't enrolled in any courses yet.</p>
                            <p style="margin-top:6px; font-size:13px;">Browse available courses on the right to get started.</p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- AVAILABLE COURSES -->
                <div class="panel" id="browse">
                    <div class="panel-header">
                        <div class="panel-title">Available Courses</div>
                    </div>
                    <div class="available-list">
                        <% if (allCourses != null) {
                            for (Course c : allCourses) {
                                boolean alreadyEnrolled = false;
                                if (enrolledCourses != null) {
                                    for (Course ec : enrolledCourses) {
                                        if (ec.getCourseId() == c.getCourseId()) { alreadyEnrolled = true; break; }
                                    }
                                }
                        %>
                        <div class="avail-card">
                            <div class="avail-top">
                                <span class="avail-code"><%= c.getCourseCode() %></span>
                                <span class="avail-credits"><%= c.getCredits() %> cr.</span>
                            </div>
                            <div class="avail-name"><%= c.getCourseName() %></div>
                            <% if (alreadyEnrolled) { %>
                            <button class="enrol-btn enrolled-already" disabled>Already Enrolled</button>
                            <% } else { %>
                            <form action="/CourseManagementSystem/auth" method="post" style="margin:0">
                                <input type="hidden" name="action" value="enroll">
                                <input type="hidden" name="courseId" value="<%= c.getCourseId() %>">
                                <button type="submit" class="enrol-btn">Enrol in Course</button>
                            </form>
                            <% } %>
                        </div>
                        <% } } %>
                    </div>
                </div>

            </div>
        </div>
    </div>

</div>
</body>
</html>
