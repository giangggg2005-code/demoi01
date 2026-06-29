<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- TẠO BIẾN CỜ DỰA TRÊN ROLE --%>
<c:set var="isViewMode" value="${mode == 'view'}" />

<style>
    /* Thanh cuộn ngang và dọc cao cấp cho sơ đồ ghế */
    .custom-scrollbar {
        scrollbar-width: thin;
        scrollbar-color: #ef4444 #0b0c10;
    }
    .custom-scrollbar::-webkit-scrollbar {
        width: 8px;
        height: 8px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: #0b0c10;
        border-radius: 20px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #1f2937;
        border-radius: 20px;
        border: 2px solid #0b0c10;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: #ef4444;
    }

    .seat-selected {
        box-shadow: 0 0 20px rgba(34, 197, 94, 0.9), inset 0 0 12px rgba(24, 240, 100, 0.6) !important;
        border-color: #22c55e !important;
        transform: scale(1.12) translateY(-4px);
        font-weight: 900 !important;
        z-index: 30;
        animation: pulseNeon 1.4s infinite alternate;
    }

    @keyframes pulseNeon {
        from {
            box-shadow: 0 0 12px rgba(34, 197, 94, 0.6), inset 0 0 6px rgba(34, 197, 94, 0.3);
        }
        to {
            box-shadow: 0 0 22px rgba(34, 197, 94, 1), inset 0 0 14px rgba(34, 197, 94, 0.7);
        }
    }

    .seat-item {
        position: relative;
        border-radius: 8px 8px 5px 5px;
        box-shadow: inset 0 -4px 0 rgba(0,0,0,0.45), 0 4px 6px rgba(0,0,0,0.3);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .seat-grid {
        display: inline-grid;
        gap: 10px 12px;
        justify-content: center;
        padding: 45px 30px;
        position: relative;
    }
    .stairs-bg {
        background: radial-gradient(circle at center, #16171d 0%, #0b0c10 100%);
        border-radius: 16px;
    }
</style>

<script>
    // 1. Dữ liệu suất chiếu từ Backend
    const showtimesData = [
        <c:forEach items="${showtimesList}" var="st" varStatus="loop">
        {
            showDate: '<fmt:formatDate value="${st.showDate}" pattern="yyyy-MM-dd" />',
            startTime: '${st.startTime}',
            soldTickets: ${st.soldTickets != null ? st.soldTickets : 0},
            movieTitle: "<c:out value='${st.movieTitle}' escapeXml='true' />"
        }${!loop.last ? ',' : ''}
        </c:forEach>
    ];

    const currentRoomId = '${room.id_Room}';

    // Hàm kiểm tra xem có vé nào đã bán không trong tương lai
    function hasSoldTicketsInFuture() {
        return showtimesData.some(st => st.soldTickets > 0);
    }

    // Các hàm hiển thị Modal
    function showCustomSuccessModal(message) {
        const modal = document.getElementById('customSuccessModal');
        const content = document.getElementById('customSuccessContent');
        const msgTemplate = document.getElementById('customSuccessMessage');
        
        if (message) msgTemplate.innerText = message;
        
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            content.classList.remove('scale-95');
            content.classList.add('scale-100');
        }, 10);
    }

    function closeCustomSuccessModal() {
        const modal = document.getElementById('customSuccessModal');
        const content = document.getElementById('customSuccessContent');
        
        modal.classList.add('opacity-0');
        content.classList.remove('scale-100');
        content.classList.add('scale-95');
        
        setTimeout(() => {
            modal.classList.remove('flex');
            modal.classList.add('hidden');
            window.location.reload();
        }, 300);
    }

    // 2. Xử lý Logic chính khi Load trang
    document.addEventListener("DOMContentLoaded", function () {
        const updateForm = document.getElementById("updateRoomForm");
        const exceptionNotice = document.getElementById("exceptionNotice");
        const exceptionMessage = document.getElementById("exceptionMessage");
        const roomStatusSelect = document.getElementById("roomStatusSelect");

        if (updateForm) {
            const priceInput = updateForm.querySelector("input[name='roomPrice']");
            const nameInput = updateForm.querySelector("input[name='roomName']");

            // Logic cảnh báo khi đổi trạng thái Select
            if (roomStatusSelect) {
                roomStatusSelect.addEventListener("change", function() {
                    if (this.value === "Maintenance" && hasSoldTicketsInFuture()) {
                        exceptionMessage.innerText = "CẢNH BÁO: Không thể chuyển sang bảo trì vì phòng chiếu hiện có vé đã bán trong 7 ngày tới!";
                        exceptionNotice.classList.remove("hidden");
                    } else {
                        exceptionNotice.classList.add("hidden");
                    }
                });
            }

            // Validation Input
            if (nameInput) {
                nameInput.addEventListener("input", function () {
                    if (this.value.trim() === "") {
                        exceptionMessage.innerText = "Tên phòng chiếu không được để trống!";
                        exceptionNotice.classList.remove("hidden");
                    } else {
                        exceptionNotice.classList.add("hidden");
                    }
                });
            }

            if (priceInput) {
                priceInput.addEventListener("input", function () {
                    const roomPrice = parseFloat(this.value);
                    if (this.value.trim() === "" || isNaN(roomPrice) || roomPrice < 0) {
                        exceptionMessage.innerText = "Giá phụ thu không hợp lệ!";
                        exceptionNotice.classList.remove("hidden");
                    } else {
                        exceptionNotice.classList.add("hidden");
                    }
                });
            }

            // Logic kiểm tra cuối cùng khi Submit
            updateForm.addEventListener("submit", function (e) {
                exceptionNotice.classList.add("hidden");
                
                // Kiểm tra trạng thái Maintenance
                if (roomStatusSelect && roomStatusSelect.value === "Maintenance" && hasSoldTicketsInFuture()) {
                    e.preventDefault();
                    exceptionMessage.innerText = "⛔ TỪ CHỐI LƯU: Phòng chiếu đang có vé đã bán!";
                    exceptionNotice.classList.remove("hidden");
                    return;
                }

                // Kiểm tra Name & Price
                if (nameInput.value.trim() === "" || priceInput.value.trim() === "" || parseFloat(priceInput.value) < 0) {
                    e.preventDefault();
                    exceptionMessage.innerText = "Vui lòng kiểm tra lại Tên phòng hoặc Giá phụ thu!";
                    exceptionNotice.classList.remove("hidden");
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                }
            });
        }
    });
</script>

<div class="mb-6 flex justify-between items-end">
    <div>
        <a id="btnBackToList" href="${pageContext.request.contextPath}/admin/rooms" class="text-gray-400 hover:text-red-500 transition text-sm flex items-center mb-2 font-bold group">
            <i class="fas fa-arrow-left mr-2 transform group-hover:-translate-x-1 transition"></i> Trở về danh sách phòng
        </a>
        <h2 class="text-3xl font-black text-white uppercase tracking-wider glow-text-red">Cấu Hình Phòng: ${room.roomName} 
            <span class="text-xs font-semibold text-red-400 ml-2 border border-red-500/30 bg-red-500/10 rounded-full px-3 py-1 vertical-middle">${room.roomType}</span>
        </h2>
    </div>
</div>

<%-- 1. Thông báo lỗi từ Server (dùng c:if) --%>
<c:if test="${not empty errorMessage}">
    <div class="mb-6 p-4 rounded-xl border border-red-500/40 bg-red-950/40 text-red-400 text-sm font-bold shadow-[0_0_20px_rgba(239,68,68,0.15)] backdrop-blur-md flex items-center gap-3 transition-all">
        <div class="w-8 h-8 rounded-full bg-red-500/20 flex items-center justify-center text-red-500"><i class="fas fa-exclamation-circle text-md"></i></div>
        <span class="flex-1">⚠️ Lỗi: ${errorMessage}</span>
    </div>
</c:if>

<%-- 2. Thông báo thành công từ Server --%>
<c:if test="${not empty successMessage}">
    <div class="mb-6 p-4 rounded-xl border border-green-500/40 bg-green-950/40 text-green-400 text-sm font-bold shadow-[0_0_20px_rgba(34,197,94,0.15)] backdrop-blur-md flex items-center gap-3 transition-all">
        <div class="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center text-green-500"><i class="fas fa-check-circle text-md"></i></div>
        <span class="flex-1">Thành công: ${successMessage}</span>
    </div>
</c:if>

<%-- 3. Khung thông báo lỗi của Javascript (Duy nhất 1 ID) --%>
<div id="exceptionNotice" class="hidden mb-6 p-4 rounded-xl border border-red-500/40 bg-red-950/40 text-red-400 text-sm font-bold shadow-[0_0_20px_rgba(239,68,68,0.15)] backdrop-blur-md flex items-center gap-3 transition-all">
    <div class="w-8 h-8 rounded-full bg-red-500/20 flex items-center justify-center text-red-500"><i class="fas fa-exclamation-circle text-md"></i></div>
    <span id="exceptionMessage" class="flex-1"></span>
</div>
<%-- KẾT THÚC PHẦN THAY THẾ --%>

<div id="exceptionNotice" class="hidden mb-6 p-4 rounded-xl border border-red-500/40 bg-red-950/40 text-red-400 text-sm font-bold shadow-[0_0_20px_rgba(239,68,68,0.15)] backdrop-blur-md flex items-center gap-3 transition-all animate-pulse">
    <div class="w-8 h-8 rounded-full bg-red-500/20 flex items-center justify-center text-red-500"><i class="fas fa-exclamation-circle text-md"></i></div>
    <span id="exceptionMessage" class="flex-1"></span>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
    <div class="bg-[#121216] border border-gray-800/80 rounded-2xl p-5 shadow-xl glass-card lg:col-span-1">
        <h3 class="text-md font-bold text-white mb-4 border-b border-gray-800 pb-2 flex items-center justify-between">
            <span><i class="fas fa-sliders-h text-red-500 mr-2"></i> Thuộc Tính Phòng</span>
            <span class="text-[11px] text-gray-500">ID: # ${room.id_Room}</span>
        </h3>

        <form id="updateRoomForm" action="${pageContext.request.contextPath}/admin/rooms/update" method="POST" class="space-y-4">
            <input type="hidden" id="id_Room" name="id_Room" value="${room.id_Room}">
            <input type="hidden" id="idRoom" name="idRoom" value="${room.id_Room}">
            <input type="hidden" id="roomId" name="id" value="${room.id_Room}">

            <div class="space-y-1.5">
                <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Tên Phòng</label>
                <%-- Bổ sung readonly nếu là mode View --%>
                <input type="text" name="roomName" value="${room.roomName}" 
                       ${isViewMode ? 'readonly' : ''} 
                       class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-4 py-2.5 text-white focus:border-red-500 focus:ring-1 focus:ring-red-500 outline-none transition ${isViewMode ? 'opacity-60 cursor-not-allowed' : ''}">
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div class="form-group">
                    <label for="roomType" style="font-weight: bold; color: #fff;">Loại phòng chiếu:</label>
                    <select name="roomType" id="roomType" ${isViewMode ? 'disabled' : ''} class="form-control" style="background-color: #1f2937; color: #fff; border: 1px solid #374151; padding: 8px; border-radius: 4px; width: 100%;">
                        <option value="Standard" ${room.roomType == 'Standard' ? 'selected' : ''}>Standard (Phòng Tiêu Chuẩn)</option>
                        <option value="IMAX" ${room.roomType == 'IMAX' ? 'selected' : ''}>IMAX (Màn Hình Đại Vĩ Tuyến)</option>
                        <option value="4DX" ${room.roomType == '4DX' ? 'selected' : ''}>4DX (Hiệu Ứng Đa Chiều)</option>
                        <option value="Sweetbox" ${room.roomType == 'Sweetbox' ? 'selected' : ''}>Sweetbox (Ghế Đôi Cặp Đôi)</option>
                        <option value="VIP" ${room.roomType == 'VIP' ? 'selected' : ''}>VIP (Thượng Hạng)</option>
                    </select>
                </div>
                <div class="space-y-1.5">
                    <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Giá Phụ Thu</label>
                    <input type="number" name="roomPrice" value="${room.roomPrice}" ${isViewMode ? 'readonly' : ''} class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-4 py-2.5 text-white focus:border-red-500 focus:ring-1 focus:ring-red-500 outline-none transition ${isViewMode ? 'opacity-60 cursor-not-allowed' : ''}">
                </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div class="space-y-1.5">
                    <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Tổng Hàng</label>
                    <input type="number" name="totalRows" value="${room.totalRows}" readonly title="Không thể đổi số hàng của phòng chiếu đã tồn tại"
                           class="w-full bg-gray-800 text-gray-500 border border-gray-700 rounded-xl px-4 py-2.5 outline-none text-center font-bold text-lg cursor-not-allowed opacity-70">
                </div>
                <div class="space-y-1.5">
                    <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Tổng Cột</label>
                    <input type="number" name="totalCols" value="${room.totalCols}" readonly title="Không thể đổi số cột của phòng chiếu đã tồn tại"
                           class="w-full bg-gray-800 text-gray-500 border border-gray-700 rounded-xl px-4 py-2.5 outline-none text-center font-bold text-lg cursor-not-allowed opacity-70">
                </div>
            </div>

            <div class="space-y-1.5">
                <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Trạng Thái Hệ Thống</label>
                <%-- Bổ sung disabled nếu là mode View --%>
                <select name="status" id="roomStatusSelect" data-current="${room.status}" ${isViewMode ? 'disabled' : ''} class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-4 py-2.5 text-white outline-none focus:border-red-500 transition font-bold ${room.status == 'Active' ? 'text-green-400' : 'text-yellow-500'}">
                    <option value="Active" class="text-green-400 font-bold" ${room.status == 'Active' ? 'selected' : ''}>🟢 Hoạt động</option>
                    <option value="Maintenance" class="text-yellow-500 font-bold" ${room.status == 'Maintenance' ? 'selected' : ''}>🟡 Bảo trì / Khóa</option>
                </select>
            </div>

            <%-- Ẩn nút lưu cập nhật nếu là mode View --%>
            <c:if test="${!isViewMode}">
                <div class="pt-2">
                    <button type="submit" class="w-full bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white font-bold py-2.5 px-4 rounded-xl shadow-[0_0_15px_rgba(220,38,38,0.4)] hover:shadow-[0_0_25px_rgba(220,38,38,0.6)] transition-all transform active:scale-95 uppercase tracking-wider text-sm">
                        <i class="fas fa-save mr-2"></i> Lưu Cập Nhật
                    </button>
                </div>
            </c:if>
        </form>
    </div>

    <div class="bg-[#121216] border border-gray-800/80 rounded-2xl p-5 shadow-xl glass-card lg:col-span-2 flex flex-col justify-between">
        <div>
            <h3 class="text-md font-bold text-white mb-4 border-b border-gray-800 pb-2"><i class="fas fa-search-plus text-blue-500 mr-2"></i> Bộ Lọc Tìm Kiếm Ghế Tích Lũy (Multi-Layer)</h3>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 items-end">
                <div class="space-y-1.5">
                    <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Chế độ phân vùng</label>
                    <select id="searchMode" onchange="toggleSearchMode()" class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-3 py-2.5 text-white text-sm outline-none focus:border-blue-500 transition">
                        <option value="name">🎯 Tìm đích danh tên ghế</option>
                        <option value="row">↔️ Chỉ lọc theo Hàng ngang</option>
                        <option value="col">↕️ Chỉ lọc theo Cột dọc</option>
                        <option value="area">🗺️ Lọc theo Vùng tùy chọn (Hàng & Cột)</option>
                    </select>
                </div>

                <%-- Bổ sung validateSeatInput(this) và label như bạn đã yêu cầu --%>
                <div id="divSearchName" class="space-y-1.5 search-group hidden">
                    <label class="text-xs text-gray-400 uppercase font-bold tracking-wider">Nhập tên ghế</label>
                    <input type="text" id="sSeatName" 
                           oninput="validateSeatInput(this)" 
                           placeholder="VD: A1, C12..." 
                           class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-3 py-2.5 text-white text-sm focus:border-blue-500 outline-none transition">
                </div>

                <div id="divSearchRow" class="hidden grid grid-cols-2 gap-2 search-group">
                    <div class="space-y-1.5">
                        <label class="text-[11px] text-gray-400 uppercase font-bold">Từ Hàng</label>
                        <input type="text" id="sRowStart" placeholder="A" class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-2 py-2 text-white text-sm text-center uppercase">
                    </div>
                    <div class="space-y-1.5">
                        <label class="text-[11px] text-gray-400 uppercase font-bold">Đến Hàng</label>
                        <input type="text" id="sRowEnd" placeholder="C" class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-2 py-2 text-white text-sm text-center uppercase">
                    </div>
                </div>

                <div id="divSearchCol" class="hidden grid grid-cols-2 gap-2 search-group">
                    <div class="space-y-1.5">
                        <label class="text-[11px] text-gray-400 uppercase font-bold">Từ Cột</label>
                        <input type="number" id="sColStart" placeholder="1" min="0" class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-2 py-2 text-white text-sm text-center">
                    </div>
                    <div class="space-y-1.5">
                        <label class="text-[11px] text-gray-400 uppercase font-bold">Đến Cột</label>
                        <input type="number" id="sColEnd" placeholder="5" min="0" class="w-full bg-[#0a0a0d] border border-gray-800 rounded-xl px-2 py-2 text-white text-sm text-center">
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-4 pt-4 border-t border-gray-800/60 flex flex-wrap gap-3 items-center justify-between">
            <div class="flex gap-2">
                <button onclick="searchAndHighlight()" type="button" class="bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-5 rounded-xl text-sm transition shadow-lg shadow-blue-900/30">
                    <i class="fas fa-filter mr-1"></i> Quét & Thêm vùng chọn
                </button>
                <button onclick="clearHighlight()" type="button" class="bg-gray-800 hover:bg-gray-700 text-gray-300 font-bold py-2 px-4 rounded-xl text-sm transition border border-gray-700">
                    <i class="fas fa-eraser mr-1"></i> Hủy chọn hoàn toàn
                </button>
            </div>

            <%-- Ẩn cụm nút Áp dụng hàng loạt nếu là mode View --%>
            <c:if test="${!isViewMode}">
                <div class="flex items-center gap-2 bg-[#0a0a0d] p-1.5 rounded-xl border border-gray-800">
                    <select id="bulkStatus" class="bg-transparent text-white text-xs px-2 py-1 outline-none font-bold">
                        <option value="Available" class="text-red-500">Hoạt Động (Trống)</option>
                        <option value="Maintenance" class="text-gray-400">Bảo trì / Khóa</option>
                    </select>
                    <button onclick="updateSelectedSeats()" type="button" class="bg-white hover:bg-gray-200 text-gray-900 font-black py-1.5 px-4 rounded-lg text-xs uppercase tracking-wider transition">
                        Áp Dụng Lên Ghế Đã Chọn
                    </button>
                </div>
            </c:if>
        </div>
    </div>
</div>

<div class="mb-8 relative overflow-hidden rounded-2xl border border-gray-800/80 shadow-[0_8px_30px_rgb(0,0,0,0.5)]">
    <div class="absolute inset-0 bg-gradient-to-br from-[#121212] via-[#1a1a24] to-[#121212] opacity-90"></div>
    <div class="absolute -top-24 -right-24 w-48 h-48 bg-red-600/10 blur-[50px] rounded-full"></div>

    <div class="relative p-6">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-5">
            <h3 class="text-lg font-black text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-amber-500 flex items-center tracking-wide">
                <i class="fas fa-calendar-check text-red-500 mr-3 animate-pulse"></i> 
                SUẤT CHIẾU 7 NGÀY TỚI ĐÃ PHÁT SINH VÉ
            </h3>
            <select id="showtimeDateFilter" class="bg-[#0a0a0d] border border-gray-800 text-gray-300 text-xs rounded-xl px-3 py-2 outline-none focus:border-red-500 transition font-bold cursor-pointer">
                <option value="ALL">📅 Tất cả ngày chiếu</option>
            </select>
        </div>

        <div class="overflow-x-auto custom-scrollbar rounded-xl border border-gray-800/50 bg-black/40 backdrop-blur-sm">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-gradient-to-r from-gray-900 to-gray-800 text-gray-400 text-xs uppercase tracking-widest border-b border-gray-800/80">
                        <th class="py-4 pl-5 font-bold">Phim Chiếu</th>
                        <th class="py-4 font-bold">Ngày Chiếu</th>
                        <th class="py-4 font-bold">Thời Gian</th>
                        <th class="py-4 pr-5 text-right font-bold">Tình Trạng Vé</th>
                    </tr>
                </thead>
                <tbody class="text-sm divide-y divide-gray-800/30">
                    <c:choose>
                        <c:when test="${not empty activeShowtimes}">
                            <c:forEach var="st" items="${activeShowtimes}">
                                <fmt:formatDate value="${st.showDate}" pattern="yyyy-MM-dd" var="formattedDate"/>
                                <tr class="showtime-row group hover:bg-white/[0.02] transition-all duration-300 hover:shadow-[inset_4px_0_0_#ef4444]" data-date="${formattedDate}">
                                    <td class="py-3 pl-5 font-bold text-white flex items-center space-x-4">
                                        <div class="relative">
                                            <c:if test="${not empty st.movie.posterUrl}">
                                                <img src="${st.movie.posterUrl}" class="w-10 h-14 object-cover rounded-lg shadow-lg group-hover:scale-110 transition-transform duration-300" alt="Poster">
                                            </c:if>
                                            <div class="absolute inset-0 border border-white/10 rounded-lg"></div>
                                        </div>
                                        <span class="group-hover:text-red-400 transition-colors tracking-wide"><c:out value="${st.movie.title}" /></span>
                                    </td>
                                    <td class="py-3 text-gray-300 font-medium tracking-wide">
                                        <i class="far fa-calendar text-gray-600 mr-2"></i><fmt:formatDate value="${st.showDate}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    <td class="py-3">
                                        <div class="flex items-center space-x-2">
                                            <span class="text-amber-500 font-black"><c:out value="${st.startTime}" /></span>
                                            <i class="fas fa-arrow-right text-gray-700 text-xs"></i>
                                            <span class="text-gray-500 font-medium"><fmt:formatDate value="${st.endTime}" pattern="HH:mm"/></span>
                                        </div>
                                    </td>
                                    <td class="py-3 pr-5 text-right">
                                        <div class="inline-flex items-center px-3 py-1.5 rounded-full bg-red-500/10 border border-red-500/30 shadow-[0_0_15px_rgba(239,68,68,0.15)] relative overflow-hidden group-hover:bg-red-500/20 transition-all">
                                            <span class="absolute w-1 h-full bg-red-500 left-0 top-0 animate-pulse"></span>
                                            <i class="fas fa-ticket-alt text-red-500 mr-2 text-xs"></i>
                                            <span class="text-red-400 font-black text-xs tracking-wider"><c:out value="${st.status}" /> VÉ ĐÃ BÁN</span>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4" class="py-12 text-center relative overflow-hidden">
                                    <div class="relative z-10 flex flex-col items-center justify-center opacity-40">
                                        <i class="fas fa-couch text-4xl mb-3 text-gray-600"></i>
                                        <span class="text-gray-400 font-semibold tracking-wider text-sm">KHÔNG CÓ SUẤT CHIẾU NÀO PHÁT SINH VÉ TRONG 7 NGÀY TỚI</span>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>
<div class="bg-[#121216] border border-gray-800 rounded-2xl p-8 shadow-2xl text-center relative overflow-hidden mb-8">
    <div class="w-2/3 max-w-2xl mx-auto h-1.5 bg-gradient-to-r from-transparent via-blue-500 to-transparent rounded-full mb-8 shadow-[0_4px_25px_rgba(59,130,246,0.6)]"></div>
    <p class="text-center text-gray-500 text-xs font-bold tracking-[0.6em] mb-6 uppercase">MÀN HÌNH CHIẾU / SCREEN CENTRIC</p>

    <div id="seatMapContainer" class="overflow-auto custom-scrollbar w-full max-h-[600px] border border-gray-900 bg-[#070709] rounded-2xl text-center relative">

        <c:set var="cols" value="${room.totalCols}" />
        <c:choose>
            <c:when test="${cols <= 6}">
                <c:set var="aisle1" value="-1" />
                <c:set var="aisle2" value="-1" />
                <c:set var="totalGridCols" value="${cols}" />
            </c:when>
            <c:when test="${cols <= 11}">
                <c:set var="aisle1" value="3" />
                <c:set var="aisle2" value="-1" />
                <c:set var="totalGridCols" value="${cols + 1}" />
            </c:when>
            <c:otherwise>
                <c:set var="aisle1" value="4" />
                <c:set var="aisle2" value="${cols - 4}" />
                <c:set var="totalGridCols" value="${cols + 2}" />
            </c:otherwise>
        </c:choose>

        <div class="seat-grid min-w-max mx-auto stairs-bg" 
             style="grid-template-columns: repeat(${totalGridCols}, minmax(40px, clamp(40px, 3.2vw, 60px)));">

            <c:forEach items="${seats}" var="seat">
                <c:set var="seatClasses" value="bg-red-600 text-white border-red-700 hover:bg-red-500 shadow-[inset_0_2px_3px_rgba(255,255,255,0.2)]" />
                <c:if test="${seat.status == 'Broken' || seat.status == 'Maintenance'}">
                    <c:set var="seatClasses" value="bg-[#242426] border-gray-800 text-gray-500 opacity-80" />
                </c:if>
                <c:if test="${seat.status == 'Sold' || seat.status == 'Booked' || seat.status == 'Reserved'}">
                    <c:set var="seatClasses" value="bg-blue-600 border-blue-800 text-blue-100 shadow-[0_0_12px_rgba(59,130,246,0.4)]" />
                </c:if>

                <c:set var="shift" value="0" />
                <c:if test="${aisle1 > 0 && seat.colPos > aisle1}">
                    <c:set var="shift" value="${shift + 1}" />
                </c:if>
                <c:if test="${aisle2 > 0 && seat.colPos > aisle2}">
                    <c:set var="shift" value="${shift + 1}" />
                </c:if>
                <c:set var="targetGridCol" value="${seat.colPos + shift}" />

                <div class="seat-item flex flex-col items-center justify-center text-[10px] sm:text-[11px] font-bold cursor-pointer border hover:-translate-y-1 transition-all ${seatClasses}"
                     style="grid-row: ${seat.rowPos}; grid-column: ${targetGridCol}; aspect-ratio: 1/1;"
                     title="Ghế ${seat.seatName} [Hàng ${seat.rowPos} - Cột ${seat.colPos}] - ${seat.status}"
                     onclick="handleSeatClick(this)"
                     id="seat-${seat.id_Seat}"
                     data-id="${seat.id_Seat}"
                     data-name="${seat.seatName}"
                     data-row="${seat.rowPos}"
                     data-col="${seat.colPos}"
                     data-status="${seat.status}">
                    <i class="fas fa-chair text-[14px] sm:text-[16px] mb-0.5"></i>
                    <span>${seat.seatName}</span>
                </div>
            </c:forEach>
        </div>
    </div>
    <div class="mt-6 flex flex-wrap justify-center gap-8 text-xs font-bold text-gray-400 border-t border-gray-800/80 pt-5">
        <div class="flex items-center gap-2.5">
            <div class="w-5 h-5 rounded bg-red-600 border border-red-700"></div> Hoạt động (Trống)
        </div>
        <div class="flex items-center gap-2.5">
            <div class="w-5 h-5 rounded bg-[#242426] border border-gray-800"></div> Bảo Trì / Khóa hệ thống
        </div>
        <div class="flex items-center gap-2.5">
            <div class="w-5 h-5 rounded bg-blue-600 border border-blue-800"></div> Đã bán (Bao gồm suất tương lai)
        </div>
        <div class="flex items-center gap-2.5">
            <div class="w-5 h-5 rounded bg-green-500 border border-green-600 animate-pulse"></div> Ghế đang được khoanh vùng lọc
        </div>
    </div>
</div>

<div id="customConfirmModal" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-md transition-all duration-300">
    <div class="bg-[#16171e] border border-gray-800 rounded-2xl p-6 max-w-md w-full mx-4 shadow-2xl transform scale-95 transition-transform duration-300">
        <div class="flex items-start gap-4 mb-4">
            <div id="modalIconContainer" class="w-12 h-12 rounded-full flex items-center justify-center text-xl shrink-0">
                <i id="modalIcon" class="fas fa-exclamation-triangle"></i>
            </div>
            <div>
                <h4 id="modalTitle" class="text-lg font-black text-white uppercase tracking-wider mb-1">Xác nhận thao tác</h4>
                <p id="modalDescription" class="text-xs text-gray-400 leading-relaxed"></p>
            </div>
        </div>
        <div class="flex justify-end gap-3 mt-6 border-t border-gray-800/80 pt-4">
            <button id="btnModalCancel" type="button" class="px-4 py-2 rounded-xl bg-gray-800 hover:bg-gray-700 text-gray-400 font-bold text-xs uppercase tracking-wider transition">Hủy bỏ</button>
            <button id="btnModalConfirm" type="button" class="px-5 py-2 rounded-xl text-white font-black text-xs uppercase tracking-wider transition shadow-lg">Xác nhận</button>
        </div>
    </div>
</div>

<div id="customSuccessModal" class="fixed inset-0 bg-black/60 z-[200] hidden flex items-center justify-center backdrop-blur-sm opacity-0 transition-opacity duration-300">
    <div id="customSuccessContent" class="bg-[#0b0c10] border border-emerald-500/30 rounded-2xl shadow-[0_0_50px_rgba(16,185,129,0.15)] w-full max-w-md overflow-hidden transform scale-95 transition-transform duration-300 p-6 text-center glass-card">
        <div class="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 mb-4 animate-bounce">
            <svg class="h-8 w-8" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>
        
        <h3 class="text-lg font-bold text-white uppercase tracking-wider mb-2">Thông Báo Hệ Thống</h3>
        <p id="customSuccessMessage" class="text-gray-300 text-sm font-medium leading-relaxed px-2">
            Cập nhật phòng chiếu và sơ đồ ghế thành công!
        </p>
        
        <div class="mt-6">
            <button type="button" onclick="closeCustomSuccessModal()" class="w-full bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold py-3 px-4 rounded-xl transition-all duration-200 shadow-lg shadow-emerald-600/20 active:scale-[0.98]">
                Xác Nhận
            </button>
        </div>
    </div>
</div>
             
<script>
    // BIẾN THÔNG MINH TỪ BACKEND
    const IS_VIEW_MODE = ${isViewMode}; // 1. Nhận biết từ JSP truyền xuống JS
    let isFormDirty = false; // Biến theo dõi thay đổi dữ liệu

    // =========================================================
    // HÀM KIỂM TRA VÉ BẤT ĐỒNG BỘ REAL-TIME (GỌI API BACKEND)
    // =========================================================
    async function checkFutureTickets(roomId) {
        try {
            const response = await fetch(`${pageContext.request.contextPath}/admin/rooms/check-future-tickets/` + roomId);
            if (!response.ok) return 0;
            const count = await response.json(); // Giả định trả về số nguyên integer số lượng vé đã bán
            return parseInt(count) || 0;
        } catch (error) {
            console.error("Lỗi khi kiểm tra vé:", error);
            return 0; // Nếu lỗi kết nối, giả định là 0 để không chặn nhầm luồng xử lý
        }
    }

    // =========================================================
    // 1. CHẠY NGAY KHI LOAD TRANG (Chặn rời đi & Lọc Ngày)
    // =========================================================
    document.addEventListener("DOMContentLoaded", function () {
        // A. Theo dõi Form xem người dùng có sửa Giá, Hàng, Cột không
        const formFields = document.querySelectorAll("form input, form select");
        formFields.forEach(field => {
            field.addEventListener("change", () => {
                isFormDirty = true;
            });
        });

        // B. Chặn nút quay lại danh sách nếu quên lưu
        const btnBack = document.getElementById("btnBackToList");
        if (btnBack) {
            btnBack.addEventListener("click", function (e) {
                if (isFormDirty) {
                    e.preventDefault(); // Chặn chuyển trang
                    openCustomModal({
                        title: "CẢNH BÁO RỜI ĐI",
                        description: "Bạn có những thay đổi chưa lưu (như Giá phòng, Hàng, Cột). Bạn có chắc chắn muốn rời đi mà không lưu không?",
                        type: 'warning',
                        onConfirm: () => {
                            window.location.href = btnBack.getAttribute("href");
                        }
                    });
                }
            });
        }

        // C. Logic lọc Bảng Suất chiếu (7 ngày)
        const showtimeRows = document.querySelectorAll(".showtime-row");
        const dateFilter = document.getElementById("showtimeDateFilter");
        if (dateFilter && showtimeRows.length > 0) {
            const uniqueDates = new Set();
            showtimeRows.forEach(row => uniqueDates.add(row.dataset.date));

            uniqueDates.forEach(date => {
                let option = document.createElement("option");
                option.value = date;
                option.textContent = "Ngày: " + date;
                dateFilter.appendChild(option);
            });

            // Khi người dùng chọn ngày ở Dropdown
            dateFilter.addEventListener("change", function () {
                const selectedDate = this.value;
                showtimeRows.forEach(row => {
                    if (selectedDate === "ALL" || row.dataset.date === selectedDate) {
                        row.style.display = "";
                        row.style.animation = "fadeIn 0.5s ease"; // Animation xuất hiện
                    } else {
                        row.style.display = "none";
                    }
                });
            });
        }
    });

    // =========================================================
    // 2. MODAL GIAO DIỆN XỊN (LỖI / CONFIRM)
    // =========================================================
    function openCustomModal({ title, description, type, onConfirm }) {
        const modal = document.getElementById('customConfirmModal');
        const mTitle = document.getElementById('modalTitle');
        const mDesc = document.getElementById('modalDescription');
        const mIconBox = document.getElementById('modalIconContainer');
        const mIcon = document.getElementById('modalIcon');
        const btnConfirm = document.getElementById('btnModalConfirm');
        const btnCancel = document.getElementById('btnModalCancel');

        mTitle.innerText = title;
        mDesc.innerText = description;

        if (type === 'danger' || type === 'warning') {
            mIconBox.className = "w-12 h-12 rounded-full bg-yellow-500/10 flex items-center justify-center text-xl text-yellow-500";
            mIcon.className = "fas fa-exclamation-triangle";
            btnConfirm.className = "px-5 py-2 rounded-xl bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-black text-xs uppercase tracking-wider transition shadow-[0_0_15px_rgba(234,179,8,0.3)]";
        } else {
            mIconBox.className = "w-12 h-12 rounded-full bg-green-500/10 flex items-center justify-center text-xl text-green-500";
            mIcon.className = "fas fa-check-circle";
            btnConfirm.className = "px-5 py-2 rounded-xl bg-green-600 hover:bg-green-500 text-white font-black text-xs uppercase tracking-wider transition shadow-[0_0_15px_rgba(22,163,74,0.4)]";
        }

        modal.classList.remove('hidden');

        btnCancel.onclick = () => {
            modal.classList.add('hidden');
            const statusSelect = document.getElementById('roomStatusSelect');
            if (statusSelect)
                statusSelect.value = statusSelect.getAttribute('data-current');
        };

        btnConfirm.onclick = () => {
            modal.classList.add('hidden');
            if (onConfirm)
                onConfirm();
        };
    }

    function showException(msg) {
        const box = document.getElementById('exceptionNotice');
        if (box) {
            document.getElementById('exceptionMessage').innerText = msg;
            box.classList.remove('hidden');
            box.scrollIntoView({behavior: 'smooth', block: 'center'});
            setTimeout(() => box.classList.add('hidden'), 8000);
        } else {
            alert(msg);
        }
    }

    // =========================================================
    // 3. XỬ LÝ ẤN NÚT LƯU FORM (Xác nhận & Kiểm tra Chặn vé bất đồng bộ)
    // =========================================================
    const mainForm = document.getElementById('updateRoomForm') || document.getElementById('roomUpdateForm');
    if (mainForm) {
        mainForm.onsubmit = async function (e) {
            e.preventDefault(); // Luôn chặn mặc định để chạy kiểm tra bất đồng bộ
            const form = this;
            const formData = new FormData(form);

            const statusSelect = document.getElementById('roomStatusSelect');
            const currentStatus = statusSelect ? statusSelect.getAttribute('data-current') : null;
            const newStatus = statusSelect ? statusSelect.value : null;
            const roomId = document.getElementById("id_Room") ? document.getElementById("id_Room").value : null;

            // Kiểm tra trường hợp chuyển trạng thái từ Active sang Maintenance (Bảo trì)
            if (newStatus === 'Maintenance' && currentStatus === 'Active') {
                if (roomId) {
                    // Gọi API kiểm tra số lượng vé thực tế real-time từ Server
                    const ticketCount = await checkFutureTickets(roomId);
                    if (ticketCount > 0) {
                        showException("⛔ TỪ CHỐI THAO TÁC: Không thể chuyển sang trạng thái Bảo Trì! Có " + ticketCount + " vé đã được mua trong 7 ngày tới.");
                        statusSelect.value = currentStatus;
                        return; // Kết thúc chặn gửi form
                    }
                }
                
                // Nếu không có vé, tiến hành hiển thị modal xác nhận
                openCustomModal({
                    title: "⚠️ Thiết lập Bảo trì",
                    description: "Khóa toàn bộ ghế sang 'Bảo trì'. Khách sẽ không thể mua vé. Xác nhận lưu?",
                    type: 'warning',
                    onConfirm: () => {
                        executeAjaxSubmit(form, formData);
                    }
                });
                return;
            }

            if (newStatus === 'Active' && currentStatus === 'Maintenance') {
                openCustomModal({
                    title: "🚀 Mở lại Phòng Chiếu",
                    description: "Khôi phục toàn bộ các ghế đang bảo trì trở lại 'Trống'. Xác nhận lưu?",
                    type: 'success',
                    onConfirm: () => {
                        executeAjaxSubmit(form, formData);
                    }
                });
                return;
            }

            // Hỏi xác nhận cập nhật thông thường (Giá tiền/Tên phòng/v.v.)
            openCustomModal({
                title: "Xác nhận Cập nhật",
                description: "Hệ thống sẽ lưu thay đổi thuộc tính phòng chiếu. Tiếp tục?",
                type: 'success',
                onConfirm: () => {
                    executeAjaxSubmit(form, formData);
                }
            });
        };
    }

    // HÀM GỬI FORM AJAX KÈM SHOW MODAL ĐẸP
    function executeAjaxSubmit(form, formData) {
        const urlEncodedData = new URLSearchParams();
        for (const pair of formData.entries()) {
            urlEncodedData.append(pair[0], pair[1]);
        }

        fetch(form.action, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            },
            body: urlEncodedData 
        })
        .then(async response => {
            const resultText = await response.text();
            if (response.ok) {
                isFormDirty = false;
                showCustomSuccessModal(resultText); 
            } else {
                showException(resultText);
            }
        })
        .catch(err => showException("Lỗi kết nối máy chủ!"));
    }

    // =========================================================
    // 4. XỬ LÝ CLICK GHẾ ĐƠN LẺ & HÀNG LOẠT
    // =========================================================
    function handleSeatClick(el) {
        if (IS_VIEW_MODE) {
            return; 
        }

        const statusSelect = document.getElementById('roomStatusSelect');
        const roomStatus = statusSelect ? statusSelect.getAttribute('data-current') : null;
        if (roomStatus === 'Maintenance') {
            showException("⛔ Chặn thao tác: Phòng chiếu đang BẢO TRÌ. Không thể đổi trạng thái ghế!");
            return;
        }

        const currentStatus = el.getAttribute('data-status');
        let newStatus = (currentStatus === 'Available') ? 'Maintenance' : 'Available';

        applyStatusUI(el, newStatus);
        const seatId = el.getAttribute('data-id');

        fetch(`${pageContext.request.contextPath}/admin/rooms/update-seat?id=` + seatId + `&status=` + newStatus, {method: 'POST'})
                .then(async (res) => {
                    if (!res.ok) {
                        const errText = await res.text();
                        throw new Error(errText);
                    }
                })
                .catch((err) => {
                    applyStatusUI(el, currentStatus);
                    el.classList.add('animate-bounce');
                    setTimeout(() => el.classList.remove('animate-bounce'), 500);
                    showException(err.message || "Lỗi kết nối máy chủ khi cập nhật ghế.");
                });
    }

    async function updateSelectedSeats() {
        const statusSelect = document.getElementById('roomStatusSelect');
        const roomStatus = statusSelect ? statusSelect.getAttribute('data-current') : null;
        if (roomStatus === 'Maintenance') {
            showException("⛔ Chặn thao tác: Phòng chiếu đang BẢO TRÌ. Không thể cập nhật ghế hàng loạt!");
            return;
        }

        const selected = document.querySelectorAll('.seat-selected');
        if (selected.length === 0) {
            showException("Hãy thực hiện quét chọn khoanh vùng ghế trước!");
            return;
        }

        const newStatus = document.getElementById('bulkStatus').value;
        let errorMessages = [];

        const promises = Array.from(selected).map(async (seat) => {
            const seatId = seat.getAttribute('data-id');
            const currentStatus = seat.getAttribute('data-status');

            applyStatusUI(seat, newStatus);
            seat.classList.remove('seat-selected');

            try {
                const res = await fetch(`${pageContext.request.contextPath}/admin/rooms/update-seat?id=` + seatId + `&status=` + newStatus, {method: 'POST'});
                if (!res.ok) {
                    const errText = await res.text();
                    throw new Error(errText);
                }
            } catch (err) {
                applyStatusUI(seat, currentStatus);
                errorMessages.push(err.message);
            }
        });

        await Promise.all(promises);

        if (errorMessages.length > 0) {
            const uniqueErrors = [...new Set(errorMessages)];
            showException(uniqueErrors.join(" | "));
        }
    }

    function applyStatusUI(el, status) {
        el.setAttribute('data-status', status);
        el.title = `Ghế ${el.getAttribute('data-name')} - Trạng thái: ${status}`;
        el.className = `seat-item flex flex-col items-center justify-center text-[10px] sm:text-[11px] font-bold cursor-pointer border hover:-translate-y-1 transition-all`;

        if (status === 'Available') {
            el.classList.add('bg-red-600', 'text-white', 'border-red-700', 'shadow-[inset_0_2px_3px_rgba(255,255,255,0.2)]');
        } else if (status === 'Maintenance' || status === 'Broken') {
            el.classList.add('bg-[#242426]', 'border-gray-800', 'text-gray-500', 'opacity-80');
        } else {
            el.classList.add('bg-blue-600', 'border-blue-800', 'text-blue-100', 'shadow-[0_0_12px_rgba(59,130,246,0.4)]');
        }
    }

    function validateSeatInput(inputEl) {
        let val = inputEl.value;
        if (val.length > 0) {
            let firstChar = val.charAt(0);
            if (!/[a-zA-Z]/.test(firstChar)) {
                inputEl.value = "";
                return;
            }
            if (val.length > 1) {
                let rest = val.substring(1).replace(/[^0-9]/g, '');
                inputEl.value = firstChar + rest;
            }
        }
    }

    // =========================================================
    // 5. BỘ TÌM KIẾM THEO TỌA ĐỘ
    // =========================================================
    function charToNum(char) {
        if (!char)
            return 0;
        char = char.toUpperCase().trim();
        if (!isNaN(char))
            return parseInt(char);
        return char.charCodeAt(0) - 64;
    }

    document.addEventListener("DOMContentLoaded", function() {
        if(typeof toggleSearchMode === "function") {
            toggleSearchMode();
        }
    });

    function evaluateBounds(startVal, endVal, isNumeric = false) {
        let s = isNumeric ? (parseInt(startVal) || 0) : charToNum(startVal);
        let e = isNumeric ? (parseInt(endVal) || 0) : charToNum(endVal);

        if ((s === 0 && e === 0) || (s === e && s !== 0))
            return {mode: 'all'};
        if (s > 0 && e === 0)
            return {mode: 'exact', target: s};
        if (s === 0 && e > 0)
            return {mode: 'exact', target: e};
        return {mode: 'range', min: Math.min(s, e), max: Math.max(s, e)};
    }

    function searchAndHighlight() {
        const mode = document.getElementById('searchMode').value;
        const seats = document.querySelectorAll('.seat-item');
        let firstMatch = null;

        const nameInput = document.getElementById('sSeatName') ? document.getElementById('sSeatName').value.toUpperCase().trim() : '';
        const rowStartRaw = document.getElementById('sRowStart') ? document.getElementById('sRowStart').value : '';
        const rowEndRaw = document.getElementById('sRowEnd') ? document.getElementById('sRowEnd').value : '';
        const colStartRaw = document.getElementById('sColStart') ? document.getElementById('sColStart').value : '';
        const colEndRaw = document.getElementById('sColEnd') ? document.getElementById('sColEnd').value : '';

        const rowFilter = evaluateBounds(rowStartRaw, rowEndRaw, false);
        const colFilter = evaluateBounds(colStartRaw, colEndRaw, true);

        clearHighlight();

        seats.forEach(seat => {
            const r = parseInt(seat.getAttribute('data-row'));
            const c = parseInt(seat.getAttribute('data-col'));
            const name = seat.getAttribute('data-name').toUpperCase();
            let isMatch = false;

            if (mode === 'name') {
                if (nameInput !== "" && name === nameInput)
                    isMatch = true;
            } else if (mode === 'row') {
                isMatch = matchAxis(r, rowFilter);
            } else if (mode === 'col') {
                isMatch = matchAxis(c, colFilter);
            } else if (mode === 'area') {
                isMatch = matchAxis(r, rowFilter) && matchAxis(c, colFilter);
            }

            if (isMatch) {
                seat.classList.add('seat-selected');
                if (!firstMatch)
                    firstMatch = seat;
            }
        });

        if (firstMatch) {
            firstMatch.scrollIntoView({behavior: 'smooth', block: 'center'});
        } else {
            showException("Không quét thêm được vị trí ghế mới nào phù hợp.");
        }
    }

    function matchAxis(val, filter) {
        if (filter.mode === 'all')
            return true;
        if (filter.mode === 'exact')
            return val === filter.target;
        if (filter.mode === 'range')
            return val >= filter.min && val <= filter.max;
        return false;
    }

    function clearHighlight() {
        document.querySelectorAll('.seat-selected').forEach(el => el.classList.remove('seat-selected'));
    }

    function toggleSearchMode() {
        const mode = document.getElementById('searchMode') ? document.getElementById('searchMode').value : null;
        if (!mode)
            return;

        document.querySelectorAll('.search-group').forEach(el => el.classList.add('hidden'));
        if (mode === 'name')
            document.getElementById('divSearchName').classList.remove('hidden');
        if (mode === 'row' || mode === 'area')
            document.getElementById('divSearchRow').classList.remove('hidden');
        if (mode === 'col' || mode === 'area')
            document.getElementById('divSearchCol').classList.remove('hidden');
    }
    // =========================================================
    // HÀM MỞ/ĐÓNG MODAL THÔNG BÁO THÀNH CÔNG ĐẸP
    // =========================================================
    function showCustomSuccessModal(message) {
        const modal = document.getElementById('customSuccessModal');
        const content = document.getElementById('customSuccessContent');
        const msgTemplate = document.getElementById('customSuccessMessage');

        if (message) {
            msgTemplate.innerText = message;
        }

        // Hiện Modal & Kích hoạt hiệu ứng animation
        modal.classList.remove('hidden');
        modal.classList.add('flex');

        setTimeout(() => {
            modal.classList.remove('opacity-0');
            content.classList.remove('scale-95');
            content.classList.add('scale-100');
        }, 10);
    }

    function closeCustomSuccessModal() {
        const modal = document.getElementById('customSuccessModal');
        const content = document.getElementById('customSuccessContent');

        modal.classList.add('opacity-0');
        content.classList.remove('scale-100');
        content.classList.add('scale-95');

        // Đợi hiệu ứng tắt hoàn tất rồi mới ẩn hẳn
        setTimeout(() => {
            modal.classList.remove('flex');
            modal.classList.add('hidden');
            // Reload lại trang để cập nhật sơ đồ ghế mới nhất (giữ nguyên logic gốc)
            window.location.reload();
        }, 300);
    }
    
    window.addEventListener('DOMContentLoaded', toggleSearchMode);
</script>

<style>
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(-5px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    /* Hiệu ứng hover rực rỡ cho dòng hiển thị suất chiếu */
    .showtime-row:hover {
        background-color: rgba(239, 68, 68, 0.1);
        transform: scale(1.01);
        transition: all 0.2s ease-in-out;
        box-shadow: 0 4px 10px rgba(0,0,0,0.3);
    }
</style>