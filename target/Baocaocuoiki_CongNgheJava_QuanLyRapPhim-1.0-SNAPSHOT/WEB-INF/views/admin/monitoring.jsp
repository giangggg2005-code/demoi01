<%-- views/admin/monitoring.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .custom-scrollbar::-webkit-scrollbar { width: 6px; height: 6px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: #1a1c23; border-radius: 8px; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: #4b5563; border-radius: 8px; }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #ef4444; }
    .animate-pulse-fast { animation: pulse 1.5s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
</style>
<style>
    /* Hiệu ứng ẩn/hiện mượt mà (Fade Out & Scale Down) cho hàng dữ liệu */
    .local-filter-item {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        opacity: 1;
        transform: scale(1);
    }
    .local-filter-item.hidden-item {
        opacity: 0 !important;
        transform: scale(0.92) translateY(-10px) !important;
        pointer-events: none;
    }
    /* Thanh cuộn Custom Scrollbar Glow Neon đẳng cấp */
    .custom-scrollbar::-webkit-scrollbar { width: 5px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: rgba(255,255,255,0.02); border-radius: 10px; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #3b82f6, #10b981); border-radius: 10px; }
    
    /* Hiệu ứng viền phát sáng Gradient vô cực khi Hover */
    .card-glowing-hover:hover {
        box-shadow: 0 0 15px rgba(59, 130, 246, 0.15);
        transform: translateY(-2px);
    }
</style>
<div class="space-y-6 animate-fade-in pb-10">
    
    <%-- 1. HEADER & NÚT CHỨC NĂNG --%>
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-2">
        <div>
            <h1 class="text-2xl font-black text-white flex items-center gap-3 uppercase tracking-wider">
                <i class="fas fa-satellite-dish text-blue-500"></i> GIÁM SÁT HOẠT ĐỘNG
                <span class="bg-red-500/20 text-red-500 text-[10px] uppercase font-bold px-2 py-0.5 rounded-full border border-red-500/50 flex items-center gap-1">
                    <span class="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse-fast"></span> LIVE
                </span>
            </h1>
            <p class="text-xs text-gray-400 mt-1">Theo dõi vận hành, tài khoản và giao dịch theo thời gian thực.</p>
        </div>
        <div class="flex gap-2 no-print">
            <button type="button" onclick="alert('Tính năng xuất Excel cho giám sát đang được phát triển!')" class="bg-green-600 hover:bg-green-700 text-white px-3 py-1.5 rounded-lg text-sm font-bold transition shadow-lg flex items-center gap-1.5">
                <i class="fa-solid fa-file-excel"></i> Xuất Excel
            </button>
            <button type="button" onclick="window.print()" class="bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg text-sm font-bold transition shadow-lg flex items-center gap-1.5">
                <i class="fa-solid fa-file-pdf"></i> In PDF
            </button>
        </div>
    </div>

    <%-- 2. KHỐI HIỂN THỊ LỖI --%>
    <c:if test="${not empty errorMessage}">
        <div class="bg-red-900/30 border border-red-500/40 rounded-xl p-4 text-xs text-red-400 flex items-center">
            <i class="fas fa-exclamation-triangle text-base mr-3"></i> ${errorMessage}
        </div>
    </c:if>
    <%-- KHUNG CẢNH BÁO LỖI NGOẠI LỆ MÀU ĐỎ (Đồng bộ hiển thị lỗi từ cả Reload trang lẫn AJAX) --%>
<div id="txValidationErrorBox" class="${not empty txValidationError ? '' : 'hidden'} mb-4 bg-red-500/10 border border-red-500/40 rounded-xl p-3.5 flex items-start gap-3 transition-all duration-300">
    <div class="w-7 h-7 rounded-lg bg-red-500/20 flex items-center justify-center text-red-500 shrink-0 text-xs">
        <i class="fas fa-exclamation-triangle"></i>
    </div>
    <div>
        <h5 class="text-white font-bold text-xs">Lỗi ràng buộc dữ liệu tìm kiếm!</h5>
        <p id="txValidationErrorMessage" class="text-[11px] text-red-400 mt-0.5">${txValidationError}</p>
    </div>
</div>

    <%-- 3. FORM BỘ LỌC TỔNG --%>
    <form id="filterForm" method="GET" action="${pageContext.request.contextPath}/admin/monitoring" class="glass-card border border-gray-800 rounded-2xl p-5 shadow-lg bg-[#1a1c23]">
        <div class="grid grid-cols-1 md:grid-cols-6 gap-4 items-end">
            
            <%-- Cột 1: Lọc nhanh --%>
            <div class="md:col-span-1">
                <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Lọc Nhanh</label>
                <select name="quickSelect" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none" id="timeQuickSelect" onchange="handleTimeQuickSelect(this.value)">
                    <option value="CUSTOM" ${currentQuickSelect == 'CUSTOM' || empty currentQuickSelect ? 'selected' : ''}>Tùy chọn...</option>
                    <option value="TODAY" ${currentQuickSelect == 'TODAY' ? 'selected' : ''}>Hôm nay</option>
                    <option value="THIS_WEEK" ${currentQuickSelect == 'THIS_WEEK' ? 'selected' : ''}>Tuần này</option>
                    <option value="THIS_MONTH" ${currentQuickSelect == 'THIS_MONTH' ? 'selected' : ''}>Tháng này</option>
                    <option value="THIS_YEAR" ${currentQuickSelect == 'THIS_YEAR' ? 'selected' : ''}>Năm nay</option>
                </select>
            </div>

            <%-- Cột 2: Từ ngày (Mặc định để trống hoàn toàn để trình duyệt hiện nn/mm/yyyy) --%>
            <div class="md:col-span-1">
                <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Từ ngày</label>
                <input type="date" name="startDate" id="startDate" value="${not empty startDate ? startDate : ''}" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
            </div>

            <%-- Cột 3: Đến ngày (Mặc định để trống hoàn toàn để trình duyệt hiện nn/mm/yyyy) --%>
            <div class="md:col-span-1">
                <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Đến ngày</label>
                <input type="date" name="endDate" id="endDate" value="${not empty endDate ? endDate : ''}" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
            </div>

            <%-- Cột 4: Chế độ thống kê (Mặc định chọn MONTH nếu currentTimeframe trống) --%>
            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Chế độ Thống kê</label>
                <select name="timeframe" id="timeframe" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
                    <option value="DAY" ${currentTimeframe == 'DAY' ? 'selected' : ''}>Nhóm theo Ngày</option>
                    <option value="WEEK" ${currentTimeframe == 'WEEK' ? 'selected' : ''}>Nhóm theo Tuần</option>
                    <option value="MONTH" ${empty currentTimeframe || currentTimeframe == 'MONTH' ? 'selected' : ''}>Nhóm theo Tháng (Mặc định)</option>
                    <option value="YEAR" ${currentTimeframe == 'YEAR' ? 'selected' : ''}>Nhóm theo Năm</option>
                </select>
            </div>

            <%-- Cột 5: Nút Submit hành động lọc --%>
            <div class="md:col-span-1">
                <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white p-2.5 rounded-lg text-sm font-bold transition shadow-lg uppercase tracking-wider flex items-center justify-center gap-1.5">
                    <i class="fa-solid fa-filter"></i> Lọc
                </button>
            </div>
        </div>
    </form>

    <%-- KHU VỰC CẢNH BÁO SUẤT CHIẾU Ế (24h TỚI) --%>
    <c:if test="${not empty zeroTicketAlerts}">
        <div class="bg-red-900/20 border border-red-700/50 rounded-2xl p-5 shadow-[0_0_15px_rgba(239,68,68,0.1)]">
            <h2 class="text-red-500 font-bold text-lg mb-4 flex items-center gap-2">
                <i class="fas fa-exclamation-triangle animate-pulse"></i> CẢNH BÁO: SUẤT CHIẾU SẮP DIỄN RA TRONG 24H CÓ NGUY CƠ "Ế" KHÁCH
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <c:forEach var="alert" items="${zeroTicketAlerts}">
                    <div class="bg-[#0b0c10] border border-red-800/50 p-4 rounded-xl relative overflow-hidden">
                        <div class="absolute top-0 right-0 bg-red-600 text-white text-[10px] font-bold px-2 py-1 rounded-bl-lg">
                            Chỉ ${alert.ticketsSold} vé
                        </div>
                        <h3 class="text-white font-bold text-base truncate pr-16">${alert.movieTitle}</h3>
                        <p class="text-sm text-gray-400 mt-1"><i class="fas fa-door-open w-4"></i> ${alert.roomName}</p>
                        <p class="text-sm text-gray-400"><i class="far fa-calendar-alt w-4"></i> ${alert.showDate} | <span class="text-red-400 font-semibold">${alert.startTime}</span></p>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <%-- BIỂU ĐỒ TĂNG TRƯỞNG TÀI KHOẢN & GIAO DỊCH --%>
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl p-5">
            <h3 class="text-white font-bold mb-4"><i class="fas fa-users text-blue-400"></i> Tốc độ tăng trưởng Tài khoản mới</h3>
            <div class="relative h-64 w-full">
                <canvas id="registrationChart"></canvas>
            </div>
        </div>

        <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl p-5">
            <h3 class="text-white font-bold mb-4"><i class="fas fa-chart-line text-purple-400"></i> Số lượng Giao dịch tăng trưởng</h3>
            <div class="relative h-64 w-full flex justify-center">
                <canvas id="transactionTrendChart"></canvas>
            </div>
        </div>
    </div>
<%-- NÚT ẨN/HIỆN DANH SÁCH CHI TIẾT TÀI KHOẢN --%>
<div class="text-center mt-2">
    <button onclick="toggleAccountDetails()" class="bg-gray-800 border border-gray-700 hover:bg-gray-700 text-gray-300 px-6 py-2 rounded-full text-sm font-semibold transition shadow-lg flex items-center justify-center mx-auto gap-2">
        <i class="fas fa-users-cog"></i> Bật/Tắt Bảng Chi Tiết Khách Hàng & Nhân Sự Mới
    </button>
</div>

<%-- KHU VỰC ẨN/HIỆN: 4 BẢNG DANH SÁCH TÀI KHOẢN & CẬP NHẬT & PHÂN QUYỀN --%>
<div id="accountDetailsSection" class="hidden mt-4 animate-fade-in">
    
    <%-- ĐỔI MỚI: THANH BỘ LỌC TÁCH BIỆT 3 CỘT KẾT HỢP SONG SONG (SMART FILTER BAR) --%>
    <div class="mb-6 bg-gradient-to-r from-[#141517] to-[#1a1c23] p-4 rounded-2xl border border-gray-800/80 shadow-2xl">
        <div class="flex items-center justify-between cursor-pointer border-b border-gray-800/60 pb-3" onclick="toggleAdvancedFilter()">
            <div class="text-xs text-gray-300 flex items-center gap-2">
                <div class="p-1.5 rounded-lg bg-blue-500/10 text-blue-400">
                    <i class="fas fa-sliders-h animate-pulse"></i>
                </div>
                <div>
                    <span class="text-gray-200 font-bold text-sm block">Bộ Lọc Tức Thì Đa Năng (Local Multi-Filter)</span>
                    <span class="text-[11px] text-gray-500">Cho phép nhập kết hợp song song cả 3 trường để lọc chéo dữ liệu thời gian thực</span>
                </div>
            </div>
            <button class="text-gray-400 hover:text-white p-1 bg-gray-800/40 rounded-lg transition-transform duration-300" id="filterToggleButton">
                <i class="fas fa-chevron-down text-xs transition-transform duration-300" id="filterToggleIcon"></i>
            </button>
        </div>

        <%-- Form 3 Inputs riêng biệt kèm hiệu ứng chuyển động trượt mở --%>
        <div id="advancedFilterBox" class="grid grid-cols-1 sm:grid-cols-3 gap-4 transition-all duration-500 overflow-hidden max-h-[300px] opacity-100 py-4">
            <div class="relative group">
                <label class="block text-[11px] font-medium text-gray-400 mb-1.5 group-focus-within:text-blue-400 transition">Họ và Tên</label>
                <div class="relative">
                    <input type="text" id="localSearchName" onkeyup="executeLocalFilter()" placeholder="Nhập tên cần tìm..." 
                           class="w-full bg-[#0b0c10] text-white border border-gray-800 rounded-xl pl-9 pr-3 py-2 text-xs focus:border-blue-500/80 focus:ring-1 focus:ring-blue-500/30 transition outline-none shadow-inner">
                    <i class="fas fa-user absolute left-3 top-2.5 text-gray-600 group-focus-within:text-blue-500 text-xs transition"></i>
                </div>
            </div>

            <div class="relative group">
                <label class="block text-[11px] font-medium text-gray-400 mb-1.5 group-focus-within:text-emerald-400 transition">Địa chỉ Email</label>
                <div class="relative">
                    <input type="text" id="localSearchEmail" onkeyup="executeLocalFilter()" placeholder="Nhập gmail cần tìm..." 
                           class="w-full bg-[#0b0c10] text-white border border-gray-800 rounded-xl pl-9 pr-3 py-2 text-xs focus:border-emerald-500/80 focus:ring-1 focus:ring-emerald-500/30 transition outline-none shadow-inner">
                    <i class="fas fa-envelope absolute left-3 top-2.5 text-gray-600 group-focus-within:text-emerald-500 text-xs transition"></i>
                </div>
            </div>

            <div class="relative group">
                <label class="block text-[11px] font-medium text-gray-400 mb-1.5 group-focus-within:text-amber-400 transition">Số Điện Thoại</label>
                <div class="relative">
                    <input type="text" id="localSearchPhone" onkeyup="executeLocalFilter()" placeholder="Nhập số điện thoại..." 
                           class="w-full bg-[#0b0c10] text-white border border-gray-800 rounded-xl pl-9 pr-3 py-2 text-xs focus:border-amber-500/80 focus:ring-1 focus:ring-amber-500/30 transition outline-none shadow-inner">
                    <i class="fas fa-phone-alt absolute left-3 top-2.5 text-gray-600 group-focus-within:text-amber-500 text-xs transition"></i>
                </div>
            </div>
        </div>
    </div>

    <%-- Cấu trúc GRID 4 Cột hiển thị dữ liệu --%>
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        
        <%-- Bảng 1: Khách hàng mới tham gia --%>
        <div class="bg-[#1a1c23] border border-gray-800/60 rounded-2xl p-4 flex flex-col shadow-xl">
            <h3 class="text-white font-bold text-sm mb-3 border-b border-gray-800 pb-2 flex justify-between items-center">
                <span class="flex items-center gap-1.5"><i class="fas fa-user-plus text-blue-400"></i> Khách hàng mới</span>
                <span class="text-[10px] bg-blue-500/10 text-blue-400 px-2 py-0.5 rounded-full font-mono font-bold border border-blue-500/20">Tổng: ${fn:length(newCustomers)}</span>
            </h3>
            <div class="overflow-y-auto custom-scrollbar max-h-80 pr-1 space-y-2.5">
                <c:forEach var="cus" items="${newCustomers}">
                    <%-- Cấu hình Thẻ chứa Dữ liệu tra cứu độc lập cho JS Engine --%>
                    <a href="${pageContext.request.contextPath}/admin/customers/detail/${cus.id_User}" 
                       class="local-filter-item card-glowing-hover block bg-[#0b0c10] p-3 rounded-xl border border-gray-800/80 flex justify-between items-center hover:border-blue-500/40 hover:bg-gradient-to-r hover:from-[#0b0c10] hover:to-blue-950/10 transition cursor-pointer group"
                       data-name="${fn:toLowerCase(cus.fullName)}" 
                       data-email="${fn:toLowerCase(cus.email)}" 
                       data-phone="${fn:toLowerCase(cus.phone != null ? cus.phone : '')}"
                       title="Gmail: ${cus.email} | SĐT: ${cus.phone}">
                        <div class="truncate mr-2">
                            <p class="text-white text-xs font-bold group-hover:text-blue-400 transition truncate">${cus.fullName}</p>
                            <p class="text-gray-500 text-[10px] font-mono">@${cus.username}</p>
                        </div>
                        <span class="text-[10px] text-blue-400/90 font-mono shrink-0 bg-blue-500/5 px-2 py-0.5 rounded border border-blue-500/10">${fn:substring(cus.createdAt, 0, 10)}</span>
                    </a>
                </c:forEach>
                <c:if test="${empty newCustomers}"><p class="text-xs text-gray-500 text-center py-4">Không tìm thấy dữ liệu.</p></c:if>
            </div>
        </div>

        <%-- Bảng 2: Nhân sự nội bộ mới --%>
        <div class="bg-[#1a1c23] border border-gray-800/60 rounded-2xl p-4 flex flex-col shadow-xl">
            <h3 class="text-white font-bold text-sm mb-3 border-b border-gray-800 pb-2 flex justify-between items-center">
                <span class="flex items-center gap-1.5"><i class="fas fa-id-badge text-amber-400"></i> Nhân sự nội bộ mới</span>
                <span class="text-[10px] bg-amber-500/10 text-amber-400 px-2 py-0.5 rounded-full font-mono font-bold border border-amber-500/20">Tổng: ${fn:length(newStaff)}</span>
            </h3>
            <div class="overflow-y-auto custom-scrollbar max-h-80 pr-1 space-y-2.5">
                <c:forEach var="staff" items="${newStaff}">
                    <div class="local-filter-item card-glowing-hover bg-[#0b0c10] p-3 rounded-xl border border-gray-800/80 flex justify-between items-center hover:border-amber-500/40 hover:bg-gradient-to-r hover:from-[#0b0c10] hover:to-amber-950/10 transition"
                         data-name="${fn:toLowerCase(staff.fullName)}" 
                         data-email="${fn:toLowerCase(staff.email)}" 
                         data-phone="${fn:toLowerCase(staff.phone != null ? staff.phone : '')}"
                         title="Gmail: ${staff.email} | SĐT: ${staff.phone}">
                        <div class="truncate mr-2">
                            <p class="text-white text-xs font-bold truncate">${staff.fullName}</p>
                            <p class="text-amber-500 text-[10px] font-mono uppercase tracking-wider">${staff.roleName}</p>
                        </div>
                        <span class="text-[10px] text-gray-400 font-mono shrink-0 bg-gray-800/40 px-2 py-0.5 rounded">${fn:substring(staff.createdAt, 0, 10)}</span>
                    </div>
                </c:forEach>
                <c:if test="${empty newStaff}"><p class="text-xs text-gray-500 text-center py-4">Không tìm thấy dữ liệu.</p></c:if>
            </div>
        </div>

        <%-- Bảng 3: Tài khoản vừa cập nhật thông tin --%>
        <div class="bg-[#1a1c23] border border-gray-800/60 rounded-2xl p-4 flex flex-col shadow-xl">
            <h3 class="text-white font-bold text-sm mb-3 border-b border-gray-800 pb-2 flex justify-between items-center">
                <span class="flex items-center gap-1.5"><i class="fas fa-user-edit text-green-400"></i> Tài khoản cập nhật TT</span>
                <span class="text-[10px] bg-green-500/10 text-green-400 px-2 py-0.5 rounded-full font-mono font-bold border border-green-500/20">Tổng: ${fn:length(recentUpdates)}</span>
            </h3>
            <div class="overflow-y-auto custom-scrollbar max-h-80 pr-1 space-y-2.5">
                <c:forEach var="update" items="${recentUpdates}">
                    <div class="local-filter-item card-glowing-hover bg-[#0b0c10] p-3 rounded-xl border border-gray-800/80 flex justify-between items-center hover:border-green-500/40 hover:bg-gradient-to-r hover:from-[#0b0c10] hover:to-green-950/10 transition"
                         data-name="${fn:toLowerCase(update.fullName)}" 
                         data-email="${fn:toLowerCase(update.email)}" 
                         data-phone="${fn:toLowerCase(update.phone != null ? update.phone : '')}"
                         title="Gmail: ${update.email} | SĐT: ${update.phone}">
                        <div class="truncate mr-2">
                            <p class="text-white text-xs font-bold truncate">${update.fullName}</p>
                            <p class="text-gray-500 text-[10px] font-mono truncate">SĐT: ${not empty update.phone ? update.phone : 'N/A'}</p>
                        </div>
                        <span class="text-[9px] bg-green-950/40 text-green-400 px-1.5 py-1 rounded border border-green-800/40 font-mono shrink-0 shadow-sm">
                            ${fn:substring(fn:replace(update.updatedAt, 'T', ' '), 0, 16)}
                        </span>
                    </div>
                </c:forEach>
                <c:if test="${empty recentUpdates}"><p class="text-xs text-gray-500 text-center py-4">Không tìm thấy dữ liệu.</p></c:if>
            </div>
        </div>

        <%-- Bảng 4: Dấu vết phân quyền hệ thống --%>
        <div class="bg-[#1a1c23] border border-gray-800/60 rounded-2xl p-4 flex flex-col shadow-xl">
            <h3 class="text-white font-bold text-sm mb-3 border-b border-gray-800 pb-2 flex justify-between items-center">
                <span class="flex items-center gap-1.5"><i class="fas fa-user-shield text-red-400"></i> Dấu vết Phân quyền</span>
                <span class="text-[10px] bg-red-500/10 text-red-400 px-2 py-0.5 rounded-full font-mono font-bold border border-red-500/20">Tổng: ${fn:length(roleAssignments)}</span>
            </h3>
            <div class="overflow-y-auto custom-scrollbar max-h-80 pr-1 space-y-2.5">
                <c:forEach var="role" items="${roleAssignments}">
                    <a href="${pageContext.request.contextPath}/admin/customers/detail/${role.id_User}" 
                       class="local-filter-item card-glowing-hover block bg-[#0b0c10] p-3 rounded-xl border border-gray-800/80 hover:border-red-500/40 hover:bg-gradient-to-r hover:from-[#0b0c10] hover:to-red-950/10 transition cursor-pointer group"
                       data-name="${fn:toLowerCase(role.fullName)}" 
                       data-email="${fn:toLowerCase(role.email)}" 
                       data-phone="${fn:toLowerCase(role.phone != null ? role.phone : '')}"
                       title="Nhân viên: ${role.fullName} | Gmail: ${role.email}">
                        <div class="flex items-center justify-between mb-1.5">
                            <div class="font-bold text-white text-xs group-hover:text-red-400 transition truncate mr-1">@${role.username}</div>
                            <time class="text-[9px] font-mono text-amber-400/90 bg-amber-500/5 px-1 rounded border border-amber-500/10 shrink-0">
                                ${fn:substring(fn:replace(role.roleUpdatedAt, 'T', ' '), 11, 16)}
                            </time>
                        </div>
                        <div class="text-[11px] text-gray-400 flex justify-between items-center">
                            <span class="text-xs text-gray-500">Quyền: <strong class="text-green-400 font-mono font-semibold">${role.roleName}</strong></span>
                            <c:choose>
                                <c:when test="${role.roleStatus == 'Active' || role.roleStatus == '1' || role.roleStatus == true}">
                                    <span class="text-[8px] bg-green-500/20 text-green-400 border border-green-500/30 px-1 rounded uppercase font-black scale-90 tracking-wide">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-[8px] bg-red-500/20 text-red-400 border border-red-500/30 px-1 rounded uppercase font-black scale-90 tracking-wide">Locked</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </a>
                </c:forEach>
                <c:if test="${empty roleAssignments}"><p class="text-xs text-gray-500 text-center py-4">Không tìm thấy dữ liệu.</p></c:if>
            </div>
        </div>

    </div>
</div>

<%-- KHU VỰC ĐỨNG RIÊNG: BIỂU ĐỒ CƠ SỞ VẬT CHẤT (ĐÃ TÁCH KHỎI GRID PHÂN QUYỀN) --%>
<div class="grid grid-cols-1 gap-6 mb-6">
    <%-- Biểu đồ rủi ro cơ sở vật chất --%>
    <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl p-5">
        <h3 class="text-white font-bold mb-4"><i class="fas fa-tools text-orange-400"></i> Trạng thái Cơ sở vật chất (Ghế)</h3>
        <div class="relative h-64 w-full">
            <canvas id="roomHealthChart"></canvas>
        </div>
    </div>
</div>
<%-- LUỒNG GIAO DỊCH LIVE (AJAX TABLE) --%>
<div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl p-5 relative">
    
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-4">
        <h3 class="text-white font-bold"><i class="fas fa-stream text-cyan-400"></i> Luồng Giao Dịch Đặt Vé (Live Stream)</h3>
        <div class="flex items-center gap-2 w-full sm:w-auto">
            <button onclick="toggleTxAdvancedFilter()" class="text-xs bg-blue-600/20 hover:bg-blue-600 text-blue-400 hover:text-white px-3 py-1.5 rounded-lg border border-blue-500/30 transition flex items-center gap-1">
                <i class="fas fa-filter text-[10px]"></i> Bộ lọc nâng cao <i id="txFilterIcon" class="fas fa-chevron-down text-[9px] transition-transform"></i>
            </button>
            <button onclick="loadLiveTransactions(1)" class="text-xs bg-gray-800 hover:bg-gray-700 text-white px-3 py-1.5 rounded-lg border border-gray-700 transition">
                <i class="fas fa-sync-alt mr-1"></i> Làm mới
            </button>
        </div>
    </div>
    
    <%-- Giao diện bộ lọc chứa các trường Input nâng cao --%>
    <div id="txAdvancedFilterBox" class="max-h-0 opacity-0 pointer-events-none transition-all duration-300 overflow-hidden grid grid-cols-1 md:grid-cols-5 gap-3 border-b border-gray-800/50 pb-4">
        <div>
            <label class="block text-[11px] text-gray-500 uppercase font-bold mb-1">Mã hóa đơn</label>
            <input type="text" id="filterTxId" oninput="validateAndLoadTransactions()" placeholder="Ví dụ: 1002" class="w-full bg-[#0b0c10] text-white placeholder-gray-600 border border-gray-800 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-cyan-500 transition">
        </div>
        <div>
            <label class="block text-[11px] text-gray-500 uppercase font-bold mb-1">Tên khách hàng</label>
            <input type="text" id="filterTxName" oninput="validateAndLoadTransactions()" placeholder="Tìm kiếm tên..." class="w-full bg-[#0b0c10] text-white placeholder-gray-600 border border-gray-800 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-cyan-500 transition">
        </div>
        <div>
            <label class="block text-[11px] text-gray-500 uppercase font-bold mb-1">Loại thanh toán</label>
            <%-- YÊU CẦU 1: Vòng lặp JSTL c:forEach duyệt danh sách 'paymentMethods' lấy động từ Database --%>
            <select id="filterTxMethod" onchange="validateAndLoadTransactions()" class="w-full bg-[#0b0c10] text-white border border-gray-800 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-cyan-500 transition">
                <option value="ALL">-- Tất cả loại --</option>
                <c:forEach items="${paymentMethods}" var="method">
                    <option value="${method}" ${txMethod eq method ? 'selected' : ''}>${method}</option>
                </c:forEach>
            </select>
        </div>
        <div>
            <label class="block text-[11px] text-gray-500 uppercase font-bold mb-1">Tổng tiền từ (VND)</label>
            <input type="text" id="filterTxMinPrice" oninput="validateAndLoadTransactions()" placeholder="0" class="w-full bg-[#0b0c10] text-white placeholder-gray-600 border border-gray-800 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-cyan-500 transition">
        </div>
        <div>
            <label class="block text-[11px] text-gray-500 uppercase font-bold mb-1">Đến giá (VND)</label>
            <input type="text" id="filterTxMaxPrice" oninput="validateAndLoadTransactions()" placeholder="500000" class="w-full bg-[#0b0c10] text-white placeholder-gray-600 border border-gray-800 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-cyan-500 transition">
        </div>
    </div>
    
    <div class="overflow-x-auto custom-scrollbar mt-3">
        <table class="w-full text-left text-sm text-gray-400">
            <thead class="text-xs text-gray-300 uppercase bg-[#0b0c10] border-y border-gray-800">
                <tr>
                    <th class="px-4 py-3">Mã Đơn</th>
                    <th class="px-4 py-3">Khách hàng</th>
                    <th class="px-4 py-3">Thời gian đặt</th>
                    <th class="px-4 py-3 text-right">Tổng tiền</th>
                    <th class="px-4 py-3 text-center">Thanh toán</th>
                    <th class="px-4 py-3 text-center">Trạng thái</th>
                </tr>
            </thead>
            <tbody id="live-transactions-body" class="divide-y divide-gray-800/50"></tbody>
        </table>
    </div>
    <div id="ajax-pagination" class="mt-4 flex justify-end gap-1"></div>
</div>

<%-- MODAL ĐIỀU HƯỚNG CHỨC NĂNG (GIỮ NGUYÊN) --%>
<div id="navigationChoiceModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 opacity-0 pointer-events-none transition-opacity duration-200">
    <div class="bg-[#1a1c23] border border-gray-800 rounded-xl w-full max-w-sm p-5 shadow-2xl transform scale-95 transition-transform duration-200">
        <div class="text-center mb-4">
            <div class="w-12 h-12 bg-blue-500/10 rounded-full flex items-center justify-center mx-auto mb-2 text-blue-500 text-xl">
                <i class="fas fa-sliders-h"></i>
            </div>
            <h4 class="text-white font-bold text-base" id="modalTitleInvoice">Xử lý hóa đơn</h4>
            <p class="text-xs text-gray-500 mt-1">Vui lòng lựa chọn màn hình chức năng bạn muốn xử lý điều hướng</p>
        </div>
        <div class="flex flex-col gap-2.5">
            <a id="btnGoToCustomer" href="#" class="w-full bg-[#0b0c10] hover:bg-blue-600/10 text-gray-300 hover:text-blue-400 border border-gray-800 hover:border-blue-500/50 font-semibold px-4 py-2.5 rounded-lg text-xs text-left flex items-center gap-3 transition">
                <i class="fas fa-user-edit text-sm w-5 text-center text-blue-500"></i>
                <div>
                    <div>Chỉnh sửa thông tin khách hàng</div>
                    <div class="text-[10px] text-gray-500 font-normal">Quản lý hồ sơ, phân quyền và trạng thái của khách hàng này</div>
                </div>
            </a>
            <a id="btnGoToShowtime" href="#" class="w-full bg-[#0b0c10] hover:bg-purple-600/10 text-gray-300 hover:text-purple-400 border border-gray-800 hover:border-purple-500/50 font-semibold px-4 py-2.5 rounded-lg text-xs text-left flex items-center gap-3 transition">
                <i class="fas fa-calendar-alt text-sm w-5 text-center text-purple-500"></i>
                <div>
                    <div>Chỉnh sửa thông tin suất chiếu</div>
                    <div class="text-[10px] text-gray-500 font-normal">Điều chỉnh phòng chiếu, thời gian xem phim của đơn hàng</div>
                </div>
            </a>
        </div>
        <div class="mt-4 pt-3 border-t border-gray-800/60 flex justify-end">
            <button onclick="closeNavigationModal()" class="text-xs bg-gray-800 hover:bg-gray-700 text-gray-400 hover:text-white px-4 py-1.5 rounded-lg transition font-medium">Hủy bỏ</button>
        </div>
    </div>
</div>

<%-- KHỐI JAVASCRIPT XỬ LÝ --%>
<script>
    // ---------------------------------------------------------
    // HÀM XỬ LÝ LỌC NHANH THỜI GIAN (GIỮ NGUYÊN)
    // ---------------------------------------------------------
    function formatDateYMD(date) {
        let d = new Date(date), month = '' + (d.getMonth() + 1), day = '' + d.getDate(), year = d.getFullYear();
        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;
        return [year, month, day].join('-');
    }

    function handleTimeQuickSelect(val) {
        const today = new Date();
        let start = new Date(today);
        let end = new Date(today);
        
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');
        
        if (!startDateInput || !endDateInput) return; 
        
        if (val === 'TODAY') {
            // Hôm nay giữ nguyên
        } else if (val === 'THIS_WEEK') {
            const first = today.getDate() - today.getDay() + 1;
            start = new Date(today.setDate(first));
            end = new Date(start);
            end.setDate(start.getDate() + 6);
        } else if (val === 'THIS_MONTH') {
            start = new Date(today.getFullYear(), today.getMonth(), 1);
            end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        } else if (val === 'THIS_YEAR') {
            start = new Date(today.getFullYear(), 0, 1);
            end = new Date(today.getFullYear(), 11, 31);
        } else {
            startDateInput.value = '';
            endDateInput.value = '';
            return;
        }
        
        startDateInput.value = formatDateYMD(start);
        endDateInput.value = formatDateYMD(end);
    }

    document.addEventListener("DOMContentLoaded", function() {
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');
        const quickSelectInput = document.getElementById('timeQuickSelect');
        
        if(startDateInput && quickSelectInput) {
            startDateInput.addEventListener('change', () => quickSelectInput.value = 'CUSTOM');
        }
        if(endDateInput && quickSelectInput) {
            endDateInput.addEventListener('change', () => quickSelectInput.value = 'CUSTOM');
        }
    });

    // ---------------------------------------------------------
    // LOGIC ẨN HIỆN & KHỞI TẠO CÁC CHART DỰ ÁN (GIỮ NGUYÊN KHÔNG ĐỔI)
    // ---------------------------------------------------------
    function toggleAccountDetails() {
        const div = document.getElementById('accountDetailsSection');
        if(div) div.classList.toggle('hidden');
    }

    const regLabels = []; const regData = [];
    <c:forEach var="item" items="${registrationStats}">
        regLabels.push('${item.label}'); regData.push(${empty item.value ? 0 : item.value});
    </c:forEach>

    const txTrendLabels = []; const txTrendData = [];
    <c:forEach var="item" items="${transactionTrend}">
        txTrendLabels.push('${item.label}'); txTrendData.push(${empty item.value ? 0 : item.value});
    </c:forEach>

    const roomLabels = []; const seatAvail = []; const seatMaint = [];
    <c:forEach var="room" items="${roomHealth}">
        roomLabels.push('${room.roomName}');
        seatAvail.push(${empty room.availableSeats ? 0 : room.availableSeats});
        seatMaint.push(${empty room.maintenanceSeats ? 0 : room.maintenanceSeats});
    </c:forEach>

    Chart.defaults.color = '#9ca3af';
    Chart.defaults.borderColor = 'rgba(75, 85, 99, 0.2)';

    if(document.getElementById('registrationChart')) {
        new Chart(document.getElementById('registrationChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: regLabels,
                datasets: [{ label: 'Tài khoản mới', data: regData, borderColor: '#3b82f6', backgroundColor: 'rgba(59, 130, 246, 0.1)', borderWidth: 2, fill: true, tension: 0.4 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
        });
    }

    if(document.getElementById('transactionTrendChart')) {
        new Chart(document.getElementById('transactionTrendChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: txTrendLabels,
                datasets: [{ label: 'Số lượng giao dịch', data: txTrendData, borderColor: '#a855f7', backgroundColor: 'rgba(168, 85, 247, 0.1)', borderWidth: 2, fill: true, tension: 0.4 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
        });
    }

    if(document.getElementById('roomHealthChart')) {
        new Chart(document.getElementById('roomHealthChart').getContext('2d'), {
            type: 'bar',
            data: {
                labels: roomLabels,
                datasets: [
                    { label: 'Đang bảo trì', data: seatMaint, backgroundColor: '#f59e0b' },
                    { label: 'Sẵn sàng', data: seatAvail, backgroundColor: '#10b981' }
                ]
            },
            options: { responsive: true, maintainAspectRatio: false, scales: { x: { stacked: true }, y: { stacked: true } } }
        });
    }

    // ---------------------------------------------------------
    // AJAX CẬP NHẬT LIVE STREAM ĐỒNG BỘ VALIDATION NÂNG CAO
    // ---------------------------------------------------------
    const API_URL = '${pageContext.request.contextPath}/admin/monitoring/api/transactions';
    let currentLivePage = 1;
    const pageSize = 8;
    
    function getStartDate() { const el = document.getElementById('startDate'); return el ? el.value : ''; }
    function getEndDate() { const el = document.getElementById('endDate'); return el ? el.value : ''; }
    function formatCurrency(amount) { return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount || 0); }
    
    function formatDate(dateString) { 
        if(!dateString) return ''; 
        const d = new Date(dateString); 
        return d.toLocaleDateString('vi-VN') + ' ' + d.toLocaleTimeString('vi-VN'); 
    }
    
    function getStatusBadge(status) {
        if(status === 'Completed' || status === 'COMPLETED') return '<span class="bg-green-500/20 text-green-500 border border-green-500/30 px-2 py-0.5 rounded text-[10px] uppercase font-bold">Hoàn tất</span>';
        if(status === 'Pending' || status === 'PENDING') return '<span class="bg-yellow-500/20 text-yellow-500 border border-yellow-500/30 px-2 py-0.5 rounded text-[10px] uppercase font-bold">Đang chờ</span>';
        return '<span class="bg-red-500/20 text-red-500 border border-red-500/30 px-2 py-0.5 rounded text-[10px] uppercase font-bold">' + (status || 'HỦY') + '</span>';
    }
    // Hàm hiển thị lỗi thủ công lên khung cảnh báo đỏ màu đẹp mắt
    function displayInputError(message) {
        const errorBox = document.getElementById("txValidationErrorBox");
        const errorMsg = document.getElementById("txValidationErrorMessage");
        if(errorBox && errorMsg) {
            errorMsg.innerText = message;
            errorBox.classList.remove("hidden");
        }
    }
    // Hàm ẩn/hiện bộ lọc nâng cao của Live Stream
    function toggleTxAdvancedFilter() {
        const box = document.getElementById("txAdvancedFilterBox");
        const icon = document.getElementById("txFilterIcon");
        if (!box) return;
        if (box.classList.contains("max-h-0")) {
            box.classList.remove("max-h-0", "opacity-0", "pointer-events-none");
            box.classList.add("max-h-[200px]", "opacity-100", "py-3", "mb-4");
            if (icon) icon.classList.add("rotate-180");
        } else {
            box.classList.add("max-h-0", "opacity-0", "pointer-events-none");
            box.classList.remove("max-h-[200px]", "opacity-100", "py-3", "mb-4");
            if (icon) icon.classList.remove("rotate-180");
        }
    }

    // YÊU CẦU 2: Hàm đánh chặn dữ liệu lỗi ngay tại Frontend (Ký tự đặc biệt, số, giá trị âm)
    function validateAndLoadTransactions() {
        const errorBox = document.getElementById("txValidationErrorBox");
        
        const txName = document.getElementById("filterTxName") ? document.getElementById("filterTxName").value.trim() : "";
        const txMinPrice = document.getElementById("filterTxMinPrice") ? document.getElementById("filterTxMinPrice").value.trim() : "";
        const txMaxPrice = document.getElementById("filterTxMaxPrice") ? document.getElementById("filterTxMaxPrice").value.trim() : "";

        // Regex Tiếng Việt chuẩn hóa 100% không cho chứa số hoặc ký tự lạ kì
        const vietnameseRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲÝỴÝỳýỵỷỹ\s]+$/;

        // 1. Kiểm tra giá trị nhập vào ô tiền
        if (txMinPrice !== "") {
            if (isNaN(txMinPrice) || parseFloat(txMinPrice) < 0) {
                displayInputError("Giá trị 'Tổng tiền từ' không được phép âm và phải nhập chữ số hợp lệ!");
                return;
            }
        }
        if (txMaxPrice !== "") {
            if (isNaN(txMaxPrice) || parseFloat(txMaxPrice) < 0) {
                displayInputError("Giá trị 'Đến giá' không được phép âm và phải nhập chữ số hợp lệ!");
                return;
            }
        }
        if (txMinPrice !== "" && txMaxPrice !== "" && parseFloat(txMinPrice) > parseFloat(txMaxPrice)) {
            displayInputError("'Tổng tiền từ' không được vượt quá mức giá tối đa 'Đến giá'!");
            return;
        }

        // 2. Kiểm tra ô Tên không cho phép số/ký tự đặc biệt
        if (txName !== "" && !vietnameseRegex.test(txName)) {
            displayInputError("Tên khách hàng không hợp lệ! Vui lòng không nhập chữ số hoặc ký tự đặc biệt.");
            return;
        }

        // Nếu tất cả hợp lệ -> Ẩn hộp báo lỗi đi và đẩy lệnh AJAX chạy lên server
        if(errorBox) errorBox.classList.add("hidden");
        loadLiveTransactions(1);
    }

    // Hàm gọi API đồng bộ dữ liệu với Controller bằng Fetch API
    function loadLiveTransactions(page) {
        currentLivePage = page;
        const tbody = document.getElementById('live-transactions-body');
        const errorBox = document.getElementById("txValidationErrorBox");
        if(!tbody) return;
        
        tbody.style.opacity = '0.5';
        
        const sDate = getStartDate();
        const eDate = getEndDate();
        
        const txId = document.getElementById("filterTxId") ? document.getElementById("filterTxId").value.trim() : "";
        const txName = document.getElementById("filterTxName") ? document.getElementById("filterTxName").value.trim() : "";
        const txMethod = document.getElementById("filterTxMethod") ? document.getElementById("filterTxMethod").value : "ALL";
        const txMinPrice = document.getElementById("filterTxMinPrice") ? document.getElementById("filterTxMinPrice").value.trim() : "";
        const txMaxPrice = document.getElementById("filterTxMaxPrice") ? document.getElementById("filterTxMaxPrice").value.trim() : "";

        let url = API_URL + "?page=" + page + "&size=" + pageSize;
        if(sDate) url += "&startDate=" + encodeURIComponent(sDate);
        if(eDate) url += "&endDate=" + encodeURIComponent(eDate);
        if(txId) url += "&txId=" + encodeURIComponent(txId);
        if(txName) url += "&txName=" + encodeURIComponent(txName);
        if(txMethod) url += "&txMethod=" + encodeURIComponent(txMethod);
        if(txMinPrice) url += "&txMinPrice=" + encodeURIComponent(txMinPrice);
        if(txMaxPrice) url += "&txMaxPrice=" + encodeURIComponent(txMaxPrice);

        fetch(url)
            .then(response => response.json())
            .then(result => {
                // KIỂM TRA LỖI NÉM TỪ SERVER CONTROLLER
                if (result.error) {
                    displayInputError(result.error);
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center py-8 text-red-500 text-xs"><i class="fas fa-exclamation-circle text-lg mb-2 block"></i> Dữ liệu lọc không đúng yêu cầu của máy chủ.</td></tr>';
                    renderPagination(1, 0);
                    tbody.style.opacity = '1';
                    return;
                }

                if(errorBox) errorBox.classList.add("hidden");
                tbody.innerHTML = '';
                
                if(result.data && result.data.length > 0) {
                    result.data.forEach(tx => {
                        const tr = document.createElement('tr');
                        tr.className = 'hover:bg-blue-600/10 cursor-pointer transition duration-150';
                        
                        tr.addEventListener('click', () => {
                            openNavigationModal(tx.id_Booking, tx.id_User, tx.id_Showtime);
                        });

                        // Giải quyết triệt để lỗi xung đột JSTL EL bằng ghép chuỗi chuẩn Javascript thuần
                        tr.innerHTML = 
                            '<td class="px-4 py-3 font-mono text-white font-medium text-xs">#BK' + (tx.id_Booking || '') + '</td>' +
                            '<td class="px-4 py-3">' +
                                '<div class="text-white font-semibold text-xs">' + (tx.customerName || 'Khách vãng lai') + '</div>' +
                                '<div class="text-[10px] text-gray-500">@' + (tx.username || 'guest') + '</div>' +
                            '</td>' +
                            '<td class="px-4 py-3 text-xs text-gray-400">' + formatDate(tx.bookingDate) + '</td>' +
                            '<td class="px-4 py-3 text-right font-bold text-amber-400 text-xs">' + formatCurrency(tx.totalAmount) + '</td>' +
                            '<td class="px-4 py-3 text-center text-xs"><span class="bg-gray-800 text-gray-300 px-2 py-0.5 rounded border border-gray-700 font-mono">' + (tx.paymentMethod || 'N/A') + '</span></td>' +
                            '<td class="px-4 py-3 text-center">' + getStatusBadge(tx.status) + '</td>';
                        tbody.appendChild(tr);
                    });
                } else {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center py-8 text-gray-500 text-xs"><i class="fas fa-inbox text-lg mb-2 block text-gray-700"></i> Không tìm thấy giao dịch nào khớp với bộ lọc kết hợp hiện tại.</td></tr>';
                }
                renderPagination(result.currentPage, result.totalPages);
                tbody.style.opacity = '1';
            })
            .catch(error => { 
                console.error("Lỗi sập luồng mạng dữ liệu:", error);
                tbody.innerHTML = '<tr><td colspan="6" class="text-center py-5 text-red-500 text-xs">Không thể kết nối máy chủ để tải dữ liệu. Vui lòng thử lại.</td></tr>';
                tbody.style.opacity = '1'; 
            });
    }
    function renderPagination(currentPage, totalPages) {
        const paginator = document.getElementById('ajax-pagination');
        if(!paginator) return;
        paginator.innerHTML = '';
        if (totalPages <= 1) return;
        
        if (currentPage > 1) {
            paginator.innerHTML += '<button onclick="loadLiveTransactions(' + (currentPage - 1) + ')" class="w-8 h-8 flex items-center justify-center rounded-lg bg-[#0b0c10] border border-gray-700 text-gray-400 hover:text-white hover:border-blue-500 transition"><i class="fas fa-chevron-left text-xs"></i></button>';
        }
        
        let start = Math.max(1, currentPage - 2); 
        let end = Math.min(totalPages, currentPage + 2);
        
        for (let i = start; i <= end; i++) {
            if (i === currentPage) {
                paginator.innerHTML += '<button class="w-8 h-8 flex items-center justify-center rounded-lg bg-blue-600 text-white font-bold border border-blue-500 shadow-[0_0_10px_rgba(37,99,235,0.4)] transition">' + i + '</button>';
            } else {
                paginator.innerHTML += '<button onclick="loadLiveTransactions(' + i + ')" class="w-8 h-8 flex items-center justify-center rounded-lg bg-[#0b0c10] border border-gray-700 text-gray-400 hover:text-white hover:border-blue-500 transition">' + i + '</button>';
            }
        }
        
        if (currentPage < totalPages) {
            paginator.innerHTML += '<button onclick="loadLiveTransactions(' + (currentPage + 1) + ')" class="w-8 h-8 flex items-center justify-center rounded-lg bg-[#0b0c10] border border-gray-700 text-gray-400 hover:text-white hover:border-blue-500 transition"><i class="fas fa-chevron-right text-xs"></i></button>';
        }
    }

    function openNavigationModal(idBooking, idUser, idShowtime) {
        const modal = document.getElementById("navigationChoiceModal");
        const title = document.getElementById("modalTitleInvoice");
        const btnCustomer = document.getElementById("btnGoToCustomer");
        const btnShowtime = document.getElementById("btnGoToShowtime");
        
        if(!modal) return;
        if(title) title.innerText = "Xử lý hóa đơn #BK" + idBooking;
        
        if(idUser) {
            btnCustomer.href = "${pageContext.request.contextPath}/admin/customers/detail/" + idUser;
            btnCustomer.classList.remove("opacity-40", "pointer-events-none");
        } else {
            btnCustomer.href = "#";
            btnCustomer.classList.add("opacity-40", "pointer-events-none");
        }
        
        if(idShowtime) {
            btnShowtime.href = "${pageContext.request.contextPath}/admin/showtimes/edit/" + idShowtime;
            btnShowtime.classList.remove("opacity-40", "pointer-events-none");
        } else {
            btnShowtime.href = "#";
            btnShowtime.classList.add("opacity-40", "pointer-events-none");
        }
        
        modal.classList.remove("opacity-0", "pointer-events-none");
        modal.children[0].classList.remove("scale-95");
        modal.children[0].classList.add("scale-100");
    }

    function closeNavigationModal() {
        const modal = document.getElementById("navigationChoiceModal");
        if(!modal) return;
        modal.classList.add("opacity-0", "pointer-events-none");
        modal.children[0].classList.remove("scale-100");
        modal.children[0].classList.add("scale-95");
    }

    document.addEventListener("DOMContentLoaded", function() {
        loadLiveTransactions(1);
        // Tự động quét cập nhật sau mỗi 30 giây nếu đang ở trang 1
        setInterval(() => { if(currentLivePage === 1) loadLiveTransactions(1); }, 30000);

        // Đóng modal khi click ra ngoài vùng xám đen
        const modal = document.getElementById("navigationChoiceModal");
        if(modal) {
            modal.addEventListener("click", function(e) {
                if(e.target === modal) closeNavigationModal();
            });
        }
    });

    // ---------------------------------------------------------
    // BỘ LỌC CỤC BỘ KHÁCH HÀNG/NHÂN VIÊN (GIỮ NGUYÊN)
    // ---------------------------------------------------------
    function executeLocalFilter() {
        const nameEl = document.getElementById("localSearchName");
        const emailEl = document.getElementById("localSearchEmail");
        const phoneEl = document.getElementById("localSearchPhone");
        
        const nameKey = nameEl ? nameEl.value.toLowerCase().trim() : "";
        const emailKey = emailEl ? emailEl.value.toLowerCase().trim() : "";
        const phoneKey = phoneEl ? phoneEl.value.toLowerCase().trim() : "";
        
        const filterItems = document.querySelectorAll(".local-filter-item");
        
        filterItems.forEach(function(item) {
            const targetName = (item.getAttribute("data-name") || "").toLowerCase();
            const targetEmail = (item.getAttribute("data-email") || "").toLowerCase();
            const targetPhone = (item.getAttribute("data-phone") || "").toLowerCase();
            
            const matchName = nameKey === "" || targetName.includes(nameKey);
            const matchEmail = emailKey === "" || targetEmail.includes(emailKey);
            const matchPhone = phoneKey === "" || targetPhone.includes(phoneKey);
            
            if (matchName && matchEmail && matchPhone) {
                item.classList.remove("hidden-item");
                setTimeout(() => { item.style.display = "flex"; }, 50);
            } else {
                item.classList.add("hidden-item");
                setTimeout(() => { if(item.classList.contains("hidden-item")) item.style.display = "none"; }, 400);
            }
        });
    }

    function toggleTxAdvancedFilter() {
        const filterBox = document.getElementById("txAdvancedFilterBox");
        const filterIcon = document.getElementById("txFilterIcon");
        if(!filterBox) return;
        
        if(filterBox.classList.contains("max-h-0")) {
            filterBox.classList.remove("max-h-0", "opacity-0", "pointer-events-none");
            filterBox.classList.add("max-h-[300px]", "opacity-100", "pt-2");
            if(filterIcon) filterIcon.classList.add("rotate-180");
        } else {
            filterBox.classList.add("max-h-0", "opacity-0", "pointer-events-none");
            filterBox.classList.remove("max-h-[300px]", "opacity-100", "pt-2");
            if(filterIcon) filterIcon.classList.remove("rotate-180");
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        // Tải danh sách lần đầu khi vừa mở trang
        loadLiveTransactions(1);
        
        // Tự động làm mới dữ liệu sau mỗi 30 giây
        setInterval(() => { if(currentLivePage === 1) loadLiveTransactions(1); }, 30000);

        const modal = document.getElementById("navigationChoiceModal");
        if(modal) {
            modal.addEventListener("click", function(e) {
                if(e.target === modal) closeNavigationModal();
            });
        }
    });
</script>