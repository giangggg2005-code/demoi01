package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.UserRole;
import uef.edu.vn.model.User;
import uef.edu.vn.model.Quyen;

@Repository
public class UserRoleRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private UserRole mapRow(ResultSet rs, int rowNum) throws SQLException {
        UserRole ur = new UserRole();
        ur.setId_UserRole(rs.getInt("id_UserRole"));
        ur.setStatus(rs.getString("status"));
        ur.setCreatedAt(rs.getTimestamp("createdAt"));
        ur.setUpdatedAt(rs.getTimestamp("updatedAt"));

        User u = new User();
        u.setId_User(rs.getInt("id_User"));
        u.setUsername(rs.getString("username"));
        u.setFullName(rs.getString("fullName"));
        u.setEmail(rs.getString("email"));
        ur.setUser(u);

        Quyen q = new Quyen();
        q.setId_Role(rs.getInt("id_Role"));
        q.setRoleName(rs.getString("roleName"));
        q.setDescription(rs.getString("description"));
        ur.setQuyen(q);

        return ur;
    }

    public List<UserRole> findAll() {
        String sql = "SELECT ur.*, u.username, u.fullName, u.email, q.roleName, q.description " +
                     "FROM `UserRole` ur " +
                     "INNER JOIN `User` u ON ur.id_User = u.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public UserRole findById(int id) {
        String sql = "SELECT ur.*, u.username, u.fullName, u.email, q.roleName, q.description " +
                     "FROM `UserRole` ur " +
                     "INNER JOIN `User` u ON ur.id_User = u.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_UserRole = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<UserRole> findByUserId(int userId) {
        String sql = "SELECT ur.*, u.username, u.fullName, u.email, q.roleName, q.description " +
                     "FROM `UserRole` ur " +
                     "INNER JOIN `User` u ON ur.id_User = u.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_User = ?";
        return jdbcTemplate.query(sql, this::mapRow, userId);
    }

    public UserRole findByUserAndRole(int userId, int roleId) {
        String sql = "SELECT ur.*, u.username, u.fullName, u.email, q.roleName, q.description " +
                     "FROM `UserRole` ur " +
                     "INNER JOIN `User` u ON ur.id_User = u.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_User = ? AND ur.id_Role = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, userId, roleId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public boolean checkUserHasRole(int userId, String roleName) {
        String sql = "SELECT COUNT(*) FROM `UserRole` ur " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_User = ? AND q.roleName = ? AND ur.status = 'Active'";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, userId, roleName);
        return count != null && count > 0;
    }

    public boolean revokeRole(int userId, int roleId) {
        String sql = "UPDATE `UserRole` SET status = 'Inactive', updatedAt = CURRENT_TIMESTAMP WHERE id_User = ? AND id_Role = ?";
        return jdbcTemplate.update(sql, userId, roleId) > 0;
    }

    public boolean restoreRole(int userId, int roleId) {
        String sql = "UPDATE `UserRole` SET status = 'Active', updatedAt = CURRENT_TIMESTAMP WHERE id_User = ? AND id_Role = ?";
        return jdbcTemplate.update(sql, userId, roleId) > 0;
    }
}