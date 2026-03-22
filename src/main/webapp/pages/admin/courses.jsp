<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.model.Course, com.cms.dao.UserDAO, com.cms.dao.CourseDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("${pageContext.request.contextPath}/pages/login.jsp");
        return;
    }
    CourseDAO courseDAO = new CourseDAO();
    UserDAO userDAO = new UserDAO();
    List<Course> courses = courseDAO.getAllCourses();
    List<User> allUsers = userDAO.getAllUsers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Courses — CMS</title>
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

        .toolbar { display:flex; align-items:center; justify-content:flex-end; margin-bottom:1.5rem; }
        .btn-add { display:flex; align-items:center; gap:8px; padding:9px 18px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; font-weight:500; cursor:pointer; transition:background 0.15s; }
        .btn-add:hover { background:var(--navy2); }

        /* COURSE CARDS GRID */
        .courses-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1rem; }

        .course-card { background:var(--white); border:1px solid var(--border); border-radius:10px; overflow:hidden; transition:box-shadow 0.2s; }
        .course-card:hover { box-shadow:0 4px 16px rgba(15,30,61,0.08); }

        .card-header { background:var(--navy); padding:1.1rem 1.25rem; display:flex; align-items:center; justify-content:space-between; }
        .card-code { font-family:'Playfair Display',serif; font-size:16px; font-weight:500; color:var(--gold2); }
        .card-status { font-size:11px; font-weight:500; padding:3px 10px; border-radius:20px; background:rgba(255,255,255,0.1); color:rgba(255,255,255,0.7); text-transform:capitalize; }

        .card-body { padding:1.1rem 1.25rem; }
        .card-name { font-size:15px; font-weight:500; color:var(--navy); margin-bottom:6px; }
        .card-desc { font-size:13px; color:var(--muted); line-height:1.5; margin-bottom:1rem; min-height:36px; }

        .card-meta { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:1rem; }
        .meta-item { }
        .meta-label { font-size:10px; letter-spacing:0.06em; text-transform:uppercase; color:var(--muted); margin-bottom:2px; }
        .meta-value { font-size:13px; font-weight:500; color:var(--navy); }

        .card-footer { padding:0.9rem 1.25rem; border-top:1px solid var(--border); display:flex; gap:8px; }
        .action-btn { padding:6px 14px; border-radius:5px; font-size:12px; font-weight:500; font-family:'DM Sans',sans-serif; cursor:pointer; border:1px solid var(--border); background:var(--white); color:var(--navy); transition:all 0.15s; }
        .action-btn:hover { background:var(--cream); border-color:var(--navy); }
        .action-btn.danger { color:#b91c1c; border-color:#fecaca; }
        .action-btn.danger:hover { background:#fef2f2; border-color:#b91c1c; }

        /* MODAL */
        .modal-backdrop { display:none; position:fixed; inset:0; background:rgba(15,30,61,0.45); z-index:200; align-items:center; justify-content:center; }
        .modal-backdrop.open { display:flex; }
        .modal { background:var(--white); border-radius:12px; padding:2rem; width:100%; max-width:500px; margin:1rem; max-height:90vh; overflow-y:auto; }
        .modal h2 { font-family:'Playfair Display',serif; font-size:20px; font-weight:500; color:var(--navy); margin-bottom:1.5rem; }
        .field { margin-bottom:1.1rem; }
        .field label { display:block; font-size:11px; font-weight:500; letter-spacing:0.06em; text-transform:uppercase; color:var(--navy2); margin-bottom:5px; }
        .field input, .field select, .field textarea { width:100%; padding:10px 12px; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; color:var(--text); background:var(--cream); outline:none; transition:border-color 0.2s; }
        .field input:focus, .field select:focus, .field textarea:focus { border-color:var(--navy2); background:var(--white); }
        .field textarea { resize:vertical; min-height:80px; }
        .two-col { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
        .modal-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:1.5rem; }
        .btn-cancel { padding:9px 18px; background:transparent; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; cursor:pointer; color:var(--muted); }
        .btn-cancel:hover { border-color:var(--navy); color:var(--navy); }
        .btn-save { padding:9px 20px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; font-weight:500; cursor:pointer; }
        .btn-save:hover { background:var(--navy2); }

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
            <a href="${pageContext.request.contextPath}/pages/admin/courses.jsp" class="nav-item active">
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
                <h1>Manage Courses</h1>
                <p><%= courses != null ? courses.size() : 0 %> active courses</p>
            </div>
        </header>
        <div class="content">
            <div class="toolbar">
                <button class="btn-add" onclick="document.getElementById('addModal').classList.add('open')">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add Course
                </button>
            </div>

            <div class="courses-grid">
                <% if (courses != null) { for (Course c : courses) { %>
                <div class="course-card">
                    <div class="card-header">
                        <span class="card-code"><%= c.getCourseCode() %></span>
                        <span class="card-status"><%= c.getStatus() %></span>
                    </div>
                    <div class="card-body">
                        <div class="card-name"><%= c.getCourseName() %></div>
                        <div class="card-desc"><%= c.getDescription() != null && !c.getDescription().isEmpty() ? c.getDescription() : "No description provided." %></div>
                        <div class="card-meta">
                            <div class="meta-item">
                                <div class="meta-label">Credits</div>
                                <div class="meta-value"><%= c.getCredits() %></div>
                            </div>
                            <div class="meta-item">
                                <div class="meta-label">Max Students</div>
                                <div class="meta-value"><%= c.getMaxStudents() %></div>
                            </div>
                            <div class="meta-item">
                                <div class="meta-label">Instructor</div>
                                <div class="meta-value" style="font-size:12px;"><%= c.getInstructorName() != null ? c.getInstructorName() : "Unassigned" %></div>
                            </div>
                            <div class="meta-item">
                                <div class="meta-label">Schedule</div>
                                <div class="meta-value" style="font-size:12px;"><%= c.getSchedule() != null ? c.getSchedule() : "TBA" %></div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <button class="action-btn" onclick="openEditCourse('<%= c.getCourseId() %>','<%= c.getCourseCode() %>','<%= c.getCourseName().replace("'","\\'") %>','<%= c.getCredits() %>','<%= c.getMaxStudents() %>','<%= c.getSchedule() != null ? c.getSchedule() : "" %>','<%= c.getRoomAssignment() != null ? c.getRoomAssignment() : "" %>')">Edit</button>
                        <form action="${pageContext.request.contextPath}/auth" method="post" style="display:inline;" onsubmit="return confirm('Delete this course?')">
                            <input type="hidden" name="action" value="deleteCourse">
                            <input type="hidden" name="courseId" value="<%= c.getCourseId() %>">
                            <button type="submit" class="action-btn danger">Delete</button>
                        </form>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>

<!-- ADD COURSE MODAL -->
<div class="modal-backdrop" id="addModal">
    <div class="modal">
        <h2>Add New Course</h2>
        <form action="${pageContext.request.contextPath}/auth" method="post">
            <input type="hidden" name="action" value="addCourse">
            <div class="two-col">
                <div class="field"><label>Course Code</label><input type="text" name="courseCode" placeholder="e.g. CS201" required></div>
                <div class="field"><label>Credits</label><input type="number" name="credits" min="1" max="6" value="3" required></div>
            </div>
            <div class="field"><label>Course Name</label><input type="text" name="courseName" required></div>
            <div class="field"><label>Description</label><textarea name="description" placeholder="Brief course description..."></textarea></div>
            <div class="two-col">
                <div class="field"><label>Max Students</label><input type="number" name="maxStudents" value="30" min="1"></div>
                <div class="field">
                    <label>Instructor</label>
                    <select name="instructorId">
                        <option value="">— Unassigned —</option>
                        <% if (allUsers != null) { for (User u : allUsers) { if ("instructor".equals(u.getRole())) { %>
                        <option value="<%= u.getUserId() %>"><%= u.getFirstName() %> <%= u.getLastName() %></option>
                        <% } } } %>
                    </select>
                </div>
            </div>
            <div class="two-col">
                <div class="field"><label>Schedule</label><input type="text" name="schedule" placeholder="e.g. Mon/Wed 10:00"></div>
                <div class="field"><label>Room</label><input type="text" name="roomAssignment" placeholder="e.g. Room 204"></div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn-save">Add Course</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT COURSE MODAL -->
<div class="modal-backdrop" id="editCourseModal">
    <div class="modal">
        <h2>Edit Course</h2>
        <form action="${pageContext.request.contextPath}/auth" method="post">
            <input type="hidden" name="action" value="updateCourse">
            <input type="hidden" name="courseId" id="editCourseId">
            <div class="two-col">
                <div class="field"><label>Course Code</label><input type="text" name="courseCode" id="editCourseCode" required></div>
                <div class="field"><label>Credits</label><input type="number" name="credits" id="editCredits" min="1" max="6"></div>
            </div>
            <div class="field"><label>Course Name</label><input type="text" name="courseName" id="editCourseName" required></div>
            <div class="two-col">
                <div class="field"><label>Max Students</label><input type="number" name="maxStudents" id="editMaxStudents"></div>
                <div class="field"><label>Schedule</label><input type="text" name="schedule" id="editSchedule"></div>
            </div>
            <div class="field"><label>Room Assignment</label><input type="text" name="roomAssignment" id="editRoom"></div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="document.getElementById('editCourseModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn-save">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditCourse(id, code, name, credits, maxStudents, schedule, room) {
    document.getElementById('editCourseId').value = id;
    document.getElementById('editCourseCode').value = code;
    document.getElementById('editCourseName').value = name;
    document.getElementById('editCredits').value = credits;
    document.getElementById('editMaxStudents').value = maxStudents;
    document.getElementById('editSchedule').value = schedule;
    document.getElementById('editRoom').value = room;
    document.getElementById('editCourseModal').classList.add('open');
}
document.querySelectorAll('.modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) { if (e.target === el) el.classList.remove('open'); });
});
</script>
</body>
</html>
