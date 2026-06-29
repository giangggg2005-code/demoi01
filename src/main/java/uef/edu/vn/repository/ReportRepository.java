package uef.edu.vn.repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

// Import file ReportException của bạn vào đây
import uef.edu.vn.exception.ReportException;

@Repository
public class ReportRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // =========================================================================
    // 1. TỔNG QUAN DASHBOARD TOÀN THỜI GIAN
    // =========================================================================
    public Map<String, Object> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();
        try {
            String sqlRev = "SELECT SUM(totalAmount) FROM `Booking` WHERE status = 'Completed'";
            Double totalRevenue = jdbcTemplate.queryForObject(sqlRev, Double.class);
            summary.put("totalRevenue", totalRevenue != null ? totalRevenue : 0.0);

            String sqlTick = "SELECT COUNT(*) FROM `Ticket` WHERE status = 'Sold'";
            Integer totalTickets = jdbcTemplate.queryForObject(sqlTick, Integer.class);
            summary.put("totalTickets", totalTickets != null ? totalTickets : 0);

            String sqlUsers = "SELECT COUNT(DISTINCT u.id_User) FROM `User` u "
                    + "JOIN `UserRole` ur ON u.id_User = ur.id_User "
                    + "JOIN `Quyen` q ON ur.id_Role = q.id_Role "
                    + "WHERE q.roleName = 'CUSTOMER'";
            Integer totalUsers = jdbcTemplate.queryForObject(sqlUsers, Integer.class);
            summary.put("totalUsers", totalUsers != null ? totalUsers : 0);
            summary.put("totalCustomers", totalUsers != null ? totalUsers : 0);

            String sqlMovies = "SELECT COUNT(*) FROM `Movie`";
            Integer totalMovies = jdbcTemplate.queryForObject(sqlMovies, Integer.class);
            summary.put("totalMovies", totalMovies != null ? totalMovies : 0);

            return summary;
        } catch (Exception e) {
            throw new ReportException("Lỗi hệ thống khi lấy số liệu tổng quan Dashboard: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 2. TỔNG QUAN TÓM TẮT TRÊN DASHBOARD THEO NĂM (ĐÃ ĐỒNG BỘ VỚI BOOKING)
    // =========================================================================
    public Map<String, Object> getDashboardSummaryCurrentYear(int year) {
        Map<String, Object> summary = new HashMap<>();
        try {
            String sqlRev = "SELECT SUM(totalAmount) FROM `Booking` WHERE status = 'Completed' AND YEAR(bookingDate) = ?";
            Double totalRevenue = jdbcTemplate.queryForObject(sqlRev, Double.class, year);
            summary.put("totalRevenue", totalRevenue != null ? totalRevenue : 0.0);

            // SỬA: Tính vé từ BookingDetail để đảm bảo khớp với Booking đã hoàn tất
            String sqlTick = "SELECT COUNT(bd.id_Detail) FROM `BookingDetail` bd "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE b.status = 'Completed' AND YEAR(b.bookingDate) = ?";
            Integer totalTickets = jdbcTemplate.queryForObject(sqlTick, Integer.class, year);
            summary.put("totalTickets", totalTickets != null ? totalTickets : 0);

            String sqlUsers = "SELECT COUNT(DISTINCT u.id_User) FROM `User` u "
                    + "JOIN `UserRole` ur ON u.id_User = ur.id_User "
                    + "JOIN `Quyen` q ON ur.id_Role = q.id_Role "
                    + "WHERE q.roleName = 'CUSTOMER' AND YEAR(ur.createdAt) = ?";
            Integer totalCustomers = jdbcTemplate.queryForObject(sqlUsers, Integer.class, year);
            summary.put("totalCustomers", totalCustomers != null ? totalCustomers : 0);
            summary.put("newUsers", totalCustomers != null ? totalCustomers : 0);

            String sqlEmployees = "SELECT COUNT(DISTINCT ur.id_User) FROM `UserRole` ur "
                    + "JOIN `Quyen` q ON ur.id_Role = q.id_Role "
                    + "WHERE q.roleName IN ('ADMIN', 'MANAGER', 'TICKETSELLER')";
            Integer totalEmployees = jdbcTemplate.queryForObject(sqlEmployees, Integer.class);
            summary.put("totalEmployees", totalEmployees != null ? totalEmployees : 0);

            String sqlActiveMovies = "SELECT COUNT(DISTINCT movieId) FROM `Showtime` WHERE YEAR(showDate) = ? AND status != 'Cancelled'";
            Integer activeMovies = jdbcTemplate.queryForObject(sqlActiveMovies, Integer.class, year);
            summary.put("activeMovies", activeMovies != null ? activeMovies : 0);

            return summary;
        } catch (Exception e) {
            throw new ReportException("Lỗi khi truy vấn số liệu tổng quan năm " + year + ": " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 3. MẢNG DOANH THU THEO 12 THÁNG TRONG NĂM CHO BIỂU ĐỒ CHART
    // =========================================================================
    public List<Double> getMonthlyRevenueForYear(int year) {
        try {
            String sql = "SELECT MONTH(bookingDate) AS month, SUM(totalAmount) AS revenue "
                    + "FROM `Booking` "
                    + "WHERE status = 'Completed' AND YEAR(bookingDate) = ? "
                    + "GROUP BY MONTH(bookingDate)";

            Map<Integer, Double> revenueMap = new HashMap<>();
            jdbcTemplate.query(sql, (rs) -> {
                revenueMap.put(rs.getInt("month"), rs.getDouble("revenue"));
            }, year);

            List<Double> monthlyRevenue = new ArrayList<>();
            for (int i = 1; i <= 12; i++) {
                monthlyRevenue.add(revenueMap.getOrDefault(i, 0.0));
            }
            return monthlyRevenue;
        } catch (Exception e) {
            throw new ReportException("Lỗi tạo dữ liệu biểu đồ doanh thu tháng cho năm " + year + ": " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 4. DANH SÁCH PHIM DOANH THU CAO NHẤT TRONG NĂM TRÊN DASHBOARD (ĐÃ SỬA)
    // =========================================================================
    public List<Map<String, Object>> getTopSellingMoviesDashboard(int limit, int year) {
        try {
            // SỬA LẠI: Join với Booking và BookingDetail, lọc theo YEAR(b.bookingDate) chuẩn xác
            String sql = "SELECT m.id_Movie, m.title, m.posterUrl, m.genre, m.duration, "
                    + "COUNT(bd.id_Detail) AS ticketsSold, SUM(bd.price) AS totalRevenue "
                    + "FROM `Movie` m "
                    + "JOIN `Showtime` s ON m.id_Movie = s.movieId "
                    + "JOIN `Ticket` t ON s.id_Showtime = t.showtimeId "
                    + "JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE b.status = 'Completed' AND YEAR(b.bookingDate) = ? "
                    + "GROUP BY m.id_Movie, m.title, m.posterUrl, m.genre, m.duration "
                    + "ORDER BY totalRevenue DESC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_Movie", rs.getInt("id_Movie"));
                map.put("title", rs.getString("title"));
                map.put("posterUrl", rs.getString("posterUrl"));
                map.put("genre", rs.getString("genre"));
                map.put("duration", rs.getInt("duration"));

                int sold = rs.getInt("ticketsSold");
                map.put("ticketsSold", sold);
                map.put("totalTickets", sold); // Giữ lại dự phòng

                double rev = rs.getDouble("totalRevenue");
                map.put("totalRevenue", rev);
                map.put("revenue", rev); // Giữ lại dự phòng
                return map;
            }, year, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải danh sách phim doanh thu cao nhất: " + e.getMessage(), e);
        }
    }

    // (Tất cả các hàm còn lại từ 5 đến 18 đều giữ nguyên như code gốc của bạn, bạn có thể copy trực tiếp từ file cũ xuống đây hoặc để y nguyên).
    // ...
    // =========================================================================
    // 5. DANH SÁCH PHIM SẮP CHIẾU (ĐÃ TÍCH HỢP HIỂN THỊ SUẤT CHIẾU GẦN NHẤT)
    // =========================================================================
    public List<Map<String, Object>> getUpcomingMoviesDashboard(int limit) {
        try {
            // CẢI TIẾN: Subquery lấy chuỗi ngày giờ (showDate + startTime) của suất chiếu gần nhất
            String sql = "SELECT m.id_Movie, m.title, m.posterUrl, m.releaseDate, m.genre, "
                    + "  (SELECT DATE_FORMAT(MIN(TIMESTAMP(s.showDate, s.startTime)), '%H:%i %d/%m/%Y') "
                    + "   FROM `Showtime` s "
                    + "   WHERE s.movieId = m.id_Movie AND TIMESTAMP(s.showDate, s.startTime) > NOW() "
                    + "  ) AS nearestShowtime "
                    + "FROM `Movie` m "
                    + "WHERE m.status = 'Coming Soon' OR m.releaseDate >= CURRENT_DATE "
                    + "ORDER BY m.releaseDate ASC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_Movie", rs.getInt("id_Movie"));
                map.put("title", rs.getString("title"));
                map.put("posterUrl", rs.getString("posterUrl"));
                map.put("releaseDate", rs.getDate("releaseDate"));
                map.put("genre", rs.getString("genre"));

                // Trích xuất Suất chiếu gần nhất (có thể null nếu chưa có lịch chiếu)
                map.put("nearestShowtime", rs.getString("nearestShowtime"));

                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải danh sách phim sắp chiếu: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 6. DANH SÁCH KHÁCH HÀNG MỚI ĐĂNG KÝ GẦN ĐÂY
    // =========================================================================
    public List<Map<String, Object>> getNewCustomersDashboard(int limit) {
        try {
            String sql = "SELECT u.id_User, u.fullName, u.email, ur.createdAt "
                    + "FROM `User` u "
                    + "JOIN `UserRole` ur ON u.id_User = ur.id_User "
                    + "JOIN `Quyen` q ON ur.id_Role = q.id_Role "
                    + "WHERE q.roleName = 'CUSTOMER' "
                    + "ORDER BY ur.createdAt DESC, u.id_User DESC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_User", rs.getInt("id_User"));
                map.put("fullName", rs.getString("fullName"));
                map.put("email", rs.getString("email"));
                map.put("createdAt", rs.getTimestamp("createdAt"));
                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải danh sách khách hàng mới: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 7. DANH SÁCH NHÂN SỰ MỚI TUYỂN DỤNG GẦN ĐÂY
    // =========================================================================
    public List<Map<String, Object>> getNewEmployeesDashboard(int limit) {
        try {
            String sql = "SELECT u.id_User, u.fullName, u.email, u.phone, q.roleName, ur.createdAt "
                    + "FROM `User` u "
                    + "JOIN `UserRole` ur ON u.id_User = ur.id_User "
                    + "JOIN `Quyen` q ON ur.id_Role = q.id_Role "
                    + "WHERE q.roleName IN ('ADMIN', 'MANAGER', 'TICKETSELLER') "
                    + "ORDER BY ur.createdAt DESC, u.id_User DESC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_User", rs.getInt("id_User"));
                map.put("fullName", rs.getString("fullName"));
                map.put("email", rs.getString("email"));
                map.put("phone", rs.getString("phone"));
                map.put("roleName", rs.getString("roleName"));
                map.put("createdAt", rs.getTimestamp("createdAt"));
                map.put("updatedAt", rs.getTimestamp("createdAt")); // Ánh xạ an toàn cho JSP cũ
                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải danh sách nhân sự mới: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 8. BÁO CÁO THỐNG KÊ DOANH THU VÀ VÉ THEO KHOẢNG NGÀY
    // =========================================================================
    public List<Map<String, Object>> getRevenueAndTicketsByDay(String startDate, String endDate) {
        try {
            String sql = "SELECT DATE(b.bookingDate) AS saleDate, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Booking` b "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "WHERE b.status = 'Completed' AND b.bookingDate BETWEEN ? AND ? "
                    + "GROUP BY DATE(b.bookingDate) ORDER BY saleDate ASC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("date", rs.getDate("saleDate").toString());
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn doanh thu theo ngày: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getRevenueAndTicketsByMonth(int year) {
        try {
            String sql = "SELECT MONTH(b.bookingDate) AS saleMonth, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Booking` b "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "WHERE b.status = 'Completed' AND YEAR(b.bookingDate) = ? "
                    + "GROUP BY MONTH(b.bookingDate) ORDER BY saleMonth ASC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("month", rs.getInt("saleMonth"));
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, year);
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn doanh thu theo tháng: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getSalesByTimeOfDay(String startDate, String endDate) {
        try {
            String sql = "SELECT CASE "
                    + "    WHEN HOUR(bookingDate) BETWEEN 6 AND 11 THEN 'Buổi Sáng' "
                    + "    WHEN HOUR(bookingDate) BETWEEN 12 AND 17 THEN 'Buổi Chiều' "
                    + "    WHEN HOUR(bookingDate) BETWEEN 18 AND 23 THEN 'Buổi Tối' "
                    + "    ELSE 'Nửa Đêm' "
                    + "  END AS shift, "
                    + "  COUNT(id_Booking) AS totalBookings, SUM(totalAmount) AS revenue "
                    + "FROM `Booking` "
                    + "WHERE status = 'Completed' AND bookingDate BETWEEN ? AND ? "
                    + "GROUP BY shift ORDER BY revenue DESC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("shift", rs.getString("shift"));
                map.put("bookings", rs.getInt("totalBookings"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn doanh thu theo khung giờ: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getRevenueByMovie(String startDate, String endDate) {
        try {
            String sql = "SELECT m.id_Movie, m.title AS movieName, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Movie` m "
                    + "JOIN `Showtime` s ON m.id_Movie = s.movieId "
                    + "JOIN `Ticket` t ON s.id_Showtime = t.showtimeId "
                    + "JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE b.status = 'Completed' AND b.bookingDate BETWEEN ? AND ? "
                    + "GROUP BY m.id_Movie, m.title ORDER BY revenue DESC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("movieId", rs.getInt("id_Movie"));
                map.put("movieName", rs.getString("movieName"));
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn doanh thu theo phim: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getMovieRevenueGrowth(int movieId, String startDate, String endDate) {
        try {
            String sql = "SELECT DATE(b.bookingDate) AS saleDate, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Booking` b "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "JOIN `Showtime` s ON t.showtimeId = s.id_Showtime "
                    + "WHERE b.status = 'Completed' AND s.movieId = ? AND b.bookingDate BETWEEN ? AND ? "
                    + "GROUP BY DATE(b.bookingDate) ORDER BY saleDate ASC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("date", rs.getDate("saleDate").toString());
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, movieId, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn tăng trưởng doanh thu phim: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getTopSellingMovies(int limit, String startDate, String endDate) {
        try {
            String sql = "SELECT m.id_Movie, m.title AS movieName, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Movie` m "
                    + "JOIN `Showtime` s ON m.id_Movie = s.movieId "
                    + "JOIN `Ticket` t ON s.id_Showtime = t.showtimeId "
                    + "JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE b.status = 'Completed' AND b.bookingDate BETWEEN ? AND ? "
                    + "GROUP BY m.id_Movie, m.title ORDER BY tickets DESC LIMIT ?";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("movieId", rs.getInt("id_Movie"));
                map.put("movieName", rs.getString("movieName"));
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59", limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải phim bán chạy nhất: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getRevenueByScreeningRoom(String startDate, String endDate) {
        try {
            String sql = "SELECT r.id_Room AS roomId, r.roomName, COUNT(bd.id_Detail) AS tickets, SUM(bd.price) AS revenue "
                    + "FROM `Room` r "
                    + "JOIN `Showtime` s ON r.id_Room = s.roomId "
                    + "JOIN `Ticket` t ON s.id_Showtime = t.showtimeId "
                    + "JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE b.status = 'Completed' AND b.bookingDate BETWEEN ? AND ? "
                    + "GROUP BY r.id_Room, r.roomName ORDER BY revenue DESC";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("roomId", rs.getInt("roomId"));
                map.put("roomName", rs.getString("roomName"));
                map.put("tickets", rs.getInt("tickets"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn doanh thu phòng chiếu: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getTopCustomers(int limit) {
        try {
            String sql = "SELECT u.fullName, u.email, COUNT(b.id_Booking) AS totalBookings, SUM(b.totalAmount) AS totalSpent "
                    + "FROM `User` u "
                    + "JOIN `Booking` b ON u.id_User = b.userId "
                    + "WHERE b.status = 'Completed' "
                    + "GROUP BY u.id_User, u.fullName, u.email ORDER BY totalSpent DESC LIMIT ?";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("customerName", rs.getString("fullName"));
                map.put("email", rs.getString("email"));
                map.put("totalBookings", rs.getInt("totalBookings"));
                map.put("totalSpent", rs.getDouble("totalSpent"));
                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải danh sách khách hàng hàng đầu: " + e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getBookingStatusRatio(String startDate, String endDate) {
        try {
            String sql = "SELECT status, COUNT(id_Booking) AS count "
                    + "FROM `Booking` "
                    + "WHERE bookingDate BETWEEN ? AND ? "
                    + "GROUP BY status";
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("status", rs.getString("status"));
                map.put("count", rs.getInt("count"));
                return map;
            }, startDate + " 00:00:00", endDate + " 23:59:59");
        } catch (Exception e) {
            throw new ReportException("Lỗi tải tỷ lệ trạng thái đặt vé: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 17. LỊCH CHIẾU HÔM NAY (ĐÃ TỐI ƯU VỚI CẤU TRÚC BẢNG)
    // =========================================================================
    public List<Map<String, Object>> getTodayShowtimesDashboard(int limit) {
        try {
            String sql = "SELECT m.title AS movieTitle, r.roomName, s.startTime, "
                    + "(SELECT COUNT(*) FROM `Ticket` t WHERE t.showtimeId = s.id_Showtime AND t.status = 'Sold') AS bookedSeats, "
                    + "(r.totalRows * r.totalCols) AS totalSeats "
                    + "FROM `Showtime` s "
                    + "JOIN `Movie` m ON s.movieId = m.id_Movie "
                    + "JOIN `Room` r ON s.roomId = r.id_Room "
                    + "WHERE DATE(s.showDate) = CURRENT_DATE "
                    + "ORDER BY s.startTime ASC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("movieTitle", rs.getString("movieTitle"));
                map.put("roomName", rs.getString("roomName"));
                try {
                    String time = rs.getString("startTime");
                    if (time != null && time.length() >= 5) {
                        map.put("startTime", time.substring(0, 5));
                    } else {
                        map.put("startTime", time);
                    }
                } catch (Exception e) {
                    map.put("startTime", "00:00");
                }
                map.put("bookedSeats", rs.getInt("bookedSeats"));
                map.put("totalSeats", rs.getInt("totalSeats"));
                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải lịch chiếu hôm nay: " + e.getMessage(), e);
        }
    }

    // =========================================================================
    // 18. GIAO DỊCH MỚI NHẤT
    // =========================================================================
    public List<Map<String, Object>> getRecentTransactionsDashboard(int limit) {
        try {
            String sql = "SELECT u.fullName AS customerName, m.title AS movieTitle, "
                    + "COUNT(bd.id_Detail) AS ticketCount, b.totalAmount AS amount, b.paymentMethod, b.bookingDate "
                    + "FROM `Booking` b "
                    + "JOIN `User` u ON b.userId = u.id_User "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "JOIN `Showtime` s ON t.showtimeId = s.id_Showtime "
                    + "JOIN `Movie` m ON s.movieId = m.id_Movie "
                    + "WHERE b.status = 'Completed' "
                    + "GROUP BY b.id_Booking, u.fullName, m.title, b.totalAmount, b.paymentMethod, b.bookingDate "
                    + "ORDER BY b.bookingDate DESC LIMIT ?";

            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("customerName", rs.getString("customerName") != null ? rs.getString("customerName") : "Khách vãng lai");
                map.put("movieTitle", rs.getString("movieTitle") != null ? rs.getString("movieTitle") : "Chưa xác định");
                map.put("ticketCount", rs.getInt("ticketCount"));
                map.put("amount", rs.getDouble("amount"));
                map.put("paymentMethod", rs.getString("paymentMethod") != null ? rs.getString("paymentMethod") : "N/A");
                map.put("bookingDate", rs.getTimestamp("bookingDate"));
                return map;
            }, limit);
        } catch (Exception e) {
            throw new ReportException("Lỗi tải giao dịch mới nhất: " + e.getMessage(), e);
        }
    }
    // =========================================================================
    // CÁC HÀM BỔ SUNG CHO TRANG BÁO CÁO DOANH THU CHI TIẾT
    // =========================================================================

    // Hàm dùng chung để nối chuỗi điều kiện lọc (Filter)
    private void appendFilters(StringBuilder sql, List<Object> params, String startDate, String endDate, Integer movieId, String roomType) {
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND b.bookingDate >= ? ");
            params.add(startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND b.bookingDate <= ? ");
            params.add(endDate + " 23:59:59");
        }
        if (movieId != null && movieId > 0) {
            sql.append(" AND m.id_Movie = ? ");
            params.add(movieId);
        }
        if (roomType != null && !roomType.trim().isEmpty() && !roomType.equalsIgnoreCase("All")) {
            sql.append(" AND r.roomType = ? ");
            params.add(roomType);
        }
    }

    // 1. LẤY CÁC CHỈ SỐ KPI TỔNG QUAN
    public Map<String, Object> getAdvancedKPIs(String startDate, String endDate, Integer movieId, String roomType) {
        try {
            // 1.1 Tính Tổng số vé và Tổng doanh thu (Có áp dụng bộ lọc)
            StringBuilder sqlKpi = new StringBuilder(
                    "SELECT COUNT(bd.id_Detail) AS totalTickets, "
                    + "SUM(bd.price) AS totalRevenue "
                    + "FROM `BookingDetail` bd "
                    + "JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                    + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "JOIN `Room` r ON st.roomId = r.id_Room "
                    + "WHERE b.status = 'Completed' "
            );
            List<Object> params = new ArrayList<>();
            appendFilters(sqlKpi, params, startDate, endDate, movieId, roomType);

            Map<String, Object> kpiResult = jdbcTemplate.queryForMap(sqlKpi.toString(), params.toArray());
            long totalTickets = kpiResult.get("totalTickets") != null ? ((Number) kpiResult.get("totalTickets")).longValue() : 0;
            double totalRevenue = kpiResult.get("totalRevenue") != null ? ((Number) kpiResult.get("totalRevenue")).doubleValue() : 0.0;

            // 1.2 Tính Tổng số ghế mở bán của các suất chiếu để chia Tỷ lệ lấp đầy
            StringBuilder sqlSeats = new StringBuilder(
                    "SELECT COUNT(s.id_Seat) AS totalSeats "
                    + "FROM `Showtime` st "
                    + "JOIN `Room` r ON st.roomId = r.id_Room "
                    + "JOIN `Seat` s ON r.id_Room = s.roomId "
                    + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "WHERE st.status != 'Cancelled' "
            );
            
            // Map bộ lọc ngày đặt vé sang ngày chiếu để tỷ lệ lấp đầy chính xác
            List<Object> seatParams = new ArrayList<>();
            if (startDate != null && !startDate.trim().isEmpty()) {
                sqlSeats.append(" AND st.showDate >= ? ");
                seatParams.add(startDate);
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                sqlSeats.append(" AND st.showDate <= ? ");
                seatParams.add(endDate);
            }
            if (movieId != null && movieId > 0) {
                sqlSeats.append(" AND m.id_Movie = ? ");
                seatParams.add(movieId);
            }
            if (roomType != null && !roomType.trim().isEmpty() && !roomType.equalsIgnoreCase("All")) {
                sqlSeats.append(" AND r.roomType = ? ");
                seatParams.add(roomType);
            }

            Integer totalSeats = jdbcTemplate.queryForObject(sqlSeats.toString(), Integer.class, seatParams.toArray());
            int maxSeats = totalSeats != null ? totalSeats : 0;

            // 1.3 Tính toán Occupancy Rate (%)
            double occupancyRate = 0.0;
            if (maxSeats > 0) {
                // Công thức tính và làm tròn 2 chữ số thập phân
                occupancyRate = Math.round(((double) totalTickets / maxSeats) * 10000.0) / 100.0; 
            }

            Map<String, Object> kpis = new HashMap<>();
            kpis.put("totalRevenue", totalRevenue);
            kpis.put("totalTickets", totalTickets);
            kpis.put("occupancyRate", occupancyRate);
            return kpis;
        } catch (Exception e) {
            throw new ReportException("Lỗi truy vấn dữ liệu KPI Tổng quan: " + e.getMessage(), e);
        }
    }

    // 2. THỐNG KÊ DOANH THU CHI TIẾT THEO PHIM
    public List<Map<String, Object>> getRevenueByMovieDetailed(String startDate, String endDate, Integer movieId, String roomType) {
        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT m.id_Movie, m.title, m.releaseDate, "
                    // Chỉ đếm vé và cộng tiền khi booking status là 'Completed', nếu không thì là 0
                    + "COUNT(CASE WHEN b.status = 'Completed' THEN bd.id_Detail ELSE NULL END) AS ticketsSold, "
                    + "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(m.basePrice, 0) ELSE 0 END) AS totalBaseRevenue, "
                    + "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(r.roomPrice, 0) ELSE 0 END) AS totalSurchargeRevenue, "
                    + "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(bd.price, 0) ELSE 0 END) AS totalRevenue "
                    
                    // Bắt đầu từ bảng Movie làm gốc
                    + "FROM `Movie` m "
                    + "LEFT JOIN `Showtime` st ON m.id_Movie = st.movieId "
                    + "LEFT JOIN `Room` r ON st.roomId = r.id_Room "
                    + "LEFT JOIN `Ticket` t ON st.id_Showtime = t.showtimeId "
                    + "LEFT JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "LEFT JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    
                    // Dùng 1=1 để hàm appendFilters ở dưới nối thêm điều kiện (AND ...) mà không bị lỗi cú pháp
                    + "WHERE 1=1 " 
            );

            List<Object> params = new ArrayList<>();
            
            // Hàm nối bộ lọc của bạn (giữ nguyên). Các bí danh m, st, r, t, bd, b mình đã giữ y hệt code cũ để không bị lỗi ở hàm này.
            appendFilters(sql, params, startDate, endDate, movieId, roomType);
            
            sql.append(" GROUP BY m.id_Movie, m.title, m.releaseDate ORDER BY totalRevenue DESC");

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_Movie", rs.getInt("id_Movie"));
                map.put("title", rs.getString("title"));
                map.put("releaseDate", rs.getDate("releaseDate"));
                map.put("ticketsSold", rs.getInt("ticketsSold"));
                map.put("totalBaseRevenue", rs.getDouble("totalBaseRevenue"));
                map.put("totalSurchargeRevenue", rs.getDouble("totalSurchargeRevenue"));
                map.put("totalRevenue", rs.getDouble("totalRevenue"));
                return map;
            }, params.toArray());
            
        } catch (Exception e) {
            throw new ReportException("Lỗi thống kê doanh thu theo Phim: " + e.getMessage(), e);
        }
    }
    // 3. THỐNG KÊ DOANH THU THEO LOẠI PHÒNG CHIẾU
    public List<Map<String, Object>> getRevenueByRoomTypeDetailed(String startDate, String endDate, Integer movieId, String roomType) {
        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT r.roomType, COUNT(bd.id_Detail) AS ticketsSold, "
                    + "SUM(IFNULL(m.basePrice, 0)) AS totalBaseAmount, "
                    + "SUM(IFNULL(r.roomPrice, 0)) AS totalSurchargeAmount, "
                    + "SUM(IFNULL(bd.price, 0)) AS totalRevenue "
                    + "FROM `Booking` b "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                    + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "JOIN `Room` r ON st.roomId = r.id_Room "
                    + "WHERE b.status = 'Completed'"
            );

            List<Object> params = new ArrayList<>();
            appendFilters(sql, params, startDate, endDate, movieId, roomType);
            sql.append(" GROUP BY r.roomType ORDER BY totalRevenue DESC");

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("roomType", rs.getString("roomType"));
                map.put("ticketsSold", rs.getInt("ticketsSold"));
                map.put("totalBaseAmount", rs.getDouble("totalBaseAmount"));
                map.put("totalSurchargeAmount", rs.getDouble("totalSurchargeAmount"));
                map.put("totalRevenue", rs.getDouble("totalRevenue"));
                return map;
            }, params.toArray());
        } catch (Exception e) {
            throw new ReportException("Lỗi thống kê doanh thu theo Loại phòng: " + e.getMessage(), e);
        }
    }

   // 4. XU HƯỚNG DOANH THU THEO THỜI GIAN (Cập nhật)
    public List<Map<String, Object>> getRevenueTrend(String startDate, String endDate, Integer movieId, String roomType, String groupByOption) {
        try {
            // Mặc định là nhóm theo NGÀY
            String timeFormula = "DATE_FORMAT(b.bookingDate, '%Y-%m-%d')"; 
            
            // Bổ sung các tùy chọn THÁNG và NĂM
            if ("MONTH".equalsIgnoreCase(groupByOption)) {
                timeFormula = "DATE_FORMAT(b.bookingDate, '%Y-%m')";
            } else if ("YEAR".equalsIgnoreCase(groupByOption)) {
                timeFormula = "DATE_FORMAT(b.bookingDate, '%Y')";
            } else if ("WEEK".equalsIgnoreCase(groupByOption)) {
                timeFormula = "YEARWEEK(b.bookingDate, 1)";
            }

            StringBuilder sql = new StringBuilder(
                    "SELECT periodLabel, SUM(tickets_in_booking) AS ticketsSold, SUM(booking_total) AS totalRevenue FROM ("
                    + "   SELECT " + timeFormula + " AS periodLabel, b.id_Booking, "
                    + "          MAX(b.totalAmount) AS booking_total, COUNT(bd.id_Detail) AS tickets_in_booking "
                    + "   FROM `Booking` b "
                    + "   LEFT JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "   LEFT JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "   LEFT JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                    + "   LEFT JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "   LEFT JOIN `Room` r ON st.roomId = r.id_Room "
                    + "   WHERE b.status = 'Completed' "
            );

            List<Object> params = new ArrayList<>();
            appendFilters(sql, params, startDate, endDate, movieId, roomType);
            sql.append(" GROUP BY periodLabel, b.id_Booking) AS grouped_bookings ");
            sql.append(" GROUP BY periodLabel ORDER BY periodLabel ASC");

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("periodLabel", rs.getString("periodLabel"));
                map.put("ticketsSold", rs.getInt("ticketsSold"));
                map.put("totalRevenue", rs.getDouble("totalRevenue"));
                return map;
            }, params.toArray());
        } catch (Exception e) {
            throw new ReportException("Lỗi lấy dữ liệu đồ thị xu hướng thời gian: " + e.getMessage(), e);
        }
    }

    // 5. DANH SÁCH BẢNG GIAO DỊCH CHI TIẾT
    // 5. DANH SÁCH BẢNG GIAO DỊCH CHI TIẾT
public List<Map<String, Object>> getDetailedTransactions(String startDate, String endDate, Integer movieId, String roomType, int limit, int offset, String sortBy, String sortDir) {
    try {
        // Xử lý Sort
        String orderByField = "b.bookingDate";
        if ("id_Booking".equalsIgnoreCase(sortBy)) orderByField = "b.id_Booking";
        else if ("title".equalsIgnoreCase(sortBy)) orderByField = "m.title";
        else if ("roomType".equalsIgnoreCase(sortBy)) orderByField = "r.roomType";
        else if ("totalAmount".equalsIgnoreCase(sortBy)) orderByField = "b.totalAmount";

        String direction = "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";

        StringBuilder sql = new StringBuilder(
                "SELECT b.id_Booking AS bookingId, b.bookingDate AS transactionTime, "
                + "m.title AS movieTitle, r.roomType AS roomType, COUNT(bd.id_Detail) AS ticketCount, "
                + "SUM(IFNULL(m.basePrice, 0)) AS baseAmount, SUM(IFNULL(r.roomPrice, 0)) AS surchargeAmount, "
                + "b.totalAmount AS totalAmount "
                + "FROM `Booking` b "
                + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                + "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "JOIN `Room` r ON st.roomId = r.id_Room "
                + "WHERE b.status = 'Completed'"
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, startDate, endDate, movieId, roomType);
        
        sql.append(" GROUP BY b.id_Booking, b.bookingDate, m.title, r.roomType, b.totalAmount ");
        sql.append(" ORDER BY ").append(orderByField).append(" ").append(direction);
        sql.append(" LIMIT ? OFFSET ?");

        params.add(limit);
        params.add(offset);

        return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("bookingId", rs.getInt("bookingId"));
            map.put("transactionTime", rs.getTimestamp("transactionTime")); // Trả đúng kiểu Timestamp để JSP format
            map.put("movieTitle", rs.getString("movieTitle") != null ? rs.getString("movieTitle") : "N/A");
            map.put("roomType", rs.getString("roomType") != null ? rs.getString("roomType") : "N/A");
            map.put("ticketCount", rs.getInt("ticketCount"));
            map.put("baseAmount", rs.getDouble("baseAmount"));
            map.put("surchargeAmount", rs.getDouble("surchargeAmount"));
            map.put("totalAmount", rs.getDouble("totalAmount"));
            return map;
        }, params.toArray());
    } catch (Exception e) {
        throw new RuntimeException("Lỗi lấy dữ liệu danh sách lịch sử giao dịch: " + e.getMessage(), e);
    }
}

    // 6. ĐẾM TỔNG SỐ BẢN GHI GIAO DỊCH
    public int getTransactionCount(String startDate, String endDate, Integer movieId, String roomType) {
        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT COUNT(DISTINCT b.id_Booking) "
                    + "FROM `Booking` b "
                    + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                    + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                    + "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                    + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "JOIN `Room` r ON st.roomId = r.id_Room "
                    + "WHERE b.status = 'Completed'"
            );
            List<Object> params = new ArrayList<>();
            appendFilters(sql, params, startDate, endDate, movieId, roomType);

            Integer count = jdbcTemplate.queryForObject(sql.toString(), Integer.class, params.toArray());
            return count != null ? count : 0;
        } catch (Exception e) {
            throw new ReportException("Lỗi tính toán tổng dòng phục vụ phân trang: " + e.getMessage(), e);
        }
    }

   public List<Map<String, Object>> getTopCustomersByFilters(String startDate, String endDate, Integer movieId, String roomType, int limit) {
    try {
        StringBuilder sql = new StringBuilder(
                "SELECT u.id_User, u.fullName, u.email, u.phone, u.avatar, "
                + "COUNT(DISTINCT b.id_Booking) AS totalInvoices, " // <-- Đã thêm: Đếm số hóa đơn duy nhất
                + "COUNT(bd.id_Detail) AS totalTickets, "
                + "SUM(IFNULL(bd.price, 0)) AS totalSpent "
                + "FROM `User` u "
                + "JOIN `Booking` b ON u.id_User = b.userId "
                + "JOIN `BookingDetail` bd ON b.id_Booking = bd.bookingId "
                + "JOIN `Ticket` t ON bd.ticketId = t.id_Ticket "
                + "JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "JOIN `Room` r ON st.roomId = r.id_Room "
                + "WHERE b.status = 'Completed' "
        );

        // Tái sử dụng hàm appendFilters với các alias đã chuẩn bị (b, m, r)
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, startDate, endDate, movieId, roomType);
        
        // Gom nhóm theo thông tin User và sắp xếp theo doanh thu giảm dần
        sql.append(" GROUP BY u.id_User, u.fullName, u.email, u.phone, u.avatar ");
        sql.append(" ORDER BY totalSpent DESC LIMIT ?");
        params.add(limit);

        return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", rs.getInt("id_User"));
            map.put("fullName", rs.getString("fullName"));
            map.put("email", rs.getString("email") != null ? rs.getString("email") : "Chưa cập nhật");
            map.put("phone", rs.getString("phone") != null ? rs.getString("phone") : "Chưa cập nhật");
            map.put("avatar", rs.getString("avatar"));
            
            // <-- Đã thêm: Lấy giá trị tổng số hóa đơn nhét vào map
            map.put("totalInvoices", rs.getInt("totalInvoices")); 
            
            map.put("totalTickets", rs.getInt("totalTickets"));
            map.put("totalSpent", rs.getDouble("totalSpent"));
            return map;
        }, params.toArray());
    } catch (Exception e) {
        throw new ReportException("Lỗi lấy danh sách Top Khách Hàng theo bộ lọc: " + e.getMessage(), e);
    }
}
  // 7. BIỂU ĐỒ DOANH THU PHIM THEO NGÀY (LẤY TẤT CẢ CÁC NGÀY CÓ SUẤT CHIẾU, KỂ CẢ DOANH THU = 0)
    public List<Map<String, Object>> getMovieDailyRevenue(Integer movieId, String startDate, String endDate) {
        try {
            // Đổi từ INNER JOIN sang LEFT JOIN và lấy Showtime làm gốc
            StringBuilder sql = new StringBuilder(
                    "SELECT DATE_FORMAT(st.showDate, '%Y-%m-%d') AS date, "
                    + "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(bd.price, 0) ELSE 0 END) AS revenue "
                    + "FROM `Showtime` st "
                    + "LEFT JOIN `Ticket` t ON st.id_Showtime = t.showtimeId "
                    + "LEFT JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "LEFT JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE st.movieId = ? "
            );

            List<Object> params = new ArrayList<>();
            params.add(movieId);

            // Áp dụng bộ lọc ngày (nếu có)
            if (startDate != null && !startDate.trim().isEmpty()) {
                sql.append(" AND st.showDate >= ? ");
                params.add(startDate);
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                sql.append(" AND st.showDate <= ? ");
                params.add(endDate);
            }

            // Gom nhóm theo ngày chiếu và sắp xếp tăng dần theo thời gian
            sql.append(" GROUP BY st.showDate ORDER BY st.showDate ASC");

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("date", rs.getString("date"));
                map.put("revenue", rs.getDouble("revenue"));
                return map;
            }, params.toArray());
            
        } catch (Exception e) {
            throw new RuntimeException("Lỗi lấy dữ liệu biểu đồ doanh thu phim theo ngày: " + e.getMessage(), e); 
        }
    }
    // 8. THỐNG KÊ HIỆU SUẤT THEO TỪNG SUẤT CHIẾU
   // 8. THỐNG KÊ HIỆU SUẤT THEO TỪNG SUẤT CHIẾU (Đã fix lỗi SQL Grammar)
    public List<Map<String, Object>> getShowtimePerformance(
            String startDate, String endDate, Integer globalMovieId, String globalRoomType,
            String keyword, Double minRev, Double maxRev, Integer specificRoomId, 
            String sortBy, String sortDir) {
            
        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT st.id_Showtime, m.title AS movieTitle, "
                    + "CAST(CONCAT(st.showDate, ' ', st.startTime) AS DATETIME) AS startTime, "
                    + "r.roomName AS roomName, "
                    + "COUNT(CASE WHEN b.status = 'Completed' THEN bd.id_Detail ELSE NULL END) AS ticketsSold, "
                    + "(SELECT COUNT(id_Seat) FROM `Seat` WHERE roomId = r.id_Room) AS totalSeats, "
                    + "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(bd.price, 0) ELSE 0 END) AS totalRevenue, "
                    // Tính luôn cột occupancy (tỷ lệ lấp đầy) ngay trong SELECT để gọi ở ORDER BY cho an toàn
                    + "(COUNT(CASE WHEN b.status = 'Completed' THEN bd.id_Detail ELSE NULL END) * 1.0 / "
                    + "NULLIF((SELECT COUNT(id_Seat) FROM `Seat` WHERE roomId = r.id_Room), 0)) AS occupancy "
                    
                    + "FROM `Showtime` st "
                    + "JOIN `Movie` m ON st.movieId = m.id_Movie "
                    + "JOIN `Room` r ON st.roomId = r.id_Room "
                    + "LEFT JOIN `Ticket` t ON st.id_Showtime = t.showtimeId "
                    + "LEFT JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId "
                    + "LEFT JOIN `Booking` b ON bd.bookingId = b.id_Booking "
                    + "WHERE 1=1 "
            );

            List<Object> params = new ArrayList<>();
            
            // 1. Áp dụng bộ lọc TỔNG
            appendFilters(sql, params, startDate, endDate, globalMovieId, globalRoomType);

            // 2. Áp dụng bộ lọc RIÊNG CỦA PHẦN 3 (WHERE)
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND m.title LIKE ? ");
                params.add("%" + keyword.trim() + "%");
            }
            if (specificRoomId != null) {
                sql.append(" AND r.id_Room = ? ");
                params.add(specificRoomId);
            }

            // Gom nhóm
            sql.append(" GROUP BY st.id_Showtime, m.title, st.showDate, st.startTime, r.roomName, r.id_Room ");

            // 3. Lọc theo khoảng doanh thu (Dùng công thức SUM gốc thay vì alias để không bao giờ bị lỗi)
            boolean hasHaving = false;
            String sumRevenueFormula = "SUM(CASE WHEN b.status = 'Completed' THEN IFNULL(bd.price, 0) ELSE 0 END)";
            
            if (minRev != null) {
                sql.append(" HAVING ").append(sumRevenueFormula).append(" >= ? ");
                params.add(minRev);
                hasHaving = true;
            }
            if (maxRev != null) {
                sql.append(hasHaving ? " AND " : " HAVING ").append(sumRevenueFormula).append(" <= ? ");
                params.add(maxRev);
            }

            // 4. Xử lý Sắp xếp Động an toàn
            String orderClause = "st.showDate DESC, st.startTime DESC"; // Mặc định
            String direction = "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";

            if ("revenue".equals(sortBy)) {
                orderClause = "totalRevenue " + direction;
            } else if ("occupancy".equals(sortBy)) {
                // Giờ chỉ cần gọi bí danh occupancy đã tạo trên SELECT
                orderClause = "occupancy " + direction; 
            }
            
            sql.append(" ORDER BY ").append(orderClause);

            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id_Showtime", rs.getInt("id_Showtime"));
                map.put("movieTitle", rs.getString("movieTitle"));
                map.put("startTime", rs.getTimestamp("startTime")); 
                map.put("roomName", rs.getString("roomName"));
                map.put("ticketsSold", rs.getInt("ticketsSold"));
                map.put("totalSeats", rs.getInt("totalSeats"));
                map.put("totalRevenue", rs.getDouble("totalRevenue"));
                // (Không bắt buộc lấy rs.getDouble("occupancy") ở đây vì JSP của bạn tự tính lại rồi)
                return map;
            }, params.toArray());

        } catch (Exception e) {
            throw new RuntimeException("Lỗi thống kê hiệu suất suất chiếu: " + e.getMessage(), e);
        }
    }
}
