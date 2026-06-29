<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thêm Khách Hàng Mới</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

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

            @keyframes shake-error {
                0%, 100% {
                    transform: translateX(0);
                }
                20%, 60% {
                    transform: translateX(-4px);
                }
                40%, 80% {
                    transform: translateX(4px);
                }
            }
            .shake-animation {
                animation: shake-error 0.4s ease-in-out;
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
            @keyframes glowPulseBlue {
                0%, 100% {
                    border-color: rgba(59, 130, 246, 0.35);
                    box-shadow: 0 10px 30px -5px rgba(59, 130, 246, 0.15), 0 0 15px rgba(59, 130, 246, 0.05);
                }
                50% {
                    border-color: rgba(59, 130, 246, 0.8);
                    box-shadow: 0 15px 35px -2px rgba(59, 130, 246, 0.35), 0 0 25px rgba(59, 130, 246, 0.15);
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
            .toast-info-glow {
                animation: glowPulseBlue 3s infinite ease-in-out;
            }
            .toast-progress-countdown {
                animation: toastTimeline 5s linear forwards;
            }
            .animate-subtle-bounce {
                animation: subtleBounce 2.5s ease-in-out infinite;
            }
        </style>
    </head>
    <body class="bg-[#121212] text-zinc-100 min-h-screen"> 

        <c:if test="${not empty errorMessage}">
            <input type="hidden" id="backend-error-bridge" value="<c:out value='${errorMessage}'/>">
            <c:remove var="errorMessage" scope="session"/>
            <c:remove var="errorMessage" scope="request"/>
        </c:if>

        <c:if test="${not empty successMessage}">
            <input type="hidden" id="backend-success-bridge" value="<c:out value='${successMessage}'/>">
            <c:remove var="successMessage" scope="session"/>
            <c:remove var="successMessage" scope="request"/>
        </c:if>

        <div id="premium-toast-container" class="fixed bottom-6 right-6 flex flex-col gap-3 z-[99999] max-w-sm w-full pointer-events-none"></div>

        <div class="container mx-auto px-4 py-8">
            <div class="mb-5">
                <a href="${pageContext.request.contextPath}/admin/customers" class="text-gray-400 hover:text-red-500 font-bold text-sm transition-colors duration-200 inline-flex items-center group">
                    <i class="fas fa-arrow-left mr-2 transform group-hover:-translate-x-1 transition-transform"></i> Quay lại danh sách
                </a>
            </div>

            <div class="mb-8 border-b border-zinc-800 pb-5">
                <h1 class="text-3xl font-bold tracking-wide text-transparent bg-clip-text bg-gradient-to-r from-zinc-50 to-zinc-400 uppercase">
                    🛡️ THÊM KHÁCH HÀNG MỚI
                </h1>
                <p class="text-zinc-400 text-sm mt-2">Điền đầy đủ thông tin để khởi tạo tài khoản với giao diện an toàn 100%.</p>
            </div>

            <form id="customerAddForm" action="${pageContext.request.contextPath}/admin/customers/add" method="POST" accept-charset="UTF-8" enctype="multipart/form-data">

                <input type="hidden" name="id_User" value="0" />
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                </c:if>

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                    <div class="lg:col-span-4 flex flex-col gap-6">
                        <div class="glass-card border border-gray-800/80 rounded-2xl p-6 shadow-xl relative bg-gradient-to-br from-[#111] to-[#1a1500]">
                            <h3 class="text-base font-black text-gray-300 uppercase tracking-wide mb-5 flex items-center gap-2 border-b border-gray-800/60 pb-3">
                                <i class="fas fa-key text-yellow-500"></i> Thông tin đăng nhập
                            </h3>

                            <div class="space-y-5">
                                <div>
                                    <label class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-2 block">Tên đăng nhập <span class="text-red-500">*</span></label>
                                    <input type="text" id="username" name="username" class="input-premium border-gray-800 font-mono" placeholder="Nhập username..."/>
                                    <span id="error-username" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                                </div>

                                <div>
                                    <label class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-2 block">Mật khẩu khởi tạo <span class="text-red-500">*</span></label>
                                    <div class="relative h-12">
                                        <input type="password" id="password" name="password" class="input-premium border-gray-800 font-mono pr-10 tracking-[0.2em] h-full py-0" placeholder="Nhập mật khẩu..." oninput="checkPasswordStrength()"/>
                                        <button type="button" onclick="togglePasswordVisibility()" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white transition">
                                            <i id="eye-icon" class="fas fa-eye text-lg"></i>
                                        </button>
                                    </div>
                                    <div class="h-1 w-full bg-gray-800 rounded-full mt-2 overflow-hidden hidden" id="pwd-strength-container">
                                        <div id="pwd-strength-bar" class="h-full w-0 transition-all duration-300 bg-red-500"></div>
                                    </div>
                                    <span id="pwd-strength-text" class="text-[11px] mt-1 hidden"></span>
                                    <span id="error-password" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                                </div>

                                <div>
                                    <label class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-2 block">Trạng thái tài khoản</label>
                                    <select name="status" class="input-premium border-gray-800 cursor-pointer">
                                        <option value="Active" selected>Hoạt động (Active)</option>
                                        <option value="Locked">Khóa (Locked)</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="lg:col-span-8 flex flex-col gap-6">
                        <div class="glass-card border border-gray-800/80 rounded-2xl p-6 shadow-xl relative">
                            <h3 class="text-xl font-black text-white uppercase tracking-wide mb-5 flex items-center gap-2 border-b border-gray-800/60 pb-3">
                                <i class="fas fa-address-card text-blue-500"></i> Hồ sơ thông tin cá nhân
                            </h3>

                            <div class="space-y-5">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div class="md:col-span-2">
                                        <label class="text-xs text-zinc-400 block mb-2 font-bold uppercase tracking-wider">Họ và tên khách hàng <span class="text-red-500">*</span></label>
                                        <input type="text" id="fullName" name="fullName" class="input-premium border-gray-800" placeholder="Nguyễn Văn A..."/>
                                        <span id="error-fullName" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                                    </div>

                                    <div>
                                        <label class="text-xs text-zinc-400 block mb-2 font-bold uppercase tracking-wider">Địa chỉ Email <span class="text-red-500">*</span></label>
                                        <input type="email" id="email" name="email" class="input-premium border-gray-800" placeholder="example@gmail.com"/>
                                        <span id="error-email" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                                    </div>

                                    <div>
                                        <label class="text-xs text-zinc-400 block mb-2 font-bold uppercase tracking-wider">Số điện thoại <span class="text-red-500">*</span></label>
                                        <input type="text" id="phone" name="phone" class="input-premium border-gray-800" placeholder="VD: 0987654321"/>
                                        <span id="error-phone" class="text-[11px] text-red-400 mt-1 hidden transition-all duration-200"></span>
                                    </div>

                                    <div class="md:col-span-2">
                                        <label class="text-xs text-zinc-400 block mb-2 font-bold uppercase tracking-wider">Ảnh đại diện (Nhập URL hoặc chọn file từ máy)</label>

                                        <%-- Khung nhập link và nút tải ảnh --%>
                                        <div class="grid grid-cols-1 sm:grid-cols-4 gap-3">
                                            <div class="sm:col-span-3">
                                                <input type="text" id="avatar" name="avatar" class="input-premium border-gray-800" placeholder="https://... hoặc đường dẫn tự động khi chọn file" oninput="previewAvatar()"/>
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

                                        <%-- Khung hiển thị ảnh Preview (Đã loại bỏ class 'hidden' để luôn hiện) --%>
                                        <div class="mt-3 flex items-center gap-3 transition-all duration-300" id="avatar-preview-container">
                                            <div class="w-12 h-12 rounded-full border border-gray-600 shadow-lg overflow-hidden flex-shrink-0 bg-gray-800 flex items-center justify-center">
                                                <img id="avatar-preview-img" 
                                                     src="${previewSrc}" 
                                                     alt="Preview" 
                                                     class="w-full h-full object-cover" 
                                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar/default-avatar.png';">
                                                <i id="avatar-error-icon" class="fas fa-image text-gray-500 hidden"></i>
                                            </div>
                                            <span class="text-xs text-gray-400 italic" id="avatar-preview-text">Đang hiển thị ảnh xem trước...</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex justify-end gap-3 pt-5 mt-5 border-t border-gray-800/60">
                                    <button type="button" onclick="resetFormFields()" class="px-6 py-3 bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white rounded-xl text-sm font-medium transition flex items-center gap-2">
                                        <i class="fas fa-undo"></i> Làm mới
                                    </button>
                                    <button type="button" onclick="validateForm()" class="px-8 py-3 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-500 hover:to-blue-600 text-white font-bold rounded-xl text-base shadow-[0_4px_20px_rgba(59,130,246,0.3)] transition-all flex items-center gap-2">
                                        <i class="fas fa-plus-circle"></i> Khởi Tạo Khách Hàng
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <div id="customConfirmModal" class="fixed inset-0 bg-black/80 z-[10000] hidden items-center justify-center backdrop-blur-sm transition-opacity duration-300 opacity-0">
            <div id="confirmModalBox" class="bg-[#121212] border border-blue-500/50 rounded-2xl p-6 max-w-md w-full shadow-2xl transform scale-95 transition-all duration-300">
                <div class="text-center mb-5">
                    <div class="w-20 h-20 bg-blue-500/10 border-blue-500/30 rounded-full flex items-center justify-center mx-auto mb-4 border">
                        <i class="fas fa-user-plus text-4xl text-blue-500 animate-subtle-bounce"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-2 uppercase tracking-wider">Xác nhận Khởi Tạo</h3>
                    <p class="text-sm text-gray-400 leading-relaxed">Bạn có chắc chắn mọi thông tin hợp lệ và muốn <strong class="text-blue-400">tạo mới tài khoản</strong> khách hàng này vào hệ thống không?</p>
                </div>
                <div class="flex gap-3">
                    <button type="button" id="btn-cancel-submit" onclick="closeConfirmModal()" class="flex-1 px-4 py-2.5 bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white rounded-xl text-sm font-medium transition flex justify-center items-center gap-2">
                        <i class="fas fa-times"></i> Hủy bỏ
                    </button>
                    <button type="button" id="btn-confirm-submit" onclick="submitFinalForm()" class="flex-1 px-4 py-2.5 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-500 hover:to-blue-600 shadow-[0_0_15px_rgba(59,130,246,0.4)] text-white rounded-xl text-sm font-bold transition flex justify-center items-center gap-2">
                        <i id="btn-confirm-icon" class="fas fa-check"></i> <span id="btn-confirm-text">Xác nhận Tạo</span>
                    </button>
                </div>
            </div>
        </div>

        <script>
            // 1. CÁC HÀM XỬ LÝ TOAST CAO CẤP
            function triggerPremiumToast(type, title, message) {
                const container = document.getElementById('premium-toast-container');
                if (!container)
                    return;

                const toast = document.createElement('div');
                let wrapperClass, iconHtml, titleColorClass, iconBgClass, barGradientClass, subIconHtml;

                if (type === 'success') {
                    wrapperClass = 'bg-zinc-950/90 text-white toast-success-glow border-green-500/30';
                    iconHtml = '<i class="fas fa-check-circle text-base animate-pulse"></i>';
                    titleColorClass = 'text-green-400';
                    iconBgClass = 'bg-green-500/10 border-green-500/20 text-green-400';
                    barGradientClass = 'from-green-500 via-emerald-400 to-teal-500';
                    subIconHtml = '<i class="fas fa-star text-[10px]"></i>';
                } else if (type === 'info') {
                    wrapperClass = 'bg-zinc-950/90 text-white toast-info-glow border-blue-500/30';
                    iconHtml = '<i class="fas fa-spinner fa-spin text-base"></i>';
                    titleColorClass = 'text-blue-400';
                    iconBgClass = 'bg-blue-500/10 border-blue-500/20 text-blue-400';
                    barGradientClass = 'from-blue-500 via-cyan-400 to-indigo-500';
                    subIconHtml = '<i class="fas fa-info-circle text-[10px]"></i>';
                } else {
                    wrapperClass = 'bg-zinc-950/90 text-white toast-error-glow border-red-500/30';
                    iconHtml = '<i class="fas fa-exclamation-triangle text-base animate-subtle-bounce"></i>';
                    titleColorClass = 'text-red-400';
                    iconBgClass = 'bg-red-500/10 border-red-500/20 text-red-400';
                    barGradientClass = 'from-red-500 via-rose-500 to-amber-500';
                    subIconHtml = '<i class="fas fa-shield-alt text-[10px]"></i>';
                }

                toast.className = 'toast-item pointer-events-auto relative overflow-hidden backdrop-blur-xl rounded-2xl border p-4 flex items-start gap-3.5 transition-all duration-300 transform shadow-2xl ' + wrapperClass;
                toast.innerHTML =
                        '<div class="flex-shrink-0 w-9 h-9 rounded-xl border flex items-center justify-center ' + iconBgClass + '">' + iconHtml + '</div>' +
                        '<div class="flex-1 min-w-0 pt-0.5">' +
                        '<h4 class="text-xs font-black uppercase tracking-wider ' + titleColorClass + ' mb-0.5 flex items-center gap-1.5">' + subIconHtml + ' ' + title + '</h4>' +
                        '<p class="text-xs text-zinc-300 font-medium leading-relaxed">' + message + '</p>' +
                        '</div>' +
                        '<div class="flex-shrink-0 pl-1">' +
                        '<button onclick="dismissTargetToast(this.closest(\'.toast-item\'))" class="w-6 h-6 rounded-lg bg-white/5 hover:bg-white/10 text-zinc-400 hover:text-white flex items-center justify-center transition-all duration-200 group" type="button">' +
                        '<i class="fas fa-times text-[10px] transform group-hover:rotate-90 transition-transform duration-300"></i>' +
                        '</button>' +
                        '</div>' +
                        '<div class="absolute bottom-0 left-0 h-[3px] bg-gradient-to-r ' + barGradientClass + ' toast-progress-countdown"></div>';

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
                    clearTimeout(parseInt(toast.dataset.timerId, 10));
                toast.classList.add('toast-leave-active');
                setTimeout(() => {
                    toast.remove();
                }, 450);
            }

            document.addEventListener("DOMContentLoaded", function () {
                // Lấy thông báo từ DOM một cách an toàn
                setTimeout(() => {
                    const errorBridge = document.getElementById('backend-error-bridge');
                    const successBridge = document.getElementById('backend-success-bridge');

                    if (errorBridge && errorBridge.value.trim() !== "") {
                        triggerPremiumToast('error', 'Lỗi Từ Hệ Thống', errorBridge.value.trim());
                    }

                    if (successBridge && successBridge.value.trim() !== "") {
                        triggerPremiumToast('success', 'Thành Công', successBridge.value.trim());
                    }
                }, 100);
            });

            // 2. LOGIC BỔ SUNG: AVATAR PREVIEW & PASSWORD STRENGTH
            // Hàm xử lý trích xuất tên file và cập nhật đường dẫn rút gọn kèm preview ảnh
            // CẬP NHẬT 1: Xử lý hiển thị ngay lập tức khi tải file từ máy tính
            function handleFileSelect(input) {
                if (input.files && input.files[0]) {
                    const fileName = input.files[0].name;

                    // SỬA Ở ĐÂY: Chỉ lấy tên file, không nối thêm '/assets/images/avatar/'
                    const avatarInput = document.getElementById('avatar');
                    avatarInput.value = fileName;

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

// CẬP NHẬT 2: Xử lý 3 trường hợp khi người dùng copy/paste dán đường link
            function previewAvatar() {
                const avatarUrl = document.getElementById('avatar').value.trim();
                // Lấy tên người dùng hiện tại để làm ảnh chữ cái, nếu chưa có thì gán là "User"
                const fullName = document.getElementById('fullName').value.trim() || 'User';
                const img = document.getElementById('avatar-preview-img');
                const icon = document.getElementById('avatar-error-icon');

                img.classList.remove('hidden');
                icon.classList.add('hidden');

                if (avatarUrl !== '') {
                    // TH1: Nhập link mạng -> Gán thẳng link
                    if (avatarUrl.startsWith('http')) {
                        img.src = avatarUrl;
                    }
                    // Bỏ qua không load lại nếu đó là đường dẫn ảo nội bộ tạo bởi handleFileSelect
                    else if (!avatarUrl.startsWith('/assets/')) {
                        img.src = '${pageContext.request.contextPath}/assets/images/avatar/' + avatarUrl;
                    }
                } else {
                    // TH2: Để trống ô link -> Tự động gọi API ảnh chữ cái theo tên
                    img.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(fullName) + '&background=random';
                }
            }

// CẬP NHẬT 3: Tự động đổi hình chữ cái (A, B, C...) mỗi khi người dùng gõ phím vào ô Họ Tên
            document.addEventListener("DOMContentLoaded", function () {
                const fullNameInput = document.getElementById('fullName');
                if (fullNameInput) {
                    fullNameInput.addEventListener('input', function () {
                        const avatarUrl = document.getElementById('avatar').value.trim();
                        // Chỉ cập nhật ảnh chữ cái nếu khách chưa tải ảnh nào lên
                        if (avatarUrl === '') {
                            previewAvatar();
                        }
                    });
                }
            });

            function checkPasswordStrength() {
                const pwd = document.getElementById('password').value;
                const container = document.getElementById('pwd-strength-container');
                const bar = document.getElementById('pwd-strength-bar');
                const text = document.getElementById('pwd-strength-text');

                if (pwd.length === 0) {
                    container.classList.add('hidden');
                    text.classList.add('hidden');
                    return;
                }

                container.classList.remove('hidden');
                text.classList.remove('hidden');
                text.classList.add('block');

                let strength = 0;
                if (pwd.length >= 6)
                    strength += 1;
                if (pwd.match(/(?=.*[0-9])/))
                    strength += 1;
                if (pwd.match(/(?=.*[A-Z])/))
                    strength += 1;
                if (pwd.match(/(?=.*[!@#$%^&*])/))
                    strength += 1;

                bar.className = 'h-full transition-all duration-300 ';

                if (strength <= 1) {
                    bar.classList.add('w-1/3', 'bg-red-500');
                    text.className = 'text-[11px] mt-1 text-red-400';
                    text.innerText = 'Độ mạnh: Yếu';
                } else if (strength === 2 || strength === 3) {
                    bar.classList.add('w-2/3', 'bg-yellow-500');
                    text.className = 'text-[11px] mt-1 text-yellow-400';
                    text.innerText = 'Độ mạnh: Khá';
                } else {
                    bar.classList.add('w-full', 'bg-green-500');
                    text.className = 'text-[11px] mt-1 text-green-400';
                    text.innerText = 'Độ mạnh: Tuyệt đối an toàn';
                }
            }

            // 3. LOGIC KIỂM TRA (ĐÃ NÂNG CẤP REGEX)
            function clearErrors() {
                document.querySelectorAll('span[id^="error-"]').forEach(el => {
                    el.classList.add('hidden');
                    el.classList.remove('block');
                });
                document.querySelectorAll('.input-premium').forEach(el => {
                    el.classList.remove('border-red-500/50', 'bg-red-500/5', 'shake-animation');
                    el.classList.add('border-gray-800');
                });
            }

            function showError(inputEl, errorSpanId, message) {
                const span = document.getElementById(errorSpanId);
                span.textContent = message;
                span.classList.remove('hidden');
                span.classList.add('block');
                inputEl.classList.remove('border-gray-800');
                inputEl.classList.add('border-red-500/50', 'bg-red-500/5', 'shake-animation');
                setTimeout(() => {
                    inputEl.classList.remove('shake-animation');
                }, 400);
            }

            function validateForm() {
                let isValid = true;
                clearErrors();

                const username = document.getElementById('username');
                const password = document.getElementById('password');
                const fullName = document.getElementById('fullName');
                const email = document.getElementById('email');
                const phone = document.getElementById('phone');

                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                const phoneRegex = /^(03|05|07|08|09)\d{8}$/;

                if (username.value.trim() === '' || username.value.includes(' ')) {
                    showError(username, 'error-username', 'Tên đăng nhập không được để trống và không chứa dấu cách.');
                    isValid = false;
                }

                if (password.value.trim() === '' || password.value.length < 6) {
                    showError(password, 'error-password', 'Mật khẩu phải chứa ít nhất 6 ký tự.');
                    isValid = false;
                }

                if (fullName.value.trim() === '') {
                    showError(fullName, 'error-fullName', 'Họ tên không được để trống.');
                    isValid = false;
                }

                if (!emailRegex.test(email.value.trim())) {
                    showError(email, 'error-email', 'Vui lòng nhập đúng định dạng Email (VD: abc@domain.com).');
                    isValid = false;
                }

                if (!phoneRegex.test(phone.value.trim())) {
                    showError(phone, 'error-phone', 'Số điện thoại không hợp lệ. Phải là 10 số và bắt đầu bằng 03, 05, 07, 08 hoặc 09.');
                    isValid = false;
                }

                if (isValid) {
                    openConfirmModal();
                } else {
                    triggerPremiumToast('error', 'Thiếu Thông Tin', 'Vui lòng kiểm tra lại các trường dữ liệu bị đỏ.');
                    const firstError = document.querySelector('.bg-red-500\\/5');
                    if (firstError)
                        firstError.focus();
                }
            }

            // 4. XỬ LÝ NÚT VÀ GIAO DIỆN PHỤ
            function openConfirmModal() {
                const modal = document.getElementById('customConfirmModal');
                const box = document.getElementById('confirmModalBox');
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
                }, 300);
            }

            function submitFinalForm() {
                const confirmBtn = document.getElementById('btn-confirm-submit');
                const cancelBtn = document.getElementById('btn-cancel-submit');
                const confirmIcon = document.getElementById('btn-confirm-icon');
                const confirmText = document.getElementById('btn-confirm-text');

                confirmBtn.disabled = true;
                cancelBtn.disabled = true;
                confirmBtn.classList.add('opacity-70', 'cursor-not-allowed');
                cancelBtn.classList.add('opacity-50', 'cursor-not-allowed');
                confirmIcon.className = 'fas fa-spinner fa-spin';
                confirmText.innerText = 'Đang xử lý...';

                triggerPremiumToast('info', 'Đang xử lý', 'Hệ thống đang tiến hành tạo hồ sơ khách hàng...');

                setTimeout(() => {
                    document.getElementById('customerAddForm').submit();
                }, 500);
            }

            function togglePasswordVisibility() {
                const passwordInput = document.getElementById('password');
                const eyeIcon = document.getElementById('eye-icon');
                if (passwordInput.type === "password") {
                    passwordInput.type = "text";
                    passwordInput.classList.remove('tracking-[0.2em]');
                    eyeIcon.classList.remove('fa-eye');
                    eyeIcon.classList.add('fa-eye-slash', 'text-yellow-500');
                } else {
                    passwordInput.type = "password";
                    passwordInput.classList.add('tracking-[0.2em]');
                    eyeIcon.classList.remove('fa-eye-slash', 'text-yellow-500');
                    eyeIcon.classList.add('fa-eye');
                }
            }

            function resetFormFields() {
                document.getElementById('customerAddForm').reset();
                clearErrors();

                document.getElementById('avatar-preview-container').classList.add('hidden');
                document.getElementById('pwd-strength-container').classList.add('hidden');
                document.getElementById('pwd-strength-text').classList.add('hidden');

                const pwd = document.getElementById('password');
                pwd.type = "password";
                pwd.classList.add('tracking-[0.2em]');
                document.getElementById('eye-icon').className = 'fas fa-eye text-lg';
            }

        </script>
    </body>
</html>