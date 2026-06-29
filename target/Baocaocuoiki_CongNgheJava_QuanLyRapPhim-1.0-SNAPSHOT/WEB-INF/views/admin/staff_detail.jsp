<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Nhân Sự</title>
    <style>
        .glass-card { background: rgba(22, 22, 22, 0.85); backdrop-filter: blur(16px); }
        .input-premium {
            background-color: #0d0d0d; border: 1px solid #262626; color: #f3f4f6;
            border-radius: 0.75rem; padding: 0.625rem 1rem; width: 100%; transition: all 0.3s ease;
        }
        .input-premium:focus:not(:read-only) { border-color: #3b82f6; outline: none; box-shadow: 0 0 12px rgba(59, 130, 246, 0.3); }
        .input-premium:read-only { background-color: #1a1a1a; color: #6b7280; cursor: not-allowed; border-color: #333; }
        .btn-premium { background: linear-gradient(135deg, #2563eb, #4f46e5); color: white; transition: all 0.3s ease; }
        .btn-premium:hover { box-shadow: 0 0 20px rgba(59, 130, 246, 0.5); transform: translateY(-2px); }
        .premium-glow { box-shadow: 0 0 15px rgba(59, 130, 246, 0.2); transition: all 0.3s ease-in-out; }
    </style>
</head>
<body class="bg-[#0b0c10] text-gray-300 font-sans min-h-screen">
    
    <div class="max-w-6xl mx-auto pb-10">
        <div class="flex items-center justify-between mb-6 pb-4 border-b border-gray-800">
            <div>
                <h2 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center text-blue-500 premium-glow">
                        <i class="fas fa-id-badge"></i>
                    </div>
                    Hồ Sơ Nhân Sự: <span class="text-blue-400">@${staff.username}</span>
                </h2>
                <p class="text-sm text-gray-500 mt-1">Cập nhật thông tin, thay đổi chức vụ hoặc phân quyền</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/staffs" class="px-4 py-2 rounded-xl bg-gray-800 hover:bg-gray-700 text-white text-sm font-medium transition duration-200 flex items-center gap-2">
                <i class="fas fa-arrow-left"></i> Trở về danh sách
            </a>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="mb-6 bg-green-500/10 border border-green-500/30 text-green-400 px-5 py-4 rounded-xl flex items-start gap-3 animate-[slideInDown_0.5s_ease-out]">
                <i class="fas fa-check-circle mt-0.5 text-lg"></i>
                <div class="text-sm leading-relaxed font-medium">${successMessage}</div>
            </div>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="mb-6 bg-red-500/10 border border-red-500/30 text-red-400 px-5 py-4 rounded-xl flex items-start gap-3 animate-[slideInDown_0.5s_ease-out]">
                <i class="fas fa-exclamation-triangle mt-0.5 text-lg"></i>
                <div class="text-sm leading-relaxed font-medium">${errorMessage}</div>
            </div>
        </c:if>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="lg:col-span-1 flex flex-col gap-6">
                <div class="glass-card p-6 rounded-2xl border border-gray-800 flex flex-col items-center text-center relative overflow-hidden">
                    <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-blue-600 to-indigo-600"></div>
                    
                    <div id="avatar-preview-container" class="w-32 h-32 mx-auto rounded-full bg-gray-800 border-4 border-gray-700 overflow-hidden mb-4 relative flex items-center justify-center shadow-xl">
                        <c:choose>
                            <c:when test="${empty staff.avatar || staff.avatar == 'default_avatar.png'}">
                                <i id="avatar-icon" class="fas fa-user-tie text-5xl text-gray-500"></i>
                                <img id="avatar-preview-img" class="w-full h-full object-cover hidden" alt="Avatar">
                            </c:when>
                            <c:otherwise>
                                <i id="avatar-icon" class="fas fa-user-tie text-5xl text-gray-500 hidden"></i>
                                <img id="avatar-preview-img" src="${fn:startsWith(staff.avatar, 'http') ? staff.avatar : pageContext.request.contextPath += '/assets/images/avatar/' += staff.avatar}" class="w-full h-full object-cover" alt="Avatar">
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h3 class="text-xl font-bold text-white mb-1">${staff.fullName}</h3>
                    <p class="text-sm text-blue-400 font-mono mb-4">@${staff.username}</p>

                    <div class="w-full flex justify-center mb-5">
                        <c:choose>
                            <c:when test="${staff.status == 'Active'}">
                                <div class="inline-flex items-center gap-2 bg-green-500/10 text-green-400 px-4 py-1.5 rounded-full text-sm font-medium border border-green-500/20 shadow-[0_0_10px_rgba(34,197,94,0.1)]">
                                    <div class="w-2 h-2 rounded-full bg-green-400 animate-pulse"></div> Trạng thái: Hoạt động
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="inline-flex items-center gap-2 bg-red-500/10 text-red-400 px-4 py-1.5 rounded-full text-sm font-medium border border-red-500/20">
                                    <i class="fas fa-lock text-xs"></i> Trạng thái: Đã khóa
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="w-full bg-[#0d0d0d] rounded-xl p-4 border border-gray-800 text-left text-xs text-gray-400 flex flex-col gap-2">
                        <div class="flex justify-between items-center pb-2 border-b border-gray-800">
                            <span>Mã nhân sự:</span>
                            <span class="font-mono text-white">#${staff.id_User}</span>
                        </div>
                        <div class="flex justify-between items-center pb-2 border-b border-gray-800">
                            <span>Ngày tham gia:</span>
                            <span class="text-white"><fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>Cập nhật lần cuối:</span>
                            <span class="text-white"><fmt:formatDate value="${staff.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                        </div>
                    </div>
                </div>

                <div class="glass-card p-6 rounded-2xl border border-red-900/30">
                    <h4 class="text-sm font-bold text-red-400 uppercase tracking-wider mb-4 flex items-center gap-2">
                        <i class="fas fa-exclamation-circle"></i> Thao Tác Quản Trị
                    </h4>
                    
                    <div class="flex flex-col gap-3">
                        <button onclick="openResetModal()" class="w-full bg-[#0d0d0d] hover:bg-orange-500/10 text-gray-300 hover:text-orange-400 border border-gray-800 hover:border-orange-500/30 px-4 py-3 rounded-xl text-sm transition duration-300 flex items-center gap-3">
                            <i class="fas fa-key w-5 text-center"></i> Khôi phục mật khẩu mặc định
                        </button>

                        <c:choose>
                            <c:when test="${staff.status == 'Active'}">
                                <button onclick="openLockModal('Locked')" class="w-full bg-[#0d0d0d] hover:bg-red-500/10 text-gray-300 hover:text-red-400 border border-gray-800 hover:border-red-500/30 px-4 py-3 rounded-xl text-sm transition duration-300 flex items-center gap-3">
                                    <i class="fas fa-user-lock w-5 text-center"></i> Khóa tài khoản này
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button onclick="openLockModal('Active')" class="w-full bg-[#0d0d0d] hover:bg-green-500/10 text-gray-300 hover:text-green-400 border border-gray-800 hover:border-green-500/30 px-4 py-3 rounded-xl text-sm transition duration-300 flex items-center gap-3">
                                    <i class="fas fa-user-check w-5 text-center"></i> Mở khóa tài khoản
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="lg:col-span-2">
                <form id="staffUpdateForm" action="${pageContext.request.contextPath}/admin/staffs/update" method="POST" class="glass-card p-6 md:p-8 rounded-2xl border border-gray-800 relative overflow-hidden" onsubmit="return validateForm()">
                    
                    <div id="staticErrorBox" class="hidden mb-6 bg-red-500/10 border border-red-500/30 text-red-400 px-4 py-3 rounded-xl flex items-center gap-3">
                        <i class="fas fa-exclamation-circle text-lg"></i>
                        <span id="staticErrorMessage" class="text-sm font-medium"></span>
                    </div>

                    <input type="hidden" name="id_User" value="${staff.id_User}">
                    <input type="hidden" name="status" value="${staff.status}">

                    <h3 class="text-lg font-bold text-white border-b border-gray-800 pb-2 mb-5"><i class="fas fa-pen-alt text-blue-500 mr-2"></i> Chỉnh Sửa Hồ Sơ</h3>

                    <div class="mb-5">
                        <label class="block text-sm font-medium text-gray-400 mb-1">Tên đăng nhập (Username)</label>
                        <div class="relative">
                            <input type="text" value="${staff.username}" readonly class="input-premium pl-10 text-sm font-mono tracking-wide" title="Không thể thay đổi tên đăng nhập">
                            <input type="hidden" name="username" value="${staff.username}">
                            <i class="fas fa-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-600"></i>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Họ và Tên <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="fullName" id="fullName" value="${staff.fullName}" class="input-premium pl-10 text-sm">
                                <i class="fas fa-signature absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="fullName-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Số điện thoại <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="phone" id="phone" value="${staff.phone}" class="input-premium pl-10 text-sm font-mono">
                                <i class="fas fa-phone-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="phone-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>
                    </div>

                    <div class="mb-5">
                        <label class="block text-sm font-medium text-gray-400 mb-1">Email <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <input type="text" name="email" id="email" value="${staff.email}" class="input-premium pl-10 text-sm">
                            <i class="fas fa-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                        </div>
                        <p id="email-error" class="text-xs text-red-500 mt-1 hidden"></p>
                    </div>

                    <div class="mb-5 bg-[#121212] p-4 rounded-xl border border-gray-800">
                        <label class="block text-sm font-medium text-gray-300 mb-2">
                            <i class="fas fa-id-badge text-blue-500 mr-1"></i> Phân Quyền Chức Vụ <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <select name="roleId" id="roleId" class="input-premium pl-10 appearance-none text-sm cursor-pointer border-blue-500/30">
                                <option value="0">-- Chọn Chức Vụ Mới --</option>
                                <c:forEach var="role" items="${roles}">
                                    <option value="${role.id_Role}" ${currentRoleId == role.id_Role ? 'selected' : ''} title="${role.description}">${role.roleName}</option>
                                </c:forEach>
                            </select>
                            <i class="fas fa-briefcase absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            <i class="fas fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-xs pointer-events-none"></i>
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-400 mb-1">Ảnh Đại Diện (URL Link)</label>
                        <div class="relative">
                            <input type="text" name="avatar" id="avatar" value="${staff.avatar}" placeholder="Dán link ảnh vào đây" class="input-premium pl-10 text-sm" oninput="previewAvatar()">
                            <i class="fas fa-image absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                        </div>
                    </div>

                    <div class="pt-5 border-t border-gray-800 flex justify-end gap-3">
                        <button type="submit" class="px-8 py-2.5 rounded-xl btn-premium font-bold flex items-center gap-2">
                            <i class="fas fa-save"></i> Cập Nhật Hồ Sơ
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div id="lockModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 opacity-0 pointer-events-none transition-opacity duration-200">
        <div class="bg-[#1a1c23] border border-gray-800 rounded-xl w-full max-w-sm p-6 shadow-2xl transform scale-95 transition-transform duration-200 text-center">
            <div id="lockModalIcon" class="w-16 h-16 rounded-full mx-auto mb-4 flex items-center justify-center text-2xl"></div>
            <h4 class="text-white font-bold text-lg mb-2" id="lockModalTitle">Xác nhận</h4>
            <p class="text-sm text-gray-400 mb-6" id="lockModalDesc"></p>
            
            <form action="${pageContext.request.contextPath}/admin/staffs/update-status" method="POST" class="flex justify-center gap-3">
                <input type="hidden" name="id_User" value="${staff.id_User}">
                <input type="hidden" name="status" id="lockModalStatusInput">
                <button type="button" onclick="closeLockModal()" class="px-5 py-2 rounded-xl bg-[#0b0c10] border border-gray-700 text-gray-300 hover:text-white transition">Hủy</button>
                <button type="submit" id="lockModalBtn" class="px-5 py-2 rounded-xl font-bold text-white transition shadow-lg"></button>
            </form>
        </div>
    </div>

    <div id="resetModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 opacity-0 pointer-events-none transition-opacity duration-200">
        <div class="bg-[#1a1c23] border border-orange-900/50 rounded-xl w-full max-w-sm p-6 shadow-2xl transform scale-95 transition-transform duration-200 text-center">
            <div class="w-16 h-16 rounded-full bg-orange-500/20 text-orange-500 mx-auto mb-4 flex items-center justify-center text-2xl">
                <i class="fas fa-key"></i>
            </div>
            <h4 class="text-white font-bold text-lg mb-2">Khôi phục mật khẩu?</h4>
            <p class="text-sm text-gray-400 mb-6">Mật khẩu của tài khoản <b>@${staff.username}</b> sẽ được đặt lại thành mặc định: <br><span class="text-white font-mono bg-gray-800 px-2 py-1 rounded mt-2 inline-block tracking-wider">Pass@123</span></p>
            
            <form action="${pageContext.request.contextPath}/admin/staffs/reset-password" method="POST" class="flex justify-center gap-3">
                <input type="hidden" name="id_User" value="${staff.id_User}">
                <button type="button" onclick="closeResetModal()" class="px-5 py-2 rounded-xl bg-[#0b0c10] border border-gray-700 text-gray-300 hover:text-white transition">Hủy</button>
                <button type="submit" class="px-5 py-2 rounded-xl font-bold text-white bg-orange-600 hover:bg-orange-500 transition shadow-[0_0_15px_rgba(249,115,22,0.4)]">Xác nhận</button>
            </form>
        </div>
    </div>

    <script>
        // XỬ LÝ PREVIEW ẢNH
        function previewAvatar() {
            const url = document.getElementById('avatar').value.trim();
            const img = document.getElementById('avatar-preview-img');
            const icon = document.getElementById('avatar-icon');
            
            if (url !== '') {
                img.classList.remove('hidden');
                icon.classList.add('hidden');
                if (url.startsWith('http')) {
                    img.src = url;
                } else if (!url.startsWith('/assets/')) {
                    img.src = '${pageContext.request.contextPath}/assets/images/avatar/' + url;
                }
            } else {
                img.classList.add('hidden');
                icon.classList.remove('hidden');
            }
        }

        // VALIDATE FORM SỬA THÔNG TIN
        function showError(fieldId, msg) {
            const el = document.getElementById(fieldId + '-error');
            const input = document.getElementById(fieldId);
            el.innerText = msg;
            el.classList.remove('hidden');
            input.classList.add('border-red-500');
        }

        function clearErrors() {
            const errors = document.querySelectorAll('[id$="-error"]');
            errors.forEach(e => e.classList.add('hidden'));
            const inputs = document.querySelectorAll('.input-premium');
            inputs.forEach(i => i.classList.remove('border-red-500'));
            document.getElementById('staticErrorBox').classList.add('hidden');
            document.getElementById('roleId').classList.remove('border-red-500');
        }

        function validateForm() {
            clearErrors();
            let isValid = true;

            const role = document.getElementById('roleId').value;
            const fname = document.getElementById('fullName').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const email = document.getElementById('email').value.trim();

            if (role === "0") {
                document.getElementById('roleId').classList.add('border-red-500');
                isValid = false;
                showStaticError("Vui lòng chọn Chức vụ cho nhân sự!");
            }

            const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲÝỴÝỳýỵỷỹ\s]+$/;
            if (fname === "") { showError('fullName', 'Họ tên không được để trống!'); isValid = false; }
            else if (!nameRegex.test(fname)) { showError('fullName', 'Họ tên không được chứa số hoặc ký tự đặc biệt!'); isValid = false; }

            const phoneRegex = /^(0|\+84)[0-9]{9}$/;
            if (phone === "") { showError('phone', 'Số điện thoại không được để trống!'); isValid = false; }
            else if (!phoneRegex.test(phone)) { showError('phone', 'SĐT phải gồm 10 số (Bắt đầu bằng 0 hoặc +84)!'); isValid = false; }

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (email === "") { showError('email', 'Email không được để trống!'); isValid = false; }
            else if (!emailRegex.test(email)) { showError('email', 'Email không hợp lệ (Ví dụ: a@gmail.com)!'); isValid = false; }

            if (!isValid) window.scrollTo({ top: 0, behavior: 'smooth' });
            return isValid;
        }

        function showStaticError(msg) {
            const box = document.getElementById('staticErrorBox');
            const msgEl = document.getElementById('staticErrorMessage');
            msgEl.innerText = msg;
            box.classList.remove('hidden');
        }

        // JS MODAL TRẠNG THÁI
        function openLockModal(targetStatus) {
            const modal = document.getElementById('lockModal');
            const icon = document.getElementById('lockModalIcon');
            const title = document.getElementById('lockModalTitle');
            const desc = document.getElementById('lockModalDesc');
            const btn = document.getElementById('lockModalBtn');
            const input = document.getElementById('lockModalStatusInput');

            input.value = targetStatus;

            if (targetStatus === 'Locked') {
                icon.className = 'w-16 h-16 rounded-full mx-auto mb-4 flex items-center justify-center text-2xl bg-red-500/20 text-red-500';
                icon.innerHTML = '<i class="fas fa-user-lock"></i>';
                title.innerText = 'Khóa Tài Khoản?';
                desc.innerText = 'Nhân sự này sẽ bị tước quyền đăng nhập và thao tác trên hệ thống ngay lập tức.';
                btn.className = 'px-5 py-2 rounded-xl font-bold text-white transition shadow-[0_0_15px_rgba(239,68,68,0.4)] bg-red-600 hover:bg-red-500';
                btn.innerText = 'Khóa Ngay';
            } else {
                icon.className = 'w-16 h-16 rounded-full mx-auto mb-4 flex items-center justify-center text-2xl bg-green-500/20 text-green-500';
                icon.innerHTML = '<i class="fas fa-user-check"></i>';
                title.innerText = 'Mở Khóa Tài Khoản?';
                desc.innerText = 'Nhân sự này sẽ được cấp lại quyền đăng nhập vào hệ thống.';
                btn.className = 'px-5 py-2 rounded-xl font-bold text-white transition shadow-[0_0_15px_rgba(34,197,94,0.4)] bg-green-600 hover:bg-green-500';
                btn.innerText = 'Mở Khóa';
            }

            modal.classList.remove('opacity-0', 'pointer-events-none');
            modal.children[0].classList.remove('scale-95');
        }

        function closeLockModal() {
            const modal = document.getElementById('lockModal');
            modal.classList.add('opacity-0', 'pointer-events-none');
            modal.children[0].classList.add('scale-95');
        }

        // JS MODAL RESET PASSWORD
        function openResetModal() {
            const modal = document.getElementById('resetModal');
            modal.classList.remove('opacity-0', 'pointer-events-none');
            modal.children[0].classList.remove('scale-95');
        }

        function closeResetModal() {
            const modal = document.getElementById('resetModal');
            modal.classList.add('opacity-0', 'pointer-events-none');
            modal.children[0].classList.add('scale-95');
        }
    </script>
</body>
</html>