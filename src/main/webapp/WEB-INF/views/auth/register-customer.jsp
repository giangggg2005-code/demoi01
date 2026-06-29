<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Starlight Club - Tham gia ngay</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Poppins', sans-serif; }
        .movie-bg {
            background-image: linear-gradient(135deg, rgba(15, 12, 41, 0.8), rgba(48, 43, 99, 0.7)), 
                              url('https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80');
            background-size: cover;
            background-position: center;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .shake { animation: shake 0.4s ease-in-out; }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }
        @keyframes errorAppear {
            0% { opacity: 0; transform: translateY(-10px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .animate-error { animation: errorAppear 0.3s ease-out forwards; }
    </style>
</head>
<body class="movie-bg min-h-screen flex items-center justify-center p-6">
    
    <div id="register-container" class="flex w-full max-w-6xl glass-card rounded-[3rem] overflow-hidden relative transition-transform duration-300">
        <div class="flex-1 p-12">
            <a href="${pageContext.request.contextPath}/customer/home" class="block text-center mb-10 cursor-pointer select-none" ondblclick="resetZoom('register-container')">
                <h1 class="text-3xl font-black text-white tracking-tighter uppercase">Gia nhập <span class="text-red-500">Starlight</span></h1>
                <p class="text-gray-400 text-[10px] mt-2 font-bold tracking-[0.3em] uppercase">Tích điểm đổi vé - Nhận ngàn ưu đãi</p>
            </a>

            <form id="register-form" action="${pageContext.request.contextPath}/register-customer" method="POST" class="space-y-6">
                <c:if test="${not empty error}">
                    <div class="bg-red-500/10 border border-red-500 text-red-500 px-4 py-3 rounded-lg mb-4 text-sm font-bold text-center">
                        ${error}
                    </div>
                </c:if>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="space-y-2">
                        <input type="text" id="fullname" name="fullName" required placeholder="Họ và tên" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                    </div>
                    <div class="space-y-2">
                        <input type="email" id="email" name="email" required placeholder="Địa chỉ Email" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                    </div>
                    <div class="space-y-2">
                        <input type="text" id="username" name="username" required placeholder="Tên đăng nhập" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                    </div>
                    <div class="space-y-2">
                        <input type="tel" id="phone" name="phone" required placeholder="Số điện thoại (VD: 0901234567)" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                    </div>
                    <div class="space-y-2 text-white">
                        <div class="relative">
                            <input type="password" id="password" name="password" required placeholder="Mật khẩu" 
                                class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                            <button type="button" onclick="togglePassword('password', this)" class="absolute right-5 top-1/2 -translate-y-1/2 text-gray-500">
                                <i class="fa-solid fa-eye"></i>
                            </button>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <div class="relative">
                            <input type="password" id="confirm_password" required placeholder="Xác nhận mật khẩu" 
                                class="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:ring-2 focus:ring-red-500/50 transition outline-none">
                            <button type="button" onclick="togglePassword('confirm_password', this)" class="absolute right-5 top-1/2 -translate-y-1/2 text-gray-500">
                                <i class="fa-solid fa-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="flex items-start space-x-3 px-2">
                    <input type="checkbox" required class="mt-1 w-4 h-4 accent-red-600 border-none rounded">
                    <p class="text-[10px] text-gray-400 font-medium">Tôi đồng ý với <a href="#" class="text-white hover:underline">Điều khoản thành viên</a> và cam kết bảo mật thông tin.</p>
                </div>

                <button type="submit" class="w-full bg-gradient-to-r from-red-600 to-pink-600 text-white font-black py-4 rounded-2xl shadow-xl shadow-red-600/20 hover:scale-[1.01] transition duration-300 uppercase tracking-[0.2em] text-xs">
                    Đăng ký thành viên
                </button>
                
                <div id="error-box" class="hidden mt-6 p-4 bg-red-500/20 border border-red-500/50 rounded-2xl flex items-center space-x-3">
                    <i class="fa-solid fa-circle-exclamation text-red-500"></i>
                    <p id="error-text" class="text-red-100 text-[10px] font-bold uppercase"></p>
                </div>
            </form>

            <div class="mt-10 pt-8 border-t border-white/10 text-center">
                <p class="text-gray-400 text-xs">Đã có tài khoản? 
                    <a href="${pageContext.request.contextPath}/login-customer" class="text-white font-black hover:text-red-500 ml-1 transition">Đăng nhập</a>
                </p>
            </div>
        </div>

        <div class="hidden md:block w-2/5 relative overflow-hidden">
            <img src="https://image.tmdb.org/t/p/original/8Y7v9Y78fwS7C91v9o9ansThzbj.jpg" alt="Poster" class="absolute inset-0 w-full h-full object-cover brightness-90">
            <div class="absolute inset-0 bg-gradient-to-tr from-red-600/20 to-transparent"></div>
        </div>

        <div id="resize-handle" class="absolute bottom-6 right-6 cursor-nwse-resize text-white/20 hover:text-red-500 z-30">
            <i class="fa-solid fa-expand text-sm"></i>
        </div>
    </div>

    <script>
        const form = document.getElementById('register-form');
        const errBox = document.getElementById('error-box');
        const container = document.getElementById('register-container');

        form.onsubmit = (e) => {
            const p1 = document.getElementById('password').value;
            const p2 = document.getElementById('confirm_password').value;
            if (p1 !== p2) {
                e.preventDefault();
                const errorText = document.getElementById('error-text');
                if (errorText) errorText.innerText = "Mật khẩu xác nhận không trùng khớp!";
                if (errBox) {
                    errBox.classList.remove('hidden');
                    errBox.classList.add('animate-error');
                }
                container.classList.add('shake');
                setTimeout(() => container.classList.remove('shake'), 400);
            }
        };

        function togglePassword(id, btn) {
            const input = document.getElementById(id);
            const icon = btn.querySelector('i');
            input.type = input.type === 'password' ? 'text' : 'password';
            icon.classList.toggle('fa-eye');
            icon.classList.toggle('fa-eye-slash');
        }

        let currentScale = 1;
        let isResizing = false;
        let startDist, startScale, centerX, centerY;
        const handle = document.getElementById('resize-handle');
        container.style.transformOrigin = 'center center';

        handle.onmousedown = (e) => {
            isResizing = true;
            const rect = container.getBoundingClientRect();
            centerX = rect.left + rect.width / 2;
            centerY = rect.top + rect.height / 2;
            startDist = Math.hypot(e.clientX - centerX, e.clientY - centerY);
            startScale = currentScale;
            document.body.classList.add('select-none');
        };

        window.onmousemove = (e) => {
            if (!isResizing) return;
            const dist = Math.hypot(e.clientX - centerX, e.clientY - centerY);
            currentScale = Math.min(Math.max(0.7, (dist / startDist) * startScale), 1.5);
            container.style.transform = `scale(${currentScale})`;
        };

        window.onmouseup = () => { isResizing = false; document.body.classList.remove('select-none'); };
        function resetZoom(id) { currentScale = 1; document.getElementById(id).style.transform = 'scale(1)'; }
    </script>
</body>
</html>