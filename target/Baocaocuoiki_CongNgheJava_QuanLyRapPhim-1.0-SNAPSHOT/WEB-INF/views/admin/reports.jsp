<%-- views/admin/reports.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<style>
    /* Làm đẹp thanh cuộn cho class custom-scrollbar */
    .custom-scrollbar::-webkit-scrollbar {
        width: 8px; /* Chiều rộng thanh cuộn dọc */
        height: 8px; /* Chiều cao thanh cuộn ngang */
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: #1a1c23; /* Màu nền của rãnh cuộn (tiệp màu card) */
        border-radius: 8px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #374151; /* Màu của thanh cuộn (gray-700) */
        border-radius: 8px;
        border: 2px solid #1a1c23; /* Tạo khoảng hở tinh tế */
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: #ea580c; /* Màu cam khi di chuột vào (orange-600) */
    }
    @media print {
    /* 1. THIẾT LẬP LỀ VÀ KHỔ GIẤY */
    @page {
        size: A4 landscape;
        margin: 1.5cm;
    }

    /* 2. CHUYỂN NỀN TRẮNG & ĐỔI MÀU CHỮ SANG ĐEN TUYỀN */
    html, body, main, section, article {
        background: #ffffff !important;
        background-color: #ffffff !important;
        color: #000000 !important;
    }

    /* ÉP TẤT CẢ CÁC LOẠI TIÊU ĐỀ VÀ ĐOẠN VĂN THÀNH MÀU ĐEN ĐẬM */
    h1, h2, h3, h4, h5, h6, p, span, a, label, strong, th, td, div {
        color: #000000 !important; /* Đen tuyệt đối */
        text-shadow: none !important;
    }

    /* LÀM CHỮ TIÊU ĐỀ CỰC ĐẬM */
    h1, h2, h3, h4 {
        font-weight: 900 !important; 
    }

    /* Nhuộm đen tất cả các class màu chữ sáng của Tailwind */
    .text-white, .text-gray-100, .text-gray-200, .text-gray-300, .text-gray-400, .text-gray-500 {
        color: #000000 !important;
    }

    /* 3. LÀM NỔI BẬT KHUNG CHỨA BIỂU ĐỒ (GLASS-CARD) TRÊN NỀN TRẮNG */
    .glass-card, [class*="bg-[#1a1c23]"], [class*="bg-[#161616]"] {
        background: #f8fafc !important; 
        background-color: #f8fafc !important;
        border: 2px solid #333333 !important; /* ĐỔI THÀNH VIỀN XÁM ĐEN DÀY 2PX */
        border-radius: 8px !important;
        box-shadow: none !important;
        padding: 20px !important;
        margin-bottom: 35px !important;
        page-break-inside: avoid !important;
        break-inside: avoid !important;
    }

    /* 4. SỬA LỖI ĐÈ CHỮ & TRÀN TRANG */
    div, section, article, .glass-card, [class*="h-"], [class*="max-h-"] {
        height: auto !important;
        max-height: none !important;
        min-height: 0 !important;
        position: relative !important;
    }

    .grid, .flex {
        display: block !important;
        width: 100% !important;
    }

    /* RESET LẠI KHOẢNG TRỐNG DO MẢNG ĐEN (SIDEBAR) ĐỂ LẠI */
    .flex-1, #main-container, .main-content {
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
    }

    /* 5. CĂN CHỈNH BIỂU ĐỒ (CANVAS) GỌN GÀNG CHÍNH GIỮA */
    canvas {
        display: block !important;
        max-width: 65% !important;   
        max-height: 280px !important;  
        margin: 20px auto !important;  
        page-break-inside: avoid !important;
        break-inside: avoid !important;
    }

    /* 6. ĐỊNH DẠNG BẢNG DANH SÁCH (TABLE) - VIỀN SIÊU ĐẬM, CHỮ RÕ NÉT */
    table {
        border-collapse: collapse !important;
        width: 100% !important;
        margin-top: 15px !important;
        margin-bottom: 35px !important;
        table-layout: auto !important;
        background: #ffffff !important;
        border: 2px solid #000000 !important; /* BAO QUANH BẢNG LÀ VIỀN ĐEN DÀY */
    }

    /* Kẻ viền đen dày cho từng ô dữ liệu */
    th, td {
        border: 1px solid #000000 !important; /* ĐỔI SANG MÀU ĐEN THUI */
        padding: 8px 12px !important;
        text-align: left !important;
        white-space: normal !important;
        word-break: break-word !important;
        font-weight: 600 !important; /* ÉP CHỮ TRONG BẢNG ĐẬM LÊN */
    }

    th {
        background-color: #e2e8f0 !important; 
        color: #000000 !important;
        font-weight: 800 !important; /* TIÊU ĐỀ CỘT CỰC ĐẬM */
        border-bottom: 2px solid #000000 !important; /* Gạch dưới tiêu đề cột dày hơn */
    }

    td {
        background-color: #ffffff !important;
        color: #000000 !important;
    }

    thead { display: table-header-group !important; }
    tr { page-break-inside: avoid !important; break-inside: avoid !important; }

    h1, h2, h3, h4 {
        page-break-after: avoid !important;
        break-after: avoid !important;
        margin-top: 25px !important;
        margin-bottom: 12px !important;
    }

    /* 7. MỞ BUNG THANH CUỘN (SCROLLBAR) */
    .overflow-x-auto, .overflow-y-auto, .max-h-\[400px\], .custom-scrollbar {
        overflow: visible !important;
        max-height: none !important;
        height: auto !important;
    }

    /* 8. ẨN NÚT BẤM, MENU SIDEBAR, CỤC ĐEN (QUAN TRỌNG) */
    button, form, .no-print, nav, aside, header, footer, .sidebar, #sidebar, .btn {
        display: none !important;
    }

    /* 9. Bắt buộc giữ màu cho các cột/đường nét của biểu đồ Chart.js */
    * {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
        color-adjust: exact !important;
    }

    /* 10. THÊM MỚI: CHUYÊN TRỊ CÁC NHÃN BỘ LỌC, LOẠI PHÒNG BỊ ĐEN/XÁM */
    /* Ép tất cả các thẻ span nhỏ, badge, nhãn trong bảng chuyển về nền trắng, chữ đen, viền rõ ràng */
    td span, th span, 
    [class*="px-"][class*="py-"][class*="rounded"], 
    .badge, .tag, .filter-item {
        background: #ffffff !important;
        background-color: #ffffff !important;
        color: #000000 !important;
        border: 1px solid #000000 !important; /* Tạo viền đen bao quanh thay vì khối màu tối */
        padding: 2px 6px !important;
        border-radius: 4px !important;
        font-weight: 700 !important; /* Chữ đen đậm rõ nét */
        box-shadow: none !important;
    }
}



</style>

<div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
    <div>
        <h2 class="text-xl font-black text-white uppercase tracking-wider"><i class="fa-solid fa-chart-line text-blue-500 mr-2"></i> Báo Cáo Phân Tích</h2>
        <p class="text-xs text-gray-400">Hệ thống giám sát doanh thu và hiệu suất rạp chiếu</p>
    </div>
    <div class="flex gap-2 no-print">
        <button type="button" onclick="openExportModal()" class="bg-green-600 hover:bg-green-700 text-white px-3 py-1.5 rounded-lg text-sm font-bold transition shadow-lg flex items-center gap-1.5">
            <i class="fa-solid fa-file-excel"></i> Xuất Excel
        </button>
        <button type="button" onclick="window.print()" class="bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg text-sm font-bold transition shadow-lg flex items-center gap-1.5"><i class="fa-solid fa-file-pdf"></i> In PDF</button>
    </div>
</div>

<c:if test="${not empty errorMessage}">
    <div class="bg-red-900/30 border border-red-500/40 rounded-xl p-4 mb-6 text-xs text-red-400 flex items-center">
        <i class="fas fa-exclamation-triangle text-base mr-3"></i> ${errorMessage}
    </div>
</c:if>

<form id="filterForm" method="GET" action="${pageContext.request.contextPath}/admin/reports" class="glass-card border border-gray-800 rounded-2xl p-5 mb-6 shadow-lg bg-[#1a1c23]">
    <input type="hidden" name="page" id="pageInput" value="${not empty currentPage ? currentPage : 1}">
    <input type="hidden" name="sortBy" id="sortByInput" value="${sortBy}">
    <input type="hidden" name="sortDir" id="sortDirInput" value="${sortDir}">

    <div class="grid grid-cols-1 md:grid-cols-6 gap-4 items-end">
        <div class="md:col-span-1">
            <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Lọc Nhanh</label>
            <select class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none" id="timeQuickSelect" onchange="handleTimeQuickSelect(this.value)">
                <option value="CUSTOM">Tùy chọn...</option>
                <option value="TODAY">Hôm nay</option>
                <option value="THIS_WEEK">Tuần này</option>
                <option value="THIS_MONTH">Tháng này</option>
                <option value="THIS_YEAR">Năm nay</option>
            </select>
        </div>
        <div class="md:col-span-1">
            <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Từ ngày</label>
            <input type="date" name="startDate" id="startDate" value="${startDate}" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
        </div>
        <div class="md:col-span-1">
            <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Đến ngày</label>
            <input type="date" name="endDate" id="endDate" value="${endDate}" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
        </div>
        <div class="md:col-span-2">
            <label class="block text-xs font-bold text-gray-400 mb-1 uppercase tracking-wider">Chế độ xem</label>
            <select name="groupByOption" id="groupByOption" class="w-full bg-[#161616] text-white border border-gray-700 rounded-lg p-2.5 text-sm font-bold focus:border-blue-500 transition outline-none">
                <option value="DAY" ${groupByOption == 'DAY' ? 'selected' : ''}>Nhóm theo Ngày</option>
                <option value="MONTH" ${groupByOption == 'MONTH' ? 'selected' : ''}>Nhóm theo Tháng</option>
                <option value="YEAR" ${groupByOption == 'YEAR' ? 'selected' : ''}>Nhóm theo Năm</option>
            </select>
        </div>
        <div class="md:col-span-1">
            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white p-2.5 rounded-lg text-sm font-bold transition shadow-lg uppercase tracking-wider flex items-center justify-center gap-1.5">
                <i class="fa-solid fa-filter"></i> Lọc
            </button>
        </div>
    </div>
</form>

<div class="mb-8">
    <h3 class="text-lg font-bold text-white mb-4 uppercase tracking-wider border-b border-gray-700 pb-2"><i class="fa-solid fa-globe text-blue-500 mr-2"></i> Phần 1: Chỉ Số Tổng Quát</h3>

    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow transition-all hover:-translate-y-1">
            <div>
                <p class="text-[11px] font-bold text-gray-500 uppercase tracking-wider">Tổng Doanh Thu</p>
                <h3 class="text-2xl font-bold text-white mt-1"><fmt:formatNumber value="${not empty kpis.totalRevenue ? kpis.totalRevenue : 0}" pattern="#,###"/> ₫</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-blue-500/10 text-blue-500 flex items-center justify-center text-xl shadow-inner"><i class="fa-solid fa-sack-dollar"></i></div>
        </div>
        <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow transition-all hover:-translate-y-1">
            <div>
                <p class="text-[11px] font-bold text-gray-500 uppercase tracking-wider">Tổng Vé Đã Bán</p>
                <h3 class="text-2xl font-bold text-white mt-1"><fmt:formatNumber value="${not empty kpis.totalTickets ? kpis.totalTickets : 0}" pattern="#,###"/> Vé</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-green-500/10 text-green-500 flex items-center justify-center text-xl shadow-inner"><i class="fa-solid fa-ticket-alt"></i></div>
        </div>
        <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow transition-all hover:-translate-y-1">
            <div>
                <p class="text-[11px] font-bold text-gray-500 uppercase tracking-wider">Tỷ Lệ Lấp Đầy Hệ Thống</p>
                <h3 class="text-2xl font-bold text-yellow-400 mt-1"><fmt:formatNumber value="${not empty kpis.occupancyRate ? kpis.occupancyRate : 0}" pattern="#,##0.0"/> %</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-yellow-500/10 text-yellow-500 flex items-center justify-center text-xl shadow-inner"><i class="fa-solid fa-users-viewfinder"></i></div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow">
            <h6 class="font-bold text-white text-xs uppercase tracking-wider mb-4"><i class="fa-solid fa-chart-line text-blue-500 mr-2"></i> Tổng Doanh Thu Theo Thời Gian</h6>
            <div class="relative h-[300px] w-full"><canvas id="revenueLineChart"></canvas></div>
        </div>
        <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow">
            <h6 class="font-bold text-white text-xs uppercase tracking-wider mb-4"><i class="fa-solid fa-chart-bar text-green-500 mr-2"></i> Lượng Vé Đã Bán</h6>
            <div class="relative h-[300px] w-full"><canvas id="ticketsBarChart"></canvas></div>
        </div>
    </div>
</div>

<div class="mb-8">
    <div class="flex justify-between items-center mb-4 border-b border-gray-700 pb-2">
        <h3 class="text-lg font-bold text-white uppercase tracking-wider">
            <i class="fa-solid fa-film text-purple-500 mr-2"></i> Phần 2: Phân Tích & Biến Động Doanh Thu Phim
        </h3>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-4">
        <div class="lg:col-span-1 glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow">
            <h6 class="font-bold text-white text-xs uppercase tracking-wider mb-4">Tỷ Trọng Doanh Thu Phim</h6>
            <div class="relative h-[250px] w-full"><canvas id="moviePieChart"></canvas></div>
        </div>

        <div class="lg:col-span-2 glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow flex flex-col justify-center">
            <div class="flex justify-between items-center mb-4">
                <h6 class="font-bold text-white text-xs uppercase tracking-wider">Top Phim Doanh Thu Cao Nhất</h6>
                <button type="button" class="border border-purple-500 text-purple-500 hover:bg-purple-600 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1" onclick="toggleSection('movieTableSection', this, 'purple')">
                    <i class="fa-solid fa-eye"></i> Xem Chi Tiết & Biểu Đồ
                </button>
            </div>
            <div class="space-y-3">
                <c:forEach items="${movieRevenueList}" var="m" begin="0" end="2">
                    <div class="flex items-center justify-between bg-[#161616] p-3 rounded-lg border border-gray-800">
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded bg-purple-500/20 text-purple-400 flex justify-center items-center font-bold text-xs">#${m.id_Movie}</div>
                            <span class="text-sm font-bold text-white">${m.title}</span>
                        </div>
                        <span class="text-sm font-bold text-red-400"><fmt:formatNumber value="${m.totalRevenue}" pattern="#,###"/> ₫</span>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <div id="movieTableSection" class="hidden transition-all duration-300">

        <div class="bg-[#1a1c23] border border-gray-800 p-4 rounded-xl mb-4 flex flex-wrap items-end gap-4 shadow-lg mt-2">
            <div class="flex-1 min-w-[200px]">
                <label class="block text-xs font-bold text-gray-400 mb-1">Tìm Tên Phim</label>
                <input type="text" id="filterMovieName" placeholder="Nhập tên phim..." class="w-full bg-[#161616] border border-gray-700 text-white text-sm rounded-lg p-2 focus:border-purple-500 focus:ring-1 focus:ring-purple-500 outline-none">
            </div>
            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1">Doanh thu từ (VNĐ)</label>
                <input type="number" id="filterMinRev" placeholder="0" class="w-full bg-[#161616] border border-gray-700 text-white text-sm rounded-lg p-2 focus:border-purple-500 outline-none">
            </div>
            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1">Đến (VNĐ)</label>
                <input type="number" id="filterMaxRev" placeholder="Không giới hạn" class="w-full bg-[#161616] border border-gray-700 text-white text-sm rounded-lg p-2 focus:border-purple-500 outline-none">
            </div>
            <button type="button" onclick="applyMovieFilter()" class="bg-purple-600 text-white hover:bg-purple-700 px-4 py-2 rounded-lg text-sm font-bold transition shadow-lg flex items-center gap-2">
                <i class="fa-solid fa-filter"></i> Lọc Phim
            </button>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-4">
            <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl flex flex-col h-[400px]">
                <div class="p-4 border-b border-gray-800 bg-[#161616] rounded-t-2xl">
                    <h6 class="font-bold text-white text-xs uppercase tracking-wider">Danh Sách Phim Chi Tiết</h6>
                </div>
                <div class="p-4 overflow-y-auto overflow-x-auto custom-scrollbar flex-1">
                    <table class="w-full text-left border-collapse text-xs whitespace-nowrap" id="movieTable">
                        <thead>
                            <tr class="bg-gray-800/50 text-gray-400 font-bold uppercase tracking-wider">
                                <th class="py-3 px-3">Mã</th>
                                <th class="py-3 px-3">Tên Phim</th>
                                <th class="py-3 px-3 text-center">Số Vé</th>
                                <th class="py-3 px-3 text-right">Vé Cơ Bản</th>
                                <th class="py-3 px-3 text-right text-purple-400">Tổng Thu</th>
                                <th class="py-3 px-3 text-center">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-800/40" id="movieTableBody">
                            <c:forEach items="${movieRevenueList}" var="m">
                                <tr class="hover:bg-white/5 transition text-gray-300 movie-row" data-name="${fn:toLowerCase(m.title)}" data-revenue="${m.totalRevenue}">
                                    <td class="py-3 px-3 font-mono">#${m.id_Movie}</td>
                                    <td class="py-3 px-3 font-bold text-white max-w-[120px] truncate" title="${m.title}">${m.title}</td>
                                    <td class="py-3 px-3 text-center">${m.ticketsSold}</td>
                                    <td class="py-3 px-3 text-right"><fmt:formatNumber value="${m.totalBaseRevenue}" pattern="#,###"/> ₫</td>
                                    <td class="py-3 px-3 text-right font-bold text-red-500"><fmt:formatNumber value="${m.totalRevenue}" pattern="#,###"/> ₫</td>
                                    <td class="py-3 px-3 flex justify-center items-center gap-2">
                                        <button type="button" onclick="loadMovieDailyChart(${m.id_Movie}, '${fn:escapeXml(m.title)}')" class="bg-purple-600/20 text-purple-400 hover:bg-purple-600 hover:text-white px-2 py-1 rounded text-[10px] font-bold transition" title="Xem biểu đồ doanh thu">
                                            <i class="fa-solid fa-chart-line"></i> Biểu đồ
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${m.id_Movie}" class="bg-blue-600/20 text-blue-400 hover:bg-blue-600 hover:text-white px-2 py-1 rounded text-[10px] font-bold transition flex items-center gap-1" title="Xem chi tiết phim">
                                            <i class="fa-solid fa-info-circle"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl h-[400px] flex flex-col">
                <h6 id="movieChartTitle" class="font-bold text-white text-xs uppercase tracking-wider mb-1">Biến Động Doanh Thu Phim Theo Ngày</h6>
                <p class="text-[10px] text-gray-400 mb-4 italic">Vui lòng chọn "Xem" tại một phim bên bảng để hiển thị dữ liệu.</p>
                <div class="relative w-full flex-1"><canvas id="movieDailyLineChart"></canvas></div>
            </div>
        </div>
    </div>
</div>
<div class="mb-8">
    <div class="flex justify-between items-center mb-4 border-b border-gray-700 pb-2">
        <h3 class="text-lg font-bold text-white uppercase tracking-wider"><i class="fa-solid fa-clock text-orange-500 mr-2"></i> Phần 3: Hiệu Suất Suất Chiếu</h3>
        <button type="button" class="bg-orange-600 text-white hover:bg-orange-700 px-3 py-1.5 rounded-lg text-xs font-bold transition shadow-lg flex items-center gap-1.5" onclick="toggleSection('showtimeTableSection', this, 'orange')">
            <i class="fa-solid fa-eye"></i> Xem Dữ Liệu
        </button>
    </div>

    <div id="showtimeTableSection" class="hidden glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl overflow-hidden shadow-lg transition-all duration-300 mb-4">
        <div class="p-4 overflow-x-auto custom-scrollbar">
            <form action="${pageContext.request.contextPath}/admin/reports" method="GET" class="flex flex-wrap items-end gap-3 text-sm">
                <input type="hidden" name="startDate" value="${startDate}">
                <input type="hidden" name="endDate" value="${endDate}">
                <input type="hidden" name="movieId" value="${movieId}">
                <input type="hidden" name="roomType" value="${roomType}">

                <div>
                    <label class="block text-gray-400 text-xs mb-1">Tên phim:</label>
                    <input type="text" name="p3Keyword" value="${p3Keyword}" placeholder="Nhập từ khóa..." class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 focus:border-orange-500 outline-none w-32">
                </div>
                <div>
                    <label class="block text-gray-400 text-xs mb-1">Phòng chiếu:</label>
                    <select name="p3RoomId" class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 focus:border-orange-500 outline-none">
                        <option value="">-- Tất cả --</option>
                        <c:forEach items="${allRoomsList}" var="r">
                            <option value="${r.id_Room}" ${p3RoomId == r.id_Room ? 'selected' : ''}>${r.roomName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-gray-400 text-xs mb-1">Doanh thu từ:</label>
                    <input type="number" name="p3MinRev" value="${p3MinRev}" placeholder="VNĐ" class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 outline-none w-24">
                </div>
                <div>
                    <label class="block text-gray-400 text-xs mb-1">Đến:</label>
                    <input type="number" name="p3MaxRev" value="${p3MaxRev}" placeholder="VNĐ" class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 outline-none w-24">
                </div>

                <div>
                    <label class="block text-gray-400 text-xs mb-1">Sắp xếp theo:</label>
                    <div class="flex gap-2">
                        <select name="p3SortBy" class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 focus:border-orange-500 outline-none">
                            <option value="default" ${p3SortBy == 'default' ? 'selected' : ''}>Mới nhất</option>
                            <option value="occupancy" ${p3SortBy == 'occupancy' ? 'selected' : ''}>Tỷ lệ lấp đầy</option>
                            <option value="revenue" ${p3SortBy == 'revenue' ? 'selected' : ''}>Doanh thu</option>
                        </select>
                        <select name="p3SortDir" class="bg-gray-900 border border-gray-700 text-white rounded px-2 py-1.5 outline-none">
                            <option value="DESC" ${p3SortDir == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                            <option value="ASC" ${p3SortDir == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="bg-orange-600 hover:bg-orange-700 text-white px-4 py-1.5 rounded font-bold transition shadow-lg">
                    <i class="fa-solid fa-filter"></i> Lọc
                </button>
            </form>
        </div>

        <div class="px-4 pb-4 overflow-x-auto overflow-y-auto max-h-[400px] custom-scrollbar relative">
            <table id="showtimeTable" class="w-full text-left border-collapse text-xs whitespace-nowrap">
                <thead class="sticky top-0 z-10 shadow-md">
                    <tr class="bg-gray-800 text-gray-400 font-bold uppercase tracking-wider">
                        <th class="py-3 px-3">Mã Suất</th>
                        <th class="py-3 px-3">Phim</th>
                        <th class="py-3 px-3">Giờ Chiếu</th>
                        <th class="py-3 px-3">Phòng</th>
                        <th class="py-3 px-3 text-center">Ghế (Đã Mua/Tổng)</th>
                        <th class="py-3 px-3 text-center">Tỷ Lệ Lấp Đầy</th>
                        <th class="py-3 px-3 text-right">Doanh Thu</th>
                        <th class="py-3 px-3 text-center">Thao Tác</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-800/40">
                    <c:forEach items="${showtimeRevenueList}" var="s">
                        <tr class="hover:bg-white/5 transition text-gray-300">
                            <td class="py-3 px-3 font-mono text-orange-400">#${s.id_Showtime}</td>
                            <td class="py-3 px-3 font-bold text-white">${s.movieTitle}</td>
                            <td class="py-3 px-3 text-gray-400"><fmt:formatDate value="${s.startTime}" pattern="HH:mm dd/MM/yyyy"/></td>
                            <td class="py-3 px-3"><span class="px-2 py-1 bg-gray-800 text-[10px] rounded text-gray-300">${s.roomName}</span></td>
                            <td class="py-3 px-3 text-center font-bold">
                                <span class="text-green-400">${s.ticketsSold}</span> / ${s.totalSeats}
                            </td>
                            <td class="py-3 px-3 text-center">
                                <c:set var="occupancy" value="${s.totalSeats > 0 ? (s.ticketsSold * 100.0) / s.totalSeats : 0}" />
                                <div class="flex items-center justify-center gap-2">
                                    <div class="w-16 h-1.5 bg-gray-700 rounded-full overflow-hidden">
                                        <div class="h-full bg-orange-500" style="width: ${occupancy}%;"></div>
                                    </div>
                                    <span class="text-[10px] font-bold ${occupancy >= 80 ? 'text-green-400' : (occupancy >= 50 ? 'text-yellow-400' : 'text-red-400')}">
                                        <fmt:formatNumber value="${occupancy}" pattern="#,##0.0"/>%
                                    </span>
                                </div>
                            </td>
                            <td class="py-3 px-3 text-right font-bold text-white"><fmt:formatNumber value="${s.totalRevenue}" pattern="#,###"/> ₫</td>
                            <td class="py-3 px-3 text-center">
                                <a href="${pageContext.request.contextPath}/admin/showtimes/edit/${s.id_Showtime}#seatMapSection" class="bg-blue-600/20 text-blue-500 hover:bg-blue-600 hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition">
                                    <i class="fa-solid fa-couch"></i> Xem Sơ Đồ
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty showtimeRevenueList}">
                        <tr><td colspan="8" class="py-6 text-center text-gray-500">Chưa có dữ liệu suất chiếu.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="mb-8">
    <h3 class="text-lg font-bold text-white mb-4 uppercase tracking-wider border-b border-gray-700 pb-2">
        <i class="fa-solid fa-door-open text-teal-500 mr-2"></i> Phần 4: Doanh Thu Loại Phòng & Phụ Thu
    </h3>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-4">
        <div class="lg:col-span-1 glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow">
            <h6 class="font-bold text-white text-xs uppercase tracking-wider mb-4">Tỷ Lệ Vé Bán</h6>
            <div class="relative h-[250px] w-full"><canvas id="roomDonutChart"></canvas></div>
        </div>

        <div class="lg:col-span-1 glass-card bg-[#1a1c23] border border-gray-800 p-5 rounded-2xl hover-glow">
            <h6 class="font-bold text-white text-xs uppercase tracking-wider mb-4">Biên Độ: Gốc vs Phụ Thu</h6>
            <div class="relative h-[250px] w-full"><canvas id="roomMarginBarChart"></canvas></div>
        </div>

        <div class="lg:col-span-2 glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl hover-glow flex flex-col">
            <div class="flex justify-between items-center p-4 border-b border-gray-800 bg-[#161616] rounded-t-2xl">
                <h6 class="font-bold text-white text-xs uppercase tracking-wider">Chi Tiết Biên Độ Phụ Thu</h6>
                <button type="button" class="border border-teal-500 text-teal-500 hover:bg-teal-600 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1" onclick="toggleSection('roomTableSection', this, 'teal')">
                    <i class="fa-solid fa-eye-slash"></i> Ẩn Dữ Liệu
                </button>
            </div>

            <div id="roomTableSection" class="p-4 overflow-x-auto custom-scrollbar flex-1">
                <table id="roomTable" class="w-full text-left border-collapse text-xs whitespace-nowrap">
                    <thead>
                        <tr class="bg-gray-800/50 text-gray-400 font-bold uppercase tracking-wider">
                            <th class="py-3 px-3">Loại Phòng</th>
                            <th class="py-3 px-3 text-right">Tổng Vé Bán</th>
                            <th class="py-3 px-3 text-right">Thu Giá Cơ Bản</th>
                            <th class="py-3 px-3 text-right text-red-400">Tổng Phụ Thu</th>
                            <th class="py-3 px-3 text-right text-teal-400">Tổng Doanh Thu</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-800/40">
                        <c:forEach items="${roomRevenueList}" var="r">
                            <tr class="hover:bg-white/5 transition text-gray-300">
                                <td class="py-3 px-3 font-bold text-white">[${r.roomType}]</td>
                                <td class="py-3 px-3 text-right">${r.ticketsSold} Vé</td>
                                <td class="py-3 px-3 text-right"><fmt:formatNumber value="${r.totalBaseAmount}" pattern="#,###"/> ₫</td>
                                <td class="py-3 px-3 text-right text-red-400"><fmt:formatNumber value="${r.totalSurchargeAmount}" pattern="#,###"/> ₫</td>
                                <td class="py-3 px-3 text-right font-bold text-teal-400"><fmt:formatNumber value="${r.totalRevenue}" pattern="#,###"/> ₫</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty roomRevenueList}">
                            <tr><td colspan="5" class="py-6 text-center text-gray-500">Không có dữ liệu loại phòng.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="mb-8">
    <div class="flex justify-between items-center mb-4 border-b border-gray-700 pb-2">
        <h3 class="text-lg font-bold text-white uppercase tracking-wider"><i class="fa-solid fa-users text-pink-500 mr-2"></i> Phần 5: Phân Tích Người Dùng</h3>
        <button type="button" class="bg-pink-600 text-white hover:bg-pink-700 px-3 py-1.5 rounded-lg text-xs font-bold transition shadow-lg flex items-center gap-1.5" onclick="toggleSection('userTableSection', this, 'pink')">
            <i class="fa-solid fa-eye"></i> Xem Dữ Liệu
        </button>
    </div>

    <div id="userTableSection" class="hidden transition-all duration-300">
        <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl overflow-hidden shadow-lg mb-6">
            <div class="p-4 border-b border-gray-800 bg-[#161616]">
                <h6 class="font-bold text-white text-xs uppercase tracking-wider">Top Khách Hàng Chi Tiêu Cao Nhất (Dựa trên bộ lọc)</h6>
            </div>
            <div class="p-4 overflow-x-auto custom-scrollbar">
                <table id="userTable" class="w-full text-left border-collapse text-xs whitespace-nowrap">
                    <thead>
                        <tr class="bg-gray-800/50 text-gray-400 font-bold uppercase tracking-wider">
                            <th class="py-3 px-3 w-12 text-center">Top</th>
                            <th class="py-3 px-3">Khách Hàng</th>
                            <th class="py-3 px-3">Email / SĐT</th>
                            <th class="py-3 px-3 text-center">Số Hóa Đơn</th>
                            <th class="py-3 px-3 text-center">Số Vé Đã Mua</th>
                            <th class="py-3 px-3 text-right text-pink-400">Tổng Mức Chi Tiêu</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-800/40">
                        <c:forEach items="${topUsersList}" var="u" varStatus="status">
                            <tr class="hover:bg-white/5 transition text-gray-300">
                                <td class="py-3 px-3 text-center">
                                    <c:choose>
                                        <c:when test="${status.index == 0}"><i class="fa-solid fa-crown text-yellow-400 text-lg"></i></c:when>
                                        <c:when test="${status.index == 1}"><i class="fa-solid fa-medal text-gray-300 text-lg"></i></c:when>
                                        <c:when test="${status.index == 2}"><i class="fa-solid fa-medal text-orange-400 text-lg"></i></c:when>
                                        <c:otherwise><span class="font-bold text-gray-500">#${status.index + 1}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="py-3 px-3 font-bold text-white flex items-center gap-2">
                                    <div class="w-6 h-6 rounded-full bg-gray-700 flex items-center justify-center text-[10px]"><i class="fa-solid fa-user"></i></div>
                                        ${u.fullName}
                                </td>
                                <td class="py-3 px-3 text-gray-400">${u.email}<br><span class="text-[10px]">${u.phone}</span></td>
                                <td class="py-3 px-3 text-center">${u.totalInvoices}</td>
                                <td class="py-3 px-3 text-center font-bold">${u.totalTickets}</td>
                                <td class="py-3 px-3 text-right font-bold text-white"><fmt:formatNumber value="${u.totalSpent}" pattern="#,###"/> ₫</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty topUsersList}">
                            <tr><td colspan="6" class="py-6 text-center text-gray-500">Chưa có dữ liệu người dùng.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="glass-card bg-[#1a1c23] border border-gray-800 rounded-2xl mb-6 overflow-hidden hover-glow">
            <div class="flex justify-between items-center p-4 border-b border-gray-800 bg-[#161616]">
                <h5 class="font-bold text-white text-sm uppercase tracking-wider">
                    <i class="fa-solid fa-list-check text-yellow-500 mr-2"></i>Nhật Ký Giao Dịch Đối Soát
                </h5>
                <button type="button" class="border border-yellow-500 text-yellow-500 hover:bg-yellow-600 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1" onclick="toggleSection('txSection', this, 'yellow')">
                    <i class="fa-solid fa-eye-slash"></i> Ẩn dữ liệu
                </button>
            </div>

            <div id="txSection" class="p-4">
                <div class="overflow-x-auto custom-scrollbar">
                    <table class="w-full text-left border-collapse whitespace-nowrap text-xs" id="txTable">
                        <thead>
                            <tr class="bg-gray-800/50 text-gray-400 font-bold uppercase tracking-wider">
                                <th class="py-3 px-3 cursor-pointer hover:text-white transition rounded-tl-lg" onclick="submitSort('bookingId')">Hóa Đơn <i class="fa-solid fa-sort ml-1"></i></th>
                                <th class="py-3 px-3 cursor-pointer hover:text-white transition" onclick="submitSort('transactionTime')">Thời Gian <i class="fa-solid fa-sort ml-1"></i></th>
                                <th class="py-3 px-3 cursor-pointer hover:text-white transition" onclick="submitSort('movieTitle')">Bộ Phim <i class="fa-solid fa-sort ml-1"></i></th>
                                <th class="py-3 px-3 cursor-pointer hover:text-white transition" onclick="submitSort('roomType')">Phòng <i class="fa-solid fa-sort ml-1"></i></th>
                                <th class="py-3 px-3 text-center">Số Vé</th>
                                <th class="py-3 px-3 text-right">Phụ Thu</th>
                                <th class="py-3 px-3 text-right cursor-pointer hover:text-white transition text-green-400 rounded-tr-lg" onclick="submitSort('totalAmount')">Tổng Tiền <i class="fa-solid fa-sort ml-1"></i></th>
                            </tr>
                        </thead>
                        <tbody id="txTableBody" class="divide-y divide-gray-800/40 Docs-container">
                            <c:forEach items="${transactionsList}" var="t">
                                <tr class="hover:bg-white/5 transition text-gray-300 font-medium">
                                    <td class="py-3 px-3 font-mono text-yellow-500 font-bold">#HD-${t.bookingId}</td>
                                    <td class="py-3 px-3 text-[11px] text-gray-400">
                                        <fmt:formatDate value="${t.transactionTime}" pattern="HH:mm dd/MM/yyyy"/>
                                    </td>
                                    <td class="py-3 px-3 font-bold text-white">${t.movieTitle}</td>
                                    <td class="py-3 px-3">
                                        <span class="px-2 py-1 bg-gray-800 text-[10px] rounded text-gray-300">${t.roomType}</span>
                                    </td>
                                    <td class="py-3 px-3 text-center font-bold">${t.ticketCount}</td>
                                    <td class="py-3 px-3 text-right text-gray-400">
                                        <fmt:formatNumber value="${t.surchargeAmount}" pattern="#,###"/> ₫
                                    </td>
                                    <td class="py-3 px-3 text-right font-bold text-green-500">
                                        <fmt:formatNumber value="${t.totalAmount}" pattern="#,###"/> ₫
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty transactionsList}">
                                <tr><td colspan="7" class="py-6 text-center text-gray-500">Không tìm thấy giao dịch nào phù hợp với bộ lọc.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <div id="paginationWrapper">
                    <c:if test="${totalPages > 1}">
                        <div class="flex flex-col md:flex-row justify-between items-center mt-4 border-t border-gray-800 pt-4">
                            <div class="text-xs font-bold text-gray-500 mb-2 md:mb-0">
                                Trang ${currentPage} / ${totalPages} (Tổng ${totalRecords} dòng)
                            </div>
                            <ul class="flex space-x-1">
                                <c:if test="${currentPage > 1}">
                                    <li class="px-3 py-1.5 bg-[#161616] hover:bg-gray-700 text-white font-bold border border-gray-700 rounded-lg text-xs cursor-pointer transition" onclick="submitPage(${currentPage - 1})">Trước</li>
                                    </c:if>

                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <c:choose>
                                        <c:when test="${i == currentPage}">
                                            <li class="px-3 py-1.5 bg-blue-600 text-white font-bold border border-blue-600 rounded-lg text-xs cursor-pointer shadow-lg">${i}</li>
                                            </c:when>
                                            <c:when test="${i == 1 || i == totalPages || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                            <li class="px-3 py-1.5 bg-[#161616] text-gray-400 font-bold hover:bg-gray-700 hover:text-white border border-gray-700 rounded-lg text-xs cursor-pointer transition" onclick="submitPage(${i})">${i}</li>
                                            </c:when>
                                            <c:when test="${i == currentPage - 2 || i == currentPage + 2}">
                                            <li class="px-2 py-1.5 text-gray-600 font-bold text-xs">...</li>
                                            </c:when>
                                        </c:choose>
                                    </c:forEach>

                                <c:if test="${currentPage < totalPages}">
                                    <li class="px-3 py-1.5 bg-[#161616] hover:bg-gray-700 text-white font-bold border border-gray-700 rounded-lg text-xs cursor-pointer transition" onclick="submitPage(${currentPage + 1})">Sau</li>
                                    </c:if>
                            </ul>
                        </div>
                    </c:if>
                </div> 
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>

<script>
                                        // Đăng ký Plugin DataLabels hiển thị % cho biểu đồ tròn
                                        Chart.register(ChartDataLabels);

                                        // Cấu hình CSS toàn cục cho Chart.js
                                        if (window.Chart) {
                                            Chart.defaults.color = '#9ca3af';
                                            Chart.defaults.scale.grid.color = '#374151';
                                            Chart.defaults.font.family = "'Inter', sans-serif";
                                        }

                                        // Đã bổ sung thêm roomMargin và movieDaily vào quản lý instance của chart
                                        let chartInstances = {revenue: null, tickets: null, movie: null, room: null, roomMargin: null, movieDaily: null};

                                        document.addEventListener("DOMContentLoaded", function () {
                                            loadAndRenderCharts();
                                        });

                                        function loadAndRenderCharts() {
                                            const urlParams = new URLSearchParams(window.location.search);
                                            let startDate = urlParams.get('startDate') || '';
                                            let endDate = urlParams.get('endDate') || '';
                                            let groupByOption = document.getElementById('groupByOption') ? document.getElementById('groupByOption').value : 'MONTH';

                                            const paramsObj = {};
                                            if (startDate)
                                                paramsObj.startDate = startDate;
                                            if (endDate)
                                                paramsObj.endDate = endDate;
                                            paramsObj.groupByOption = groupByOption;

                                            const queryParams = new URLSearchParams(paramsObj).toString();
                                            const contextPath = "${pageContext.request.contextPath}";

                                            // Gọi API song song để lấy dữ liệu
                                            const endpoints = [
                                                fetch(contextPath + "/admin/reports/api/kpis-and-charts?" + queryParams),
                                                fetch(contextPath + "/admin/reports/api/movie-revenue?" + queryParams),
                                                fetch(contextPath + "/admin/reports/api/room-revenue?" + queryParams)
                                            ];

                                            Promise.all(endpoints)
                                                    .then(responses => {
                                                        return Promise.all(responses.map(r => r.ok ? r.json() : null));
                                                    })
                                                    .then(([chartData, movieData, roomData]) => {
                                                        const trendList = (chartData && Array.isArray(chartData.trend)) ? chartData.trend : [];
                                                        const validMovieData = Array.isArray(movieData) ? movieData : [];
                                                        const validRoomData = Array.isArray(roomData) ? roomData : [];

                                                        // ==========================================
                                                        // 1. BIỂU ĐỒ ĐƯỜNG: TỔNG DOANH THU
                                                        // ==========================================
                                                        const revCtx = document.getElementById("revenueLineChart")?.getContext("2d");
                                                        if (revCtx) {
                                                            if (chartInstances.revenue)
                                                                chartInstances.revenue.destroy();

                                                            let gradient = revCtx.createLinearGradient(0, 0, 0, 300);
                                                            gradient.addColorStop(0, 'rgba(59, 130, 246, 0.4)');
                                                            gradient.addColorStop(1, 'rgba(59, 130, 246, 0.0)');

                                                            chartInstances.revenue = new Chart(revCtx, {
                                                                type: 'line',
                                                                data: {
                                                                    labels: trendList.map(i => i.periodLabel || 'N/A'),
                                                                    datasets: [{
                                                                            label: 'Doanh thu (VNĐ)',
                                                                            data: trendList.map(i => i.totalRevenue || 0),
                                                                            borderColor: '#3b82f6',
                                                                            backgroundColor: gradient,
                                                                            borderWidth: 3,
                                                                            pointBackgroundColor: '#ffffff',
                                                                            pointBorderColor: '#3b82f6',
                                                                            pointBorderWidth: 2,
                                                                            pointRadius: 4,
                                                                            pointHoverRadius: 6,
                                                                            fill: true,
                                                                            tension: 0.4
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {display: false},
                                                                        datalabels: {display: false} // Tắt % ở biểu đồ đường
                                                                    },
                                                                    scales: {
                                                                        x: {grid: {display: false}},
                                                                        y: {
                                                                            ticks: {callback: v => v.toLocaleString('vi-VN') + ' đ'},
                                                                            grid: {color: '#2d3139', borderDash: [5, 5]}
                                                                        }
                                                                    }
                                                                }
                                                            });
                                                        }

                                                        // ==========================================
                                                        // 2. BIỂU ĐỒ CỘT: LƯỢNG VÉ ĐÃ BÁN
                                                        // ==========================================
                                                        const ticketCtx = document.getElementById("ticketsBarChart")?.getContext("2d");
                                                        if (ticketCtx) {
                                                            if (chartInstances.tickets)
                                                                chartInstances.tickets.destroy();
                                                            chartInstances.tickets = new Chart(ticketCtx, {
                                                                type: 'bar',
                                                                data: {
                                                                    labels: trendList.map(i => i.periodLabel || 'N/A'),
                                                                    datasets: [{
                                                                            label: 'Số vé bán ra',
                                                                            data: trendList.map(i => i.ticketsSold || 0),
                                                                            backgroundColor: 'rgba(16, 185, 129, 0.8)',
                                                                            hoverBackgroundColor: '#10b981',
                                                                            borderRadius: 4,
                                                                            barPercentage: 0.5
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {display: false},
                                                                        datalabels: {display: false}
                                                                    },
                                                                    scales: {
                                                                        x: {grid: {display: false}},
                                                                        y: {grid: {color: '#2d3139', borderDash: [5, 5]}}
                                                                    }
                                                                }
                                                            });
                                                        }

                                                        // ==========================================
                                                        // 3. BIỂU ĐỒ TRÒN (PIE): TỶ TRỌNG DOANH THU PHIM
                                                        // ==========================================
                                                        const movieCtx = document.getElementById("moviePieChart")?.getContext("2d");
                                                        if (movieCtx) {
                                                            if (chartInstances.movie)
                                                                chartInstances.movie.destroy();
                                                            let topMovies = validMovieData.slice(0, 5); // Lấy top 5 phim

                                                            chartInstances.movie = new Chart(movieCtx, {
                                                                type: 'pie',
                                                                data: {
                                                                    labels: topMovies.map(i => (i.title && i.title.length > 15) ? i.title.substring(0, 15) + '...' : (i.title || 'Unknown')),
                                                                    datasets: [{
                                                                            data: topMovies.map(i => i.totalRevenue || 0),
                                                                            backgroundColor: ['#a855f7', '#ef4444', '#3b82f6', '#f59e0b', '#10b981'],
                                                                            borderWidth: 2,
                                                                            borderColor: '#1a1c23'
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {position: 'right', labels: {boxWidth: 12}},
                                                                        datalabels: {
                                                                            color: '#ffffff',
                                                                            font: {weight: 'bold', size: 11},
                                                                            formatter: (value, ctx) => {
                                                                                let sum = ctx.chart._metasets[ctx.datasetIndex].total;
                                                                                if (sum === 0)
                                                                                    return '0%';
                                                                                let percentage = (value * 100 / sum).toFixed(1) + "%";
                                                                                return percentage; // Chỉ hiện % trên biểu đồ
                                                                            }
                                                                        },
                                                                        tooltip: {
                                                                            callbacks: {
                                                                                label: function (context) {
                                                                                    let label = context.label || '';
                                                                                    if (label)
                                                                                        label += ': ';
                                                                                    label += context.raw.toLocaleString('vi-VN') + ' ₫';
                                                                                    return label; // Khi hover chuột mới hiện số tiền
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            });
                                                        }

                                                        // ==========================================
                                                        // 4. BIỂU ĐỒ DONUT: LOẠI PHÒNG
                                                        // ==========================================
                                                        const roomCtx = document.getElementById("roomDonutChart")?.getContext("2d");
                                                        if (roomCtx) {
                                                            if (chartInstances.room)
                                                                chartInstances.room.destroy();
                                                            chartInstances.room = new Chart(roomCtx, {
                                                                type: 'doughnut',
                                                                data: {
                                                                    labels: validRoomData.map(r => r.roomType || 'N/A'),
                                                                    datasets: [{
                                                                            data: validRoomData.map(r => r.ticketsSold || 0),
                                                                            backgroundColor: ['#14b8a6', '#d946ef', '#ec4899', '#f43f5e', '#8b5cf6'],
                                                                            borderWidth: 2,
                                                                            borderColor: '#1a1c23'
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    cutout: '65%',
                                                                    plugins: {
                                                                        legend: {position: 'right', labels: {boxWidth: 12}},
                                                                        datalabels: {
                                                                            color: '#ffffff',
                                                                            font: {weight: 'bold', size: 11},
                                                                            formatter: (value, ctx) => {
                                                                                let sum = ctx.chart._metasets[ctx.datasetIndex].total;
                                                                                if (sum === 0)
                                                                                    return '0%';
                                                                                let percentage = (value * 100 / sum).toFixed(1) + "%";
                                                                                return percentage;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            });
                                                        }

                                                        // ==========================================
                                                        // 5. BỔ SUNG: BIỂU ĐỒ STACKED BAR CHO LOẠI PHÒNG
                                                        // ==========================================
                                                        const roomMarginCtx = document.getElementById("roomMarginBarChart")?.getContext("2d");
                                                        if (roomMarginCtx) {
                                                            if (chartInstances.roomMargin)
                                                                chartInstances.roomMargin.destroy();
                                                            chartInstances.roomMargin = new Chart(roomMarginCtx, {
                                                                type: 'bar',
                                                                data: {
                                                                    labels: validRoomData.map(r => r.roomType || 'N/A'),
                                                                    datasets: [
                                                                        {
                                                                            label: 'Doanh thu Gốc',
                                                                            data: validRoomData.map(r => r.totalBaseAmount || 0),
                                                                            backgroundColor: '#3b82f6'
                                                                        },
                                                                        {
                                                                            label: 'Phụ Thu',
                                                                            data: validRoomData.map(r => r.totalSurchargeAmount || 0),
                                                                            backgroundColor: '#ef4444'
                                                                        }
                                                                    ]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {position: 'bottom', labels: {boxWidth: 10}},
                                                                        datalabels: {display: false}
                                                                    },
                                                                    scales: {
                                                                        x: {stacked: true, grid: {display: false}},
                                                                        y: {stacked: true, grid: {color: '#2d3139', borderDash: [5, 5]}}
                                                                    }
                                                                }
                                                            });
                                                    }

                                                    })
                                                    .catch(err => console.error("🚨 Lỗi tải dữ liệu biểu đồ: ", err));
                                        }

                                        // ==========================================
                                        // CÁC HÀM XỬ LÝ SỰ KIỆN KHÁC
                                        // ==========================================

                                        // Hàm thay đổi trạng thái Ẩn/Hiện của các khối section
                                        function toggleSection(sectionId, btnElem, color) {
                                            const section = document.getElementById(sectionId);
                                            if (section.classList.contains("hidden")) {
                                                section.classList.remove("hidden");
                                                // Đổi text và style của nút thành trạng thái "Ẩn"
                                                btnElem.innerHTML = '<i class="fa-solid fa-eye-slash"></i> Ẩn Dữ Liệu';
                                                btnElem.className = 'border border-' + color + '-500 text-' + color + '-500 hover:bg-' + color + '-600 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1';
                                            } else {
                                                section.classList.add("hidden");
                                                // Đổi text và style của nút thành trạng thái "Xem"
                                                btnElem.innerHTML = '<i class="fa-solid fa-eye"></i> Xem Dữ Liệu';
                                                btnElem.className = 'bg-' + color + '-600 text-white hover:bg-' + color + '-700 px-3 py-1.5 rounded-lg text-xs font-bold transition shadow-lg flex items-center gap-1.5';
                                            }
                                        }

                                        // Xử lý bộ lọc nhanh thời gian
                                        function handleTimeQuickSelect(value) {
                                            if (value === 'CUSTOM')
                                                return;

                                            let today = new Date();
                                            let startDateInput = document.getElementById('startDate');
                                            let endDateInput = document.getElementById('endDate');

                                            if (value === 'TODAY') {
                                                let dateStr = today.toISOString().split('T')[0];
                                                startDateInput.value = dateStr;
                                                endDateInput.value = dateStr;
                                            } else if (value === 'THIS_WEEK') {
                                                let firstDay = new Date(today.setDate(today.getDate() - today.getDay() + 1));
                                                let lastDay = new Date(today.setDate(today.getDate() - today.getDay() + 7));
                                                startDateInput.value = firstDay.toISOString().split('T')[0];
                                                endDateInput.value = lastDay.toISOString().split('T')[0];
                                            } else if (value === 'THIS_MONTH') {
                                                let firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
                                                let lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                                                startDateInput.value = firstDay.toISOString().split('T')[0];
                                                endDateInput.value = lastDay.toISOString().split('T')[0];
                                            } else if (value === 'THIS_YEAR') {
                                                let firstDay = new Date(today.getFullYear(), 0, 1);
                                                let lastDay = new Date(today.getFullYear(), 11, 31);
                                                startDateInput.value = firstDay.toISOString().split('T')[0];
                                                endDateInput.value = lastDay.toISOString().split('T')[0];
                                            }

                                            // Tự động submit form khi chọn lọc nhanh
                                            document.getElementById('filterForm').submit();
                                        }

                                        // ---- HÀM XỬ LÝ LỌC PHIM CỤC BỘ (Client-side) ----
                                        function applyMovieFilter() {
                                            let nameFilter = document.getElementById('filterMovieName').value.trim().toLowerCase();
                                            let minRev = document.getElementById('filterMinRev').value;
                                            let maxRev = document.getElementById('filterMaxRev').value;

                                            let min = minRev ? parseFloat(minRev) : 0;
                                            let max = maxRev ? parseFloat(maxRev) : Infinity;

                                            let rows = document.querySelectorAll('#movieTableBody .movie-row');
                                            rows.forEach(row => {
                                                let movieName = row.getAttribute('data-name');
                                                let movieRev = parseFloat(row.getAttribute('data-revenue'));

                                                let matchName = movieName.includes(nameFilter);
                                                let matchRev = (movieRev >= min && movieRev <= max);

                                                if (matchName && matchRev) {
                                                    row.style.display = '';
                                                } else {
                                                    row.style.display = 'none';
                                                }
                                            });
                                        }

                                        // ---- HÀM GỌI API & VẼ BIỂU ĐỒ DOANH THU THEO NGÀY CỦA 1 PHIM ----
                                        let movieDailyChartInstance = null;

                                        function loadMovieDailyChart(movieId, movieTitle) {
                                            // Cập nhật lại tiêu đề biểu đồ 
                                            const titleElement = document.getElementById('movieChartTitle');
                                            if (titleElement) {
                                                titleElement.innerText = 'Biến Động Doanh Thu Phim: ' + movieTitle;
                                            }

                                            const startDateInput = document.getElementById('startDate');
                                            const endDateInput = document.getElementById('endDate');

                                            let contextPath = '${pageContext.request.contextPath}';

                                            let url = contextPath + '/admin/reports/api/movie-daily?movieId=' + movieId;

                                            if (startDateInput && startDateInput.value) {
                                                url += '&startDate=' + startDateInput.value;
                                            }
                                            if (endDateInput && endDateInput.value) {
                                                url += '&endDate=' + endDateInput.value;
                                            }

                                            // Gọi API
                                            fetch(url)
                                                    .then(response => {
                                                        if (!response.ok) {
                                                            console.error("HTTP Error Status:", response.status);
                                                            throw new Error("Lỗi kết nối mạng hoặc API trả về lỗi: " + response.status);
                                                        }
                                                        return response.json();
                                                    })
                                                    .then(data => {
                                                        const labels = data.map(item => item.date);
                                                        const revenues = data.map(item => item.revenue);

                                                        const ctx = document.getElementById('movieDailyLineChart').getContext('2d');

                                                        if (movieDailyChartInstance != null) {
                                                            movieDailyChartInstance.destroy();
                                                        }

                                                        movieDailyChartInstance = new Chart(ctx, {
                                                            type: 'line',
                                                            data: {
                                                                labels: labels,
                                                                datasets: [{
                                                                        label: 'Doanh thu (VNĐ)',
                                                                        data: revenues,
                                                                        borderColor: '#a855f7',
                                                                        backgroundColor: 'rgba(168, 85, 247, 0.2)',
                                                                        borderWidth: 2,
                                                                        fill: true,
                                                                        tension: 0.3,
                                                                        pointBackgroundColor: '#ffffff',
                                                                        pointBorderColor: '#a855f7'
                                                                    }]
                                                            },
                                                            options: {
                                                                responsive: true,
                                                                maintainAspectRatio: false,
                                                                scales: {
                                                                    y: {
                                                                        beginAtZero: true,
                                                                        grid: {color: '#374151'},
                                                                        ticks: {
                                                                            color: '#9ca3af',
                                                                            callback: function (value) {
                                                                                return value.toLocaleString('vi-VN') + ' ₫';
                                                                            }
                                                                        }
                                                                    },
                                                                    x: {
                                                                        grid: {display: false},
                                                                        ticks: {color: '#9ca3af'}
                                                                    }
                                                                },
                                                                plugins: {
                                                                    legend: {display: false}
                                                                }
                                                            }
                                                        });
                                                    })
                                                    .catch(error => {
                                                        console.error("Lỗi chi tiết khi tải biểu đồ:", error);
                                                        alert("Không thể tải dữ liệu biểu đồ. Vui lòng nhấn F12 -> tab Console để xem chi tiết lỗi.");
                                                    });
                                        }
                                        function submitPage(pageNumber) {
                                            // 1. Lấy thẻ input ẩn chứa số trang và cập nhật giá trị mới
                                            const pageInput = document.getElementById('pageInput');
                                            if (pageInput) {
                                                pageInput.value = pageNumber;
                                            }

                                            // 2. Submit form lọc (Hãy chắc chắn form lọc của bạn có id="filterForm")
                                            const form = document.getElementById('filterForm');
                                            if (form) {
                                                form.submit();
                                            } else {
                                                console.error("Không tìm thấy form nào có id là 'filterForm'");
                                            }
                                        }

                                        // Hàm xử lý khi bấm vào tiêu đề cột để sắp xếp
                                        function submitSort(column) {
                                            const sortByInput = document.getElementById('sortByInput');
                                            const sortDirInput = document.getElementById('sortDirInput');
                                            const pageInput = document.getElementById('pageInput');

                                            if (sortByInput && sortDirInput) {
                                                let currentSortBy = sortByInput.value;
                                                let currentSortDir = sortDirInput.value;

                                                // Nếu bấm lại vào đúng cột đang sắp xếp thì đảo chiều (Từ Tăng -> Giảm hoặc ngược lại)
                                                if (currentSortBy === column) {
                                                    sortDirInput.value = (currentSortDir === 'ASC') ? 'DESC' : 'ASC';
                                                } else {
                                                    // Nếu bấm sang cột mới, mặc định gán là Giảm dần (DESC)
                                                    sortByInput.value = column;
                                                    sortDirInput.value = 'DESC';
                                                }
                                            }

                                            // Khi thay đổi sắp xếp, tự động đưa về trang 1 để không bị lỗi rỗng dữ liệu
                                            if (pageInput) {
                                                pageInput.value = 1;
                                            }

                                            // Submit form
                                            const form = document.getElementById('filterForm');
                                            if (form) {
                                                form.submit();
                                            }
                                        }
</script>
<div style="display: none;">
    <table id="txTableFull">
        <thead>
            <tr>
                <th>Hóa Đơn</th>
                <th>Thời Gian</th>
                <th>Bộ Phim</th>
                <th>Phòng</th>
                <th>Số Vé</th>
                <th>Phụ Thu</th>
                <th>Tổng Tiền</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${allTransactionsList}" var="t">
                <tr>
                    <td>#HD-${t.bookingId}</td>
                    <td>${t.transactionTime}</td>
                    <td>${t.movieTitle}</td>
                    <td>${t.roomType}</td>
                    <td>${t.ticketCount}</td>
                    <td>${t.surchargeAmount} ₫</td>
                    <td>${t.totalAmount} ₫</td>
                </tr>
            </c:forEach>
            <c:if test="${empty allTransactionsList}">
                <tr><td colspan="7">Không có dữ liệu giao dịch.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<div id="exportExcelModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(15, 23, 42, 0.7); backdrop-filter: blur(4px); align-items: center; justify-content: center;">
    <div style="background-color: #ffffff; padding: 25px; border-radius: 12px; width: 450px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); font-family: Arial, sans-serif;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #f1f5f9; padding-bottom: 12px;">
            <h3 style="margin: 0; font-size: 16px; font-weight: bold; color: #1e3a8a; text-transform: uppercase;">Tùy chọn xuất báo cáo</h3>
            <span onclick="closeExportModal()" style="color: #94a3b8; font-size: 24px; font-weight: bold; cursor: pointer;">&times;</span>
        </div>
        <p style="margin: 0 0 15px 0; font-size: 13px; color: #64748b; font-style: italic;">Chọn phân đoạn báo cáo bạn muốn xuất:</p>
        <div style="display: flex; flex-direction: column; gap: 10px;">
            <button onclick="executeGranularExport(1)" style="text-align: left; padding: 10px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">📊 Phần 1: Chỉ số KPI</button>
            <button onclick="executeGranularExport(2)" style="text-align: left; padding: 10px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">🎬 Phần 2: Doanh thu phim</button>
            <button onclick="executeGranularExport(3)" style="text-align: left; padding: 10px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">⏰ Phần 3: Hiệu suất suất chiếu</button>
            <button onclick="executeGranularExport(4)" style="text-align: left; padding: 10px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">🚪 Phần 4: Doanh thu phòng</button>
            <button onclick="executeGranularExport(5)" style="text-align: left; padding: 10px; background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">🧾 Phần 5: Khách hàng & Nhật ký</button>
            <div style="height: 1px; background-color: #f1f5f9; margin: 5px 0;"></div>
            <button onclick="executeGranularExport('ALL')" style="text-align: center; padding: 12px; background-color: #1e3a8a; border: none; border-radius: 6px; font-size: 13px; color: #fff; font-weight: bold; cursor: pointer;">📥 Xuất toàn bộ 5 Phần</button>
        </div>
    </div>
</div>

<script type="text/javascript">
    function openExportModal() {
        document.getElementById("exportExcelModal").style.display = "flex";
    }

    function closeExportModal() {
        document.getElementById("exportExcelModal").style.display = "none";
    }

    function cleanTableHTML(tableId, hasActionColumn) {
        var tableObj = document.getElementById(tableId);
        if (!tableObj)
            return "<p style='color:gray; font-style:italic;'>Không có dữ liệu</p>";
        var cloneTable = tableObj.cloneNode(true);

        if (hasActionColumn) {
            var ths = cloneTable.querySelectorAll("thead tr th");
            if (ths.length > 0)
                ths[ths.length - 1].remove();
            var rows = cloneTable.querySelectorAll("tbody tr");
            rows.forEach(function (row) {
                var tds = row.querySelectorAll("td");
                if (tds.length > 0)
                    tds[tds.length - 1].remove();
            });
        }
        var allCells = cloneTable.querySelectorAll("th, td");
        allCells.forEach(function (cell) {
            var text = cell.innerText.trim();
            if (text.indexOf("₫") !== -1 || text.indexOf("Vé") !== -1) {
                if (cell.tagName.toLowerCase() === "td") {
                    var numericValue = text.replace(/,/g, "").replace(/₫/g, "").replace(/Vé/g, "").trim();
                    if (!isNaN(numericValue) && numericValue !== "") {
                        cell.setAttribute("x:num", numericValue);
                        cell.innerText = numericValue;
                    }
                }
            }
        });
        return cloneTable.outerHTML;
    }

    function executeGranularExport(partOption) {
        closeExportModal();

        var exportContentHTML = "";
        var fileNameSuffix = "";
        var startDateElem = document.getElementById("startDate");
        var endDateElem = document.getElementById("endDate");
        var startDate = startDateElem && startDateElem.value ? startDateElem.value : 'Tất cả';
        var endDate = endDateElem && endDateElem.value ? endDateElem.value : 'Tất cả';

        var movieTableHTML = cleanTableHTML("movieTable", true);
        var showtimeTableHTML = cleanTableHTML("showtimeTable", true);
        var roomTableHTML = cleanTableHTML("roomTable", false);
        var userTableHTML = cleanTableHTML("userTable", false);
        var txTableHTML = cleanTableHTML("txTableFull", false);

        var totalRevenue = "${not empty kpis.totalRevenue ? kpis.totalRevenue : 0}";
        var totalTickets = "${not empty kpis.totalTickets ? kpis.totalTickets : 0}";
        var occupancyRate = "${not empty kpis.occupancyRate ? kpis.occupancyRate : 0}";

        var kpiBlockHTML =
                "<div class='section-title'>PHẦN 1: CHỈ SỐ TỔNG QUÁT (KPI)</div>" +
                "<table class='kpi-table'>" +
                "<tr><th>Tổng Doanh Thu:</th><td class='kpi-val' x:num='" + totalRevenue + "'>" + Number(totalRevenue).toLocaleString('vi-VN') + "</td></tr>" +
                "<tr><th>Tổng Số Vé Đã Bán:</th><td class='kpi-val' x:num='" + totalTickets + "'>" + Number(totalTickets).toLocaleString('vi-VN') + "</td></tr>" +
                "<tr><th>Tỷ Lệ Lấp Đầy:</th><td class='kpi-val' x:num='" + occupancyRate + "'>" + Number(occupancyRate).toLocaleString('vi-VN') + "%</td></tr>" +
                "</table>";

        if (partOption === 1) {
            exportContentHTML = kpiBlockHTML;
            fileNameSuffix = "Phan_1_KPIs";
        } else if (partOption === 2) {
            exportContentHTML = "<div class='section-title'>PHẦN 2: DOANH THU PHIM</div>" + movieTableHTML;
            fileNameSuffix = "Phan_2_DoanhThuPhim";
        } else if (partOption === 3) {
            exportContentHTML = "<div class='section-title'>PHẦN 3: HIỆU SUẤT SUẤT CHIẾU</div>" + showtimeTableHTML;
            fileNameSuffix = "Phan_3_HieuSuat";
        } else if (partOption === 4) {
            exportContentHTML = "<div class='section-title'>PHẦN 4: DOANH THU LOẠI PHÒNG</div>" + roomTableHTML;
            fileNameSuffix = "Phan_4_DoanhThuPhong";
        } else if (partOption === 5) {
            exportContentHTML = "<div class='section-title'>PHẦN 5.1: KHÁCH HÀNG CAO NHẤT</div>" + userTableHTML +
                    "<div class='section-title'>PHẦN 5.2: NHẬT KÝ ĐỐI SOÁT</div>" + txTableHTML;
            fileNameSuffix = "Phan_5_NhatKy";
        } else {
            exportContentHTML = kpiBlockHTML +
                    "<div class='section-title'>PHẦN 2: DOANH THU PHIM</div>" + movieTableHTML +
                    "<div class='section-title'>PHẦN 3: HIỆU SUẤT SUẤT CHIẾU</div>" + showtimeTableHTML +
                    "<div class='section-title'>PHẦN 4: DOANH THU LOẠI PHÒNG</div>" + roomTableHTML +
                    "<div class='section-title'>PHẦN 5.1: KHÁCH HÀNG CAO NHẤT</div>" + userTableHTML +
                    "<div class='section-title'>PHẦN 5.2: NHẬT KÝ ĐỐI SOÁT</div>" + txTableHTML;
            fileNameSuffix = "Tong_Hop";
        }

        // Dùng \x3C thay cho < để JSP không nuốt thẻ
        var excelTemplate =
                "\x3Chtml xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'\x3E" +
                "\x3Chead\x3E\x3Cmeta charset='utf-8'\x3E" +
                "\x3Cstyle\x3E" +
                "table { border-collapse: collapse; width: 100%; margin-bottom: 25px; font-family: Arial;} " +
                "th, td { border: 1px solid #cbd5e1; padding: 6px; } " +
                "th { background-color: #1e293b; color: #ffffff; font-size: 11px; } " +
                ".section-title { font-size: 13px; font-weight: bold; margin: 20px 0 10px 0; font-family: Arial; } " +
                "td[x\\:num] { text-align: right; }" +
                "\x3C/style\x3E\x3C/head\x3E\x3Cbody\x3E" +
                "\x3Ch2 style='text-align:center;font-family:Arial;'\x3EBÁO CÁO HỆ THỐNG RẠP CHIẾU PHIM\x3C/h2\x3E" +
                "\x3Cp style='text-align:center;font-family:Arial;'\x3EThời gian: " + startDate + " đến " + endDate + "\x3C/p\x3E" +
                exportContentHTML +
                "\x3C/body\x3E\x3C/html\x3E";

        var blob = new Blob([excelTemplate], {type: 'application/vnd.ms-excel;charset=utf-8'});
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = "Bao_Cao_" + fileNameSuffix + "_" + new Date().toISOString().slice(0, 10) + ".xls";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
</script>