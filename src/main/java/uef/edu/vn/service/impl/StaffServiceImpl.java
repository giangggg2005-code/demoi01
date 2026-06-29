package uef.edu.vn.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.StaffException;
import uef.edu.vn.model.Quyen;
import uef.edu.vn.model.User;
import uef.edu.vn.model.UserRole;
import uef.edu.vn.repository.StaffRepository;
import uef.edu.vn.service.StaffService;

@Service
public class StaffServiceImpl implements StaffService {

    private final StaffRepository staffRepo;

    @Autowired
    public StaffServiceImpl(StaffRepository staffRepo) {
        this.staffRepo = staffRepo;
    }

    @Override
    public List<UserRole> getAllStaffs() {
        return staffRepo.findAll();
    }

    @Override
    public UserRole getStaffById(int staffId) {
        if (staffId <= 0) throw new StaffException("ID nhân sự không hợp lệ!");
        UserRole staffRole = staffRepo.findById(staffId);
        if (staffRole == null) throw new StaffException("Không tìm thấy thông tin quyền hoặc tài khoản nhân sự với ID: " + staffId);
        return staffRole;
    }

    @Override
    public List<Quyen> getAllStaffRoles() {
        return staffRepo.getAllStaffRoles();
    }

    @Override
    public boolean addStaff(User staff, int roleId) {
        if (roleId <= 0) throw new StaffException("Vui lòng chọn chức vụ cho nhân sự!");
        if (staff.getUsername() != null && staffRepo.isUsernameTaken(staff.getUsername().trim())) {
            throw new StaffException("Tên đăng nhập '" + staff.getUsername() + "' đã tồn tại!");
        }
        if (staff.getEmail() != null && staffRepo.isEmailTakenByOther(staff.getEmail().trim(), 0)) {
            throw new StaffException("Email '" + staff.getEmail() + "' đã được sử dụng!");
        }
        if (staff.getPhone() != null && staffRepo.isPhoneTakenByOther(staff.getPhone().trim(), 0)) {
            throw new StaffException("Số điện thoại '" + staff.getPhone() + "' đã được sử dụng!");
        }

        try {
            staffRepo.addStaff(staff, roleId);
            return true;
        } catch (DataAccessException e) {
            throw new StaffException("Lỗi CSDL khi thêm nhân sự: " + e.getMessage());
        }
    }

    @Override
    public boolean updateStaffFullInfo(User staff, int roleId) {
        if (roleId <= 0) throw new StaffException("Vui lòng chọn chức vụ hợp lệ!");
        if (staff.getEmail() != null && staffRepo.isEmailTakenByOther(staff.getEmail().trim(), staff.getId_User())) {
            throw new StaffException("Email '" + staff.getEmail() + "' đã thuộc về nhân sự khác!");
        }
        if (staff.getPhone() != null && staffRepo.isPhoneTakenByOther(staff.getPhone().trim(), staff.getId_User())) {
            throw new StaffException("Số điện thoại '" + staff.getPhone() + "' đã thuộc về nhân sự khác!");
        }

        try {
            staffRepo.updateStaffFullInfo(staff, roleId);
            return true;
        } catch (DataAccessException e) {
            throw new StaffException("Lỗi CSDL khi cập nhật: " + e.getMessage());
        }
    }

    @Override
    public boolean updateStaffStatus(int staffId, String status) {
        try {
            staffRepo.updateStaffStatus(staffId, status);
            return true;
        } catch (DataAccessException e) {
            // Chuyển đổi lỗi thô của CSDL thành StaffException thân thiện với giao diện
            throw new StaffException("Lỗi hệ thống: Không thể cập nhật trạng thái tài khoản vào CSDL!");
        }
    }

    @Override
    public boolean resetPassword(int staffId) {
        try {
            staffRepo.resetPassword(staffId, "Pass@123"); 
            return true;
        } catch (DataAccessException e) {
            // Chuyển đổi lỗi thô của CSDL thành StaffException thân thiện với giao diện
            throw new StaffException("Lỗi hệ thống: Không thể khôi phục mật khẩu trên cơ sở dữ liệu!");
        }
    }

    @Override
    public List<UserRole> filterStaffsAdvanced(String nameKeyword, String contactKeyword, String status, Integer roleId, String startDate, String endDate, List<String> dateFilterType) {
        return staffRepo.filterStaffsAdvanced(nameKeyword, contactKeyword, status, roleId, startDate, endDate, dateFilterType);
    }
}