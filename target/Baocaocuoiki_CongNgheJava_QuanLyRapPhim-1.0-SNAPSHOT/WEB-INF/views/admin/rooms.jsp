<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .premium-glow {
        box-shadow: 0 0 15px rgba(239, 68, 68, 0.2);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .premium-glow:hover {
        box-shadow: 0 0 25px rgba(239, 68, 68, 0.4);
        transform: translateY(-2px);
    }
    
    .room-row-animate {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .room-row-animate:hover {
        background: rgba(255, 255, 255, 0.04) !important;
        transform: scale(1.005);
        box-shadow: inset 4px 0 0 #ef4444, 0 10px 20px rgba(0,0,0,0.3);
        z-index: 10;
        position: relative;
    }

    .pulse-green {
        animation: softPulse 2s infinite alternate;
    }
    @keyframes softPulse {
        0% { opacity: 0.5; transform: scale(0.9); box-shadow: 0 0 0 rgba(34, 197, 94, 0); }
        100% { opacity: 1; transform: scale(1.1); box-shadow: 0 0 8px rgba(34, 197, 94, 0.6); }
    }

    @keyframes modalIn {
        from { opacity: 0; transform: scale(0.9) translateY(-20px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .animate-modal-in {
        animation: modalIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    }
</style>

<div id="alert-container" class="w-full max-w-4xl mx-auto mb-4 px-4">
    <%-- ĐÃ LOẠI BỎ KHUNG BÁO LỖI MÀU ĐỎ TẠI ĐÂY THEO YÊU CẦU --%>

    <%-- Khung báo thành công màu Xanh Lá (Sẽ tự biến mất) --%>
    <c:if test="${not empty successMsg}">
        <div id="success-alert" class="bg-green-900/40 border border-green-500 text-green-200 px-4 py-3 rounded-lg relative shadow-[0_0_15px_rgba(34,197,94,0.3)] flex items-center gap-3 transition-all duration-500 ease-out">
            <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <span class="block sm:inline font-medium">${successMsg}</span>
        </div>
        <script>
            // Tự động mờ dần và biến mất sau 4 giây
            setTimeout(() => {
                const successAlert = document.getElementById('success-alert');
                if (successAlert) {
                    successAlert.style.opacity = '0';
                    successAlert.style.transform = 'translateY(-10px)';
                    setTimeout(() => successAlert.remove(), 500); // Đợi animation xong rồi xóa khỏi DOM
                }
            }, 4000);
        </script>
    </c:if>
</div>

<div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
    <div>
        <h2 class="text-xl font-black text-white uppercase tracking-wider flex items-center gap-2">
            <span class="w-1.5 h-6 bg-red-600 rounded-full inline-block"></span>
            Quản Lý Phòng Chiếu
        </h2>
        <p class="text-xs text-gray-500">Quản lý danh sách, loại phòng và theo dõi sơ đồ ghế ngồi trực quan</p>
    </div>
    <div class="flex gap-3">
        <button onclick="openAddRoomModal()" class="premium-glow bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white px-5 py-2.5 rounded-xl text-sm font-bold transition-all active:scale-95 flex items-center">
            <i class="fas fa-plus mr-2"></i> Thêm phòng mới
        </button>
    </div>
</div>

<div class="bg-[#121212]/90 backdrop-blur-md p-4 rounded-2xl border border-gray-800/80 mb-6 flex flex-wrap gap-4 items-center shadow-inner shadow-black/40">
    <div class="flex-1 min-w-[200px]">
        <div class="relative group">
            <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-red-500 transition-colors duration-300"></i>
            <input type="text" id="roomSearchInput" onkeyup="filterRooms()" placeholder="Tìm kiếm tên phòng chiếu..." class="w-full bg-[#0e0f14] border border-gray-800 rounded-xl pl-10 pr-4 py-2.5 text-sm text-white focus:outline-none focus:border-red-600/80 focus:ring-1 focus:ring-red-600/50 transition-all duration-300">
        </div>
    </div>
    
    <%-- ĐÃ BỔ SUNG THÊM LỰA CHỌN 4DX VÀ SWEETBOX --%>
    <select id="roomTypeFilter" onchange="filterRooms()" class="bg-[#0e0f14] border border-gray-800 rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-red-600/80 focus:ring-1 focus:ring-red-600/50 cursor-pointer transition-all duration-300">
        <option value="all">Loại Phòng (Tất cả)</option>
        <option value="Standard">Phòng Thường (Standard)</option>
        <option value="IMAX">Phòng IMAX</option>
        <option value="VIP">Phòng VIP</option>
        <option value="4DX">Phòng 4DX</option>
        <option value="Sweetbox">Phòng Sweetbox</option>
    </select>
    
    <select id="roomStatusFilter" onchange="filterRooms()" class="bg-[#0a0a0d] border border-gray-800 text-gray-300 text-sm rounded-xl px-4 py-2.5 outline-none focus:border-red-500 transition font-bold cursor-pointer shadow-inner">
        <option value="all">🌟 Tất cả trạng thái</option>
        <option value="Active">🟢 Hoạt động</option>
        <option value="Maintenance">🟡 Bảo trì</option>
    </select>
</div>

<div class="bg-[#121212] border border-gray-800/60 rounded-2xl overflow-hidden shadow-2xl glass-card relative">
    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="bg-gradient-to-r from-[#0e0f14] to-[#16171d] border-b border-gray-800 text-xs uppercase tracking-wider text-gray-500 font-bold">
                <th class="p-4">Tên Phòng</th>
                <th class="p-4">Loại Phòng</th>
                <th class="p-4">Sức Chứa</th>
                <th class="p-4 text-center">Phụ Thu (VNĐ)</th>
                <th class="p-4 text-center">Trạng Thái</th>
                <th class="p-4 text-right">Thao Tác</th>
            </tr>
        </thead>
        <tbody id="roomTableBody">
            <c:forEach var="room" items="${roomList}">
                <tr id="room-row-${room.id_Room}" class="border-b border-gray-800/40 hover:bg-white/5 transition-all room-row-animate" 
                    data-name="${room.roomName}" data-type="${room.roomType}" data-status="${room.status}">
                    <td class="p-4 font-bold text-white tracking-wide">${room.roomName}</td>
                    
                    <%-- ĐÃ BỔ SUNG THÊM HIỂN THỊ BADGE CHO 4DX VÀ SWEETBOX --%>
                    <td class="p-4">
                        <c:choose>
                            <c:when test="${room.roomType == 'IMAX'}"><span class="px-2 py-1 bg-blue-500/10 text-blue-400 font-black tracking-widest text-[10px] rounded border border-blue-500/20">IMAX</span></c:when>
                            <c:when test="${room.roomType == 'VIP'}"><span class="px-2 py-1 bg-yellow-500/10 text-yellow-400 font-black tracking-widest text-[10px] rounded border border-yellow-500/20 glow-text-red">VIP</span></c:when>
                            <c:when test="${room.roomType == '4DX'}"><span class="px-2 py-1 bg-purple-500/10 text-purple-400 font-black tracking-widest text-[10px] rounded border border-purple-500/20">4DX</span></c:when>
                            <c:when test="${room.roomType == 'Sweetbox'}"><span class="px-2 py-1 bg-pink-500/10 text-pink-400 font-black tracking-widest text-[10px] rounded border border-pink-500/20">SWEETBOX</span></c:when>
                            <c:otherwise><span class="px-2 py-1 bg-gray-500/10 text-gray-400 font-bold tracking-widest text-[10px] rounded border border-gray-500/20">STANDARD</span></c:otherwise>
                        </c:choose>
                    </td>
                    
                    <td class="p-4 text-gray-300 text-sm">
                        <i class="fas fa-th text-gray-600 mr-1.5 text-xs"></i> Lưới: <span class="font-semibold text-white">${room.totalRows}x${room.totalCols}</span>
                    </td>
                    <td class="p-4 text-center text-red-400 font-bold tracking-wider">
                        <c:choose>
                            <c:when test="${room.roomPrice > 0}">+${room.roomPrice}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </td>
                    <td class="p-4 text-center">
                        <c:if test="${room.status == 'Active'}">
                            <span class="inline-flex items-center px-3 py-1 bg-green-500/10 text-green-500 rounded-full text-xs font-bold border border-green-500/20 shadow-sm shadow-green-500/10"><i class="fas fa-circle text-[6px] mr-1.5 pulse-green"></i> Active</span>
                        </c:if>
                        <c:if test="${room.status != 'Active'}">
                            <span class="inline-flex items-center px-3 py-1 bg-red-500/10 text-red-500 rounded-full text-xs font-bold border border-red-500/20"><i class="fas fa-ban text-[9px] mr-1.5"></i> ${room.status}</span>
                        </c:if>
                    </td>
                    <td class="p-4 text-right">
                        <div class="flex items-center justify-end gap-2.5">
                           <a href="${pageContext.request.contextPath}/admin/rooms/detail?id=${room.id_Room}&mode=view" class="w-8 h-8 rounded-lg bg-blue-500/10 text-blue-500 hover:bg-blue-500 hover:text-white transition-all flex items-center justify-center shadow-sm"> <i class="fas fa-eye text-xs"></i> </a>
                           <a href="${pageContext.request.contextPath}/admin/rooms/detail?id=${room.id_Room}&mode=edit" class="w-8 h-8 rounded-lg bg-yellow-500/10 text-yellow-500 hover:bg-yellow-500 hover:text-white transition-all flex items-center justify-center shadow-sm"> <i class="fas fa-pen text-xs"></i> </a>
                           <button onclick="openConfirmModal('${room.id_Room}', '${room.roomName}')" class="w-8 h-8 rounded-lg bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white transition-all flex items-center justify-center shadow-sm" title="Xóa phòng chiếu">
                                <i class="fas fa-trash text-xs"></i>
                           </button>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div id="confirmOverlay" class="fixed inset-0 bg-black/80 backdrop-blur-md z-[998] hidden flex items-center justify-center p-4 transition-opacity duration-300 opacity-0">
    <div id="confirmModalBox" class="bg-[#121214] border border-red-500/40 rounded-2xl max-w-md w-full p-6 shadow-[0_0_40px_rgba(239,68,68,0.15)] text-center relative overflow-hidden transform scale-95 transition-transform duration-300">
        <div class="absolute top-0 left-0 right-0 h-[3px] bg-gradient-to-r from-transparent via-red-500 to-transparent"></div>
        <div class="w-16 h-16 bg-red-500/10 border border-red-500/30 rounded-full flex items-center justify-center mx-auto mb-4 shadow-inner shadow-red-500/20">
            <i class="fas fa-trash-alt text-2xl text-red-500"></i>
        </div>
        <h3 class="text-lg font-black text-white uppercase tracking-wider mb-2">Xác Nhận Xóa Phòng</h3>
        <p id="confirmModalMessage" class="text-sm text-gray-400 leading-relaxed px-2 mb-6">Bạn có chắc chắn muốn xóa phòng này không?</p>
        <div class="flex gap-3 mt-4">
            <button onclick="closeConfirmModal()" class="w-1/2 bg-[#1c1d22] hover:bg-gray-800 border border-gray-700 text-gray-300 font-bold text-sm py-3 rounded-xl transition-all duration-200">Hủy Bỏ</button>
            <button id="btnConfirmDelete" class="w-1/2 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white font-bold text-sm py-3 rounded-xl transition-all duration-200 shadow-lg shadow-red-900/40">Xác Nhận Xóa</button>
        </div>
    </div>
</div>

<%-- Cửa sổ thông báo lỗi (Modal) - Bắt buộc ấn nút mới đóng được --%>
<div id="errorOverlay" class="fixed inset-0 bg-black/80 backdrop-blur-md z-[999] hidden flex items-center justify-center p-4 transition-opacity duration-300 opacity-0">
    <div id="errorModalBox" class="bg-[#121214] border border-red-500/40 rounded-2xl max-w-md w-full p-6 shadow-[0_0_40px_rgba(239,68,68,0.15)] text-center relative overflow-hidden transform scale-95 transition-transform duration-300">
        <div class="absolute top-0 left-0 right-0 h-[3px] bg-gradient-to-r from-transparent via-red-500 to-transparent"></div>
        <div class="w-16 h-16 bg-red-500/10 border border-red-500/30 rounded-full flex items-center justify-center mx-auto mb-4 shadow-inner shadow-red-500/20">
            <i class="fas fa-exclamation-triangle text-2xl text-red-500 animate-pulse"></i>
        </div>
        <h3 id="errorModalTitle" class="text-lg font-black text-white uppercase tracking-wider mb-2">Hành Động Bị Từ Chối</h3>
        <div id="errorModalMessage" class="text-sm text-red-400/90 font-medium leading-relaxed px-4 mb-6">Nội dung lỗi chi tiết.</div>
        <button onclick="closeErrorModal()" class="w-full bg-gradient-to-r from-red-600 to-red-700 hover:from-red-500 hover:to-red-600 text-white font-bold text-sm py-3 rounded-xl transition-all duration-200 shadow-lg shadow-red-900/40 tracking-wide active:scale-95">Tôi Đã Hiểu & Đóng Lại</button>
    </div>
</div>

<jsp:include page="room_add_edit.jsp" />

<script>
    function openAddRoomModal() {
        const modal = document.getElementById('roomModal');
        if (!modal) return;
        modal.classList.remove('hidden');
        document.getElementById('roomModalTitle').innerText = 'Thêm Phòng Chiếu Mới';
        
        document.getElementById('form-room-id').value = '0';
        document.getElementById('form-room-name').value = '';
        document.getElementById('form-room-rows').readOnly = false;
        document.getElementById('form-room-cols').readOnly = false;
        document.getElementById('form-room-rows').value = '5';
        document.getElementById('form-room-cols').value = '5';
        
        if (document.getElementById('form-room-type')) document.getElementById('form-room-type').value = 'Standard';
        if (document.getElementById('form-room-price')) document.getElementById('form-room-price').value = '0';
        if (document.getElementById('form-room-status')) document.getElementById('form-room-status').value = 'Active';
        
        const notice = document.getElementById('roomNotice');
        if (notice) notice.classList.remove('hidden');
    }

    function closeRoomModal() {
        const modal = document.getElementById('roomModal');
        if (modal) modal.classList.add('hidden');
    }

    function openConfirmModal(id, name) {
        const overlay = document.getElementById('confirmOverlay');
        const modalBox = document.getElementById('confirmModalBox');
        
        document.getElementById('confirmModalMessage').innerHTML = 'Bạn có chắc chắn muốn xóa phòng chiếu <strong class="text-white text-base">"' + name + '"</strong> không?<br><span class="text-xs text-red-400 block mt-2">Hành động này không thể hoàn tác!</span>';
        
        const btnConfirm = document.getElementById('btnConfirmDelete');
        btnConfirm.onclick = function() {
            closeConfirmModal();
            executeDeleteRoomAjax(id); 
        };
        
        overlay.classList.remove('hidden');
        overlay.classList.add('flex');
        
        setTimeout(() => {
            overlay.classList.remove('opacity-0');
            modalBox.classList.remove('scale-95');
            modalBox.classList.add('scale-100', 'animate-modal-in');
        }, 10);
    }

    function closeConfirmModal() {
        const overlay = document.getElementById('confirmOverlay');
        const modalBox = document.getElementById('confirmModalBox');
        
        overlay.classList.add('opacity-0');
        modalBox.classList.remove('scale-100', 'animate-modal-in');
        modalBox.classList.add('scale-95');
        
        setTimeout(() => {
            overlay.classList.remove('flex');
            overlay.classList.add('hidden');
        }, 300);
    }

    function executeDeleteRoomAjax(id) {
        fetch('${pageContext.request.contextPath}/admin/rooms/delete-ajax?id=' + id, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(response => {
            if (response.ok) {
                const row = document.getElementById('room-row-' + id);
                if (row) {
                    row.style.transition = 'all 0.5s cubic-bezier(0.4, 0, 0.2, 1)';
                    row.style.opacity = '0';
                    row.style.transform = 'translateX(-80px)';
                    row.style.background = 'rgba(239, 68, 68, 0.1)';
                    setTimeout(() => { row.remove(); }, 500);
                } else {
                    window.location.reload();
                }
            } else {
                return response.text().then(errorMessage => {
                    if (errorMessage.trim().toLowerCase().startsWith("<!doctype html>") || errorMessage.trim().toLowerCase().startsWith("<html")) {
                        throw new Error("Hệ thống chưa thiết lập API xử lý đường dẫn xóa phòng hoặc xảy ra lỗi biên dịch mã nguồn!");
                    }
                    throw new Error(errorMessage);
                });
            }
        })
        .catch(error => {
            let finalMessage = error.message;
            let lowerMsg = finalMessage.toLowerCase();
            
            // CHỐT CHẶN: Phát hiện lỗi SQL/Database và đè lại bằng tiếng Việt thuần túy
            if (lowerMsg.includes("sql") || lowerMsg.includes("foreign key") || lowerMsg.includes("constraint") || lowerMsg.includes("preparedstatement")) {
                finalMessage = "Không thể xóa phòng chiếu này vì sơ đồ ghế trong phòng đã có lịch sử giao dịch mua vé của khách hàng!";
            }
            
            showErrorModal("Không Thể Xóa Phòng!", finalMessage);
        });
    }

    function showErrorModal(title, message) {
        const overlay = document.getElementById('errorOverlay');
        const modalBox = document.getElementById('errorModalBox');
        
        document.getElementById('errorModalTitle').innerText = title;
        document.getElementById('errorModalMessage').innerHTML = message;
        
        overlay.classList.remove('hidden');
        overlay.classList.add('flex');
        
        setTimeout(() => {
            overlay.classList.remove('opacity-0');
            modalBox.classList.remove('scale-95');
            modalBox.classList.add('scale-100', 'animate-modal-in');
        }, 10);
    }

    function closeErrorModal() {
        const overlay = document.getElementById('errorOverlay');
        const modalBox = document.getElementById('errorModalBox');
        
        overlay.classList.add('opacity-0');
        modalBox.classList.remove('scale-100', 'animate-modal-in');
        modalBox.classList.add('scale-95');
        
        setTimeout(() => {
            overlay.classList.remove('flex');
            overlay.classList.add('hidden');
        }, 300);
    }

    function filterRooms() {
        const searchInput = document.getElementById('roomSearchInput');
        const typeFilter = document.getElementById('roomTypeFilter');
        const statusFilter = document.getElementById('roomStatusFilter');
        if (!searchInput || !typeFilter || !statusFilter) return;
        
        const searchVal = searchInput.value.toLowerCase().trim();
        const typeVal = typeFilter.value;
        const statusVal = statusFilter.value.toLowerCase().trim(); 
        const rows = document.querySelectorAll("#roomTableBody tr");
        
        rows.forEach(row => {
            const name = (row.getAttribute('data-name') || '').toLowerCase().trim();
            const type = row.getAttribute('data-type') || '';
            const status = (row.getAttribute('data-status') || '').toLowerCase().trim(); 
            
            const matchesSearch = name.includes(searchVal);
            const matchesType = (typeVal === 'all' || type === typeVal);
            const matchesStatus = (statusVal === 'all' || status === statusVal);
            
            if (matchesSearch && matchesType && matchesStatus) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }
</script>