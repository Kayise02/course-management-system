<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CMS — Sign In</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --navy:   #0f1e3d;
            --navy2:  #1a2f5e;
            --gold:   #c9a84c;
            --gold2:  #e8c96a;
            --cream:  #f9f6ef;
            --text:   #1a1a2e;
            --muted:  #6b7280;
            --border: #e0d8c8;
            --white:  #ffffff;
            --error:  #b91c1c;
        }

        html, body {
            height: 100%;
            font-family: 'DM Sans', sans-serif;
            background: var(--cream);
            color: var(--text);
        }

        .page {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 480px;
        }

        /* ── LEFT PANEL ── */
        .left {
            background: var(--navy);
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 3rem;
        }

        .left::before {
            content: '';
            position: absolute;
            top: -120px; right: -120px;
            width: 500px; height: 500px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.15);
        }
        .left::after {
            content: '';
            position: absolute;
            bottom: -80px; left: -80px;
            width: 380px; height: 380px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.1);
        }

        .left-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
            z-index: 1;
        }

        .logo-crest {
            width: 44px; height: 44px;
            background: var(--gold);
            border-radius: 4px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 600;
            color: var(--navy);
        }

        .logo-text {
            font-family: 'Playfair Display', serif;
            font-size: 18px;
            font-weight: 500;
            color: var(--white);
            line-height: 1.2;
        }
        .logo-text span {
            display: block;
            font-family: 'DM Sans', sans-serif;
            font-size: 11px;
            font-weight: 300;
            color: rgba(255,255,255,0.5);
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .left-hero {
            position: relative;
            z-index: 1;
        }

        .left-hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(2rem, 3.5vw, 3rem);
            font-weight: 400;
            color: var(--white);
            line-height: 1.25;
            margin-bottom: 1.25rem;
        }

        .left-hero h1 em {
            font-style: italic;
            color: var(--gold2);
        }

        .left-hero p {
            font-size: 15px;
            font-weight: 300;
            color: rgba(255,255,255,0.6);
            line-height: 1.7;
            max-width: 360px;
        }

        .stats-row {
            display: flex;
            gap: 2rem;
            margin-top: 2.5rem;
            padding-top: 2.5rem;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        .stat-item strong {
            display: block;
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            font-weight: 500;
            color: var(--gold2);
        }
        .stat-item span {
            font-size: 12px;
            color: rgba(255,255,255,0.45);
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        .left-footer {
            font-size: 12px;
            color: rgba(255,255,255,0.3);
            position: relative;
            z-index: 1;
        }

        /* ── RIGHT PANEL ── */
        .right {
            background: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem 2.5rem;
            border-left: 1px solid var(--border);
        }

        .form-box {
            width: 100%;
            max-width: 360px;
        }

        .form-top {
            margin-bottom: 2.5rem;
        }

        .form-top h2 {
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            font-weight: 500;
            color: var(--navy);
            margin-bottom: 6px;
        }

        .form-top p {
            font-size: 14px;
            color: var(--muted);
        }

        .divider-line {
            width: 40px; height: 2px;
            background: var(--gold);
            margin: 1rem 0 1.5rem;
        }

        .field {
            margin-bottom: 1.25rem;
        }

        .field label {
            display: block;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            color: var(--navy2);
            margin-bottom: 6px;
        }

        .field input {
            width: 100%;
            height: 46px;
            padding: 0 14px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            color: var(--text);
            background: var(--cream);
            transition: border-color 0.2s, background 0.2s;
            outline: none;
        }

        .field input:focus {
            border-color: var(--navy2);
            background: var(--white);
        }

        .field-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
        }

        .field-row label {
            margin-bottom: 0;
        }

        .forgot {
            font-size: 12px;
            color: var(--gold);
            text-decoration: none;
            font-weight: 500;
        }
        .forgot:hover { text-decoration: underline; }

        .remember {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 1.75rem;
            cursor: pointer;
        }
        .remember input { width: auto; }

        .btn-primary {
            width: 100%;
            height: 48px;
            background: var(--navy);
            color: var(--white);
            border: none;
            border-radius: 6px;
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
            letter-spacing: 0.02em;
        }
        .btn-primary:hover { background: var(--navy2); }
        .btn-primary:active { transform: scale(0.99); }

        .separator {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 1.5rem 0;
            font-size: 12px;
            color: var(--muted);
        }
        .separator::before, .separator::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        .btn-secondary {
            width: 100%;
            height: 46px;
            background: transparent;
            color: var(--navy);
            border: 1px solid var(--border);
            border-radius: 6px;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            font-weight: 400;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn-secondary:hover {
            border-color: var(--navy);
            background: var(--cream);
        }

        .error-msg {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: var(--error);
            font-size: 13px;
            padding: 10px 14px;
            border-radius: 6px;
            margin-bottom: 1.25rem;
        }

        @media (max-width: 768px) {
            .page { grid-template-columns: 1fr; }
            .left { display: none; }
            .right { padding: 2rem 1.5rem; }
        }
    </style>
</head>
<body>
<div class="page">

    <!-- LEFT -->
    <div class="left">
        <div class="left-logo">
            <div class="logo-crest">U</div>
            <div class="logo-text">
                University CMS
                <span>Course Management System</span>
            </div>
        </div>

        <div class="left-hero">
            <h1>Honours <em>Computer Science</em><br>Management System</h1>
            <p>A unified platform for administrators, supervisors, and students to manage Honours modules, supervision, submissions and academic milestones.</p>
            <div class="stats-row">
                <div class="stat-item">
                    <strong>12</strong>
                    <span>Students</span>
                </div>
                <div class="stat-item">
                    <strong>6</strong>
                    <span>Supervisors</span>
                </div>
                <div class="stat-item">
                    <strong>5</strong>
                    <span>Modules</span>
                </div>
            </div>
        </div>

        <div class="left-footer">© 2026 University Course Management System</div>
    </div>

    <!-- RIGHT -->
    <div class="right">
        <div class="form-box">
            <div class="form-top">
                <h2>Welcome back</h2>
                <p>Sign in to your account to continue</p>
                <div class="divider-line"></div>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
            <div class="error-msg"><%= error %></div>
            <% } %>

            <form action="/CourseManagementSystem/auth" method="post">
                <input type="hidden" name="action" value="login">

                <div class="field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Enter your username" autocomplete="username" required>
                </div>

                <div class="field">
                    <div class="field-row">
                        <label for="password">Password</label>
                        <a href="#" class="forgot">Forgot password?</a>
                    </div>
                    <input type="password" id="password" name="password" placeholder="Enter your password" autocomplete="current-password" required>
                </div>

                <label class="remember">
                    <input type="checkbox" name="remember"> Remember me for 30 days
                </label>

                <button type="submit" class="btn-primary">Sign In</button>
            </form>

            <div class="separator">or</div>

            <a href="/CourseManagementSystem/pages/register.jsp" class="btn-secondary">Create a new account</a>
        </div>
    </div>

</div>
</body>
</html>
