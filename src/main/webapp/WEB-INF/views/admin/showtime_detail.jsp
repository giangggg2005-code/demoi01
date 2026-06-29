<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* Thanh cuộn cho sơ đồ ghế */
    .custom-scrollbar::-webkit-scrollbar { height: 8px; width: 8px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: #121212; border-radius: 10px; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: #374151; border-radius: 10px; }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #ef4444; }

    /* Hiệu ứng ghế */
    .seat {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
    }
    .seat-available { background-color: #4b5563; color: white; } /* Xám */
    .seat-available:hover { background-color: #6b7280; transform: translateY(-2px); box-shadow: 0 4px 10px rgba(255,255,255,0.1); }
    
    .seat-booked { 
        background-color: #dc2626; color: white; /* Đỏ */
        box-shadow: 0 0 10px rgba(220, 38, 38, 0.6), inset 0 0 5px rgba(0,0,0,0.5);
    }
    .seat-booked:hover { transform: scale(1.1); box-shadow: 0 0 20px rgba(220, 38, 38, 0.9); z-index: 10; cursor: pointer; }
    
    .seat-maintenance { 
        background-color: #000000; color: #4b5563; /* Đen */
        border: 1px solid #374151; cursor: not-allowed;
        background-image: repeating-linear-gradient(45deg, transparent, transparent 5px, #1f2937 5px, #1f2937 10px);
    }

    /* Màn hình cong */
    .cinema-screen {
        height: 60px;
        background: linear-gradient(to bottom, rgba(255,255,255,0.8), transparent);
        border-top-left-radius: 50% 100%;
        border-top-right-radius: 50% 100%;
        box-shadow: 0 -15px 30px rgba(255, 255, 255, 0.15);
        position: relative;
    }
    .cinema-screen::after {
        content: 'MÀN HÌNH CHÍNH';
        position: absolute;
        top: -25px;
        left: 50%;
        transform: translateX(-50%);
        color: #9ca3af;
        font-size: 0.75rem;
        letter-spacing: 0.2em;
        font-weight: bold;
    }
</style>

<div class="p-4 sm:p-6 space-y-6">
    <div class="flex items-center justify-between bg-gradient-to-r from-[#1a1a1a] to-[#121212] p-5 rounded-2xl border border-gray-800 shadow-xl">
        <div class="flex items-center gap-4">
            <a href="${pageContext.request.contextPath}/admin/showtimes" class="w-10 h-10 rounded-full bg-gray-800 hover:bg-gray-700 flex items-center justify-center text-white transition-colors">
                <i class="fas fa-arrow-left"></i>
            </a>
            <div>
                <h2 class="text-2xl font-black text-white tracking-wide uppercase">Chi Tiết Suất Chiếu <span class="text-red-500">#${showtime.id_Showtime}</span></h2>
                <p class="text-gray-400 text-sm mt-1">Sơ đồ vé và thông tin tổng quan</p>
            </div>
        </div>
        <div class="px-4 py-2 bg-gray-800 rounded-lg border border-gray-700 text-sm font-mono text-gray-300 shadow-inner">
            Trạng thái: 
            <span class="${showtime.status == 'Active' ? 'text-green-400' : 'text-yellow-400'} font-bold uppercase">${showtime.status}</span>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="bg-[#1a1a1a] rounded-2xl border border-gray-800 p-5 flex gap-5 shadow-lg lg:col-span-1">
            <img src="${showtime.movie.posterUrl}" alt="Poster" class="w-28 h-40 object-cover rounded-xl shadow-md border border-gray-700">
            <div class="flex-1 space-y-2">
                <h3 class="text-lg font-bold text-white uppercase leading-tight">${showtime.movie.title}</h3>
                <p class="text-xs text-gray-400"><i class="fas fa-clock text-red-500 mr-1"></i> Thời lượng: <span class="text-white">${showtime.movie.duration} phút</span></p>
                <p class="text-xs text-gray-400"><i class="fas fa-tags text-red-500 mr-1"></i> Thể loại: <span class="text-white">${showtime.movie.genre}</span></p>
                <p class="text-xs text-gray-400"><i class="fas fa-calendar-check text-red-500 mr-1"></i> Khởi chiếu: <span class="text-white"><fmt:formatDate value="${showtime.movie.releaseDate}" pattern="dd/MM/yyyy"/></span></p>
                <p class="text-xs text-gray-400"><i class="fas fa-ticket-alt text-red-500 mr-1"></i> Giá gốc: <span class="text-green-400 font-bold"><fmt:formatNumber value="${showtime.movie.basePrice}" type="number" maxFractionDigits="0"/> VNĐ</span></p>
            </div>
        </div>

        <div class="bg-[#1a1a1a] rounded-2xl border border-gray-800 p-5 shadow-lg lg:col-span-2 grid grid-cols-2 gap-4">
            <div class="bg-[#121212] p-4 rounded-xl border border-gray-800/50">
                <p class="text-sm text-gray-500 mb-1">Phòng Chiếu</p>
                <p class="text-xl font-black text-red-400 flex items-center gap-2"><i class="fas fa-door-open text-gray-600"></i> ${showtime.room.roomName}</p>
                <p class="text-xs text-gray-500 mt-2">Tổng số ghế: ${showtime.room.totalRows * showtime.room.totalCols}</p>
            </div>
            <div class="bg-[#121212] p-4 rounded-xl border border-gray-800/50">
                <p class="text-sm text-gray-500 mb-1">Thời gian chiếu</p>
                <p class="text-lg font-bold text-white flex items-center gap-2">
                    <i class="fas fa-calendar-day text-blue-400"></i> <fmt:formatDate value="${showtime.showDate}" pattern="dd/MM/yyyy"/>
                </p>
                <p class="text-lg font-mono text-gray-300 mt-1 flex items-center gap-2">
                    <span class="text-blue-300"><fmt:formatDate value="${showtime.startTime}" type="time" pattern="HH:mm"/></span>
                    <i class="fas fa-arrow-right text-xs text-gray-600"></i>
                    <span class="text-orange-300"><fmt:formatDate value="${showtime.endTime}" type="time" pattern="HH:mm"/></span>
                </p>
            </div>
        </div>
    </div>

    <div class="bg-[#1a1a1a] rounded-2xl border border-gray-800 p-6 shadow-2xl relative overflow-hidden">
        
        <div class="flex flex-wrap justify-center gap-6 mb-10 pb-4 border-b border-gray-800/50">
            <div class="flex items-center gap-2 text-sm text-gray-300"><div class="w-6 h-6 rounded-t-lg rounded-b-sm bg-gray-600"></div> Ghế trống (Chưa mua)</div>
            <div class="flex items-center gap-2 text-sm text-gray-300"><div class="w-6 h-6 rounded-t-lg rounded-b-sm bg-red-600 shadow-[0_0_8px_rgba(220,38,38,0.8)]"></div> Đã bán (Click xem chi tiết)</div>
            <div class="flex items-center gap-2 text-sm text-gray-300"><div class="w-6 h-6 rounded-t-lg rounded-b-sm bg-black border border-gray-600"></div> Bảo trì (Không thể bán)</div>
        </div>

        <div class="cinema-screen mt-8 mb-16 mx-auto w-3/4 max-w-3xl"></div>

        <div class="overflow-x-auto custom-scrollbar pb-6">
            <div class="min-w-max mx-auto flex flex-col items-center gap-3">
                <div class="grid gap-2 sm:gap-3" style="grid-template-columns: repeat(${showtime.room.totalCols}, minmax(0, 1fr));">
                    
                    <c:forEach items="${seatMap}" var="seat">
                        <%-- 
                            GHI CHÚ DÀNH CHO BACKEND:
                            Backend cần cung cấp danh sách "seatMap" gồm các object có thuộc tính:
                            - seatName (VD: A1, A2)
                            - status (Tình trạng: 'Available', 'Booked', 'Maintenance')
                            - buyerName (Tên người mua nếu Booked)
                            - price (Giá vé đã mua)
                            - bookingDate (Ngày đặt vé)
                        --%>
                        <c:choose>
                            <c:when test="${seat.status == 'Booked'}">
                                <div onclick="openTicketModal('${seat.seatName}', '${seat.buyerName}', '${seat.price}', '${seat.bookingDate}')" 
                                     class="seat seat-booked w-8 h-8 sm:w-10 sm:h-10 rounded-t-xl rounded-b-md flex items-center justify-center text-[10px] sm:text-xs font-bold transition-all"
                                     title="Ghế ${seat.seatName} - Đã bán">
                                    ${seat.seatName}
                                </div>
                            </c:when>
                            <c:when test="${seat.status == 'Maintenance'}">
                                <div class="seat seat-maintenance w-8 h-8 sm:w-10 sm:h-10 rounded-t-xl rounded-b-md flex items-center justify-center text-[10px] sm:text-xs font-bold"
                                     title="Ghế ${seat.seatName} - Đang bảo trì">
                                    X
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="seat seat-available w-8 h-8 sm:w-10 sm:h-10 rounded-t-xl rounded-b-md flex items-center justify-center text-[10px] sm:text-xs font-bold"
                                     title="Ghế ${seat.seatName} - Trống">
                                    ${seat.seatName}
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                </div>
            </div>
        </div>
    </div>
</div>

<div id="ticketDetailModal" class="hidden fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm transition-opacity duration-300 opacity-0">
    <div id="ticketDetailContent" class="bg-gradient-to-b from-[#1a1a1a] to-[#121212] p-8 rounded-2xl border border-gray-700 shadow-[0_0_40px_rgba(220,38,38,0.15)] w-full max-w-sm transform scale-95 transition-transform duration-300">
        
        <div class="text-center mb-6 relative">
            <div class="absolute -top-16 left-1/2 transform -translate-x-1/2 w-16 h-16 bg-red-600 rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(220,38,38,0.8)] border-4 border-[#121212]">
                <i class="fas fa-ticket-alt text-2xl text-white"></i>
            </div>
            <h3 class="text-2xl font-black text-white mt-4 uppercase tracking-widest">Ghế <span id="modalSeatName" class="text-red-500">--</span></h3>
            <p class="text-sm text-gray-400 mt-1">Thông tin chi tiết vé đã đặt</p>
        </div>

        <div class="space-y-4 bg-[#0b0c10] p-5 rounded-xl border border-gray-800">
            <div class="flex justify-between items-center pb-3 border-b border-gray-800">
                <span class="text-gray-500 text-sm"><i class="fas fa-user-circle mr-2"></i>Khách hàng</span>
                <span id="modalBuyerName" class="text-white font-semibold text-right">--</span>
            </div>
            <div class="flex justify-between items-center pb-3 border-b border-gray-800">
                <span class="text-gray-500 text-sm"><i class="fas fa-coins mr-2"></i>Giá vé</span>
                <span id="modalPrice" class="text-green-400 font-bold font-mono">-- VNĐ</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-gray-500 text-sm"><i class="fas fa-calendar-check mr-2"></i>Ngày đặt</span>
                <span id="modalDate" class="text-blue-300 font-mono text-sm">--</span>
            </div>
        </div>

        <div class="mt-8 flex justify-center">
            <button onclick="closeTicketModal()" class="w-full px-6 py-3 bg-gray-800 hover:bg-gray-700 text-white font-semibold rounded-xl border border-gray-600 transition-colors shadow-lg">
                Đóng thông tin
            </button>
        </div>
    </div>
</div>

<script>
    // Hàm mở Modal kèm hiệu ứng mượt mà
    function openTicketModal(seatName, buyerName, price, bookingDate) {
        document.getElementById('modalSeatName').innerText = seatName;
        document.getElementById('modalBuyerName').innerText = buyerName ? buyerName : 'Khách vãng lai';
        
        // Format tiền tệ VNĐ
        let formattedPrice = new Intl.NumberFormat('vi-VN').format(price);
        document.getElementById('modalPrice').innerText = formattedPrice + ' đ';
        
        document.getElementById('modalDate').innerText = bookingDate ? bookingDate : 'Không xác định';

        const modal = document.getElementById('ticketDetailModal');
        const content = document.getElementById('ticketDetailContent');
        
        modal.classList.remove('hidden');
        // Kích hoạt animation bằng cách setTimeout nhỏ
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            content.classList.remove('scale-95');
            content.classList.add('scale-100');
        }, 10);
    }

    // Hàm đóng Modal
    function closeTicketModal() {
        const modal = document.getElementById('ticketDetailModal');
        const content = document.getElementById('ticketDetailContent');

        modal.classList.add('opacity-0');
        content.classList.remove('scale-100');
        content.classList.add('scale-95');

        setTimeout(() => {
            modal.classList.add('hidden');
        }, 300); // Khớp với duration-300 của Tailwind
    }
</script>