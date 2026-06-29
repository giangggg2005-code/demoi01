package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Quyen;

@Repository
public class QuyenRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Quyen mapRow(ResultSet rs, int rowNum) throws SQLException {
        Quyen q = new Quyen();
        q.setId_Role(rs.getInt("id_Role"));
        q.setRoleName(rs.getString("roleName"));
        q.setDescription(rs.getString("description"));
        return q;
    }

    public List<Quyen> findAll() {
        String sql = "SELECT * FROM `Quyen`";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public Quyen findById(int id) {
        String sql = "SELECT * FROM `Quyen` WHERE id_Role = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public void save(Quyen q) {
        String sql = "INSERT INTO `Quyen` (roleName, description) VALUES (?, ?)";
        jdbcTemplate.update(sql, q.getRoleName(), q.getDescription());
    }

    public void update(Quyen q) {
        String sql = "UPDATE `Quyen` SET roleName = ?, description = ? WHERE id_Role = ?";
        jdbcTemplate.update(sql, q.getRoleName(), q.getDescription(), q.getId_Role());
    }

    public void deleteById(int id) {
        String sql = "DELETE FROM `Quyen` WHERE id_Role = ?";
        jdbcTemplate.update(sql, id);
    }

    public Quyen findByRoleName(String roleName) {
        String sql = "SELECT * FROM `Quyen` WHERE roleName = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, roleName);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Quyen> getRolesByUserId(int userId) {
        // Đã sửa lại khớp đúng tên cột id_Role và id_User trong bảng UserRole
        String sql = "SELECT q.* FROM `Quyen` q " +
                     "INNER JOIN `UserRole` ur ON q.id_Role = ur.id_Role " +
                     "WHERE ur.id_User = ? AND ur.status = 'Active'";
        return jdbcTemplate.query(sql, this::mapRow, userId);
    }
}