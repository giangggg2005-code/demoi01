<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Rạp Phim UEF - Test Dữ Liệu</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0b0f19;
            --card-bg: #1a2235;
            --primary: #e50914; /* Màu đỏ chủ đạo */
            --text-main: #ffffff;
            --text-muted: #a0aabf;
        }
        body {
            font-family: 'Roboto', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0; padding: 20px;
        }
        .header-title {
            text-align: center;
            font-size: 2.5rem;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .alert {
            max-width: 800px; margin: 0 auto 30px; padding: 15px;
            border-radius: 8px; text-align: center; font-weight: bold;
        }
        .alert-success { background: rgba(40, 167, 69, 0.2); border: 1px solid #28a745; color: #4ade80; }
        .alert-error { background: rgba(220, 53, 69, 0.2); border: 1px solid #dc3545; color: #ff6b6b; }
        
        /* Grid Phim */
        .movies-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
            max-width: 1300px;
            margin: 0 auto;
        }
        .movie-card {
            background-color: var(--card-bg);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex; flex-direction: column;
        }
        .movie-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(229, 9, 20, 0.2);
        }
        .movie-img {
            width: 100%; height: 400px; object-fit: cover;
            background-color: #333;
            border-bottom: 3px solid var(--primary);
        }
        .movie-content { padding: 20px; flex-grow: 1; display: flex; flex-direction: column; }
        .movie-title { font-size: 1.4rem; font-weight: 700; margin: 0 0 10px; color: #fff; }
        .movie-tags { margin-bottom: 15px; }
        .tag {
            display: inline-block; padding: 4px 10px; font-size: 0.8rem;
            border-radius: 20px; margin-right: 5px; font-weight: bold;
        }
        .tag-genre { background-color: #3b82f6; color: white; }
        .tag-censor { background-color: #f59e0b; color: #000; }
        .tag-duration { border: 1px solid #fff; }
        
        .movie-desc {
            font-size: 0.9rem; color: var(--text-muted); line-height: 1.5;
            margin-bottom: 15px;
        }
        .movie-details { font-size: 0.9rem; margin-bottom: 20px; color: #ccc; }
        .movie-details strong { color: #fff; }
        
        .movie-footer {
            margin-top: auto;
            display: flex; justify-content: space-between; align-items: center;
            border-top: 1px solid rgba(255,255,255,0.1); padding-top: 15px;
        }
        .movie-price { font-size: 1.2rem; font-weight: bold; color: var(--primary); }
        .status-badge {
            padding: 5px 12px; border-radius: 5px; font-size: 0.85rem; font-weight: bold;
            background: #10b981; color: white;
        }
        .status-closed { background: #6b7280; }
    </style>
</head>
<body>

    <h1 class="header-title"><span style="color: var(--primary);">UEF</span> CINEMA</h1>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">${successMessage}</div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">${errorMessage}</div>
    </c:if>

    <div class="movies-grid">
        <c:forEach var="movie" items="${movies}">
            <div class="movie-card">
                <img src="${not empty movie.posterUrl ? movie.posterUrl : 'https://via.placeholder.com/400x600/1a2235/e50914?text=UEF+Cinema'}" alt="${movie.title}" class="movie-img">
                
                <div class="movie-content">
                    <h2 class="movie-title">${movie.title}</h2>
                    
                    <div class="movie-tags">
                        <span class="tag tag-genre">${movie.genre}</span>
                        <span class="tag tag-censor">${movie.censorship}</span>
                        <span class="tag tag-duration">${movie.duration} Phút</span>
                    </div>
                    
                    <div class="movie-desc">
                        ${movie.description}
                    </div>
                    
                    <div class="movie-details">
                        <div><strong>Đạo diễn:</strong> ${movie.director}</div>
                        <div style="margin-top: 5px;"><strong>Diễn viên:</strong> ${movie.cast}</div>
                        <div style="margin-top: 5px;"><strong>Khởi chiếu:</strong> <fmt:formatDate value="${movie.releaseDate}" pattern="dd/MM/yyyy" /></div>
                    </div>
                    
                    <div class="movie-footer">
                        <div class="movie-price">
                            <fmt:formatNumber value="${movie.basePrice}" type="number" groupingUsed="true"/> VNĐ
                        </div>
                        <div class="status-badge ${movie.status == 'Closed' ? 'status-closed' : ''}">
                            ${movie.status}
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

</body>
</html>