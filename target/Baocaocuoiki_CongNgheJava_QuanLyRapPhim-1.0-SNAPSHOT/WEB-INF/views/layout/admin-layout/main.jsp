<%-- views/layout/admin-layout/main.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // LẤY BIẾN "view" TỪ CONTROLLER TRUYỀN SANG (Giúp sidebar đỏ đúng chỗ)
    String view = (String) request.getAttribute("view");

    // Nếu không có, dự phòng lấy từ thanh URL cho các tính năng cũ
    if (view == null || view.trim().isEmpty()) {
        view = request.getParameter("view");
    }

    // Mặc định luôn là dashboard
    if (view == null || view.trim().isEmpty()) {
        view = "dashboard";
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Starlight Admin - Hệ thống quản lý rạp phim</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    </head>
    <body class="text-gray-300 font-sans flex flex-col min-h-screen bg-[#0b0c10]">

        <jsp:include page="header.jsp" />

        <div class="flex flex-1 pt-16 relative">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="currentView" value="<%= view%>" />
            </jsp:include>

            <div id="main-container-wrapper" class="flex-1 p-4 md:p-6 flex flex-col justify-between min-h-[calc(100vh-4rem)] sidebar-transition w-full overflow-hidden">
                <main class="flex-1 pb-6 w-full">
                    <%-- DÙNG BIẾN BODY TỪ CONTROLLER ĐỂ NHÚNG ĐỘNG FILE (Ngăn chặn Crash) --%>
                    <c:choose>
                        <c:when test="${not empty body}">
                            <jsp:include page="${body}" />
                        </c:when>
                        <c:otherwise>
                            <% if ("dashboard".equals(view)) { %>
                            <jsp:include page="dashboard.jsp" />
                            <% } else if ("movies".equals(view)) { %>
                            <jsp:include page="movies.jsp" /> <% } else {%>
                            <div class="p-8 text-center glass-card border border-gray-800 rounded-2xl">
                                <h2 class="text-xl font-bold text-white mb-2">Phân hệ: <%= view.toUpperCase()%></h2>
                                <p class="text-gray-500 text-sm">Giao diện tính năng đang được phát triển.</p>
                            </div>
                            <% }%>
                        </c:otherwise>
                    </c:choose>
                </main>

                <%-- Giờ thì Footer sẽ luôn hiện --%>
                <jsp:include page="footer.jsp" />
            </div>
        </div>

        <%-- JavaScript chạy đồng hồ mượt mà --%>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    </body>
</html>