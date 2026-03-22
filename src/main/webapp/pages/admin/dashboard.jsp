<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.dao.UserDAO, com.cms.dao.CourseDAO, com.cms.model.Course, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("${pageContext.request.contextPath}/pages/login.jsp");
        return;
    }
    UserDAO userDAO = new UserDAO();
    CourseDAO courseDAO = new CourseDAO();
    List<User> users = userDAO.getAllUsers();
    List<Course> courses = courseDAO.getAllCourses();
    int totalUsers = users != null ? users.size() : 0;
    int totalCourses = courses != null ? courses.size() : 0;
    int instructorCount = 0;
    int studentCount = 0;
    if (users != null) {
        for (User u : users) {
            if ("instructor".equals(u.getRole())) instructorCount++;
            else if ("student".equals(u.getRole())) studentCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — CMS</title>
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
            --sidebar: 260px;
        }

        html, body {
            height: 100%;
            font-family: 'DM Sans', sans-serif;
            background: var(--cream);
            color: var(--text);
        }

        /* ── LAYOUT ── */
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
        .nav-item:hover {
            background: rgba(255,255,255,0.07);
            color: var(--white);
        }
        .nav-item.active {
            background: rgba(201,168,76,0.15);
            color: var(--gold2);
        }

        .nav-icon {
            width: 18px; height: 18px;
            opacity: 0.7;
            flex-shrink: 0;
        }
        .nav-item.active .nav-icon { opacity: 1; }

        .sidebar-footer {
            margin-top: auto;
            padding: 1.25rem 1rem;
            border-top: 1px solid rgba(255,255,255,0.08);
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-avatar {
            width: 34px; height: 34px;
            background: var(--navy3);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px;
            font-weight: 500;
            color: var(--gold2);
            flex-shrink: 0;
        }

        .user-info strong {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: var(--white);
        }
        .user-info span {
            font-size: 11px;
            color: rgba(255,255,255,0.4);
        }

        .logout-btn {
            margin-left: auto;
            background: none;
            border: none;
            cursor: pointer;
            color: rgba(255,255,255,0.35);
            padding: 4px;
            transition: color 0.15s;
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
            top: 0;
            z-index: 50;
        }

        .topbar-left h1 {
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 500;
            color: var(--navy);
        }
        .topbar-left p {
            font-size: 12px;
            color: var(--muted);
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .badge-admin {
            background: #fef3c7;
            color: #92400e;
            font-size: 11px;
            font-weight: 500;
            padding: 3px 10px;
            border-radius: 20px;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        /* ── CONTENT ── */
        .content {
            padding: 2rem;
            flex: 1;
        }

        /* ── STAT CARDS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
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
            transition: box-shadow 0.2s;
        }
        .stat-card:hover { box-shadow: 0 4px 16px rgba(15,30,61,0.06); }

        .stat-label {
            font-size: 11px;
            letter-spacing: 0.07em;
            text-transform: uppercase;
            color: var(--muted);
            font-weight: 500;
        }

        .stat-value {
            font-family: 'Playfair Display', serif;
            font-size: 36px;
            font-weight: 500;
            color: var(--navy);
            line-height: 1;
        }

        .stat-accent {
            width: 28px; height: 3px;
            border-radius: 2px;
            margin-top: 4px;
        }
        .stat-card:nth-child(1) .stat-accent { background: var(--navy); }
        .stat-card:nth-child(2) .stat-accent { background: #16a34a; }
        .stat-card:nth-child(3) .stat-accent { background: #d97706; }
        .stat-card:nth-child(4) .stat-accent { background: #7c3aed; }

        /* ── GRID ── */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 380px;
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

        .panel-action {
            font-size: 12px;
            color: var(--gold);
            text-decoration: none;
            font-weight: 500;
        }
        .panel-action:hover { text-decoration: underline; }

        /* ── TABLE ── */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        thead th {
            text-align: left;
            padding: 10px 1.5rem;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: 0.07em;
            text-transform: uppercase;
            color: var(--muted);
            background: var(--cream);
            border-bottom: 1px solid var(--border);
        }

        tbody tr {
            border-bottom: 1px solid #f3f0e8;
            transition: background 0.1s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #fdfaf4; }

        tbody td {
            padding: 12px 1.5rem;
            color: var(--text);
        }

        .role-badge {
            display: inline-block;
            font-size: 11px;
            font-weight: 500;
            padding: 3px 10px;
            border-radius: 20px;
            text-transform: capitalize;
        }
        .role-admin    { background: #eff6ff; color: #1e40af; }
        .role-instructor { background: #f0fdf4; color: #15803d; }
        .role-student  { background: #faf5ff; color: #7e22ce; }

        /* ── COURSE CARDS ── */
        .course-list { padding: 1rem 1.5rem; display: flex; flex-direction: column; gap: 12px; }

        .course-card {
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1rem 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: background 0.15s;
        }
        .course-card:hover { background: var(--cream); }

        .course-code-badge {
            background: var(--navy);
            color: var(--gold2);
            font-size: 11px;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 4px;
            letter-spacing: 0.04em;
            flex-shrink: 0;
        }

        .course-info { flex: 1; }
        .course-info strong {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: var(--navy);
        }
        .course-info span {
            font-size: 12px;
            color: var(--muted);
        }

        .enrol-bar-wrap {
            width: 80px;
            text-align: right;
        }

        .enrol-text {
            font-size: 12px;
            color: var(--muted);
            margin-bottom: 4px;
        }

        .enrol-bar {
            height: 4px;
            background: var(--border);
            border-radius: 2px;
            overflow: hidden;
        }
        .enrol-fill {
            height: 100%;
            background: var(--navy2);
            border-radius: 2px;
        }

        @media (max-width: 1100px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .content-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main { margin-left: 0; }
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
            <div class="brand-sub">Course Management</div>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-section-label">Overview</div>
            <a href="${pageContext.request.contextPath}/pages/admin/dashboard.jsp" class="nav-item active">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                Dashboard
            </a>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-section-label">Management</div>
            <a href="${pageContext.request.contextPath}/pages/admin/users.jsp" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Manage Users
            </a>
            <a href="${pageContext.request.contextPath}/pages/admin/courses.jsp" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                Manage Courses
            </a>
            <a href="${pageContext.request.contextPath}/pages/admin/enrollments.jsp" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                Enrolments
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-chip">
                <div class="user-avatar">
                    <%= currentUser.getFirstName() != null ? currentUser.getFirstName().substring(0,1).toUpperCase() : "A" %>
                </div>
                <div class="user-info">
                    <strong><%= currentUser.getFirstName() %> <%= currentUser.getLastName() %></strong>
                    <span>Administrator</span>
                </div>
                <form action="${pageContext.request.contextPath}/auth" method="post" style="margin-left:auto;">
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
                <h1>Dashboard Overview</h1>
                <p>Welcome back, <%= currentUser.getFirstName() %> <%= currentUser.getLastName() %></p>
            </div>
            <div class="topbar-right">
                <span class="badge-admin">Admin</span>
            </div>
        </header>

        <div class="content">

            <!-- STATS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Total Users</div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <div class="stat-accent"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Honours Modules</div>
                    <div class="stat-value"><%= totalCourses %></div>
                    <div class="stat-accent"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Supervisors</div>
                    <div class="stat-value"><%= instructorCount %></div>
                    <div class="stat-accent"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Honours Students</div>
                    <div class="stat-value"><%= studentCount %></div>
                    <div class="stat-accent"></div>
                </div>
            </div>

            <!-- CONTENT GRID -->
            <div class="content-grid">

                <!-- USERS TABLE -->
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Recent Users</div>
                        <a href="${pageContext.request.contextPath}/pages/admin/users.jsp" class="panel-action">View all →</a>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Role</th>
                                <th>Email</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null) { for (User u : users) { %>
                            <tr>
                                <td><strong><%= u.getFirstName() %> <%= u.getLastName() %></strong></td>
                                <td>
                                    <span class="role-badge role-<%= u.getRole() %>">
                                        <%= u.getRole() %>
                                    </span>
                                </td>
                                <td style="color: #6b7280; font-size: 13px;"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>

                <!-- COURSES PANEL -->
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Active Courses</div>
                        <a href="${pageContext.request.contextPath}/pages/admin/courses.jsp" class="panel-action">Manage →</a>
                    </div>
                    <div class="course-list">
                        <% if (courses != null) { for (Course c : courses) {
                            int max = c.getMaxStudents();
                        %>
                        <div class="course-card">
                            <div class="course-code-badge"><%= c.getCourseCode() %></div>
                            <div class="course-info">
                                <strong><%= c.getCourseName() %></strong>
                                <span><%= c.getCredits() %> credits &nbsp;·&nbsp; <%= c.getSchedule() != null ? c.getSchedule() : "TBA" %></span>
                            </div>
                            <div class="enrol-bar-wrap">
                                <div class="enrol-text">Max <%= max %></div>
                                <div class="enrol-bar">
                                    <div class="enrol-fill" style="width:100%"></div>
                                </div>
                            </div>
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
