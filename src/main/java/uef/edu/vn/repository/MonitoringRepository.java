package uef.edu.vn.repository;

import java.util.ArrayList;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public class MonitoringRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Hàm phụ trợ (Helper) để chuyển đổi từ tham số 'timeframe' sang định dạng DATE_FORMAT tương ứng trong MySQL
     */
    private String getDateFormatByTimeframe(String timeframe) {
        if (timeframe == null) return "%Y-%m-%d";
        switch (timeframe.toUpperCase()) {
            case "DAY": return "%Y-%m-%d";
            case "WEEK": return "%Y-W%v";
            case "MONTH": return "%Y-%m";
            case "YEAR": return "%Y";
            default: return "%Y-%m-%d";
        }
    }

    /**
     * 1. THỐNG KÊ TÀI KHOẢN GIA NHẬP MỚI (LINE CHART) CÓ BỘ LỌC NGÀY VÀ TIMEFRAME
     */
    public List<Map<String, Object>> getNewUserRegistrationStats(String startDate, String endDate, String timeframe) {
        String format = getDateFormatByTimeframe(timeframe);
        String sql = "SELECT DATE_FORMAT(u.createdAt, '" + format + "') AS label, COUNT(*) AS value " +
                     "FROM `User` u WHERE 1=1 ";
        if (startDate != null && !startDate.trim().isEmpty()) { sql += " AND DATE(u.createdAt) >= '" + startDate + "' "; }
        if (endDate != null && !endDate.trim().isEmpty()) { sql += " AND DATE(u.createdAt) <= '" + endDate + "' "; }
        sql += " GROUP BY DATE_FORMAT(u.createdAt, '" + format + "') ORDER BY MIN(u.createdAt) ASC";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * 2. BIỂU ĐỒ SỐ LƯỢNG GIAO DỊCH TĂNG TRƯỞNG (LINE CHART) CÓ TIMEFRAME
     */
    public List<Map<String, Object>> getTransactionGrowthTrend(String startDate, String endDate, String timeframe) {
        String format = getDateFormatByTimeframe(timeframe);
        String sql = "SELECT DATE_FORMAT(bookingDate, '" + format + "') AS label, COUNT(*) AS value " +
                     "FROM `Booking` WHERE status = 'Completed' ";
        if (startDate != null && !startDate.trim().isEmpty()) { sql += " AND DATE(bookingDate) >= '" + startDate + "' "; }
        if (endDate != null && !endDate.trim().isEmpty()) { sql += " AND DATE(bookingDate) <= '" + endDate + "' "; }
        sql += " GROUP BY DATE_FORMAT(bookingDate, '" + format + "') ORDER BY MIN(bookingDate) ASC";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * 3. DANH SÁCH TÀI KHOẢN MỚI THAM GIA
     * BỔ SUNG: Tách biệt 3 trường tìm kiếm chạy đồng thời, lọc kết hợp song song với lọc ngày.
     */
    public List<Map<String, Object>> getNewUsersList(String type, String startDate, String endDate, 
                                                     String searchName, String searchEmail, String searchPhone) {
        String sql = "SELECT DISTINCT u.id_User, u.username, u.fullName, u.email, u.phone, u.createdAt, u.status, q.roleName " +
                     "FROM `User` u " +
                     "INNER JOIN `UserRole` ur ON u.id_User = ur.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role WHERE 1=1 ";
                     
        List<Object> params = new ArrayList<>();
        
        if ("CUSTOMER".equalsIgnoreCase(type)) {
            sql += " AND q.roleName = 'CUSTOMER' ";
        } else {
            sql += " AND q.roleName IN ('ADMIN', 'MANAGER', 'TICKETSELLER') ";
        }
        
        // --- Kết hợp Bộ lọc Tổng thời gian ---
        if (startDate != null && !startDate.trim().isEmpty()) { 
            sql += " AND DATE(u.createdAt) >= ? "; 
            params.add(startDate);
        }
        if (endDate != null && !endDate.trim().isEmpty()) { 
            sql += " AND DATE(u.createdAt) <= ? "; 
            params.add(endDate);
        }
        
        // --- Kết hợp đồng thời 3 bộ lọc con (Ràng buộc logic AND chặt chẽ) ---
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql += " AND u.fullName LIKE ? ";
            params.add("%" + searchName.trim() + "%");
        }
        if (searchEmail != null && !searchEmail.trim().isEmpty()) {
            sql += " AND u.email LIKE ? ";
            params.add("%" + searchEmail.trim() + "%");
        }
        if (searchPhone != null && !searchPhone.trim().isEmpty()) {
            sql += " AND u.phone LIKE ? ";
            params.add("%" + searchPhone.trim() + "%");
        }
        
        sql += " ORDER BY u.createdAt DESC";
        return jdbcTemplate.queryForList(sql, params.toArray());
    }

    /**
     * 4. DANH SÁCH TÀI KHOẢN VỪA CẬP NHẬT THÔNG TIN
     * BỔ SUNG: Tách biệt 3 trường tìm kiếm chạy đồng thời, lọc kết hợp song song với lọc ngày.
     */
    public List<Map<String, Object>> getRecentProfileUpdates(String startDate, String endDate, 
                                                             String searchName, String searchEmail, String searchPhone) {
        String sql = "SELECT u.id_User, u.username, u.fullName, u.email, u.phone, u.updatedAt, u.createdAt, u.status " +
                     "FROM `User` u WHERE u.updatedAt > u.createdAt ";
                     
        List<Object> params = new ArrayList<>();
        
        // --- Kết hợp Bộ lọc Tổng thời gian ---
        if (startDate != null && !startDate.trim().isEmpty()) { 
            sql += " AND DATE(u.updatedAt) >= ? "; 
            params.add(startDate);
        }
        if (endDate != null && !endDate.trim().isEmpty()) { 
            sql += " AND DATE(u.updatedAt) <= ? "; 
            params.add(endDate);
        }
        
        // --- Kết hợp đồng thời 3 bộ lọc con (Ràng buộc logic AND chặt chẽ) ---
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql += " AND u.fullName LIKE ? ";
            params.add("%" + searchName.trim() + "%");
        }
        if (searchEmail != null && !searchEmail.trim().isEmpty()) {
            sql += " AND u.email LIKE ? ";
            params.add("%" + searchEmail.trim() + "%");
        }
        if (searchPhone != null && !searchPhone.trim().isEmpty()) {
            sql += " AND u.phone LIKE ? ";
            params.add("%" + searchPhone.trim() + "%");
        }
        
        sql += " ORDER BY u.updatedAt DESC";
        return jdbcTemplate.queryForList(sql, params.toArray());
    }

    /**
     * 5. THEO DÕI THỜI ĐIỂM PHÂN QUYỀN GẦN NHẤT
     * BỔ SUNG: Tách biệt 3 trường tìm kiếm chạy đồng thời, lọc kết hợp song song với lọc ngày.
     */
    public List<Map<String, Object>> getRecentRoleAssignments(String startDate, String endDate, 
                                                              String searchName, String searchEmail, String searchPhone) {
        String sql = "SELECT ur.id_UserRole, u.id_User, u.username, u.fullName, u.email, u.phone, q.roleName, " +
                     "ur.status AS roleStatus, ur.createdAt AS roleCreatedAt, ur.updatedAt AS roleUpdatedAt " +
                     "FROM `UserRole` ur " +
                     "INNER JOIN `User` u ON ur.id_User = u.id_User " +
                     "INNER JOIN `Quyen` q ON ur.id_Role = q.id_Role " +
                     "WHERE 1=1 ";
                     
        List<Object> params = new ArrayList<>();
        
        // --- Kết hợp Bộ lọc Tổng thời gian ---
        if (startDate != null && !startDate.trim().isEmpty()) { 
            sql += " AND (DATE(ur.createdAt) >= ? OR DATE(ur.updatedAt) >= ?) "; 
            params.add(startDate);
            params.add(startDate);
        }
        if (endDate != null && !endDate.trim().isEmpty()) { 
            sql += " AND (DATE(ur.createdAt) <= ? OR DATE(ur.updatedAt) <= ?) "; 
            params.add(endDate);
            params.add(endDate);
        }
        
        // --- Kết hợp đồng thời 3 bộ lọc con (Ràng buộc logic AND chặt chẽ) ---
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql += " AND u.fullName LIKE ? ";
            params.add("%" + searchName.trim() + "%");
        }
        if (searchEmail != null && !searchEmail.trim().isEmpty()) {
            sql += " AND u.email LIKE ? ";
            params.add("%" + searchEmail.trim() + "%");
        }
        if (searchPhone != null && !searchPhone.trim().isEmpty()) {
            sql += " AND u.phone LIKE ? ";
            params.add("%" + searchPhone.trim() + "%");
        }
        
        sql += " ORDER BY ur.updatedAt DESC"; 
        return jdbcTemplate.queryForList(sql, params.toArray());
    }

    /**
     * 6. GIÁM SÁT RỦI RO GHẾ / PHÒNG BẢO TRÌ (CHỈ CÓ BẢO TRÌ VÀ TRỐNG)
     */
    public List<Map<String, Object>> getRoomFacilityHealthMetrics() {
        String sql = "SELECT r.id_Room, r.roomName, " +
                     "SUM(CASE WHEN s.status = 'Available' THEN 1 ELSE 0 END) AS availableSeats, " +
                     "SUM(CASE WHEN s.status = 'Maintenance' THEN 1 ELSE 0 END) AS maintenanceSeats " +
                     "FROM `Room` r LEFT JOIN `Seat` s ON r.id_Room = s.roomId " +
                     "GROUP BY r.id_Room, r.roomName " +
                     "ORDER BY maintenanceSeats DESC, r.roomName ASC";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * 7. CẢNH BÁO SUẤT CHIẾU Ế KHÁCH (TRONG 24 GIỜ TỚI)
     */
    public List<Map<String, Object>> getZeroOrLowTicketShowtimeAlerts(int thresholdTickets) {
        String currentSystemTime = "2026-06-28 15:45:00";
        String sql = "SELECT st.id_Showtime, m.title AS movieTitle, r.roomName, st.showDate, st.startTime, " +
                     "COUNT(CASE WHEN t.status = 'Sold' THEN 1 END) AS ticketsSold " +
                     "FROM `Showtime` st " +
                     "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     "INNER JOIN `Room` r ON st.roomId = r.id_Room " +
                     "LEFT JOIN `Ticket` t ON st.id_Showtime = t.showtimeId " +
                     "WHERE CONCAT(st.showDate, ' ', st.startTime) >= ? " +
                     "AND CONCAT(st.showDate, ' ', st.startTime) <= DATE_ADD(?, INTERVAL 24 HOUR) " +
                     "GROUP BY st.id_Showtime, m.title, r.roomName, st.showDate, st.startTime " +
                     "HAVING ticketsSold <= ? " +
                     "ORDER BY st.showDate ASC, st.startTime ASC";
        return jdbcTemplate.queryForList(sql, currentSystemTime, currentSystemTime, thresholdTickets);
    }

  public List<String> getAllPaymentMethods() {
        String sql = "SELECT DISTINCT b.paymentMethod " +
                     "FROM `Booking` b " +
                     "WHERE b.paymentMethod IS NOT NULL AND b.paymentMethod != '' " +
                     "ORDER BY b.paymentMethod ASC";
        
        // Sử dụng queryForList với String.class làm tham số đích để nhận về List<String>
        return jdbcTemplate.queryForList(sql, String.class);
    }

    public List<Map<String, Object>> getLiveTransactionStream(int page, int size, String startDate, String endDate,
                                                              String txName, String txMinPrice, String txMaxPrice, 
                                                              String txMethod, String txId) {
        int offset = (page - 1) * size;
        
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT b.id_Booking, DATE_FORMAT(b.bookingDate, '%Y-%m-%dT%H:%i:%s') AS bookingDate, " +
            "b.totalAmount, b.paymentMethod, b.status, u.fullName AS customerName, u.username, u.id_User, " +
            "(SELECT t.showtimeId FROM `BookingDetail` bd JOIN `Ticket` t ON bd.ticketId = t.id_Ticket WHERE bd.bookingId = b.id_Booking LIMIT 1) AS id_Showtime " +
            "FROM `Booking` b " +
            "LEFT JOIN `User` u ON b.userId = u.id_User " +
            "WHERE b.status IS NOT NULL "
        );
        
        List<Object> params = new ArrayList<>();
        buildFilterQuery(sql, params, startDate, endDate, txName, txMinPrice, txMaxPrice, txMethod, txId);
        
        sql.append(" ORDER BY b.bookingDate DESC LIMIT ? OFFSET ?");
        params.add(size);
        params.add(offset);
        
        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    public int getTotalTransactionCount(String startDate, String endDate, String txName, 
                                        String txMinPrice, String txMaxPrice, String txMethod, String txId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT b.id_Booking) FROM `Booking` b " +
            "LEFT JOIN `User` u ON b.userId = u.id_User " +
            "WHERE b.status IS NOT NULL "
        );
        List<Object> params = new ArrayList<>();
        buildFilterQuery(sql, params, startDate, endDate, txName, txMinPrice, txMaxPrice, txMethod, txId);
        
        Integer count = jdbcTemplate.queryForObject(sql.toString(), Integer.class, params.toArray());
        return count != null ? count : 0;
    }

    /**
     * Hàm bổ trợ dùng chung để build câu lệnh SQL động
     */
    private void buildFilterQuery(StringBuilder sql, List<Object> params, String startDate, String endDate,
                                   String txName, String txMinPrice, String txMaxPrice, String txMethod, String txId) {
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND DATE(b.bookingDate) >= ? ");
            params.add(startDate.trim());
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND DATE(b.bookingDate) <= ? ");
            params.add(endDate.trim());
        }
        if (txName != null && !txName.trim().isEmpty()) {
            sql.append(" AND u.fullName LIKE ? ");
            params.add("%" + txName.trim() + "%");
        }
        if (txMethod != null && !txMethod.trim().isEmpty() && !txMethod.equalsIgnoreCase("ALL")) {
            sql.append(" AND b.paymentMethod = ? ");
            params.add(txMethod.trim());
        }
        if (txId != null && !txId.trim().isEmpty()) {
            try {
                String cleanId = txId.replaceAll("[^0-9]", "");
                if(!cleanId.isEmpty()) {
                    sql.append(" AND b.id_Booking = ? ");
                    params.add(Integer.parseInt(cleanId));
                }
            } catch (NumberFormatException e) {
                // Chặn lỗi parse số
            }
        }
        if (txMinPrice != null && !txMinPrice.trim().isEmpty()) {
            try {
                double minPrice = Double.parseDouble(txMinPrice.trim());
                sql.append(" AND b.totalAmount >= ? ");
                params.add(minPrice);
            } catch (NumberFormatException e) { }
        }
        if (txMaxPrice != null && !txMaxPrice.trim().isEmpty()) {
            try {
                double maxPrice = Double.parseDouble(txMaxPrice.trim());
                sql.append(" AND b.totalAmount <= ? ");
                params.add(maxPrice);
            } catch (NumberFormatException e) { }
        }
    }
}