<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* Ràng buộc cắt text dài (Ellipsis) cho tên phim */
    .line-clamp-1 {
        display: -webkit-box;
        -webkit-line-clamp: 1;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    /* Hiệu ứng phát sáng cao cấp cho nút bấm ở Header */
    .premium-glow {
        box-shadow: 0 0 15px rgba(239, 68, 68, 0.2);
        transition: all 0.3s ease-in-out;
    }
    .premium-glow:hover {
        box-shadow: 0 0 25px rgba(239, 68, 68, 0.5);
        transform: translateY(-2px);
    }

    /* ========================================================
       FIX LỖI LỆCH CỘT BẢNG VÀ TẠO HIỆU ỨNG VIỀN CHẠY
       ======================================================== */
    .showtime-row {
        transition: background-color 0.4s ease;
        position: relative;
        z-index: 1;
    }

    .showtime-row td {
        position: relative; /* Cần thiết cho viền chạy */
        transition: all 0.4s ease;
    }

    .showtime-row:hover {
        background-color: #161616 !important; /* Đổi màu nền khi hover */
        z-index: 50;
    }

    /* Chuyển hiệu ứng "BỰ LÊN" vào phần tử bên trong (inner-content) để giữ an toàn cho bảng */
    .showtime-row .inner-content {
        transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        transform-origin: left center;
    }
    .showtime-row:hover .inner-content {
        transform: scale(1.05); /* LÀM NỘI DUNG BỰ HƠN XÍU */
    }
    .showtime-row td.text-center .inner-content {
        transform-origin: center center; /* Cột trạng thái và thao tác thì bự từ giữa ra */
    }

    /* Bóng đổ đỏ nhẹ sau lưng dòng khi Hover */
    .showtime-row:hover td {
        box-shadow: 0 10px 30px -10px rgba(239, 68, 68, 0.3);
    }

    /* HIỆU ỨNG VIỀN ĐỘNG CHẠY (RUNNING BORDER) */
    .showtime-row td::before, .showtime-row td::after {
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
    /* Chạy viền trên và viền dưới */
    .showtime-row td::before {
        top: 0;
        animation: borderRunRight 1.5s linear infinite;
    }
    .showtime-row td::after {
        bottom: 0;
        animation: borderRunLeft 1.5s linear infinite;
    }

    /* Khi để chuột vô dòng -> Hiện viền chạy lên */
    .showtime-row:hover td::before, .showtime-row:hover td::after {
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

    /* ========================================================
       CÁC HIỆU ỨNG HIỆN ĐẠI ĐỘC ĐÁO CŨ (GIỮ NGUYÊN)
       ======================================================== */
    .badge-pulse {
        animation: pulseGlow 2s infinite;
    }
    @keyframes pulseGlow {
        0% {
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.4);
        }
        70% {
            box-shadow: 0 0 0 6px rgba(34, 197, 94, 0);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0);
        }
    }

    /* Tia lấp lánh (Shimmer) lướt qua Poster khi hover */
    .shimmer-img::after {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 50%;
        height: 100%;
        background: linear-gradient(to right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.3) 50%, rgba(255,255,255,0) 100%);
        transform: skewX(-25deg);
        animation: shimmer 1.5s infinite;
        display: none;
        z-index: 5;
    }
    .showtime-row:hover .shimmer-img::after {
        display: block;
    }
    @keyframes shimmer {
        0% {
            left: -100%;
        }
        100% {
            left: 200%;
        }
    }

    /* 1. Hiệu ứng bay đàn hồi (Elastic Fly-In) lướt từ rìa phải vào */
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

    /* 2. FIX MỚI: Hiệu ứng ẩn dần, thu nhỏ và lướt nhẹ ra sau khi biến mất (Premium Fade & Zoom Out) */
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

    /* 3. Hiệu ứng thanh tiến trình thời gian co rút dưới đáy */
    @keyframes toastTimeline {
        0% {
            width: 100%;
        }
        100% {
            width: 0%;
        }
    }

    /* 4. Hiệu ứng viền phát sáng Neon mạch đập (Ambient Glow Pulse) */
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

    /* Class điều khiển hoạt họa */
    .toast-item {
        animation: toastFlyIn 0.55s cubic-bezier(0.25, 1, 0.5, 1) forwards;
        will-change: transform, opacity;
    }
    /* Class kích hoạt khi ẩn biến mất */
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

    @keyframes subtleBounce {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-3px);
        }
    }
    .animate-subtle-bounce {
        animation: subtleBounce 2.5s ease-in-out infinite;
    }
</style>

<%-- KHAY CHỨA TOAST LƠ LỬNG (Cố định góc trên bên phải, tự xếp chồng thông minh) --%>
<div id="premium-toast-container" class="fixed top-6 right-6 z-[9999] flex flex-col gap-4 w-full max-w-sm pointer-events-none"></div>

<%-- CẦU NỐI CHỨA DỮ LIỆU CHỮ AN TOÀN TỪ BACKEND --%>
<input type="hidden" id="backend-error-bridge" value="${not empty systemErrorMsg ? systemErrorMsg : errorMessage}">
<input type="hidden" id="backend-success-bridge" value="${not empty successMsg ? successMsg : successMessage}">
<div class="p-4 sm:p-6 space-y-6">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center bg-gradient-to-r from-[#1a1a1a] to-[#121212] p-5 rounded-2xl border border-gray-800/60 shadow-xl gap-4 relative overflow-hidden">
        <div class="absolute -top-10 -right-10 w-40 h-40 bg-red-600/10 blur-[50px] rounded-full pointer-events-none"></div>

        <div class="relative z-10">
            <h2 class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white to-gray-400 tracking-wide uppercase">Quản lý Suất Chiếu</h2>
            <p class="text-gray-400 text-sm mt-1 flex items-center gap-2">
                <i class="fas fa-calendar-alt text-red-500"></i> Sắp xếp và quản lý lịch chiếu phim tại các phòng
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/showtimes/add" class="relative z-10 premium-glow bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white px-5 py-2.5 rounded-xl font-medium flex items-center gap-2">
            <i class="fas fa-plus-circle"></i> <span>Thêm suất chiếu</span>
        </a>
    </div>


    <div class="bg-[#1a1a1a] p-5 rounded-2xl border border-gray-800/60 shadow-xl space-y-4 overflow-visible">
        <div class="flex items-center gap-2 pb-2 border-b border-gray-800/60">
            <i class="fas fa-filter text-red-500 text-sm"></i>
            <span class="text-xs font-bold text-gray-200 uppercase tracking-wider">Bộ lọc suất chiếu liên kết nâng cao</span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 overflow-visible">
            <div class="flex flex-col space-y-1">
                <label class="text-xs font-semibold text-gray-400">Từ khóa tên phim</label>
                <input type="text" id="filterMovieTitle" placeholder="Tất cả phim" 
                       class="w-full bg-[#121212] text-white text-xs px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
            </div>

            <div class="flex flex-col space-y-1">
                <label class="text-xs font-semibold text-gray-400">Trạng thái suất chiếu</label>
                <select name="status" id="filterShowtimeStatus" 
                        class="w-full bg-[#121212] text-white text-xs px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    <option value="">Tất cả trạng thái suất</option>
                    <option value="Đang chiếu" ${selectedStatus == 'Đang chiếu' ? 'selected' : ''}>Đang chiếu</option>
                    <option value="Sắp chiếu" ${selectedStatus == 'Sắp chiếu' ? 'selected' : ''}>Sắp chiếu</option>
                    <option value="Đã chiếu" ${selectedStatus == 'Đã chiếu' ? 'selected' : ''}>Đã chiếu</option>
                </select>
            </div>

            <div class="flex flex-col space-y-1">
                <label class="text-xs font-semibold text-gray-400">Trạng thái phòng chiếu</label>
                <select id="filterRoomStatus" onchange="onRoomStatusChange()"
                        class="w-full bg-[#121212] text-white text-xs px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    <option value="">Tất cả trạng thái phòng</option>
                    <option value="Active">Hoạt động (Active)</option>
                    <option value="Maintenance">Bảo trì (Maintenance)</option>
                </select>
            </div>

            <div class="flex flex-col space-y-1 relative overflow-visible">
                <label class="text-xs font-semibold text-gray-400">Tên phòng chiếu</label>
                <div class="relative">
                    <input type="text" id="filterRoomNameDisplay" readonly placeholder="Tất cả phòng" onclick="toggleRoomDropdown(event)"
                           class="w-full bg-[#121212] text-white text-xs px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none cursor-pointer transition">
                    <input type="hidden" id="filterRoomNameValue" value="">
                    <span class="absolute right-3 top-3.5 text-gray-500 pointer-events-none text-[10px]"><i class="fas fa-chevron-down"></i></span>
                </div>

                <div id="customRoomDropdownPanel" class="hidden absolute left-0 right-0 top-[62px] bg-[#1a1a1a] border border-gray-800 rounded-xl shadow-2xl p-3 z-50 space-y-2 max-h-[240px] overflow-y-auto">
                    <input type="text" id="roomKeywordSearch" placeholder="Nhập từ khóa tìm phòng..." oninput="filterRoomListItems()"
                           class="w-full bg-[#121212] text-white text-xs px-2.5 py-1.5 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    <ul id="roomSelectableList" class="space-y-1 pt-1 max-h-[140px] overflow-y-auto">
                    </ul>
                </div>
            </div>

            <div class="flex flex-col space-y-1">
                <label class="text-xs font-semibold text-gray-400">Loại phòng chiếu</label>
                <select name="roomType" id="filterRoomType" class="w-full bg-[#121212] text-white text-xs px-3 py-2.5 rounded-xl border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    <option value="">Tất cả loại phòng</option>
                    <option value="Standard" ${selectedRoomType == 'Standard' ? 'selected' : ''}>Standard</option>
                    <option value="VIP" ${selectedRoomType == 'VIP' ? 'selected' : ''}>VIP</option>
                    <option value="IMAX" ${selectedRoomType == 'IMAX' ? 'selected' : ''}>IMAX</option>
                    <option value="4DX" ${selectedRoomType == '4DX' ? 'selected' : ''}>4DX</option>
                    <option value="Sweetbox" ${selectedRoomType == 'Sweetbox' ? 'selected' : ''}>Sweetbox</option>
                </select>
            </div>
        </div>

        <div class="mt-4 pt-4 border-t border-gray-800/40">
            <div class="flex justify-between items-center mb-3">
                <div class="flex items-center gap-4">
                    <label class="text-xs font-semibold text-gray-400"><i class="fas fa-clock text-red-500 mr-1"></i> Bộ lọc Khoảng Thời Gian</label>
                    <select id="timeFilterMode" class="bg-[#121212] text-gray-300 text-xs px-3 py-1.5 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition cursor-pointer">
                        <option value="strict">Lọc chính xác (Nằm hoàn toàn trong khoảng)</option>
                        <option value="overlap">Lọc theo khoảng (Chỉ cần có chứa một phần)</option>
                    </select>
                </div>
                <button type="button" onclick="resetDateTimeFilter()" title="Quay lại tất cả suất ở mọi mốc thời gian"
                        class="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 text-gray-400 hover:text-white rounded-lg transition text-xs flex items-center justify-center gap-1.5 shrink-0">
                    <i class="fas fa-undo-alt"></i> Xóa giờ
                </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="space-y-3 p-4 rounded-xl border border-gray-800/80 bg-[#141414]">
                    <div class="flex justify-between items-center border-b border-gray-800 pb-2">
                        <span class="text-[11px] font-bold text-gray-300 uppercase tracking-wider block">Thời gian bắt đầu</span>
                        <div class="relative group cursor-pointer" title="Chọn ngày giờ tự động">
                            <i class="fas fa-calendar-plus text-red-500 hover:text-red-400 transition text-sm" onclick="document.getElementById('autoFillStart').showPicker()"></i>
                            <input type="datetime-local" id="autoFillStart" onchange="autoFillDateTime('start', this.value)" class="absolute w-0 h-0 opacity-0 -z-10">
                        </div>
                    </div>
                    <div class="grid grid-cols-3 gap-2.5">
                        <input type="number" id="startDay" placeholder="Ngày" min="1" max="31" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="startMonth" placeholder="Tháng" min="1" max="12" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="startYear" placeholder="Năm" min="2000" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="startHour" placeholder="Giờ" min="0" max="23" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="startMinute" placeholder="Phút" min="0" max="59" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="startSecond" placeholder="Giây" min="0" max="59" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    </div>
                </div>

                <div class="space-y-3 p-4 rounded-xl border border-gray-800/80 bg-[#141414]">
                    <div class="flex justify-between items-center border-b border-gray-800 pb-2">
                        <span class="text-[11px] font-bold text-gray-300 uppercase tracking-wider block">Thời gian kết thúc</span>
                        <div class="relative group cursor-pointer" title="Chọn ngày giờ tự động">
                            <i class="fas fa-calendar-check text-red-500 hover:text-red-400 transition text-sm" onclick="document.getElementById('autoFillEnd').showPicker()"></i>
                            <input type="datetime-local" id="autoFillEnd" onchange="autoFillDateTime('end', this.value)" class="absolute w-0 h-0 opacity-0 -z-10">
                        </div>
                    </div>
                    <div class="grid grid-cols-3 gap-2.5">
                        <input type="number" id="endDay" placeholder="Ngày" min="1" max="31" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="endMonth" placeholder="Tháng" min="1" max="12" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="endYear" placeholder="Năm" min="2000" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="endHour" placeholder="Giờ" min="0" max="23" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="endMinute" placeholder="Phút" min="0" max="59" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                        <input type="number" id="endSecond" placeholder="Giây" min="0" max="59" class="w-full bg-[#121212] text-center text-white text-xs px-2 py-2 rounded-lg border border-gray-800 focus:border-red-500 focus:outline-none transition">
                    </div>
                </div>
            </div>
        </div>

        <div class="flex justify-end items-center gap-3 pt-2 border-t border-gray-800/40 mt-4">
            <button type="button" onclick="resetAllFilters()" 
                    class="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white rounded-xl text-xs font-medium transition flex items-center gap-1.5">
                <i class="fas fa-eraser"></i> Xóa bộ lọc
            </button>
            <button type="button" onclick="executeShowtimeFiltering()" 
                    class="px-5 py-2 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white rounded-xl text-xs font-bold shadow-lg shadow-red-600/10 hover:shadow-red-600/30 transition transform hover:-translate-y-0.5 flex items-center gap-1.5">
                <i class="fas fa-search"></i> Lọc kết quả
            </button>
        </div>
    </div>

    <div class="bg-[#1a1a1a]/80 backdrop-blur-md rounded-2xl border border-gray-800 shadow-2xl overflow-visible">
        <div class="overflow-visible rounded-xl bg-[#121212] relative z-10 w-full">
            <table class="w-full text-sm text-left text-gray-400 border-collapse">
                <thead class="text-xs text-gray-300 uppercase bg-gradient-to-r from-[#1a1a1a] to-[#121212] border-b border-gray-800">
                    <tr>
                        <th scope="col" class="p-5 font-semibold tracking-wider w-[30%]">Thông Tin Phim</th>
                        <th scope="col" class="p-5 font-semibold tracking-wider w-[25%]">Phòng Chiếu</th>
                        <th scope="col" class="p-5 font-semibold tracking-wider w-[20%]">Thời Gian</th>
                        <th scope="col" class="p-5 font-semibold tracking-wider text-center w-[15%]">Trạng Thái</th>
                        <th scope="col" class="p-5 font-semibold tracking-wider text-center w-[10%]">Thao Tác</th>
                    </tr>
                </thead>
                <tbody id="showtimeTableBody">
                    <c:forEach items="${showtimes}" var="st">
                        <tr class="showtime-row border-b border-gray-800/60 group"
                            data-movie-title="${st.movie.title}"
                            data-showtime-status="${st.displayStatus}" 
                            data-room-name="${st.room.roomName}"
                            data-room-type="${st.room.roomType != null ? st.room.roomType : 'Standard'}"
                            data-show-date="<fmt:formatDate value='${st.showDate}' pattern='yyyy-MM-dd' />"
                            data-start-time="<fmt:formatDate value='${st.startTime}' pattern='HH:mm:ss' />"
                            data-end-time="<fmt:formatDate value='${st.endTime}' pattern='HH:mm:ss' />">

                            <td class="p-4">
                                <div class="inner-content flex items-center gap-4">
                                    <div class="relative overflow-hidden rounded-lg shadow-lg border border-gray-700/50 shimmer-img shrink-0">
                                        <img src="${st.movie.posterUrl}" alt="Poster" 
                                             class="w-[64px] h-[90px] object-cover transform group-hover:scale-110 transition-transform duration-500">
                                    </div>
                                    <div class="flex flex-col">
                                        <h4 class="font-bold text-white text-base group-hover:text-red-400 transition-colors duration-300 line-clamp-2 leading-tight">
                                            ${st.movie.title}
                                        </h4>
                                        <span class="text-[11px] text-gray-500 mt-1"><i class="fas fa-film mr-1 text-gray-600"></i>Suất chiếu chuẩn</span>
                                    </div>
                                </div>
                            </td>

                            <td class="p-4">
                                <div class="inner-content flex items-center gap-3">
                                    <div class="relative overflow-hidden rounded-xl border border-gray-700 shadow-lg shrink-0 shimmer-img">
                                        <c:choose>
                                            <c:when test="${st.room.roomType == 'VIP'}">
                                                <img src="https://iguov8nhvyobj.vcdn.cloud/media/wysiwyg/special-cinemas/000.jpg" class="w-[84px] h-[56px] object-cover">
                                            </c:when>
                                            <c:when test="${st.room.roomType == 'IMAX'}">
                                                <img src="https://cinematone.info/public/cover/2018_04_28CgsoQIinkkSu64HKW.jpg" class="w-[84px] h-[56px] object-cover">
                                            </c:when>
                                            <c:when test="${st.room.roomType == '4DX'}">
                                                <img src="https://image.made-in-china.com/202f0j00ifCUGyvrhVcM/4D-Movie-Theater-Motion-Platform-5D-Cinema-4dx-Movie-Theater.jpg" class="w-[84px] h-[56px] object-cover">
                                            </c:when>
                                            <c:when test="${st.room.roomType == 'Sweetbox'}">
                                                <img src="https://cdn.moveek.com/storage/media/cache/large/5ERv8X2apK.jpg" class="w-[84px] h-[56px] object-cover">
                                            </c:when>
                                            <c:otherwise> 
                                                <img src="https://noithatduonggia.vn/wp-content/uploads/2019/05/tieu-chuan-thiet-ke-rap-chieu-phim.jpg" class="w-[84px] h-[56px] object-cover">
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="absolute inset-0 bg-black/40 group-hover:bg-transparent transition-colors duration-300"></div>
                                    </div>

                                    <div class="flex flex-col">
                                        <span class="font-bold text-gray-100 group-hover:text-white transition-colors text-sm">${st.room.roomName}</span>
                                        <span class="text-[10px] uppercase font-bold px-2 py-0.5 rounded bg-gray-800 text-red-500 border border-red-500/20 w-fit mt-1">
                                            ${st.room.roomType != null ? st.room.roomType : 'Standard'}
                                        </span>
                                    </div>
                                </div>
                            </td>

                            <td class="p-4">
                                <div class="inner-content flex flex-col space-y-1.5">
                                    <div class="flex items-center gap-2 text-gray-300 text-sm font-medium group-hover:text-white transition-colors">
                                        <i class="far fa-calendar-alt text-red-500"></i>
                                        <fmt:formatDate value="${st.showDate}" pattern="dd/MM/yyyy" />
                                    </div>
                                    <div class="flex items-center gap-2 font-mono text-white/90 bg-[#0b0c10] w-fit px-2.5 py-1 rounded-md border border-gray-700/50 group-hover:border-red-500/30 transition-all">
                                        <i class="far fa-clock text-blue-400"></i>
                                        <fmt:formatDate value="${st.startTime}" pattern="HH:mm" /> - <fmt:formatDate value="${st.endTime}" pattern="HH:mm" />
                                    </div>
                                </div>
                            </td>

                            <td class="p-4 align-middle text-center">
                                <div class="inner-content inline-block">
                                    <c:choose>
                                        <c:when test="${st.displayStatus == 'Đang chiếu'}">
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-green-500/10 text-green-500 border-green-500/30 badge-pulse">
                                                <i class="fas fa-play-circle"></i> Đang chiếu
                                            </span>
                                        </c:when>
                                        <c:when test="${st.displayStatus == 'Sắp chiếu'}">
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-blue-500/10 text-blue-400 border-blue-500/30">
                                                <i class="fas fa-clock"></i> Sắp chiếu
                                            </span>
                                        </c:when>
                                        <c:when test="${st.displayStatus == 'Đã chiếu'}">
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-gray-500/10 text-gray-400 border-gray-500/30">
                                                <i class="fas fa-check-circle"></i> Đã chiếu
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-3 py-1.5 text-[11px] font-bold tracking-wider rounded-md border inline-flex items-center gap-1.5 bg-red-500/10 text-red-500 border-red-500/30">
                                                <i class="fas fa-info-circle"></i> ${st.displayStatus}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>

                            <td class="p-4">
                                <div class="inner-content flex justify-center gap-2 opacity-60 group-hover:opacity-100 transition-opacity duration-300">
                                    <a href="${pageContext.request.contextPath}/admin/showtimes/edit/${st.id_Showtime}" title="Sửa suất chiếu" class="w-9 h-9 rounded-lg bg-blue-500/10 text-blue-400 flex items-center justify-center hover:bg-blue-500 hover:text-white hover:shadow-[0_0_15px_rgba(59,130,246,0.6)] transition-all duration-300 transform hover:-translate-y-1">
                                        <i class="fas fa-pen text-sm"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/showtimes/delete/${st.id_Showtime}" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa lịch chiếu phim này?')" 
                                       title="Xóa suất chiếu"
                                       class="w-9 h-9 rounded-lg bg-red-500/10 text-red-400 flex items-center justify-center hover:bg-red-600 hover:text-white hover:shadow-[0_0_15px_rgba(239,68,68,0.6)] transition-all duration-300 transform hover:-translate-y-1">
                                        <i class="fas fa-trash text-sm"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>


<script>
    
    function triggerPremiumToast(type, title, message) {
        const container = document.getElementById('premium-toast-container');
        if (!container)
            return;

        const toast = document.createElement('div');
        toast.className = `toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ` +
                (type === 'success' ? 'bg-zinc-950/90 text-white toast-success-glow' : 'bg-zinc-950/90 text-white toast-error-glow');

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
    function showStaticError(message) {
        triggerPremiumToast('error', 'Cảnh báo bộ lọc', message);
    }
    window.addEventListener('DOMContentLoaded', () => {
        const errorBridge = document.getElementById('backend-error-bridge');
        const successBridge = document.getElementById('backend-success-bridge');

        if (errorBridge && errorBridge.value.trim() !== "") {
            triggerPremiumToast('error', 'Lỗi hệ thống', errorBridge.value.trim());
        }

        if (successBridge && successBridge.value.trim() !== "") {
            triggerPremiumToast('success', 'Thành công', successBridge.value.trim());
        }

        if (typeof renderRoomSelectOptions === "function") {
            renderRoomSelectOptions();
        }
    });
     function dismissTargetToast(toast) {
        if (!toast || toast.classList.contains('toast-leave-active'))
            return;

        if (toast.dataset.timerId) {
            clearTimeout(parseInt(toast.dataset.timerId));
        }

         toast.classList.add('toast-leave-active');

        setTimeout(() => {
            toast.remove();
        }, 400);
    }
    function showStaticError(message) {
        triggerPremiumToast('error', 'Cảnh báo bộ lọc', message);
    }
    window.addEventListener('DOMContentLoaded', () => {
        const errorFromBackend = `${not empty systemErrorMsg ? systemErrorMsg : errorMessage}`;
        const successFromBackend = `${not empty successMsg ? successMsg : successMessage}`;

        if (errorFromBackend && errorFromBackend.trim() !== "" && errorFromBackend !== "false") {
            triggerPremiumToast('error', 'Lỗi hệ thống', errorFromBackend);
        }

       if (successFromBackend && successFromBackend.trim() !== "" && successFromBackend !== "false") {
            triggerPremiumToast('success', 'Thành công', successFromBackend);
        }
        if (typeof renderRoomSelectOptions === "function") {
            renderRoomSelectOptions();
        }
    });
    function autoFillDateTime(prefix, datetimeValue) {
        if (!datetimeValue)
            return;
        const dt = new Date(datetimeValue);

        document.getElementById(prefix + 'Day').value = dt.getDate();
        document.getElementById(prefix + 'Month').value = dt.getMonth() + 1; // getMonth() bắt đầu từ 0
        document.getElementById(prefix + 'Year').value = dt.getFullYear();
        document.getElementById(prefix + 'Hour').value = dt.getHours();
        document.getElementById(prefix + 'Minute').value = dt.getMinutes();
        document.getElementById(prefix + 'Second').value = "00"; // Mặc định giây là 0
    }

    // 2. Hàm hỗ trợ lấy Object Date từ các ô input
    function getDateTimeFromInputs(prefix) {
        const year = document.getElementById(prefix + 'Year').value;
        const month = document.getElementById(prefix + 'Month').value;
        const day = document.getElementById(prefix + 'Day').value;
        const hour = document.getElementById(prefix + 'Hour').value || 0;
        const min = document.getElementById(prefix + 'Minute').value || 0;
        const sec = document.getElementById(prefix + 'Second').value || 0;

        if (year && month && day) {
            return new Date(year, month - 1, day, hour, min, sec).getTime();
        }
        return null;
    }


</script>
<script>

    function showToast(message, type = 'error') {
        const container = document.getElementById('toast-container');
        if (!container)
            return;

        const toast = document.createElement('div');
        const isError = type === 'error';

        // Cài đặt CSS (Đỏ cho lỗi, Xanh cho thành công)
        const bgClass = isError ? 'bg-red-600/95 shadow-[0_0_20px_rgba(220,38,38,0.5)]' : 'bg-green-600/95 shadow-[0_0_20px_rgba(22,163,74,0.5)]';
        const iconClass = isError ? 'fa-exclamation-triangle' : 'fa-check-circle';

        // Khởi tạo khung thông báo trượt (Mặc định ở ngoài màn hình)
        toast.className = `toast-msg text-white px-5 py-3 rounded-xl flex items-center gap-3 transform transition-all duration-500 translate-x-[120%] opacity-0 pointer-events-auto ${bgClass}`;
        toast.innerHTML = `<i class="fas ${iconClass} text-lg"></i> <span class="text-sm font-medium">${message}</span>`;

        container.appendChild(toast);

        // Hiệu ứng trượt vào
        setTimeout(() => {
            toast.classList.remove('translate-x-[120%]', 'opacity-0');
            toast.classList.add('translate-x-0', 'opacity-100');
        }, 10);

        // Tự động tắt sau 4.5 giây
        setTimeout(() => {
            toast.classList.remove('translate-x-0', 'opacity-100');
            toast.classList.add('translate-x-[120%]', 'opacity-0');
            setTimeout(() => toast.remove(), 500);
        }, 4500);
    }// Khởi tạo mảng lưu dữ liệu phòng chiếu từ DB lên để liên kết trạng thái phòng
    const allRoomsData = [
    <c:forEach items="${rooms}" var="r" varStatus="loop">
    {
    id: "${r.id_Room}",
            roomName: "${r.roomName}",
            // Đổi từ 'STANDARD' thành 'Standard' để khớp DB
            roomType: "${r.roomType != null ? r.roomType : 'Standard'}",
            status: "${r.status != null ? r.status : 'Active'}"
    }${!loop.last ? ',' : ''}
    </c:forEach>
    ];
    window.addEventListener('DOMContentLoaded', () => {
    <c:if test="${not empty successMsg}">
        showToast("${successMsg}", 'success');
    </c:if>
    <c:if test="${not empty systemErrorMsg}">
        showToast("${systemErrorMsg}", 'error');
    </c:if>
        // Gọi hàm render danh sách phòng cũ của bạn
        renderRoomSelectOptions();
    });
    // Tạo các lựa chọn hiển thị trong custom dropdown cho tên phòng chiếu
    function renderRoomSelectOptions() {
        const selectedStatus = document.getElementById('filterRoomStatus').value;
        const listContainer = document.getElementById('roomSelectableList');
        const keyword = document.getElementById('roomKeywordSearch').value.toLowerCase().trim();

        listContainer.innerHTML = '';

        // Bước 1: Trước khi lọc từ khóa, lọc theo trạng thái phòng đã chọn kế bên nó
        let filteredRooms = allRoomsData;
        if (selectedStatus) {
            filteredRooms = filteredRooms.filter(r => r.status === selectedStatus);
        }

        // Bước 2: Người dùng nhập từ khóa tìm phòng -> tự động lọc danh sách dưới
        if (keyword) {
            filteredRooms = filteredRooms.filter(r => r.roomName.toLowerCase().includes(keyword));
        }

        if (filteredRooms.length === 0) {
            const li = document.createElement('li');
            li.className = 'text-gray-500 text-xs p-2 text-center italic';
            li.textContent = 'Không tìm thấy phòng phù hợp';
            listContainer.appendChild(li);
            return;
        }

        // Tạo các item cho danh sách phòng
        filteredRooms.forEach(room => {
            const li = document.createElement('li');
            li.className = 'text-xs text-gray-300 hover:text-white hover:bg-red-600/20 px-2.5 py-1.5 rounded-lg cursor-pointer transition flex justify-between items-center';
            li.innerHTML = `<span>\${room.roomName}</span> <span class="text-[9px] font-mono tracking-wider px-1 py-0.5 rounded bg-gray-800 text-gray-400">\${room.status}</span>`;

            // Ép buộc người dùng ấn vào danh sách mới gán giá trị để lọc suất chiếu
            li.onclick = function () {
                selectRoomItem(room.roomName);
            };
            listContainer.appendChild(li);
        });
    }

    // Khi người dùng đổi trạng thái phòng chiếu ở ô kế bên
    function onRoomStatusChange() {
        const currentSelectedRoom = document.getElementById('filterRoomNameValue').value;
        const selectedStatus = document.getElementById('filterRoomStatus').value;

        // Kiểm tra xem phòng đang chọn trước đó có thuộc nhóm trạng thái mới hay không
        if (currentSelectedRoom) {
            const roomObj = allRoomsData.find(r => r.roomName === currentSelectedRoom);
            if (selectedStatus && roomObj && roomObj.status !== selectedStatus) {
                // Tự động xoá và khôi phục hiển thị tổng quát nếu không tương thích trạng thái phòng
                document.getElementById('filterRoomNameDisplay').value = 'Tất cả phòng';
                document.getElementById('filterRoomNameValue').value = '';
            }
        }
        // Tự động tìm và cập nhật danh sách phòng tương ứng bên trạng thái vừa chọn
        renderRoomSelectOptions();
    }

    // Khi nhấn chọn 1 phòng hoàn chỉnh trong danh sách xổ xuống
    function selectRoomItem(roomName) {
        document.getElementById('filterRoomNameDisplay').value = roomName;
        document.getElementById('filterRoomNameValue').value = roomName; // Gán giá trị chính thức
        document.getElementById('customRoomDropdownPanel').classList.add('hidden'); // Đóng hộp chọn
    }

    // Bật/tắt hiển thị danh sách phòng tự tạo
    function toggleRoomDropdown(event) {
        event.stopPropagation();
        const panel = document.getElementById('customRoomDropdownPanel');
        panel.classList.toggle('hidden');
        if (!panel.classList.contains('hidden')) {
            document.getElementById('roomKeywordSearch').value = '';
            document.getElementById('roomKeywordSearch').focus();
            renderRoomSelectOptions();
        }
    }

    // Xử lý sự kiện khi gõ từ khóa tìm phòng trong ô tìm kiếm của custom dropdown
    function filterRoomListItems() {
        renderRoomSelectOptions();
    }

    // Hàm xoá 12 ô mốc thời gian
    function resetDateTimeFilter() {
        const timeInputs = ['Day', 'Month', 'Year', 'Hour', 'Minute', 'Second'];
        timeInputs.forEach(type => {
            if (document.getElementById('start' + type))
                document.getElementById('start' + type).value = '';
            if (document.getElementById('end' + type))
                document.getElementById('end' + type).value = '';
        });
        if (document.getElementById('autoFillStart'))
            document.getElementById('autoFillStart').value = '';
        if (document.getElementById('autoFillEnd'))
            document.getElementById('autoFillEnd').value = '';
    }
    function setQuickDateTime(target, dateObj = new Date()) {
        const d = dateObj.getDate().toString().padStart(2, '0');
        const m = (dateObj.getMonth() + 1).toString().padStart(2, '0');
        const y = dateObj.getFullYear().toString();
        const H = dateObj.getHours().toString().padStart(2, '0');
        const min = dateObj.getMinutes().toString().padStart(2, '0');
        const sec = dateObj.getSeconds().toString().padStart(2, '0');

        if (target === 'start' || target === 'both') {
            document.getElementById('startDay').value = d;
            document.getElementById('startMonth').value = m;
            document.getElementById('startYear').value = y;
            document.getElementById('startHour').value = H;
            document.getElementById('startMinute').value = min;
            document.getElementById('startSecond').value = sec;
        }
        if (target === 'end' || target === 'both') {
            document.getElementById('endDay').value = d;
            document.getElementById('endMonth').value = m;
            document.getElementById('endYear').value = y;
            document.getElementById('endHour').value = H;
            document.getElementById('endMinute').value = min;
            document.getElementById('endSecond').value = sec;
    }
    } function executeShowtimeFiltering() {
        // Lấy các giá trị lọc cơ bản
        const errContainer = document.getElementById('js-error-container');
        if (errContainer)
            errContainer.classList.add('hidden');

        const movieTitleKeyword = document.getElementById('filterMovieTitle').value.toLowerCase().trim();
        const showtimeStatus = document.getElementById('filterShowtimeStatus').value.toLowerCase();
        const roomStatus = document.getElementById('filterRoomStatus').value;
        const roomNameValue = document.getElementById('filterRoomNameValue').value.toLowerCase();
        const roomType = document.getElementById('filterRoomType').value.toLowerCase();

        // Lấy chế độ lọc thời gian: 'strict' (chính xác) hoặc 'overlap' (theo khoảng). Mặc định là 'overlap' nếu chưa có.
        const filterTimeModeElement = document.getElementById('timeFilterMode');
        const timeFilterMode = filterTimeModeElement ? filterTimeModeElement.value : 'overlap';

        // Lấy 12 ô input thời gian
        const sD = document.getElementById('startDay').value;
        const sM = document.getElementById('startMonth').value;
        const sY = document.getElementById('startYear').value;
        const sH = document.getElementById('startHour').value;
        const sm = document.getElementById('startMinute').value;
        const ss = document.getElementById('startSecond').value;

        const eD = document.getElementById('endDay').value;
        const eM = document.getElementById('endMonth').value;
        const eY = document.getElementById('endYear').value;
        const eH = document.getElementById('endHour').value;
        const em = document.getElementById('endMinute').value;
        const es = document.getElementById('endSecond').value;

        // BƯỚC RÀNG BUỘC: Bắt buộc nhập đủ cặp (Bắt đầu - Kết thúc)
        const timePairs = [
            {start: sD, end: eD, label: 'Ngày'},
            {start: sM, end: eM, label: 'Tháng'},
            {start: sY, end: eY, label: 'Năm'},
            {start: sH, end: eH, label: 'Giờ'},
            {start: sm, end: em, label: 'Phút'},
            {start: ss, end: es, label: 'Giây'}
        ];

        for (let pair of timePairs) {
            if ((pair.start !== "" && pair.end === "") || (pair.start === "" && pair.end !== "")) {
                // Hiển thị lỗi tĩnh màu đỏ giống hệt trang Phim
                showStaticError(`Lỗi bộ lọc: Bạn phải nhập đầy đủ 2 mốc thời gian cho [${pair.label}]. Nếu đã nhập ô bắt đầu thì phải nhập ô kết thúc (và ngược lại).`);
                return; // Dừng việc lọc
            }
        }
        const rows = document.querySelectorAll('.showtime-row');

        rows.forEach(row => {
            const rowMovieTitle = row.getAttribute('data-movie-title').toLowerCase();
            const rowShowtimeStatus = row.getAttribute('data-showtime-status').toLowerCase();
            const rowRoomName = row.getAttribute('data-room-name').toLowerCase();
            const rowRoomType = row.getAttribute('data-room-type').toLowerCase();

            // Ràng buộc phòng chiếu
            const roomObj = allRoomsData.find(r => r.roomName.toLowerCase() === rowRoomName);
            const rowRoomStatus = roomObj ? roomObj.status : '';

           // 1 -> 5. Lọc các thông số cơ bản
            let isMatched = true;

            // Lọc tên phim
            if (movieTitleKeyword && !rowMovieTitle.includes(movieTitleKeyword)) {
                isMatched = false;
            }

            // Lọc trạng thái suất chiếu (Sắp chiếu, Đang chiếu, Đã chiếu)
            if (showtimeStatus && rowShowtimeStatus !== showtimeStatus) {
                isMatched = false;
            }

            // Lọc trạng thái phòng (Active, Maintenance)
            if (roomStatus && rowRoomStatus !== roomStatus) {
                isMatched = false;
            }

            // Lọc tên phòng cụ thể
            if (roomNameValue && rowRoomName !== roomNameValue) {
                isMatched = false;
            }

            // Lọc loại phòng (Standard, VIP...)
            if (roomType && rowRoomType !== roomType) {
                isMatched = false;
            }
            // Nếu cơ bản đã khớp, tiến hành kiểm tra thời gian
            if (isMatched) {
                const rowShowDateStr = row.getAttribute('data-show-date'); // yyyy-MM-dd
                const rowStartStr = row.getAttribute('data-start-time'); // HH:mm:ss
                const rowEndStr = row.getAttribute('data-end-time'); // HH:mm:ss

                if (rowShowDateStr) {
                    let rDateParts = rowShowDateStr.split('-');
                    let R_Y = parseInt(rDateParts[0]), R_M = parseInt(rDateParts[1]), R_D = parseInt(rDateParts[2]);

                    // BƯỚC 1: KIỂM TRA ĐỘC LẬP TỪNG TRƯỜNG NĂM/THÁNG/NGÀY
                    if (sY !== "" && eY !== "") {
                        let yS = parseInt(sY), yE = parseInt(eY);
                        if (yS > yE) {
                            let t = yS;
                            yS = yE;
                            yE = t;
                        }
                        if (R_Y < yS || R_Y > yE)
                            isMatched = false;
                    }

                    if (sM !== "" && eM !== "") {
                        let mS = parseInt(sM), mE = parseInt(eM);
                        if (mS > mE) {
                            let t = mS;
                            mS = mE;
                            mE = t;
                        }
                        if (R_M < mS || R_M > mE)
                            isMatched = false;
                    }

                    if (sD !== "" && eD !== "") {
                        let dS = parseInt(sD), dE = parseInt(eD);
                        if (dS > dE) {
                            let t = dS;
                            dS = dE;
                            dE = t;
                        }
                        if (R_D < dS || R_D > dE)
                            isMatched = false;
                    }

                    // BƯỚC 2: KIỂM TRA GIỜ THEO CHẾ ĐỘ STRICT/OVERLAP (Chỉ xử lý khi có nhập khung giờ)
                    let isUseTime = (sH !== "" || sm !== "" || ss !== "" || eH !== "" || em !== "" || es !== "");

                    if (isMatched && isUseTime && rowStartStr && rowEndStr) {
                        let tStart = rowStartStr.split(':');
                        let tEnd = rowEndStr.split(':');

                        let rowStartInSec = parseInt(tStart[0]) * 3600 + parseInt(tStart[1]) * 60 + parseInt(tStart[2] || 0);
                        let rowEndInSec = parseInt(tEnd[0]) * 3600 + parseInt(tEnd[1]) * 60 + parseInt(tEnd[2] || 0);

                        // Trường hợp phim chiếu qua ngày hôm sau (giờ kết thúc < giờ bắt đầu)
                        if (rowEndInSec < rowStartInSec) {
                            rowEndInSec += (24 * 60 * 60);
                        }

                        let filterStartInSec = parseInt(sH || 0) * 3600 + parseInt(sm || 0) * 60 + parseInt(ss || 0);
                        let filterEndInSec = parseInt(eH || 23) * 3600 + parseInt(em || 59) * 60 + parseInt(es || 59);

                        if (filterStartInSec > filterEndInSec) {
                            let t = filterStartInSec;
                            filterStartInSec = filterEndInSec;
                            filterEndInSec = t;
                        }

                        if (timeFilterMode === 'strict') {
                            // Lọc chính xác: Nằm gọn hoàn toàn trong khoảng
                            if (!(rowStartInSec >= filterStartInSec && rowEndInSec <= filterEndInSec)) {
                                isMatched = false;
                            }
                        } else if (timeFilterMode === 'overlap') {
                            // Lọc theo khoảng: Chỉ cần có giao nhau (chạm một phần)
                            if (!(rowStartInSec <= filterEndInSec && rowEndInSec >= filterStartInSec)) {
                                isMatched = false;
                            }
                        }
                    }
                }
            }

            // Hiển thị hoặc ẩn dựa trên tất cả các điều kiện
            if (isMatched) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    // Cài lại toàn bộ bộ lọc về giá trị mặc định tổng quát
    function resetAllFilters() {
        document.getElementById('filterMovieTitle').value = '';
        document.getElementById('filterShowtimeStatus').value = '';
        document.getElementById('filterRoomStatus').value = '';
        document.getElementById('filterRoomNameDisplay').value = 'Tất cả phòng';
        document.getElementById('filterRoomNameValue').value = '';
        document.getElementById('filterRoomType').value = '';
        document.getElementById('roomKeywordSearch').value = '';

        // Reset luôn nút chọn chế độ nếu có
        const filterTimeModeElement = document.getElementById('filterTimeMode');
        if (filterTimeModeElement)
            filterTimeModeElement.value = 'overlap';

        resetDateTimeFilter(); // Clear cả 12 ô

        // Hiển thị lại toàn bộ các dòng của bảng
        const rows = document.querySelectorAll('#showtimeTableBody .showtime-row');
        rows.forEach(row => {
            row.style.display = '';
        });

        renderRoomSelectOptions();
    }

    // Khi thay đổi trạng thái phòng (Listener thêm nếu cần thiết)
    document.getElementById('filterRoomStatus').addEventListener('change', function () {
        let selectedStatus = this.value;
        let roomList = document.querySelectorAll('.room-option');

        // Ẩn/Hiện các phòng dựa trên trạng thái
        roomList.forEach(room => {
            if (selectedStatus === 'all' || room.dataset.status === selectedStatus) {
                room.style.display = 'block';
            } else {
                room.style.display = 'none';
            }
        });
    });

    // Đóng hộp custom dropdown khi bấm ra ngoài vùng chọn
    document.addEventListener('click', function (e) {
        const panel = document.getElementById('customRoomDropdownPanel');
        const displayInput = document.getElementById('filterRoomNameDisplay');
        if (panel && !panel.contains(e.target) && e.target !== displayInput) {
            panel.classList.add('hidden');
        }
    });

    // Gọi khởi chạy render danh sách phòng ngay khi tải trang xong
    window.addEventListener('DOMContentLoaded', () => {
        renderRoomSelectOptions();
    });
</script>