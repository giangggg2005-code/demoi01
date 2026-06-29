package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.User;

@Repository
public class CustomerRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String BASE_SELECT_SQL =
    "SELECT u.id_User, u.username, u.password, u.fullName, u.avatar, u.email, u.phone, u.createdAt, u.updatedAt, u.status, " +
    "COALESCE(stats.totalBookings, 0) AS totalBookings, COALESCE(stats.totalSpent, 0) AS totalSpent " +
    "FROM `User` u " +
        "JOIN `UserRole` ur ON u.id_User = ur.id_User " +
        "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
        "LEFT JOIN ( " +
        "    SELECT userId, COUNT(id_Booking) AS totalBookings, SUM(totalAmount) AS totalSpent " +
        "    FROM `Booking` WHERE status = 'Completed' GROUP BY userId " +
        ") stats ON u.id_User = stats.userId " +
        "WHERE q.roleName IN ('CUSTOMER', 'Customer') AND ur.status = 'Active'";

    private User mapRow(ResultSet rs, int rowNum) throws SQLException {
        User u = new User();
        u.setId_User(rs.getInt("id_User"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password")); // Lấy password để hiển thị
        u.setFullName(rs.getString("fullName"));
        u.setAvatar(rs.getString("avatar"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));

        Timestamp createdAt = rs.getTimestamp("createdAt");
        if (createdAt != null) u.setCreatedAt(createdAt);

        // Lấy updatedAt
        Timestamp updatedAt = rs.getTimestamp("updatedAt");
        if (updatedAt != null) u.setUpdatedAt(updatedAt);

        u.setStatus(rs.getString("status"));
        u.setTotalBookings(rs.getInt("totalBookings"));
        u.setTotalSpent(rs.getDouble("totalSpent"));
        return u;
    }

    public List<User> findAll() {
        String sql = BASE_SELECT_SQL + " ORDER BY u.createdAt DESC";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public User findById(int customerId) {
        String sql = BASE_SELECT_SQL + " AND u.id_User = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, customerId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public User findByEmail(String email) {
        String sql = BASE_SELECT_SQL + " AND u.email = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, email);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public User findByUsername(String username) {
        String sql = BASE_SELECT_SQL + " AND u.username = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, username);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<User> findByStatus(String status) {
        String sql = BASE_SELECT_SQL + " AND u.status = ? ORDER BY u.createdAt DESC";
        return jdbcTemplate.query(sql, this::mapRow, status);
    }

    public List<User> searchByKeyword(String keyword) {
        String sql = BASE_SELECT_SQL +
            " AND (LOWER(u.fullName) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.phone) LIKE ? OR LOWER(u.username) LIKE ?) " +
            "ORDER BY u.fullName ASC";
        String pattern = "%" + keyword.toLowerCase().trim() + "%";
        return jdbcTemplate.query(sql, this::mapRow, pattern, pattern, pattern, pattern);
    }

    public List<User> findWithPagination(int limit, int offset) {
        String sql = BASE_SELECT_SQL + " ORDER BY u.createdAt DESC LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, this::mapRow, limit, offset);
    }

    public List<User> findNewCustomers(int limit) {
        String sql = BASE_SELECT_SQL + " ORDER BY u.createdAt DESC LIMIT ?";
        return jdbcTemplate.query(sql, this::mapRow, limit);
    }

    public List<User> findTopBySpending(int limit) {
        String sql = BASE_SELECT_SQL + " ORDER BY stats.totalSpent DESC, stats.totalBookings DESC LIMIT ?";
        return jdbcTemplate.query(sql, this::mapRow, limit);
    }

    public int countAll() {
        String sql = "SELECT COUNT(DISTINCT u.id_User) FROM `User` u " +
                     "JOIN `UserRole` ur ON u.id_User = ur.id_User " +
                     "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE q.roleName IN ('CUSTOMER', 'Customer') AND ur.status = 'Active'";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    public boolean isEmailTakenByOther(String email, int excludeCustomerId) {
        String sql = "SELECT COUNT(*) FROM `User` WHERE email = ? AND id_User != ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, email, excludeCustomerId);
        return count != null && count > 0;
    }

    public void update(User customer) {
        String sql = "UPDATE `User` SET fullName = ?, email = ?, phone = ?, avatar = ?, status = ? WHERE id_User = ?";
        jdbcTemplate.update(sql,
            customer.getFullName(),
            customer.getEmail(),
            customer.getPhone(),
            customer.getAvatar(),
            customer.getStatus(),
            customer.getId_User());
    }

    public void updateStatus(int customerId, String status) {
        String sql = "UPDATE `User` SET status = ? WHERE id_User = ?";
        jdbcTemplate.update(sql, status, customerId);
    }
    // =========================================================================
    // HÀM MỚI 1: Xóa khách hàng
    // =========================================================================
    public boolean deleteCustomer(int customerId) {
        String sql = "DELETE FROM `User` WHERE id_User = ?";
        return jdbcTemplate.update(sql, customerId) > 0;
    }
    
    // Thay thế hàm filterCustomersAdvanced bằng đoạn này
    public List<User> filterCustomersAdvanced(String nameKeyword, String contactKeyword, String status, Double minSpent, Double maxSpent, 
                                              String sortSpent, String startDate, String endDate, List<String> dateFilterType) {
        
        // Phân tích Checkbox thời gian
        boolean filterCreated = (dateFilterType == null || dateFilterType.isEmpty() || dateFilterType.contains("created")); 
        boolean filterSpending = (dateFilterType != null && dateFilterType.contains("spending"));

        // 1. Bảng phụ thống kê chi tiêu
        StringBuilder statsQuery = new StringBuilder("SELECT userId, COUNT(id_Booking) AS totalBookings, SUM(totalAmount) AS totalSpent FROM `Booking` WHERE status = 'Completed' ");
        
        if (filterSpending) {
            if (startDate != null && !startDate.trim().isEmpty()) {
                statsQuery.append(" AND bookingDate >= '").append(startDate.trim()).append(" 00:00:00' ");
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                statsQuery.append(" AND bookingDate <= '").append(endDate.trim()).append(" 23:59:59' ");
            }
        }
        statsQuery.append(" GROUP BY userId");

        // =====================================================================
        // 2. Query chính (ĐÃ FIX LỖI: BỔ SUNG u.password và u.updatedAt)
        // =====================================================================
        StringBuilder sql = new StringBuilder(
            "SELECT u.id_User, u.username, u.password, u.fullName, u.avatar, u.email, u.phone, u.createdAt, u.updatedAt, u.status, " +
            "COALESCE(stats.totalBookings, 0) AS totalBookings, COALESCE(stats.totalSpent, 0) AS totalSpent " +
            "FROM `User` u " +
            "JOIN `UserRole` ur ON u.id_User = ur.id_User " +
            "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
            "LEFT JOIN (" + statsQuery.toString() + ") stats ON u.id_User = stats.userId " +
            "WHERE q.roleName IN ('CUSTOMER', 'Customer') "
        );

        // Lọc Từ khóa theo Tên
        if (nameKeyword != null && !nameKeyword.trim().isEmpty()) {
            sql.append(" AND LOWER(u.fullName) LIKE LOWER('%").append(nameKeyword.trim()).append("%') ");
        }
        
        // Lọc Từ khóa theo Email hoặc Số điện thoại
        if (contactKeyword != null && !contactKeyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(u.email) LIKE LOWER('%").append(contactKeyword.trim()).append("%') " +
                       "OR u.phone LIKE '%").append(contactKeyword.trim()).append("%') ");
        }

        // Lọc Trạng thái
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND u.status = '").append(status.trim()).append("' ");
        }

        // Lọc Ngày tạo tài khoản
        if (filterCreated) {
            if (startDate != null && !startDate.trim().isEmpty()) {
                sql.append(" AND u.createdAt >= '").append(startDate.trim()).append(" 00:00:00' ");
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                sql.append(" AND u.createdAt <= '").append(endDate.trim()).append(" 23:59:59' ");
            }
        }

        // Lọc khoảng tiền (HAVING)
        boolean hasHaving = false;
        if (minSpent != null && minSpent >= 0) {
            sql.append(" HAVING totalSpent >= ").append(minSpent);
            hasHaving = true;
        }
        if (maxSpent != null && maxSpent >= 0) {
            sql.append(hasHaving ? " AND " : " HAVING ").append("totalSpent <= ").append(maxSpent);
        }

        // Sắp xếp
        if ("asc".equalsIgnoreCase(sortSpent)) {
            sql.append(" ORDER BY totalSpent ASC ");
        } else if ("desc".equalsIgnoreCase(sortSpent)) {
            sql.append(" ORDER BY totalSpent DESC ");
        } else {
            sql.append(" ORDER BY u.createdAt DESC ");
        }

        return jdbcTemplate.query(sql.toString(), this::mapRow);
    }
    // 1. Reset mật khẩu mặc định (VD: Pass@123)
    public void resetPassword(int customerId, String defaultPassword) {
        String sql = "UPDATE `User` SET password = ? WHERE id_User = ?";
        jdbcTemplate.update(sql, defaultPassword, customerId);
    }

   public void updateCustomerFullInfo(User customer) {
       // Đã thêm avatar = ? vào câu lệnh SQL
       String sql = "UPDATE `User` SET fullName = ?, email = ?, phone = ?, avatar = ? WHERE id_User = ?";
       
       jdbcTemplate.update(sql, 
           customer.getFullName(), 
           customer.getEmail(), 
           customer.getPhone(), 
           customer.getAvatar(), // <-- THÊM DÒNG NÀY ĐỂ LƯU TÊN ẢNH
           customer.getId_User());
    }

    // 3. Lấy lịch sử mua vé (Cho AJAX) - LẤY CẢ VÉ ĐÃ THANH TOÁN VÀ ĐÃ HOÀN TIỀN
    public List<java.util.Map<String, Object>> getBookingHistory(int userId) {
        String sql = "SELECT b.id_Booking, b.bookingDate, bd.price AS ticketPrice, t.id_Ticket, t.status AS ticketStatus, " +
                     "s.seatName, s.id_Seat, st.id_Showtime, st.showDate, st.startTime, m.title AS movieTitle, r.roomName " + 
                     "FROM `Booking` b " +
                     "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId " +
                     "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket " +
                     "JOIN `Seat` s ON t.seatId = s.id_Seat " +
                     "JOIN `Room` r ON s.roomId = r.id_Room " + 
                     "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     // MỞ RỘNG: Lấy cả hóa đơn Thành công/Đã hoàn và Vé Đã bán/Đã hoàn
                     "WHERE b.userId = ? AND b.status IN ('Completed', 'Refunded', 'Cancelled') " +
                     "AND t.status IN ('Sold', 'Refunded', 'Cancelled') " + 
                     "ORDER BY b.bookingDate DESC";
        return jdbcTemplate.queryForList(sql, userId);
    }
    public List<String> findRolesByUserId(int userId) {
        String sql = "SELECT q.roleName FROM `UserRole` ur " +
                     "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_User = ? AND ur.status = 'Active'";
        return jdbcTemplate.queryForList(sql, String.class, userId);
    }
    // HÀM MỚI: Lấy chi tiết thông tin bảng Quyen và UserRole
    public List<java.util.Map<String, Object>> getRoleDetailsByUserId(int userId) {
        String sql = "SELECT ur.id_UserRole, ur.status AS roleStatus, ur.createdAt AS roleCreatedAt, ur.updatedAt AS roleUpdatedAt, " +
                     "q.id_Role, q.roleName, q.description " +
                     "FROM `UserRole` ur " +
                     "JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE ur.id_User = ?";
        return jdbcTemplate.queryForList(sql, userId);
    }
    // =========================================================================
    // HÀM MỚI 1: Thêm khách hàng mới (Kèm theo tự động cấp quyền CUSTOMER)
    // =========================================================================
    public void addCustomer(User customer) {
        // Bước 1: Lưu thông tin vào bảng User
        String sqlUser = "INSERT INTO `User` (username, password, fullName, email, phone, avatar, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
                         
        org.springframework.jdbc.support.KeyHolder keyHolder = new org.springframework.jdbc.support.GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            java.sql.PreparedStatement ps = connection.prepareStatement(sqlUser, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, customer.getUsername());
            // Lưu ý: Nếu hệ thống có dùng Bcrypt, hãy mã hóa password ở Service trước khi truyền vào đây
            ps.setString(2, customer.getPassword()); 
            ps.setString(3, customer.getFullName());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            ps.setString(6, customer.getAvatar() != null ? customer.getAvatar() : "");
            ps.setString(7, customer.getStatus() != null ? customer.getStatus() : "Active");
            return ps;
        }, keyHolder);

        // Bước 2: Lấy ID user vừa tạo và Gán quyền CUSTOMER
        if (keyHolder.getKey() != null) {
            int newUserId = keyHolder.getKey().intValue();
            customer.setId_User(newUserId); // Gắn ngược lại vào object để trả về nếu cần
            
            // Tìm ID của quyền 'CUSTOMER'
            String sqlFindRole = "SELECT id_Role FROM `Quyen` WHERE roleName = 'CUSTOMER' OR roleName = 'Customer' LIMIT 1";
            try {
                Integer roleId = jdbcTemplate.queryForObject(sqlFindRole, Integer.class);
                if (roleId != null) {
                    // Gán quyền vào bảng UserRole
                    String sqlRole = "INSERT INTO `UserRole` (id_User, id_Role, status) VALUES (?, ?, 'Active')";
                    jdbcTemplate.update(sqlRole, newUserId, roleId);
                }
            } catch (EmptyResultDataAccessException e) {
                // Rơi vào chốt chặn Lớp 4
                throw new RuntimeException("Lỗi cấu trúc CSDL: Không tìm thấy nhóm quyền 'CUSTOMER' để gán cho tài khoản mới!");
            }
        }
    }

    // =========================================================================
    // HÀM MỚI 2: Kiểm tra trùng Username (Bổ trợ cho chốt chặn Lớp 3)
    // =========================================================================
    public boolean isUsernameTaken(String username) {
        String sql = "SELECT COUNT(*) FROM `User` WHERE username = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, username);
        return count != null && count > 0;
    }
    // =========================================================================
    // HÀM MỚI 3: Kiểm tra trùng Số điện thoại (Bổ trợ cho chốt chặn Lớp 3)
    // =========================================================================
    public boolean isPhoneTakenByOther(String phone, int excludeCustomerId) {
        String sql = "SELECT COUNT(*) FROM `User` WHERE phone = ? AND id_User != ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, phone, excludeCustomerId);
        return count != null && count > 0;
    }
}