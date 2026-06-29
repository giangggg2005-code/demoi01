<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Starlight Cinema - Hồ sơ cá nhân</title>
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

        .logo { display: flex; align-items: center; gap: 10px; }
        .logo-icon { background-color: var(--primary-color); color: black; width: 35px; height: 35px; border-radius: 8px; display: flex; justify-content: center; align-items: center; font-size: 18px; }
        .logo-text { display: flex; flex-direction: column; }
        .logo-text span:first-child { font-weight: 800; font-size: 18px; letter-spacing: 1px; }
        .logo-text span:last-child { font-size: 10px; color: var(--text-muted); letter-spacing: 2px; }

        nav ul { display: flex; gap: 30px; }
        nav a { font-size: 13px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; }
        nav a:hover, nav a.active { color: var(--primary-color); }

        .logout-btn {
            background-color: transparent;
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: 0.3s;
        }
        .logout-btn:hover { color: #ff4444; border-color: #ff4444; }

        /* --- PROFILE CONTENT --- */
        .profile-container {
            padding: 50px;
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 40px;
        }

        .profile-sidebar {
            background: #111;
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 40px;
            text-align: center;
            height: fit-content;
        }

        .avatar-wrapper {
            position: relative;
            width: 120px;
            height: 120px;
            margin: 0 auto 25px;
        }
        .avatar-wrapper img { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; border: 4px solid var(--primary-color); }
        
        .user-name { font-size: 22px; font-weight: 800; margin-bottom: 5px; }
        .user-email { font-size: 14px; color: var(--text-muted); margin-bottom: 30px; }

        .loyalty-card {
            background: linear-gradient(135deg, #222, #000);
            border: 1px solid #444;
            border-radius: 16px;
            padding: 20px;
            text-align: left;
            margin-bottom: 30px;
        }
        .loyalty-label { font-size: 10px; text-transform: uppercase; font-weight: 800; color: var(--primary-color); letter-spacing: 1px; margin-bottom: 10px; display: block; }
        .loyalty-points { font-size: 28px; font-weight: 900; }
        .loyalty-level { font-size: 12px; color: var(--text-muted); margin-top: 5px; display: flex; align-items: center; gap: 8px; }

        .sidebar-menu ul { display: flex; flex-direction: column; gap: 5px; text-align: left; }
        .sidebar-menu li a { display: flex; align-items: center; gap: 12px; padding: 12px 15px; border-radius: 12px; font-size: 14px; font-weight: 600; color: var(--text-muted); }
        .sidebar-menu li a:hover, .sidebar-menu li a.active { background: #1a1a1a; color: var(--primary-color); }

        /* --- MAIN SECTION --- */
        .profile-main { }
        .main-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .main-title { font-size: 24px; font-weight: 800; }

        .history-list { display: flex; flex-direction: column; gap: 15px; }
        .booking-card {
            background: #111;
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 20px;
            display: grid;
            grid-template-columns: 80px 1fr auto;
            gap: 25px;
            align-items: center;
            transition: 0.3s;
        }
        .booking-card:hover { border-color: var(--primary-color); transform: translateX(5px); }
        
        .movie-poster-small { width: 80px; height: 120px; border-radius: 10px; object-fit: cover; }
        
        .booking-details h4 { font-size: 18px; font-weight: 800; margin-bottom: 10px; }
        .meta-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 20px; font-size: 13px; color: var(--text-muted); }
        .meta-item { display: flex; align-items: center; gap: 8px; }
        .meta-item i { color: var(--primary-color); width: 14px; }

        .booking-status-box { text-align: right; display: flex; flex-direction: column; justify-content: space-between; height: 100%; }
        .status-badge { padding: 6px 14px; border-radius: 30px; font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; }
        .status-success { background: rgba(0, 200, 100, 0.1); color: #00c864; border: 1px solid rgba(0, 200, 100, 0.2); }
        .status-expired { background: rgba(255, 255, 255, 0.05); color: #666; border: 1px solid rgba(255, 255, 255, 0.1); }
        .price-tag { font-size: 20px; font-weight: 900; color: var(--primary-color); margin-top: 15px; }

        /* --- FOOTER --- */
        footer { background-color: var(--bg-footer); padding: 60px 50px 30px; border-top: 1px solid var(--border-color); margin-top: 80px; }
        .footer-content { display: flex; justify-content: space-between; margin-bottom: 50px; flex-wrap: wrap; gap: 40px; }
        .footer-bottom { border-top: 1px solid #222; padding-top: 30px; display: flex; justify-content: space-between; font-size: 12px; color: var(--text-muted); }
    </style>
</head>
<body>

    <header>
        <a href="${pageContext.request.contextPath}/customer/home" class="logo" style="text-decoration: none;">
            <div class="logo-icon"><i class="fa-solid fa-star"></i></div>
            <div class="logo-text"><span>STARLIGHT</span><span>CINEMA CLUB</span></div>
        </a>
        <nav>
            <ul>
                <li><a href="${pageContext.request.contextPath}/customer/home">Trang chủ</a></li>
                <li><a href="#">Lịch chiếu</a></li>
                <li><a href="#">Phim</a></li>
            </ul>
        </nav>
        <div class="header-actions">
            <button class="logout-btn" onclick="location.href='${pageContext.request.contextPath}/logout-customer'">ĐĂNG XUẤT</button>
        </div>
    </header>

    <div class="profile-container">
        <aside class="profile-sidebar">
            <div class="avatar-wrapper">
                <img src="${pageContext.request.contextPath}/assets/images/brand/logo/logo-icon.svg" alt="Avatar"
                     onerror="this.src='https://i.pravatar.cc/150?u=${customer.username}'">
            </div>
            <h3 class="user-name"><c:out value="${customer.fullName}" /></h3>
            <p class="user-email"><c:out value="${customer.email}" /></p>

            <div class="loyalty-card">
                <span class="loyalty-label">STARLIGHT REWARDS</span>
                <div class="loyalty-points">
                    <fmt:formatNumber value="${customer.totalSpent / 1000}" maxFractionDigits="0" />
                    <small style="font-size: 12px; font-weight: 400; color: #888;">PTS</small>
                </div>
                <div class="loyalty-level">
                    <i class="fa-solid fa-crown"></i>
                    <c:choose>
                        <c:when test="${customer.totalBookings >= 10}">THÀNH VIÊN VÀNG</c:when>
                        <c:when test="${customer.totalBookings >= 3}">THÀNH VIÊN BẠC</c:when>
                        <c:otherwise>THÀNH VIÊN MỚI</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="sidebar-menu">
                <ul>
                    <li><a href="#" class="active"><i class="fa-solid fa-ticket"></i> Lịch sử đặt vé</a></li>
                    <li><a href="#"><i class="fa-solid fa-gift"></i> Ưu đãi của tôi</a></li>
                    <li><a href="#"><i class="fa-solid fa-user-pen"></i> Chỉnh sửa hồ sơ</a></li>
                    <li><a href="#"><i class="fa-solid fa-lock"></i> Đổi mật khẩu</a></li>
                </ul>
            </div>
        </aside>

        <main class="profile-main">
            <div class="main-header">
                <h2 class="main-title">Lịch sử đặt vé</h2>
            </div>

            <div class="history-list">
                <c:choose>
                    <c:when test="${empty bookingList}">
                        <div class="booking-card" style="grid-template-columns: 1fr; text-align: center; padding: 40px;">
                            <p style="color: var(--text-muted);">Bạn chưa có lịch sử đặt vé nào.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="booking" items="${bookingList}">
                            <div class="booking-card" style="${booking.status == 'Completed' ? '' : 'opacity: 0.85;'}">
                                <img src="${pageContext.request.contextPath}/assets/images/brand/logo/logo-icon.svg" alt="Poster" class="movie-poster-small">
                                <div class="booking-details">
                                    <h4>Đơn đặt vé #${booking.id_Booking}</h4>
                                    <div class="meta-grid">
                                        <div class="meta-item">
                                            <i class="fa-solid fa-calendar"></i>
                                            <fmt:formatDate value="${booking.bookingDate}" pattern="dd/MM/yyyy" />
                                        </div>
                                        <div class="meta-item">
                                            <i class="fa-solid fa-clock"></i>
                                            <fmt:formatDate value="${booking.bookingDate}" pattern="HH:mm" />
                                        </div>
                                        <div class="meta-item">
                                            <i class="fa-solid fa-credit-card"></i>
                                            <c:out value="${booking.paymentMethod}" />
                                        </div>
                                        <div class="meta-item">
                                            <i class="fa-solid fa-receipt"></i>
                                            Mã thanh toán: <c:out value="${booking.paymentId != null ? booking.paymentId : 'N/A'}" />
                                        </div>
                                    </div>
                                </div>
                                <div class="booking-status-box">
                                    <span class="status-badge ${booking.status == 'Completed' ? 'status-success' : 'status-expired'}">
                                        <c:out value="${booking.status}" />
                                    </span>
                                    <div class="price-tag">
                                        <fmt:formatNumber value="${booking.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0" />đ
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <footer>
        <div class="footer-content">
            <div class="logo footer-logo">
                <div class="logo-icon"><i class="fa-solid fa-star"></i></div>
                <div class="logo-text"><span>STARLIGHT</span></div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2024 Starlight Cinema. All rights reserved.</p>
            </div>
        </div>
    </footer>

</body>
</html>