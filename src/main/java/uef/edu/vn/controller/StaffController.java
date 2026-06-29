package uef.edu.vn.controller;

import java.util.List;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import uef.edu.vn.exception.StaffException;
import uef.edu.vn.model.User;
import uef.edu.vn.model.UserRole;
import uef.edu.vn.service.StaffService;

@Controller
@RequestMapping("/admin")
public class StaffController {

    private final StaffService staffService;
    private final String path = "/WEB-INF/views/admin/";
    private final String pathView = "layout/admin-layout/main";

    @Autowired
    public StaffController(StaffService staffService) {
        this.staffService = staffService;
    }

    @GetMapping("/staffs")
    public String showStaffList(
            Model model,
            @RequestParam(value = "nameKeyword", required = false) String nameKeyword,
            @RequestParam(value = "contactKeyword", required = false) String contactKeyword,
            @RequestParam(value = "statusFilter", required = false, defaultValue = "ALL") String statusFilter,
            @RequestParam(value = "roleFilter", required = false) Integer roleFilter,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "dateFilterType", required = false) List<String> dateFilterType) {

        try {
            model.addAttribute("roles", staffService.getAllStaffRoles());
            List<UserRole> staffs;
            
            boolean isFiltering = (nameKeyword != null && !nameKeyword.trim().isEmpty()) ||
                                  (contactKeyword != null && !contactKeyword.trim().isEmpty()) ||
                                  (!statusFilter.equals("ALL")) ||
                                  (roleFilter != null && roleFilter > 0) ||
                                  (startDate != null && !startDate.trim().isEmpty()) ||
                                  (endDate != null && !endDate.trim().isEmpty());

            if (isFiltering) {
                staffs = staffService.filterStaffsAdvanced(nameKeyword, contactKeyword, statusFilter, roleFilter, startDate, endDate, dateFilterType);
                model.addAttribute("isFiltering", true);
            } else {
                staffs = staffService.getAllStaffs();
                model.addAttribute("isFiltering", false);
            }

            model.addAttribute("staffs", staffs);
            model.addAttribute("nameKeyword", nameKeyword);
            model.addAttribute("contactKeyword", contactKeyword);
            model.addAttribute("statusFilter", statusFilter);
            model.addAttribute("roleFilter", roleFilter);
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
            model.addAttribute("dateFilterType", dateFilterType);

            // Bổ sung thông điệp thành công mặc định nếu danh sách tải mượt mà (nếu cần thiết)
            if (!model.containsAttribute("successMessage") && isFiltering) {
                model.addAttribute("successMessage", "Đã cập nhật danh sách nhân sự theo bộ lọc!");
            }

        } catch (Exception e) {
            // Tương thích tuyệt đối với thuộc tính 'errorMessage' mà Frontend đang hứng qua cầu nối
            model.addAttribute("errorMessage", "Hệ thống không thể tải danh sách: " + e.getMessage());
        }

        model.addAttribute("view", "staffs");
        model.addAttribute("body", path + "staffs.jsp");
        return pathView;
    }

    @GetMapping("/staffs/add")
    public String showAddStaffForm(Model model) {
        if (!model.containsAttribute("staff")) {
            model.addAttribute("staff", new User());
        }
        model.addAttribute("roles", staffService.getAllStaffRoles());
        model.addAttribute("view", "staff_add");
        model.addAttribute("body", path + "staff_add.jsp");
        return pathView;
    }

    @PostMapping("/staffs/add")
    public String processAddStaff(@Valid User staff, BindingResult bindingResult, @RequestParam(value = "roleId", required = false, defaultValue = "0") int roleId, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            StringBuilder errorMsg = new StringBuilder("Lỗi nhập liệu: ");
            for (FieldError error : bindingResult.getFieldErrors()) {
                errorMsg.append(error.getDefaultMessage()).append(" | ");
            }
            // Loại bỏ dấu gạch đứng thừa ở cuối chuỗi thông báo
            if(errorMsg.length() > 3) {
                errorMsg.setLength(errorMsg.length() - 3);
            }
            // Flash Attribute đẩy thẳng thông tin lỗi sang trang Add để Toast Engine hiển thị ngay lập tức
            redirectAttributes.addFlashAttribute("errorMessage", errorMsg.toString());
            redirectAttributes.addFlashAttribute("staff", staff);
            return "redirect:/admin/staffs/add";
        }
        try {
            if (staff.getAvatar() == null || staff.getAvatar().trim().isEmpty()) {
                staff.setAvatar(null); 
            }
            staffService.addStaff(staff, roleId);
            // Flash Attribute truyền mượt qua redirect để trang danh sách kích hoạt Toast thành công
            redirectAttributes.addFlashAttribute("successMessage", "Thêm nhân sự mới '" + staff.getFullName() + "' thành công!");
            return "redirect:/admin/staffs";
        } catch (StaffException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            redirectAttributes.addFlashAttribute("staff", staff);
            return "redirect:/admin/staffs/add";
        }
    }

    @GetMapping("/staffs/detail/{id}")
    public String showStaffDetail(@PathVariable("id") int staffId, Model model, RedirectAttributes redirectAttributes) {
        try {
            UserRole staffRole = staffService.getStaffById(staffId);
            model.addAttribute("staffRole", staffRole);
            model.addAttribute("roles", staffService.getAllStaffRoles());
            model.addAttribute("currentRoleId", staffRole.getQuyen().getId_Role());

            model.addAttribute("view", "staff_detail");
            model.addAttribute("body", path + "staff_detail.jsp");
            return pathView;
        } catch (StaffException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Không thể xem chi tiết: " + e.getMessage());
            return "redirect:/admin/staffs";
        }
    }

    @PostMapping("/staffs/update")
    public String processUpdateStaff(User staff, @RequestParam(value = "roleId", required = false, defaultValue = "0") int roleId, RedirectAttributes redirectAttributes) {
        try {
            if (staff.getAvatar() == null || staff.getAvatar().trim().isEmpty()) {
                staff.setAvatar(null);
            }
            staffService.updateStaffFullInfo(staff, roleId);
            // Đồng bộ thông điệp thành công, hiển thị chính xác tên người được cập nhật
            redirectAttributes.addFlashAttribute("successMessage", "Cập nhật hồ sơ nhân sự '" + staff.getFullName() + "' thành công!");
        } catch (StaffException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Cập nhật thất bại: " + e.getMessage());
        }
        return "redirect:/admin/staffs/detail/" + staff.getId_User();
    }

    @PostMapping("/staffs/update-status")
    public String updateStaffStatus(@RequestParam("id_User") int staffId, @RequestParam("status") String status, RedirectAttributes redirectAttributes) {
        try {
            staffService.updateStaffStatus(staffId, status);
            String hanhDong = status.equals("Active") ? "mở khóa" : "khóa";
            redirectAttributes.addFlashAttribute("successMessage", "Hệ thống đã thực hiện " + hanhDong + " tài khoản nhân sự (ID: #" + staffId + ") thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi thay đổi trạng thái: " + e.getMessage());
        }
        return "redirect:/admin/staffs/detail/" + staffId;
    }

    @PostMapping("/staffs/reset-password")
    public String resetPassword(@RequestParam("id_User") int staffId, RedirectAttributes redirectAttributes) {
        try {
            staffService.resetPassword(staffId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã khôi phục mật khẩu mặc định (Pass@123) cho nhân sự thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi đặt lại mật khẩu: " + e.getMessage());
        }
        return "redirect:/admin/staffs/detail/" + staffId;
    }
}