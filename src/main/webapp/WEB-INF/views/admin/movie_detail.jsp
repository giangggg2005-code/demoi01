<%-- views/admin/movie_detail.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .detail-bg-blur {
        background-image: url('${movie.posterUrl}');
        background-size: 100% auto; 
        background-position: center center; 
        background-repeat: no-repeat;
        filter: blur(0px) brightness(0.65) contrast(1.15); 
        
        position: absolute;
        top: 0; right: 0;
        width: 80%; 
        height: 100%; 
        z-index: 0;
    }
    .bg-gradient-overlay {
        position: absolute;
        top: 0; right: 0;
        width: 80%; 
        height: 100%;
        background: 
            linear-gradient(90deg, #0a0b0d 0%, rgba(10, 11, 13, 0.9) 15%, transparent 50%),
            linear-gradient(0deg, #0a0b0d 0%, rgba(10, 11, 13, 0.8) 15%, transparent 50%);
        z-index: 1;
        pointer-events: none;
    }
    
    .custom-scrollbar::-webkit-scrollbar {
        width: 5px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.3);
        border-radius: 10px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: linear-gradient(to bottom, #ef4444, #f59e0b); 
        border-radius: 10px;
    }
    
    .glass-panel {
        background: rgba(15, 16, 20, 0.45);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-left: 3px solid rgba(239, 68, 68, 0.8); 
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
        transition: all 0.3s ease;
    }
    .glass-panel:hover {
        background: rgba(20, 22, 28, 0.7);
        border-color: rgba(239, 68, 68, 0.3);
        border-left: 3px solid #f59e0b; 
        box-shadow: 0 10px 40px 0 rgba(239, 68, 68, 0.2);
        transform: translateY(-4px);
    }
</style>

<div class="relative min-h-screen p-3 md:p-6 rounded-2xl overflow-hidden bg-[#0a0b0d]">
    <%-- Lớp nền hiển thị --%>
    <div class="detail-bg-blur"></div>
    
    <%-- Lớp Gradient Overlay --%>
    <div class="bg-gradient-overlay"></div>

    <%-- Sửa max-w-7xl mx-auto thành w-full px-4 lg:px-8 để nội dung tràn sát 2 rìa --%>
    <div class="relative z-10 w-full px-4 lg:px-8">
        
        <%-- THANH TIÊU ĐỀ TRÊN ĐẦU (Nút Trở về tự động sát rìa phải do justify-between và w-full) --%>
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-10">
            <div>
                <h2 class="text-3xl font-black text-white uppercase tracking-widest flex items-center gap-2 drop-shadow-2xl">
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-red-500 via-red-400 to-amber-500" style="filter: drop-shadow(0 0 10px rgba(239,68,68,0.5));">
                        ${movie.title}
                    </span>
                </h2>
                <p class="text-xs text-gray-300 mt-1.5 font-medium tracking-widest uppercase">Hồ sơ Điện ảnh Kỹ thuật số Starlight</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/admin/movies" class="glass-panel text-white px-6 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 flex items-center group overflow-hidden relative">
                    <div class="absolute inset-0 bg-gradient-to-r from-red-600 to-red-800 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                    <i class="fas fa-arrow-left mr-2 transition-transform group-hover:-translate-x-1 relative z-10"></i> 
                    <span class="relative z-10">Trở về danh sách</span>
                </a>
            </div>
        </div>

        <%-- KHU VỰC HIỂN THỊ NỘI DUNG --%>
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 items-start relative z-10">
            
            <%-- CỘT TRÁI: POSTER PHIM & GIÁ VÉ (Sửa items-end thành items-start để Poster sát rìa trái) --%>
            <div class="lg:col-span-3 flex flex-col items-center lg:items-start">
                
                <%-- Khung chứa Poster có viền sáng và Hào quang --%>
                <div onclick="openTrailerModal('${movie.trailerUrl}')" class="relative group w-full max-w-[320px] aspect-[2/3] rounded-2xl overflow-hidden border border-gray-600/50 shadow-[0_0_40px_rgba(239,68,68,0.25)] bg-black cursor-pointer ring-1 ring-white/10 transition-all duration-500 hover:shadow-[0_0_60px_rgba(239,68,68,0.6)] hover:-translate-y-2">
                    
                    <img src="${movie.posterUrl}" alt="${movie.title}" class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105">
                    
                    <div class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent opacity-50 group-hover:opacity-80 transition-opacity duration-300"></div>
                    
                    <%-- Nút Play đập nhịp đằng sau và nút tĩnh đằng trước --%>
                    <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                        <span class="absolute inline-flex h-full w-full rounded-full bg-red-500 opacity-30 group-hover:animate-ping"></span>
                        <button type="button" class="relative bg-gradient-to-br from-red-500 to-red-700 text-white w-16 h-16 rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(239,68,68,0.8)] border border-red-400/50 pointer-events-none transition-transform duration-300 group-hover:scale-110">
                            <i class="fas fa-play text-xl ml-1 drop-shadow-md"></i>
                        </button>
                    </div>
                    
                    <div class="absolute bottom-5 left-0 right-0 text-center z-10 pointer-events-none transform group-hover:-translate-y-1 transition-transform duration-300">
                        <span class="bg-black/60 border border-gray-500/50 text-white text-[10px] uppercase font-black tracking-widest px-4 py-2 rounded-full backdrop-blur-md group-hover:border-red-500 group-hover:text-red-400 transition-colors shadow-lg">
                            <i class="fab fa-youtube text-red-500 mr-1.5 animate-pulse"></i>Khám phá Trailer
                        </span>
                    </div>
                </div>
                
                <%-- Khối giá vé nhanh --%>
                <div class="w-full max-w-[320px] mt-6 space-y-3 relative z-20">
                    <div class="glass-panel rounded-xl p-4 text-center">
                        <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider block mb-1">Giá vé cơ sở (Tham chiếu)</span>
                        <span class="text-transparent bg-clip-text bg-gradient-to-r from-amber-400 to-yellow-500 font-black text-2xl" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.5));">
                            <fmt:formatNumber value="${movie.basePrice}" pattern="#,###" /> <span class="text-xs text-amber-500">VND</span>
                        </span>
                    </div>
                    
                    <div class="text-center transform transition duration-300 hover:scale-[1.02]">
                        <c:choose>
                            <c:when test="${movie.status == 'Showing'}">
                                <span class="w-full flex justify-center items-center bg-emerald-500/10 border border-emerald-500/40 text-emerald-400 font-black px-4 py-3.5 rounded-xl text-xs uppercase tracking-widest backdrop-blur-md shadow-[0_0_20px_rgba(16,185,129,0.15)]">
                                    <span class="w-2 h-2 rounded-full bg-emerald-400 animate-ping mr-2"></span> Đang Trình Chiếu
                                </span>
                            </c:when>
                            <c:when test="${movie.status == 'Coming Soon'}">
                                <span class="w-full flex justify-center items-center bg-amber-500/10 border border-amber-500/40 text-amber-400 font-black px-4 py-3.5 rounded-xl text-xs uppercase tracking-widest backdrop-blur-md shadow-[0_0_20px_rgba(245,158,11,0.15)]">
                                    <i class="fas fa-clock mr-2 animate-pulse"></i> Sắp Trình Chiếu
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="w-full flex justify-center items-center bg-gray-500/10 border border-gray-600/50 text-gray-300 font-black px-4 py-3.5 rounded-xl text-xs uppercase tracking-widest backdrop-blur-md">
                                    <i class="fas fa-archive mr-2"></i> Đã Ngưng Chiếu
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="lg:col-span-9 flex flex-col space-y-8 relative z-20">
                
                <%-- Khối tóm tắt phim --%>
                <div class="glass-panel p-6 md:p-7 rounded-2xl relative overflow-hidden border-t-4 border-t-red-500">
                    
                    <div class="border-b border-gray-700/50 pb-4 mb-4">
                        <span class="text-[10px] font-black text-red-500 uppercase tracking-widest block drop-shadow-md mb-1">Tên tác phẩm</span>
                        <h1 class="text-3xl md:text-4xl font-black text-white tracking-wide drop-shadow-lg">${movie.title}</h1>
                    </div>

                    <div>
                        <span class="text-[11px] font-bold text-gray-400 uppercase tracking-wider block mb-2"><i class="fas fa-align-left text-red-500 w-4"></i> Mô tả phim (Synopsis)</span>
                        <div class="text-gray-200 text-[13px] leading-loose max-h-[160px] overflow-y-auto custom-scrollbar pr-3 text-justify font-medium">
                            ${not empty movie.description ? movie.description : 'Chưa có thông tin mô tả chi tiết cho bộ phim này.'}
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                    
                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-red-500/10 border border-red-500/20 flex items-center justify-center text-red-500 shadow-[0_0_10px_rgba(239,68,68,0.2)] flex-shrink-0"><i class="fas fa-clapperboard"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Đạo diễn</span>
                            <span class="text-white font-bold text-sm truncate block">${movie.director}</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 shadow-[0_0_10px_rgba(245,158,11,0.2)] flex-shrink-0"><i class="fas fa-hourglass-half"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Thời lượng</span>
                            <span class="text-white font-bold text-sm truncate block">${movie.duration} phút</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 shadow-[0_0_10px_rgba(59,130,246,0.2)] flex-shrink-0"><i class="fas fa-masks-theater"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Thể loại</span>
                            <span class="text-white font-bold text-sm truncate block">${movie.genre}</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 shadow-[0_0_10px_rgba(16,185,129,0.2)] flex-shrink-0"><i class="fas fa-language text-lg"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Ngôn ngữ gốc</span>
                            <span class="text-white font-bold text-sm truncate block">${movie.language}</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 shadow-[0_0_10px_rgba(168,85,247,0.2)] flex-shrink-0"><i class="fas fa-film"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Định dạng</span>
                            <span class="text-white font-bold text-sm truncate block">${movie.category}</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default">
                        <div class="w-10 h-10 rounded-full bg-red-600/20 border border-red-500/30 flex items-center justify-center text-white font-black shadow-[0_0_10px_rgba(220,38,38,0.3)] flex-shrink-0 text-xs">${movie.censorship}</div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Kiểm duyệt</span>
                            <span class="text-white font-bold text-sm truncate block">Giới hạn độ tuổi</span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default sm:col-span-2 lg:col-span-1 border-t-2 border-t-indigo-500/30">
                        <div class="w-10 h-10 rounded-full bg-indigo-500/10 border border-indigo-500/20 flex items-center justify-center text-indigo-400 shadow-[0_0_10px_rgba(99,102,241,0.2)] flex-shrink-0"><i class="far fa-calendar-check"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Ngày phát hành</span>
                            <span class="text-white font-bold text-sm truncate block">
                                <fmt:formatDate value="${movie.releaseDate}" pattern="dd/MM/yyyy" />
                            </span>
                        </div>
                    </div>

                    <div class="glass-panel rounded-xl p-4 flex items-center gap-3 cursor-default sm:col-span-2 lg:col-span-2 border-t-2 border-t-teal-500/30">
                        <div class="w-10 h-10 rounded-full bg-teal-500/10 border border-teal-500/20 flex items-center justify-center text-teal-400 shadow-[0_0_10px_rgba(20,184,166,0.2)] flex-shrink-0"><i class="fas fa-users"></i></div> 
                        <div class="overflow-hidden">
                            <span class="text-[9px] font-bold text-gray-400 uppercase tracking-wider block">Dàn diễn viên (Cast)</span>
                            <span class="text-white font-bold text-sm truncate block" title="${movie.cast}">${movie.cast}</span>
                        </div>
                    </div>
                </div>

                <%-- KHO TÀI NGUYÊN --%>
                <div class="glass-panel p-5 rounded-2xl">
                    <span class="text-[11px] font-bold text-gray-400 uppercase tracking-wider block mb-3"><i class="fas fa-link text-gray-500 w-4"></i> Liên kết hệ thống</span>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs">
                        <div class="flex items-center gap-2.5 bg-black/40 hover:bg-black/60 px-4 py-3 rounded-xl border border-gray-700/50 text-gray-400 truncate transition-colors">
                            <i class="fas fa-image text-blue-400 flex-shrink-0 text-sm"></i>
                            <span class="font-bold text-[10px] uppercase text-gray-500">Poster:</span>
                            <a href="${movie.posterUrl}" target="_blank" class="text-blue-400 hover:text-blue-300 hover:underline truncate">${movie.posterUrl}</a>
                        </div>
                        <div class="flex items-center gap-2.5 bg-black/40 hover:bg-black/60 px-4 py-3 rounded-xl border border-gray-700/50 text-gray-400 truncate transition-colors">
                            <i class="fab fa-youtube text-red-500 flex-shrink-0 text-sm"></i>
                            <span class="font-bold text-[10px] uppercase text-gray-500">Trailer:</span>
                            <a href="${movie.trailerUrl}" target="_blank" class="text-red-400 hover:text-red-300 hover:underline truncate">${movie.trailerUrl}</a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<%-- KHU VỰC HIỂN THỊ MODAL TRAILER --%>
<div id="trailer-modal" class="fixed inset-0 z-[999] hidden flex items-center justify-center p-4 bg-black/90 backdrop-blur-md transition-all duration-300">
    <div class="absolute inset-0 cursor-pointer" onclick="closeTrailerModal()"></div>
    
    <div class="relative w-full max-w-5xl aspect-video bg-black border border-gray-800 rounded-2xl overflow-hidden shadow-[0_0_80px_rgba(239,68,68,0.3)] z-10 animate-scaleUp ring-1 ring-white/10">
        <div class="absolute top-4 right-4 z-50">
            <button onclick="closeTrailerModal()" class="w-10 h-10 rounded-full bg-black/50 hover:bg-red-600 text-white flex items-center justify-center border border-white/20 hover:border-transparent hover:rotate-90 transition-all duration-300 shadow-xl backdrop-blur-sm">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>
        
        <div class="w-full h-full">
            <iframe id="trailer-iframe" class="w-full h-full" src="" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
        </div>
    </div>
</div>

<script>
    function getYoutubeEmbedUrl(url) {
        if (!url) return '';
        let videoId = '';
        try {
            if (url.includes('youtube.com/watch')) {
                const urlParams = new URLSearchParams(new URL(url).search);
                videoId = urlParams.get('v');
            } else if (url.includes('youtu.be/')) {
                videoId = url.split('youtu.be/')[1].split('?')[0];
            } else if (url.includes('youtube.com/embed/')) {
                return url;
            }
        } catch (e) {
            console.error("Lỗi phân tích URL:", e);
        }
        return videoId ? 'https://www.youtube.com/embed/' + videoId + '?autoplay=1&rel=0' : url;
    }

    function openTrailerModal(trailerUrl) {
        const modal = document.getElementById('trailer-modal');
        const iframe = document.getElementById('trailer-iframe');
        if (modal && iframe) {
            const embedUrl = getYoutubeEmbedUrl(trailerUrl);
            iframe.src = embedUrl;
            modal.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }
    }

    function closeTrailerModal() {
        const modal = document.getElementById('trailer-modal');
        const iframe = document.getElementById('trailer-iframe');
        if (modal && iframe) {
            iframe.src = '';
            modal.classList.add('hidden');
            document.body.style.overflow = '';
        }
    }
    
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeTrailerModal();
        }
    });
</script>