<%-- views/layout/sidebar.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // ĐÃ SỬA: Lấy biến "view" từ Controller truyền sang (model.addAttribute("view", "..."))
    String currentView = (String) request.getAttribute("view");
    
    // Dự phòng trường hợp gọi qua URL trực tiếp (VD: ?view=movies)
    if (currentView == null || currentView.trim().isEmpty()) {
        currentView = request.getParameter("view"); 
    }
    
    // Mặc định là dashboard nếu không có
    if (currentView == null || currentView.trim().isEmpty()) {
        currentView = "dashboard";
    }

    String baseClass = "flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-300 group font-medium text-sm sidebar-item-hover relative ";
    String activeClass = "bg-gradient-to-r from-red-600 to-red-700 text-white shadow-lg shadow-red-900/30 sidebar-glow active-indicator";
    String inactiveClass = "text-gray-400 hover:bg-[#1a1a1a] hover:text-white";
%>

<aside id="admin-sidebar" class="w-64 bg-[#121212] border-r border-gray-800/80 fixed left-0 top-16 bottom-0 z-40 p-4 overflow-y-auto sidebar-transition">

    <%-- PHẦN ĐẦU TÊN: MENU CHÍNH CỰC ĐẸP --%>
    <div class="mb-6 text-center border-b border-gray-800 pb-4 mt-2 sidebar-category">
        <h2 class="text-white font-black tracking-widest uppercase text-lg glow-text-red">MENU CHÍNH</h2>
    </div>

    <div class="space-y-1.5">
        <%-- KHUNG 1: HỆ THỐNG --%>
        <p class="text-[10px] font-bold text-gray-500 px-4 uppercase tracking-widest mb-2 sidebar-category">Hệ thống</p>

        <a href="${pageContext.request.contextPath}/admin/dashboard" class="<%= baseClass%> <%= "dashboard".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-chart-pie w-5 text-center transition-transform duration-300 group-hover:rotate-12 group-hover:text-red-400"></i>
            <span class="sidebar-text">Dashboard</span>
        </a>

        <%-- KHUNG 2: QUẢN LÝ RẠP --%>
        <p class="text-[10px] font-bold text-gray-500 px-4 uppercase tracking-widest pt-4 mb-2 sidebar-category">Quản lý rạp</p>

        <a href="${pageContext.request.contextPath}/admin/movies" class="<%= baseClass%> <%= "movies".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-film w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý phim</span>
        </a>
        
        <a href="${pageContext.request.contextPath}/admin/rooms" class="<%= baseClass%> <%= "rooms".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-door-open w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý phòng</span>
        </a>
        
        <a href="${pageContext.request.contextPath}/admin/showtimes" class="<%= baseClass%> <%= "showtimes".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-clock w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý suất chiếu</span>
        </a>
        
        <a href="${pageContext.request.contextPath}/admin/cinemas" class="<%= baseClass%> <%= "cinemas".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-building w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý rạp</span>
        </a>

        <%-- KHUNG 3: KHÁCH HÀNG & NHÂN SỰ --%>
        <p class="text-[10px] font-bold text-gray-500 px-4 uppercase tracking-widest pt-4 mb-2 sidebar-category">Khách hàng & Nhân sự</p>
        
        <a href="${pageContext.request.contextPath}/admin/customers" class="<%= baseClass%> <%= "customers".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-users w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý khách hàng</span>
        </a>
        
        <%-- ĐÃ SỬA: Đổi link thành /staffs và logic active gom cả staffs, staff_add, staff_detail --%>
        <a href="${pageContext.request.contextPath}/admin/staffs" class="<%= baseClass%> <%= (currentView != null && currentView.startsWith("staff")) ? activeClass : inactiveClass%>">
            <i class="fas fa-user-tie w-5 text-center transition-transform duration-300 group-hover:scale-110 group-hover:text-red-400"></i>
            <span class="sidebar-text">Quản lý nhân sự</span>
        </a>

        <%-- KHUNG 4: BÁO CÁO THỐNG KÊ --%>
        <p class="text-[10px] font-bold text-gray-500 px-4 uppercase tracking-widest pt-4 mb-2 sidebar-category">Báo cáo thống kê</p>
        
        <a href="${pageContext.request.contextPath}/admin/reports" class="<%= baseClass%> <%= "reports".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-chart-line w-5 text-center transition-transform duration-300 group-hover:translate-x-1 group-hover:text-red-400"></i>
            <span class="sidebar-text">Báo cáo doanh thu</span>
        </a>
        
        <a href="${pageContext.request.contextPath}/admin/monitoring" class="<%= baseClass%> <%= "monitoring".equals(currentView) ? activeClass : inactiveClass%>">
            <i class="fas fa-satellite-dish w-5 text-center transition-transform duration-300 group-hover:translate-x-1 group-hover:text-red-400"></i>
            <span class="sidebar-text">Giám sát hoạt động</span>
        </a>
    </div>
</aside>