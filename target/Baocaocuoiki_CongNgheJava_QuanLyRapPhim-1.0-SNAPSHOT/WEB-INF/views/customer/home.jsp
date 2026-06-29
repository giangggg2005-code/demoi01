<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Starlight Cinema - Trải nghiệm điện ảnh đỉnh cao</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --bg-dark: #0a0a0a;
            --bg-header: #000000;
            --bg-footer: #111111;
            --primary-color: #FFB800;
            --text-main: #ffffff;
            --text-muted: #a0a0a0;
            --border-color: #333333;
            
            --card-1: #2a2008;
            --card-2: #081e2a;
            --card-3: #22082a;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            line-height: 1.5;
            overflow-x: hidden;
        }

        a {
            text-decoration: none;
            color: inherit;
            transition: 0.3s;
        }

        ul {
            list-style: none;
        }

        /* --- HEADER --- */
        header {
            background-color: var(--bg-header);
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 50px;
            border-bottom: 1px solid #1a1a1a;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo-icon {
            background-color: var(--primary-color);
            color: black;
            width: 35px;
            height: 35px;
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 18px;
        }

        .logo-text {
            display: flex;
            flex-direction: column;
        }

        .logo-text span:first-child {
            font-weight: 800;
            font-size: 18px;
            letter-spacing: 1px;
        }

        .logo-text span:last-child {
            font-size: 10px;
            color: var(--text-muted);
            letter-spacing: 2px;
        }

        nav ul {
            display: flex;
            gap: 30px;
        }

        nav a {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
        }

        nav a:hover, nav a.active {
            color: var(--primary-color);
        }

        /* --- DROPDOWN MENU --- */
        nav ul li {
            position: relative;
        }

        .dropdown-menu {
            position: absolute;
            top: 100%;
            left: 0;
            background-color: #000;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 0;
            min-width: 180px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(15px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1000;
            box-shadow: 0 10px 30px rgba(0,0,0,0.8);
        }

        .dropdown-menu a {
            padding: 10px 20px;
            display: block;
            font-size: 12px;
            text-transform: none;
            font-weight: 500;
            color: var(--text-muted) !important;
        }

        .dropdown-menu a:hover {
            background-color: #111;
            color: var(--primary-color) !important;
        }

        nav ul li:hover .dropdown-menu {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .search-btn {
            background: #1a1a1a;
            border: none;
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 8px;
            cursor: pointer;
            transition: 0.3s;
        }
        
        .search-btn:hover { background: #333; }

        .register-btn {
            background-color: transparent;
            color: var(--text-main);
            border: 1px solid var(--border-color);
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: 0.3s;
        }

        .register-btn:hover { 
            border-color: var(--primary-color);
            color: var(--primary-color);
            transform: translateY(-2px);
        }

        .login-btn {
            background-color: var(--primary-color);
            color: black;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: 0.3s;
        }
        
        .login-btn:hover { 
            opacity: 1; 
            transform: translateY(-2px);
            background: linear-gradient(135deg, var(--primary-color) 0%, #FF8A00 100%);
            box-shadow: 0 0 20px rgba(255, 184, 0, 0.6);
        }

        /* --- HERO SECTION --- */
        .hero {
            padding: 100px 50px;
            background: linear-gradient(to right, rgba(10,10,10,1) 30%, rgba(10,10,10,0.4) 60%, rgba(10,10,10,0.1) 100%), 
                        url('https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80');
            background-size: cover;
            background-position: center;
            min-height: 650px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .badges {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .badge {
            padding: 5px 12px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .badge.hot { background-color: #E50914; color: white; }
        .badge.new { background-color: var(--primary-color); color: black; }

        .hero h1 {
            font-size: 72px;
            font-weight: 900;
            line-height: 1;
            margin-bottom: 20px;
            letter-spacing: -2px;
            max-width: 800px;
            text-transform: uppercase;
        }

        .hero p {
            color: var(--text-muted);
            max-width: 550px;
            margin-bottom: 30px;
            font-size: 16px;
            line-height: 1.6;
        }

        .meta-info {
            display: flex;
            align-items: center;
            gap: 20px;
            font-size: 14px;
            color: var(--text-muted);
            margin-bottom: 40px;
        }

        .rating {
            color: var(--primary-color);
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .rating span.score {
            color: white;
        }

        .hero-buttons {
            display: flex;
            gap: 15px;
        }

        .btn {
            padding: 14px 28px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            border: none;
            transition: 0.3s;
        }

        .btn-primary { background-color: var(--primary-color); color: black; }
        .btn-primary:hover { transform: scale(1.05); }

        .btn-secondary { background-color: rgba(255,255,255,0.1); color: white; backdrop-filter: blur(10px); }
        .btn-secondary:hover { background-color: rgba(255,255,255,0.2); }

        /* --- DASHBOARD/STATS SECTION --- */
        .dashboard {
            padding: 50px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-top: -60px;
            position: relative;
            z-index: 10;
        }

        .stat-card {
            border-radius: 16px;
            padding: 25px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: 0.3s;
        }
        
        .stat-card:hover { transform: translateY(-5px); }

        .stat-card.c1 { background: linear-gradient(135deg, var(--card-1), #1a1505); border: 1px solid #4a3a10; }
        .stat-card.c2 { background: linear-gradient(135deg, var(--card-2), #05151a); border: 1px solid #103a4a; }
        .stat-card.c3 { background: linear-gradient(135deg, var(--card-3), #15051a); border: 1px solid #3a104a; }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            background: rgba(255,255,255,0.1);
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 20px;
        }
        
        .c1 .stat-icon { color: var(--primary-color); }
        .c2 .stat-icon { color: #00d1ff; }
        .c3 .stat-icon { color: #d100ff; }

        .stat-info h3 { font-size: 24px; font-weight: 800; }
        .stat-info p { font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; }

        /* --- MOVIE GRID --- */
        .section-container { padding: 40px 50px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .section-title { font-size: 24px; font-weight: 800; }
        .view-all { color: var(--primary-color); font-size: 13px; font-weight: 600; }

        .movie-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 30px;
        }

        .movie-card {
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
            position: relative;
        }

        .movie-card:hover {
            transform: translateY(-10px);
        }

        /* --- BOOKING MODAL (LOTTE STYLE) --- */
        #booking-modal {
            position: fixed;
            inset: 0;
            z-index: 200;
            background: rgba(0, 0, 0, 0.95);
            display: flex;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(10px);
            padding: 20px;
        }

        #booking-modal.hidden { display: none; }

        .booking-container {
            background: #111;
            border: 1px solid #333;
            width: 100%;
            max-width: 1100px;
            height: 90vh;
            border-radius: 30px;
            overflow: hidden;
            display: flex;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .booking-main { flex: 1; padding: 40px; overflow-y: auto; display: flex; flex-direction: column; }
        .booking-sidebar { width: 320px; background: #080808; border-l: 1px solid #222; padding: 40px; display: flex; flex-direction: column; }

        .step-progress { display: flex; gap: 20px; margin-bottom: 40px; }
        .step-item { font-size: 13px; font-weight: 700; color: #444; text-transform: uppercase; letter-spacing: 1px; }
        .step-item.active { color: var(--primary-color); }

        .booking-step-content { flex: 1; }
        .booking-step-content.hidden { display: none; }

        /* Step 1: Schedule */
        .date-list { display: flex; gap: 10px; margin-bottom: 30px; overflow-x: auto; padding-bottom: 10px; }
        .date-btn { min-width: 70px; padding: 10px; border-radius: 12px; border: 1px solid #333; background: transparent; color: white; cursor: pointer; text-align: center; }
        .date-btn.active { background: var(--primary-color); color: black; border-color: var(--primary-color); }
        .date-btn span { display: block; font-size: 10px; opacity: 0.6; }
        .date-btn strong { font-size: 18px; }

        .time-group-title { font-size: 11px; font-weight: 800; color: var(--primary-color); text-transform: uppercase; margin-bottom: 15px; display: block; }
        .time-slots { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 25px; }
        .time-slot { padding: 10px 20px; border-radius: 10px; border: 1px solid #333; color: white; font-weight: 600; cursor: pointer; transition: 0.3s; }
        .time-slot:hover, .time-slot.active { border-color: var(--primary-color); color: var(--primary-color); }

        /* Step 2: Seats */
        .screen-ui { width: 80%; h: 4px; background: linear-gradient(to right, transparent, #444, transparent); margin: 0 auto 40px; position: relative; border-radius: 4px; }
        .screen-ui::after { content: 'MÀN HÌNH'; position: absolute; top: 10px; left: 50%; transform: translateX(-50%); font-size: 10px; color: #444; letter-spacing: 5px; font-weight: 800; }
        
        .seat-grid { display: grid; gap: 8px; justify-content: center; margin-bottom: 30px; }
        .seat { width: 30px; height: 30px; border-radius: 6px; background: #222; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 9px; font-weight: 700; color: rgba(255,255,255,0.1); transition: 0.2s; }
        .seat:hover { background: #444; transform: scale(1.1); }
        .seat.selected { background: var(--primary-color) !important; color: black !important; box-shadow: 0 0 15px rgba(255, 184, 0, 0.4); }
        .seat.vip { background: #1a2a3a; border: 1px solid #2a4a6a; }
        .seat.sold { background: #333 !important; cursor: not-allowed; opacity: 0.3; }

        /* Sidebar */
        .sidebar-poster { width: 100%; aspect-ratio: 2/3; border-radius: 15px; object-fit: cover; margin-bottom: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.5); }
        .summary-item { border-bottom: 1px solid #222; padding: 15px 0; }
        .summary-label { font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 800; margin-bottom: 5px; }
        .summary-value { font-size: 14px; font-weight: 700; color: white; }
        .total-price { margin-top: auto; padding-top: 20px; }
        .total-price .amount { font-size: 28px; font-weight: 900; color: var(--primary-color); }

        .booking-nav { display: flex; justify-content: space-between; margin-top: 30px; padding-top: 20px; border-top: 1px solid #222; }
        .btn-nav { padding: 12px 30px; border-radius: 12px; font-weight: 800; text-transform: uppercase; font-size: 12px; cursor: pointer; border: none; transition: 0.3s; }
        .btn-back { background: transparent; color: #555; border: 1px solid #333; }
        .btn-back:hover { color: white; border-color: white; }
        .btn-next { background: var(--primary-color); color: black; box-shadow: 0 10px 20px rgba(255, 184, 0, 0.2); }
        .btn-next:hover { transform: translateY(-2px); box-shadow: 0 15px 30px rgba(255, 184, 0, 0.3); }

        .movie-poster {
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            aspect-ratio: 2/3;
            margin-bottom: 15px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.5);
        }

        .movie-poster img { width: 100%; height: 100%; object-fit: cover; transition: 0.5s; } /* ĐÃ ĐƯỢC SỬA TẠI ĐÂY */
        .movie-card:hover img { transform: scale(1.1); }

        /* Overlay hiệu ứng hover */
        .poster-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            opacity: 0;
            transition: 0.3s ease;
            background: rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(2px);
        }

        .movie-card:hover .poster-overlay {
            opacity: 1;
        }

        .hover-book-btn {
            padding: 12px 24px;
            background: var(--primary-color);
            color: black;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 10px;
            transform: translateY(20px);
            transition: 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        .movie-card:hover .hover-book-btn {
            transform: translateY(0);
        }

        .movie-info h4 { font-size: 16px; font-weight: 700; margin-bottom: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .movie-card:hover .movie-info h4 { color: var(--primary-color); }
        .movie-info p { font-size: 13px; color: var(--text-muted); }

        /* --- SEARCH BOX --- */
        .search-box-container {
            position: relative;
            margin-bottom: 25px;
            max-width: 450px;
        }

        .search-box-container input {
            width: 100%;
            background-color: #1a1a1a;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 12px 15px 12px 45px;
            color: white;
            outline: none;
            transition: 0.3s;
        }

        .search-box-container input:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(255, 184, 0, 0.1);
        }

        .search-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            pointer-events: none;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- GENRE FILTERS --- */
        .genre-filters {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .genre-btn {
            padding: 8px 20px;
            border-radius: 20px;
            background: #1a1a1a;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
            border: 1px solid var(--border-color);
            cursor: pointer;
            transition: 0.3s;
        }

        .genre-btn.active, .genre-btn:hover {
            background: var(--primary-color);
            color: black;
            border-color: var(--primary-color);
        }

        /* --- FOOTER --- */
        footer {
            background-color: var(--bg-footer);
            padding: 60px 50px 30px;
            border-top: 1px solid var(--border-color);
            margin-top: 50px;
        }
        
        .footer-content {
            display: flex;
            justify-content: space-between;
            margin-bottom: 50px;
            flex-wrap: wrap;
            gap: 40px;
        }
        
        .footer-logo { margin-bottom: 20px; }
        .footer-desc { color: var(--text-muted); font-size: 14px; max-width: 300px; }
        .footer-links h4 { margin-bottom: 20px; font-size: 16px; }
        .footer-links ul li { margin-bottom: 10px; color: var(--text-muted); font-size: 14px; transition: 0.3s; }
        .footer-links ul li:hover { color: white; }

        /* Social Icon Animations */
        .footer-links a i, .footer-bottom a {
            display: inline-block;
            transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), color 0.3s ease;
        }

        .footer-links a:hover i {
            transform: scale(1.3) rotate(8deg);
            color: white !important;
        }

        .footer-bottom a:hover {
            transform: translateY(-5px) scale(1.3);
            color: var(--primary-color);
        }

        .footer-bottom { border-top: 1px solid #222; padding-top: 30px; display: flex; justify-content: space-between; font-size: 12px; color: var(--text-muted); }

        /* BỔ SUNG RESPONSIVE Ở ĐÂY DÀNH CHO MOBILE */
        @media (max-width: 768px) {
            .hero h1 { font-size: 40px; }
            .hero { padding: 50px 20px; min-height: 500px; }
            .dashboard { grid-template-columns: 1fr; margin-top: 20px; padding: 20px; }
            header { padding: 15px 20px; flex-direction: column; gap: 15px; }
            nav ul { flex-wrap: wrap; justify-content: center; }
            .section-container { padding: 40px 20px; }
        }
    </style>
</head>
<body>

    <header>
        <a href="${pageContext.request.contextPath}/customer/home" class="logo">
            <div class="logo-icon"><i class="fa-solid fa-star"></i></div>
            <div class="logo-text"><span>STARLIGHT</span><span>CINEMA CLUB</span></div>
        </a>
        <nav>
            <ul>
                <li><a href="${pageContext.request.contextPath}/customer/home" class="active">Trang chủ</a></li>
                <li><a href="#">Lịch chiếu</a></li>
                <li><a href="#">Phim</a></li>
                <li><a href="#">Khuyến mãi</a></li>
            </ul>
        </nav>
        
        <div class="header-actions" style="display: flex; align-items: center; gap: 1rem;">
            <button class="search-btn"><i class="fa-solid fa-search"></i></button>
            <div class="flex items-center gap-4">
                <c:choose>
                    <c:when test="${not empty sessionScope.loggedInUser}">
                        <a href="${pageContext.request.contextPath}/customer/profile" class="flex items-center gap-2 hover:text-red-500 transition">
                            <img src="${pageContext.request.contextPath}/assets/img/${sessionScope.loggedInUser.avatar}" 
                                 alt="Avatar" class="w-10 h-10 rounded-full border-2 border-gray-500 object-cover">
                            <span class="font-bold text-white hidden md:block">${sessionScope.loggedInUser.fullName}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/logout-customer" class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm font-bold transition">
                            Đăng xuất
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login-customer" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-bold transition">
                            Đăng nhập
                        </a>
                        <a href="${pageContext.request.contextPath}/register-customer" class="px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-800 text-sm font-bold transition">
                            Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </header>

    <c:if test="${not empty heroMovie}">
    <div class="hero" style="background: linear-gradient(to right, rgba(10,10,10,1) 30%, rgba(10,10,10,0.4) 60%, rgba(10,10,10,0.1) 100%), url('${heroMovie.posterUrl}') center/cover;">
        <div class="badges">
            <span class="badge hot">${heroMovie.censorship != null ? heroMovie.censorship : 'P'}</span>
            <span class="badge new">ĐANG CHIẾU</span>
        </div>
        <h1>${heroMovie.title}</h1>
        <p>${heroMovie.description}</p>
        <div class="meta-info">
            <div><i class="fa-solid fa-clock"></i> ${heroMovie.duration} Phút</div>
            <div><i class="fa-solid fa-calendar"></i> <fmt:formatDate value="${heroMovie.releaseDate}" pattern="dd/MM/yyyy" /></div>
            <div style="border: 1px solid var(--border-color); padding: 2px 8px; border-radius: 4px; font-size: 11px;">${heroMovie.genre}</div>
            <div><i class="fa-solid fa-language"></i> ${heroMovie.language}</div>
        </div>
        <div class="hero-buttons">
            <button class="btn btn-primary" onclick="openBooking('${heroMovie.id_Movie}', '${heroMovie.title}', '${heroMovie.posterUrl}', ${heroMovie.basePrice})"><i class="fa-solid fa-ticket"></i> Đặt vé ngay</button>
            <a href="${heroMovie.trailerUrl}" target="_blank" class="btn btn-secondary"><i class="fa-solid fa-play"></i> Xem Trailer</a>
        </div>
    </div>
    </c:if>

    <div class="dashboard">
        <div class="stat-card c1">
            <div class="stat-icon"><i class="fa-solid fa-film"></i></div>
            <div class="stat-info">
                <h3>${totalMovies != null ? totalMovies : '20+'}</h3>
                <p>Phim Đang Chiếu</p>
            </div>
        </div>
        <div class="stat-card c2">
            <div class="stat-icon"><i class="fa-solid fa-video"></i></div>
            <div class="stat-info">
                <h3>${totalRooms != null ? totalRooms : '5'}</h3>
                <p>Phòng Chiếu Tiêu Chuẩn</p>
            </div>
        </div>
        <div class="stat-card c3">
            <div class="stat-icon"><i class="fa-solid fa-users"></i></div>
            <div class="stat-info">
                <h3>${totalMembers != null ? totalMembers : '10,000+'}</h3>
                <p>Khách Hàng Thành Viên</p>
            </div>
        </div>
    </div>

    <div class="section-container">
        <div class="section-header">
            <h2 class="section-title">Phim Đang Chiếu</h2>
            <a href="#" class="view-all">Xem tất cả <i class="fa-solid fa-angle-right ml-1"></i></a>
        </div>

        <div class="search-box-container">
            <i class="fa-solid fa-search search-icon"></i>
            <input type="text" placeholder="Tìm kiếm phim, thể loại...">
        </div>

        <div class="genre-filters">
            <button class="genre-btn active">Tất cả</button>
            <c:forEach var="genre" items="${genreList}">
                <button class="genre-btn">${genre}</button>
            </c:forEach>
        </div>

        <div class="movie-grid">
            <c:choose>
                <c:when test="${not empty movieList}">
                    <c:forEach var="movie" items="${movieList}">
                        <div class="movie-card" onclick="openBooking('${movie.id_Movie}', '${movie.title}', '${movie.posterUrl}', ${movie.basePrice})">
                            <div class="movie-poster">
                                <img src="${movie.posterUrl}" alt="${movie.title}" onerror="this.src='https://via.placeholder.com/300x450?text=No+Poster'">
                                <div class="poster-overlay">
                                    <div class="hover-book-btn">
                                        <i class="fa-solid fa-ticket"></i> Đặt vé ngay
                                    </div>
                                </div>
                            </div>
                            <div class="movie-info">
                                <h4>${movie.title}</h4>
                                <p>${movie.genre} | ${movie.duration} Phút</p>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p class="text-gray-500 col-span-full">Đang cập nhật danh sách phim. Vui lòng quay lại sau!</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div id="booking-modal" class="hidden">
        <div class="booking-container">
            <div class="booking-main">
                <div class="step-progress">
                    <div class="step-item active" id="step-idx-1">01. Chọn Lịch Chiếu</div>
                    <div class="step-item" id="step-idx-2">02. Chọn Ghế</div>
                    <div class="step-item" id="step-idx-3">03. Thanh Toán</div>
                </div>

                <div class="booking-step-content" id="step-1">
                    <h3 style="font-weight: 800; font-size: 18px; margin-bottom: 20px;">CHỌN NGÀY VÀ GIỜ CHIẾU</h3>
                    
                    <div class="date-list" id="dynamic-date-list">
                    </div>

                    <div>
                        <span class="time-group-title">Starlight Quận 1 - Rạp IMAX</span>
                        <div class="time-slots" id="dynamic-time-slots">
                        </div>
                    </div>
                </div>

                <div class="booking-step-content hidden" id="step-2">
                    <div class="screen-ui"></div>
                    <div class="seat-grid" id="seat-grid" style="grid-template-columns: repeat(10, 1fr);">
                        </div>
                    <div class="flex justify-center gap-6 mt-6 text-xs text-gray-400 font-bold uppercase">
                        <div class="flex items-center gap-2"><div class="w-4 h-4 bg-[#222] rounded"></div> Ghế thường</div>
                        <div class="flex items-center gap-2"><div class="w-4 h-4 bg-[#1a2a3a] border border-[#2a4a6a] rounded"></div> Ghế VIP</div>
                        <div class="flex items-center gap-2"><div class="w-4 h-4 rounded" style="background: var(--primary-color);"></div> Đang chọn</div>
                        <div class="flex items-center gap-2"><div class="w-4 h-4 bg-[#333] rounded"></div> Đã bán</div>
                    </div>
                </div>

                <div class="booking-step-content hidden" id="step-3">
                    <div style="text-align: center; margin-top: 50px;">
                        <i class="fa-solid fa-qrcode" style="font-size: 80px; color: white; margin-bottom: 20px;"></i>
                        <h3 style="font-size: 24px; font-weight: 800;">QUÉT MÃ ĐỂ THANH TOÁN</h3>
                        <p style="color: var(--text-muted); margin-top: 10px;">Mở ứng dụng ngân hàng hoặc ví điện tử để quét mã</p>
                    </div>
                </div>

            </div>

            <div class="booking-sidebar">
                <img id="modal-movie-poster" src="" alt="Poster" class="sidebar-poster">
                <h3 id="modal-movie-title" style="font-size: 20px; font-weight: 800; line-height: 1.2; margin-bottom: 20px;">Tên Phim</h3>
                
                <div class="summary-item">
                    <div class="summary-label">Rạp chiếu</div>
                    <div class="summary-value">Starlight Quận 1</div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Suất chiếu</div>
                    <div class="summary-value text-primary"><span id="summary-date">Hôm nay</span> | <span id="summary-time">--:--</span></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Ghế đã chọn</div>
                    <div class="summary-value" id="summary-seats">Chưa chọn ghế</div>
                </div>
                
                <div class="total-price">
                    <div class="summary-label">Tổng tiền</div>
                    <div class="amount" id="summary-total">0đ</div>
                </div>

                <div class="booking-nav">
                    <button class="btn-nav btn-back" id="btn-booking-prev" onclick="changeStep(-1)">Quay lại</button>
                    <form id="submit-booking-form" action="${pageContext.request.contextPath}/customer/booking/checkout" method="POST" class="m-0 p-0">
                        <input type="hidden" name="movieId" id="form-movie-id">
                        <input type="hidden" name="showTime" id="form-show-time">
                        <input type="hidden" name="selectedSeats" id="form-selected-seats">
                        <button type="button" class="btn-nav btn-next" id="btn-booking-next" onclick="changeStep(1)">Tiếp tục</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <footer>
        <div class="footer-content">
            <div class="logo footer-logo">
                <div class="logo-icon"><i class="fa-solid fa-star"></i></div>
                <div class="logo-text"><span>STARLIGHT</span></div>
            </div>
            <div class="footer-desc">Hệ thống rạp chiếu phim chất lượng cao mang đến trải nghiệm đỉnh cao cho khán giả yêu điện ảnh.</div>
            <div class="footer-links">
                <h4>Chính sách</h4>
                <ul>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách bảo mật</a></li>
                    <li><a href="#">Câu hỏi thường gặp</a></li>
                </ul>
            </div>
            <div class="footer-links">
                <h4>Kết nối</h4>
                <div style="display: flex; gap: 15px; font-size: 20px;">
                    <a href="#"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#"><i class="fa-brands fa-youtube"></i></a>
                    <a href="#"><i class="fa-brands fa-tiktok"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2024 Starlight Cinema. All rights reserved.</p>
        </div>
    </footer>

    <script>
        const contextPath = "${pageContext.request.contextPath}";
        let currentStep = 1;
        let selectedTime = null;
        let selectedSeats = [];
        let currentMovieId = null;
        let ticketPrice = 0; 

        function generateDateButtons() {
            const dateListContainer = document.getElementById('dynamic-date-list');
            dateListContainer.innerHTML = ''; 
            
            const today = new Date();
            const daysOfWeek = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

            for (let i = 0; i < 7; i++) {
                let d = new Date();
                d.setDate(today.getDate() + i);

                let dayName = i === 0 ? 'Hôm nay' : daysOfWeek[d.getDay()];
                let dateNum = d.getDate();
                
                let tzoffset = (new Date()).getTimezoneOffset() * 60000;
                let fullDateStr = (new Date(d - tzoffset)).toISOString().split('T')[0];

                let btn = document.createElement('button');
                btn.className = 'date-btn ' + (i === 0 ? 'active' : '');
               
                btn.innerHTML = '<span>' + dayName + '</span><strong>' + dateNum + '</strong>';
                
                btn.onclick = () => selectDate(btn, fullDateStr, dayName, dateNum);
                
                dateListContainer.appendChild(btn);
            }
        }

        function selectDate(element, dateStr, dayName, dateNum) {
            document.querySelectorAll('.date-btn').forEach(btn => btn.classList.remove('active'));
            element.classList.add('active');
            
            document.getElementById('summary-date').innerText = dayName + ' ' + dateNum;
            
            selectedTime = null;
            document.getElementById('summary-time').innerText = '--:--';
            document.getElementById('form-show-time').value = '';

            fetchShowtimes(currentMovieId, dateStr);
        }

        function fetchShowtimes(movieId, dateStr) {
            const timeSlotsContainer = document.getElementById('dynamic-time-slots');
            timeSlotsContainer.innerHTML = '<p style="color:var(--text-muted); font-size:14px; padding:10px 0;">Đang tải suất chiếu...</p>';

            const fetchUrl = contextPath + '/customer/api/showtimes?movieId=' + movieId + '&date=' + dateStr;

            fetch(fetchUrl)
                .then(async response => {
                    if (!response.ok) {
                        throw new Error("Lỗi Server " + response.status + ": Đường dẫn hoặc tham số không hợp lệ.");
                    }
                    
                    const contentType = response.headers.get("content-type");
                    if (contentType && contentType.indexOf("application/json") !== -1) {
                        return response.json();
                    } else {
                        throw new Error("Dữ liệu trả về không phải JSON! Rất có thể API đã bị chuyển hướng (Redirect) tới trang Login.");
                    }
                })
                .then(data => {
                    timeSlotsContainer.innerHTML = '';
                    if (data && data.length > 0) {
                        data.forEach(st => {
                            let timeStr = st.startTime;
                            let btn = document.createElement('button');
                            btn.className = 'time-slot';
                            btn.onclick = () => selectTime(btn, timeStr);
                            btn.innerHTML = '<strong>' + timeStr + '</strong>'; 
                            timeSlotsContainer.appendChild(btn);
                        });
                    } else {
                        timeSlotsContainer.innerHTML = '<p style="color: #666; font-size:14px; padding:10px 0; font-style: italic;">Không có suất chiếu trong ngày này.</p>';
                    }
                })
                .catch(err => {
                    console.error('Chi tiết lỗi:', err);
                    timeSlotsContainer.innerHTML = '<p style="color: #ff4444; font-size:14px; padding:10px 0;">' + err.message + '</p>';
                });
        }
        
        function openBooking(movieId, title, posterUrl, basePrice) {
            document.getElementById('booking-modal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
            
            ticketPrice = basePrice || 85000; 
            
            document.getElementById('modal-movie-title').innerText = title;
            document.getElementById('modal-movie-poster').src = posterUrl;
            
            currentMovieId = movieId;
            document.getElementById('form-movie-id').value = movieId; 
            
            selectedTime = null;
            selectedSeats = [];
            updateSummary();
            renderSeats(); 
            
            generateDateButtons();
            
            let tzoffset = (new Date()).getTimezoneOffset() * 60000;
            let todayStr = (new Date(Date.now() - tzoffset)).toISOString().split('T')[0];
            fetchShowtimes(movieId, todayStr);
            document.getElementById('summary-date').innerText = "Hôm nay " + new Date().getDate();
        }

        function closeBooking() {
            document.getElementById('booking-modal').classList.add('hidden');
            document.body.style.overflow = 'auto';
            currentStep = 1;
            document.querySelectorAll('.booking-step-content').forEach(el => el.classList.add('hidden'));
            document.getElementById('step-1').classList.remove('hidden');
            document.querySelectorAll('.step-item').forEach(el => el.classList.remove('active'));
            document.getElementById('step-idx-1').classList.add('active');
            
            document.getElementById('btn-booking-prev').innerText = 'Quay về trang chủ';
            document.getElementById('btn-booking-next').innerText = 'Tiếp tục';
        }

        function selectTime(element, time) {
            document.querySelectorAll('.time-slot').forEach(btn => btn.classList.remove('active'));
            element.classList.add('active');
            selectedTime = time;
            document.getElementById('summary-time').innerText = time;
            document.getElementById('form-show-time').value = time; 
        }

        function renderSeats() {
            const grid = document.getElementById('seat-grid');
            grid.innerHTML = '';
            const rows = ['A','B','C','D','E','F','G','H']; 
            for(let r = 0; r < rows.length; r++) {
                for(let c = 1; c <= 10; c++) {
                    const seatId = rows[r] + c; 
                    const isVip = (r >= 3 && r <= 5 && c >= 3 && c <= 8);
                    
                    const isSold = Math.random() > 0.85; 
                    
                    const div = document.createElement('div');
                    div.className = `seat ${isVip ? 'vip' : ''} ${isSold ? 'sold' : ''}`;
                    div.innerText = seatId;
                    
                    if(!isSold) {
                        div.onclick = () => toggleSeat(div, seatId);
                    }
                    grid.appendChild(div);
                }
            }
        }

        function toggleSeat(element, seatId) {
            if(element.classList.contains('selected')) {
                element.classList.remove('selected');
                selectedSeats = selectedSeats.filter(id => id !== seatId);
            } else {
                if(selectedSeats.length >= 8) {
                    alert('Bạn chỉ được chọn tối đa 8 ghế!');
                    return;
                }
                element.classList.add('selected');
                selectedSeats.push(seatId);
            }
            document.getElementById('form-selected-seats').value = selectedSeats.join(','); 
            updateSummary();
        }

        function updateSummary() {
            document.getElementById('summary-seats').innerText = selectedSeats.length > 0 ? selectedSeats.join(', ') : 'Chưa chọn ghế';
            const total = selectedSeats.length * ticketPrice;
            document.getElementById('summary-total').innerText = new Intl.NumberFormat('vi-VN').format(total) + 'đ';
        }

        function changeStep(n) {
            if (n === -1 && currentStep === 1) {
                closeBooking();
                return;
            }

            if (n === 1) { 
                if (currentStep === 1 && !selectedTime) {
                    alert('Vui lòng chọn suất chiếu để tiếp tục!');
                    return;
                }
                if (currentStep === 2 && selectedSeats.length === 0) {
                    alert('Vui lòng chọn ít nhất một chỗ ngồi!');
                    return;
                }
                if (currentStep === 3) {
                    let checkLogin = "${sessionScope.loggedInUser != null ? 'true' : 'false'}";
                    if(checkLogin === 'false') {
                        alert("Vui lòng đăng nhập để tiến hành thanh toán!");
                        window.location.href = contextPath + "/login-customer";
                        return;
                    }
                    document.getElementById('submit-booking-form').submit();
                    return;
                }
            }

            const newStep = currentStep + n;
            if(newStep < 1 || newStep > 3) return;
            
            document.getElementById('step-' + currentStep).classList.add('hidden');
            document.getElementById('step-idx-' + currentStep).classList.remove('active');
            currentStep = newStep;
            document.getElementById('step-' + currentStep).classList.remove('hidden');
            document.getElementById('step-idx-' + currentStep).classList.add('active');

            document.getElementById('btn-booking-prev').innerText = currentStep === 1 ? 'Quay về trang chủ' : 'Quay lại';
            document.getElementById('btn-booking-next').innerText = currentStep === 3 ? 'Xác nhận đặt vé' : 'Tiếp tục';
        }
    </script>
</body>