<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Starlight Cinema - Đăng nhập</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
        }
        .movie-bg {
            background-image: linear-gradient(45deg, rgba(15, 12, 41, 0.8), rgba(48, 43, 99, 0.7), rgba(36, 36, 62, 0.8)), 
                              url('https://images.unsplash.com/photo-1536440136628-849c177e76a1?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80');
            background-size: cover;
            background-position: center;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }
        .neon-text {
            text-shadow: 0 0 10px rgba(239, 68, 68, 0.5), 0 0 20px rgba(239, 68, 68, 0.3);
        }
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        .animate-float {
            animation: float 4s ease-in-out infinite;
        }
        .shake {
            animation: shake 0.4s ease-in-out;
        }
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
<body class="movie-bg min-h-screen flex items-center justify-center p-6 overflow-hidden">
    
    <div id="login-container" class="flex w-full max-w-5xl glass-card rounded-[2.5rem] overflow-hidden relative transition-transform duration-300">
        <div class="flex-1 p-10">
            <a href="${pageContext.request.contextPath}/customer/home" class="block text-center mb-10 cursor-pointer select-none group" ondblclick="resetZoom('login-container')">
                <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-tr from-red-600 to-pink-500 text-white rounded-3xl mb-4 shadow-xl shadow-red-500/30 transform group-hover:rotate-12 transition-transform animate-float">
                    <i class="fa-solid fa-play text-3xl ml-1"></i>
                </div>
                <h1 class="text-3xl font-black text-white tracking-tighter neon-text uppercase">Starlight <span class="text-red-500">Club</span></h1>
                <p class="text-gray-400 text-xs mt-2 font-medium tracking-widest uppercase">Thế giới điện ảnh của bạn</p>
            </a>

            <c:if test="${not empty successMessage}">
                <div class="bg-green-500/10 border border-green-500 text-green-500 px-4 py-3 rounded-lg mb-4 text-sm font-bold text-center">
                    ${successMessage}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="bg-red-500/10 border border-red-500 text-red-500 px-4 py-3 rounded-lg mb-4 text-sm font-bold text-center">
                    ${error}
                </div>
            </c:if>

            <form id="login-form" action="${pageContext.request.contextPath}/login-customer" method="post" class="space-y-6">
                <div class="space-y-2">
                    <div class="relative group">
                        <i class="fa-solid fa-envelope absolute left-5 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-red-500 transition"></i>
                        <input type="text" id="username" name="username" required placeholder="Tên đăng nhập hoặc Email" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl pl-14 pr-6 py-4 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-red-500/50 transition">
                    </div>
                </div>

                <div class="space-y-2">
                    <div class="relative group">
                        <i class="fa-solid fa-shield-halved absolute left-5 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-red-500 transition"></i>
                        <input type="password" id="password" name="password" required placeholder="Mật khẩu" 
                            class="w-full bg-white/5 border border-white/10 rounded-2xl pl-14 pr-14 py-4 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-red-500/50 transition">
                        <button type="button" onclick="togglePassword('password', this)" class="absolute right-5 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="flex items-center justify-between px-2">
                    <a href="#" class="text-[11px] text-gray-400 hover:text-red-400 font-bold uppercase tracking-tighter">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="w-full bg-gradient-to-r from-red-600 to-pink-600 text-white font-black py-4 rounded-2xl shadow-xl shadow-red-600/20 hover:shadow-red-600/40 hover:scale-[1.02] active:scale-[0.98] transition duration-300 uppercase tracking-widest text-sm">
                    Vào rạp ngay
                </button>
            </form>

            <div class="mt-10 pt-8 border-t border-white/10 text-center">
                <p class="text-gray-400 text-xs">Thành viên mới? 
                    <a href="${pageContext.request.contextPath}/register-customer" class="text-white font-black hover:text-red-500 ml-1 transition">Đăng ký thành viên</a>
                </p>
            </div>
        </div>

        <div class="hidden md:block w-2/5 relative overflow-hidden">
            <img src="https://image.tmdb.org/t/p/original/1g0dhYtWyge9ZpKWvF9Z3O9vUwb.jpg" alt="Poster" class="absolute inset-0 w-full h-full object-cover brightness-90">
            <div class="absolute inset-0 bg-gradient-to-tr from-red-600/20 to-transparent"></div>
        </div>

        <div id="resize-handle" title="Kéo để zoom" class="absolute bottom-4 right-4 cursor-nwse-resize text-white/20 hover:text-red-500 transition-colors z-30">
            <i class="fa-solid fa-expand text-sm"></i>
        </div>
    </div>

    <script>
        const container = document.getElementById('login-container');
        <c:if test="${not empty error}">
        container.classList.add('shake');
        setTimeout(() => container.classList.remove('shake'), 400);
        </c:if>

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