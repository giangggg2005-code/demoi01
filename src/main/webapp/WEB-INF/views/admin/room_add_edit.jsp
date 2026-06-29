<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    @keyframes popInModal {
        0% { opacity: 0; transform: scale(0.9) translateY(15px); }
        100% { opacity: 1; transform: scale(1) translateY(0); }
    }
    .modal-animate-pop {
        animation: popInModal 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    }
    @keyframes errorGlow {
        0%, 100% { border-color: rgba(239, 68, 68, 0.6); box-shadow: 0 0 5px rgba(239, 68, 68, 0.2); }
        50% { border-color: rgba(239, 68, 68, 1); box-shadow: 0 0 15px rgba(239, 68, 68, 0.5); }
    }
    .input-error-glow {
        animation: errorGlow 1.5s infinite;
    }
</style>

<div id="roomModal" class="fixed inset-0 bg-black/80 z-[100] hidden flex items-center justify-center backdrop-blur-sm transition-opacity duration-300">
    <div class="bg-[#0b0c10] border border-gray-800 rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden relative transform scale-95 transition-transform duration-300 glass-card" id="roomModalContent">
        
        <div class="p-6 border-b border-gray-800 flex justify-between items-center bg-[#121212]">
            <h2 id="roomModalTitle" class="text-xl font-black text-white uppercase tracking-wider flex items-center gap-2">
                <span class="w-1.5 h-5 bg-red-600 rounded-full inline-block"></span> Thêm Phòng Chiếu
            </h2>
            <button type="button" onclick="closeRoomModal()" class="text-gray-500 hover:text-red-500 transition-colors duration-200"><i class="fas fa-times text-xl"></i></button>
        </div>

        <form action="${pageContext.request.contextPath}/admin/rooms/save" method="POST" class="p-6 space-y-4">
            <input type="hidden" name="id_Room" id="form-room-id" value="${not empty roomData ? roomData.id_Room : '0'}">
            
            <div class="space-y-2 relative">
                <label class="text-xs font-bold text-gray-500 uppercase">Tên Phòng</label>
                <input type="text" name="roomName" id="form-room-name" required 
                       value="${not empty roomData ? roomData.roomName : ''}"
                       placeholder="Nhập tên phòng..." 
                       class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600 transition-all duration-300 ${not empty errorMsg ? 'input-error-glow' : ''}">
                
                <c:if test="${not empty errorMsg}">
                    <p class="text-xs text-red-500 font-medium mt-1"><i class="fas fa-exclamation-circle mr-1"></i>${errorMsg}</p>
                </c:if>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-500 uppercase">Loại Phòng</label>
                    <select name="roomType" id="form-room-type" class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600">
                        <option value="Standard" ${roomData.roomType == 'Standard' ? 'selected' : ''}>Standard</option>
                        <option value="IMAX" ${roomData.roomType == 'IMAX' ? 'selected' : ''}>IMAX</option>
                        <option value="VIP" ${roomData.roomType == 'VIP' ? 'selected' : ''}>VIP</option>
                    </select>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-500 uppercase">Phụ Thu (VNĐ)</label>
                    <input type="number" name="roomPrice" id="form-room-price" min="0" value="${not empty roomData ? roomData.roomPrice : '0'}" class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600">
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-500 uppercase">Tổng Hàng (Row)</label>
                    <input type="number" name="totalRows" id="form-room-rows" required min="1" max="50" value="${not empty roomData ? roomData.totalRows : '5'}" class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600 read-only:opacity-50 transition-all">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-500 uppercase">Tổng Cột (Col)</label>
                    <input type="number" name="totalCols" id="form-room-cols" required min="1" max="50" value="${not empty roomData ? roomData.totalCols : '5'}" class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600 read-only:opacity-50 transition-all">
                </div>
            </div>
            
            <div id="realtime-validation-error" class="text-red-500 text-sm font-medium mt-1 hidden transition-all duration-300"></div>
            
            <p id="roomNotice" class="text-xs text-yellow-500 mt-1 mb-2"><i class="fas fa-info-circle"></i> Sơ đồ ghế sẽ được Database Trigger tự động sinh ra khi lưu phòng mới.</p>

           <div class="space-y-2">
                <label class="text-xs font-bold text-gray-500 uppercase">Trạng Thái</label>
                <select name="status" id="form-room-status" class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-red-600">
                    <option value="Active" ${roomData.status == 'Active' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="Maintenance" ${roomData.status == 'Maintenance' ? 'selected' : ''}>Ngừng hoạt động / Bảo trì</option>
                </select>
            </div>

            <div class="pt-4 flex gap-3">
                <button type="button" onclick="closeRoomModal()" class="w-1/2 bg-gray-800 hover:bg-gray-700 text-white font-bold py-3 px-4 rounded-xl transition duration-200">Hủy</button>
                <button type="submit" id="submitRoomBtn" class="w-1/2 bg-red-600 hover:bg-red-700 text-white font-bold py-3 px-4 rounded-xl transition duration-200 shadow-[0_0_15px_rgba(220,38,38,0.3)]">Lưu</button>
            </div>
        </form>
    </div>
</div>


<c:if test="${not empty systemErrorMsg}">
    <div id="systemErrorModal" class="fixed inset-0 bg-black/80 z-[200] flex items-center justify-center backdrop-blur-sm transition-opacity duration-300">
        <div class="bg-[#0b0c10] border border-red-500/40 rounded-2xl shadow-[0_0_30px_rgba(239,68,68,0.2)] w-full max-w-md overflow-hidden relative glass-card modal-animate-pop">
            
            <div class="p-5 border-b border-gray-800 flex justify-between items-center bg-[#121212]">
                <h2 class="text-sm font-black text-white uppercase tracking-wider flex items-center gap-2">
                    <span class="w-1.5 h-4 bg-red-600 rounded-full inline-block animate-pulse"></span>
                    Lỗi Hệ Thống
                </h2>
                <button type="button" onclick="closeSystemErrorModal()" class="text-gray-500 hover:text-red-500 transition-colors"><i class="fas fa-times text-lg"></i></button>
            </div>

            <div class="p-6 text-center space-y-3">
                <div class="w-14 h-14 bg-red-500/10 border border-red-500/20 rounded-full flex items-center justify-center mx-auto shadow-inner">
                    <i class="fas fa-exclamation-triangle text-2xl text-red-500"></i>
                </div>
                <p class="text-gray-300 text-sm font-medium px-2 leading-relaxed">
                    ${systemErrorMsg}
                </p>
            </div>

            <div class="p-6 pt-0">
                <button type="button" onclick="closeSystemErrorModal()" class="w-full bg-gray-800 hover:bg-gray-700 text-white font-bold py-3 rounded-xl transition duration-200 shadow-md">
                    Đóng Lại
                </button>
            </div>
        </div>
    </div>
</c:if>


<script>
    // Hàm mở Modal thêm/sửa phòng thông thường
    function openAddRoomModal() {
        const modal = document.getElementById('roomModal');
        const modalContent = document.getElementById('roomModalContent');
        
        modal.classList.remove('hidden');
        setTimeout(() => {
            modalContent.classList.add('modal-animate-pop');
        }, 10);
    }

    function closeRoomModal() {
        const modal = document.getElementById('roomModal');
        modal.classList.add('hidden');
    }

    // Hàm đóng Modal thông báo lỗi ID hệ thống
    function closeSystemErrorModal() {
        const errModal = document.getElementById('systemErrorModal');
        if(errModal) {
            errModal.style.opacity = '0';
            setTimeout(() => { errModal.remove(); }, 250);
        }
    }

    // Xử lý Validate Realtime và tự động mở form nếu có lỗi
    document.addEventListener("DOMContentLoaded", function() {
        // Tự động kích hoạt mở lại Modal và giữ nguyên dữ liệu cũ nếu phát hiện lỗi trùng tên sau khi chuyển trang về
        <c:if test="${not empty errorMsg}">
            openAddRoomModal();
            // Xóa viền đỏ chớp nháy khi admin click gõ lại vào ô nhập tên
            const nameInput = document.getElementById('form-room-name');
            if(nameInput) {
                nameInput.addEventListener('input', function() {
                    this.classList.remove('input-error-glow');
                });
            }
        </c:if>

        // ---- BỔ SUNG VALIDATE REAL-TIME CHO HÀNG VÀ CỘT (GIỚI HẠN TỐI ĐA 20) ----
        const rowsInput = document.getElementById('form-room-rows'); 
        const colsInput = document.getElementById('form-room-cols');
        const submitBtn = document.getElementById('submitRoomBtn'); 
        const realtimeErrorBox = document.getElementById('realtime-validation-error');

        function validateDimensionsRealtime() {
            let errorMessages = [];
            // Nếu người dùng xóa trống ô nhập thì coi như bằng 0 để không bị lỗi NaN
            let r = parseInt(rowsInput.value) || 0;
            let c = parseInt(colsInput.value) || 0;
            
            if (r > 20) errorMessages.push("Số hàng (Row) không được vượt quá 20!");
            if (c > 20) errorMessages.push("Số cột (Col) không được vượt quá 20!");
            
            if (errorMessages.length > 0) {
                // Hiển thị lỗi ngay lập tức và hiệu ứng nhấp nháy đỏ cho ô input
                realtimeErrorBox.innerHTML = '⚠️ ' + errorMessages.join(" <br> ⚠️ ");
                realtimeErrorBox.classList.remove('hidden');
                
                if(r > 20) rowsInput.classList.add('input-error-glow');
                else rowsInput.classList.remove('input-error-glow');

                if(c > 20) colsInput.classList.add('input-error-glow');
                else colsInput.classList.remove('input-error-glow');
                
                // Khóa nút Submit
                if(submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.classList.add('opacity-50', 'cursor-not-allowed');
                }
            } else {
                // Nhập hợp lệ -> Ẩn lỗi và mở khóa nút
                realtimeErrorBox.classList.add('hidden');
                if(rowsInput) rowsInput.classList.remove('input-error-glow');
                if(colsInput) colsInput.classList.remove('input-error-glow');
                
                if(submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                }
            }
        }

        // Lắng nghe sự kiện người dùng đang gõ (chứ không cần chờ ấn nút)
        if (rowsInput) rowsInput.addEventListener('input', validateDimensionsRealtime);
        if (colsInput) colsInput.addEventListener('input', validateDimensionsRealtime);
    });
</script>