<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Starlight Admin - Đăng nhập</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap');
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        .login-bg {
            background: radial-gradient(circle at top right, rgba(220, 38, 38, 0.15), transparent),
                        radial-gradient(circle at bottom left, rgba(37, 99, 235, 0.1), transparent), #0b0c10;
            background-size: cover;
        }
        .glass-card {
            background: rgba(20, 21, 27, 0.8);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7);
        }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
        .animate-float { animation: float 4s ease-in-out infinite; }
        .shake { animation: shake 0.4s ease-in-out; }
        @keyframes shake { 0%, 100% { transform: translateX(0); } 25% { transform: translateX(-10px); } 75% { transform: translateX(10px); } }
        @keyframes errorAppear { 0% { opacity: 0; transform: translateY(-10px); } 100% { opacity: 1; transform: translateY(0); } }
        .animate-error { animation: errorAppear 0.3s ease-out forwards; }
        @keyframes fadeInUp { from { opacity: 0; transform: scale(0.9) translateY(40px); } to { opacity: 1; transform: scale(1) translateY(0); } }
    </style>
</head>
<body class="login-bg min-h-screen flex items-center justify-center p-6 overflow-hidden">
    <div class="fixed top-[-10%] left-[-10%] w-[40%] h-[40%] bg-red-600/10 blur-[120px] rounded-full"></div>
    <div class="fixed bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-blue-600/10 blur-[120px] rounded-full"></div>

    <div id="login-container" class="flex w-full max-w-5xl glass-card rounded-[2.5rem] overflow-hidden relative transition-all duration-500 scale-95 opacity-0 translate-y-10" style="animation: fadeInUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;">
        
        <div class="flex-1 p-10 md:p-16">
            <div class="text-center mb-12">
                <div class="inline-flex items-center justify-center bg-gradient-to-tr from-red-600 to-red-500 text-white w-16 h-16 rounded-2xl mb-6 shadow-xl shadow-red-900/40 animate-float">
                    <i class="fa-solid fa-star text-3xl"></i>
                </div>
                <h1 class="text-3xl font-extrabold text-white uppercase tracking-tighter">Starlight <span class="text-red-500">Admin</span></h1>
                <p class="text-gray-400 text-[10px] mt-2 font-bold tracking-[0.4em] uppercase opacity-60">Control Panel System</p>
            </div>

            <%-- ĐÃ ĐỔI THÀNH FORM SUBMIT LÊN CONTROLLER --%>
            <form id="login-form" action="${pageContext.request.contextPath}/login-admin" method="POST" class="space-y-6">
                <div class="space-y-2">
                    <label class="block text-[10px] font-black text-gray-500 uppercase tracking-[0.2em] ml-2">Tài khoản</label>
                    <div class="relative">
                        <i class="fa-solid fa-user-ninja absolute left-5 top-1/2 -translate-y-1/2 text-gray-600"></i>
                        <input type="text" id="username" name="username" required value="${param.username}"
                            class="w-full bg-white/[0.03] border border-white/5 rounded-2xl pl-14 pr-6 py-4 text-white focus:outline-none focus:border-red-500/50 focus:bg-white/[0.05] transition-all duration-300"
                            placeholder="Nhập tên đăng nhập">
                    </div>
                </div>

                <div class="space-y-2">
                    <label class="block text-[10px] font-black text-gray-500 uppercase tracking-[0.2em] ml-2">Mật khẩu</label>
                    <div class="relative">
                        <i class="fa-solid fa-shield-halved absolute left-5 top-1/2 -translate-y-1/2 text-gray-600"></i>
                        <input type="password" id="password" name="password" required 
                            class="w-full bg-white/[0.03] border border-white/5 rounded-2xl pl-14 pr-14 py-4 text-white focus:outline-none focus:border-red-500/50 focus:bg-white/[0.05] transition-all duration-300"
                            placeholder="••••••••">
                        <button type="button" onclick="togglePassword('password', this)" class="absolute right-5 top-1/2 -translate-y-1/2 text-gray-600 hover:text-red-500 transition">
                            <i class="fa-solid fa-eye text-lg"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" 
                    class="w-full bg-gradient-to-r from-red-600 to-red-500 hover:from-red-500 hover:to-red-400 text-white font-black py-5 rounded-2xl transition-all duration-300 shadow-xl shadow-red-600/20 uppercase text-[11px] tracking-[0.2em] mt-4 hover:scale-[1.02] active:scale-[0.98]">
                    Đăng nhập
                </button>

                <div id="error-box" class="${empty error ? 'hidden' : ''} mt-6 p-4 bg-red-500/10 border border-red-500/20 rounded-2xl flex items-center space-x-3 backdrop-blur-md animate-error">
                    <div class="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center flex-shrink-0">
                        <i class="fa-solid fa-xmark text-white text-sm"></i>
                    </div>
                    <p class="text-red-400 text-[11px] font-bold uppercase tracking-wider">${error}</p>
                </div>
            </form>
        </div>

        <div class="hidden md:block w-1/2 relative overflow-hidden">
            <img src="https://image.tmdb.org/t/p/original/or06vSaeEbDb3WEzGCO7oA0P7NQ.jpg" alt="Movie Poster" class="absolute inset-0 w-full h-full object-cover brightness-50 grayscale-[0.3] hover:grayscale-0 hover:scale-105 transition-all duration-1000">
            <div class="absolute inset-0 bg-gradient-to-t from-[#0b0c10] via-transparent to-red-900/20"></div>
            <div class="absolute inset-0 flex flex-col justify-end p-12">
                <div class="p-8 glass-card border-white/10 rounded-[2rem] transform translate-y-4">
                    <h3 class="text-white text-xl font-black uppercase tracking-tighter mb-2">Trải nghiệm quản trị tối ưu</h3>
                    <p class="text-gray-400 text-xs leading-relaxed italic">"Nơi mọi vì sao tỏa sáng và mọi thước phim đều được trân trọng."</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        function togglePassword(inputId, button) {
            const input = document.getElementById(inputId);
            const icon = button.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        }

        // Tự động rung form nếu Server trả về có lỗi (sai pass)
        <c:if test="${not empty error}">
            document.addEventListener("DOMContentLoaded", function() {
                const loginContainer = document.getElementById('login-container');
                loginContainer.classList.add('shake');
                setTimeout(() => loginContainer.classList.remove('shake'), 400);
            });
        </c:if>
    </script>
</body>
</html>