<%-- views/admin/movie_add_edit.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  
    .form-bg-blur {
        background-size: 80% auto; 
        background-position: right top; 
        background-repeat: no-repeat;
        filter: blur(0px) brightness(0.4) contrast(1.15); 
        position: absolute;
        top: 0; right: 0; width: 75%; height: 100%; z-index: 0;
        transition: background-image 0.5s ease-in-out;
    }
    .form-gradient-overlay {
        position: absolute; top: 0; right: 0; width: 75%; height: 100%;
        background: linear-gradient(90deg, #0a0b0d 0%, rgba(10, 11, 13, 0.95) 20%, transparent 60%),
                    linear-gradient(0deg, #0a0b0d 0%, rgba(10, 11, 13, 0.9) 20%, transparent 60%);
        z-index: 1; pointer-events: none;
    }
 
    .glass-input {
        background: rgba(0, 0, 0, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: white;
        transition: all 0.3s ease;
    }
    .glass-input:focus {
        background: rgba(20, 22, 28, 0.8);
        border-color: #ef4444;
        box-shadow: 0 0 15px rgba(239, 68, 68, 0.3);
        outline: none;
    }
</style>

<div id="movie-form-modal" class="fixed inset-0 z-[999] hidden flex items-center justify-center bg-[#0a0b0d] transition-all duration-300 animate-fadeIn overflow-hidden">
    
    <%-- LỚP NỀN LIVE PREVIEW TỰ ĐỘNG ĐỔI THEO LINK ẢNH --%>
    <div id="modal-bg-poster" class="form-bg-blur" style="background-image: url('https://cdn.galaxycine.vn/fanti.jpg');"></div>
    <div class="form-gradient-overlay"></div>

    <div class="relative w-full h-full max-w-7xl mx-auto flex flex-col p-4 md:p-6 overflow-hidden z-10">
        
        <%-- HEADER FORM --%>
        <div class="flex items-center justify-between gap-4 mb-6 shrink-0">
            <div>
                <h2 class="text-3xl font-black text-white uppercase tracking-widest flex items-center gap-2 drop-shadow-2xl">
                    <span id="modal-title-text" class="text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-amber-500">
                        Thêm phim mới
                    </span>
                </h2>
                <p class="text-xs text-gray-400 mt-1.5 font-medium tracking-widest uppercase"><i class="fas fa-edit text-red-500 mr-1"></i> Không gian chỉnh sửa dữ liệu phim</p>
            </div>
            <button type="button" onclick="handleCancelOrBack()" class="w-10 h-10 rounded-full bg-red-600/20 text-red-500 hover:bg-red-600 hover:text-white flex items-center justify-center transition-all shadow-lg border border-red-500/30 hover:rotate-90">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>

        <%-- FORM NHẬP LIỆU (BỐ CỤC CHIA 2 CỘT GIỐNG HỆT DETAIL) --%>
        <form id="movie-core-form" action="${pageContext.request.contextPath}/admin/movies/save" method="POST" class="grid grid-cols-1 lg:grid-cols-12 gap-10 flex-1 overflow-y-auto custom-scrollbar pb-24 pr-2">
            <input type="hidden" id="form-movie-id" name="id_Movie" value="0">

            <%-- CỘT TRÁI: LIVE PREVIEW POSTER & PLAY TRAILER --%>
            <div class="lg:col-span-4 flex flex-col items-center lg:items-end space-y-6">
                
                <%-- Khung Poster y hệt trang xem chi tiết --%>
                <div class="relative group w-full max-w-[320px] aspect-[2/3] rounded-2xl overflow-hidden border border-gray-600/50 shadow-[0_0_40px_rgba(239,68,68,0.25)] bg-black ring-1 ring-white/10 transition-all duration-500 hover:shadow-[0_0_60px_rgba(239,68,68,0.6)]">
                    <%-- Ảnh Poster hiển thị trực tiếp --%>
                    <img id="live-poster-img" src="https://cdn.galaxycine.vn/fanti.jpg" alt="Preview" class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105">
                    
                    <div class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent opacity-60"></div>
                    
                    <%-- Nút Test Trailer --%>
                    <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 cursor-pointer" onclick="previewLiveTrailer()">
                        <span class="absolute inline-flex h-full w-full rounded-full bg-red-500 opacity-40 animate-ping"></span>
                        <button type="button" class="relative bg-gradient-to-br from-red-500 to-red-700 text-white w-16 h-16 rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(239,68,68,0.8)] border border-red-400/50 transition-transform duration-300 hover:scale-110">
                            <i class="fas fa-play text-xl ml-1"></i>
                        </button>
                    </div>
                    
                    <div class="absolute bottom-4 left-0 right-0 text-center z-10 pointer-events-none">
                        <span class="bg-black/80 border border-gray-500/50 text-white text-[10px] uppercase font-black tracking-widest px-4 py-2 rounded-full backdrop-blur-md">
                            <i class="fas fa-eye text-red-500 mr-1.5"></i> Live Preview
                        </span>
                    </div>
                </div>

                <%-- Vùng chứa cảnh báo lỗi ngay dưới poster --%>
                
                <%-- Lỗi từ Backend (Trạm 2 & 3) trả về --%>
                <c:if test="${not empty errorMessage}">
                    <div id="backend-error-box" class="w-full max-w-[320px] glass-panel border-l-4 border-l-red-500 text-red-400 p-4 rounded-xl text-xs font-semibold animate-shake mb-4 shadow-[0_0_15px_rgba(239,68,68,0.3)]">
                        <i class="fas fa-exclamation-triangle"></i> <span>${errorMessage}</span>
                    </div>
                </c:if>

                <%-- Lỗi từ Frontend (Trạm 1) - Mặc định ẩn --%>
                <div id="frontend-error-box" class="w-full max-w-[320px] hidden glass-panel border-l-4 border-l-red-500 text-red-400 p-4 rounded-xl text-xs font-semibold animate-shake shadow-[0_0_15px_rgba(239,68,68,0.3)]">
                    <i class="fas fa-exclamation-triangle"></i> <span id="frontend-error-msg"></span>
                </div>
            </div>

            <%-- CỘT PHẢI: CÁC Ô NHẬP LIỆU --%>
            <div class="lg:col-span-8 flex flex-col space-y-6">
                
                <%-- Nhóm thông tin cơ bản --%>
                <div class="glass-panel p-6 md:p-7 rounded-2xl relative overflow-hidden border-t-4 border-t-red-500">
                    <div class="border-b border-gray-700/50 pb-3 mb-4">
                        <span class="text-[10px] font-black text-red-500 uppercase tracking-widest block drop-shadow-md mb-1"><i class="fas fa-info-circle mr-1"></i> Thông tin cốt lõi</span>
                    </div>
                    <div class="space-y-4">
                        <div class="space-y-1.5">
                            <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wider">Tên phim <span class="text-red-500">*</span></label>
                            <input type="text" id="form-movie-title" name="title" required maxlength="150" placeholder="Nhập tên chính thức của tác phẩm..." class="w-full glass-input rounded-xl px-4 py-3 text-lg font-bold">
                        </div>
                        <div class="space-y-1.5">
                            <label class="text-[11px] font-bold text-gray-400 uppercase tracking-wider">Mô tả cốt truyện (Synopsis) <span class="text-red-500">*</span></label>
                            <textarea id="form-movie-description" name="description" required maxlength="1000" rows="3" placeholder="Viết tóm tắt nội dung thu hút khán giả..." class="w-full glass-input rounded-xl px-4 py-3 text-sm resize-none custom-scrollbar"></textarea>
                        </div>
                    </div>
                </div>

                <%-- Lưới nhập liệu chi tiết 1 --%>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="glass-panel rounded-xl p-4 space-y-2">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider"><i class="fas fa-link text-blue-400 w-4"></i> Link Ảnh Poster <span class="text-red-500">*</span></label>
                        <input type="url" id="form-movie-poster" name="posterUrl" required placeholder="Dán link ảnh (https://...)" class="w-full glass-input rounded-lg px-3 py-2 text-sm text-blue-400">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider"><i class="fab fa-youtube text-red-400 w-4"></i> Link Trailer <span class="text-red-500">*</span></label>
                        <input type="url" id="form-movie-trailer" name="trailerUrl" required placeholder="Dán link Youtube..." class="w-full glass-input rounded-lg px-3 py-2 text-sm text-red-400">
                    </div>
                </div>

                <%-- Lưới nhập liệu chi tiết 2 --%>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div class="glass-panel rounded-xl p-4 space-y-2">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider"><i class="fas fa-clapperboard text-gray-500 w-4"></i> Đạo diễn</label>
                        <input type="text" id="form-movie-director" name="director" required class="w-full glass-input rounded-lg px-3 py-2 text-sm">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider"><i class="fas fa-users text-gray-500 w-4"></i> Diễn viên</label>
                        <input type="text" id="form-movie-cast" name="cast" required placeholder="Cách nhau dấu phẩy" class="w-full glass-input rounded-lg px-3 py-2 text-sm">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider"><i class="fas fa-masks-theater text-gray-500 w-4"></i> Thể loại</label>
                        <select id="form-movie-genre" name="genre" required class="w-full glass-input rounded-lg px-3 py-2 text-sm cursor-pointer">
                            <option value="Hành động">Hành động</option>
                            <option value="Tâm lý">Tâm lý</option>
                            <option value="Gia đình">Gia đình</option>
                            <option value="Hài hước">Hài hước</option>
                            <option value="Kinh dị">Kinh dị</option>
                            <option value="Hoạt hình">Hoạt hình</option>
                            <option value="Viễn tưởng">Viễn tưởng</option>
                            <option value="Phiêu lưu">Phiêu lưu</option>
                            <option value="Cổ trang">Cổ trang</option>
                            <option value="Tình cảm">Tình cảm</option>
                            <option value="Nhạc kịch">Nhạc kịch</option>
                            <option value="Võ thuật">Võ thuật</option>
                        </select>
                    </div>
                </div>

                <%-- Lưới nhập liệu chi tiết 3 --%>
                <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-l-2 border-l-indigo-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Thời lượng (p)</label>
                        <input type="number" id="form-movie-duration" name="duration" required min="1" class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-l-2 border-l-indigo-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Ngôn ngữ</label>
                        <input type="text" id="form-movie-language" name="language" required value="Tiếng Việt" class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center">
                    </div>
                    
                    <%-- ========================================================================= --%>
                    <%-- THAY ĐỔI TẠI ĐÂY: CHUYỂN INPUT THÀNH SELECT DROPDOWN THEO ẢNH --%>
                    <%-- ========================================================================= --%>
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-l-2 border-l-indigo-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Định dạng</label>
                        <select id="form-movie-category" name="category" required class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center cursor-pointer">
                            <option value="Standard (Phòng Tiêu Chuẩn)">Standard (Phòng Tiêu Chuẩn)</option>
                            <option value="IMAX (Màn Hình Đại Vĩ Tuyến)">IMAX (Màn Hình Đại Vĩ Tuyến)</option>
                            <option value="4DX (Hiệu Ứng Đa Chiều)">4DX (Hiệu Ứng Đa Chiều)</option>
                            <option value="Sweetbox (Ghế Đôi Cặp Đôi)">Sweetbox (Ghế Đôi Cặp Đôi)</option>
                            <option value="VIP (Thượng Hạng)">VIP (Thượng Hạng)</option>
                        </select>
                    </div>
                    
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-l-2 border-l-indigo-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Kiểm duyệt</label>
                        <select id="form-movie-censorship" name="censorship" required class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center cursor-pointer">
                            <option value="P">P</option><option value="K">K</option><option value="T13">T13</option><option value="T16">T16</option><option value="T18">T18</option>
                        </select>
                    </div>
                </div>

                <%-- Lưới nhập liệu chi tiết 4 (Mốc thời gian và trạng thái) --%>
                <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-t-2 border-t-amber-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Năm sản xuất</label>
                        <input type="number" id="form-movie-prodyear" name="productionYear" required min="1900" class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-t-2 border-t-amber-500">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Ngày Khởi chiếu</label>
                        <input type="date" id="form-movie-releasedate" name="releaseDate" required class="w-full glass-input rounded-lg px-3 py-2 text-sm text-center">
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2 border-t-2 border-t-amber-500">
                        <label class="text-[10px] font-bold text-amber-500 uppercase tracking-wider">Trạng thái</label>
                        <select id="form-movie-status" name="status" required class="w-full glass-input rounded-lg px-3 py-2 text-sm font-bold cursor-pointer">
                            <option value="Coming Soon" class="text-amber-500">Sắp chiếu</option>
                            <option value="Showing" class="text-green-500">Đang chiếu</option>
                            <option value="Closed" class="text-gray-500">Đã ngưng</option>
                        </select>
                    </div>
                    <div class="glass-panel rounded-xl p-4 space-y-2 bg-red-900/10 border-red-500/30 shadow-[0_0_15px_rgba(239,68,68,0.1)]">
                        <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Giá vé cơ bản (VNĐ)</label>
                        <input type="number" id="form-movie-price" name="basePrice" required min="0" step="1000" class="w-full bg-black border border-red-500/50 focus:border-red-500 rounded-lg px-3 py-2 text-lg text-amber-500 font-black text-center outline-none">
                    </div>
                </div>

            </div>
        </form>

        <%-- FLOATING ACTION BAR (Thanh chứa nút Lưu/Hủy nổi ở dưới cùng) --%>
        <div class="absolute bottom-0 left-0 right-0 p-5 bg-gradient-to-t from-[#0a0b0d] via-[#0a0b0d]/90 to-transparent flex justify-end gap-4 z-50 pointer-events-none">
            <div class="pointer-events-auto flex gap-4">
                <button type="button" onclick="handleCancelOrBack()" class="glass-panel hover:bg-gray-800 text-gray-300 font-bold py-3.5 px-8 rounded-xl transition-all text-xs flex items-center gap-2 shadow-lg">
                    <i class="fas fa-undo"></i> Hủy thay đổi
                </button>
                <button type="button" onclick="triggerSaveValidation()" class="bg-gradient-to-r from-red-600 to-amber-600 hover:from-red-700 hover:to-amber-700 text-white font-black py-3.5 px-10 rounded-xl shadow-[0_10px_20px_rgba(239,68,68,0.3)] transition-all transform hover:-translate-y-1 text-xs flex items-center gap-2">
                    <i class="fas fa-save"></i> Ghi nhận Hệ thống
                </button>
            </div>
        </div>

    </div>
</div>

<%-- HỘP THOẠI XÁC NHẬN CHUNG (Chạy đè lên trên tất cả) --%>
<div id="custom-confirm-dialog" class="fixed inset-0 z-[1000] hidden flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm transition-all duration-300 animate-fadeIn">
    <div class="relative w-full max-w-md bg-[#16171e] border border-gray-800 rounded-3xl p-8 shadow-[0_0_60px_rgba(0,0,0,0.9)] text-center space-y-6 animate-scaleUp">
        <div class="w-20 h-20 bg-red-600/10 border border-red-500/20 text-red-500 rounded-full flex items-center justify-center text-3xl mx-auto" id="confirm-icon-wrapper">
            <i class="fas fa-question" id="confirm-dialog-icon"></i>
        </div>
        <div class="space-y-2">
            <h4 id="confirm-dialog-title" class="text-white font-black uppercase tracking-widest text-lg">Xác nhận</h4>
            <p id="confirm-dialog-message" class="text-gray-400 text-sm leading-relaxed">Bạn có chắc chắn?</p>
        </div>
        <div class="flex gap-4 pt-4">
            <button id="confirm-btn-no" class="flex-1 bg-[#22232b] hover:bg-gray-800 text-gray-300 font-bold py-3.5 rounded-xl text-sm transition-all">Hủy bỏ</button>
            <button id="confirm-btn-yes" class="flex-1 bg-red-600 hover:bg-red-700 text-white font-black py-3.5 rounded-xl text-sm transition-all shadow-lg shadow-red-600/20">Đồng ý</button>
        </div>
    </div>
</div>

<%-- MODAL TRAILER --%>
<div id="trailer-modal" class="fixed inset-0 z-[1050] hidden flex items-center justify-center p-4 bg-black/95 backdrop-blur-md transition-all duration-300">
    <div class="absolute inset-0 cursor-pointer" onclick="closeTrailerModal()"></div>
    
    <div class="relative w-full max-w-5xl aspect-video bg-black border border-gray-800 rounded-2xl overflow-hidden shadow-[0_0_80px_rgba(239,68,68,0.4)] z-10 animate-scaleUp ring-1 ring-white/10">
        <div class="absolute top-4 right-4 z-50">
            <button type="button" onclick="closeTrailerModal()" class="w-10 h-10 rounded-full bg-black/50 hover:bg-red-600 text-white flex items-center justify-center border border-white/20 hover:border-transparent hover:rotate-90 transition-all duration-300 shadow-xl backdrop-blur-sm">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>
        
        <div class="w-full h-full">
            <iframe id="trailer-iframe" class="w-full h-full" src="" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
        </div>
    </div>
</div>

<script>
    // Hàm bóc tách link Youtube chuẩn
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
            console.error("Lỗi phân tích URL Trailer:", e);
        }
        return videoId ? 'https://www.youtube.com/embed/' + videoId + '?autoplay=1&rel=0' : url;
    }

    // Hàm mở Video từ ô nhập liệu
    window.openTrailerModal = function(trailerUrl) {
        const modal = document.getElementById('trailer-modal');
        const iframe = document.getElementById('trailer-iframe');
        if (modal && iframe) {
            const embedUrl = getYoutubeEmbedUrl(trailerUrl);
            iframe.src = embedUrl;
            modal.classList.remove('hidden');
        }
    };

    // Hàm đóng Video (tắt cả âm thanh)
    window.closeTrailerModal = function() {
        const modal = document.getElementById('trailer-modal');
        const iframe = document.getElementById('trailer-iframe');
        if (modal && iframe) {
            iframe.src = '';
            modal.classList.add('hidden');
        }
    };
    // 🛡️ TRẠM 1: Hàm kích hoạt từ nút "Ghi nhận Hệ thống"
    window.triggerSaveValidation = function() {
        const form = document.getElementById('movie-core-form');
        const errorBox = document.getElementById('frontend-error-box');
        const errorMsg = document.getElementById('frontend-error-msg');
        const backendBox = document.getElementById('backend-error-box');

        // Nếu form không hợp lệ (Trống tên, thiếu link, sai định dạng...)
        if (!form.checkValidity()) {
            if(backendBox) backendBox.style.display = 'none'; // Ẩn lỗi backend cũ đi
            
            errorMsg.textContent = "Vui lòng điền đầy đủ và đúng định dạng các thông tin bắt buộc!";
            errorBox.classList.remove('hidden'); // Hiển thị cái hộp đỏ của bạn lên
            
            form.reportValidity(); // Kích hoạt bong bóng báo lỗi mặc định chỉ thẳng vào ô bị sai
        } else {
            // Nếu Trạm 1 qua trót lọt, cho phép gửi dữ liệu đi để Trạm 2 và Trạm 3 kiểm tra
            errorBox.classList.add('hidden');
            form.submit();
        }
    };

    // 🛡️ CHỮA BỆNH "BỊT MIỆNG": Tự động mở lại Modal nếu Backend phát hiện lỗi
    document.addEventListener("DOMContentLoaded", function() {
        // Kiểm tra cờ hasModalError từ Controller gửi sang
        <c:if test="${hasModalError}">
            const modal = document.getElementById('movie-form-modal');
            if (modal) {
                // Xóa class hidden để Modal không bị đóng sập xuống
                modal.classList.remove('hidden');
            }
        </c:if>
    });
</script>