<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cms.model.User, com.cms.dao.UserDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("/CourseManagementSystem/pages/login.jsp");
        return;
    }
    UserDAO userDAO = new UserDAO();
    List<User> users = userDAO.getAllUsers();
    String filterRole = request.getParameter("role");
    if (filterRole != null && filterRole.isEmpty()) filterRole = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users — CMS</title>
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

        /* SIDEBAR */
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
        .logout-btn { margin-left:auto; background:none; border:none; cursor:pointer; color:rgba(255,255,255,0.35); padding:4px; transition:color 0.15s; text-decoration:none; display:flex; }
        .logout-btn:hover { color:rgba(255,255,255,0.7); }

        /* MAIN */
        .main { margin-left:var(--sidebar); flex:1; display:flex; flex-direction:column; min-height:100vh; }
        .topbar { background:var(--white); border-bottom:1px solid var(--border); padding:0 2rem; height:64px; display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:50; }
        .topbar-left h1 { font-family:'Playfair Display',serif; font-size:20px; font-weight:500; color:var(--navy); }
        .topbar-left p { font-size:12px; color:var(--muted); }
        .content { padding:2rem; flex:1; }

        /* TOOLBAR */
        .toolbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:1.5rem; gap:1rem; flex-wrap:wrap; }
        .filter-tabs { display:flex; gap:6px; }
        .filter-tab { padding:7px 16px; border-radius:20px; border:1px solid var(--border); background:var(--white); font-family:'DM Sans',sans-serif; font-size:13px; color:var(--muted); cursor:pointer; text-decoration:none; transition:all 0.15s; }
        .filter-tab:hover { border-color:var(--navy); color:var(--navy); }
        .filter-tab.active { background:var(--navy); border-color:var(--navy); color:var(--white); }

        .btn-add { display:flex; align-items:center; gap:8px; padding:9px 18px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; font-weight:500; cursor:pointer; text-decoration:none; transition:background 0.15s; }
        .btn-add:hover { background:var(--navy2); }

        /* TABLE PANEL */
        .panel { background:var(--white); border:1px solid var(--border); border-radius:10px; overflow:hidden; }
        table { width:100%; border-collapse:collapse; font-size:14px; }
        thead th { text-align:left; padding:11px 1.5rem; font-size:11px; font-weight:500; letter-spacing:0.07em; text-transform:uppercase; color:var(--muted); background:var(--cream); border-bottom:1px solid var(--border); }
        tbody tr { border-bottom:1px solid #f3f0e8; transition:background 0.1s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#fdfaf4; }
        tbody td { padding:13px 1.5rem; color:var(--text); }

        .user-cell { display:flex; align-items:center; gap:10px; }
        .avatar { width:32px; height:32px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:500; flex-shrink:0; }
        .avatar-admin    { background:#eff6ff; color:#1e40af; }
        .avatar-instructor { background:#f0fdf4; color:#15803d; }
        .avatar-student  { background:#faf5ff; color:#7e22ce; }

        .role-badge { display:inline-block; font-size:11px; font-weight:500; padding:3px 10px; border-radius:20px; text-transform:capitalize; }
        .role-admin    { background:#eff6ff; color:#1e40af; }
        .role-instructor { background:#f0fdf4; color:#15803d; }
        .role-student  { background:#faf5ff; color:#7e22ce; }

        .action-btn { padding:5px 12px; border-radius:5px; font-size:12px; font-weight:500; font-family:'DM Sans',sans-serif; cursor:pointer; border:1px solid var(--border); background:var(--white); color:var(--navy); transition:all 0.15s; text-decoration:none; display:inline-block; }
        .action-btn:hover { background:var(--cream); border-color:var(--navy); }
        .action-btn.danger { color:#b91c1c; border-color:#fecaca; }
        .action-btn.danger:hover { background:#fef2f2; border-color:#b91c1c; }

        .empty-state { padding:3rem; text-align:center; color:var(--muted); font-size:14px; }

        /* MODAL */
        .modal-backdrop { display:none; position:fixed; inset:0; background:rgba(15,30,61,0.45); z-index:200; align-items:center; justify-content:center; }
        .modal-backdrop.open { display:flex; }
        .modal { background:var(--white); border-radius:12px; padding:2rem; width:100%; max-width:440px; margin:1rem; }
        .modal h2 { font-family:'Playfair Display',serif; font-size:20px; font-weight:500; color:var(--navy); margin-bottom:1.5rem; }
        .field { margin-bottom:1.1rem; }
        .field label { display:block; font-size:11px; font-weight:500; letter-spacing:0.06em; text-transform:uppercase; color:var(--navy2); margin-bottom:5px; }
        .field input, .field select { width:100%; height:42px; padding:0 12px; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; color:var(--text); background:var(--cream); outline:none; transition:border-color 0.2s; }
        .field input:focus, .field select:focus { border-color:var(--navy2); background:var(--white); }
        .modal-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:1.5rem; }
        .btn-cancel { padding:9px 18px; background:transparent; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; cursor:pointer; color:var(--muted); transition:all 0.15s; }
        .btn-cancel:hover { border-color:var(--navy); color:var(--navy); }
        .btn-save { padding:9px 20px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; font-weight:500; cursor:pointer; transition:background 0.15s; }
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
            <a href="/CourseManagementSystem/pages/admin/dashboard.jsp" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                Dashboard
            </a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-section-label">Management</div>
            <a href="/CourseManagementSystem/pages/admin/users.jsp" class="nav-item active">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Manage Users
            </a>
            <a href="/CourseManagementSystem/pages/admin/courses.jsp" class="nav-item">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                Manage Courses
            </a>
            <a href="/CourseManagementSystem/pages/admin/enrollments.jsp" class="nav-item">
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
                <form action="/CourseManagementSystem/auth" method="post" style="margin-left:auto;">
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
                <h1>Manage Users</h1>
                <p><%= users != null ? users.size() : 0 %> total users registered</p>
            </div>
        </header>
        <div class="content">
            <div class="toolbar">
                <div class="filter-tabs">
                    <a href="users.jsp" class="filter-tab <%= filterRole == null ? "active" : "" %>">All</a>
                    <a href="users.jsp?role=admin" class="filter-tab <%= "admin".equals(filterRole) ? "active" : "" %>">Admins</a>
                    <a href="users.jsp?role=instructor" class="filter-tab <%= "instructor".equals(filterRole) ? "active" : "" %>">Instructors</a>
                    <a href="users.jsp?role=student" class="filter-tab <%= "student".equals(filterRole) ? "active" : "" %>">Students</a>
                </div>
                <button class="btn-add" onclick="document.getElementById('addModal').classList.add('open')">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add User
                </button>
            </div>

            <div class="panel">
                <table>
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (users != null) { for (User u : users) {
                            if (filterRole != null && !filterRole.equals(u.getRole())) continue;
                            String initials = (u.getFirstName() != null ? u.getFirstName().substring(0,1) : "") +
                                             (u.getLastName()  != null ? u.getLastName().substring(0,1)  : "");
                            if (initials.isEmpty()) initials = u.getUsername().substring(0,1).toUpperCase();
                        %>
                        <tr>
                            <td>
                                <div class="user-cell">
                                    <div class="avatar avatar-<%= u.getRole() %>"><%= initials.toUpperCase() %></div>
                                    <div>
                                        <div style="font-weight:500;"><%= u.getFirstName() != null ? u.getFirstName() + " " + u.getLastName() : u.getUsername() %></div>
                                        <div style="font-size:12px;color:var(--muted);">@<%= u.getUsername() %></div>
                                    </div>
                                </div>
                            </td>
                            <td style="color:var(--muted);font-size:13px;"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
                            <td><span class="role-badge role-<%= u.getRole() %>"><%= u.getRole() %></span></td>
                            <td>
                                <div style="display:flex;gap:6px;">
                                    <button class="action-btn" onclick="openEdit('<%= u.getUserId() %>','<%= u.getUsername() %>','<%= u.getEmail() != null ? u.getEmail() : "" %>','<%= u.getFirstName() != null ? u.getFirstName() : "" %>','<%= u.getLastName() != null ? u.getLastName() : "" %>','<%= u.getRole() %>')">Edit</button>
                                    <form action="/CourseManagementSystem/auth" method="post" style="display:inline;" onsubmit="return confirm('Delete this user?')">
                                        <input type="hidden" name="action" value="deleteUser">
                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                        <button type="submit" class="action-btn danger">Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- ADD USER MODAL -->
<div class="modal-backdrop" id="addModal">
    <div class="modal">
        <h2>Add New User</h2>
        <form action="/CourseManagementSystem/auth" method="post">
            <input type="hidden" name="action" value="addUser">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                <div class="field"><label>First Name</label><input type="text" name="firstName" required></div>
                <div class="field"><label>Last Name</label><input type="text" name="lastName" required></div>
            </div>
            <div class="field"><label>Username</label><input type="text" name="username" required></div>
            <div class="field"><label>Email</label><input type="email" name="email" required></div>
            <div class="field"><label>Password</label><input type="password" name="password" required></div>
            <div class="field">
                <label>Role</label>
                <select name="role">
                    <option value="student">Student</option>
                    <option value="instructor">Instructor</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn-save">Add User</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT USER MODAL -->
<div class="modal-backdrop" id="editModal">
    <div class="modal">
        <h2>Edit User</h2>
        <form action="/CourseManagementSystem/auth" method="post">
            <input type="hidden" name="action" value="updateUser">
            <input type="hidden" name="userId" id="editUserId">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                <div class="field"><label>First Name</label><input type="text" name="firstName" id="editFirstName"></div>
                <div class="field"><label>Last Name</label><input type="text" name="lastName" id="editLastName"></div>
            </div>
            <div class="field"><label>Username</label><input type="text" name="username" id="editUsername"></div>
            <div class="field"><label>Email</label><input type="email" name="email" id="editEmail"></div>
            <div class="field">
                <label>Role</label>
                <select name="role" id="editRole">
                    <option value="student">Student</option>
                    <option value="instructor">Instructor</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="document.getElementById('editModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn-save">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEdit(id, username, email, firstName, lastName, role) {
    document.getElementById('editUserId').value = id;
    document.getElementById('editUsername').value = username;
    document.getElementById('editEmail').value = email;
    document.getElementById('editFirstName').value = firstName;
    document.getElementById('editLastName').value = lastName;
    document.getElementById('editRole').value = role;
    document.getElementById('editModal').classList.add('open');
}
document.querySelectorAll('.modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) el.classList.remove('open');
    });
});
</script>
</body>
</html>
