package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class User {

    @Min(value = 0, message = "ID người dùng không được là số âm")
    private int id_User;

    @NotBlank(message = "Tên đăng nhập không được để trống")
    @Size(min = 4, max = 50, message = "Tên đăng nhập phải từ 4 đến 50 ký tự")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "Tên đăng nhập không hợp lệ (Chỉ chứa chữ cái, số và dấu gạch dưới, không khoảng trắng)")
    private String username;

    @NotBlank(message = "Mật khẩu không được để trống")
    @Pattern(regexp = "^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?\":{}|<>]).{6,15}$", 
             message = "Mật khẩu phải từ 6 đến 15 ký tự, bao gồm ít nhất 1 chữ in hoa và 1 ký tự đặc biệt (Ví dụ: Abc@123)")
    private String password;

    @NotBlank(message = "Họ và tên không được để trống")
    @Size(min = 2, max = 100, message = "Họ và tên không được vượt quá 100 ký tự và không được nhỏ hơn 2 kí tự")
    @Pattern(regexp = "^[\\p{L}\\s]+$", message = "Họ và tên chỉ được chứa chữ cái và khoảng trắng, không chứa số hay ký tự đặc biệt")
    private String fullName;

    
    private String avatar;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng (Ví dụ chuẩn: nguyenvan@gmail.com)")
    private String email;

    @NotBlank(message = "Số điện thoại không được để trống")
    @Pattern(regexp = "^(0|\\+84)[0-9]{9}$", message = "Số điện thoại không hợp lệ (Phải là số di động Việt Nam gồm 10 số, bắt đầu bằng 0 hoặc +84)")
    private String phone;
    
    @Valid 
    private List<Quyen> roles; 
    
    @PastOrPresent(message = "Ngày tạo tài khoản không được nằm trong tương lai")
    private Date createdAt;
    // BỔ SUNG: Thuộc tính updatedAt
    @PastOrPresent(message = "Ngày cập nhật không được nằm trong tương lai")
    private Date updatedAt;

    @NotBlank(message = "Trạng thái tài khoản không được để trống")
    private String status;

    @AssertTrue(message = "Lỗi bảo mật: Mật khẩu không được phép trùng với Tên đăng nhập!")
    public boolean isPasswordSafe() {
        if (this.username != null && this.password != null) {
            return !this.password.equals(this.username);
        }
        return true;
    }

    @AssertTrue(message = "Lỗi logic: Trạng thái tài khoản không hợp lệ! (Chỉ chấp nhận: Active, Locked)")
    public boolean isStatusValid() {
        if (this.status != null) {
            // Đã đồng bộ danh sách trạng thái cho khớp với CustomerServiceImpl
            List<String> validStatuses = Arrays.asList("Active", "Locked");
            return validStatuses.contains(this.status);
        }
        return true;
    }

    public User() {
        this.id_User = 0;
        this.username = "";
        this.password = "";
        this.fullName = "Chưa cập nhật";
        this.avatar = "default_avatar.png";
        this.email = "";
        this.phone = "";
        this.roles = new ArrayList<>(); 
        this.createdAt = new Date();
        this.status = "Active";
    }

    public User(int id_User, String username, String password, String fullName, String avatar, 
                String email, String phone, List<Quyen> roles, Date createdAt, String status) {
        this.id_User = id_User;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.avatar = avatar;
        this.email = email;
        this.phone = phone;
        this.roles = roles;
        this.createdAt = createdAt;
        this.status = status;
    }

    public boolean hasRole(String roleName) {
        if (this.roles == null || this.roles.isEmpty()) {
            return false;
        }
        return this.roles.stream().anyMatch(q -> q.getRoleName().equalsIgnoreCase(roleName));
    }
    
    private int totalBookings;
    private double totalSpent;

    public int getTotalBookings() { return totalBookings; }
    public void setTotalBookings(int totalBookings) { this.totalBookings = totalBookings; }

    public double getTotalSpent() { return totalSpent; }
    public void setTotalSpent(double totalSpent) { this.totalSpent = totalSpent; }

    public int getId_User() { return id_User; }
    public void setId_User(int id_User) { this.id_User = id_User; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public List<Quyen> getRoles() { return roles; }
    public void setRoles(List<Quyen> roles) { this.roles = roles; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}