package uef.edu.vn.service;

import java.util.List;
import uef.edu.vn.model.User;
import uef.edu.vn.model.Quyen;

public interface UserService {
    
    User authenticate(String username, String password);
    User registerUser(User user);
    
    void registerCustomer(User user) throws Exception;

    boolean lockAccount(int userId);
    boolean unlockAccount(int userId);
    List<User> getAllUsers();
    User getUserById(int userId);
    
    boolean grantRoleToUser(int userId, String roleName);
    boolean revokeRoleFromUser(int userId, String roleName);
    List<Quyen> getUserRoles(int userId);
    
    boolean changePassword(int userId, String oldPassword, String newPassword);
    boolean updateProfile(User user);
}