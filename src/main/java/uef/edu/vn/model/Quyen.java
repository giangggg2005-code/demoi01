package uef.edu.vn.model;

import jakarta.validation.constraints.*;

public class Quyen {

    @Min(value = 0, message = "ID quyền không được là số âm")
    private int id_Role;

    @NotBlank(message = "Tên quyền không được để trống")
    @Size(min = 3, max = 50, message = "Tên quyền phải từ 3 đến 50 ký tự")
    @Pattern(regexp = "^[A-Z0-9_]+$", message = "Tên quyền không hợp lệ (Chỉ bao gồm chữ in hoa, số và dấu gạch dưới. Ví dụ: ADMIN, ROLE_USER, STAFF_01)")
    private String roleName;

    @NotBlank(message = "Mô tả quyền không được để trống để tránh nhầm lẫn tính năng")
    @Size(max = 250, message = "Mô tả quyền không được vượt quá 250 ký tự")
    private String description;

    @AssertTrue(message = "Lỗi bảo mật: Không được phép tạo quyền chứa từ khóa nhạy cảm hệ thống như 'ROOT' hoặc 'SUPER'!")
    public boolean isRoleNameSafe() {
        if (this.roleName != null) {
            String upperRole = this.roleName.toUpperCase();
            return !upperRole.contains("ROOT") && !upperRole.contains("SUPER");
        }
        return true;
    }

    public Quyen() {
        this.id_Role = 0;
        this.roleName = "";
        this.description = "";
    }

    public Quyen(int id_Role, String roleName, String description) {
        this.id_Role = id_Role;
        this.roleName = roleName;
        this.description = description;
    }

    public int getId_Role() { return id_Role; }
    public void setId_Role(int id_Role) { this.id_Role = id_Role; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}