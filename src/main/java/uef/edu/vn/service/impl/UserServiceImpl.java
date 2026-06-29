package uef.edu.vn.service.impl;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.UserException;
import uef.edu.vn.model.Quyen;
import uef.edu.vn.model.User;
import uef.edu.vn.model.UserRole;
import uef.edu.vn.repository.UserRepository;
import uef.edu.vn.repository.QuyenRepository;
import uef.edu.vn.repository.UserRoleRepository;
import uef.edu.vn.service.UserService;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepo;
    private final QuyenRepository quyenRepo;
    private final UserRoleRepository userRoleRepo;

    @Autowired
    public UserServiceImpl(UserRepository userRepo, QuyenRepository quyenRepo, UserRoleRepository userRoleRepo) {
        this.userRepo = userRepo;
        this.quyenRepo = quyenRepo;
        this.userRoleRepo = userRoleRepo;
    }

    @Override
    public User authenticate(String username, String password) {
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            throw new UserException("Tên đăng nhập và mật khẩu không được để trống!");
        }

        User user = userRepo.findByUsername(username.trim());
        
        if (user == null) {
            throw new UserException("Tài khoản đăng nhập không tồn tại trên hệ thống!");
        }

        if ("Locked".equalsIgnoreCase(user.getStatus())) {
            throw new UserException("Tài khoản này đã bị khóa. Vui lòng liên hệ Admin để mở lại!");
        }
        if ("Inactive".equalsIgnoreCase(user.getStatus())) {
            throw new UserException("Tài khoản chưa được kích hoạt hoặc đã bị ngừng sử dụng!");
        }

        String hashedInputPassword = hashPassword(password);
        if (!password.equals(user.getPassword()) && !hashedInputPassword.equals(user.getPassword())) {
            throw new UserException("Mật khẩu đăng nhập không chính xác!");
        }

        return user;
    }

    @Override
    public User registerUser(User user) {
        if (userRepo.findByUsername(user.getUsername().trim()) != null) {
            throw new UserException("Tên đăng nhập đã được sử dụng!");
        }
        if (user.getEmail() != null && userRepo.findByEmail(user.getEmail().trim()) != null) {
            throw new UserException("Địa chỉ Email đã tồn tại trên hệ thống!");
        }

        user.setPassword(hashPassword(user.getPassword()));
        user.setStatus("Active");

        try {
            boolean isSaved = userRepo.save(user); 
            if (!isSaved) {
                throw new UserException("Lỗi hệ thống: Không thể khởi tạo dữ liệu tài khoản mới!");
            }

            User savedUser = userRepo.findByUsername(user.getUsername().trim());
            Quyen customerRole = quyenRepo.findByRoleName("Customer"); 
            if (customerRole != null && savedUser != null) {
                userRepo.assignRoleToUser(savedUser.getId_User(), customerRole.getId_Role());
            }

            return savedUser;
        } catch (DataAccessException e) {
            throw new UserException("Lỗi CSDL khi đăng ký người dùng: " + e.getMessage());
        }
    }

    @Override
    public void registerCustomer(User user) throws Exception {
        if (userRepo.findByUsername(user.getUsername()) != null) {
            throw new Exception("Tên đăng nhập đã tồn tại trong hệ thống!");
        }
        if (userRepo.findByEmail(user.getEmail()) != null) {
            throw new Exception("Email này đã được sử dụng!");
        }
        
        user.setPassword(hashPassword(user.getPassword()));
        
        int userId = userRepo.saveCustomerAndGetId(user);
        userRepo.assignCustomerRole(userId);
    }

    @Override
    public boolean lockAccount(int userId) {
        if (userRepo.findById(userId) == null) throw new UserException("Không tìm thấy người dùng!");
        return userRepo.changeStatus(userId, "Locked");
    }

    @Override
    public boolean unlockAccount(int userId) {
        if (userRepo.findById(userId) == null) throw new UserException("Không tìm thấy người dùng!");
        return userRepo.changeStatus(userId, "Active");
    }

    @Override
    public List<User> getAllUsers() {
        return userRepo.findAll();
    }

    @Override
    public User getUserById(int userId) {
        return userRepo.findById(userId);
    }

    @Override
    public boolean grantRoleToUser(int userId, String roleName) {
        Quyen role = quyenRepo.findByRoleName(roleName);
        if (role == null) throw new UserException("Quyền hạn không tồn tại!");

        UserRole existingLink = userRoleRepo.findByUserAndRole(userId, role.getId_Role());
        if (existingLink != null) {
            if ("Inactive".equalsIgnoreCase(existingLink.getStatus())) {
                return userRoleRepo.restoreRole(userId, role.getId_Role());
            }
            return true; 
        }
        return userRepo.assignRoleToUser(userId, role.getId_Role());
    }

    @Override
    public boolean revokeRoleFromUser(int userId, String roleName) {
        Quyen role = quyenRepo.findByRoleName(roleName);
        if (role == null) throw new UserException("Không tìm thấy quyền!");

        if ("ADMIN".equalsIgnoreCase(roleName) || "Admin".equalsIgnoreCase(roleName)) {
            User user = userRepo.findById(userId);
            if (user != null && user.getRoles().size() <= 1) {
                throw new UserException("Lỗi an toàn: Không thể thu hồi quyền ADMIN cuối cùng!");
            }
        }
        return userRoleRepo.revokeRole(userId, role.getId_Role());
    }

    @Override
    public List<Quyen> getUserRoles(int userId) {
        return quyenRepo.getRolesByUserId(userId);
    }

    @Override
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        User user = userRepo.findById(userId);
        if (user == null) throw new UserException("Người dùng không hợp lệ!");

        String hashedOld = hashPassword(oldPassword);
        if (!oldPassword.equals(user.getPassword()) && !hashedOld.equals(user.getPassword())) {
            throw new UserException("Mật khẩu hiện tại không chính xác!");
        }
        user.setPassword(hashPassword(newPassword));
        return userRepo.update(user);
    }

    @Override
    public boolean updateProfile(User user) {
        User existingUser = userRepo.findById(user.getId_User());
        if (existingUser == null) throw new UserException("Không tìm thấy tài khoản!");

        User checkEmail = userRepo.findByEmail(user.getEmail());
        if (checkEmail != null && checkEmail.getId_User() != user.getId_User()) {
            throw new UserException("Địa chỉ email đã thuộc về người khác!");
        }

        existingUser.setFullName(user.getFullName());
        existingUser.setEmail(user.getEmail());
        existingUser.setPhone(user.getPhone());
        existingUser.setAvatar(user.getAvatar());
        return userRepo.update(existingUser);
    }

    private String hashPassword(String originalPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(originalPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Lỗi hệ thống mã hóa: " + e.getMessage());
        }
    }
}