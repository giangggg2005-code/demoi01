package uef.edu.vn.controller;

import jakarta.servlet.http.HttpSession; 
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import uef.edu.vn.model.User;
import uef.edu.vn.service.UserService;

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/login-admin")
    public String showLoginAdmin() {
        return "auth/login-admin"; 
    }

    @PostMapping("/login-admin")
    public String processLoginAdmin(@RequestParam("username") String username, 
                                    @RequestParam("password") String password, 
                                    HttpSession session, Model model) {
        try {
            User user = userService.authenticate(username, password);

            if (user != null) {
                session.setAttribute("loggedInUser", user);
                
                if (user.getRoles() != null && !user.getRoles().isEmpty()) {
                    session.setAttribute("userRole", user.getRoles().get(0).getRoleName().toUpperCase());
                } else {
                    session.setAttribute("userRole", "ADMIN"); 
                }

                return "redirect:/admin/dashboard"; 
            } else {
                model.addAttribute("error", "Đăng nhập thất bại!");
                return "auth/login-admin";
            }
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "auth/login-admin";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate(); 
        return "redirect:/login-admin"; 
    }

    @GetMapping("/login-customer")
    public String showLoginCustomer() {
        return "auth/login-customer";
    }

    @PostMapping("/login-customer")
    public String processLoginCustomer(@RequestParam("username") String username,
                                       @RequestParam("password") String password,
                                       HttpSession session, Model model) {
        try {
            User user = userService.authenticate(username, password);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("userRole", "CUSTOMER");
            return "redirect:/customer/home";
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "auth/login-customer";
        }
    }

    @GetMapping("/register-customer")
    public String showRegisterCustomer() {
        return "auth/register-customer";
    }

    @PostMapping("/register-customer")
    public String processRegisterCustomer(@RequestParam("fullName") String fullName,
                                          @RequestParam("email") String email,
                                          @RequestParam("username") String username,
                                          @RequestParam("phone") String phone,
                                          @RequestParam("password") String password,
                                          Model model,
                                          RedirectAttributes redirectAttributes) {
        try {
            User user = new User();
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setUsername(username.trim());
            user.setPhone(phone.trim());
            user.setPassword(password);
            user.setAvatar("default_avatar.png"); 
            user.setStatus("Active");

            userService.registerCustomer(user);
            
            redirectAttributes.addFlashAttribute("successMessage", "Đăng ký tài khoản thành công! Vui lòng đăng nhập.");
            return "redirect:/login-customer";
            
        } catch (Exception e) {
            e.printStackTrace(); 
            model.addAttribute("error", e.getMessage());
            return "auth/register-customer"; 
        }
    }

    @GetMapping("/logout-customer")
    public String logoutCustomer(HttpSession session) {
        session.invalidate();
        return "redirect:/customer/home";
    }
}