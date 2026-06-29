<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<style>
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

    /* 2. Hiệu ứng ẩn dần, thu nhỏ và lướt nhẹ ra sau khi biến mất */
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
    .custom-scrollbar::-webkit-scrollbar {
        width: 6px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: transparent;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #374151;
        border-radius: 10px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: #ef4444;
    }
</style>
<c:if test="${not empty showtime.id_Showtime && showtime.id_Showtime > 0}">
    <fmt:formatDate value="${showtime.showDate}" pattern="yyyy-MM-dd" var="fmtDate"/>
    <fmt:formatDate value="${showtime.startTime}" pattern="HH:mm" var="fmtStart"/>
    <fmt:formatDate value="${showtime.endTime}" pattern="yyyy-MM-dd'T'HH:mm" var="fmtEnd"/>
    <fmt:formatDate value="${showtime.endTime}" pattern="HH:mm - dd/MM/yyyy" var="fmtEndDisplay"/>
</c:if>
<div id="premium-toast-container" class="fixed top-6 right-6 z-[9999] flex flex-col gap-4 w-full max-w-sm pointer-events-none"></div>

<input type="hidden" id="backend-error-bridge" value="${not empty systemErrorMsg ? systemErrorMsg : errorMessage}">
<input type="hidden" id="backend-success-bridge" value="${not empty successMsg ? successMsg : successMessage}">
<div class="p-4 sm:p-6 space-y-8">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center bg-gradient-to-r from-[#1a1a1a] to-[#121212] p-5 sm:p-6 rounded-3xl border border-gray-800/60 shadow-xl relative overflow-hidden gap-4 group">
        <div class="absolute -top-10 -right-10 w-40 h-40 bg-red-600/10 blur-[50px] rounded-full pointer-events-none group-hover:bg-red-600/20 transition-all duration-700"></div>
        <div class="relative z-10">
            <h2 class="text-2xl sm:text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white to-gray-400 uppercase tracking-wide flex items-center gap-3">
                <i class="fas fa-film text-red-500 animate-pulse"></i>
                <c:choose>
                    <c:when test="${not empty showtime.id_Showtime && showtime.id_Showtime > 0}">CẬP NHẬT SUẤT CHIẾU #${showtime.id_Showtime}</c:when>
                    <c:otherwise>THÊM SUẤT CHIẾU MỚI</c:otherwise>
                </c:choose>
            </h2>
        </div>
        <a href="${pageContext.request.contextPath}/admin/showtimes" class="relative z-10 bg-gray-800 hover:bg-gray-700 text-white px-6 py-3 rounded-xl text-sm font-bold transition-all duration-300 shadow-lg hover:shadow-gray-900 flex items-center gap-2 border border-gray-700 hover:border-gray-500 hover:-translate-x-1">
            <i class="fas fa-arrow-left"></i> Trở về danh sách
        </a>
    </div>

    <c:if test="${not empty showtime.id_Showtime && showtime.id_Showtime > 0}">
        <div class="grid grid-cols-1 xl:grid-cols-2 gap-8 relative z-10">
            <div class="group relative p-6 sm:p-8 rounded-3xl border border-gray-700/50 shadow-2xl flex flex-col sm:flex-row gap-8 hover:border-red-500/60 hover:shadow-[0_10px_50px_rgba(220,38,38,0.25)] hover:-translate-y-2 transition-all duration-500 overflow-hidden h-full bg-[#141414]">
                <div class="absolute inset-0 bg-cover bg-center opacity-10 blur-[40px] scale-110 transition-transform duration-1000 group-hover:scale-125" style="background-image: url('${showtime.movie.posterUrl}');"></div>
                <div class="absolute inset-0 bg-gradient-to-br from-[#121212]/95 via-[#1a1a1a]/90 to-black/95"></div>
                <div class="absolute -left-10 -top-10 w-64 h-64 bg-red-600/10 blur-[70px] rounded-full transition-all duration-700 group-hover:bg-red-600/30 group-hover:scale-125 pointer-events-none"></div>

                <div class="relative shrink-0 w-40 sm:w-48 md:w-56 mx-auto sm:mx-0 rounded-2xl overflow-hidden bg-black/80 border border-gray-600/50 shadow-[0_10px_30px_rgba(0,0,0,0.8)] group-hover:shadow-red-500/40 group-hover:border-red-500/50 transition-all duration-500 z-10 flex items-start justify-center p-2 h-max">
                    <img src="${showtime.movie.posterUrl}" class="w-full h-auto object-cover rounded-xl transform group-hover:scale-105 transition-transform duration-700 drop-shadow-2xl" alt="Poster">
                    <div class="absolute top-2 right-2 bg-gradient-to-bl from-red-600 to-red-800 text-white text-xs font-black px-3 py-1.5 rounded-lg shadow-lg z-20 shadow-red-500/50 border border-red-500/50">${showtime.movie.censorship}</div>
                </div>

                <div class="flex flex-col w-full relative z-10 flex-grow space-y-5">
                    <div class="space-y-3 text-center sm:text-left border-b border-gray-800 pb-4">
                        <h3 class="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white to-gray-300 drop-shadow-lg group-hover:from-white group-hover:to-red-200 transition-all duration-500 leading-tight">${showtime.movie.title}</h3>
                        <div class="flex flex-wrap justify-center sm:justify-start gap-3">
                            <span class="px-4 py-1.5 rounded-full bg-blue-500/20 border border-blue-500/50 text-blue-400 text-xs font-bold tracking-widest uppercase shadow-[0_0_10px_rgba(59,130,246,0.2)]">${showtime.movie.category}</span>
                            <span class="px-4 py-1.5 rounded-full bg-gray-500/20 border border-gray-500/50 text-gray-300 text-xs font-bold tracking-widest uppercase">${showtime.movie.status}</span>
                            <span class="px-4 py-1.5 rounded-full bg-gray-500/20 border border-gray-500/50 text-gray-300 text-xs font-bold tracking-widest uppercase">${showtime.movie.language}</span>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4 text-sm text-gray-200">
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-3 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-red-500/30 transition-all hover:-translate-y-1 shadow-md">
                            <div class="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-clock text-red-400 text-base animate-pulse"></i></div>
                            <div><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Thời lượng</p><p class="font-black text-white text-base">${showtime.movie.duration} Phút</p></div>
                        </div>
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-3 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-red-500/30 transition-all hover:-translate-y-1 shadow-md">
                            <div class="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-calendar-alt text-red-400 text-base"></i></div>
                            <div><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Sản xuất</p><p class="font-black text-white text-base">Năm ${showtime.movie.productionYear}</p></div>
                        </div>
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-3 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-red-500/30 transition-all hover:-translate-y-1 shadow-md col-span-2">
                            <div class="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-film text-red-400 text-base"></i></div>
                            <div class="overflow-hidden w-full"><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Thể loại</p><p class="font-black text-white text-sm break-words">${showtime.movie.genre}</p></div>
                        </div>
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-3 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-red-500/30 transition-all hover:-translate-y-1 shadow-md col-span-2">
                            <div class="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-play-circle text-red-400 text-base"></i></div>
                            <div><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Khởi chiếu</p><p class="font-black text-white text-base"><fmt:formatDate value="${showtime.movie.releaseDate}" pattern="dd/MM/yyyy"/></p></div>
                        </div>
                    </div>

                    <div class="text-sm text-gray-300 space-y-4 bg-black/40 backdrop-blur-xl p-5 rounded-xl border border-white/5 shadow-inner flex-grow flex flex-col justify-start">
                        <div class="group/item flex gap-3 items-start transition-transform duration-300 hover:translate-x-2 cursor-default">
                            <i class="fas fa-video text-red-500 mt-1 w-5 text-center text-lg"></i>
                            <p class="leading-relaxed text-base"><strong class="text-gray-400 uppercase text-xs tracking-wider mr-2 block sm:inline">Đạo diễn:</strong> <span class="text-white font-medium">${showtime.movie.director}</span></p>
                        </div>
                        <div class="group/item flex gap-3 items-start transition-transform duration-300 hover:translate-x-2 cursor-default">
                            <i class="fas fa-users text-red-500 mt-1 w-5 text-center text-lg"></i>
                            <p class="leading-relaxed text-base"><strong class="text-gray-400 uppercase text-xs tracking-wider mr-2 block sm:inline">Diễn viên:</strong> <span class="text-white font-medium break-words">${showtime.movie.cast}</span></p>
                        </div>
                        <div class="group/item flex gap-3 items-start transition-transform duration-300 hover:translate-x-2 cursor-default mt-2 bg-white/5 p-3 rounded-lg">
                            <i class="fas fa-align-left text-red-500 mt-1 w-5 text-center text-lg"></i>
                            <p class="leading-relaxed text-gray-300 italic text-sm text-justify">${showtime.movie.description}</p>
                        </div>

                        <div class="pt-4 mt-auto border-t border-white/10 flex flex-wrap gap-4 justify-between items-center">
                            <div class="flex items-center gap-3">
                                <strong class="text-gray-400 uppercase tracking-widest text-xs">Trailer:</strong>
                                <c:choose>
                                    <c:when test="${not empty showtime.movie.trailerUrl}">
                                        <a href="${showtime.movie.trailerUrl}" target="_blank" class="px-4 py-2 rounded-lg bg-red-600/20 text-red-400 hover:bg-red-600 hover:text-white transition-all duration-300 text-sm font-bold flex items-center gap-2 border border-red-600/50 shadow-[0_0_15px_rgba(220,38,38,0.2)] hover:shadow-[0_0_20px_rgba(220,38,38,0.5)] hover:-translate-y-1">
                                            <i class="fab fa-youtube text-lg"></i> Xem Ngay
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-gray-600 text-sm italic bg-gray-800/50 px-3 py-1 rounded-lg">Chưa cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="flex items-center gap-3 bg-green-500/10 px-5 py-2.5 rounded-xl border border-green-500/30">
                                <strong class="text-green-500/80 uppercase tracking-widest text-xs">Giá vé gốc:</strong>
                                <span class="text-green-400 font-black text-xl lg:text-2xl drop-shadow-[0_0_15px_rgba(74,222,128,0.6)] tracking-wide"><fmt:formatNumber value="${showtime.movie.basePrice}" pattern="#,###"/> ₫</span>
                            </div>
                        </div>
                    </div>

                    <div class="mt-auto pt-2">
                        <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${showtime.movie.id_Movie}" 
                           class="inline-flex items-center justify-center gap-3 w-full px-5 py-4 bg-gradient-to-r from-gray-800 to-[#121212] hover:from-red-700 hover:to-red-900 text-gray-200 hover:text-white rounded-xl text-base font-black tracking-widest uppercase transition-all duration-500 shadow-lg hover:shadow-[0_10px_30px_rgba(220,38,38,0.4)] hover:-translate-y-1 relative overflow-hidden group/btn border border-gray-700 hover:border-red-500">
                            <i class="fas fa-magic z-10 group-hover/btn:animate-spin-slow text-red-500 group-hover/btn:text-white transition-colors text-lg"></i>
                            <span class="z-10">Cập Nhật Thông Tin Phim</span>
                        </a>
                    </div>
                </div>
            </div>

            <c:set var="roomBgUrl" value="https://noithatduonggia.vn/wp-content/uploads/2019/05/tieu-chuan-thiet-ke-rap-chieu-phim.jpg" />
            <c:if test="${roomDetail.roomType == 'VIP'}">
                <c:set var="roomBgUrl" value="https://iguov8nhvyobj.vcdn.cloud/media/wysiwyg/special-cinemas/000.jpg" />
            </c:if>

            <div class="group relative p-6 sm:p-8 rounded-3xl border border-gray-700/50 shadow-2xl flex flex-col gap-6 hover:border-yellow-500/60 hover:shadow-[0_10px_50px_rgba(234,179,8,0.25)] hover:-translate-y-2 transition-all duration-500 overflow-hidden h-full bg-[#141414]">
                <div class="absolute inset-0 bg-cover bg-center opacity-10 blur-[40px] scale-110 transition-transform duration-1000 group-hover:scale-125" style="background-image: url('${roomBgUrl}');"></div>
                <div class="absolute inset-0 bg-gradient-to-br from-[#121212]/95 via-[#1a1a1a]/90 to-black/95"></div>
                <div class="absolute -right-10 -top-10 w-64 h-64 bg-yellow-600/10 blur-[70px] rounded-full transition-all duration-700 group-hover:bg-yellow-600/30 group-hover:scale-125 pointer-events-none"></div>

                <div class="relative overflow-hidden rounded-2xl shrink-0 w-full h-56 sm:h-72 shadow-[0_10px_30px_rgba(0,0,0,0.8)] group-hover:shadow-yellow-500/30 transition-all duration-500 z-10 border border-gray-600/50 group-hover:border-yellow-500/50">
                    <img src="${roomBgUrl}" class="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-700">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/95 via-black/50 to-transparent"></div>
                    <div class="absolute bottom-5 left-6">
                        <h3 class="text-4xl font-black text-white uppercase group-hover:text-yellow-400 transition-colors duration-300 drop-shadow-[0_5px_10px_rgba(0,0,0,0.9)] tracking-wider">${roomDetail.roomName}</h3>
                    </div>
                </div>

                <div class="flex flex-col justify-between w-full relative z-10 flex-grow space-y-5 mt-2">
                    <div class="flex flex-wrap gap-3 pb-3 border-b border-gray-800">
                        <span class="px-4 py-1.5 rounded-full bg-yellow-500/20 border border-yellow-500/50 text-yellow-400 text-xs font-bold tracking-widest uppercase shadow-[0_0_10px_rgba(234,179,8,0.2)]">${roomDetail.roomType}</span>
                        <c:choose>
                            <c:when test="${roomDetail.status == 'Active'}">
                                <span class="px-4 py-1.5 rounded-full bg-green-500/20 border border-green-500/50 text-green-400 text-xs font-bold tracking-widest uppercase shadow-[0_0_10px_rgba(34,197,94,0.2)]">Hoạt Động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="px-4 py-1.5 rounded-full bg-red-500/20 border border-red-500/50 text-red-400 text-xs font-bold tracking-widest uppercase shadow-[0_0_10px_rgba(239,68,68,0.2)]">${roomDetail.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="grid grid-cols-2 gap-4 text-sm text-gray-300">
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-4 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-yellow-500/30 transition-all hover:-translate-y-1 shadow-md">
                            <div class="w-12 h-12 rounded-full bg-yellow-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-arrows-alt-v text-yellow-400 text-lg"></i></div>
                            <div><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Số hàng</p><p class="font-black text-white text-lg">${roomDetail.totalRows}</p></div>
                        </div>
                        <div class="bg-black/40 backdrop-blur-md rounded-xl p-4 border border-white/5 flex items-center gap-4 hover:bg-black/60 hover:border-yellow-500/30 transition-all hover:-translate-y-1 shadow-md">
                            <div class="w-12 h-12 rounded-full bg-yellow-500/20 flex items-center justify-center shrink-0 shadow-inner"><i class="fas fa-arrows-alt-h text-yellow-400 text-lg"></i></div>
                            <div><p class="text-xs text-gray-400 uppercase font-bold tracking-wider mb-0.5">Số cột</p><p class="font-black text-white text-lg">${roomDetail.totalCols}</p></div>
                        </div>
                    </div>

                    <div class="text-sm text-gray-300 space-y-4 bg-black/40 backdrop-blur-xl p-6 rounded-xl border border-white/5 shadow-inner flex-grow flex flex-col justify-start">
                        <div class="group/item flex justify-between items-center transition-transform duration-300 hover:translate-x-2 cursor-default bg-white/5 p-3 rounded-lg">
                            <strong class="text-gray-300 uppercase text-xs tracking-wider flex items-center gap-3"><i class="fas fa-users text-yellow-500 text-lg"></i> Tổng sức chứa:</strong>
                            <span class="text-white font-black text-xl">${roomDetail.totalRows * roomDetail.totalCols} <span class="text-sm font-normal text-gray-400">ghế ngồi</span></span>
                        </div>
                        <div class="group/item flex justify-between items-center transition-transform duration-300 hover:translate-x-2 cursor-default bg-white/5 p-3 rounded-lg">
                            <strong class="text-gray-300 uppercase text-xs tracking-wider flex items-center gap-3"><i class="fas fa-vr-cardboard text-yellow-500 text-lg"></i> Định dạng hỗ trợ:</strong>
                            <span class="text-white font-bold text-base bg-gray-800 px-3 py-1 rounded-md">Chiếu 2D, 3D</span>
                        </div>

                        <div class="pt-4 mt-auto border-t border-white/10 flex justify-between items-center">
                            <div class="flex items-center gap-3 bg-yellow-500/10 px-5 py-3 rounded-xl border border-yellow-500/30 w-full justify-between shadow-[0_0_15px_rgba(234,179,8,0.1)] hover:shadow-[0_0_25px_rgba(234,179,8,0.3)] transition-shadow">
                                <strong class="text-yellow-500/80 uppercase tracking-widest text-xs">Phụ thu phòng:</strong>
                                <span class="text-yellow-400 font-black text-xl lg:text-2xl drop-shadow-[0_0_15px_rgba(250,204,21,0.6)] tracking-wide">+<fmt:formatNumber value="${roomDetail.roomPrice}" pattern="#,###"/> ₫</span>
                            </div>
                        </div>
                    </div>

                    <div class="mt-auto pt-2">
                        <a href="${pageContext.request.contextPath}/admin/rooms/detail?id=${roomDetail.id_Room}&mode=edit" 
                           class="inline-flex items-center justify-center gap-3 w-full px-5 py-4 bg-gradient-to-r from-gray-800 to-[#121212] hover:from-yellow-600 hover:to-yellow-800 text-gray-200 hover:text-white rounded-xl text-base font-black tracking-widest uppercase transition-all duration-500 shadow-lg hover:shadow-[0_10px_30px_rgba(234,179,8,0.4)] hover:-translate-y-1 relative overflow-hidden group/btn border border-gray-700 hover:border-yellow-500">
                            <i class="fas fa-cogs z-10 group-hover/btn:rotate-180 transition-transform duration-700 text-yellow-500 group-hover/btn:text-white text-lg"></i>
                            <span class="z-10">Cấu Hình Lại Phòng Này</span>
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </c:if>

    <div class="group/form relative bg-gradient-to-b from-[#1a1a1a] to-[#121212] p-6 sm:p-10 rounded-3xl border border-gray-800/60 shadow-2xl z-20 hover:border-gray-700 transition-all duration-500 mt-12 overflow-hidden">
        <div class="absolute -bottom-20 -right-20 w-80 h-80 bg-red-600/5 blur-[100px] rounded-full group-hover/form:bg-red-600/10 transition-all duration-1000 pointer-events-none"></div>

        <h3 class="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-white mb-10 border-b border-gray-800/80 pb-6 flex items-center gap-4 relative z-10 uppercase tracking-widest">
            <i class="fas fa-sliders-h text-red-500 drop-shadow-[0_0_10px_rgba(239,68,68,0.8)]"></i> Cấu Hình Lịch Trình Suất Chiếu
        </h3>

        <div class="mb-8 p-5 bg-blue-900/10 border border-blue-500/20 rounded-2xl relative z-10 hover:bg-blue-900/20 transition-colors duration-300 shadow-inner">
            <label class="text-sm font-bold text-blue-400 tracking-widest uppercase ml-2 mb-3 flex items-center gap-2">
                <i class="fas fa-calendar-check animate-bounce"></i> Tự điền nhanh Thời gian
            </label>
            <div class="flex flex-col md:flex-row gap-4 items-center">
                <div class="relative group/input w-full md:w-1/2">
                    <input type="datetime-local" id="quickDateTime" class="w-full bg-black/60 text-white pl-14 pr-6 py-4 rounded-xl border border-blue-500/50 hover:border-blue-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/30 transition-all outline-none text-base font-medium shadow-inner cursor-pointer">
                    <i class="fas fa-magic absolute left-5 top-1/2 -translate-y-1/2 text-blue-400 text-xl group-hover/input:scale-110 transition-transform"></i>
                </div>
                <div class="text-sm text-gray-400 italic flex-1">
                    <i class="fas fa-info-circle text-gray-500 mr-1"></i> Mẹo: Chọn ngày và giờ ở đây, hệ thống sẽ tự động tách và điền xuống 2 ô "Ngày chiếu" & "Giờ bắt đầu" bên dưới.
                </div>
            </div>
        </div>

        <form id="showtimeForm" action="${pageContext.request.contextPath}/admin/showtimes/save" method="POST" class="space-y-10 relative z-10" onsubmit="return validateForm()">
            <input type="hidden" name="id_Showtime" value="${showtime.id_Showtime}">
            <input type="hidden" name="endTime" id="hiddenEndTime" value="${fmtEnd}">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
                <div class="space-y-4">
                    <label class="text-sm font-bold text-gray-300 tracking-widest uppercase ml-2">Phim được chiếu</label>

                    <div class="relative group/input" id="customMovieSelectContainer">

                        <select name="movieId" id="movieSelect" class="hidden" required>
                            <option value="" disabled ${empty showtime.movieId ? 'selected' : ''}>-- Chọn Phim --</option>
                            <c:forEach items="${movies}" var="m">
                                <option value="${m.id_Movie}" data-duration="${m.duration}" data-price="${m.basePrice}" ${m.id_Movie == showtime.movieId ? 'selected' : ''}>${m.title}</option>
                            </c:forEach>
                        </select>

                        <div id="movieSelectDisplay" class="w-full bg-black/50 text-white pl-14 pr-6 py-5 rounded-2xl border border-gray-700/80 hover:border-red-500/50 focus-within:border-red-500 focus-within:ring-2 focus-within:ring-red-500/30 transition-all outline-none backdrop-blur-md text-base font-medium shadow-inner cursor-pointer flex items-center justify-between">
                            <span id="selectedMovieText" class="truncate">
                                <c:choose>
                                    <c:when test="${not empty showtime.movieId && showtime.movieId > 0}">
                                        <c:forEach var="m" items="${movies}">
                                            <c:if test="${m.id_Movie == showtime.movieId}">${m.title}</c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise><span class="text-gray-400">-- Nhấp để chọn phim --</span></c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <i class="fas fa-film absolute left-5 top-1/2 -translate-y-1/2 text-red-500 text-xl group-hover/input:scale-110 transition-transform pointer-events-none"></i>
                        <i class="fas fa-chevron-down absolute right-5 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none transition-transform duration-300" id="movieSelectIcon"></i>

                        <div id="movieDropdownList" class="absolute z-[100] w-full mt-2 bg-[#121212] border border-gray-700/80 rounded-2xl shadow-2xl hidden opacity-0 transform scale-95 transition-all duration-200 origin-top overflow-hidden">

                            <div class="p-3 border-b border-gray-700/80 bg-[#1a1a1a]">
                                <div class="relative">
                                    <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                                    <input type="text" id="movieSearchInput" placeholder="Nhập tên phim để lọc nhanh..." 
                                           class="w-full bg-black/60 border border-gray-700 text-white text-sm rounded-xl pl-10 pr-4 py-3 focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 transition-colors" autocomplete="off">
                                </div>
                            </div>

                            <ul id="movieOptionsUl" class="max-h-60 overflow-y-auto custom-scrollbar py-2">
                            </ul>

                            <div id="movieNoResult" class="p-4 text-center text-red-400 text-sm hidden font-medium">
                                <i class="fas fa-times-circle mr-1"></i> Không tìm thấy phim phù hợp!
                            </div>
                        </div>
                    </div>
                </div>
                <div class="space-y-4">
                    <label class="text-sm font-bold text-gray-300 tracking-widest uppercase ml-2">Phòng chiếu</label>
                    <div class="relative group/input">
                        <select name="roomId" id="roomSelect" class="w-full bg-black/50 text-white pl-14 pr-6 py-5 rounded-2xl border border-gray-700/80 hover:border-red-500/50 focus:border-red-500 focus:ring-2 focus:ring-red-500/30 transition-all outline-none backdrop-blur-md appearance-none text-base font-medium shadow-inner cursor-pointer" required>
                            <option value="" disabled ${empty showtime.roomId ? 'selected' : ''}>-- Chọn Phòng --</option>
                            <c:forEach items="${rooms}" var="r">
                                <option value="${r.id_Room}" data-price="${r.roomPrice}" class="bg-[#121212]" ${r.id_Room == showtime.roomId ? 'selected' : ''}>${r.roomName} (${r.roomType})</option>
                            </c:forEach>
                        </select>
                        <i class="fas fa-door-open absolute left-5 top-1/2 -translate-y-1/2 text-red-500 text-xl group-hover/input:scale-110 transition-transform"></i>
                        <i class="fas fa-chevron-down absolute right-5 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none"></i>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 bg-black/30 p-8 rounded-3xl border border-white/5 shadow-inner">
                <div class="space-y-4">
                    <label class="text-sm font-bold text-gray-300 tracking-widest uppercase ml-2">Ngày chiếu</label>
                    <div class="relative group/dt">
                        <input type="date" name="showDate" id="showDate" value="${fmtDate}" class="w-full bg-black/50 text-white pl-12 pr-4 py-4 rounded-xl border border-gray-700/80 hover:border-red-500/50 focus:border-red-500 focus:ring-2 focus:ring-red-500/30 transition-all outline-none backdrop-blur-md text-base font-medium shadow-inner" required>
                        <i class="fas fa-calendar-day absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-hover/dt:text-red-400 transition-colors"></i>
                    </div>
                </div>
                <div class="space-y-4">
                    <label class="text-sm font-bold text-gray-300 tracking-widest uppercase ml-2">Giờ bắt đầu</label>
                    <div class="relative group/dt">
                        <input type="time" name="startTime" id="startTime" value="${fmtStart}" class="w-full bg-black/50 text-white pl-12 pr-4 py-4 rounded-xl border border-gray-700/80 hover:border-red-500/50 focus:border-red-500 focus:ring-2 focus:ring-red-500/30 transition-all outline-none backdrop-blur-md text-base font-medium shadow-inner" required>
                        <i class="fas fa-clock absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-hover/dt:text-red-400 transition-colors"></i>
                    </div>
                </div>
                <div class="space-y-4">
                    <label class="text-sm font-bold text-yellow-500/80 tracking-widest uppercase ml-2">Thời gian quảng cáo</label>
                    <div class="relative">
                        <input type="text" value="15 Phút" class="w-full bg-yellow-900/10 text-yellow-500 px-5 py-4 rounded-xl border border-yellow-700/40 outline-none text-center font-bold text-base cursor-not-allowed shadow-inner" readonly title="Mặc định chiếu quảng cáo trước phim">
                        <i class="fas fa-ad absolute left-4 top-1/2 -translate-y-1/2 text-yellow-600"></i>
                    </div>
                </div>
                <div class="space-y-4">
                    <label class="text-sm font-bold text-red-400 tracking-widest uppercase ml-2">Giờ kết thúc dự kiến</label>
                    <div class="relative">
                        <input type="text" id="endTimeDisplay" value="${not empty fmtEndDisplay ? fmtEndDisplay : 'Chưa có dữ liệu'}" class="w-full bg-red-900/10 text-red-400 px-5 py-4 rounded-xl border border-red-800/40 outline-none text-center text-base font-black cursor-not-allowed shadow-inner" readonly title="Hệ thống sẽ tự tính toán">
                        <i class="fas fa-flag-checkered absolute left-4 top-1/2 -translate-y-1/2 text-red-500/50"></i>
                    </div>
                </div>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-6 bg-[#1a1a1a] p-6 rounded-2xl border border-gray-800 shadow-lg">
                <div class="flex items-center gap-4 bg-green-900/10 px-6 py-3 rounded-xl border border-green-500/20 w-full md:w-auto">
                    <div class="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center shrink-0"><i class="fas fa-ticket-alt text-green-500 text-xl"></i></div>
                    <div>
                        <p class="text-xs text-green-500/80 uppercase font-bold tracking-widest mb-1">Giá 1 vé (Gốc + Phụ thu)</p>
                        <p class="font-black text-green-400 text-2xl" id="displayTotalPrice">0 ₫</p>
                    </div>
                </div>

                <div class="flex flex-wrap gap-4 w-full md:w-auto justify-end">
                    <button type="button" onclick="predictEndTime()" class="px-6 py-3 bg-gray-800 hover:bg-gray-700 text-white rounded-xl font-bold text-sm uppercase tracking-wider transition-all duration-300 border border-gray-600 flex items-center gap-2 hover:-translate-y-1 hover:shadow-lg">
                        <i class="fas fa-calculator text-blue-400"></i> Xem Dự Đoán
                    </button>
                    <button type="button" onclick="resetCalculations()" class="px-6 py-3 bg-red-900/20 hover:bg-red-800/40 text-red-400 hover:text-red-300 rounded-xl font-bold text-sm uppercase tracking-wider transition-all duration-300 border border-red-800/50 flex items-center gap-2 hover:-translate-y-1 hover:shadow-lg">
                        <i class="fas fa-undo"></i> Đặt Lại
                    </button>
                </div>
            </div>

            <div class="flex justify-end pt-8 mt-8 border-t border-gray-800/80">
                <button type="submit" id="btnSubmitForm" class="group px-12 py-5 bg-gradient-to-r from-red-600 to-red-700 text-white rounded-2xl font-black text-base uppercase tracking-widest shadow-[0_10px_30px_rgba(220,38,38,0.4)] transition-all duration-300 hover:from-red-500 hover:to-red-600 hover:-translate-y-2 hover:shadow-[0_15px_40px_rgba(220,38,38,0.6)] flex items-center overflow-hidden relative border border-red-500">
                    <span class="absolute w-0 h-0 transition-all duration-500 ease-out bg-white rounded-full group-hover:w-72 group-hover:h-72 opacity-20"></span>
                    <i class="fas fa-check-circle mr-3 text-xl relative z-10 group-hover:scale-125 transition-transform duration-300"></i> 
                    <span class="relative z-10">Xác Nhận Lưu</span>
                </button>
            </div>
        </form>
    </div>

    <c:if test="${not empty showtime.id_Showtime && showtime.id_Showtime > 0}">
        <div class="bg-[#1a1a1a] p-8 sm:p-10 rounded-3xl border border-gray-800/60 shadow-xl mt-12 relative overflow-hidden group">
            <div class="absolute -top-32 -left-32 w-80 h-80 bg-blue-600/5 blur-[100px] rounded-full pointer-events-none group-hover:bg-blue-600/10 transition-all duration-1000"></div>

            <h3 class="text-3xl font-black text-white mb-10 border-b border-gray-800 pb-6 flex items-center gap-4 uppercase tracking-widest relative z-10">
                <i class="fas fa-ticket-alt text-red-500 drop-shadow-[0_0_10px_rgba(239,68,68,0.8)]"></i> Bản Đồ Bán Vé Mốc Thời Gian Này
            </h3>

            <div class="w-full overflow-x-auto pb-10 custom-scrollbar relative z-10">
                <div class="min-w-max mx-auto flex flex-col items-center px-6">
                    <div class="relative w-[90%] max-w-4xl h-16 border-t-8 border-white/70 bg-gradient-to-b from-white/10 to-transparent rounded-t-[50%] mb-20 flex justify-center mt-8 shadow-[0_-15px_40px_rgba(255,255,255,0.1)] group-hover:border-white transition-colors duration-500">
                        <span class="absolute top-4 text-gray-300 font-black tracking-[25px] text-base uppercase shadow-sm">MÀN HÌNH CHIẾU</span>
                        <div class="absolute -top-2 w-full h-2 bg-white/40 blur-[15px] group-hover:bg-white/60 transition-colors duration-500"></div>
                    </div>

                    <div class="grid gap-3 sm:gap-4 mb-16" style="grid-template-columns: repeat(${not empty roomDetail ? roomDetail.totalCols : 10}, minmax(0, 1fr));">
                        <c:forEach items="${roomDetail.seats}" var="seat">
                            <c:choose>
                                <c:when test="${seat.status == 'Broken' || seat.status == 'Maintenance'}">
                                    <div class="w-12 h-12 bg-gray-700/80 text-gray-400 font-bold text-sm flex items-center justify-center rounded-t-2xl rounded-b-md flex-col border-b-4 border-gray-900 opacity-70 cursor-not-allowed" title="Ghế bảo trì">
                                        <span>${seat.seatName}</span>
                                    </div>
                                </c:when>
                                <c:when test="${seat.status == 'Sold'}">
                                    <div data-seat-id="${seat.id_Seat}" 
                                         onclick="openTicketModal(${showtime.id_Showtime}, ${seat.id_Seat}, '${seat.seatName}')" 
                                         class="w-12 h-12 bg-yellow-500 text-yellow-900 font-black text-sm flex items-center justify-center rounded-t-2xl rounded-b-md flex-col border-b-4 border-yellow-700 shadow-[0_0_20px_rgba(234,179,8,0.6)] cursor-pointer transform hover:scale-110 hover:-translate-y-2 transition-all duration-300 group/sold" 
                                         title="Nhấn để xem thông tin người mua">
                                        <span class="relative z-10">${seat.seatName}</span>
                                        <div class="absolute inset-0 bg-white/30 rounded-t-2xl rounded-b-md opacity-0 group-hover/sold:opacity-100 transition-opacity"></div>
                                    </div>
                                </c:when>

                                <c:when test="${seat.status == 'Sold_Maintenance'}">
                                    <div data-seat-id="${seat.id_Seat}" 
                                         onclick="openTicketModal(${showtime.id_Showtime}, ${seat.id_Seat}, '${seat.seatName}')" 
                                         class="w-12 h-12 text-white font-black text-sm flex items-center justify-center rounded-t-2xl rounded-b-md flex-col border-b-4 border-gray-900 shadow-[0_0_20px_rgba(234,179,8,0.3)] cursor-pointer transform hover:scale-110 hover:-translate-y-2 transition-all duration-300 group/mixed relative overflow-hidden" 
                                         title="Ghế đang bảo trì nhưng có vé đã bán. Nhấn để xem thông tin!">

                                        <div class="absolute inset-0 bg-gradient-to-br from-gray-700 via-gray-600 to-yellow-600 opacity-90 z-0"></div>

                                        <span class="relative z-10 drop-shadow-md">${seat.seatName}</span>
                                        <div class="absolute inset-0 bg-white/30 rounded-t-2xl rounded-b-md opacity-0 group-hover/mixed:opacity-100 transition-opacity z-10"></div>

                                        <i class="fas fa-exclamation-triangle absolute top-0.5 right-0.5 text-[8px] text-yellow-300 z-10 animate-pulse"></i>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-12 h-12 bg-gradient-to-b from-red-500 to-red-600 text-white font-bold text-sm flex items-center justify-center rounded-t-2xl rounded-b-md flex-col border-b-4 border-red-800 shadow-[0_0_15px_rgba(220,38,38,0.5)] cursor-pointer hover:-translate-y-2 hover:from-red-400 hover:to-red-500 hover:shadow-[0_10px_25px_rgba(220,38,38,0.8)] transition-all duration-300 relative group/seat" title="Ghế trống">
                                        <span class="relative z-10">${seat.seatName}</span>
                                        <div class="absolute inset-0 bg-white/20 rounded-t-2xl rounded-b-md opacity-0 group-hover/seat:opacity-100 transition-opacity"></div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </div>

                    <div class="flex flex-wrap justify-center gap-10 bg-[#121212]/80 backdrop-blur-sm px-10 py-6 rounded-2xl border border-gray-800 shadow-inner w-full max-w-4xl">
                        <div class="flex items-center gap-4 hover:scale-105 transition-transform cursor-default">
                            <div class="w-8 h-8 bg-gradient-to-b from-red-500 to-red-600 border-b-4 border-red-800 rounded-t-xl rounded-b-sm shadow-[0_0_15px_rgba(220,38,38,0.5)]"></div>
                            <span class="text-base font-bold text-red-500 uppercase tracking-widest">Trống</span>
                        </div>
                        <div class="flex items-center gap-4 hover:scale-105 transition-transform cursor-default">
                            <div class="w-8 h-8 bg-yellow-500 border-b-4 border-yellow-700 rounded-t-xl rounded-b-sm shadow-[0_0_20px_rgba(234,179,8,0.6)]"></div>
                            <span class="text-base font-bold text-yellow-500 uppercase tracking-widest">Đã Bán</span>
                        </div>
                        <div class="flex items-center gap-4 hover:scale-105 transition-transform cursor-default">
                            <div class="w-8 h-8 bg-gray-700/80 border-b-4 border-gray-900 rounded-t-xl rounded-b-sm opacity-70"></div>
                            <span class="text-base font-bold text-gray-400 uppercase tracking-widest">Bảo Trì</span>
                        </div>

                        <div class="flex items-center gap-4 hover:scale-105 transition-transform cursor-default">
                            <div class="relative w-8 h-8 rounded-t-xl rounded-b-sm border-b-4 border-gray-900 overflow-hidden shadow-[0_0_15px_rgba(234,179,8,0.3)]">
                                <div class="absolute inset-0 bg-gradient-to-br from-gray-700 via-gray-600 to-yellow-600"></div>
                            </div>
                            <span class="text-base font-bold text-transparent bg-clip-text bg-gradient-to-r from-gray-400 to-yellow-500 uppercase tracking-widest">Vé Bán / Bảo Trì</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-[#1a1a1a] p-8 sm:p-10 rounded-3xl border border-gray-800/60 shadow-xl mt-12">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-5 border-b border-gray-800 pb-6">
                <h3 class="text-2xl sm:text-3xl font-black text-white flex items-center gap-4 uppercase tracking-widest relative z-10 w-full md:w-auto">
                    <i class="fas fa-list-alt text-red-500 drop-shadow-[0_0_10px_rgba(239,68,68,0.8)]"></i> Suất Chiếu Cùng Phim
                </h3>

                <div class="flex flex-wrap gap-4 w-full md:w-auto">
                    <div class="relative group/filter">
                        <select id="statusFilter" class="bg-black/50 text-gray-300 pl-10 pr-8 py-2.5 rounded-xl border border-gray-700/80 focus:border-red-500 focus:ring-2 focus:ring-red-500/30 outline-none text-sm font-bold shadow-inner cursor-pointer appearance-none min-w-[160px]">
                            <option value="all">Tất cả trạng thái</option>
                            <option value="upcoming">Sắp chiếu</option>
                            <option value="now_showing">Đang chiếu</option>
                            <option value="finished">Đã chiếu</option>
                        </select>
                        <i class="fas fa-filter absolute left-4 top-1/2 -translate-y-1/2 text-red-500"></i>
                        <i class="fas fa-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none text-xs"></i>
                    </div>

                    <div class="relative group/filter">
                        <select id="dateFilter" class="bg-black/50 text-gray-300 pl-10 pr-8 py-2.5 rounded-xl border border-gray-700/80 focus:border-red-500 focus:ring-2 focus:ring-red-500/30 outline-none text-sm font-bold shadow-inner cursor-pointer appearance-none min-w-[160px]">
                            <option value="all">Tất cả ngày chiếu</option>
                        </select>
                        <i class="fas fa-calendar-alt absolute left-4 top-1/2 -translate-y-1/2 text-blue-400"></i>
                        <i class="fas fa-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none text-xs"></i>
                    </div>
                </div>
            </div>

            <div class="overflow-x-auto rounded-2xl border border-gray-800 shadow-inner">
                <table class="w-full text-base text-left text-gray-400">
                    <thead class="text-xs text-gray-300 uppercase bg-[#121212] border-b border-gray-800 tracking-widest">
                        <tr>
                            <th class="px-6 py-5">Ngày Chiếu</th>
                            <th class="px-6 py-5">Khung Giờ</th>
                            <th class="px-6 py-5">Phòng Chiếu</th>
                            <th class="px-6 py-5 text-center">Tỉ Lệ Vé (Đã Bán/Tổng)</th>
                            <th class="px-6 py-5 text-right">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="otherShowtimesTableBody" class="divide-y divide-gray-800/50 relative">
                        <tr id="emptyFilterRow" class="hidden">
                            <td colspan="5" class="px-6 py-10 text-center text-gray-500">
                                <i class="fas fa-box-open text-4xl mb-3 opacity-50 block"></i>
                                <p class="text-sm uppercase tracking-wider font-bold">Không tìm thấy suất chiếu nào phù hợp với bộ lọc</p>
                            </td>
                        </tr>

                        <c:forEach items="${otherShowtimes}" var="os">
                            <c:if test="${os.id_Showtime != showtime.id_Showtime}">
                                <fmt:formatDate value="${os.showDate}" pattern="yyyy-MM-dd" var="osRawDate"/>
                                <fmt:formatDate value="${os.showDate}" pattern="dd/MM/yyyy" var="osDisplayDate"/>
                                <fmt:formatDate value="${os.startTime}" pattern="HH:mm" var="osStart"/>
                                <fmt:formatDate value="${os.endTime}" pattern="HH:mm" var="osEnd"/>

                                <tr class="other-st-row hover:bg-red-900/10 transition-colors duration-300 group/row" 
                                    data-date="${osRawDate}" 
                                    data-start="${osRawDate}T${osStart}" 
                                    data-end="${os.endTime}">

                                    <td class="px-6 py-4 text-white font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="w-8 h-8 rounded-lg bg-blue-500/10 flex items-center justify-center border border-blue-500/20"><i class="fas fa-calendar-day text-blue-400 text-sm"></i></div>
                                                ${osDisplayDate}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="bg-gray-800/80 text-gray-300 font-bold px-3 py-1.5 rounded-lg text-sm tracking-wider border border-gray-700">${osStart} - ${osEnd}</span>
                                    </td>
                                    <td class="px-6 py-4 text-yellow-400 font-bold tracking-wide uppercase text-sm">
                                        <i class="fas fa-door-closed mr-1 opacity-70"></i> ${os.room.roomName}
                                    </td>

                                    <td class="px-6 py-4">
                                        <div class="w-full max-w-[150px] mx-auto">
                                            <div class="flex justify-between text-xs font-bold mb-1">
                                                <span class="text-green-400">${os.room.totalCols} Đã bán</span>
                                                <span class="text-gray-500">${os.room.totalRows} Ghế</span>
                                            </div>
                                            <div class="w-full bg-gray-800 rounded-full h-2 overflow-hidden shadow-inner border border-gray-700">
                                                <c:set var="percent" value="${(os.room.totalCols * 100) / (os.room.totalRows == 0 ? 1 : os.room.totalRows)}" />
                                                <div class="bg-gradient-to-r from-green-500 to-emerald-400 h-2 rounded-full" style="width: ${percent}%;"></div>
                                            </div>
                                        </div>
                                    </td>

                                    <td class="px-6 py-4 text-right">
                                        <a href="${pageContext.request.contextPath}/admin/showtimes/edit/${os.id_Showtime}" class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-red-600/10 text-red-500 font-bold hover:bg-red-600 hover:text-white transition-all duration-300 border border-red-600/30 text-xs uppercase tracking-wider hover:shadow-[0_0_15px_rgba(220,38,38,0.5)] hover:-translate-x-1">
                                            Sửa <i class="fas fa-pencil-alt group-hover/row:scale-110 transition-transform"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>
</div>
<div id="ticketModal" class="fixed inset-0 z-[99999] flex items-center justify-center hidden opacity-0 transition-opacity duration-300">
    <div class="absolute inset-0 bg-black/80 backdrop-blur-sm" onclick="closeTicketModal()"></div>

    <div class="relative bg-[#141414] border border-gray-700/60 rounded-3xl shadow-[0_20px_50px_rgba(0,0,0,0.8)] w-full max-w-md transform scale-95 transition-transform duration-300 overflow-hidden group">
        <div class="absolute -top-20 -right-20 w-40 h-40 bg-yellow-500/10 blur-[50px] rounded-full pointer-events-none"></div>

        <div class="bg-[#1a1a1a] px-6 py-4 border-b border-gray-800 flex justify-between items-center relative z-10">
            <h3 class="text-xl font-black text-white uppercase tracking-widest flex items-center gap-3">
                <i class="fas fa-ticket-alt text-yellow-500"></i> Thông Tin Vé
            </h3>
            <button onclick="closeTicketModal()" class="text-gray-500 hover:text-red-500 transition-colors bg-white/5 w-8 h-8 rounded-full flex items-center justify-center hover:bg-red-500/10">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <div class="p-6 relative z-10">
            <div id="modalLoader" class="flex flex-col items-center justify-center py-10">
                <i class="fas fa-circle-notch fa-spin text-4xl text-yellow-500 mb-4"></i>
                <p class="text-gray-400 font-bold uppercase tracking-wider text-sm animate-pulse">Đang tải dữ liệu...</p>
            </div>

            <div id="modalContent" class="hidden space-y-6">
                <div class="flex justify-between items-center bg-black/40 p-4 rounded-xl border border-white/5">
                    <div class="text-center">
                        <p class="text-xs text-gray-500 uppercase font-bold tracking-widest mb-1">Ghế ngồi</p>
                        <p id="mdSeatName" class="text-3xl font-black text-yellow-500 drop-shadow-[0_0_10px_rgba(234,179,8,0.5)]">--</p>
                    </div>
                    <div class="text-right">
                        <p class="text-xs text-gray-500 uppercase font-bold tracking-widest mb-1">Mã HĐ</p>
                        <p id="mdBookingId" class="text-xl font-black text-white">#--</p>
                    </div>
                </div>

                <div class="space-y-3">
                    <h4 class="text-xs text-gray-500 uppercase font-bold tracking-widest border-b border-gray-800 pb-2">Thông tin khách hàng</h4>
                    <div class="flex items-center gap-3 bg-white/5 p-3 rounded-lg border border-white/5">
                        <div class="w-10 h-10 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400 shrink-0"><i class="fas fa-user"></i></div>
                        <div class="overflow-hidden">
                            <p id="mdCusName" class="text-white font-bold text-base truncate">--</p>
                            <p id="mdCusContact" class="text-gray-400 text-xs truncate">--</p>
                        </div>
                    </div>
                </div>

                <div class="space-y-3">
                    <h4 class="text-xs text-gray-500 uppercase font-bold tracking-widest border-b border-gray-800 pb-2">Chi tiết thanh toán</h4>
                    <div class="grid grid-cols-2 gap-3 text-sm">
                        <div class="bg-white/5 p-3 rounded-lg border border-white/5">
                            <p class="text-gray-400 text-xs mb-1">Ngày mua</p>
                            <p id="mdBookingDate" class="text-white font-medium">--</p>
                        </div>
                        <div class="bg-white/5 p-3 rounded-lg border border-white/5">
                            <p class="text-gray-400 text-xs mb-1">Phương thức</p>
                            <p id="mdPaymentMethod" class="text-green-400 font-bold uppercase">--</p>
                        </div>
                        <div class="bg-yellow-500/10 p-3 rounded-lg border border-yellow-500/20 col-span-2 flex justify-between items-center">
                            <p class="text-yellow-500/80 text-xs font-bold uppercase">Giá vé này</p>
                            <p id="mdTicketPrice" class="text-yellow-400 font-black text-lg">-- ₫</p>
                        </div>
                    </div>
                </div>

                <div class="pt-2">
                    <a id="mdCusLink" href="#" class="w-full block text-center py-3 bg-gray-800 hover:bg-gray-700 text-white rounded-xl font-bold uppercase tracking-widest text-sm transition-all border border-gray-600 hover:border-gray-500">
                        <i class="fas fa-external-link-alt mr-2"></i> Đi tới Hồ Sơ Khách Hàng
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
    const rows = document.querySelectorAll('.other-st-row');
    const dateFilter = document.getElementById('dateFilter');
    const statusFilter = document.getElementById('statusFilter');
    const emptyRow = document.getElementById('emptyFilterRow');
    // Lấy tất cả các ngày chiếu duy nhất để đổ vào Dropdown Date
    // Hàm tự động tính toán và cập nhật danh sách các Ngày chiếu trong Dropdown
    // Hàm tự động tính toán và cập nhật danh sách các Ngày chiếu trong Dropdown
    function populateDateFilter() {
    const selectedStatus = statusFilter.value;
    const now = new Date();
    const currentSelectedDate = dateFilter.value; // Lưu lại ngày đang chọn

    // Reset dropdown về mặc định
    dateFilter.innerHTML = '<option value="all">Tất cả ngày chiếu</option>';
    let availableDates = new Set();
    // Duyệt qua tất cả các dòng để tìm các ngày hợp lệ với trạng thái đang chọn
    rows.forEach(row => {
    const startObj = new Date(row.getAttribute('data-start'));
    const rawEnd = row.getAttribute('data-end').replace('.0', '').replace(' ', 'T');
    const endObj = new Date(rawEnd);
    let matchesStatus = true;
    if (selectedStatus !== 'all') {
    if (selectedStatus === 'finished' && endObj >= now) matchesStatus = false;
    else if (selectedStatus === 'now_showing' && !(now >= startObj && now <= endObj)) matchesStatus = false;
    else if (selectedStatus === 'upcoming' && startObj <= now) matchesStatus = false;
    }

    // Nếu thỏa mãn trạng thái, thêm ngày của nó vào danh sách hiển thị
    if (matchesStatus) {
    availableDates.add(row.getAttribute('data-date'));
    }
    });
    // Chuyển Set thành Array và sắp xếp ngày giảm dần
    let sortedDates = Array.from(availableDates).sort().reverse();
    // Đổ dữ liệu ngày mới vào Dropdown lọc ngày
    sortedDates.forEach(dateStr => {
    const option = document.createElement('option');
    option.value = dateStr;
    const parts = dateStr.split('-');
    // ĐÃ SỬA LỖI ĐỤNG ĐỘ JSP (Sửa // thành dấu cộng chuỗi)
    option.textContent = parts.length === 3 ? (parts[2] + '/' + parts[1] + '/' + parts[0]) : dateStr;
    dateFilter.appendChild(option);
    });
    // Khôi phục lại ngày người dùng đang chọn trước đó (nếu ngày đó vẫn hợp lệ)
    if (availableDates.has(currentSelectedDate)) {
    dateFilter.value = currentSelectedDate;
    } else {
    dateFilter.value = 'all';
    }
    }

    // Hàm xử lý logic lọc (Ẩn/hiện các dòng trên bảng)
    function filterShowtimes() {
    const selectedDate = dateFilter.value;
    const selectedStatus = statusFilter.value;
    const now = new Date();
    let visibleCount = 0;
    rows.forEach(row => {
    const rowDate = row.getAttribute('data-date');
    const startObj = new Date(row.getAttribute('data-start'));
    const rawEnd = row.getAttribute('data-end').replace('.0', '').replace(' ', 'T');
    const endObj = new Date(rawEnd);
    let showRow = true;
    // Kiểm tra bộ lọc ngày chiếu
    if (selectedDate !== 'all' && rowDate !== selectedDate) {
    showRow = false;
    }

    // Kiểm tra bộ lọc trạng thái
    if (selectedStatus !== 'all') {
    if (selectedStatus === 'finished') {
    if (endObj >= now) showRow = false;
    } else if (selectedStatus === 'now_showing') {
    if (!(now >= startObj && now <= endObj)) showRow = false;
    } else if (selectedStatus === 'upcoming') {
    if (startObj <= now) showRow = false;
    }
    }

    // Hiển thị hoặc ẩn dòng
    if (showRow) {
    row.style.display = '';
    row.style.opacity = '1';
    visibleCount++;
    } else {
    row.style.display = 'none';
    row.style.opacity = '0';
    }
    });
    if (visibleCount === 0 && rows.length > 0) {
    emptyRow.style.display = '';
    } else {
    emptyRow.style.display = 'none';
    }
    }

    // GẮN SỰ KIỆN LẮNG NGHE CHO 2 BỘ LỌC
    // Khi thay đổi trạng thái -> Cập nhật lại dropdown ngày -> Sau đó mới lọc bảng
    statusFilter.addEventListener('change', function() {
    populateDateFilter();
    filterShowtimes();
    });
    // Khi thay đổi ngày -> Chỉ lọc bảng
    dateFilter.addEventListener('change', filterShowtimes);
    // Khởi chạy lần đầu khi tải trang
    populateDateFilter();
    filterShowtimes();
    });
    // 1. Tự động lấy dữ liệu lịch chiếu hiện có từ JSP đưa vào mảng JS để kiểm tra trùng lặp
    const existingShowtimes = [
    <c:forEach items="${otherShowtimes}" var="os">
        <c:if test="${os.id_Showtime != showtime.id_Showtime}">
    {
    roomId: '${os.roomId}',
            // Ép kiểu chuẩn ISO 8601 để Date() trong JS đọc được
            start: new Date('${os.showDate}T${os.startTime}'),
                        end: new Date('${os.showDate}T${os.endTime}')
                            },
        </c:if>
    </c:forEach>
                            ];
                            // 2. Chức năng tự điền nhanh (Quick Fill)
                            document.getElementById('quickDateTime').addEventListener('change', function() {
                            const val = this.value; // Format: YYYY-MM-DDTHH:MM
                            if (val) {
                            const parts = val.split('T');
                            document.getElementById('showDate').value = parts[0];
                            document.getElementById('startTime').value = parts[1];
                            }
                            });
                            // 3. Hàm tính toán và Dự đoán giờ kết thúc / Giá vé
                            function predictEndTime() {
                            const movieSelect = document.getElementById('movieSelect');
                            const roomSelect = document.getElementById('roomSelect');
                            const showDate = document.getElementById('showDate').value;
                            const startTime = document.getElementById('startTime').value;
                            let moviePrice = 0, roomPrice = 0, duration = 0;
                            if (movieSelect.selectedIndex > 0) {
                            const mOption = movieSelect.options[movieSelect.selectedIndex];
                            moviePrice = parseInt(mOption.getAttribute('data-price')) || 0;
                            duration = parseInt(mOption.getAttribute('data-duration')) || 0;
                            }
                            if (roomSelect.selectedIndex > 0) {
                            const rOption = roomSelect.options[roomSelect.selectedIndex];
                            roomPrice = parseInt(rOption.getAttribute('data-price')) || 0;
                            }

                            const totalPrice = moviePrice + roomPrice;
                            document.getElementById('displayTotalPrice').innerText = new Intl.NumberFormat('vi-VN').format(totalPrice) + ' ₫';
                            if (showDate && startTime && duration > 0) {
                            const startDateObj = new Date(showDate + 'T' + startTime);
                            startDateObj.setMinutes(startDateObj.getMinutes() + duration + 15);
                            const endHH = String(startDateObj.getHours()).padStart(2, '0');
                            const endMM = String(startDateObj.getMinutes()).padStart(2, '0');
                            const endDD = String(startDateObj.getDate()).padStart(2, '0');
                            const endMonth = String(startDateObj.getMonth() + 1).padStart(2, '0');
                            const endYYYY = startDateObj.getFullYear();
                            document.getElementById('endTimeDisplay').value = endHH + ':' + endMM + ' - ' + endDD + '/' + endMonth + '/' + endYYYY;
                            document.getElementById('hiddenEndTime').value = endYYYY + '-' + endMonth + '-' + endDD + 'T' + endHH + ':' + endMM;
                            } else {
                            triggerPremiumToast('error', 'Lỗi thao tác', 'Vui lòng chọn Phim, Ngày chiếu và Giờ bắt đầu để tính toán dự đoán!');
                            }
                            }
                            // 4. Hàm Đặt lại (Reset)
                            function resetCalculations() {
                            document.getElementById('showtimeForm').reset();
                            document.getElementById('quickDateTime').value = '';
                            // Khôi phục giá trị ban đầu nếu đang ở mode edit
                            document.getElementById('endTimeDisplay').value = '${not empty fmtEndDisplay ? fmtEndDisplay : "Chưa có dữ liệu"}';
                            document.getElementById('hiddenEndTime').value = '${fmtEnd}';
                            // Reset giá
                            document.getElementById('displayTotalPrice').innerText = '0 ₫';
                            // Cố gắng tính lại giá nếu các dropdown đang có value sau khi reset form
                            setTimeout(() => { updateInitialPrice(); }, 100);
                            }
                            // ================= HÀM TẠO TOAST CAO CẤP =================
// Hàm hiển thị Toast thông báo thiết kế Premium biệt lập (Đã fix lỗi JSP EL)
                            function triggerPremiumToast(type, title, message) {
                            const container = document.getElementById('premium-toast-container');
                            if (!container) return;
                            const toast = document.createElement('div');
                            toast.className = 'toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ' +
                                    (type === 'success' ? 'bg-zinc-950/90 text-white toast-success-glow border-green-500/30' : 'bg-zinc-950/90 text-white toast-error-glow border-red-500/30');
                            let iconHtml = '', titleColorClass = '', barGradientClass = '', iconBgClass = '';
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

                            // Đã sửa thành phép cộng chuỗi để không bị máy chủ Java/JSP hiểu nhầm
                            toast.innerHTML =
                                    '<div class="flex-shrink-0 w-10 h-10 flex items-center justify-center rounded-full border ' + iconBgClass + '">' + iconHtml + '</div>' +
                                    '<div class="flex-1 pt-0.5">' +
                                    '<h4 class="text-sm font-bold ' + titleColorClass + ' tracking-wide uppercase mb-1">' + title + '</h4>' +
                                    '<p class="text-xs text-gray-300 leading-relaxed">' + message + '</p>' +
                                    '</div>' +
                                    '<button type="button" onclick="dismissTargetToast(this.closest(\'.toast-item\'))" class="flex-shrink-0 text-gray-500 hover:text-white transition-colors p-1">' +
                                    '<i class="fas fa-times text-sm"></i>' +
                                    '</button>' +
                                    '<div class="absolute bottom-0 left-0 h-1 bg-gradient-to-r ' + barGradientClass + ' toast-progress-countdown"></div>';
                            container.appendChild(toast);
                            const timerId = setTimeout(() => { dismissTargetToast(toast); }, 5000);
                            toast.dataset.timerId = timerId;
                            }
                            function dismissTargetToast(toast) {
                            if (!toast || toast.classList.contains('toast-leave-active')) return;
                            if (toast.dataset.timerId) clearTimeout(parseInt(toast.dataset.timerId));
                            toast.classList.add('toast-leave-active');
                            setTimeout(() => { toast.remove(); }, 400);
                            }

// BẮT LỖI TỪ BACKEND VÀ HIỂN THỊ LÊN TOAST KHI TẢI TRANG
                            window.addEventListener('DOMContentLoaded', () => {
                            const errorBridge = document.getElementById('backend-error-bridge');
                            const successBridge = document.getElementById('backend-success-bridge');
                            if (errorBridge && errorBridge.value.trim() !== "") {
                            triggerPremiumToast('error', 'Hệ thống', errorBridge.value.trim());
                            }
                            if (successBridge && successBridge.value.trim() !== "") {
                            triggerPremiumToast('success', 'Thành công', successBridge.value.trim());
                            }
                            });
                            function updateInitialPrice() {
                            const movieSelect = document.getElementById('movieSelect');
                            const roomSelect = document.getElementById('roomSelect');
                            let p1 = 0, p2 = 0;
                            if (movieSelect.selectedIndex > 0) p1 = parseInt(movieSelect.options[movieSelect.selectedIndex].getAttribute('data-price')) || 0;
                            if (roomSelect.selectedIndex > 0) p2 = parseInt(roomSelect.options[roomSelect.selectedIndex].getAttribute('data-price')) || 0;
                            if (p1 + p2 > 0) {
                            document.getElementById('displayTotalPrice').innerText = new Intl.NumberFormat('vi-VN').format(p1 + p2) + ' ₫';
                            }
                            }

                            // Tự động hiện giá vé khi vừa tải trang xong (nếu là trang edit)
                            window.onload = function() { updateInitialPrice(); }
                            document.getElementById('movieSelect').addEventListener('change', updateInitialPrice);
                            document.getElementById('roomSelect').addEventListener('change', updateInitialPrice);
                            // 5. Hàm Kiểm tra dữ liệu Form trước khi Submit (Thêm ràng buộc Quá khứ & Trùng lặp)
                            function validateForm() {
                            const showDate = document.getElementById('showDate').value;
                            const startTime = document.getElementById('startTime').value;
                            const roomId = document.getElementById('roomSelect').value;
                            const movieId = document.getElementById('movieSelect').value;
                            if (!showDate || !startTime || !roomId || !movieId) {
                            triggerPremiumToast('error', 'Lỗi nhập liệu', 'Vui lòng điền đầy đủ các thông tin bắt buộc (Phim, Phòng, Ngày giờ)!');
                            return false;
                            }

                            predictEndTime();
                            const hiddenEndTimeVal = document.getElementById('hiddenEndTime').value;
                            const newStart = new Date(showDate + 'T' + startTime);
                            const newEnd = new Date(hiddenEndTimeVal);
                            const now = new Date();
                            if (newStart < now) {
                            triggerPremiumToast('error', 'Lỗi thời gian', 'Bạn không thể lên lịch suất chiếu vào một khoảng thời gian trong quá khứ.');
                            return false;
                            }

                            for (let i = 0; i < existingShowtimes.length; i++) {
                            let ex = existingShowtimes[i];
                            if (ex.roomId === roomId) {
                            if (newStart < ex.end && newEnd > ex.start) {
                            const exStartFormat = ('0' + ex.start.getHours()).slice( - 2) + ':' + ('0' + ex.start.getMinutes()).slice( - 2);
                            const exEndFormat = ('0' + ex.end.getHours()).slice( - 2) + ':' + ('0' + ex.end.getMinutes()).slice( - 2);
                            triggerPremiumToast('error', 'Trùng lặp suất chiếu', `Suất chiếu bạn sắp thêm bị trùng thời gian với một suất chiếu khác (từ ${exStartFormat} đến ${exEndFormat}) đang tồn tại trong phòng này.`);
                            return false;
                            }
                            }
                            }

                            return true;
                            }
                            // =========================================================================
                            // HỆ THỐNG HIỂN THỊ THÔNG TIN VÉ (MODAL & AJAX)
                            // =========================================================================
                            const ticketModal = document.getElementById('ticketModal');
                            const modalContent = document.getElementById('modalContent');
                            const modalLoader = document.getElementById('modalLoader');
                            function openTicketModal(showtimeId, seatId, seatName) {
                            const clickedSeatElement = document.querySelector(`[data-seat-id="${seatId}"]`);
                            const isAlreadyHighlighted = clickedSeatElement && clickedSeatElement.classList.contains('ring-yellow-400');
                            // 2. NẾU BẤM VÀO GHẾ "LẠ" (CHƯA CÓ VIỀN VÀNG) -> XÓA HẾT VIỀN CŨ ĐI
                            if (!isAlreadyHighlighted) {
                            const oldHighlightedSeats = document.querySelectorAll('.ring-yellow-400, .ring-red-500');
                            oldHighlightedSeats.forEach(seat => {
                            seat.classList.remove('ring-2', 'ring-yellow-400', 'ring-4', 'ring-red-500', 'animate-pulse');
                            });
                            }
                            // Mở Modal và reset trạng thái
                            ticketModal.classList.remove('hidden');
                            setTimeout(() => {
                            ticketModal.classList.remove('opacity-0');
                            ticketModal.querySelector('.scale-95').classList.remove('scale-95');
                            ticketModal.querySelector('.scale-95')?.classList.add('scale-100');
                            }, 10);
                            document.getElementById('mdSeatName').innerText = seatName;
                            modalContent.classList.add('hidden');
                            modalLoader.classList.remove('hidden');
                            // Gọi AJAX lấy dữ liệu
                            fetch(`${pageContext.request.contextPath}/admin/showtimes/api/ticket-info?showtimeId=` + showtimeId + `&seatId=` + seatId)
                                    .then(response => {
                                    if (!response.ok) throw new Error("HTTP error " + response.status);
                                    return response.json();
                                    })
                                    .then(data => {
                                    // Kiểm tra nếu API báo lỗi nội bộ
                                    if (data.error) {
                                    throw new Error(data.error);
                                    }

                                    // Đổ dữ liệu vào Modal (Đã tương thích với dữ liệu có thể null)
                                    document.getElementById('mdBookingId').innerText = data.id_Booking ? "#" + data.id_Booking : "#TRỐNG";
                                    document.getElementById('mdCusName').innerText = data.fullName;
                                    document.getElementById('mdCusContact').innerText = data.phone + " | " + data.email;
                                    // Format ngày (nếu có ngày)
                                    if (data.bookingDate && data.bookingDate.trim() !== "") {
                                    const bDate = new Date(data.bookingDate);
                                    const formatDate = ("0" + bDate.getDate()).slice( - 2) + "/" + ("0" + (bDate.getMonth() + 1)).slice( - 2) + "/" + bDate.getFullYear() + " " + ("0" + bDate.getHours()).slice( - 2) + ":" + ("0" + bDate.getMinutes()).slice( - 2);
                                    document.getElementById('mdBookingDate').innerText = formatDate;
                                    } else {
                                    document.getElementById('mdBookingDate').innerText = "Chưa có thông tin";
                                    }

                                    document.getElementById('mdPaymentMethod').innerText = data.paymentMethod;
                                    document.getElementById('mdTicketPrice').innerText = new Intl.NumberFormat('vi-VN').format(data.ticketPrice) + ' ₫';
                                    // Gắn link chuyển hướng (Nếu id_User null, ẩn nút đi)
                                    const cusLink = document.getElementById('mdCusLink');
                                    if (data.id_User) {
                                    cusLink.style.display = 'block';
                                    cusLink.href = `${pageContext.request.contextPath}/admin/customers/detail/` + data.id_User;
                                    } else {
                                    cusLink.style.display = 'none';
                                    }

                                    // Tắt Loader, hiện Content
                                    modalLoader.classList.add('hidden');
                                    modalContent.classList.remove('hidden');
                                    })
                                    .catch(error => {
                                    // In chi tiết lỗi ra màn hình để biết nếu vẫn còn hỏng
                                    modalLoader.innerHTML = `<i class="fas fa-exclamation-triangle text-red-500 text-4xl mb-3"></i><p class="text-red-400 font-bold text-center text-sm">Lỗi dữ liệu: Khách vãng lai mua tại quầy không lưu thông tin hoặc ` + error.message + `</p>`;
                                    });
                            }

                            function closeTicketModal() {
                            ticketModal.classList.add('opacity-0');
                            ticketModal.querySelector('.scale-100')?.classList.add('scale-95');
                            ticketModal.querySelector('.scale-100')?.classList.remove('scale-100');
                            setTimeout(() => {
                            ticketModal.classList.add('hidden');
                            }, 300);
                            }
                            document.addEventListener("DOMContentLoaded", function() {
                            const originalSelect = document.getElementById('movieSelect');
                            const displayBox = document.getElementById('movieSelectDisplay');
                            const dropdownList = document.getElementById('movieDropdownList');
                            const optionsUl = document.getElementById('movieOptionsUl');
                            const searchInput = document.getElementById('movieSearchInput');
                            const noResult = document.getElementById('movieNoResult');
                            const selectedText = document.getElementById('selectedMovieText');
                            const icon = document.getElementById('movieSelectIcon');
                            let isDropdownOpen = false;
                            if (!originalSelect || !displayBox) return; // Bảo vệ tránh lỗi Javascript nếu bị thiếu HTML

                            // 1. Tải TOÀN BỘ PHIM mặc định vào danh sách cuộn
                            // 1. Tải TOÀN BỘ PHIM mặc định vào danh sách cuộn
                            // 1. Tải TOÀN BỘ PHIM mặc định vào danh sách cuộn
                            // 1. Tải TOÀN BỘ PHIM mặc định vào danh sách cuộn
                            // 1. Tải TOÀN BỘ PHIM mặc định vào danh sách cuộn (Phương pháp Văn bản Thuần)
                            function populateOptions() {
                            optionsUl.innerHTML = '';
                            Array.from(originalSelect.options).forEach((option) => {
                            if (option.value === "") return;
                            const li = document.createElement('li');
                            // Ép class chữ trắng tiêu chuẩn của Tailwind và thiết lập layout flex rõ ràng
                            li.className = 'px-5 py-3 cursor-pointer text-white hover:text-red-400 text-base font-medium flex items-center gap-3 border-b border-gray-700/40 w-full select-none';
                            // Ép cứng bằng JS style để chữ luôn mang màu trắng sáng rõ ràng trên nền tối
                            li.style.color = '#ffffff';
                            li.dataset.value = option.value;
                            li.dataset.text = option.text.toLowerCase(); // Lưu lại Text thường để so khớp cho tính năng lọc

                            // Tạo thẻ i làm Icon Check/Khoảng trống phía trước
                            const iconEl = document.createElement('i');
                            if (option.selected) {
                            iconEl.className = 'fas fa-check text-red-500 w-4';
                            li.style.backgroundColor = 'rgba(239, 68, 68, 0.15)';
                            li.style.color = '#ef4444'; // Chữ đỏ nếu đang chọn
                            } else {
                            iconEl.className = 'w-4';
                            li.style.backgroundColor = 'transparent';
                            }
                            li.appendChild(iconEl);
                            // PHƯƠNG PHÁP MỚI: Tạo một Text Node văn bản độc lập để chống bị ẩn chữ
                            const textNode = document.createTextNode(" " + option.text);
                            li.appendChild(textNode);
                            // Giữ nguyên hiệu ứng Hover di chuột mượt mà của hệ thống
                            li.addEventListener('mouseenter', () => {
                            if (originalSelect.value !== option.value) {
                            li.style.backgroundColor = 'rgba(239, 68, 68, 0.2)';
                            li.style.color = '#f87171'; // Chữ sáng hồng lên khi hover
                            }
                            });
                            li.addEventListener('mouseleave', () => {
                            if (originalSelect.value !== option.value) {
                            li.style.backgroundColor = 'transparent';
                            li.style.color = '#ffffff'; // Về lại màu trắng khi rời chuột
                            }
                            });
                            li.addEventListener('click', () => {
                            originalSelect.value = option.value;
                            selectedText.innerHTML = option.text;
                            optionsUl.querySelectorAll('li').forEach(el => {
                            el.style.backgroundColor = 'transparent';
                            el.style.color = '#ffffff';
                            const isElSelected = originalSelect.value === el.dataset.value;
                            const elIcon = el.querySelector('i');
                            if (elIcon) {
                            if (isElSelected) {
                            elIcon.className = 'fas fa-check text-red-500 w-4';
                            el.style.backgroundColor = 'rgba(239, 68, 68, 0.15)';
                            el.style.color = '#ef4444';
                            } else {
                            elIcon.className = 'w-4';
                            }
                            }
                            });
                            li.style.backgroundColor = 'rgba(239, 68, 68, 0.15)';
                            li.style.color = '#ef4444';
                            const liIcon = li.querySelector('i');
                            if (liIcon) liIcon.className = 'fas fa-check text-red-500 w-4';
                            originalSelect.dispatchEvent(new Event('change'));
                            closeDropdown();
                            });
                            optionsUl.appendChild(li);
                            });
                            }

                            function toggleDropdown(e) {
                            e.stopPropagation();
                            isDropdownOpen = !isDropdownOpen;
                            if (isDropdownOpen) {
                            dropdownList.classList.remove('hidden');
                            setTimeout(() => {
                            dropdownList.classList.remove('opacity-0', 'scale-95');
                            icon.classList.add('rotate-180');
                            }, 10);
                            searchInput.value = '';
                            filterList('');
                            searchInput.focus();
                            } else {
                            closeDropdown();
                            }
                            }

                            function closeDropdown() {
                            isDropdownOpen = false;
                            dropdownList.classList.add('opacity-0', 'scale-95');
                            icon.classList.remove('rotate-180');
                            setTimeout(() => { dropdownList.classList.add('hidden'); }, 200);
                            }

                            function filterList(keyword) {
                            keyword = keyword.toLowerCase().trim();
                            let hasVisible = false;
                            optionsUl.querySelectorAll('li').forEach(li => {
                            if (li.dataset.text.includes(keyword)) {
                            li.style.display = 'flex';
                            hasVisible = true;
                            } else {
                            li.style.display = 'none';
                            }
                            });
                            if (hasVisible) {
                            noResult.classList.add('hidden');
                            optionsUl.classList.remove('hidden');
                            } else {
                            noResult.classList.remove('hidden');
                            optionsUl.classList.add('hidden');
                            }
                            }

                            populateOptions();
                            displayBox.addEventListener('click', toggleDropdown);
                            dropdownList.addEventListener('click', (e) => e.stopPropagation());
                            searchInput.addEventListener('input', (e) => filterList(e.target.value));
                            document.addEventListener('click', (e) => {
                            const container = document.getElementById('customMovieSelectContainer');
                            if (isDropdownOpen && container && !container.contains(e.target)) {
                            closeDropdown();
                            }
                            });
                            });</script>
<script>
    // Logic tự động focus vào ghế từ trang Lịch sử Khách hàng
    window.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    // Hỗ trợ nhận nhiều ghế cùng lúc, phân cách bằng dấu phẩy, VD: ?autoSelectSeat=12,13,14
    const autoSelectSeatParam = urlParams.get('autoSelectSeat');
    if (autoSelectSeatParam) {
    // Tách các ID ghế thành mảng
    const seatIds = autoSelectSeatParam.split(',');
    // Dùng setInterval để kiểm tra liên tục (mỗi 0.5s) xem Sơ đồ ghế đã load xong chưa
    let attempts = 0;
    const checkExist = setInterval(function() {
    attempts++;
    const firstSeatDom = document.querySelector('[data-seat-id="' + seatIds[0] + '"]');
    // Nếu tìm thấy ghế đầu tiên tức là sơ đồ đã render xong
    if (firstSeatDom) {
    clearInterval(checkExist); // Dừng vòng lặp kiểm tra

    // 1. Cuộn màn hình mượt mà xuống chỗ sơ đồ ghế
    firstSeatDom.scrollIntoView({ behavior: 'smooth', block: 'center' });
    // 2. Tự động bật Modal cho ghế đầu tiên
    firstSeatDom.click();
    // 3. Duyệt qua TẤT CẢ các ghế khách đã mua trong mảng để tô màu
    seatIds.forEach(id => {
    const seatElement = document.querySelector('[data-seat-id="' + id + '"]');
    if (seatElement) {
    // Thêm hiệu ứng nhấp nháy 
    seatElement.classList.add('ring-4', 'ring-red-500', 'animate-pulse');
    // Sau 3 giây tắt nhấp nháy, nhưng đổi sang viền vàng cố định để admin dễ theo dõi lâu dài
    setTimeout(() => {
    seatElement.classList.remove('ring-4', 'ring-red-500', 'animate-pulse');
    seatElement.classList.add('ring-2', 'ring-yellow-400');
    }, 3000);
    }
    });
    }

    // Tránh treo trình duyệt: Nếu sau 10 lần (5 giây) vẫn không thấy ghế thì bỏ cuộc
    if (attempts >= 10) {
    clearInterval(checkExist);
    console.log("Không tìm thấy sơ đồ ghế nào sau 5 giây.");
    }
    }, 500);
    }
    });
</script>