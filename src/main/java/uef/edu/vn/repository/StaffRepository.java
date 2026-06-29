package uef.edu.vn.repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Quyen;
import uef.edu.vn.model.User;
import uef.edu.vn.model.UserRole;

@Repository
public class StaffRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // ĐÃ FIX CRASH: Đồng bộ GROUP_CONCAT cho cả tên quyền và ngày cấp quyền.
    // ORDER BY q.id_Role giúp mảng tên quyền và mảng ngày tháng khớp vị trí 1-1 với nhau trên JSP.
    private static final String BASE_SELECT_SQL =
        "SELECT u.id_User, MAX(u.username) AS username, MAX(u.password) AS password, MAX(u.fullName) AS fullName, " +
        "MAX(u.avatar) AS avatar, MAX(u.email) AS email, MAX(u.phone) AS phone, " +
        "MAX(u.createdAt) AS userCreatedAt, MAX(u.updatedAt) AS userUpdatedAt, MAX(u.status) AS userStatus, " +
        "MAX(q.id_Role) AS id_Role, " +
        "GROUP_CONCAT(q.roleName ORDER BY q.id_Role ASC SEPARATOR ',') AS roleName, " +
        "GROUP_CONCAT(DATE_FORMAT(ur.createdAt, '%d/%m/%Y') ORDER BY q.id_Role ASC SEPARATOR ',') AS description, " +
        "MAX(ur.id_UserRole) AS id_UserRole, MAX(ur.status) AS roleStatus, " +
        "MAX(ur.createdAt) AS roleCreatedAt, MAX(ur.updatedAt) AS roleUpdatedAt " +
        "FROM `User` u " +
        "JOIN `UserRole` ur ON u.id_User = ur.id_User " +
        "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
        "WHERE q.roleName IN ('ADMIN', 'MANAGER', 'TICKETSELLER') ";

    private RowMapper<UserRole> staffRowMapper = (rs, rowNum) -> {
        User user = new User();
        user.setId_User(rs.getInt("id_User"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("fullName"));
        user.setAvatar(rs.getString("avatar"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setCreatedAt(rs.getTimestamp("userCreatedAt"));
        user.setUpdatedAt(rs.getTimestamp("userUpdatedAt"));
        user.setStatus(rs.getString("userStatus"));

        Quyen quyen = new Quyen();
        quyen.setId_Role(rs.getInt("id_Role"));
        // roleName giờ sẽ chứa chuỗi VD: "ADMIN,MANAGER"
        quyen.setRoleName(rs.getString("roleName"));
        // description giờ sẽ chứa chuỗi ngày VD: "01/01/2025,15/06/2026"
        quyen.setDescription(rs.getString("description"));

        UserRole userRole = new UserRole();
        userRole.setId_UserRole(rs.getInt("id_UserRole"));
        userRole.setUser(user);
        userRole.setQuyen(quyen);
        userRole.setStatus(rs.getString("roleStatus"));
        userRole.setCreatedAt(rs.getTimestamp("roleCreatedAt"));
        userRole.setUpdatedAt(rs.getTimestamp("roleUpdatedAt"));

        return userRole;
    };

    public List<UserRole> findAll() {
        // Gom nhóm theo id_User để không bị nhân đôi dòng
        String sql = BASE_SELECT_SQL + " AND ur.status = 'Active' GROUP BY u.id_User ORDER BY MAX(u.createdAt) DESC";
        return jdbcTemplate.query(sql, staffRowMapper);
    }

    public UserRole findById(int staffId) {
        String sql = BASE_SELECT_SQL + " AND u.id_User = ? AND ur.status = 'Active' GROUP BY u.id_User";
        try {
            return jdbcTemplate.queryForObject(sql, staffRowMapper, staffId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Quyen> getAllStaffRoles() {
        // Ở hàm này description vẫn lấy từ bảng Quyen bình thường nên dropdown Thêm/Sửa vẫn hiện đầy đủ
        String sql = "SELECT id_Role, roleName, description FROM `Quyen` WHERE roleName IN ('ADMIN', 'MANAGER', 'TICKETSELLER') ORDER BY id_Role ASC";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            return new Quyen(rs.getInt("id_Role"), rs.getString("roleName"), rs.getString("description"));
        });
    }

    public List<UserRole> filterStaffsAdvanced(String nameKeyword, String contactKeyword, String status, Integer roleId, String startDate, String endDate, List<String> dateFilterType) {
        StringBuilder sql = new StringBuilder(BASE_SELECT_SQL);
        sql.append(" AND ur.status = 'Active' "); 
        List<Object> params = new ArrayList<>();

        if (nameKeyword != null && !nameKeyword.trim().isEmpty()) {
            sql.append(" AND u.fullName LIKE ? ");
            params.add("%" + nameKeyword.trim() + "%");
        }

        if (contactKeyword != null && !contactKeyword.trim().isEmpty()) {
            sql.append(" AND (u.email LIKE ? OR u.phone LIKE ? OR u.username LIKE ?) ");
            String kw = "%" + contactKeyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }

        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append(" AND u.status = ? ");
            params.add(status.trim());
        }

        if (roleId != null && roleId > 0) {
            sql.append(" AND q.id_Role = ? ");
            params.add(roleId);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            if (dateFilterType != null && !dateFilterType.isEmpty()) {
                sql.append(" AND (");
                boolean first = true;
                for (String dt : dateFilterType) {
                    if (!first) sql.append(" OR ");
                    if ("userCreatedAt".equals(dt)) { sql.append(" DATE(u.createdAt) >= ? "); params.add(startDate); first = false; }
                    else if ("userUpdatedAt".equals(dt)) { sql.append(" DATE(u.updatedAt) >= ? "); params.add(startDate); first = false; }
                    else if ("roleCreatedAt".equals(dt)) { sql.append(" DATE(ur.createdAt) >= ? "); params.add(startDate); first = false; }
                    else if ("roleUpdatedAt".equals(dt)) { sql.append(" DATE(ur.updatedAt) >= ? "); params.add(startDate); first = false; }
                }
                sql.append(") ");
            } else {
                sql.append(" AND DATE(u.createdAt) >= ? ");
                params.add(startDate);
            }
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            if (dateFilterType != null && !dateFilterType.isEmpty()) {
                sql.append(" AND (");
                boolean first = true;
                for (String dt : dateFilterType) {
                    if (!first) sql.append(" OR ");
                    if ("userCreatedAt".equals(dt)) { sql.append(" DATE(u.createdAt) <= ? "); params.add(endDate); first = false; }
                    else if ("userUpdatedAt".equals(dt)) { sql.append(" DATE(u.updatedAt) <= ? "); params.add(endDate); first = false; }
                    else if ("roleCreatedAt".equals(dt)) { sql.append(" DATE(ur.createdAt) <= ? "); params.add(endDate); first = false; }
                    else if ("roleUpdatedAt".equals(dt)) { sql.append(" DATE(ur.updatedAt) <= ? "); params.add(endDate); first = false; }
                }
                sql.append(") ");
            } else {
                sql.append(" AND DATE(u.createdAt) <= ? ");
                params.add(endDate);
            }
        }

        // Gom nhóm cuối cùng
        sql.append(" GROUP BY u.id_User ORDER BY MAX(u.createdAt) DESC");
        return jdbcTemplate.query(sql.toString(), staffRowMapper, params.toArray());
    }

    public void addStaff(User staff, int roleId) {
        String sqlUser = "INSERT INTO `User` (username, password, fullName, avatar, email, phone, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, staff.getUsername());
            ps.setString(2, staff.getPassword()); 
            ps.setString(3, staff.getFullName());
            ps.setString(4, staff.getAvatar());
            ps.setString(5, staff.getEmail());
            ps.setString(6, staff.getPhone());
            ps.setString(7, "Active");
            return ps;
        }, keyHolder);

        if (keyHolder.getKey() != null) {
            int newUserId = keyHolder.getKey().intValue();
            String sqlRole = "INSERT INTO `UserRole` (id_User, id_Role, status) VALUES (?, ?, 'Active')";
            jdbcTemplate.update(sqlRole, newUserId, roleId);
        }
    }

    public void updateStaffFullInfo(User staff, int newRoleId) {
        String sqlUser = "UPDATE `User` SET fullName = ?, avatar = ?, email = ?, phone = ? WHERE id_User = ?";
        jdbcTemplate.update(sqlUser, staff.getFullName(), staff.getAvatar(), staff.getEmail(), staff.getPhone(), staff.getId_User());

        jdbcTemplate.update("UPDATE `UserRole` SET status = 'Locked' WHERE id_User = ?", staff.getId_User());
        int count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM `UserRole` WHERE id_User = ? AND id_Role = ?", Integer.class, staff.getId_User(), newRoleId);
        
        if (count > 0) {
            jdbcTemplate.update("UPDATE `UserRole` SET status = 'Active' WHERE id_User = ? AND id_Role = ?", staff.getId_User(), newRoleId);
        } else {
            jdbcTemplate.update("INSERT INTO `UserRole` (id_User, id_Role, status) VALUES (?, ?, 'Active')", staff.getId_User(), newRoleId);
        }
    }

    public void updateStaffStatus(int id, String status) {
        jdbcTemplate.update("UPDATE `User` SET status = ? WHERE id_User = ?", status, id);
    }

    public void resetPassword(int id, String encodedDefaultPass) {
        jdbcTemplate.update("UPDATE `User` SET password = ? WHERE id_User = ?", encodedDefaultPass, id);
    }

    public boolean isUsernameTaken(String username) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM `User` WHERE username = ?", Integer.class, username) > 0;
    }
    public boolean isEmailTakenByOther(String email, int excludeUserId) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM `User` WHERE email = ? AND id_User != ?", Integer.class, email, excludeUserId) > 0;
    }
    public boolean isPhoneTakenByOther(String phone, int excludeUserId) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM `User` WHERE phone = ? AND id_User != ?", Integer.class, phone, excludeUserId) > 0;
    }
}