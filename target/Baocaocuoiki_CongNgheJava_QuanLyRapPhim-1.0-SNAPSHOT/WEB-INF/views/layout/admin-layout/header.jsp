<%-- views/layout/admin-layout/header.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<header class="no-print bg-[#121212]/90 border-b border-gray-800/80 px-4 md:px-6 py-3 flex justify-between items-center fixed w-full top-0 z-50 h-16 backdrop-blur">
    
    <%-- KHỐI TRÁI: Nút đóng/mở Sidebar & Logo Thương hiệu --%>
    <div class="flex items-center space-x-4">
        <button id="sidebar-toggle" class="p-2 text-gray-400 hover:text-white hover:bg-gray-800 rounded-xl transition md:block">
            <i class="fas fa-bars text-lg"></i>
        </button>
        <div class="flex items-center space-x-2">
            <div class="bg-gradient-to-r from-red-600 to-amber-500 p-2 rounded-lg text-white shadow-md shadow-red-600/20">
                <i class="fas fa-star text-base animate-pulse"></i>
            </div>
            <span class="text-white font-black text-lg tracking-wider hidden sm:inline">STARLIGHT</span>
        </div>
    </div>
    
    <%-- KHỐI GIỮA: Kế thừa nguyên vẹn Đồng hồ thời gian thực --%>
    <div id="realtime-clock" class="hidden lg:flex items-center bg-[#0d0d0d] px-4 py-1.5 rounded-xl border border-gray-800 text-sm font-medium tracking-wide text-gray-400">
        <i class="far fa-clock text-red-500 mr-2"></i>--:--:--
    </div>
    
    <%-- KHỐI PHẢI: Các phím chức năng bổ sung & Thông tin Admin nâng cao --%>
    <div class="flex items-center space-x-2 md:space-x-3">
        
        <%-- THÊM MỚI 1: Nút xem nhanh trang chủ khách hàng (View Website) --%>
        <a href="${pageContext.request.contextPath}/" target="_blank" title="Xem trang khách hàng" 
           class="w-9 h-9 text-gray-400 hover:text-white hover:bg-gray-800 rounded-xl flex items-center justify-center transition">
            <i class="fas fa-globe text-base"></i>
        </a>

        <%-- THÊM MỚI 2: Nút Phóng to / Thu nhỏ toàn màn hình (Fullscreen) --%>
        <button id="fullscreen-toggle" title="Phóng to toàn màn hình" onclick="toggleFullscreen()"
                class="hidden sm:flex w-9 h-9 text-gray-400 hover:text-white hover:bg-gray-800 rounded-xl items-center justify-center transition">
            <i class="fas fa-expand text-base"></i>
        </button>

        <%-- KẾ THỪA: Nút Cài đặt hệ thống --%>
        <button title="Cài đặt hệ thống" class="w-9 h-9 text-gray-400 hover:text-white hover:bg-gray-800 rounded-xl flex items-center justify-center transition">
            <i class="fas fa-cog text-base"></i>
        </button>

        <%-- KẾ THỪA: Nút Chuông thông báo (Thêm hiệu ứng rung bounce tự nhiên) --%>
        <button title="Thông báo" class="relative w-9 h-9 text-gray-400 hover:text-white hover:bg-gray-800 rounded-xl flex items-center justify-center transition">
            <i class="fas fa-bell text-base"></i>
            <span class="absolute top-1 right-1 bg-red-600 text-white text-[9px] w-4 h-4 rounded-full flex items-center justify-center font-bold animate-pulse">4</span>
        </button>
        
        <%-- ĐÃ CHỈNH SỬA LẤY DỮ LIỆU ĐỘNG TỪ SESSION: Khối thông tin Admin --%>
        <div id="profile-menu-btn" class="relative flex items-center space-x-3 border-l border-gray-800 pl-3 md:pl-4 py-1 cursor-pointer">
            
            <%-- Phần văn bản hiển thị tên và quyền hạn từ Session --%>
            <div class="text-right hidden sm:block">
                <p class="text-white text-xs font-semibold leading-tight">
                    Xin chào, <c:out value="${not empty sessionScope.loggedInUser ? sessionScope.loggedInUser.fullName : 'Khách'}" />
                </p>
                <p class="text-red-500 text-[10px] font-bold mt-0.5 uppercase tracking-wider">
                    (<c:out value="${not empty sessionScope.userRole ? sessionScope.userRole : 'Chưa xác định'}" />)
                </p>
            </div>
            
            <%-- Phần Avatar tạo động từ tên đăng nhập --%>
            <div class="relative w-9 h-9 rounded-full p-[1.5px] bg-gradient-to-tr from-red-600 to-amber-500 shadow-md">
                <c:set var="avatarName" value="${not empty sessionScope.loggedInUser ? sessionScope.loggedInUser.fullName : 'Admin'}" />
                <img src="https://ui-avatars.com/api/?name=${fn:replace(avatarName, ' ', '+')}&background=121212&color=ef4444&bold=true" 
                     alt="Avatar" 
                     class="w-full h-full object-cover rounded-full bg-[#121212]">
                <span class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-[#121212] rounded-full"></span>
            </div>

            <%-- THÊM MỚI 3: Menu Thả xuống (Profile Dropdown) --%>
            <div id="profile-dropdown" class="absolute right-0 top-full mt-2 w-48 bg-[#121212] border border-gray-800 rounded-xl shadow-2xl p-1.5 opacity-0 invisible -translate-y-2 transition-all duration-300 z-50 transform origin-top-right">
                <div class="px-3 py-2 border-b border-gray-800 mb-1 sm:hidden">
                    <p class="text-white text-xs font-bold truncate"><c:out value="${sessionScope.loggedInUser.fullName}" /></p>
                    <p class="text-gray-500 text-[10px] truncate"><c:out value="${sessionScope.loggedInUser.email}" default="admin@starlight.vn" /></p>
                </div>
                
                <a href="${pageContext.request.contextPath}/admin/profile" class="flex items-center space-x-2.5 px-3 py-2 rounded-lg text-xs text-gray-400 hover:text-white hover:bg-gray-800 transition">
                    <i class="far fa-user-circle text-sm w-4 text-center"></i>
                    <span>Hồ sơ cá nhân</span>
                </a>
                
                <a href="${pageContext.request.contextPath}/admin/security" class="flex items-center space-x-2.5 px-3 py-2 rounded-lg text-xs text-gray-400 hover:text-white hover:bg-gray-800 transition">
                    <i class="fas fa-shield-alt text-sm w-4 text-center"></i>
                    <span>Đổi mật khẩu</span>
                </a>
                
                <hr class="border-gray-800 my-1">
                
                <%-- Trỏ đường link Đăng xuất về Controller --%>
                <a href="${pageContext.request.contextPath}/logout" class="flex items-center space-x-2.5 px-3 py-2 rounded-lg text-xs text-red-400 hover:text-white hover:bg-red-600 transition font-medium">
                    <i class="fas fa-sign-out-alt text-sm w-4 text-center"></i>
                    <span>Đăng xuất hệ thống</span>
                </a>
            </div>
        </div>
    </div>
</header>

<%-- Khối Script điều khiển logic Toàn màn hình nội bộ cho Topbar --%>
<script>
    function toggleFullscreen() {
        const btn = document.getElementById('fullscreen-toggle');
        const icon = btn.querySelector('i');
        
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen().then(() => {
                icon.className = 'fas fa-compress text-base';
                btn.title = 'Thoát toàn màn hình';
            }).catch(err => {
                console.error("Lỗi khi mở toàn màn hình:", err.message);
            });
        } else {
            document.exitFullscreen().then(() => {
                icon.className = 'fas fa-expand text-base';
                btn.title = 'Phóng to toàn màn hình';
            });
        }
    }
</script>