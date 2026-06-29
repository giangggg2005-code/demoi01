<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

    .customer-row {
        transition: background-color 0.4s ease;
        position: relative;
        z-index: 1;
    }
    .customer-row td {
        position: relative;
        transition: all 0.4s ease;
    }
    .customer-row:hover {
        background-color: #161616 !important;
        z-index: 50;
    }

    .customer-row .inner-content {
        transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        transform-origin: left center;
    }
    .customer-row:hover .inner-content {
        transform: scale(1.05);
    }
    .customer-row td.text-center .inner-content {
        transform-origin: center center;
    }
    .customer-row:hover td {
        box-shadow: 0 10px 30px -10px rgba(239, 68, 68, 0.3);
    }

    .customer-row td::before, .customer-row td::after {
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
    .customer-row td::before {
        top: 0;
        animation: borderRunRight 1.5s linear infinite;
    }
    .customer-row td::after {
        bottom: 0;
        animation: borderRunLeft 1.5s linear infinite;
    }
    .customer-row:hover td::before, .customer-row:hover td::after {
        opacity: 1;
    }

    @keyframes borderRunRight {
        0% {
            background-position: 200% 0;
        }
        100% {
            background-position: -200% 0;
        }
    }
    @keyframes borderRunLeft {
        0% {
            background-position: -200% 0;
        }
        100% {
            background-position: 200% 0;
        }
    }
    @keyframes toastFlyIn {
        0% {
            transform: translateX(130%) scale(0.9);
            opacity: 0;
            filter: blur(5px);
        }
        60% {
            transform: translateX(-15px) scale(1.02);
            filter: blur(0);
        }
        80% {
            transform: translateX(5px) scale(0.99);
        }
        100% {
            transform: translateX(0) scale(1);
            opacity: 1;
            filter: blur(0);
        }
    }
    @keyframes toastFadeZoomOut {
        0% {
            transform: translate(0) scale(1);
            opacity: 1;
            filter: blur(0);
        }
        40% {
            transform: translateX(10px) scale(1.01);
            opacity: 0.8;
        }
        100% {
            transform: translateX(60px) scale(0.85);
            opacity: 0;
            filter: blur(6px);
        }
    }
    @keyframes toastTimeline {
        0% {
            width: 100%;
        }
        100% {
            width: 0%;
        }
    }
    @keyframes glowPulseRed {
        0%, 100% {
            border-color: rgba(239, 68, 68, 0.35);
            box-shadow: 0 10px 30px -5px rgba(239, 68, 68, 0.15), 0 0 15px rgba(239, 68, 68, 0.05);
        }
        50% {
            border-color: rgba(239, 68, 68, 0.8);
            box-shadow: 0 15px 35px -2px rgba(239, 68, 68, 0.35), 0 0 25px rgba(239, 68, 68, 0.15);
        }
    }
    @keyframes glowPulseGreen {
        0%, 100% {
            border-color: rgba(34, 197, 94, 0.35);
            box-shadow: 0 10px 30px -5px rgba(34, 197, 94, 0.15), 0 0 15px rgba(34, 197, 94, 0.05);
        }
        50% {
            border-color: rgba(34, 197, 94, 0.8);
            box-shadow: 0 15px 35px -2px rgba(34, 197, 94, 0.35), 0 0 25px rgba(34, 197, 94, 0.15);
        }
    }
    @keyframes subtleBounce {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-3px);
        }
    }

    .toast-item {
        animation: toastFlyIn 0.55s cubic-bezier(0.25, 1, 0.5, 1) forwards;
        will-change: transform, opacity;
    }
    .toast-item.toast-leave-active {
        animation: toastFadeZoomOut 0.45s cubic-bezier(0.25, 1, 0.5, 1) forwards !important;
    }
    .toast-error-glow {
        animation: glowPulseRed 3s infinite ease-in-out;
    }
    .toast-success-glow {
        animation: glowPulseGreen 3s infinite ease-in-out;
    }
    .toast-progress-countdown {
        animation: toastTimeline 5s linear forwards;
    }
    .animate-subtle-bounce {
        animation: subtleBounce 2.5s ease-in-out infinite;
    }
    @keyframes modalIn {
        from {
            opacity: 0;
            transform: scale(0.9) translateY(-20px);
        }
        to {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
    }
    .animate-modal-in {
        animation: modalIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    }
    .custom-checkbox {
        accent-color: #dc2626;
        width: 1.1rem;
        height: 1.1rem;
        cursor: pointer;
    }
    .bg-grid-pattern {
        background-image: linear-gradient(to right, rgba(255,255,255,0.02) 1px, transparent 1px),
            linear-gradient(to bottom, rgba(255,255,255,0.02) 1px, transparent 1px);
        background-size: 24px 24px;
    }
    .custom-scrollbar::-webkit-scrollbar {
        height: 8px;
        width: 8px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.2);
        border-radius: 8px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        transition: all 0.3s;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: rgba(239, 68, 68, 0.6);
    }
    .avatar-ring {
        padding: 2px;
        background: linear-gradient(45deg, #ef4444, #f59e0b, #ec4899);
        border-radius: 50%;
    }
</style>

<%-- KHAY CHỨA TOAST LƠ LỬNG --%>
<div id="premium-toast-container" class="fixed top-6 right-6 z-[9999] flex flex-col gap-4 w-full max-w-sm pointer-events-none"></div>

<%-- CẦU NỐI DỮ LIỆU TỪ BACKEND --%>
<input type="hidden" id="backend-error-bridge" value="${not empty errorMessage ? errorMessage : ''}">
<input type="hidden" id="backend-success-bridge" value="${not empty successMessage ? successMessage : ''}">

<div class="p-4 sm:p-6 space-y-6">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-[#1a1a1a] to-[#121212] p-5 rounded-2xl border border-gray-800/60 shadow-xl relative overflow-hidden">
        <div class="absolute -top-10 -right-10 w-40 h-40 bg-red-600/10 blur-[50px] rounded-full pointer-events-none"></div>
        <div class="relative z-10">
            <h2 class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white to-gray-400 tracking-wide uppercase">Quản Lý Khách Hàng</h2>
            <p class="text-sm text-gray-400 mt-1 flex items-center gap-2">
                <i class="fas fa-users text-red-500"></i> Tổng thành viên: <span class="text-white font-bold">${totalCustomers != null ? totalCustomers : 0}</span>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/customers/add" 
           class="bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-[0_0_15px_rgba(220,38,38,0.3)] transition-all flex items-center gap-2 transform hover:-translate-y-0.5">
            <i class="fas fa-plus-circle text-lg"></i> Thêm Khách Hàng
        </a>
    </div>

    <div class="bg-[#1a1a1a] p-6 rounded-2xl border border-gray-800/60 shadow-xl space-y-5 relative z-10">
        <div class="flex items-center justify-between pb-3 border-b border-gray-800/60">
            <div class="flex items-center gap-2">
                <i class="fas fa-filter text-red-500 text-sm"></i>
                <span class="text-xs font-bold text-gray-200 uppercase tracking-wider">Bộ lọc khách hàng đa luồng</span>
            </div>
            <button type="button" onclick="clearAllFilters()" class="text-gray-400 hover:text-red-400 text-xs transition flex items-center gap-1.5"><i class="fas fa-undo"></i> Làm mới lọc</button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/customers" method="GET" id="advancedFilterForm" class="space-y-5">
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">Tên Khách Hàng</label>
                    <div class="relative">
                        <i class="fas fa-user absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-sm fa-icon transition-colors"></i>
                        <input type="text" name="nameKeyword" id="nameKeyword" value="${currentNameKeyword}" placeholder="Chỉ nhập chữ..." class="w-full bg-[#121212] text-white text-sm pl-9 pr-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    </div>
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">SĐT / Email</label>
                    <div class="relative">
                        <i class="fas fa-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-sm fa-icon transition-colors"></i>
                        <input type="text" name="contactKeyword" id="contactKeyword" value="${currentContactKeyword}" placeholder="Không dấu, không khoảng trắng..." class="w-full bg-[#121212] text-white text-sm pl-9 pr-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    </div>
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">Trạng thái tài khoản</label>
                    <select name="status" id="statusFilter" class="w-full bg-[#121212] text-white text-sm px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition cursor-pointer">
                        <option value="all" ${currentStatus == 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Active" ${currentStatus == 'Active' ? 'selected' : ''}>Hoạt động (Active)</option>
                        <option value="Locked" ${currentStatus == 'Locked' ? 'selected' : ''}>Khóa (Locked)</option>
                    </select>
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">Sắp xếp mức chi tiêu</label>
                    <select name="sortSpent" id="sortSpentFilter" class="w-full bg-[#121212] text-white text-sm px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition cursor-pointer">
                        <option value="none" ${currentSortSpent == 'none' ? 'selected' : ''}>Mặc định (Tạo mới nhất)</option>
                        <option value="desc" ${currentSortSpent == 'desc' ? 'selected' : ''}>Chi tiêu Cao đến Thấp</option>
                        <option value="asc" ${currentSortSpent == 'asc' ? 'selected' : ''}>Chi tiêu Thấp đến Cao</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">Chi tiêu tối thiểu (VNĐ)</label>
                    <input type="number" name="minSpent" id="minSpent" value="${currentMinSpent}" min="0" oninput="validity.valid||(value='');" placeholder="VD: 50000" class="w-full bg-[#121212] text-white text-sm px-4 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide flex justify-between items-center">
                        <span>Chi tiêu tối đa (VNĐ)</span>
                        <button type="button" onclick="clearSpending()" class="text-red-500 hover:text-red-400 text-[10px] normal-case cursor-pointer transition flex items-center gap-1"><i class="fas fa-eraser"></i> Xóa mức chi</button>
                    </label>
                    <input type="number" name="maxSpent" id="maxSpent" value="${currentMaxSpent}" min="0" oninput="validity.valid||(value='');" placeholder="VD: 1000000" class="w-full bg-[#121212] text-white text-sm px-4 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide">Từ ngày</label>
                    <div class="relative">
                        <input type="date" name="startDate" id="startDate" value="${currentStartDate}" class="w-full bg-[#121212] text-white text-sm pl-4 pr-10 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition relative z-10 bg-transparent">
                        <i class="fas fa-calendar-alt absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none z-0 fa-icon transition-colors"></i>
                    </div>
                </div>
                <div class="flex flex-col space-y-1.5 input-group">
                    <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wide flex justify-between items-center">
                        <span>Đến ngày</span>
                        <button type="button" onclick="clearDates()" class="text-red-500 hover:text-red-400 text-[10px] normal-case cursor-pointer transition flex items-center gap-1"><i class="fas fa-eraser"></i> Xóa ngày</button>
                    </label>
                    <div class="relative">
                        <input type="date" name="endDate" id="endDate" value="${currentEndDate}" class="w-full bg-[#121212] text-white text-sm pl-4 pr-10 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition relative z-10 bg-transparent">
                        <i class="fas fa-calendar-alt absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none z-0 fa-icon transition-colors"></i>
                    </div>
                </div>
            </div>

            <div class="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 pt-4 border-t border-gray-800/40">
                <div class="flex items-center gap-5 bg-[#121212] px-5 py-3 rounded-xl border border-gray-800 input-group shadow-inner">
                    <span class="text-xs text-gray-400 font-bold uppercase tracking-wider"><i class="fas fa-layer-group text-red-500 mr-1 fa-icon transition-colors"></i> Mốc thời gian áp dụng:</span>

                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="created" class="custom-checkbox bg-gray-800 border-gray-600 transition"
                               ${currentDateFilterType == null || fn:contains(currentDateFilterType, 'created') ? 'checked' : ''}>
                        <span class="text-sm font-bold text-gray-300 group-hover:text-white transition">Ngày tạo TK</span>
                    </label>

                    <span class="text-gray-700 select-none">|</span>

                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="checkbox" name="dateFilterType" value="spending" class="custom-checkbox bg-gray-800 border-gray-600 transition"
                               ${currentDateFilterType != null && fn:contains(currentDateFilterType, 'spending') ? 'checked' : ''}>
                        <span class="text-sm font-bold text-yellow-500 group-hover:text-yellow-400 transition">Ngày chi tiêu</span>
                    </label>
                </div>

                <div class="flex gap-3 w-full lg:w-auto">
                    <button type="button" onclick="submitFilterForm()" class="flex-1 lg:flex-none px-8 py-3 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white rounded-xl text-sm font-bold shadow-[0_0_15px_rgba(239,68,68,0.3)] hover:shadow-[0_0_25px_rgba(239,68,68,0.5)] transition transform hover:-translate-y-1 flex items-center justify-center gap-2">
                        <i class="fas fa-search"></i> Lọc Kết Quả
                    </button>
                </div>
            </div>
        </form>
    </div>
    <div class="bg-[#1a1a1a]/90 bg-grid-pattern backdrop-blur-xl rounded-2xl border border-gray-800/80 shadow-[0_8px_30px_rgb(0,0,0,0.5)] overflow-hidden relative z-10">
        <div class="overflow-x-auto overflow-y-auto max-h-[600px] w-full custom-scrollbar">
            <table class="w-full text-sm text-left text-gray-400 border-collapse relative">
                <thead class="text-xs text-gray-300 uppercase bg-[#121212]/95 backdrop-blur-md border-b border-gray-800 sticky top-0 z-30 shadow-sm">
                    <tr>
                        <th class="p-5 font-bold tracking-wider">Khách Hàng</th>
                        <th class="p-5 font-bold tracking-wider">Email</th>
                        <th class="p-5 font-bold tracking-wider text-center">Ngày Tạo</th>
                        <th class="p-5 font-bold tracking-wider text-center">Vé Mua</th>
                        <th class="p-5 font-bold tracking-wider text-center">Tổng Chi Tiêu</th>
                        <th class="p-5 font-bold tracking-wider text-center">Trạng Thái</th>
                        <th class="p-5 font-bold tracking-wider text-center">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${customerList}" var="cus">
                        <tr class="customer-row border-b border-gray-800/60 group">
                            <td class="p-4">
                                <div class="inner-content flex items-center gap-3.5">
                                    <div class="avatar-ring shrink-0 shadow-lg transform group-hover:scale-110 group-hover:rotate-3 transition-all duration-500">
                                        <c:choose>
                                            <%-- 1. Nếu avatar có dữ liệu (Link mạng HOẶC Tên file) --%>
                                            <c:when test="${not empty cus.avatar && cus.avatar != 'null' && fn:trim(cus.avatar) != ''}">

                                                <c:choose>
                                                    <%-- TH 1A: Nếu là link từ Internet (bắt đầu bằng http) --%>
                                                    <c:when test="${fn:startsWith(fn:trim(cus.avatar), 'http')}">
                                                        <img src="${fn:trim(cus.avatar)}" 
                                                             class="w-10 h-10 rounded-full object-cover border-2 border-[#1a1a1a]"
                                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                                                    </c:when>

                                                    <%-- TH 1B: Nếu là Tên File (ghép với đường dẫn của dự án) --%>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/assets/images/avatar/${fn:trim(cus.avatar)}" 
                                                             class="w-10 h-10 rounded-full object-cover border-2 border-[#1a1a1a]"
                                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                                                    </c:otherwise>
                                                </c:choose>

                                            </c:when>

                                            <%-- 2. Nếu trống hoàn toàn -> Ảnh chữ cái tạo tự động --%>
                                            <c:otherwise>
                                                <img src="https://ui-avatars.com/api/?name=${cus.fullName}&background=random" 
                                                     class="w-10 h-10 rounded-full object-cover border-2 border-[#1a1a1a]">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="flex flex-col">
                                        <div class="font-bold text-gray-100 group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-white group-hover:to-red-400 transition-all duration-300 text-base line-clamp-1">${cus.fullName}</div>
                                        <div class="text-[11px] text-gray-500 mt-0.5"><i class="fas fa-phone-alt text-[10px] mr-1 opacity-70 text-red-500/70"></i>${cus.phone}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="p-4">
                                <div class="inner-content text-gray-400 font-mono text-xs group-hover:text-gray-300 transition-colors">${cus.email}</div>
                            </td>
                            <td class="p-4 text-center">
                                <div class="inner-content flex justify-center items-center gap-1.5 text-gray-400 text-[11px] font-medium group-hover:text-white transition-colors">
                                    <i class="far fa-calendar-alt text-red-500"></i>
                                    <fmt:formatDate value="${cus.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </div>
                            </td>
                            <td class="p-4 text-center">
                                <div class="inner-content font-bold text-blue-400 group-hover:text-blue-300 transition-colors text-sm">${cus.totalBookings}</div>
                            </td>
                            <td class="p-4 text-center">
                                <div class="inner-content text-yellow-500 font-black tracking-wide text-sm group-hover:text-yellow-400 transition-colors">
                                    <fmt:formatNumber value="${cus.totalSpent}" maxFractionDigits="0" /> đ
                                </div>
                            </td>
                            <td class="p-4 text-center">
                                <div class="inner-content inline-block">
                                    <c:choose>
                                        <c:when test="${cus.status == 'Active'}">
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-green-500/10 text-green-500 border-green-500/30">
                                                <i class="fas fa-check-circle"></i> Hoạt động
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-red-500/10 text-red-500 border-red-500/30">
                                                <i class="fas fa-lock"></i> Bị Khóa
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td class="p-4">
                                <div class="inner-content flex items-center justify-center gap-2 opacity-60 group-hover:opacity-100 transition-opacity duration-300">
                                    <a href="${pageContext.request.contextPath}/admin/customers/detail/${cus.id_User}" class="w-8 h-8 rounded-lg bg-blue-500/10 text-blue-400 flex items-center justify-center hover:bg-blue-500 hover:text-white hover:shadow-[0_0_15px_rgba(59,130,246,0.6)] transition-all duration-300 transform hover:-translate-y-1" title="Chỉnh sửa hồ sơ">
                                        <i class="fas fa-pen text-sm"></i>
                                    </a>

                                    <button type="button" onclick="openDeleteModal(${cus.id_User})" class="w-8 h-8 rounded-lg bg-red-500/10 text-red-500 flex items-center justify-center hover:bg-red-600 hover:text-white hover:shadow-[0_0_15px_rgba(239,68,68,0.6)] transition-all duration-300 transform hover:-translate-y-1" title="Xóa khách hàng">
                                        <i class="fas fa-trash-alt text-sm"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty customerList}">
                        <tr>
                            <td colspan="7" class="p-12">
                                <div class="flex flex-col items-center justify-center gap-4 w-full max-w-md mx-auto p-8 rounded-2xl border-2 border-dashed border-gray-700/50 bg-[#121212]/50">
                                    <div class="w-16 h-16 rounded-2xl bg-gray-800/80 flex items-center justify-center border border-gray-700 shadow-inner transform rotate-3">
                                        <i class="fas fa-search text-2xl text-gray-500"></i>
                                    </div>
                                    <div class="text-center">
                                        <h4 class="text-gray-300 font-bold text-sm mb-1">Không tìm thấy khách hàng</h4>
                                        <p class="text-gray-500 text-xs">Vui lòng thử thay đổi từ khóa hoặc xóa bớt các bộ lọc để xem thêm dữ liệu.</p>
                                    </div>
                                    <button type="button" onclick="clearAllFilters(); submitFilterForm();" class="mt-2 px-4 py-2 bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white rounded-lg text-xs font-bold transition-colors">
                                        Xóa Bộ Lọc Ngay
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <div id="deleteModalOverlay" class="fixed inset-0 bg-black/80 z-[10000] hidden items-center justify-center backdrop-blur-sm transition-opacity duration-300 opacity-0">
        <div id="deleteModalBox" class="bg-[#121212] border border-red-500/50 rounded-2xl p-6 max-w-md w-full shadow-[0_0_30px_rgba(220,38,38,0.3)] transform scale-95 transition-transform duration-300">
            <div class="text-center mb-5">
                <div class="w-20 h-20 bg-red-500/10 rounded-full flex items-center justify-center mx-auto mb-4 border border-red-500/30">
                    <i class="fas fa-user-slash text-4xl text-red-500"></i>
                </div>
                <h3 class="text-xl font-bold text-white mb-2 uppercase tracking-wider">Cảnh Báo Xóa</h3>
                <p class="text-sm text-gray-400 leading-relaxed">
                    Hệ thống sẽ <strong class="text-red-400">chặn thao tác xóa</strong> nếu khách hàng này đã có phát sinh giao dịch hoặc mua vé để bảo vệ tính toàn vẹn của báo cáo doanh thu.
                </p>
                <div class="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-3.5 mt-4 text-left shadow-inner">
                    <p class="text-xs text-yellow-500 leading-relaxed">
                        <i class="fas fa-lightbulb text-yellow-400 mr-1.5 animate-pulse"></i> <strong>Lời khuyên nghiệp vụ:</strong> Bạn nên sử dụng tính năng <strong>[Khóa Tài Khoản]</strong> ở trang Chi tiết để vô hiệu hóa người dùng mà không làm mất lịch sử dữ liệu.
                    </p>
                </div>
                <p class="text-sm text-gray-300 mt-5 font-medium">Bạn vẫn chắc chắn muốn thử xóa khách hàng này?</p>
            </div>
            <div class="flex gap-3">
                <button type="button" onclick="closeDeleteModal()" class="flex-1 px-4 py-2.5 bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white rounded-xl text-sm font-medium transition flex justify-center items-center gap-2">
                    <i class="fas fa-times"></i> Hủy bỏ
                </button>
                <button type="button" id="confirmDeleteBtn" class="flex-1 px-4 py-2.5 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white rounded-xl text-sm font-bold shadow-[0_0_15px_rgba(220,38,38,0.4)] transition flex justify-center items-center gap-2">
                    <i class="fas fa-trash-alt"></i> Vẫn Xóa
                </button>
            </div>
        </div>
    </div>

</div> 

<script>
    // ==========================================
    // 1. LOGIC CHO CUSTOM TOAST NOTIFICATION CAO CẤP
    // ==========================================
    function triggerPremiumToast(type, title, message) {
        const container = document.getElementById('premium-toast-container');
        if (!container)
            return;

        const toast = document.createElement('div');

        toast.className = `toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ` +
                (type === 'success' ? 'bg-zinc-950/90 text-white toast-success-glow border-green-500/30' : 'bg-zinc-950/90 text-white toast-error-glow border-red-500/30');

        let iconHtml = '';
        let titleColorClass = '';
        let barGradientClass = '';
        let iconBgClass = '';

        let subIconHtml = (type === 'success')
                ? '<i class="fas fa-star text-[10px]"></i>'
                : '<i class="fas fa-shield-alt text-[10px]"></i>';

        if (type === 'success') {
            iconHtml = '<i class="fas fa-check-circle text-base animate-pulse"></i>';
            titleColorClass = 'text-green-400';
            iconBgClass = 'bg-green-500/10 border-green-500/20 text-green-400';
            barGradientClass = 'from-green-500 via-emerald-400 to-teal-500';
        } else {
            iconHtml = '<i class="fas fa-exclamation-triangle text-base animate-subtle-bounce"></i>';
            titleColorClass = 'text-red-400';
            iconBgClass = 'bg-red-500/10 border-red-500/20 text-red-400';
            barGradientClass = 'from-red-500 via-rose-500 to-amber-500';
        }

        toast.innerHTML = `
            <div class="flex-shrink-0 w-9 h-9 rounded-xl border flex items-center justify-center \${iconBgClass}">
                \${iconHtml}
            </div>
            <div class="flex-1 min-w-0 pt-0.5">
                <h4 class="text-xs font-black uppercase tracking-wider \${titleColorClass} mb-0.5 flex items-center gap-1.5">
                    \${subIconHtml} 
                    \${title}
                </h4>
                <p class="text-xs text-zinc-300 font-medium leading-relaxed">\${message}</p>
            </div>
            <div class="flex-shrink-0 pl-1">
                <button onclick="dismissTargetToast(this.closest('.toast-item'))" class="w-6 h-6 rounded-lg bg-white/5 hover:bg-white/10 text-zinc-400 hover:text-white flex items-center justify-center transition-all duration-200 group" type="button" title="Đóng thông báo">
                    <i class="fas fa-times text-[10px] transform group-hover:rotate-90 transition-transform duration-300"></i>
                </button>
            </div>
            <div class="absolute bottom-0 left-0 h-[3px] bg-gradient-to-r \${barGradientClass} toast-progress-countdown"></div>
        `;

        container.appendChild(toast);

        const autoDismissTimer = setTimeout(() => {
            dismissTargetToast(toast);
        }, 5000);

        toast.dataset.timerId = autoDismissTimer;
    }

    function dismissTargetToast(toast) {
        if (!toast || toast.classList.contains('toast-leave-active'))
            return;

        if (toast.dataset.timerId) {
            clearTimeout(parseInt(toast.dataset.timerId));
        }

        toast.classList.add('toast-leave-active');

        setTimeout(() => {
            toast.remove();
        }, 450);
    }

    window.addEventListener('DOMContentLoaded', () => {
        const errorBridge = document.getElementById('backend-error-bridge');
        const successBridge = document.getElementById('backend-success-bridge');

        if (errorBridge && errorBridge.value.trim() !== "" && errorBridge.value !== "false") {
            triggerPremiumToast('error', 'Cảnh Báo Lỗi', errorBridge.value.trim());
        }

        if (successBridge && successBridge.value.trim() !== "" && successBridge.value !== "false") {
            triggerPremiumToast('success', 'Thành Công', successBridge.value.trim());
        }
    });

    function showStaticError(message) {
        triggerPremiumToast('error', 'Cảnh Báo Bộ Lọc', message);
    }

    // ==========================================
    // 2. LOGIC CHO CUSTOM MODAL XÓA KHÁCH HÀNG
    // ==========================================
    let currentDeleteId = null;

    function openDeleteModal(id) {
        currentDeleteId = id;
        const overlay = document.getElementById('deleteModalOverlay');
        const box = document.getElementById('deleteModalBox');

        overlay.classList.remove('hidden');
        overlay.classList.add('flex');

        setTimeout(() => {
            overlay.classList.remove('opacity-0');
            overlay.classList.add('opacity-100');
            box.classList.remove('scale-95');
            box.classList.add('scale-100', 'animate-modal-in');
        }, 10);
    }

    function closeDeleteModal() {
        const overlay = document.getElementById('deleteModalOverlay');
        const box = document.getElementById('deleteModalBox');

        overlay.classList.remove('opacity-100');
        overlay.classList.add('opacity-0');
        box.classList.remove('scale-100', 'animate-modal-in');
        box.classList.add('scale-95');

        setTimeout(() => {
            overlay.classList.remove('flex');
            overlay.classList.add('hidden');
            currentDeleteId = null;
        }, 300);
    }

    document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
        if (currentDeleteId) {
            window.location.href = `${pageContext.request.contextPath}/admin/customers/delete/` + currentDeleteId;
        }
    });

    // ==========================================
    // 3. LOGIC BỘ LỌC TÌM KIẾM (REGEX & VALIDATION & CLEAR)
    // ==========================================

    // Hàm xóa trắng riêng thời gian (Nút Xóa ngày)
    function clearDates() {
        document.getElementById('startDate').value = '';
        document.getElementById('endDate').value = '';
    }

    // Hàm xóa trắng riêng mức chi tiêu (Nút Xóa mức chi - BỔ SUNG MỚI)
    function clearSpending() {
        document.getElementById('minSpent').value = '';
        document.getElementById('maxSpent').value = '';
    }

    // Hàm làm mới toàn bộ form lọc
    function clearAllFilters() {
        document.getElementById('nameKeyword').value = '';
        document.getElementById('contactKeyword').value = '';
        document.getElementById('statusFilter').value = 'all';
        document.getElementById('sortSpentFilter').value = 'none';

        // Gọi lại 2 hàm xóa lẻ để làm sạch input
        clearSpending();
        clearDates();

        const checkboxes = document.querySelectorAll('.custom-checkbox');
        checkboxes.forEach(cb => cb.checked = false);
        document.querySelector('input[value="created"]').checked = true;
    }

    // Validate Regex và logic form trước khi Submit tìm kiếm
    function submitFilterForm() {
        const nameKeyword = document.getElementById('nameKeyword').value.trim();
        const contactKeyword = document.getElementById('contactKeyword').value.trim();
        const minS = document.getElementById('minSpent').value;
        const maxS = document.getElementById('maxSpent').value;
        const startD = document.getElementById('startDate').value;
        const endD = document.getElementById('endDate').value;

        if (nameKeyword !== "") {
            const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỮỰỲỴÝỶỸửữựỳỵỷỹ\s]+$/;
            if (!nameRegex.test(nameKeyword)) {
                showStaticError("Tên khách hàng không được chứa số hoặc ký tự đặc biệt!");
                return false;
            }
        }

        if (contactKeyword !== "") {
            const contactRegex = /^[a-zA-Z0-9@.\-_+]+$/;
            if (!contactRegex.test(contactKeyword)) {
                showStaticError("SĐT hoặc Email không được chứa khoảng trắng hoặc dấu Tiếng Việt!");
                return false;
            }
        }

        const minVal = minS !== "" ? parseFloat(minS) : null;
        const maxVal = maxS !== "" ? parseFloat(maxS) : null;

        if (minVal !== null && minVal < 0) {
            showStaticError("Chi tiêu tối thiểu không được là số âm!");
            return false;
        }
        if (maxVal !== null && maxVal < 0) {
            showStaticError("Chi tiêu tối đa không được là số âm!");
            return false;
        }
        if (minVal !== null && maxVal !== null && minVal > maxVal) {
            showStaticError("Khoảng chi tiêu không hợp lệ! (Tối thiểu phải nhỏ hơn hoặc bằng Tối đa)");
            return false;
        }

        if (startD !== "" && endD !== "") {
            const date1 = new Date(startD);
            const date2 = new Date(endD);
            if (date1 > date2) {
                showStaticError("Khoảng thời gian không hợp lệ! (Từ ngày phải nằm trước hoặc bằng Đến ngày)");
                return false;
            }
        }

        document.getElementById('advancedFilterForm').submit();
    }
</script>