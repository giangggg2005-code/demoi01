<%-- views/admin/dashboard.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script>
    try {
        var rawData = '${monthlyRevenueData}';
        if (!rawData || rawData === '[]' || rawData.trim() === '') {
            window.chartDataFromDB = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else {
            window.chartDataFromDB = JSON.parse(rawData);
        }
    } catch (error) {
        console.error("Lỗi phân tích cú pháp dữ liệu biểu đồ:", error);
        window.chartDataFromDB = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    }
</script>

<div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
    <div>
        <h2 class="text-xl font-black text-white uppercase tracking-wider">Bảng Điều Khiển Quản Trị</h2>
        <p class="text-xs text-gray-500">Giám sát hoạt động rạp phim thời gian thực</p>
    </div>
    
    <form method="GET" action="${pageContext.request.contextPath}/admin/dashboard" class="glass-card border border-gray-800 rounded-xl p-2 flex items-center gap-3">
        <label for="year-select" class="text-xs font-bold text-gray-400 pl-2 whitespace-nowrap"><i class="fas fa-filter text-red-500 mr-1"></i> Chọn năm báo cáo:</label>
        <select id="year-select" name="year" onchange="this.form.submit()" class="bg-[#161616] text-white border border-gray-800 text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-red-500 font-bold cursor-pointer transition">
            <c:forEach var="y" begin="${currentYear - 3}" end="${currentYear + 1}">
                <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
            </c:forEach>
        </select>
    </form>
</div>

<c:if test="${not empty errorMessage}">
    <div class="bg-red-900/30 border border-red-500/40 rounded-xl p-4 mb-6 text-xs text-red-400 flex items-center">
        <i class="fas fa-exclamation-triangle text-base mr-3"></i> ${errorMessage}
    </div>
</c:if>

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <div class="glass-card border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow">
        <div>
            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Tổng doanh thu (${selectedYear != null ? selectedYear : currentYear})</p>
            <h3 class="text-xl font-bold text-white mt-1 count-up" data-target="${not empty summary.totalRevenue ? summary.totalRevenue / 1000000 : 0}" data-decimal="true" data-suffix="M ₫">
                <fmt:formatNumber value="${not empty summary.totalRevenue ? summary.totalRevenue / 1000000 : 0}" pattern="#,##0.0"/>M ₫
            </h3>
        </div>
        <div class="w-12 h-12 rounded-xl bg-green-500/10 text-green-500 flex items-center justify-center text-xl shadow-inner"><i class="fas fa-wallet"></i></div>
    </div>
    <div class="glass-card border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow">
        <div>
            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Số vé đã bán (${selectedYear != null ? selectedYear : currentYear})</p>
            <h3 class="text-xl font-bold text-white mt-1 count-up" data-target="${not empty summary.totalTickets ? summary.totalTickets : 0}" data-suffix=" Vé">
                <fmt:formatNumber value="${not empty summary.totalTickets ? summary.totalTickets : 0}" pattern="#,###"/> Vé
            </h3>
        </div>
        <div class="w-12 h-12 rounded-xl bg-red-500/10 text-red-500 flex items-center justify-center text-xl shadow-inner"><i class="fas fa-ticket-alt"></i></div>
    </div>
    <div class="glass-card border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow">
        <div>
            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Người dùng mới (${selectedYear != null ? selectedYear : currentYear})</p>
            <h3 class="text-xl font-bold text-white mt-1 count-up" data-target="${not empty summary.newUsers ? summary.newUsers : 0}" data-prefix="+" data-suffix=" Users">
                +<fmt:formatNumber value="${not empty summary.newUsers ? summary.newUsers : 0}" pattern="#,###"/> Users
            </h3>
        </div>
        <div class="w-12 h-12 rounded-xl bg-blue-500/10 text-blue-500 flex items-center justify-center text-xl shadow-inner"><i class="fas fa-users"></i></div>
    </div>
    <div class="glass-card border border-gray-800 p-5 rounded-2xl flex items-center justify-between hover-glow">
        <div>
            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Phim đang chiếu (${selectedYear != null ? selectedYear : currentYear})</p>
            <h3 class="text-xl font-bold text-white mt-1 count-up" data-target="${not empty summary.activeMovies ? summary.activeMovies : 0}" data-suffix=" Phim">
                ${not empty summary.activeMovies ? summary.activeMovies : 0} Phim
            </h3>
        </div>
        <div class="w-12 h-12 rounded-xl bg-amber-500/10 text-amber-500 flex items-center justify-center text-xl shadow-inner"><i class="fas fa-film"></i></div>
    </div>
</div>

<div class="glass-card border border-gray-800 rounded-2xl p-6 mb-6">
    <h3 class="text-sm font-bold text-white mb-6 uppercase tracking-wider text-center"><i class="fas fa-crown text-amber-500 mr-2"></i> Bảng xếp hạng phim thịnh hành nhất</h3>
    <div class="flex flex-col md:flex-row items-center justify-center gap-6 md:gap-12 md:items-end py-4">
            
        <c:if test="${fn:length(top3Movies) >= 2}">
        <div class="flex flex-col items-center order-2 md:order-1">
            <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${top3Movies[1].id_Movie}" class="group block relative text-center">
                <div class="absolute -top-3 -left-3 w-7 h-7 bg-blue-600 text-white rounded-full flex items-center justify-center font-bold text-xs border-2 border-[#121212]">2</div>
                <img src="${top3Movies[1].posterUrl}" class="w-28 h-40 object-cover rounded-xl border border-gray-700 group-hover:scale-105 group-hover:border-blue-500 transition shadow-lg" alt="Top 2">
                <p class="mt-2 text-xs font-semibold text-gray-300 w-28 truncate">${top3Movies[1].title}</p>
            </a>
        </div>
        </c:if>

        <c:if test="${fn:length(top3Movies) >= 1}">
        <div class="flex flex-col items-center order-1 md:order-2 transform md:-translate-y-6">
            <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${top3Movies[0].id_Movie}" class="group block relative text-center">
                <div class="absolute -top-4 left-1/2 -translate-x-1/2 w-8 h-8 bg-red-600 text-white rounded-full flex items-center justify-center font-bold text-sm border-2 border-[#121212] top1-shadow z-10">1</div>
                <img src="${top3Movies[0].posterUrl}" class="w-36 h-52 object-cover rounded-xl border-2 border-red-500 shadow-2xl group-hover:scale-105 transition" alt="Top 1">
                <p class="mt-2 text-sm font-bold text-white w-36 truncate tracking-wide">${top3Movies[0].title}</p>
            </a>
        </div>
        </c:if>

        <c:if test="${fn:length(top3Movies) >= 3}">
        <div class="flex flex-col items-center order-3 md:order-3">
            <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${top3Movies[2].id_Movie}" class="group block relative text-center">
                <div class="absolute -top-3 -right-3 w-7 h-7 bg-amber-700 text-white rounded-full flex items-center justify-center font-bold text-xs border-2 border-[#121212]">3</div>
                <img src="${top3Movies[2].posterUrl}" class="w-28 h-40 object-cover rounded-xl border border-gray-700 group-hover:scale-105 group-hover:border-amber-600 transition shadow-lg" alt="Top 3">
                <p class="mt-2 text-xs font-semibold text-gray-300 w-28 truncate">${top3Movies[2].title}</p>
            </a>
        </div>
        </c:if>
            
    </div>
</div>

<div class="glass-card border border-gray-800 rounded-2xl p-5 mb-6">
    <h3 class="text-xs font-bold text-white mb-4 uppercase tracking-wider"><i class="far fa-calendar-alt text-red-500 mr-2"></i> Phim sắp chiếu mới nhất</h3>
    <div class="flex overflow-x-auto gap-4 pb-3 pr-1 snap-x custom-scrollbar stagger-container">
        
        <c:forEach var="movie" items="${upcomingMovies}">
        <div class="relative text-center group cursor-pointer flex-shrink-0 w-28 sm:w-32 snap-start">
            <div class="relative overflow-hidden rounded-lg mb-2 border border-gray-800 group-hover:border-red-500 transition shadow-lg">
                <img src="${movie.posterUrl}" class="w-full h-36 object-cover" alt="Phim">
                
                <div class="absolute inset-0 bg-black/85 backdrop-blur-[2px] flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 z-10">
                    <i class="far fa-calendar-check text-red-500 text-xl mb-1.5 translate-y-3 group-hover:translate-y-0 transition-transform duration-300"></i>
                    <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest translate-y-3 group-hover:translate-y-0 transition-transform duration-300 delay-75">Suất gần nhất</p>
                    <div class="text-white text-[11px] font-bold mt-1 translate-y-3 group-hover:translate-y-0 transition-transform duration-300 delay-150">
                        <c:choose>
                            <c:when test="${not empty movie.nearestShowtime}">
                                ${movie.nearestShowtime}
                            </c:when>
                            <c:otherwise>
                                <fmt:formatDate value="${movie.releaseDate}" pattern="HH:mm dd/MM/yyyy"/>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <p class="text-[11px] text-gray-400 font-medium truncate">${movie.title}</p>
        </div>
        </c:forEach>

    </div>
</div>

<div class="glass-card border border-gray-800 rounded-2xl p-5 mb-6 hover-glow">
    <h3 class="text-xs font-bold text-white mb-4 uppercase tracking-wider"><i class="fas fa-chart-line text-red-500 mr-2"></i> Biểu đồ diễn biến doanh thu theo tháng</h3>
    <div class="h-64 relative w-full">
        <canvas id="monthlyRevenueChart"></canvas>
    </div>
</div>

<div class="grid grid-cols-1 xl:grid-cols-3 xl:grid-rows-2 gap-6">
    
    <div class="glass-card border border-gray-800 rounded-2xl p-5 xl:col-span-2 xl:row-span-2 order-1 flex flex-col justify-between hover-glow">
        <div>
            <h3 class="text-xs font-bold text-white mb-4 uppercase tracking-wider"><i class="fas fa-list-ol text-red-500 mr-2"></i> Top 10 Phim Doanh Thu Cao Nhất</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-xs">
                    <thead>
                        <tr class="text-gray-500 border-b border-gray-800 font-bold">
                            <th class="pb-3 w-12 text-center">Hạng</th>
                            <th class="pb-3 w-14">Poster</th>
                            <th class="pb-3">Tên phim</th>
                            <th class="pb-3 text-right">Số vé bán</th>
                            <th class="pb-3 text-right">Doanh thu</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-800/40 stagger-container">
                        
                        <c:forEach var="top" items="${top10Movies}" end="9" varStatus="loop">
                        <tr class="hover:bg-white/5 transition">
                            <c:choose>
                                <c:when test="${loop.index == 0}">
                                    <td class="py-2.5 text-center font-bold text-red-500">1</td>
                                </c:when>
                                <c:when test="${loop.index == 1}">
                                    <td class="py-2.5 text-center font-bold text-amber-500">2</td>
                                </c:when>
                                <c:when test="${loop.index == 2}">
                                    <td class="py-2.5 text-center font-bold text-blue-500">3</td>
                                </c:when>
                                <c:otherwise>
                                    <td class="py-2.5 text-center font-bold text-gray-500">${loop.index + 1}</td>
                                </c:otherwise>
                            </c:choose>
                            <td class="py-2.5"><img src="${top.posterUrl}" class="w-8 h-11 object-cover rounded-md" alt="Poster"></td>
                            <td class="py-2.5 font-semibold text-white">${top.title}</td>
                            <td class="py-2.5 text-right"><fmt:formatNumber value="${top.totalTickets}" pattern="#,###"/></td>
                            <td class="py-2.5 text-right text-green-500 font-bold"><fmt:formatNumber value="${top.totalRevenue / 1000000}" pattern="#,##0.0"/>M ₫</td>
                        </tr>
                        </c:forEach>

                    </tbody>
                </table>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mt-6 pt-5 border-t border-gray-800/40">
            <div class="flex flex-col">
                <h4 class="text-xs font-bold text-gray-400 mb-3 uppercase tracking-wider flex items-center justify-between">
                    <span><i class="far fa-clock text-red-500 mr-2"></i> Lịch chiếu hôm nay</span>
                    <span class="text-[9px] bg-red-500/10 text-red-500 px-1.5 py-0.5 rounded font-bold animate-pulse">LIVE</span>
                </h4>
                <div class="space-y-2 max-h-[17.5rem] overflow-y-auto pr-1 custom-scrollbar flex-1 stagger-container">
                    <c:choose>
                        <c:when test="${not empty todayShowtimes}">
                            <c:forEach var="st" items="${todayShowtimes}">
                                <div class="p-2.5 bg-[#141414] rounded-xl border border-gray-800/50 text-[11px] flex items-center justify-between hover:border-gray-700 transition">
                                    <div class="truncate mr-2">
                                        <p class="text-white font-bold truncate">${st.movieTitle}</p>
                                        <p class="text-gray-400 text-[10px] mt-0.5"><i class="fas fa-door-open mr-1 text-gray-600"></i> ${st.roomName}</p>
                                     </div>
                                    <div class="text-right flex-shrink-0">
                                        <span class="px-1.5 py-0.5 bg-red-500/10 text-red-500 rounded font-mono font-bold">${st.startTime}</span>
                                        <p class="text-[9px] text-gray-500 mt-0.5">${st.bookedSeats}/${st.totalSeats} Ghế</p>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="p-2.5 bg-[#141414] rounded-xl border border-gray-800/50 text-[11px] flex items-center justify-between opacity-85">
                                <div class="truncate mr-2">
                                    <p class="text-white font-bold truncate">Chưa có lịch chiếu ngày hôm nay</p>
                                    <p class="text-gray-400 text-[10px] mt-0.5">Vui lòng cập nhật thêm dữ liệu</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="flex flex-col">
                <h4 class="text-xs font-bold text-gray-400 mb-3 uppercase tracking-wider"><i class="fas fa-exchange-alt text-green-500 mr-2"></i> Giao dịch mới nhất</h4>
                <div class="space-y-2 max-h-[17.5rem] overflow-y-auto pr-1 custom-scrollbar flex-1 stagger-container">
                    <c:choose>
                        <c:when test="${not empty recentTransactions}">
                            <c:forEach var="tx" items="${recentTransactions}">
                                <div class="p-2.5 bg-[#141414] rounded-xl border border-gray-800/50 text-[11px] flex items-center justify-between hover:border-gray-700 transition">
                                    <div class="truncate mr-2">
                                        <p class="text-white font-bold truncate">${tx.customerName}</p>
                                        <p class="text-gray-500 text-[10px] mt-0.5 truncate">${tx.movieTitle} • ${tx.ticketCount} vé</p>
                                        <p class="text-gray-400 text-[10px] mt-0.5"><i class="far fa-clock mr-1"></i><fmt:formatDate value="${tx.bookingDate}" pattern="HH:mm:ss dd/MM/yyyy"/></p>
                                    </div>
                                    <div class="text-right flex-shrink-0">
                                        <span class="text-green-500 font-bold font-mono"><fmt:formatNumber value="${tx.amount}" pattern="#,###"/> ₫</span>
                                        <p class="text-[9px] text-gray-400 mt-0.5">${tx.paymentMethod}</p>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="p-2.5 bg-[#141414] rounded-xl border border-gray-800/50 text-[11px] flex items-center justify-between opacity-85">
                                <div class="truncate mr-2">
                                    <p class="text-white font-bold truncate">Chưa có giao dịch mới</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    </div>

    <div class="glass-card border border-gray-800 rounded-2xl p-5 xl:col-span-1 order-2 xl:order-3 hover-glow flex flex-col">
        <h3 class="text-xs font-bold text-white mb-3 uppercase tracking-wider"><i class="fas fa-user-tie text-red-500 mr-2"></i> Nhân viên mới tham gia</h3>
        <div class="space-y-3 max-h-[31rem] overflow-y-auto pr-1 flex-1 stagger-container">
            
            <c:forEach var="emp" items="${newEmployees}">
            <a href="${pageContext.request.contextPath}/admin/employees/detail/${emp.id_User}" class="block group">
                <div class="p-2.5 bg-[#161616] rounded-xl border border-gray-800/60 text-xs group-hover:bg-gray-800/50 transition cursor-pointer">
                    <div class="flex justify-between items-center mb-1">
                        <span class="text-white font-bold group-hover:text-red-500 transition">${emp.fullName}</span>
                        <span class="px-2 py-0.5 ${emp.roleName == 'MANAGER' || emp.roleName == 'ADMIN' ? 'bg-red-500/10 text-red-500' : 'bg-blue-500/10 text-blue-500'} rounded-md text-[10px] font-bold">${emp.roleName}</span>
                    </div>
                    <p class="text-gray-400 text-[11px] truncate">${emp.email}</p>
                    <p class="text-gray-400 text-[11px]">SĐT: ${emp.phone != null ? emp.phone : 'Chưa cập nhật'}</p>
                    <div class="flex justify-between items-center text-[10px] text-gray-500 mt-1 pt-1 border-t border-gray-800/40">
                        <span>Tạo: <fmt:formatDate value="${emp.createdAt}" pattern="HH:mm:ss dd/MM/yyyy"/></span>
                        <span>Cập nhật: <fmt:formatDate value="${emp.updatedAt}" pattern="HH:mm:ss dd/MM/yyyy"/></span>
                    </div>
                </div>
            </a>
            </c:forEach>

        </div>
    </div>

    <div class="glass-card border border-gray-800 rounded-2xl p-5 xl:col-span-1 order-3 xl:order-2 hover-glow flex flex-col">
        <h3 class="text-xs font-bold text-white mb-3 uppercase tracking-wider"><i class="fas fa-user-plus text-red-500 mr-2"></i> Khách hàng mới</h3>
        <div class="space-y-3 max-h-[31rem] overflow-y-auto pr-1 flex-1 stagger-container">
            
            <c:forEach var="cus" items="${newCustomers}">
            <a href="${pageContext.request.contextPath}/admin/customers/detail/${cus.id_User}" class="block group">
                <div class="flex justify-between items-center p-2.5 bg-[#161616] rounded-xl border border-gray-800/60 text-xs group-hover:bg-gray-800/50 transition cursor-pointer">
                    <div>
                        <p class="text-white font-bold group-hover:text-red-500 transition">${cus.fullName}</p>
                        <p class="text-gray-400 text-[11px] truncate">${cus.email}</p>
                    </div>
                    <span class="text-gray-500 text-[10px] font-medium whitespace-nowrap"><i class="far fa-calendar-alt mr-1"></i><fmt:formatDate value="${cus.createdAt}" pattern="HH:mm:ss dd/MM/yyyy"/></span>
                </div>
            </a>
            </c:forEach>

        </div>
    </div>

</div>