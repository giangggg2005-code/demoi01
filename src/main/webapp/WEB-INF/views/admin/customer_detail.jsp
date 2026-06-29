<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    /* ------------------------------------- */
    /* 1. GIAO DIỆN CƠ BẢN TỪ TRƯỚC          */
    /* ------------------------------------- */
    .glass-card {
        background: rgba(22, 22, 22, 0.85);
        backdrop-filter: blur(16px);
    }
    .input-premium {
        background-color: #0d0d0d;
        border: 1px solid #262626;
        color: #f3f4f6;
        border-radius: 0.75rem;
        padding: 0.625rem 1rem;
        width: 100%;
        transition: all 0.3s ease;
    }
    .input-premium:focus {
        border-color: #dc2626;
        outline: none;
        box-shadow: 0 0 12px rgba(220, 38, 38, 0.25);
    }
    .input-readonly {
        background-color: #050505;
        color: #737373;
        cursor: not-allowed;
        border-color: #171717;
    }
    .animate-fade-down {
        animation: fadeDown 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    @keyframes fadeDown {
        from {
            opacity: 0;
            transform: translateY(-16px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* ------------------------------------- */
    /* 2. HIỆU ỨNG PREMIUM TOAST & MODAL MỚI */
    /* ------------------------------------- */
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
    @keyframes toastTimeline {
        0% {
            width: 100%;
        }
        100% {
            width: 0%;
        }
    }
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
    @keyframes subtleBounce {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-3px);
        }
    }

    .toast-item {
        animation: toastFlyIn 0.55s cubic-bezier(0.25, 1, 0.5, 1) forwards;
        will-change: transform, opacity;
        z-index: 99999;
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
    .animate-subtle-bounce {
        animation: subtleBounce 2.5s ease-in-out infinite;
    }
</style>

<input type="hidden" id="backend-error-bridge" value="${errorMessage}">
<input type="hidden" id="backend-success-bridge" value="${successMessage}">

<div id="premium-toast-container" class="fixed bottom-6 right-6 flex flex-col gap-3 z-[99999] max-w-sm w-full pointer-events-none"></div>

<div class="mb-5">
    <a href="${pageContext.request.contextPath}/admin/customers" class="text-gray-400 hover:text-red-500 font-bold text-sm transition-colors duration-200 inline-flex items-center group">
        <i class="fas fa-arrow-left mr-2 transform group-hover:-translate-x-1 transition-transform"></i> Quay lại danh sách
    </a>
</div>

<div class="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-6">

    <div class="lg:col-span-4 flex flex-col gap-6">

        <div class="glass-card border border-gray-800/80 rounded-2xl p-6 shadow-xl relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-red-600/10 blur-[30px] rounded-full"></div>

            <div class="text-center mb-5 relative z-10">
                <div class="w-24 h-24 mx-auto rounded-full bg-gradient-to-tr from-red-600 to-amber-500 p-0.5 shadow-2xl flex items-center justify-center text-3xl font-black text-white mb-3">
    <c:choose>
        <%-- 1. Kiểm tra avatar khác rỗng và khác chữ 'null' --%>
        <c:when test="${not empty customer.avatar && customer.avatar != 'null' && fn:trim(customer.avatar) != ''}">
            <c:choose>
                <%-- TH 1A: Link mạng --%>
                <c:when test="${fn:startsWith(fn:trim(customer.avatar), 'http')}">
                    <img src="${fn:trim(customer.avatar)}" 
                         class="w-full h-full rounded-full object-cover"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                </c:when>
                <%-- TH 1B: Link nội bộ lưu trong máy chủ --%>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/assets/images/avatar/${fn:trim(customer.avatar)}" 
                         class="w-full h-full rounded-full object-cover"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                </c:otherwise>
            </c:choose>
        </c:when>
        <%-- 2. Nếu trống -> tự động load ảnh API chữ cái theo tên --%>
        <c:otherwise>
            <img src="https://ui-avatars.com/api/?name=${not empty customer.fullName ? customer.fullName : 'User'}&background=random" 
                 class="w-full h-full rounded-full object-cover">
        </c:otherwise>
    </c:choose>
</div>
                <h2 class="text-2xl font-black text-white tracking-wide">${customer.fullName}</h2>
                <div class="mt-2">
                    <span class="text-gray-400 text-xs font-mono bg-gray-800/50 px-3 py-1 rounded-full border border-gray-700/50 inline-block shadow-inner">UID: #${customer.id_User}</span>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-2 text-center bg-[#0a0a0a] rounded-xl p-3 border border-gray-800 relative z-10 shadow-inner">
                <div>
                    <p class="text-xs text-gray-500 uppercase font-bold mb-1">Tạo ngày</p>
                    <p class="text-sm text-gray-300 font-mono"><fmt:formatDate value='${customer.createdAt}' pattern='dd/MM/yy HH:mm'/></p>
                </div>
                <div class="border-l border-gray-800">
                    <p class="text-xs text-gray-500 uppercase font-bold mb-1">Cập nhật</p>
                    <p class="text-sm text-yellow-500/80 font-mono"><fmt:formatDate value='${customer.updatedAt}' pattern='dd/MM/yy HH:mm'/></p>
                </div>
            </div>
        </div>

        <div class="glass-card border border-yellow-500/20 rounded-2xl p-6 shadow-xl relative bg-gradient-to-br from-[#111] to-[#1a1500]">
            <h3 class="text-base font-black text-gray-300 uppercase tracking-wide mb-5 flex items-center gap-2 border-b border-gray-800/60 pb-3">
                <i class="fas fa-key text-yellow-500"></i> Thông tin đăng nhập
            </h3>

            <div class="space-y-5">
                <div>
                    <label class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-2 block">Tên đăng nhập (Username)</label>
                    <div class="flex items-center bg-[#050505] border border-gray-800 rounded-xl px-4 py-3 shadow-inner">
                        <i class="fas fa-user-circle text-gray-600 mr-3 text-xl"></i>
                        <span class="text-red-400 font-mono font-bold tracking-wider text-base">@${customer.username}</span>
                    </div>
                </div>

                <div>
                    <label class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-2 block">Mật khẩu (Password)</label>
                    <div class="flex gap-2 h-12">
                        <div class="relative flex-1 h-full">
                            <input type="password" id="pwdInput" value="${customer.password}" readonly class="input-premium input-readonly font-mono pr-10 text-xl tracking-[0.25em] h-full py-0">
                            <button type="button" onclick="togglePassword()" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white transition">
                                <i id="pwdIcon" class="fas fa-eye text-lg"></i>
                            </button>
                        </div>

                        <form id="formResetPass" action="${pageContext.request.contextPath}/admin/customers/reset-password" method="POST" class="h-full">
                            <input type="hidden" name="customerId" value="${customer.id_User}">
                            <button type="button" onclick="openConfirmModal('reset')" class="px-5 bg-yellow-600/10 hover:bg-yellow-600 border border-yellow-600/30 text-yellow-500 hover:text-white rounded-xl text-sm font-bold transition-all h-full flex items-center justify-center gap-1.5 shadow-sm whitespace-nowrap">
                                <i class="fas fa-redo-alt"></i> Reset
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="glass-card border border-gray-800/80 rounded-2xl p-6 shadow-xl">
            <h3 class="text-base font-black text-gray-300 uppercase tracking-wide mb-5 flex items-center gap-2 border-b border-gray-800/60 pb-3"><i class="fas fa-user-shield text-purple-500"></i> Phân quyền hệ thống</h3>
            <div class="space-y-5">
                <c:if test="${empty roleDetails}">
                    <div class="bg-[#121212] border border-gray-800/50 border-dashed rounded-xl p-5 text-center">
                        <i class="fas fa-user-lock text-gray-600 text-2xl mb-2"></i>
                        <p class="text-sm text-gray-500 font-medium mt-2">Tài khoản này chưa được cấp quyền quản trị.</p>
                    </div>
                </c:if>
                <c:forEach items="${roleDetails}" var="rd">
                    <div class="bg-[#121212] border border-gray-700/60 rounded-xl p-5 relative shadow-md hover:border-gray-600 transition-colors">
                        <div class="flex justify-between items-start mb-3 border-b border-gray-800/80 pb-3">
                            <div>
                                <span class="px-3 py-1 rounded bg-purple-500/10 border border-purple-500/30 text-purple-400 text-sm font-black uppercase tracking-wider shadow-sm">${rd.rolename}</span>
                                <div class="text-xs text-gray-500 font-mono mt-2 flex gap-3">
                                    <span title="ID của nhóm quyền">Role ID: #${rd.id_role}</span>
                                    <span title="ID của lượt cấp quyền này">UserRole ID: #${rd.id_userrole}</span>
                                </div>
                            </div>
                            <span class="text-xs font-black uppercase tracking-wider ${rd.rolestatus == 'Active' ? 'text-green-500 bg-green-500/10 border-green-500/20' : 'text-red-500 bg-red-500/10 border-red-500/20'} border px-3 py-1.5 rounded-lg shadow-sm">
                                ${rd.rolestatus}
                            </span>
                        </div>
                        <div class="mb-4">
                            <label class="text-[11px] text-gray-500 font-bold uppercase tracking-wider mb-1 block">Chi tiết quyền hạn:</label>
                            <p class="text-sm text-gray-300 font-medium leading-relaxed bg-[#0a0a0a] p-3 rounded-lg border border-gray-800/50">${rd.description}</p>
                        </div>
                        <div class="flex flex-col gap-1.5 bg-[#050505] p-3 rounded-lg border border-gray-800/40">
                            <div class="flex justify-between items-center text-xs">
                                <span class="text-gray-500 font-bold"><i class="fas fa-calendar-plus mr-1.5 text-blue-500/70"></i>Cấp quyền lúc:</span>
                                <span class="text-gray-300 font-mono bg-gray-800/40 px-2 py-0.5 rounded">${rd.rolecreatedat}</span>
                            </div>
                            <div class="flex justify-between items-center text-xs">
                                <span class="text-gray-500 font-bold"><i class="fas fa-history mr-1.5 text-yellow-500/70"></i>Sửa lần cuối:</span>
                                <span class="text-yellow-500/80 font-mono bg-yellow-900/10 px-2 py-0.5 rounded border border-yellow-500/10">${rd.roleupdatedat}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <div class="lg:col-span-8 flex flex-col gap-6">

        <div class="glass-card border border-gray-800/80 rounded-2xl p-6 shadow-xl relative">
    <h3 class="text-xl font-black text-white uppercase tracking-wide mb-5 flex items-center gap-2 border-b border-gray-800/60 pb-3"><i class="fas fa-address-card text-blue-500"></i> Hồ sơ thông tin cá nhân</h3>

    <%-- ⚠️ QUAN TRỌNG 1: Bắt buộc thêm enctype="multipart/form-data" vào thẻ form để có thể upload được file ảnh --%>
    <form id="formUpdateInfo" action="${pageContext.request.contextPath}/admin/customers/update-info" method="POST" enctype="multipart/form-data" class="space-y-5">
        <input type="hidden" name="id_User" value="${customer.id_User}">
        
        <%-- ========================================== --%>
        <%-- BẮT ĐẦU: DÁN ĐOẠN CODE AVATAR CỦA BẠN VÀO ĐÂY --%>
        <%-- ========================================== --%>
        <div class="form-group mb-4">
            <label class="block text-sm font-medium text-gray-300 mb-2">Ảnh đại diện</label>
            
            <%-- Khung nhập link và nút tải ảnh --%>
            <div class="grid grid-cols-1 sm:grid-cols-4 gap-3">
                <div class="sm:col-span-3">
                    <input type="text" id="avatar" name="avatar" value="${customer.avatar}" class="input-premium border-gray-800 w-full" placeholder="https://... hoặc đường dẫn tự động khi chọn file" oninput="previewAvatar()"/>
                </div>
                <div class="sm:col-span-1">
                    <input type="file" id="avatarFile" name="imageFile" accept="image/*" class="hidden" onchange="handleFileSelect(this)"/>
                    <button type="button" onclick="document.getElementById('avatarFile').click()" class="w-full py-2.5 px-4 bg-zinc-900 hover:bg-zinc-800 text-gray-300 rounded-xl border border-gray-800 hover:border-gray-700 transition flex items-center justify-center gap-2 text-sm font-medium h-full min-h-[44px]">
                        <i class="fas fa-upload text-blue-500"></i> Chọn ảnh
                    </button>
                </div>
            </div>

            <%-- Khởi tạo logic tính toán nguồn ảnh xem trước cho 3 trường hợp --%>
            <c:set var="previewSrc" value=""/>
            <c:choose>
                <c:when test="${not empty customer.avatar && customer.avatar != 'null' && fn:trim(customer.avatar) != ''}">
                    <c:choose>
                        <c:when test="${fn:startsWith(fn:trim(customer.avatar), 'http')}">
                            <c:set var="previewSrc" value="${fn:trim(customer.avatar)}"/>
                        </c:when>
                        <c:otherwise>
                            <c:set var="previewSrc" value="${pageContext.request.contextPath}/assets/images/avatar/${fn:trim(customer.avatar)}"/>
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <c:set var="previewSrc" value="https://ui-avatars.com/api/?name=${not empty customer.fullName ? customer.fullName : 'User'}&background=random"/>
                </c:otherwise>
            </c:choose>

            <%-- Khung hiển thị ảnh Preview --%>
            <div class="mt-3 flex items-center gap-3 transition-all duration-300" id="avatar-preview-container">
                <div class="w-12 h-12 rounded-full border border-gray-600 shadow-lg overflow-hidden flex-shrink-0 bg-gray-800 flex items-center justify-center">
                    <img id="avatar-preview-img" 
                         src="${previewSrc}" 
                         alt="Preview" 
                         class="w-full h-full object-cover" 
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                    <i id="avatar-error-icon" class="fas fa-image text-gray-500 hidden"></i>
                </div>
                <span class="text-xs text-gray-400 italic" id="avatar-preview-text">Đang hiển thị ảnh xem trước hiện tại...</span>
            </div>
        </div>
        <%-- ========================================== --%>
        <%-- KẾT THÚC ĐOẠN CODE AVATAR --%>
        <%-- ========================================== --%>

        <div class="mb-4">
            <label class="text-xs text-zinc-400">Họ và tên</label>
            <%-- ⚠️ QUAN TRỌNG 2: Bổ sung id="fullName" vào thẻ input này để Javascript lấy được tên làm ảnh mặc định --%>
            <input type="text" id="fullName" name="fullName" value="${customer.fullName}" class="w-full bg-zinc-900 border border-zinc-800 rounded-xl p-2.5 text-sm text-white focus:border-blue-500 outline-none transition">
            <span id="error-fullName" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
        </div>

        <div class="mb-4">
            <label class="text-xs text-zinc-400">Số điện thoại</label>
            <input type="text" name="phone" value="${customer.phone}" class="w-full bg-zinc-900 border border-zinc-800 rounded-xl p-2.5 text-sm text-white focus:border-blue-500 outline-none transition">
            <span id="error-phone" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
        </div>

                <div class="mb-4">
                    <label class="text-xs text-zinc-400">Email</label>
                    <input type="text" name="email" value="${customer.email}" class="w-full bg-zinc-900 border border-zinc-800 rounded-xl p-2.5 text-sm text-white focus:border-blue-500 outline-none transition">
                    <span id="error-email" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                </div>

                <div class="flex justify-end pt-5 mt-5 border-t border-gray-800/60">
                    <button type="button" onclick="openConfirmModal('info')" class="px-8 py-3 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-500 hover:to-blue-600 text-white font-bold rounded-xl text-base shadow-[0_4px_20px_rgba(59,130,246,0.3)] transition-all flex items-center gap-2">
                        <i class="fas fa-save"></i> Lưu thông tin cá nhân
                    </button>
                </div>
            </form>
        </div>

        <div class="glass-card border border-red-500/20 rounded-2xl p-6 shadow-xl bg-gradient-to-br from-black to-red-950/10">
            <h3 class="text-base font-black text-gray-300 uppercase tracking-wide mb-5 flex items-center gap-2"><i class="fas fa-power-off text-red-500"></i> Quản lý trạng thái tài khoản</h3>

            <form id="formUpdateStatus" action="${pageContext.request.contextPath}/admin/customers/update-status" method="POST" class="flex flex-col gap-5">
                <input type="hidden" name="customerId" value="${customer.id_User}">

                <div>
                    <label class="text-sm text-gray-400 font-bold mb-3 block">Chọn trạng thái để áp dụng:</label>
                    <div class="flex gap-4">
                        <label class="cursor-pointer flex-1 relative group">
                            <input type="radio" name="status" value="Active" class="peer sr-only" ${customer.status == 'Active' ? 'checked' : ''}>
                            <div class="py-4 px-4 rounded-xl border-2 border-gray-800 bg-[#0a0a0a] text-gray-500 text-center text-base font-bold transition-all duration-300 peer-checked:border-green-500 peer-checked:bg-green-500/10 peer-checked:text-green-400 group-hover:border-gray-600 shadow-sm">
                                <i class="fas fa-user-check mr-2"></i> Hoạt động (Active)
                            </div>
                            <div class="absolute -top-2 -right-2 bg-green-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs opacity-0 peer-checked:opacity-100 transition-opacity duration-300 shadow-md"><i class="fas fa-check"></i></div>
                        </label>

                        <label class="cursor-pointer flex-1 relative group">
                            <input type="radio" name="status" value="Locked" class="peer sr-only" ${customer.status == 'Locked' ? 'checked' : ''}>
                            <div class="py-4 px-4 rounded-xl border-2 border-gray-800 bg-[#0a0a0a] text-gray-500 text-center text-base font-bold transition-all duration-300 peer-checked:border-red-500 peer-checked:bg-red-500/10 peer-checked:text-red-400 group-hover:border-gray-600 shadow-sm">
                                <i class="fas fa-user-lock mr-2"></i> Khóa (Locked)
                            </div>
                            <div class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs opacity-0 peer-checked:opacity-100 transition-opacity duration-300 shadow-md"><i class="fas fa-check"></i></div>
                        </label>
                    </div>
                </div>

                <button type="button" onclick="openConfirmModal('status')" class="w-full py-3.5 bg-red-600/20 hover:bg-red-600 border border-red-600 text-red-500 hover:text-white font-bold rounded-xl text-base transition-all flex items-center justify-center gap-2 mt-2 uppercase tracking-wider">
                    <i class="fas fa-sync-alt"></i> Xác nhận cập nhật hệ thống
                </button>
            </form>
        </div>
    </div>
</div>
<div class="flex justify-center my-8 border-t border-gray-800/50 pt-8">
    <button type="button" id="btnLoadHistory" onclick="toggleHistory(${customer.id_User})" class="px-8 py-3.5 bg-[#111] hover:bg-gray-800 border border-gray-700 hover:border-red-500/50 text-gray-300 hover:text-white rounded-full font-bold shadow-xl transition-all duration-300 flex items-center gap-2 group text-base">
        <i class="fas fa-history text-red-500 group-hover:-rotate-45 transition-transform duration-300"></i> 
        <span id="textHistoryBtn">Xem lịch sử vé đã mua</span>
    </button>
</div>

<div id="historySection" class="hidden glass-card border border-gray-800/80 rounded-2xl p-6 shadow-2xl animate-fade-down mb-10">
    
    <div class="flex flex-wrap items-end gap-4 mb-5 p-5 bg-[#0a0a0a] rounded-xl border border-gray-800">
        
        <div class="flex-1 min-w-[200px]">
            <label class="text-xs text-gray-500 font-bold uppercase block mb-2">Tìm tên phim</label>
            <input type="text" id="searchMovie" placeholder="Nhập từ khóa..." class="input-premium py-2.5 text-sm w-full" oninput="filterTable()">
        </div>
        
        <div class="flex-1 min-w-[150px]">
            <label class="text-xs text-gray-500 font-bold uppercase block mb-2">Lọc số ghế</label>
            <input type="text" id="searchSeat" placeholder="VD: A1, E5..." class="input-premium py-2.5 text-sm w-full" oninput="filterTable()">
        </div>
        
        <div class="flex-1 min-w-[200px]">
            <label class="text-xs text-gray-500 font-bold uppercase block mb-2">Phân loại vé</label>
            <select id="searchType" class="input-premium py-2.5 text-sm w-full cursor-pointer" onchange="filterTable()">
                <option value="ALL">Tất cả lịch sử</option>
                <option value="UPCOMING">Vé sắp xem (Chưa chiếu)</option>
                <option value="PAST">Vé đã xem (Đã chiếu)</option>
                <option value="REFUNDED">Đã hủy / Hoàn tiền</option>
            </select>
        </div>

        <div class="flex-[2] min-w-[350px] flex items-end gap-3">
            <div class="flex-1">
                <label class="text-xs text-gray-500 font-bold uppercase block mb-2">Từ ngày giờ</label>
                <input type="datetime-local" id="fromDate" class="input-premium py-2.5 text-sm w-full cursor-pointer" onchange="filterTable()" title="Chọn ngày giờ bắt đầu">
            </div>
            
            <div class="flex-1">
                <label class="text-xs text-gray-500 font-bold uppercase block mb-2">Đến ngày giờ</label>
                <input type="datetime-local" id="toDate" class="input-premium py-2.5 text-sm w-full cursor-pointer" onchange="filterTable()" title="Chọn ngày giờ kết thúc">
            </div>
            
            <button type="button" onclick="clearDateFilter()" class="h-[42px] w-[42px] flex-shrink-0 bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/30 rounded-lg transition-colors flex items-center justify-center" title="Xóa bộ lọc ngày giờ (Hiển thị tất cả)">
                <i class="fas fa-filter-circle-xmark text-lg"></i>
            </button>
        </div>

    </div>
    <div class="overflow-x-auto rounded-xl border border-gray-800/60">
        <table class="w-full text-base text-left text-gray-400 border-collapse">
            <thead class="text-sm text-gray-300 uppercase bg-[#0d0d0d] border-b border-gray-800/80">
                <tr>
                    <th class="p-4 font-bold tracking-wider">Ngày mua</th>
                    <th class="p-4 font-bold tracking-wider">Phim</th>
                    <th class="p-4 font-bold tracking-wider text-center">Ghế</th>
                    <th class="p-4 font-bold tracking-wider text-right">Giá Vé</th>
                    <th class="p-4 font-bold tracking-wider text-center">Trạng Thái</th>
                    <th class="p-4 font-bold tracking-wider text-center">Chi tiết</th>
                </tr>
            </thead>
            <tbody id="historyBody"></tbody>
        </table>

        <div id="loadingHistory" class="hidden py-10 flex flex-col items-center justify-center">
            <i class="fas fa-circle-notch fa-spin text-4xl text-red-500 mb-4"></i>
            <p class="text-gray-500 text-sm mt-3">Đang tải dữ liệu từ máy chủ...</p>
        </div>
    </div>
</div>

<div id="customConfirmModal" class="fixed inset-0 bg-black/80 z-[10000] hidden items-center justify-center backdrop-blur-sm transition-opacity duration-300 opacity-0">
    <div id="confirmModalBox" class="bg-[#121212] border border-gray-600 rounded-2xl p-6 max-w-md w-full shadow-2xl transform scale-95 transition-all duration-300">
        <div class="text-center mb-5">
            <div id="modalIconContainer" class="w-20 h-20 bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-4 border border-gray-600">
                <i id="modalIcon" class="fas fa-question text-4xl text-gray-300"></i>
            </div>
            <h3 id="modalTitle" class="text-xl font-bold text-white mb-2 uppercase tracking-wider">Xác nhận</h3>
            <p id="modalDesc" class="text-sm text-gray-400 leading-relaxed"></p>
        </div>
        <div class="flex gap-3">
            <button type="button" onclick="closeConfirmModal()" class="flex-1 px-4 py-2.5 bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white rounded-xl text-sm font-medium transition flex justify-center items-center gap-2">
                <i class="fas fa-times"></i> Hủy bỏ
            </button>
            <button type="button" id="btnConfirmAction" class="flex-1 px-4 py-2.5 text-white rounded-xl text-sm font-bold shadow-lg transition flex justify-center items-center gap-2">
                <i class="fas fa-check"></i> Xác nhận
            </button>
        </div>
    </div>
</div>

<script>
    // ==========================================
    // HỆ THỐNG PREMIUM TOAST THÔNG BÁO TỪ BACKEND
    // ==========================================
    function triggerPremiumToast(type, title, message) {
        const container = document.getElementById('premium-toast-container');
        if (!container)
            return;

        const toast = document.createElement('div');
        toast.className = `toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ` +
                (type === 'success' ? 'bg-zinc-950/90 text-white toast-success-glow border-green-500/30' : 'bg-zinc-950/90 text-white toast-error-glow border-red-500/30');

        let iconHtml = type === 'success' ? '<i class="fas fa-check-circle text-base animate-pulse"></i>' : '<i class="fas fa-exclamation-triangle text-base animate-subtle-bounce"></i>';
        let titleColorClass = type === 'success' ? 'text-green-400' : 'text-red-400';
        let iconBgClass = type === 'success' ? 'bg-green-500/10 border-green-500/20 text-green-400' : 'bg-red-500/10 border-red-500/20 text-red-400';
        let barGradientClass = type === 'success' ? 'from-green-500 via-emerald-400 to-teal-500' : 'from-red-500 via-rose-500 to-amber-500';
        let subIconHtml = type === 'success' ? '<i class="fas fa-star text-[10px]"></i>' : '<i class="fas fa-shield-alt text-[10px]"></i>';

        // 🌟 ĐÃ SỬA: Thêm dấu \ trước ký tự $ để tránh xung đột bộ biên dịch EL của file .jsp
        toast.innerHTML = `
            <div class="flex-shrink-0 w-9 h-9 rounded-xl border flex items-center justify-center \${iconBgClass}">\${iconHtml}</div>
            <div class="flex-1 min-w-0 pt-0.5">
                <h4 class="text-xs font-black uppercase tracking-wider \${titleColorClass} mb-0.5 flex items-center gap-1.5">\${subIconHtml} \${title}</h4>
                <p class="text-xs text-zinc-300 font-medium leading-relaxed">\${message}</p>
            </div>
            <div class="flex-shrink-0 pl-1">
                <button onclick="dismissTargetToast(this.closest('.toast-item'))" class="w-6 h-6 rounded-lg bg-white/5 hover:bg-white/10 text-zinc-400 hover:text-white flex items-center justify-center transition-all duration-200 group" type="button">
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
        if (toast.dataset.timerId)
            clearTimeout(parseInt(toast.dataset.timerId, 10)); // 🌟 ĐÃ SỬA: Thêm cơ số 10 phòng vệ
        toast.classList.add('toast-leave-active');
        setTimeout(() => {
            toast.remove();
        }, 450);
    }

    // Khởi tạo lắng nghe Real-Time Validation ngay khi trang tải xong
    window.addEventListener('DOMContentLoaded', () => {
        const errorBridge = document.getElementById('backend-error-bridge');
        const successBridge = document.getElementById('backend-success-bridge');
        if (errorBridge && errorBridge.value.trim() !== "") {
            triggerPremiumToast('error', 'Lỗi Cập Nhật', errorBridge.value.trim());
        }
        if (successBridge && successBridge.value.trim() !== "") {
            triggerPremiumToast('success', 'Thành Công', successBridge.value.trim());
        }

        const formInfo = document.getElementById('formUpdateInfo');
        if (formInfo) {
            window.customerInputFields = {
                fullName: {
                    element: formInfo.querySelector('input[name="fullName"]'),
                    errorSpan: document.getElementById('error-fullName'),
                    validate: (val) => {
                        if (!val) return 'Vui lòng không để trống Họ và tên khách hàng.';
                        if (val.length < 2) return 'Họ và tên quá ngắn, vui lòng nhập ít nhất 2 ký tự.';
                        const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s]+$/;
                        if (!nameRegex.test(val)) return 'Họ và tên không hợp lệ. Vui lòng không nhập số hay ký tự đặc biệt.';
                        return '';
                    }
                },
                phone: {
                    element: formInfo.querySelector('input[name="phone"]'),
                    errorSpan: document.getElementById('error-phone'),
                    validate: (val) => {
                        if (!val) return 'Vui lòng không để trống số điện thoại.';
                        const phoneRegex = /^(0[3|5|7|8|9])+([0-9]{8})$/;
                        if (!phoneRegex.test(val)) return 'Số điện thoại không hợp lệ. Vui lòng nhập đúng 10 số (VD: 098..., 035...).';
                        return '';
                    }
                },
                email: {
                    element: formInfo.querySelector('input[name="email"]'),
                    errorSpan: document.getElementById('error-email'),
                    validate: (val) => {
                        if (!val) return 'Vui lòng không để trống địa chỉ Email.';
                        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                        if (!emailRegex.test(val)) return 'Địa chỉ Email không đúng định dạng (VD: contact@gmail.com).';
                        return '';
                    }
                }
            };

            function checkFieldRealTime(field) {
                const value = field.element.value.trim();
                const errorMsg = field.validate(value);

                if (errorMsg) {
                    if (field.errorSpan) {
                        field.errorSpan.innerText = errorMsg;
                        field.errorSpan.classList.remove('hidden');
                        field.errorSpan.classList.add('block');
                    }
                    field.element.classList.add('border-red-500/50', 'focus:border-red-500', 'bg-red-500/5');
                    field.element.classList.remove('border-zinc-800', 'focus:border-blue-500', 'border-green-500/30', 'bg-green-500/5');
                } else {
                    if (field.errorSpan) {
                        field.errorSpan.classList.add('hidden');
                        field.errorSpan.classList.remove('block');
                    }
                    // 🌟 ĐÃ NÂNG CẤP: Khi nhập đúng, đổi viền xanh ngọc nhẹ để tạo hiệu ứng thành công cao cấp
                    field.element.classList.remove('border-red-500/50', 'focus:border-red-500', 'bg-red-500/5', 'border-zinc-800');
                    field.element.classList.add('border-green-500/30', 'focus:border-blue-500', 'bg-green-500/5');
                }
            }

            Object.values(window.customerInputFields).forEach(field => {
                if (field.element) {
                    field.element.addEventListener('input', () => checkFieldRealTime(field));
                    field.element.addEventListener('blur', () => checkFieldRealTime(field));
                }
            });
        }
    });

    // ==========================================
    // HỆ THỐNG MODAL XÁC NHẬN ĐỘNG CHO 3 FORM
    // ==========================================
    let formToSubmitId = '';

    function openConfirmModal(actionType) {
        const modal = document.getElementById('customConfirmModal');
        const box = document.getElementById('confirmModalBox');

        const title = document.getElementById('modalTitle');
        const desc = document.getElementById('modalDesc');
        const icon = document.getElementById('modalIcon');
        const iconContainer = document.getElementById('modalIconContainer');
        const btnConfirm = document.getElementById('btnConfirmAction');

        iconContainer.className = "w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 border";
        box.className = "bg-[#121212] border rounded-2xl p-6 max-w-md w-full shadow-2xl transform scale-95 transition-all duration-300";
        btnConfirm.className = "flex-1 px-4 py-2.5 text-white rounded-xl text-sm font-bold shadow-lg transition flex justify-center items-center gap-2";

        if (actionType === 'info') {
            if (!validateUpdateInfoForm())
                return;
            formToSubmitId = 'formUpdateInfo';
            title.innerText = 'Lưu Thông Tin';
            desc.innerHTML = 'Bạn có chắc chắn muốn lưu lại các thay đổi về <strong class="text-blue-400">thông tin cá nhân</strong> của người dùng này không?';
            icon.className = 'fas fa-save text-4xl text-blue-500';
            iconContainer.classList.add('bg-blue-500/10', 'border-blue-500/30');
            box.classList.add('border-blue-500/50');
            btnConfirm.classList.add('bg-gradient-to-r', 'from-blue-600', 'to-blue-700', 'hover:from-blue-500', 'hover:to-blue-600', 'shadow-[0_0_15px_rgba(59,130,246,0.4)]');
            btnConfirm.innerHTML = '<i class="fas fa-save"></i> Đồng ý Lưu';

        } else if (actionType === 'status') {
            formToSubmitId = 'formUpdateStatus';
            title.innerText = 'Cảnh Báo Trạng Thái';
            desc.innerHTML = 'Bạn đang thay đổi <strong class="text-red-400">quyền truy cập</strong>. Việc khóa tài khoản sẽ lập tức chặn người dùng này đăng nhập vào hệ thống. Tiếp tục?';
            icon.className = 'fas fa-power-off text-4xl text-red-500 animate-pulse';
            iconContainer.classList.add('bg-red-500/10', 'border-red-500/30');
            box.classList.add('border-red-500/50');
            btnConfirm.classList.add('bg-gradient-to-r', 'from-red-600', 'to-red-700', 'hover:from-red-500', 'hover:to-red-600', 'shadow-[0_0_15px_rgba(220,38,38,0.4)]');
            btnConfirm.innerHTML = '<i class="fas fa-sync-alt"></i> Cập Nhật';

        } else if (actionType === 'reset') {
            formToSubmitId = 'formResetPass';
            title.innerText = 'Reset Mật Khẩu';
            desc.innerHTML = 'Hành động này sẽ đặt lại mật khẩu về mặc định <strong class="text-yellow-400">Pass@123</strong> và có thể khiến người dùng bị thoát phiên hiện tại. Xác nhận?';
            icon.className = 'fas fa-key text-4xl text-yellow-500';
            iconContainer.classList.add('bg-yellow-500/10', 'border-yellow-500/30');
            box.classList.add('border-yellow-500/50');
            btnConfirm.classList.add('bg-gradient-to-r', 'from-yellow-600', 'to-orange-600', 'hover:from-yellow-500', 'hover:to-orange-500', 'shadow-[0_0_15px_rgba(234,179,8,0.4)]');
            btnConfirm.innerHTML = '<i class="fas fa-redo-alt"></i> Đặt Lại';
        }

        modal.classList.remove('hidden');
        modal.classList.add('flex');
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            box.classList.remove('scale-95');
            box.classList.add('scale-100');
        }, 10);
    }

    function closeConfirmModal() {
        const modal = document.getElementById('customConfirmModal');
        const box = document.getElementById('confirmModalBox');

        modal.classList.add('opacity-0');
        box.classList.remove('scale-100');
        box.classList.add('scale-95');

        setTimeout(() => {
            modal.classList.add('hidden');
            modal.classList.remove('flex');
            formToSubmitId = '';
        }, 300);
    }

    document.getElementById('btnConfirmAction').addEventListener('click', function () {
        if (formToSubmitId !== '') {
            document.getElementById(formToSubmitId).submit();
        }
    });

    // ==========================================
    // CÁC HÀM CŨ (PASSWORD, HISTORY, FILTER)
    // ==========================================
    function togglePassword() {
        const input = document.getElementById('pwdInput');
        const icon = document.getElementById('pwdIcon');
        if (input.type === 'password') {
            input.type = 'text';
            input.classList.remove('text-xl', 'tracking-[0.25em]');
            input.classList.add('text-base');
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            input.classList.remove('text-base');
            input.classList.add('text-xl', 'tracking-[0.25em]');
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    let rawData = [];
    let isFetched = false;

    const normalizeData = (dataArray) => {
        return dataArray.map(obj => {
            return Object.keys(obj).reduce((acc, key) => {
                acc[key.toLowerCase()] = obj[key];
                return acc;
            }, {});
        });
    };

    function toggleHistory(userId) {
        const section = document.getElementById('historySection');
        const btnText = document.getElementById('textHistoryBtn');
        const spinner = document.getElementById('loadingHistory');
        const tbody = document.getElementById('historyBody');

        if (section.classList.contains('hidden')) {
            section.classList.remove('hidden');
            btnText.innerText = 'Ẩn lịch sử vé đã mua';

            if (!isFetched) {
                spinner.classList.remove('hidden');
                tbody.innerHTML = '';

                // Thêm tiền tố \ để tránh hiểu nhầm EL trong JSP
                // 🌟 ĐÃ SỬA: Bỏ dấu \ để JSP thực hiện đổ dữ liệu context path thật (Ví dụ: /ten_du_an/admin/...)
        const fetchUrl = "${pageContext.request.contextPath}/admin/customers/" + userId + "/booking-history";

                fetch(fetchUrl)
                        .then(res => {
                            if (!res.ok)
                                throw new Error("HTTP error: " + res.status);
                            return res.text();
                        })
                        .then(textData => {
                            try {
                                const data = JSON.parse(textData);
                                spinner.classList.add('hidden');
                                rawData = normalizeData(data);
                                isFetched = true;
                                renderTable(rawData);
                            } catch (parseError) {
                                throw new Error("Lỗi rách chuỗi JSON");
                            }
                        })
                        .catch(err => {
                            spinner.classList.add('hidden');
                            triggerPremiumToast('error', 'Lỗi Tải Dữ Liệu', 'Không thể tải lịch sử giao dịch. Vui lòng F5 lại trang.');
                        });
            }
        } else {
            section.classList.add('hidden');
            btnText.innerText = 'Xem lịch sử vé đã mua';
        }
    }

   function renderTable(dataArray) {
        const tbody = document.getElementById('historyBody');
        if (!dataArray || dataArray.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="p-8 text-center text-zinc-500 text-sm font-medium">Không tìm thấy vé nào phù hợp với bộ lọc.</td></tr>';
            return;
        }

        let html = '';
        dataArray.forEach(item => {
            // Chuyển chuỗi bookingdate thành định dạng VN
            let bDate = 'N/A';
            if (item.bookingdate) {
                const bDateObj = new Date(item.bookingdate.replace(' ', 'T'));
                bDate = bDateObj.toLocaleString('vi-VN', {dateStyle: 'short', timeStyle: 'short'});
            }

            const mTitle = item.movietitle || 'N/A';
            const sName = item.seatname || 'N/A';
            const tPrice = item.ticketprice || 0;
            const tStatus = item.ticketstatus || '';
            const stId = item.id_showtime;
            const currentSeatId = item.id_seat;

            const allSeatsInSameShowtime = dataArray.filter(ticket => ticket.id_showtime === stId).map(ticket => ticket.id_seat);
            const combinedSeatIds = [...new Set([currentSeatId, ...allSeatsInSameShowtime])].join(',');

            // Xác định UI Trạng Thái Vé
            let statusUi = '';
            if (tStatus.toUpperCase() === 'SOLD') {
                statusUi = '<span class="px-2.5 py-1 rounded bg-green-500/10 text-green-400 border border-green-500/20 text-xs font-bold uppercase tracking-wider">Đã thanh toán</span>';
            } else if (tStatus.toUpperCase() === 'REFUNDED' || tStatus.toUpperCase() === 'CANCELLED') {
                statusUi = '<span class="px-2.5 py-1 rounded bg-red-500/10 text-red-400 border border-red-500/20 text-xs font-bold uppercase tracking-wider">Đã hoàn tiền</span>';
            } else {
                statusUi = '<span class="px-2.5 py-1 rounded bg-zinc-500/10 text-zinc-400 border border-zinc-500/20 text-xs font-bold uppercase tracking-wider">' + tStatus + '</span>';
            }

            const linkDetail = '${pageContext.request.contextPath}/admin/showtimes/edit/' + stId + '?autoSelectSeat=' + combinedSeatIds;

            html += '<tr class="border-b border-zinc-800/60 hover:bg-zinc-800/30 transition-colors">' +
                    '<td class="p-4 font-mono text-sm text-zinc-300">' + bDate + '</td>' +
                    '<td class="p-4 font-bold text-sm text-zinc-200">' + mTitle + '</td>' +
                    '<td class="p-4 text-center font-black text-sm text-blue-400 tracking-wider">' + sName + '</td>' +
                    '<td class="p-4 text-right font-medium text-sm text-amber-500 font-mono">' + Number(tPrice).toLocaleString('vi-VN') + ' đ</td>' +
                    '<td class="p-4 text-center">' + statusUi + '</td>' +
                    '<td class="p-4 text-center">' +
                    '<a href="' + linkDetail + '" target="_blank" class="w-8 h-8 inline-flex items-center justify-center rounded-lg bg-blue-500/10 text-blue-400 hover:bg-blue-500 hover:text-white transition-all shadow-sm"><i class="fas fa-eye text-xs"></i></a>' +
                    '</td></tr>';
        });
        tbody.innerHTML = html;
    }

    function filterTable() {
        const movieKw = document.getElementById('searchMovie') ? document.getElementById('searchMovie').value.toLowerCase() : '';
        
        // ĐOẠN BỔ SUNG: Lấy dữ liệu từ ô lọc ghế
        const seatKw = document.getElementById('searchSeat') ? document.getElementById('searchSeat').value.toLowerCase().trim() : '';
        
        const ticketType = document.getElementById('searchType') ? document.getElementById('searchType').value : 'ALL';
        const fromDateVal = document.getElementById('fromDate') ? document.getElementById('fromDate').value : '';
        const toDateVal = document.getElementById('toDate') ? document.getElementById('toDate').value : '';

        const now = new Date();

        const filtered = rawData.filter(item => {
            // 1. Lọc theo Tên phim
            const matchMovie = (item.movietitle || '').toLowerCase().includes(movieKw);

            // ĐOẠN BỔ SUNG: Lọc theo Số ghế
            const matchSeat = (item.seatname || '').toLowerCase().includes(seatKw);

            // 2. Lọc theo khoảng thời gian mua vé
            let matchDate = true;
            if (fromDateVal || toDateVal) {
                const bDateStr = item.bookingdate ? item.bookingdate.replace(' ', 'T') : '';
                const bDateMs = new Date(bDateStr).getTime();
                
                if (fromDateVal && bDateMs < new Date(fromDateVal).getTime()) matchDate = false;
                if (toDateVal && bDateMs > new Date(toDateVal).getTime()) matchDate = false;
            }

            // 3. Lọc theo Phân loại vé (Sắp xem, Đã xem, Đã hoàn tiền)
            let matchType = true;
            const tStatus = (item.ticketstatus || '').toUpperCase();
            
            // Lấy thời gian chiếu thực tế của vé đó ghép lại
            const showDateTimeStr = (item.showdate && item.starttime) ? (item.showdate + 'T' + item.starttime) : '';
            const showTimeMs = showDateTimeStr ? new Date(showDateTimeStr).getTime() : 0;

            if (ticketType === 'UPCOMING') {
                // Sắp xem: Vé Đã thanh toán (Sold) VÀ Giờ chiếu vẫn còn nằm trong tương lai
                if (tStatus !== 'SOLD' || showTimeMs <= now.getTime()) matchType = false;
            } else if (ticketType === 'PAST') {
                // Đã xem: Vé Đã thanh toán (Sold) VÀ Giờ chiếu đã trôi qua
                if (tStatus !== 'SOLD' || showTimeMs > now.getTime()) matchType = false;
            } else if (ticketType === 'REFUNDED') {
                // Đã hoàn: Trạng thái vé dưới DB là Refunded hoặc Cancelled
                if (tStatus !== 'REFUNDED' && tStatus !== 'CANCELLED') matchType = false;
            }

            // ĐOẠN BỔ SUNG: Thêm biến matchSeat vào kết quả lọc
            return matchMovie && matchSeat && matchDate && matchType;
        });
        renderTable(filtered);
    }

    // Hàm gắn vào nút xóa bộ lọc ngày (GIỮ NGUYÊN)
    function clearDateFilter() {
        if (document.getElementById('fromDate')) document.getElementById('fromDate').value = '';
        if (document.getElementById('toDate')) document.getElementById('toDate').value = '';
        filterTable(); // Chạy lại hàm lọc để đổ về tất cả dữ liệu
    }
    // ==========================================
    // HÀM KIỂM TRA RÀNG BUỘC DỮ LIỆU (VALIDATION) - ĐÃ ĐỒNG BỘ UI HOÀN CHỈNH
    // ==========================================
    function validateUpdateInfoForm() {
        let isAllValid = true;
        let firstErrorMsg = '';

        if (window.customerInputFields) {
            Object.values(window.customerInputFields).forEach(field => {
                const value = field.element.value.trim();
                const errorMsg = field.validate(value);
                
                if (errorMsg) {
                    isAllValid = false;
                    if (!firstErrorMsg) firstErrorMsg = errorMsg;

                    if (field.errorSpan) {
                        field.errorSpan.innerText = errorMsg;
                        field.errorSpan.classList.remove('hidden');
                        field.errorSpan.classList.add('block');
                    }
                    field.element.classList.add('border-red-500/50', 'focus:border-red-500', 'bg-red-500/5');
                    field.element.classList.remove('border-zinc-800', 'focus:border-blue-500', 'border-green-500/30', 'bg-green-500/5');
                }
            });
        }

        if (!isAllValid) {
            triggerPremiumToast('error', 'Lỗi Nhập Liệu', firstErrorMsg);
            return false;
        }

        return true;
    }
    function handleFileSelect(input) {
        if (input.files && input.files[0]) {
            const fileName = input.files[0].name;
            const customPath = '/assets/images/avatar/' + fileName;

            const avatarInput = document.getElementById('avatar');
            avatarInput.value = customPath;

            const container = document.getElementById('avatar-preview-container');
            const img = document.getElementById('avatar-preview-img');
            const icon = document.getElementById('avatar-error-icon');

            container.classList.remove('hidden');
            container.classList.add('flex');

            // Dùng URL.createObjectURL để mô phỏng ảnh local lên trình duyệt cực nhanh
            img.src = URL.createObjectURL(input.files[0]);
            img.classList.remove('hidden');
            icon.classList.add('hidden');
        }
    }

    // Xử lý 3 trường hợp khi người dùng copy/paste dán đường link
    function previewAvatar() {
        const avatarUrl = document.getElementById('avatar').value.trim();
        // Lấy tên người dùng hiện tại để làm ảnh chữ cái, nếu chưa có thì gán là "User"
        // LƯU Ý: Đảm bảo ô input Họ Tên của bạn có id="fullName"
        const fullName = document.getElementById('fullName') ? document.getElementById('fullName').value.trim() : 'User';
        
        const img = document.getElementById('avatar-preview-img');
        const icon = document.getElementById('avatar-error-icon');

        img.classList.remove('hidden');
        icon.classList.add('hidden');

        if (avatarUrl !== '') {
            // TH1: Nhập link mạng -> Gán thẳng link
            if (avatarUrl.startsWith('http')) {
                img.src = avatarUrl;
            }
            // TH2: Bỏ qua không load lại nếu đó là đường dẫn ảo nội bộ tạo bởi handleFileSelect
            else if (!avatarUrl.startsWith('/assets/')) {
                img.src = '${pageContext.request.contextPath}/assets/images/avatar/' + avatarUrl;
            }
        } else {
            // TH3: Để trống ô link -> Tự động gọi API ảnh chữ cái theo tên
            img.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(fullName) + '&background=random';
        }
    }
</script>