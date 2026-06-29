<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm Nhân Sự Mới</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .glass-card { background: rgba(22, 22, 22, 0.85); backdrop-filter: blur(16px); }
        .input-premium {
            background-color: #0d0d0d; border: 1px solid #262626; color: #f3f4f6;
            border-radius: 0.75rem; padding: 0.625rem 1rem; width: 100%; transition: all 0.3s ease;
        }
        .input-premium:focus { border-color: #3b82f6; outline: none; box-shadow: 0 0 12px rgba(59, 130, 246, 0.3); }
        .btn-premium { background: linear-gradient(135deg, #2563eb, #4f46e5); color: white; transition: all 0.3s ease; }
        .btn-premium:hover { box-shadow: 0 0 20px rgba(59, 130, 246, 0.5); transform: translateY(-2px); }
    </style>
</head>
<body class="bg-[#0b0c10] text-gray-300 font-sans min-h-screen">
    
    <div class="max-w-4xl mx-auto pb-10">
        <div class="flex items-center justify-between mb-8 pb-4 border-b border-gray-800">
            <div>
                <h2 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center text-blue-500">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    Thêm Nhân Sự Mới
                </h2>
                <p class="text-sm text-gray-500 mt-1">Cấp tài khoản nhân sự quản trị hệ thống</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/staffs" class="px-4 py-2 rounded-xl bg-gray-800 hover:bg-gray-700 text-white text-sm font-medium transition duration-200 flex items-center gap-2">
                <i class="fas fa-arrow-left"></i> Trở về
            </a>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="mb-6 bg-red-500/10 border border-red-500/30 text-red-400 px-5 py-4 rounded-xl flex items-start gap-3">
                <i class="fas fa-exclamation-triangle mt-1"></i>
                <div class="text-sm leading-relaxed">${errorMessage}</div>
            </div>
        </c:if>

        <form id="staffAddForm" action="${pageContext.request.contextPath}/admin/staffs/add" method="POST" class="glass-card rounded-2xl border border-gray-800 p-6 md:p-8 relative overflow-hidden" onsubmit="return validateForm()">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <div class="lg:col-span-1 flex flex-col gap-6">
                    <div class="bg-[#0d0d0d] p-5 rounded-xl border border-gray-800 text-center">
                        <div class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">Thiết Lập Quyền Hạn</div>
                        
                        <div class="text-left">
                            <label class="block text-sm font-medium text-gray-400 mb-2">Chức vụ <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <select name="roleId" id="roleId" class="input-premium pl-10 appearance-none text-sm cursor-pointer">
                                    <option value="0">-- Chọn Chức Vụ --</option>
                                    <c:forEach var="role" items="${roles}">
                                        <option value="${role.id_Role}" title="${role.description}">${role.roleName}</option>
                                    </c:forEach>
                                </select>
                                <i class="fas fa-briefcase absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                                <i class="fas fa-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 text-xs pointer-events-none"></i>
                            </div>
                            <p class="text-[10px] text-blue-400 mt-2 italic">* Chức vụ quyết định quyền truy cập vào các menu hệ thống.</p>
                        </div>
                    </div>

                    <div class="bg-[#0d0d0d] p-5 rounded-xl border border-gray-800 text-center">
                        <div class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">Ảnh Đại Diện</div>
                        <div id="avatar-preview-container" class="w-28 h-28 mx-auto rounded-full bg-gray-800 border-2 border-gray-700 overflow-hidden mb-4 relative flex items-center justify-center">
                            <i id="avatar-icon" class="fas fa-user text-4xl text-gray-600"></i>
                            <img id="avatar-preview" class="w-full h-full object-cover hidden" alt="Preview">
                        </div>
                        <div class="text-left">
                            <label class="block text-xs font-medium text-gray-400 mb-1">URL Ảnh Internet</label>
                            <input type="text" name="avatar" id="avatar" value="${staff.avatar}" placeholder="Dán link ảnh vào đây" class="input-premium text-xs py-2" oninput="previewAvatarUrl()">
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-2 flex flex-col gap-5">
                    <h3 class="text-lg font-bold text-white border-b border-gray-800 pb-2 mb-2"><i class="fas fa-id-card text-blue-500 mr-2"></i> Hồ Sơ Căn Bản</h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Họ và Tên <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="fullName" id="fullName" value="${staff.fullName}" class="input-premium pl-10 text-sm" placeholder="Nhập tên nhân sự">
                                <i class="fas fa-signature absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="fullName-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Số điện thoại <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="phone" id="phone" value="${staff.phone}" class="input-premium pl-10 text-sm font-mono" placeholder="Ví dụ: 0901234567">
                                <i class="fas fa-phone-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="phone-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>

                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-400 mb-1">Email <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="email" id="email" value="${staff.email}" class="input-premium pl-10 text-sm" placeholder="Ví dụ: nhansu@starlight.com">
                                <i class="fas fa-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="email-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>
                    </div>

                    <h3 class="text-lg font-bold text-white border-b border-gray-800 pb-2 mb-2 mt-4"><i class="fas fa-lock text-blue-500 mr-2"></i> Tài Khoản Truy Cập</h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Tên đăng nhập <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="text" name="username" id="username" value="${staff.username}" class="input-premium pl-10 text-sm font-mono text-blue-300" placeholder="Username (Không dấu)">
                                <i class="fas fa-user-circle absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            </div>
                            <p id="username-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Mật khẩu khởi tạo <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="password" name="password" id="password" class="input-premium pl-10 pr-10 text-sm font-mono tracking-[0.2em]" placeholder="********" value="Pass@123">
                                <i class="fas fa-key absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-500"></i>
                                <button type="button" onclick="togglePassword()" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white outline-none">
                                    <i id="eye-icon" class="fas fa-eye"></i>
                                </button>
                            </div>
                            <p class="text-[10px] text-gray-500 mt-1">* Hệ thống tự đặt mật khẩu mặc định là <b class="text-white tracking-wider">Pass@123</b>.</p>
                            <p id="password-error" class="text-xs text-red-500 mt-1 hidden"></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-8 pt-5 border-t border-gray-800 flex justify-end gap-4">
                <button type="button" onclick="resetForm()" class="px-6 py-2.5 rounded-xl border border-gray-700 text-gray-400 hover:text-white hover:bg-gray-800 transition duration-300 font-medium">Nhập lại</button>
                <button type="submit" class="px-8 py-2.5 rounded-xl btn-premium font-bold flex items-center gap-2">
                    <i class="fas fa-save"></i> Lưu Nhân Sự
                </button>
            </div>
        </form>
    </div>

    <script>
        function togglePassword() {
            const pwd = document.getElementById('password');
            const icon = document.getElementById('eye-icon');
            if (pwd.type === 'password') {
                pwd.type = 'text';
                pwd.classList.remove('tracking-[0.2em]');
                icon.className = 'fas fa-eye-slash text-yellow-500';
            } else {
                pwd.type = 'password';
                pwd.classList.add('tracking-[0.2em]');
                icon.className = 'fas fa-eye text-gray-500';
            }
        }

        function previewAvatarUrl() {
            const url = document.getElementById('avatar').value.trim();
            const preview = document.getElementById('avatar-preview');
            const icon = document.getElementById('avatar-icon');
            
            if (url && url.startsWith('http')) {
                preview.src = url;
                preview.classList.remove('hidden');
                icon.classList.add('hidden');
            } else {
                preview.classList.add('hidden');
                icon.classList.remove('hidden');
            }
        }

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
            
            const roleEl = document.getElementById('roleId');
            roleEl.classList.remove('border-red-500');
        }

        function resetForm() {
            document.getElementById('staffAddForm').reset();
            clearErrors();
            previewAvatarUrl();
        }

        function validateForm() {
            clearErrors();
            let isValid = true;

            const role = document.getElementById('roleId').value;
            const fname = document.getElementById('fullName').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const email = document.getElementById('email').value.trim();
            const uname = document.getElementById('username').value.trim();
            const pwd = document.getElementById('password').value;

            if (role === "0") {
                document.getElementById('roleId').classList.add('border-red-500');
                isValid = false;
                alert("Vui lòng chọn Chức Vụ cho nhân sự!");
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

            const userRegex = /^[a-zA-Z0-9_]{4,50}$/;
            if (uname === "") { showError('username', 'Tên đăng nhập không được để trống!'); isValid = false; }
            else if (!userRegex.test(uname)) { showError('username', 'Tên đăng nhập từ 4-50 ký tự, không dấu, không khoảng trắng!'); isValid = false; }

            const pwdRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,15}$/;
            if (pwd === "") { showError('password', 'Mật khẩu không được để trống!'); isValid = false; }
            else if (!pwdRegex.test(pwd)) { showError('password', 'Mật khẩu từ 6-15 ký tự, có 1 chữ in hoa và 1 ký tự đặc biệt!'); isValid = false; }

            if (!isValid) window.scrollTo({ top: 0, behavior: 'smooth' });
            return isValid;
        }

        // Tự chạy check ảnh khi load form (trường hợp bị lỗi DB trả lại)
        window.onload = previewAvatarUrl;
    </script>
</body>
</html>