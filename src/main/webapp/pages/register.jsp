<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CMS — Create Account</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --navy:#0f1e3d; --navy2:#1a2f5e;
            --gold:#c9a84c; --gold2:#e8c96a;
            --cream:#f9f6ef; --white:#ffffff;
            --text:#1a1a2e; --muted:#6b7280; --border:#e0d8c8;
            --error:#b91c1c;
        }
        html,body { height:100%; font-family:'DM Sans',sans-serif; background:var(--cream); color:var(--text); }

        .page { min-height:100vh; display:grid; grid-template-columns:1fr 480px; }

        /* LEFT */
        .left { background:var(--navy); position:relative; overflow:hidden; display:flex; flex-direction:column; justify-content:space-between; padding:3rem; }
        .left::before { content:''; position:absolute; top:-120px; right:-120px; width:500px; height:500px; border-radius:50%; border:1px solid rgba(201,168,76,0.15); }
        .left::after  { content:''; position:absolute; bottom:-80px; left:-80px; width:380px; height:380px; border-radius:50%; border:1px solid rgba(201,168,76,0.1); }

        .left-logo { display:flex; align-items:center; gap:12px; position:relative; z-index:1; }
        .logo-crest { width:44px; height:44px; background:var(--gold); border-radius:4px; display:flex; align-items:center; justify-content:center; font-family:'Playfair Display',serif; font-size:20px; font-weight:600; color:var(--navy); }
        .logo-text { font-family:'Playfair Display',serif; font-size:18px; font-weight:500; color:var(--white); line-height:1.2; }
        .logo-text span { display:block; font-family:'DM Sans',sans-serif; font-size:11px; font-weight:300; color:rgba(255,255,255,0.5); letter-spacing:0.08em; text-transform:uppercase; }

        .left-hero { position:relative; z-index:1; }
        .left-hero h1 { font-family:'Playfair Display',serif; font-size:clamp(1.8rem,3vw,2.6rem); font-weight:400; color:var(--white); line-height:1.25; margin-bottom:1.25rem; }
        .left-hero h1 em { font-style:italic; color:var(--gold2); }
        .left-hero p { font-size:15px; font-weight:300; color:rgba(255,255,255,0.6); line-height:1.7; max-width:360px; }

        .steps { margin-top:2.5rem; padding-top:2.5rem; border-top:1px solid rgba(255,255,255,0.1); display:flex; flex-direction:column; gap:1rem; }
        .step { display:flex; align-items:center; gap:12px; }
        .step-num { width:28px; height:28px; border-radius:50%; background:rgba(201,168,76,0.2); border:1px solid rgba(201,168,76,0.4); display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:500; color:var(--gold2); flex-shrink:0; }
        .step-text { font-size:13px; color:rgba(255,255,255,0.55); }

        .left-footer { font-size:12px; color:rgba(255,255,255,0.3); position:relative; z-index:1; }

        /* RIGHT */
        .right { background:var(--white); display:flex; align-items:center; justify-content:center; padding:2.5rem; border-left:1px solid var(--border); overflow-y:auto; }

        .form-box { width:100%; max-width:360px; }

        .form-top { margin-bottom:2rem; }
        .form-top h2 { font-family:'Playfair Display',serif; font-size:26px; font-weight:500; color:var(--navy); margin-bottom:6px; }
        .form-top p { font-size:14px; color:var(--muted); }
        .divider-line { width:40px; height:2px; background:var(--gold); margin:1rem 0 1.5rem; }

        .two-col { display:grid; grid-template-columns:1fr 1fr; gap:12px; }

        .field { margin-bottom:1.1rem; }
        .field label { display:block; font-size:11px; font-weight:500; letter-spacing:0.06em; text-transform:uppercase; color:var(--navy2); margin-bottom:5px; }
        .field input, .field select { width:100%; height:44px; padding:0 12px; border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; color:var(--text); background:var(--cream); outline:none; transition:border-color 0.2s,background 0.2s; }
        .field input:focus, .field select:focus { border-color:var(--navy2); background:var(--white); }

        .btn-primary { width:100%; height:48px; background:var(--navy); color:var(--white); border:none; border-radius:6px; font-family:'DM Sans',sans-serif; font-size:15px; font-weight:500; cursor:pointer; transition:background 0.2s; letter-spacing:0.02em; }
        .btn-primary:hover { background:var(--navy2); }

        .separator { display:flex; align-items:center; gap:12px; margin:1.25rem 0; font-size:12px; color:var(--muted); }
        .separator::before, .separator::after { content:''; flex:1; height:1px; background:var(--border); }

        .btn-secondary { width:100%; height:44px; background:transparent; color:var(--navy); border:1px solid var(--border); border-radius:6px; font-family:'DM Sans',sans-serif; font-size:14px; cursor:pointer; transition:border-color 0.2s,background 0.2s; text-decoration:none; display:flex; align-items:center; justify-content:center; }
        .btn-secondary:hover { border-color:var(--navy); background:var(--cream); }

        .error-msg { background:#fef2f2; border:1px solid #fecaca; color:var(--error); font-size:13px; padding:10px 14px; border-radius:6px; margin-bottom:1.25rem; }

        @media(max-width:768px) { .page{grid-template-columns:1fr;} .left{display:none;} .right{padding:2rem 1.5rem;} }
    </style>
</head>
<body>
<div class="page">

    <div class="left">
        <div class="left-logo">
            <div class="logo-crest">U</div>
            <div class="logo-text">
                University CMS
                <span>Course Management System</span>
            </div>
        </div>

        <div class="left-hero">
            <h1>Join the <em>academic</em><br>community.</h1>
            <p>Create your account to access courses, track your progress, and connect with instructors.</p>
            <div class="steps">
                <div class="step"><div class="step-num">1</div><div class="step-text">Create your account with your university details</div></div>
                <div class="step"><div class="step-num">2</div><div class="step-text">Browse and enrol in available courses</div></div>
                <div class="step"><div class="step-num">3</div><div class="step-text">Track your academic progress from your dashboard</div></div>
            </div>
        </div>

        <div class="left-footer">© 2026 University Course Management System</div>
    </div>

    <div class="right">
        <div class="form-box">
            <div class="form-top">
                <h2>Create account</h2>
                <p>Fill in your details to get started</p>
                <div class="divider-line"></div>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
            <div class="error-msg"><%= error %></div>
            <% } %>

            <form action="/CourseManagementSystem/auth" method="post">
                <input type="hidden" name="action" value="register">

                <div class="two-col">
                    <div class="field">
                        <label>First Name</label>
                        <input type="text" name="firstName" placeholder="John" required>
                    </div>
                    <div class="field">
                        <label>Last Name</label>
                        <input type="text" name="lastName" placeholder="Smith" required>
                    </div>
                </div>

                <div class="field">
                    <label>Username</label>
                    <input type="text" name="username" placeholder="Choose a username" required>
                </div>

                <div class="field">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="you@university.edu" required>
                </div>

                <div class="field">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Minimum 8 characters" minlength="8" required>
                </div>

                <div class="field">
                    <label>Role</label>
                    <select name="role">
                        <option value="student">Student</option>
                        <option value="instructor">Instructor</option>
                    </select>
                </div>

                <button type="submit" class="btn-primary">Create Account</button>
            </form>

            <div class="separator">already have an account?</div>
            <a href="/CourseManagementSystem/pages/login.jsp" class="btn-secondary">Sign In</a>
        </div>
    </div>

</div>
</body>
</html>
