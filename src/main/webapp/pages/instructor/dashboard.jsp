<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.model.Course, com.cms.dao.CourseDAO, java.util.List, java.util.ArrayList" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"instructor".equals(currentUser.getRole())) {
        response.sendRedirect("${pageContext.request.contextPath}/pages/login.jsp");
        return;
    }
    CourseDAO courseDAO = new CourseDAO();
    List<Course> allCourses = courseDAO.getAllCourses();
    List<Course> myCourses = new ArrayList<>();
    if (allCourses != null) {
        for (Course c : allCourses) {
            if (c.getInstructorId() == currentUser.getUserId()) {
                myCourses.add(c);
            }
        }
    }
    int totalCredits = 0;
    int totalCapacity = 0;
    for (Course c : myCourses) {
        totalCredits  += c.getCredits();
        totalCapacity += c.getMaxStudents();
    }
    String displayName = (currentUser.getFirstName() != null && !currentUser.getFirstName().isEmpty())
        ? currentUser.getFirstName() + " " + currentUser.getLastName()
        : currentUser.getUsername();
    String firstName = (currentUser.getFirstName() != null && !currentUser.getFirstName().isEmpty())
        ? currentUser.getFirstName() : currentUser.getUsername();
    String initials = displayName.substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Dashboard — CMS</title>
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
        .user-avatar { width:34px; height:34px; background:rgba(201,168,76,0.2); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:500; color:var(--gold2); flex-shrink:0; }
        .user-info strong { display:block; font-size:13px; font-weight:500; color:var(--white); }
        .user-info span { font-size:11px; color:rgba(255,255,255,0.4); }
        .logout-btn { margin-left:auto; background:none; border:none; cursor:pointer; color:rgba(255,255,255,0.35); padding:4px; transition:color 0.15s; display:flex; }
        .logout-btn:hover { color:rgba(255,255,255,0.7); }

        .main { margin-left:var(--sidebar); flex:1; display:flex; flex-direction:column; min-height:100vh; }
        .topbar { background:var(--white); border-bottom:1px solid var(--border); padding:0 2rem; height:64px; display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:50; }
        .topbar-left h1 { font-family:'Playfair Display',serif; font-size:20px; font-weight:500; color:var(--navy); }
        .topbar-left p { font-size:12px; color:var(--muted); }
        .badge-instructor { background:#f0fdf4; color:#15803d; font-size:11px; font-weight:500; padding:3px 10px; border-radius:20px; letter-spacing:0.04em; text-transform:uppercase; }
        .content { padding:2rem; flex:1; }

        .welcome-banner { background:var(--navy); border-radius:12px; padding:1.75rem 2rem; margin-bottom:2rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
        .welcome-banner::before { content:''; position:absolute; top:-60px; right:-60px; width:200px; height:200px; border-radius:50%; border:1px solid rgba(201,168,76,0.15); }
        .welcome-text h2 { font-family:'Playfair Display',serif; font-size:22px; font-weight:500; color:var(--white); margin-bottom:4px; }
        .welcome-text p { font-size:14px; color:rgba(255,255,255,0.55); }
        .welcome-stats { display:flex; gap:2rem; position:relative; z-index:1; }
        .w-stat strong { display:block; font-family:'Playfair Display',serif; font-size:28px; font-weight:500; color:var(--gold2); }
        .w-stat span { font-size:12px; color:rgba(255,255,255,0.45); }

        .stats-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:1rem; margin-bottom:2rem; }
        .stat-card { background:var(--white); border:1px solid var(--border); border-radius:10px; padding:1.25rem 1.5rem; }
        .stat-label { font-size:11px; letter-spacing:0.07em; text-transform:uppercase; color:var(--muted); font-weight:500; }
        .stat-value { font-family:'Playfair Display',serif; font-size:32px; font-weight:500; color:var(--navy); line-height:1; margin:6px 0 4px; }
        .stat-sub { font-size:12px; color:var(--muted); }

        .content-grid { display:grid; grid-template-columns:1fr 320px; gap:1.5rem; }

        .panel { background:var(--white); border:1px solid var(--border); border-radius:10px; overflow:hidden; }
        .panel-header { padding:1.25rem 1.5rem; border-bottom:1px solid var(--border); }
        .panel-title { font-family:'Playfair Display',serif; font-size:16px; font-weight:500; color:var(--navy); }

        .course-list { padding:1rem 1.5rem; display:flex; flex-direction:column; gap:12px; }
        .course-row { border:1px solid var(--border); border-radius:8px; padding:1rem 1.25rem; transition:background 0.15s; }
        .course-row:hover { background:var(--cream); }
        .course-row-top { display:flex; align-items:center; gap:12px; margin-bottom:10px; }
        .course-code { background:var(--navy); color:var(--gold2); font-size:11px; font-weight:500; padding:4px 10px; border-radius:4px; letter-spacing:0.04em; flex-shrink:0; }
        .course-name { font-size:14px; font-weight:500; color:var(--navy); }
        .course-meta { display:flex; gap:1.25rem; flex-wrap:wrap; }
        .meta-chip { font-size:12px; color:var(--muted); display:flex; align-items:center; gap:4px; }

        .empty-state { padding:3rem; text-align:center; color:var(--muted); font-size:14px; }

        .actions-list { padding:1rem 1.5rem; display:flex; flex-direction:column; gap:8px; }
        .action-card { display:flex; align-items:center; gap:12px; padding:0.9rem 1rem; border:1px solid var(--border); border-radius:8px; cursor:pointer; background:var(--white); width:100%; font-family:'DM Sans',sans-serif; text-align:left; transition:background 0.15s,border-color 0.15s; }
        .action-card:hover { background:var(--cream); border-color:var(--navy2); }
        .action-icon { width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .action-icon.blue   { background:#eff6ff; }
        .action-icon.green  { background:#f0fdf4; }
        .action-icon.amber  { background:#fffbeb; }
        .action-icon.purple { background:#faf5ff; }
        .action-label { font-size:14px; font-weight:500; color:var(--navy); }
        .action-desc  { font-size:12px; color:var(--muted); }

        @media(max-width:1100px) { .stats-grid{grid-template-columns:repeat(2,1fr);} .content-grid{grid-template-columns:1fr;} }
        @media(max-width:768px) { .sidebar{display:none;} .main{margin-left:0;} .welcome-stats{display:none;} }
    </style>
</head>
<body>
<div class="shell">

    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-crest">U</div>
            <div class="brand-name">University CMS</div>
            <div class="brand-sub">Instructor Portal</div>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-section-label">My Teaching</div>
            <a href="${pageContext.request.contextPath}/pages/instructor/dashboard.jsp" class="nav-item active">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                Dashboard
            </a>
            <a href="#my-courses" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                My Courses
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="user-chip">
                <div class="user-avatar"><%= initials %></div>
                <div class="user-info">
                    <strong><%= displayName %></strong>
                    <span>Instructor</span>
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
                <h1>Supervisor Dashboard</h1>
                <p>Honours Computer Science — supervision portal</p>
            </div>
            <div><span class="badge-instructor">Supervisor</span></div>
        </header>

        <div class="content">

            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Good day, <%= firstName %></h2>
                    <p>BSc Honours Computer Science — your supervision assignments for 2026.</p>
                </div>
                <div class="welcome-stats">
                    <div class="w-stat">
                        <strong><%= myCourses.size() %></strong>
                        <span>Courses</span>
                    </div>
                    <div class="w-stat">
                        <strong><%= totalCredits %></strong>
                        <span>Credits</span>
                    </div>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">My Courses</div>
                    <div class="stat-value"><%= myCourses.size() %></div>
                    <div class="stat-sub">Assigned this semester</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Teaching Credits</div>
                    <div class="stat-value"><%= totalCredits %></div>
                    <div class="stat-sub">Total credit hours</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Capacity</div>
                    <div class="stat-value"><%= totalCapacity %></div>
                    <div class="stat-sub">Max students across courses</div>
                </div>
            </div>

            <div class="content-grid">

                <div class="panel" id="my-courses">
                    <div class="panel-header">
                        <div class="panel-title">My Assigned Courses</div>
                    </div>
                    <div class="course-list">
                        <% if (!myCourses.isEmpty()) { for (Course c : myCourses) { %>
                        <div class="course-row">
                            <div class="course-row-top">
                                <div class="course-code"><%= c.getCourseCode() %></div>
                                <div class="course-name"><%= c.getCourseName() %></div>
                            </div>
                            <div class="course-meta">
                                <div class="meta-chip">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    <%= c.getSchedule() != null && !c.getSchedule().isEmpty() ? c.getSchedule() : "TBA" %>
                                </div>
                                <div class="meta-chip">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                                    <%= c.getRoomAssignment() != null && !c.getRoomAssignment().isEmpty() ? c.getRoomAssignment() : "Room TBA" %>
                                </div>
                                <div class="meta-chip">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                                    Max <%= c.getMaxStudents() %> students
                                </div>
                                <div class="meta-chip">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                    <%= c.getCredits() %> credits
                                </div>
                            </div>
                        </div>
                        <% } } else { %>
                        <div class="empty-state">
                            <p>No courses assigned yet.</p>
                            <p style="margin-top:6px;font-size:13px;">Contact your administrator to get courses assigned.</p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Quick Actions</div>
                    </div>
                    <div class="actions-list">
                        <button class="action-card">
                            <div class="action-icon blue">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1e40af" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div>
                                <div class="action-label">View Students</div>
                                <div class="action-desc">See enrolled students per course</div>
                            </div>
                        </button>
                        <button class="action-card">
                            <div class="action-icon green">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="1.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                            </div>
                            <div>
                                <div class="action-label">Grade Assignments</div>
                                <div class="action-desc">Review and submit grades</div>
                            </div>
                        </button>
                        <button class="action-card">
                            <div class="action-icon amber">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#92400e" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                            </div>
                            <div>
                                <div class="action-label">Course Materials</div>
                                <div class="action-desc">Upload notes and resources</div>
                            </div>
                        </button>
                        <button class="action-card">
                            <div class="action-icon purple">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7e22ce" stroke-width="1.5"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                            </div>
                            <div>
                                <div class="action-label">Announcements</div>
                                <div class="action-desc">Post updates to your class</div>
                            </div>
                        </button>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
</body>
</html>
