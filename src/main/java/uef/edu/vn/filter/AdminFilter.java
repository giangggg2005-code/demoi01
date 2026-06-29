package uef.edu.vn.filter;

import uef.edu.vn.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Chặn MỌI đường dẫn bắt đầu bằng /admin
@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // Lấy thông tin User từ Session (Do AuthController lưu lúc đăng nhập)
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser != null) {
            // Đã đăng nhập -> Cho phép đi tiếp vào Controller hoặc JSP
            chain.doFilter(request, response);
        } else {
            // BẢO MẬT: Chưa đăng nhập -> Đá thẳng về trang Login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login-admin");
        }
    }

    @Override
    public void destroy() {}
}