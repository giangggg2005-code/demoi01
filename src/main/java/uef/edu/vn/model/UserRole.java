package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

public class UserRole {

    @Min(value = 0, message = "ID cấp quyền không được là số âm")
    private int id_UserRole;

    @NotNull(message = "Đối tượng người dùng không được để trống")
    @Valid 
    private User user;       

    @NotNull(message = "Đối tượng quyền không được để trống")
    @Valid 
    private Quyen quyen;   

    @NotBlank(message = "Trạng thái cấp quyền không được để trống")
    private String status;

    @PastOrPresent(message = "Thời gian tạo không được nằm ở tương lai")
    private Timestamp createdAt;

    @PastOrPresent(message = "Thời gian cập nhật không được nằm ở tương lai")
    private Timestamp updatedAt;

    @AssertTrue(message = "Lỗi nghiêm trọng: Phải xác định rõ Người dùng (User ID > 0) và Quyền (Role ID > 0) để thực hiện gán!")
    public boolean isValidAssignment() {
        if (this.user != null && this.quyen != null) {
            return this.user.getId_User() > 0 && this.quyen.getId_Role() > 0;
        }
        return false; 
    }

    @AssertTrue(message = "Lỗi logic thời gian: Thời gian cập nhật (updatedAt) không thể diễn ra trước thời gian tạo (createdAt)!")
    public boolean isTimelineValid() {
        if (this.createdAt != null && this.updatedAt != null) {
            return !this.updatedAt.before(this.createdAt);
        }
        return true;
    }

    @AssertTrue(message = "Lỗi logic: Trạng thái cấp quyền không hợp lệ! (Chỉ chấp nhận: Active, Inactive, Revoked)")
    public boolean isStatusValid() {
        if (this.status != null) {
            List<String> validStatuses = Arrays.asList("Active", "Inactive", "Revoked");
            return validStatuses.contains(this.status);
        }
        return true;
    }

    public UserRole() {
        this.id_UserRole = 0;
        this.user = new User();        
        this.quyen = new Quyen();    
        this.status = "Active";
        this.createdAt = new Timestamp(System.currentTimeMillis());
        this.updatedAt = new Timestamp(System.currentTimeMillis());
    }

    public UserRole(int id_UserRole, User user, Quyen quyen, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id_UserRole = id_UserRole;
        this.user = user;
        this.quyen = quyen;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId_UserRole() { return id_UserRole; }
    public void setId_UserRole(int id_UserRole) { this.id_UserRole = id_UserRole; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Quyen getQuyen() { return quyen; }
    public void setQuyen(Quyen quyen) { this.quyen = quyen; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}