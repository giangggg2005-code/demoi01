package uef.edu.vn.controller;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid; 
import org.springframework.validation.BindingResult; 

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import uef.edu.vn.exception.CustomerException; 
import uef.edu.vn.model.User;
import uef.edu.vn.service.CustomerService;

@Controller
@RequestMapping("/admin")
public class CustomerController {

    private final CustomerService customerService;
    private final String path = "/WEB-INF/views/admin/";
    private final String pathView = "layout/admin-layout/main";

    @Autowired
    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @GetMapping("/customers")
    public String showCustomers(
            @RequestParam(required = false) String nameKeyword,
            @RequestParam(required = false) String contactKeyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Double minSpent,
            @RequestParam(required = false) Double maxSpent,
            @RequestParam(required = false) String sortSpent,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) List<String> dateFilterType,
            Model model) {
        try {
            List<User> customers = customerService.filterCustomersAdvanced(
                    nameKeyword, contactKeyword, status, minSpent, maxSpent, sortSpent, startDate, endDate, dateFilterType);

            model.addAttribute("customerList", customers);
            model.addAttribute("totalCustomers", customerService.getTotalCustomerCount());
            
            model.addAttribute("currentNameKeyword", nameKeyword);
            model.addAttribute("currentContactKeyword", contactKeyword);
            model.addAttribute("currentStatus", status);
            model.addAttribute("currentMinSpent", minSpent);
            model.addAttribute("currentMaxSpent", maxSpent);
            model.addAttribute("currentSortSpent", sortSpent);
            model.addAttribute("currentStartDate", startDate);
            model.addAttribute("currentEndDate", endDate);
            model.addAttribute("currentDateFilterType", dateFilterType);

        } catch (CustomerException e) {
            model.addAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }

        model.addAttribute("view", "customers");
        model.addAttribute("body", path + "customers.jsp");
        return pathView;
    }

    @GetMapping("/customers/delete/{id}")
    public String deleteCustomer(@PathVariable("id") int id, RedirectAttributes redirectAttributes) {
        try {
            customerService.deleteCustomer(id);
            redirectAttributes.addFlashAttribute("successMessage", "Đã xóa khách hàng thành công!");
        } catch (CustomerException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi hệ thống khi xóa: " + e.getMessage());
        }
        return "redirect:/admin/customers";
    }

    @GetMapping("/customers/detail/{id}")
    public String showCustomerDetail(@PathVariable("id") int id, Model model, RedirectAttributes redirectAttributes) {
        try {
            User customer = customerService.getCustomerById(id);
            if (customer == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy thông tin khách hàng!");
                return "redirect:/admin/customers";
            }
            
            List<Map<String, Object>> roleDetails = customerService.getRoleDetailsByUserId(id);
            
            model.addAttribute("customer", customer);
            model.addAttribute("roleDetails", roleDetails);
            model.addAttribute("view", "customers");
            model.addAttribute("body", path + "customer_detail.jsp");
            return pathView;
        } catch (CustomerException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/admin/customers";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            return "redirect:/admin/customers";
        }
    }

    @PostMapping("/customers/update-status")
    public String updateCustomerStatus(@RequestParam("customerId") int customerId,
                                       @RequestParam("status") String status,
                                       RedirectAttributes redirectAttributes) {
        try {
            customerService.updateCustomerStatus(customerId, status);
            redirectAttributes.addFlashAttribute("successMessage", "Cập nhật trạng thái khách hàng thành công!");
        } catch (CustomerException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }
        return "redirect:/admin/customers/detail/" + customerId;
    }

    // =========================================================================
    // [XỬ LÝ CẬP NHẬT THÔNG TIN] CÓ TÍCH HỢP UPLOAD ẢNH ĐẠI DIỆN NUỘT NÀ
    // =========================================================================
   // =========================================================================
    // [XỬ LÝ CẬP NHẬT THÔNG TIN] TÍCH HỢP UPLOAD FILE & NHẬP URL ĐỒNG BỘ
    // =========================================================================
    // =========================================================================
    // [XỬ LÝ CẬP NHẬT THÔNG TIN] TÍCH HỢP UPLOAD FILE & NHẬP URL ĐỒNG BỘ
    // =========================================================================
    @PostMapping("/customers/update-info")
    public String updateCustomerInfo(@Valid User customer, BindingResult result, 
                                     @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                                     HttpServletRequest request,
                                     RedirectAttributes redirectAttributes) {
        
        // 1. KIỂM TRA VÀ LỌC LỖI VALIDATION
        if (result.hasErrors()) {
            boolean hasActualErrors = false;
            StringBuilder combinedErrors = new StringBuilder("Lỗi dữ liệu đầu vào:<br>");
            List<String> fieldsToValidate = java.util.Arrays.asList("fullName", "email", "phone");
            
            for (org.springframework.validation.FieldError error : result.getFieldErrors()) {
                if (fieldsToValidate.contains(error.getField())) {
                    hasActualErrors = true;
                    combinedErrors.append("• ").append(error.getDefaultMessage()).append("<br>");
                }
            }

            if (hasActualErrors) {
                redirectAttributes.addFlashAttribute("errorMessage", combinedErrors.toString());
                return "redirect:/admin/customers/detail/" + customer.getId_User();
            }
        }

        // 2. XỬ LÝ LOGIC NGHIỆP VỤ, FILE UPLOAD & LƯU VÀO DATABASE
        try {
            User existingUser = customerService.getCustomerById(customer.getId_User());
            
            // TH1: Xử lý nếu người dùng có chọn file ảnh từ máy (Bắt chước chuẩn từ hàm Add)
            if (imageFile != null && !imageFile.isEmpty()) {
                try {
                    // ĐỔI ĐƯỜNG DẪN: Lưu vào /assets/images/avatar/ để đồng bộ với hàm thêm mới
                    String uploadPath = request.getServletContext().getRealPath("/assets/images/avatar/");
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    
                    // Đính kèm thêm chuỗi thời gian đằng trước tên file gốc để tránh bị ghi đè trùng ảnh
                    String fileName = System.currentTimeMillis() + "_" + imageFile.getOriginalFilename();
                    imageFile.transferTo(new File(uploadDir, fileName));
                    
                    customer.setAvatar(fileName); // Gán tên file mới
                    System.out.println("BACKEND - UPLOAD (UPDATE): Đã lưu ảnh thành công tên: " + fileName);
                } catch (IOException e) {
                    System.out.println("LỖI UPLOAD FILE (UPDATE): " + e.getMessage());
                }
            } else {
                // TH2: Nếu không chọn file, kiểm tra giá trị của ô input text 'avatar'
                // Nếu người dùng lỡ tay xóa trống cả ô text, ta mới gọi lại ảnh cũ từ Database
                if (customer.getAvatar() == null || customer.getAvatar().trim().isEmpty()) {
                    if (existingUser != null) {
                        customer.setAvatar(existingUser.getAvatar()); // Khác với hàm add, update phải giữ lại ảnh cũ
                    }
                }
                // (Nếu customer.getAvatar() đang chứa link http:// do người dùng nhập, hệ thống sẽ tự giữ nguyên)
            }

            // Đắp lại các trường hệ thống không đổi từ dữ liệu cũ
            if (existingUser != null) {
                customer.setUsername(existingUser.getUsername());
                customer.setPassword(existingUser.getPassword());
                customer.setStatus(existingUser.getStatus());
                customer.setCreatedAt(existingUser.getCreatedAt());
            }

            customerService.updateCustomerFullInfo(customer);
            redirectAttributes.addFlashAttribute("successMessage", "Đã cập nhật thông tin cá nhân khách hàng thành công!");
        } catch (CustomerException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Hệ thống gặp sự cố bất ngờ: " + e.getMessage());
        }
        
        return "redirect:/admin/customers/detail/" + customer.getId_User();
    }

    @PostMapping("/customers/reset-password")
    public String resetPassword(@RequestParam("customerId") int customerId, RedirectAttributes redirectAttributes) {
        try {
            customerService.resetPassword(customerId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã đặt lại mật khẩu về mặc định (Pass@123) thành công!");
        } catch (CustomerException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }
        return "redirect:/admin/customers/detail/" + customerId;
    }

    @GetMapping(value = "/customers/{id}/booking-history", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public String getBookingHistory(@PathVariable("id") int id) {
        List<Map<String, Object>> history = customerService.getCustomerBookingHistory(id);
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        for (int i = 0; i < history.size(); i++) {
            Map<String, Object> row = history.get(i);
            json.append("{");
            
            String bDate = row.get("bookingDate") != null ? row.get("bookingDate").toString() : "";
            String mTitle = row.get("movieTitle") != null ? row.get("movieTitle").toString().replace("\"", "\\\"") : "";
            String rName = row.get("roomName") != null ? row.get("roomName").toString() : "";
            String sName = row.get("seatName") != null ? row.get("seatName").toString() : "";
            Object tPrice = row.get("ticketPrice") != null ? row.get("ticketPrice") : 0;
            String tStatus = row.get("ticketStatus") != null ? row.get("ticketStatus").toString() : "";
            Object idSt = row.get("id_Showtime") != null ? row.get("id_Showtime") : 0;
            Object idSeat = row.get("id_Seat") != null ? row.get("id_Seat") : 0;
            
            String sDate = row.get("showDate") != null ? row.get("showDate").toString() : "";
            String sTime = row.get("startTime") != null ? row.get("startTime").toString() : "";

            json.append("\"bookingdate\":\"").append(bDate).append("\",");
            json.append("\"movietitle\":\"").append(mTitle).append("\",");
            json.append("\"roomname\":\"").append(rName).append("\",");
            json.append("\"seatname\":\"").append(sName).append("\",");
            json.append("\"ticketprice\":").append(tPrice).append(",");
            json.append("\"ticketstatus\":\"").append(tStatus).append("\",");
            json.append("\"id_showtime\":").append(idSt).append(",");
            json.append("\"id_seat\":").append(idSeat).append(",");
            json.append("\"showdate\":\"").append(sDate).append("\",");
            json.append("\"starttime\":\"").append(sTime).append("\"");
            
            json.append("}");
            if (i < history.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        return json.toString();
    }

    @GetMapping("/customers/add")
    public String showAddCustomerForm(Model model) {
        model.addAttribute("customer", new User()); 
        model.addAttribute("view", "customers"); 
        model.addAttribute("body", path + "customer_add.jsp"); 
        return pathView;
    }

   @PostMapping("/customers/add")
    public String processAddCustomer(@Valid User customer, BindingResult result, 
                                     @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                                     HttpServletRequest request,
                                     RedirectAttributes redirectAttributes) {
        
        System.out.println("\n========== BẮT ĐẦU TEST LƯU KHÁCH HÀNG KÈM ẢNH ==========");

        // 1. Check Lỗi Validation (Giữ nguyên logic kiểm tra lỗi chi tiết)
        if (result.hasErrors()) {
            boolean hasActualErrors = false;
            StringBuilder combinedErrors = new StringBuilder("Dữ liệu không đạt chuẩn (Lớp 2):<br>");
            List<String> fieldsToValidate = java.util.Arrays.asList("username", "password", "fullName", "email", "phone");
            
            for (org.springframework.validation.FieldError error : result.getFieldErrors()) {
                if (fieldsToValidate.contains(error.getField())) {
                    hasActualErrors = true;
                    combinedErrors.append("• ").append(error.getDefaultMessage()).append("<br>");
                }
            }

            if (hasActualErrors) {
                redirectAttributes.addFlashAttribute("errorMessage", combinedErrors.toString());
                return "redirect:/admin/customers/add";
            }
        }

        // 2. Xử lý File và Lưu CSDL
        try {
            // TH1: NGƯỜI DÙNG CÓ CHỌN FILE ẢNH TỪ MÁY TÍNH
            if (imageFile != null && !imageFile.isEmpty()) {
                try {
                    // SỬA CHUẨN ĐƯỜNG DẪN THỰC TẾ TRÊN SERVER:
                    String uploadPath = request.getServletContext().getRealPath("/assets/images/avatar/");
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    
                    // Đính kèm thêm chuỗi thời gian đằng trước tên file gốc để tránh bị ghi đè trùng ảnh
                    String fileName = System.currentTimeMillis() + "_" + imageFile.getOriginalFilename();
                    imageFile.transferTo(new File(uploadDir, fileName));
                    
                    // Chỉ lưu TÊN FILE vào DB (Ví dụ: 1698123_anh.jpg)
                    customer.setAvatar(fileName); 
                    System.out.println("BACKEND - UPLOAD: Đã lưu ảnh thành công tên: " + fileName);
                } catch (IOException e) {
                    System.out.println("LỖI UPLOAD FILE: " + e.getMessage());
                }
            } 
            // TH2: KHÔNG CHỌN FILE TẢI LÊN
            else {
                // Nếu ô input avatar cũng bị bỏ trống (không nhập link mạng) -> Đặt là null để JSP tự tạo ảnh chữ cái
                if (customer.getAvatar() == null || customer.getAvatar().trim().isEmpty()) {
                    customer.setAvatar(null); 
                }
                // (Nếu khách có dán link mạng internet vào ô input, nó sẽ tự động giữ nguyên link đó để lưu vào DB)
            }

            // 3. Lưu vào Database thông qua Service
            customerService.addCustomer(customer); 
            redirectAttributes.addFlashAttribute("successMessage", "Đã khởi tạo tài khoản khách hàng mới thành công!");
            return "redirect:/admin/customers"; 
            
        } catch (CustomerException e) {
            // Bắt lỗi nghiệp vụ (Ví dụ: Trùng Username, trùng Email,...)
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/admin/customers/add";
        } catch (Exception e) {
            // Bắt lỗi hệ thống / lỗi CSDL
            e.printStackTrace(); 
            redirectAttributes.addFlashAttribute("errorMessage", "Hệ thống gặp sự cố Database: " + e.getMessage());
            return "redirect:/admin/customers/add";
        }
    }
}