<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    .line-clamp-1 { display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
    .premium-glow { box-shadow: 0 0 15px rgba(59, 130, 246, 0.2); transition: all 0.3s ease-in-out; }
    .premium-glow:hover { box-shadow: 0 0 25px rgba(59, 130, 246, 0.5); transform: translateY(-2px); }
    .input-group { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
    .input-group:focus-within { transform: translateY(-3px); box-shadow: 0 10px 25px -5px rgba(59, 130, 246, 0.15); }
    .glass-card { background: rgba(22, 22, 22, 0.85); backdrop-filter: blur(16px); border: 1px solid rgba(255, 255, 255, 0.05); }
    
    /* ========================================================= */
    /* HIỆU ỨNG VÒNG LIGHT-RING NEON PHÂN CẤP CHỨC VỤ CHO STAFFS */
    /* ========================================================= */
    .avatar-ring-admin {
        box-shadow: 0 0 0 2px rgba(22, 22, 22, 1), 0 0 0 4px rgba(239, 68, 68, 0.6), 0 0 12px rgba(239, 68, 68, 0.4);
    }
    .avatar-ring-manager {
        box-shadow: 0 0 0 2px rgba(22, 22, 22, 1), 0 0 0 4px rgba(168, 85, 247, 0.6), 0 0 12px rgba(168, 85, 247, 0.4);
    }
    .avatar-ring-seller {
        box-shadow: 0 0 0 2px rgba(22, 22, 22, 1), 0 0 0 4px rgba(59, 130, 246, 0.6), 0 0 12px rgba(59, 130, 246, 0.4);
    }
    .avatar-ring-default {
        box-shadow: 0 0 0 2px rgba(22, 22, 22, 1), 0 0 0 4px rgba(107, 114, 128, 0.4);
    }
</style>
<style>
    .line-clamp-1 {
        display: -webkit-box;
        -webkit-line-clamp: 1;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .premium-glow {
        box-shadow: 0 0 15px rgba(239, 68, 68, 0.2);
        transition: all 0.3s ease-in-out;
    }
    .premium-glow:hover {
        box-shadow: 0 0 25px rgba(239, 68, 68, 0.5);
        transform: translateY(-2px);
    }

    .input-group {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .input-group:focus-within {
        transform: translateY(-3px);
        box-shadow: 0 10px 25px -5px rgba(239, 68, 68, 0.25);
    }
    .input-group:focus-within i.fa-icon {
        color: #ef4444 !important;
    }

    input[type="date"]::-webkit-calendar-picker-indicator {
        opacity: 0;
        position: absolute;
        right: 0;
        top: 0;
        width: 100%;
        height: 100%;
        cursor: pointer;
    }

    /* ĐỔI HIỆU ỨNG FOCUS CHO DÒNG NHÂN VIÊN */
    .staff-row {
        transition: background-color 0.4s ease;
        position: relative;
        z-index: 1;
    }
    .staff-row td {
        position: relative;
        transition: all 0.4s ease;
    }
    .staff-row:hover {
        background-color: #161616 !important;
        z-index: 50;
    }

    /* Đã sửa đổi CSS: Hỗ trợ phóng to trực tiếp text hoặc đối tượng con khi hover */
    .staff-row .inner-content {
        transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        transform-origin: left center;
        display: block;
    }
    .staff-row:hover .inner-content {
        transform: scale(1.03); /* Chỉnh lại 1.03 để không bị tràn vỡ khung chữ */
    }
    .staff-row td.text-center .inner-content {
        transform-origin: center center;
    }
    .staff-row:hover td {
        box-shadow: 0 10px 30px -10px rgba(239, 68, 68, 0.3);
    }

    /* ĐƯỜNG CHẠY GRADIENT HOVER TRÊN TỪNG THÀNH PHẦN TABLE */
    .staff-row td::before, .staff-row td::after {
        content: '';
        position: absolute;
        left: 0;
        right: 0;
        height: 2px;
        background: linear-gradient(90deg, transparent, #ef4444, #ff8a8a, #ef4444, transparent);
        background-size: 200% 100%;
        opacity: 0;
        transition: opacity 0.4s ease;
        pointer-events: none;
        z-index: 20;
    }
    .staff-row td::before {
        top: 0;
        animation: borderRunRight 1.5s linear infinite;
    }
    .staff-row td::after {
        bottom: 0;
        animation: borderRunLeft 1.5s linear infinite;
    }
    .staff-row:hover td::before, .staff-row:hover td::after {
        opacity: 1;
    }

    @keyframes borderRunRight {
        0% { background-position: 200% 0; }
        100% { background-position: -200% 0; }
    }
    @keyframes borderRunLeft {
        0% { background-position: -200% 0; }
        100% { background-position: 200% 0; }
    }
    @keyframes toastFlyIn {
        0% { transform: translateX(130%) scale(0.9); opacity: 0; filter: blur(5px); }
        60% { transform: translateX(-15px) scale(1.02); filter: blur(0); }
        80% { transform: translateX(5px) scale(0.99); }
        100% { transform: translateX(0) scale(1); opacity: 1; filter: blur(0); }
    }
    @keyframes toastFadeZoomOut {
        0% { transform: translate(0) scale(1); opacity: 1; filter: blur(0); }
        40% { transform: translateX(10px) scale(1.01); opacity: 0.8; }
        100% { transform: translateX(60px) scale(0.85); opacity: 0; filter: blur(6px); }
    }
    @keyframes toastTimeline {
        0% { width: 100%; }
        100% { width: 0%; }
    }
    @keyframes glowPulseRed {
        0%, 100% { border-color: rgba(239, 68, 68, 0.35); box-shadow: 0 10px 30px -5px rgba(239, 68, 68, 0.15), 0 0 15px rgba(239, 68, 68, 0.05); }
        50% { border-color: rgba(239, 68, 68, 0.8); box-shadow: 0 15px 35px -2px rgba(239, 68, 68, 0.35), 0 0 25px rgba(239, 68, 68, 0.15); }
    }
    
    @keyframes glowPulseGreen {
        0%, 100% { border-color: rgba(34, 197, 94, 0.45); box-shadow: 0 10px 30px -5px rgba(34, 197, 94, 0.2), 0 0 15px rgba(34, 197, 94, 0.08); }
        50% { border-color: rgba(74, 222, 128, 0.95); box-shadow: 0 15px 35px -2px rgba(34, 197, 94, 0.45), 0 0 28px rgba(74, 222, 128, 0.22); }
    }
    @keyframes subtleBounce {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-3px); }
    }

    .toast-item {
        animation: toastFlyIn 0.55s cubic-bezier(0.25, 1, 0.5, 1) forwards;
        will-change: transform, opacity;
    }
    .toast-item.toast-leave-active {
        animation: toastFadeZoomOut 0.45s cubic-bezier(0.25, 1, 0.5, 1) forwards !important;
    }
    .toast-error-glow { animation: glowPulseRed 3s infinite ease-in-out; }
    .toast-success-glow { animation: glowPulseGreen 3s infinite ease-in-out; }
    .toast-progress-countdown { animation: toastTimeline 5s linear forwards; }
    .animate-subtle-bounce { animation: subtleBounce 2.5s ease-in-out infinite; }
    
    @keyframes modalIn {
        from { opacity: 0; transform: scale(0.9) translateY(-20px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .animate-modal-in { animation: modalIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; }
    .custom-checkbox { accent-color: #dc2626; width: 1.1rem; height: 1.1rem; cursor: pointer; }
    .bg-grid-pattern {
        background-image: linear-gradient(to right, rgba(255,255,255,0.02) 1px, transparent 1px), linear-gradient(to bottom, rgba(255,255,255,0.02) 1px, transparent 1px);
        background-size: 24px 24px;
    }
    .custom-scrollbar::-webkit-scrollbar { height: 8px; width: 8px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: rgba(0, 0, 0, 0.2); border-radius: 8px; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 8px; transition: all 0.3s; }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(239, 68, 68, 0.6); }
    .avatar-ring { padding: 2px; background: linear-gradient(45deg, #ef4444, #f59e0b, #ec4899); border-radius: 50%; }
</style>

<%-- KHAY CHỨA TOAST LƠ LỬNG TRÊN ĐẦU TRANG --%>
<div id="premium-toast-container" class="fixed top-6 right-6 z-[9999] flex flex-col gap-4 w-full max-w-sm pointer-events-none"></div>

<%-- CẦU NỐI DỮ LIỆU TỪ BACKEND CONTROLLER: nhận errorMessage/successMessage từ StaffController --%>
<input type="hidden" id="backend-error-bridge" value="<c:out value='${errorMessage}'/>">
<input type="hidden" id="backend-success-bridge" value="<c:out value='${successMessage}'/>">
<div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
    <div>
        <h2 class="text-2xl font-bold text-white flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center text-blue-500 premium-glow">
                <i class="fas fa-user-tie"></i>
            </div>
            Quản Lý Nhân Sự
        </h2>
        <p class="text-gray-400 text-sm mt-1">Hệ thống quản trị tài khoản Admin, Manager và Ticket Seller</p>
    </div>
    
    <div class="flex items-center gap-3 w-full md:w-auto">
        <button type="button" onclick="toggleFilter()" class="flex-1 md:flex-none px-4 py-2.5 bg-[#1a1c23] hover:bg-[#252830] text-gray-300 rounded-xl border border-gray-700 transition duration-300 flex items-center justify-center gap-2 group">
            <i class="fas fa-filter text-gray-400 group-hover:text-blue-400 transition-colors"></i>
            <span class="font-medium text-sm">Bộ Lọc</span>
        </button>
        <a href="${pageContext.request.contextPath}/admin/staffs/add" class="flex-1 md:flex-none px-4 py-2.5 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white rounded-xl shadow-[0_0_15px_rgba(59,130,246,0.3)] transition duration-300 flex items-center justify-center gap-2 font-medium text-sm premium-glow">
            <i class="fas fa-plus"></i> Thêm Nhân Sự
        </a>
    </div>
</div>

<div id="filterPanel" class="glass-card rounded-2xl mb-6 overflow-hidden transition-all duration-500 ${isFiltering ? 'max-h-[1000px] opacity-100 p-6' : 'max-h-0 opacity-0 p-0'}">
    <form action="${pageContext.request.contextPath}/admin/staffs" method="GET" id="filterForm" onsubmit="return validateFilter()">
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Họ & Tên</label>
                <div class="relative">
                    <i class="fas fa-font absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <input type="text" name="nameKeyword" id="filterName" value="${nameKeyword}" placeholder="Ví dụ: Nguyễn Văn A" class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-all placeholder-gray-600">
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Liên Hệ / Username</label>
                <div class="relative">
                    <i class="fas fa-address-book absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <input type="text" name="contactKeyword" id="filterContact" value="${contactKeyword}" placeholder="SĐT, Email, User..." class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-all placeholder-gray-600">
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Chức Vụ</label>
                <div class="relative">
                    <i class="fas fa-id-badge absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <select name="roleFilter" class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none appearance-none transition-all">
                        <option value="0">Tất cả chức vụ</option>
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.id_Role}" ${roleFilter == role.id_Role ? 'selected' : ''}>${role.roleName}</option>
                        </c:forEach>
                    </select>
                    <i class="fas fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-xs pointer-events-none"></i>
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Trạng Thái (User)</label>
                <div class="relative">
                    <i class="fas fa-shield-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <select name="statusFilter" class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none appearance-none transition-all">
                        <option value="ALL" ${statusFilter == 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Active" ${statusFilter == 'Active' ? 'selected' : ''}>Hoạt động</option>
                        <option value="Locked" ${statusFilter == 'Locked' ? 'selected' : ''}>Đã khóa</option>
                    </select>
                    <i class="fas fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-xs pointer-events-none"></i>
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Từ Ngày</label>
                <div class="relative">
                    <i class="fas fa-calendar-plus absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <input type="date" name="startDate" id="filterStart" value="${startDate}" class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-all" style="color-scheme: dark;">
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Đến Ngày</label>
                <div class="relative">
                    <i class="fas fa-calendar-check absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    <input type="date" name="endDate" id="filterEnd" value="${endDate}" class="w-full bg-[#0d0d0d] border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-2.5 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-all" style="color-scheme: dark;">
                </div>
            </div>

            <div class="input-group md:col-span-2 border-l border-gray-800 pl-4">
                <label class="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Áp Dụng Cho Mốc Thời Gian (Chọn nhiều)</label>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3 pt-1">
                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="userCreatedAt" class="peer hidden" ${empty dateFilterType || dateFilterType.contains('userCreatedAt') ? 'checked' : ''}>
                        <div class="w-4 h-4 rounded border border-gray-600 flex items-center justify-center bg-[#0d0d0d] peer-checked:bg-blue-600 peer-checked:border-blue-500 transition-colors">
                            <i class="fas fa-check text-white text-[10px] opacity-0 peer-checked:opacity-100"></i>
                        </div>
                        <span class="text-sm text-gray-400 group-hover:text-white transition-colors">Ngày tạo tài khoản</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="userUpdatedAt" class="peer hidden" ${not empty dateFilterType && dateFilterType.contains('userUpdatedAt') ? 'checked' : ''}>
                        <div class="w-4 h-4 rounded border border-gray-600 flex items-center justify-center bg-[#0d0d0d] peer-checked:bg-blue-600 peer-checked:border-blue-500 transition-colors">
                            <i class="fas fa-check text-white text-[10px] opacity-0 peer-checked:opacity-100"></i>
                        </div>
                        <span class="text-sm text-gray-400 group-hover:text-white transition-colors">Ngày cập nhật hồ sơ cá nhân</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="roleCreatedAt" class="peer hidden" ${not empty dateFilterType && dateFilterType.contains('roleCreatedAt') ? 'checked' : ''}>
                        <div class="w-4 h-4 rounded border border-gray-600 flex items-center justify-center bg-[#0d0d0d] peer-checked:bg-blue-600 peer-checked:border-blue-500 transition-colors">
                            <i class="fas fa-check text-white text-[10px] opacity-0 peer-checked:opacity-100"></i>
                        </div>
                        <span class="text-sm text-gray-400 group-hover:text-white transition-colors">Ngày cấp phân quyền hiện tại</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="roleUpdatedAt" class="peer hidden" ${not empty dateFilterType && dateFilterType.contains('roleUpdatedAt') ? 'checked' : ''}>
                        <div class="w-4 h-4 rounded border border-gray-600 flex items-center justify-center bg-[#0d0d0d] peer-checked:bg-blue-600 peer-checked:border-blue-500 transition-colors">
                            <i class="fas fa-check text-white text-[10px] opacity-0 peer-checked:opacity-100"></i>
                        </div>
                        <span class="text-sm text-gray-400 group-hover:text-white transition-colors">Ngày cập nhật trạng thái phân quyền</span>
                    </label>
                </div>
            </div>
        </div>

        <div class="flex justify-end gap-3 mt-6 pt-5 border-t border-gray-800">
            <a href="${pageContext.request.contextPath}/admin/staffs" class="px-5 py-2 rounded-xl border border-gray-700 text-gray-400 hover:text-white hover:bg-gray-800 transition duration-300 text-sm font-medium">Xóa Lọc</a>
            <button type="submit" class="px-6 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white shadow-[0_0_10px_rgba(59,130,246,0.3)] transition duration-300 text-sm font-medium flex items-center gap-2">
                <i class="fas fa-search"></i> Áp Dụng Lọc
            </button>
        </div>
    </form>
</div>

<div class="glass-card rounded-2xl overflow-hidden">
    <div class="overflow-x-auto custom-scrollbar">
        <table class="w-full text-left text-sm text-gray-400 whitespace-nowrap">
            <thead class="text-xs text-gray-300 uppercase bg-[#0b0c10] border-b border-gray-800">
                <tr>
                    <th class="px-5 py-4 font-semibold text-center w-16">#ID</th>
                    <th class="px-5 py-4 font-semibold w-72">Nhân sự</th>
                    <th class="px-5 py-4 font-semibold">Username / Phân quyền</th>
                    <th class="px-5 py-4 font-semibold">Thông tin liên hệ</th>
                    <th class="px-5 py-4 font-semibold text-center">Trạng thái (User)</th>
                    <th class="px-5 py-4 font-semibold text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-800/50">
                <c:choose>
                    <c:when test="${empty staffs}">
                        <tr>
                            <td colspan="6" class="px-5 py-12 text-center">
                                <div class="inline-flex flex-col items-center justify-center text-gray-500">
                                    <i class="fas fa-user-slash text-4xl mb-3 opacity-50"></i>
                                    <p class="text-base">Không tìm thấy nhân sự nào!</p>
                                    <p class="text-xs mt-1">Thử thay đổi điều kiện lọc hoặc từ khóa tìm kiếm.</p>
                                </div>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="s" items="${staffs}">
                            <tr class="hover:bg-blue-600/5 transition duration-200 group">
                                <td class="px-5 py-4 text-center font-mono text-gray-500 text-xs">#${s.user.id_User}</td>
                                <td class="px-5 py-4">
                                    <div class="flex items-center gap-4 w-64">
                                        
                                        <%-- THIẾT LẬP THỨ TỰ ƯU TIÊN MÀU VÒNG CHO TRƯỜNG HỢP NHÂN VIÊN CÓ NHIỀU QUYỀN GỘP CHUỖI --%>
                                        <c:set var="ringClass" value="avatar-ring-default" />
                                        <c:choose>
                                            <c:when test="${fn:contains(s.quyen.roleName, 'ADMIN')}">
                                                <c:set var="ringClass" value="avatar-ring-admin" />
                                            </c:when>
                                            <c:when test="${fn:contains(s.quyen.roleName, 'MANAGER')}">
                                                <c:set var="ringClass" value="avatar-ring-manager" />
                                            </c:when>
                                            <c:when test="${fn:contains(s.quyen.roleName, 'SELLER') || fn:contains(s.quyen.roleName, 'VÉ')}">
                                                <c:set var="ringClass" value="avatar-ring-seller" />
                                            </c:when>
                                        </c:choose>

                                        <%-- KHỐI CHỨA AVATAR HOÀN TOÀN TRÙNG KHỚP HIỆU ỨNG VÀ 3 TRƯỜNG HỢP LOGIC CỦA BẠN --%>
                                        <div class="shrink-0 shadow-lg transform group-hover:scale-110 group-hover:rotate-3 transition-all duration-500 relative my-1">
                                            <c:choose>
                                                <%-- 1. Nếu avatar có dữ liệu (Link mạng HOẶC Tên file) --%>
                                                <c:when test="${not empty s.user.avatar && s.user.avatar != 'null' && fn:trim(s.user.avatar) != ''}">
                                                    <c:choose>
                                                        <%-- TH 1A: Nếu là link từ Internet (bắt đầu bằng http) --%>
                                                        <c:when test="${fn:startsWith(fn:trim(s.user.avatar), 'http')}">
                                                            <img src="${fn:trim(s.user.avatar)}" 
                                                                 class="w-10 h-10 rounded-full object-cover border-2 border-[#161616] ${ringClass}"
                                                                 onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                                                        </c:when>
                                                        <%-- TH 1B: Nếu là Tên File (ghép với đường dẫn của dự án) --%>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/assets/images/avatar/${fn:trim(s.user.avatar)}" 
                                                                 class="w-10 h-10 rounded-full object-cover border-2 border-[#161616] ${ringClass}"
                                                                 onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <%-- 2. Nếu trống hoàn toàn -> Ảnh chữ cái tạo tự động --%>
                                                <c:otherwise>
                                                    <img src="https://ui-avatars.com/api/?name=${s.user.fullName}&background=random" 
                                                         class="w-10 h-10 rounded-full object-cover border-2 border-[#161616] ${ringClass}">
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <%-- Chấm trạng thái nhỏ góc phải dưới --%>
                                            <div class="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-[#161616] ${s.user.status == 'Active' ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.8)]' : 'bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.8)]'}"></div>
                                        </div>

                                        <div class="min-w-0 flex-1">
                                            <div class="text-white font-semibold line-clamp-1 group-hover:text-blue-400 transition-colors" title="${s.user.fullName}">${s.user.fullName}</div>
                                            <div class="text-[10px] text-gray-500 mt-0.5">Tham gia: <fmt:formatDate value="${s.user.createdAt}" pattern="dd/MM/yyyy"/></div>
                                        </div>
                                    </div>
                                </td>
                                
                                <td class="px-5 py-4">
                                    <div class="text-blue-400 font-mono text-xs mb-2">@${s.user.username}</div>
                                    
                                    <div class="flex flex-col gap-2.5 max-w-[200px]">
                                        <c:choose>
                                            <c:when test="${not empty s.quyen.roleName}">
                                                <c:forEach var="singleRole" items="${fn:split(s.quyen.roleName, ',')}" varStatus="loop">
                                                    <c:set var="trimmedRole" value="${fn:trim(singleRole)}" />
                                                    
                                                    <div class="flex flex-col gap-0.5">
                                                        <c:choose>
                                                            <c:when test="${trimmedRole == 'ADMIN'}">
                                                                <span class="inline-flex items-center gap-1 w-max bg-red-500/10 text-red-400 border border-red-500/20 px-2 py-0.5 rounded text-[10px] uppercase font-bold tracking-wider shadow-sm animate-pulse">
                                                                    <i class="fas fa-crown text-[9px]"></i> ADMIN
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${trimmedRole == 'MANAGER'}">
                                                                <span class="inline-flex items-center gap-1 w-max bg-purple-500/10 text-purple-400 border border-purple-500/20 px-2 py-0.5 rounded text-[10px] uppercase font-bold tracking-wider shadow-sm">
                                                                    <i class="fas fa-briefcase text-[9px]"></i> QUẢN LÝ
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="inline-flex items-center gap-1 w-max bg-blue-500/10 text-blue-400 border border-blue-500/20 px-2 py-0.5 rounded text-[10px] uppercase font-bold tracking-wider shadow-sm">
                                                                    <i class="fas fa-ticket-alt text-[9px]"></i> NV BÁN VÉ
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <c:set var="dateArray" value="${fn:split(s.quyen.description, ',')}" />
                                                        <c:choose>
                                                            <c:when test="${fn:length(dateArray) > 1 && fn:length(dateArray) > loop.index}">
                                                                <div class="text-[9px] text-yellow-600/70 ml-1" title="Ngày cấp quyền này">
                                                                    <i class="fas fa-clock"></i> ${fn:trim(dateArray[loop.index])}
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:if test="${loop.index == 0}">
                                                                    <div class="text-[9px] text-yellow-600/70 ml-1" title="Ngày cấp quyền (gần nhất)">
                                                                        <i class="fas fa-clock"></i> <fmt:formatDate value="${s.createdAt}" pattern="dd/MM/yyyy"/>
                                                                    </div>
                                                                </c:if>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center gap-1 w-max bg-gray-500/10 text-gray-400 border border-gray-500/20 px-2 py-0.5 rounded text-[10px] uppercase font-bold tracking-wider italic">
                                                    <i class="fas fa-user-slash text-[9px]"></i> Trống quyền
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>

                                <td class="px-5 py-4">
                                    <div class="flex flex-col gap-1 text-xs">
                                        <div class="flex items-center gap-2"><i class="fas fa-envelope text-gray-500 w-3"></i> ${not empty s.user.email ? s.user.email : '<span class="text-gray-600 italic">Chưa cập nhật</span>'}</div>
                                        <div class="flex items-center gap-2"><i class="fas fa-phone-alt text-gray-500 w-3"></i> ${not empty s.user.phone ? s.user.phone : '<span class="text-gray-600 italic">Chưa cập nhật</span>'}</div>
                                    </div>
                                </td>
                                <td class="px-5 py-4 text-center">
                                    <c:choose>
                                        <c:when test="${s.user.status == 'Active'}">
                                            <div class="inline-flex items-center gap-1.5 bg-green-500/10 text-green-400 px-2.5 py-1 rounded-full text-xs font-medium border border-green-500/20 shadow-[0_0_10px_rgba(34,197,94,0.1)]">
                                                <div class="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse"></div> Hoạt động
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="inline-flex items-center gap-1.5 bg-red-500/10 text-red-400 px-2.5 py-1 rounded-full text-xs font-medium border border-red-500/20">
                                                <i class="fas fa-lock text-[10px]"></i> Đã khóa
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="px-5 py-4 text-center">
                                    <a href="${pageContext.request.contextPath}/admin/staffs/detail/${s.user.id_User}" class="inline-flex w-8 h-8 items-center justify-center bg-gray-800 hover:bg-blue-600 text-gray-400 hover:text-white rounded-lg border border-gray-700 transition duration-200 premium-glow" title="Xem/Sửa chi tiết">
                                        <i class="fas fa-pen text-xs"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
    <div class="px-5 py-4 border-t border-gray-800 bg-[#0b0c10] flex justify-between items-center text-xs text-gray-500">
        <div>Hiển thị tổng cộng <strong class="text-white">${fn:length(staffs)}</strong> nhân sự đang hoạt động quyền</div>
    </div>
</div>

<script>
    // =========================================================================
    // 1. PREMIUM TOAST ENGINE (ĐỎ CHO ERROR, XANH LÁ CHO SUCCESS)
    // =========================================================================
    function escapeToastText(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function readBackendMessage(element) {
        if (!element) return '';
        const message = (element.value || '').trim();
        if (message === '' || message.toLowerCase() === 'false' || message.toLowerCase() === 'null') {
            return '';
        }
        return message;
    }

    function triggerPremiumToast(type, title, message) {
        const container = document.getElementById('premium-toast-container');
        if (!container) return;

        const toast = document.createElement('div');
        
        // Thiết lập class cấu trúc layout & hiệu ứng đổ bóng (Glow) theo Type
        let typeClasses = '';
        if (type === 'success') {
            typeClasses = 'bg-green-950/95 text-white toast-success-glow border-green-400/50';
        } else {
            typeClasses = 'bg-red-950/95 text-white toast-error-glow border-red-400/50';
        }
        
        toast.className = `toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ` + typeClasses;

        let iconHtml = '';
        let titleColorClass = '';
        let barGradientClass = '';
        let iconBgClass = '';
        let subIconHtml = '';

        // Tùy biến giao diện đỏ động và xanh lá động
        if (type === 'success') {
            iconHtml = '<i class="fas fa-check-circle text-base animate-pulse"></i>';
            titleColorClass = 'text-green-200';
            iconBgClass = 'bg-green-400/15 border-green-300/30 text-green-200';
            barGradientClass = 'from-green-500 via-emerald-300 to-lime-400';
            subIconHtml = '<i class="fas fa-star text-[10px]"></i>';
        } else {
            iconHtml = '<i class="fas fa-exclamation-triangle text-base animate-subtle-bounce"></i>';
            titleColorClass = 'text-red-200';
            iconBgClass = 'bg-red-400/15 border-red-300/30 text-red-200';
            barGradientClass = 'from-red-500 via-rose-400 to-orange-300';
            subIconHtml = '<i class="fas fa-shield-alt text-[10px]"></i>';
        }

        const safeTitle = escapeToastText(title);
        const safeMessage = escapeToastText(message);

        toast.innerHTML = `
            <div class="flex-shrink-0 w-9 h-9 rounded-xl border flex items-center justify-center ${iconBgClass}">
                ${iconHtml}
            </div>
            <div class="flex-1 min-w-0 pt-0.5">
                <h4 class="text-xs font-black uppercase tracking-wider ${titleColorClass} mb-0.5 flex items-center gap-1.5">
                    ${subIconHtml} 
                    ${safeTitle}
                </h4>
                <p class="text-xs text-white/95 font-medium leading-relaxed">${safeMessage}</p>
            </div>
            <div class="flex-shrink-0 pl-1">
                <button onclick="dismissTargetToast(this.closest('.toast-item'))" class="w-6 h-6 rounded-lg bg-white/5 hover:bg-white/10 text-zinc-400 hover:text-white flex items-center justify-center transition-all duration-200 group" type="button" title="Đóng thông báo">
                    <i class="fas fa-times text-[10px] transform group-hover:rotate-90 transition-transform duration-300"></i>
                </button>
            </div>
            <div class="absolute bottom-0 left-0 h-[3px] bg-gradient-to-r ${barGradientClass} toast-progress-countdown"></div>
        `;

        container.appendChild(toast);
        const autoDismissTimer = setTimeout(() => { dismissTargetToast(toast); }, 5000);
        toast.dataset.timerId = autoDismissTimer;
    }

    function dismissTargetToast(toast) {
        if (!toast || toast.classList.contains('toast-leave-active')) return;
        if (toast.dataset.timerId) clearTimeout(parseInt(toast.dataset.timerId, 10));
        toast.classList.add('toast-leave-active');
        setTimeout(() => { toast.remove(); }, 450);
    }

    // LẮNG NGHE TÍN HIỆU CẦU NỐI BACKEND (Mở trang tự check thông báo Spring/Servlet)
    window.addEventListener('DOMContentLoaded', () => {
        const errorBridge = document.getElementById('backend-error-bridge');
        const successBridge = document.getElementById('backend-success-bridge');
        const errorMessage = readBackendMessage(errorBridge);
        const successMessage = readBackendMessage(successBridge);

        if (errorMessage) {
            triggerPremiumToast('error', 'Cảnh Báo Hệ Thống', errorMessage);
        }
        if (successMessage) {
            triggerPremiumToast('success', 'Thành Công', successMessage);
        }
    });

    // Hàm bao bọc lỗi tĩnh cũ để giữ khả năng tương thích ngược
    function showStaticError(message) {
        triggerPremiumToast('error', 'Lỗi Bộ Lọc Lập Trình', message);
    }

    // =========================================================================
    // 2. LOGIC TƯƠNG TÁC GIAO DIỆN & MODAL CẢNH BÁO
    // =========================================================================
    function toggleFilter() {
        const panel = document.getElementById("filterPanel");
        if (!panel) return;
        if (panel.classList.contains("max-h-0")) {
            panel.classList.remove("max-h-0", "opacity-0", "p-0");
            panel.classList.add("max-h-[1000px]", "opacity-100", "p-6");
        } else {
            panel.classList.add("max-h-0", "opacity-0", "p-0");
            panel.classList.remove("max-h-[1000px]", "opacity-100", "p-6");
        }
    }

    function openDeleteModal() {
        const overlay = document.getElementById('deleteModalOverlay');
        const box = document.getElementById('deleteModalBox');
        if(!overlay || !box) return;
        
        overlay.classList.remove('hidden');
        overlay.classList.add('flex');
        setTimeout(() => {
            overlay.classList.add('opacity-100');
            box.classList.remove('scale-95');
            box.classList.add('scale-100', 'animate-modal-in');
        }, 10);
    }

    function closeDeleteModal() {
        const overlay = document.getElementById('deleteModalOverlay');
        const box = document.getElementById('deleteModalBox');
        if(!overlay || !box) return;
        
        overlay.classList.remove('opacity-100');
        box.classList.remove('scale-100');
        box.classList.add('scale-95');
        setTimeout(() => {
            overlay.classList.remove('flex');
            overlay.classList.add('hidden');
        }, 300);
    }

    // =========================================================================
    // 3. LOGIC BỘ LỌC TÌM KIẾM (ĐỒNG BỘ ID PHẦN TỬ CHUẨN)
    // =========================================================================
    function clearDates() {
        const start = document.getElementById('startDate') || document.getElementById('filterStart');
        const end = document.getElementById('endDate') || document.getElementById('filterEnd');
        if(start) start.value = '';
        if(end) end.value = '';
    }

    function clearAllFilters() {
        // Đồng bộ đọc cả 2 loại id cũ và mới để tránh lỗi null phần tử
        const nameInput = document.getElementById('nameKeyword') || document.getElementById('filterName');
        const contactInput = document.getElementById('contactKeyword') || document.getElementById('filterContact');
        const statusSelect = document.getElementById('statusFilter');
        const roleSelect = document.getElementById('roleFilter');

        if(nameInput) nameInput.value = '';
        if(contactInput) contactInput.value = '';
        if(statusSelect) statusSelect.value = 'ALL';
        if(roleSelect) roleSelect.value = '';
        
        clearDates();

        // Trả trạng thái các nút checkbox lọc bổ sung về mặc định nếu có
        const checkboxes = document.querySelectorAll('.custom-checkbox');
        checkboxes.forEach(cb => cb.checked = false);
        const defaultCheck = document.querySelector('input[value="created"]');
        if(defaultCheck) defaultCheck.checked = true;
    }

    // HÀM CHẠY VALIDATE ĐỒNG BỘ VÀ SUBMIT FORM
    function submitFilterForm() {
        // Lấy dữ liệu an toàn dựa trên cả 2 cấu trúc ID của bạn
        const nameElement = document.getElementById('nameKeyword') || document.getElementById('filterName');
        const contactElement = document.getElementById('contactKeyword') || document.getElementById('filterContact');
        const startElement = document.getElementById('startDate') || document.getElementById('filterStart');
        const endElement = document.getElementById('endDate') || document.getElementById('filterEnd');

        const nameKeyword = nameElement ? nameElement.value.trim() : "";
        const contactKeyword = contactElement ? contactElement.value.trim() : "";
        const startD = startElement ? startElement.value : "";
        const endD = endElement ? endElement.value : "";

        // 1. Kiểm tra Regex họ và tên nhân viên (Chỉ cho phép chữ và dấu khoảng trắng)
        if (nameKeyword !== "") {
            const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏố lookup ồổỗộớờởỡợụủứừỮỰỲỴÝỶỸửữựỳỵỷỹ\s]+$/;
            if (!nameRegex.test(nameKeyword)) {
                triggerPremiumToast('error', 'Lỗi Tìm Kiếm', 'Họ tên nhân sự tìm kiếm không hợp lệ (Không được chứa số hoặc ký tự lạ)!');
                return false;
            }
        }

        // 2. Kiểm tra Regex thông tin liên hệ (SĐT hoặc Email) không chứa ký tự khoảng trắng / dấu Việt Nam
        if (contactKeyword !== "") {
            const contactRegex = /^[a-zA-Z0-9@.\-_+]+$/;
            if (!contactRegex.test(contactKeyword)) {
                triggerPremiumToast('error', 'Lỗi Tìm Kiếm', 'Thông tin SĐT hoặc Email liên hệ không chứa khoảng trắng hoặc chữ có dấu!');
                return false;
            }
        }

        // 3. Kiểm tra khoảng logic ngày (Từ ngày phải nhỏ hơn hoặc bằng đến ngày)
        if (startD !== "" && endD !== "") {
            const date1 = new Date(startD);
            const date2 = new Date(endD);
            if (date1 > date2) {
                triggerPremiumToast('error', 'Bộ Lọc Thời Gian', 'Khoảng ngày lọc không hợp lệ! Thời gian "Từ ngày" không được lớn hơn "Đến ngày".');
                return false;
            }
        }

        // Nếu qua hết các bước Validate, tự động quét tìm form để gửi đi
        const filterForm = document.getElementById('advancedFilterForm') || document.getElementById('filterForm') || document.querySelector('form');
        if(filterForm) {
            filterForm.submit();
        }
    }
</script>