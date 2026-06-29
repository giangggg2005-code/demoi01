package uef.edu.vn.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.User;
import uef.edu.vn.model.Quyen;

@Repository
public class UserRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private List<Quyen> fetchRolesForUser(int userId) {
        String sql = "SELECT q.id_Role, q.roleName, q.description FROM `Quyen` q " +
                     "JOIN `UserRole` ur ON q.id_Role = ur.id_Role " +
                     "WHERE ur.id_User = ? AND ur.status = 'Active'";
        
        // ĐÃ SỬA: Truyền userId vào lệnh query để không bị lỗi thiếu tham số
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Quyen q = new Quyen();
            q.setId_Role(rs.getInt("id_Role"));
            q.setRoleName(rs.getString("roleName"));
            q.setDescription(rs.getString("description"));
            return q;
        }, userId); 
    }

    private User mapRow(ResultSet rs, int rowNum) throws SQLException {
        User u = new User();
        u.setId_User(rs.getInt("id_User"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("fullName"));
        u.setAvatar(rs.getString("avatar"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        
        Timestamp createdAt = rs.getTimestamp("createdAt");
        if (createdAt != null) u.setCreatedAt(createdAt);
        
        u.setStatus(rs.getString("status"));
        u.setRoles(fetchRolesForUser(u.getId_User()));
        return u;
    }

    public User findByUsername(String username) {
        String sql = "SELECT * FROM `User` WHERE username = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, username);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM `User` WHERE email = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, email);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public boolean save(User u) {
        String sql = "INSERT INTO `User` (username, password, fullName, avatar, email, phone, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, u.getUsername(), u.getPassword(), u.getFullName(), u.getAvatar(), u.getEmail(), u.getPhone(), u.getStatus()) > 0;
    }

    public boolean update(User u) {
        String sql = "UPDATE `User` SET fullName = ?, email = ?, phone = ?, avatar = ?, password = ?, status = ? WHERE id_User = ?";
        return jdbcTemplate.update(sql, u.getFullName(), u.getEmail(), u.getPhone(), u.getAvatar(), u.getPassword(), u.getStatus(), u.getId_User()) > 0;
    }

    public List<User> findAll() {
        String sql = "SELECT * FROM `User`";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public User findById(int id) {
        String sql = "SELECT * FROM `User` WHERE id_User = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<User> findByRole(String roleName) {
        String sql = "SELECT u.* FROM `User` u " +
                     "JOIN `UserRole` ur ON u.id_User = ur.id_User " +
                     "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE q.roleName = ?";
        return jdbcTemplate.query(sql, this::mapRow, roleName);
    }

    public User login(String username, String password) {
        String sql = "SELECT * FROM `User` WHERE username = ? AND password = ? AND status = 'Active'";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, username, password);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public boolean changeStatus(int userId, String newStatus) {
        String sql = "UPDATE `User` SET status = ? WHERE id_User = ?";
        return jdbcTemplate.update(sql, newStatus, userId) > 0;
    }

    public boolean assignRoleToUser(int userId, int roleId) {
        String sql = "INSERT INTO `UserRole` (id_User, id_Role, status, createdAt, updatedAt) VALUES (?, ?, 'Active', NOW(), NOW())";
        return jdbcTemplate.update(sql, userId, roleId) > 0;
    }

    public boolean revokeRoleFromUser(int userId, int roleId) {
        String sql = "UPDATE `UserRole` SET status = 'Inactive', updatedAt = NOW() WHERE id_User = ? AND id_Role = ?";
        return jdbcTemplate.update(sql, userId, roleId) > 0;
    }
    public int saveCustomerAndGetId(User u) {
    String sql = "INSERT INTO `User` (username, password, fullName, avatar, email, phone, status, createdAt) VALUES (?, ?, ?, ?, ?, ?, 'Active', NOW())";
    KeyHolder keyHolder = new GeneratedKeyHolder();
    
    jdbcTemplate.update(connection -> {
        PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, u.getUsername());
        ps.setString(2, u.getPassword()); 
        ps.setString(3, u.getFullName());
        ps.setString(4, u.getAvatar() != null ? u.getAvatar() : "default_avatar.png");
        ps.setString(5, u.getEmail());
        ps.setString(6, u.getPhone());
        return ps;
    }, keyHolder);
    
    return keyHolder.getKey().intValue();
}

public void assignCustomerRole(int userId) {
    String sql = "INSERT INTO `UserRole` (id_User, id_Role, status, createdAt, updatedAt) VALUES (?, 4, 'Active', NOW(), NOW())";
    jdbcTemplate.update(sql, userId);
}
}