<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.model.Course, com.cms.dao.UserDAO, com.cms.dao.CourseDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("${pageContext.request.contextPath}/pages/login.jsp");
        return;
    }
    CourseDAO courseDAO = new CourseDAO();
    UserDAO userDAO   = new UserDAO();
    List<Course> courses = courseDAO.getAllCourses();
    List<User>   users   = userDAO.getAllUsers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrolments — CMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --navy:#0f1e3d; --navy2:#1a2f5e; --navy3:#243f7a;
            --gold:#c9a84c; --gold2:#e8c96a;
            --cream:#f9f6ef; --white:#ffffff;
            --text:#1a1a2e; --muted:#6b7280; --border:#e5e0d5;
            --sidebar:260px;
        }
        html,body { height:100%; font-family:'DM Sans',sans-serif; background:var(--cream); color:var(--text); }
        .shell { display:flex; min-height:100vh; }

        .sidebar { width:var(--sidebar); background:var(--navy); display:flex; flex-direction:column; flex-shrink:0; position:fixed; top:0; left:0; height:100vh; overflow-y:auto; z-index:100; }
        .sidebar-brand { padding:1.75rem 1.5rem 1.5rem; border-bottom:1px solid rgba(255,255,255,0.08); }
        .brand-crest { width:40px; height:40px; background:var(--gold); border-radius:4px; display:flex; align-items:center; justify-content:center; font-family:'Playfair Display',serif; font-size:18px; font-weight:600; color:var(--navy); margin-bottom:10px; }
        .brand-name { font-family:'Playfair Display',serif; font-size:15px; font-weight:500; color:var(--white); }
        .brand-sub { font-size:11px; color:rgba(255,255,255,0.4); letter-spacing:0.06em; text-transform:uppercase; margin-top:2px; }
        .sidebar-section { padding:1.5rem 1rem 0.5rem; }
        .sidebar-section-label { font-size:10px; letter-spacing:0.1em; text-transform:uppercase; color:rgba(255,255,255,0.3); padding:0 0.5rem; margin-bottom:6px; }
        .nav-item { display:flex; align-items:center; gap:10px; padding:10px 12px; border-radius:6px; text-decoration:none; font-size:14px; color:rgba(255,255,255,0.65); transition:background 0.15s,color 0.15s; margin-bottom:2px; }
        .nav-item:hover { background:rgba(255,255,255,0.07); color:var(--white); }
        .nav-item.active { background:rgba(201,168,76,0.15); color:var(--gold2); }
        .nav-icon { width:18px; height:18px; opacity:0.7; flex-shrink:0; }
        .nav-item.active .nav-icon { opacity:1; }
        .sidebar-footer { margin-top:auto; padding:1.25rem 1rem; border-top:1px solid rgba(255,255,255,0.08); }
        .user-chip { display:flex; align-items:center; gap:10px; }
        .user-avatar { width:34px; height:34px; background:var(--navy3); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:500; color:var(--gold2); flex-shrink:0; }
        .user-info strong { display:block; font-size:13px; font-weight:500; color:var(--white); }
        .user-info span { font-size:11px; color:rgba(255,255,255,0.4); }
        .logout-btn { margin-left:auto; background:none; border:none; cursor:pointer; color:rgba(255,255,255,0.35); padding:4px; transition:color 0.15s; display:flex; }
        .logout-btn:hover { color:rgba(255,255,255,0.7); }

        .main { margin-left:var(--sidebar); flex:1; display:flex; flex-direction:column; min-height:100vh; }
        .topbar { background:var(--white); border-bottom:1px solid var(--border); padding:0 2rem; height:64px; display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:50; }
        .topbar-left h1 { font-family:'Playfair Display',serif; font-size:20px; font-weight:500; color:var(--navy); }
        .topbar-left p { font-size:12px; color:var(--muted); }
        .content { padding:2rem; flex:1; }

        .two-panel { display:grid; grid-template-columns:1fr 360px; gap:1.5rem; }

        /* ENROL FORM PANEL */
        .panel { background:var(--white); border:1px solid var(--border); border-radius:10px; overflow:hidden; }
        .panel-header { padding:1.25rem 1.5rem; border-bottom:1px solid var(--border); }
        .panel-title { font-family:'Playfair Display',serif; font-size:16px; font-weight:500; color:var(--navy); }
        .panel-body { padding:1.5rem; }

        .field { margin-bottom:1.25rem; }
        .field label { display:block; font-size:11px; font-weight:500; letter-spacing:0.06em; text-transform:uppercase; color:var(--navy2); margin-bottom:6px; }
        .field select { width:100%; height:44px; padding:0 12px; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; color:var(--text); background:var(--cream); outline:none; transition:border-color 0.2s; }
        .field select:focus { border-color:var(--navy2); background:var(--white); }

        .btn-enrol { width:100%; height:46px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:15px; font-weight:500; cursor:pointer; transition:background 0.15s; }
        .btn-enrol:hover { background:var(--navy2); }

        .success-msg { background:#f0fdf4; border:1px solid #bbf7d0; color:#15803d; font-size:13px; padding:10px 14px; border-radius:6px; margin-bottom:1.25rem; }
        .error-msg   { background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; font-size:13px; padding:10px 14px; border-radius:6px; margin-bottom:1.25rem; }

        /* COURSES TABLE */
        table { width:100%; border-collapse:collapse; font-size:14px; }
        thead th { text-align:left; padding:11px 1.5rem; font-size:11px; font-weight:500; letter-spacing:0.07em; text-transform:uppercase; color:var(--muted); background:var(--cream); border-bottom:1px solid var(--border); }
        tbody tr { border-bottom:1px solid #f3f0e8; transition:background 0.1s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#fdfaf4; }
        tbody td { padding:12px 1.5rem; }

        .course-code-badge { background:var(--navy); color:var(--gold2); font-size:11px; font-weight:500; padding:3px 9px; border-radius:4px; letter-spacing:0.04em; }

        .capacity-wrap { display:flex; align-items:center; gap:8px; }
        .capacity-bar { flex:1; height:4px; background:var(--border); border-radius:2px; overflow:hidden; }
        .capacity-fill { height:100%; background:var(--navy2); border-radius:2px; }
        .capacity-text { font-size:12px; color:var(--muted); white-space:nowrap; }

        @media(max-width:1000px) { .two-panel{grid-template-columns:1fr;} }
        @media(max-width:768px) { .sidebar{display:none;} .main{margin-left:0;} }
    </style>
</head>
<body>
<div class="shell">
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-crest">U</div>
            <div class="brand-name">University CMS</div>
            <div class="brand-sub">Course Management</div>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-section-label">Overview</div>
            <a href="${pageContext.request.contextPath}/pages/admin/dashboard.jsp" class="nav-item">
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
            <a href="${pageContext.request.contextPath}/pages/admin/enrollments.jsp" class="nav-item active">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                Enrolments
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="user-chip">
                <div class="user-avatar"><%= currentUser.getUsername().substring(0,1).toUpperCase() %></div>
                <div class="user-info">
                    <strong><%= currentUser.getUsername() %></strong>
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

    <div class="main">
        <header class="topbar">
            <div class="topbar-left">
                <h1>Enrolments</h1>
                <p>Enrol students into courses manually</p>
            </div>
        </header>
        <div class="content">
            <div class="two-panel">

                <!-- COURSES LIST -->
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Active Courses</div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Course Name</th>
                                <th>Credits</th>
                                <th>Capacity</th>
                                <th>Instructor</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (courses != null) { for (Course c : courses) { %>
                            <tr>
                                <td><span class="course-code-badge"><%= c.getCourseCode() %></span></td>
                                <td style="font-weight:500;color:var(--navy);"><%= c.getCourseName() %></td>
                                <td style="color:var(--muted);"><%= c.getCredits() %></td>
                                <td>
                                    <div class="capacity-wrap">
                                        <div class="capacity-bar">
                                            <div class="capacity-fill" style="width:40%"></div>
                                        </div>
                                        <span class="capacity-text">/<%= c.getMaxStudents() %></span>
                                    </div>
                                </td>
                                <td style="font-size:13px;color:var(--muted);"><%= c.getInstructorName() != null ? c.getInstructorName() : "—" %></td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>

                <!-- ENROL FORM -->
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Enrol a Student</div>
                    </div>
                    <div class="panel-body">
                        <% String msg = (String) request.getAttribute("message");
                           String err = (String) request.getAttribute("error"); %>
                        <% if (msg != null) { %><div class="success-msg"><%= msg %></div><% } %>
                        <% if (err != null) { %><div class="error-msg"><%= err %></div><% } %>

                        <form action="${pageContext.request.contextPath}/auth" method="post">
                            <input type="hidden" name="action" value="adminEnroll">
                            <div class="field">
                                <label>Select Student</label>
                                <select name="studentId" required>
                                    <option value="">— Choose a student —</option>
                                    <% if (users != null) { for (User u : users) { if ("student".equals(u.getRole())) { %>
                                    <option value="<%= u.getUserId() %>">
                                        <%= u.getFirstName() != null ? u.getFirstName() + " " + u.getLastName() : u.getUsername() %>
                                    </option>
                                    <% } } } %>
                                </select>
                            </div>
                            <div class="field">
                                <label>Select Course</label>
                                <select name="courseId" required>
                                    <option value="">— Choose a course —</option>
                                    <% if (courses != null) { for (Course c : courses) { %>
                                    <option value="<%= c.getCourseId() %>">
                                        <%= c.getCourseCode() %> — <%= c.getCourseName() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                            <button type="submit" class="btn-enrol">Enrol Student</button>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
</body>
</html>
