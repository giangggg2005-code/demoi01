package uef.edu.vn.repository;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.model.Movie;
import uef.edu.vn.model.Room;

@Repository
public class ShowtimeRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Showtime mapRowWithMovie(ResultSet rs, int rowNum) throws SQLException {
        Showtime s = new Showtime();
        s.setId_Showtime(rs.getInt("id_Showtime"));
        s.setMovieId(rs.getInt("movieId"));
        s.setRoomId(rs.getInt("roomId"));
        s.setShowDate(rs.getDate("showDate"));
        s.setStartTime(rs.getTime("startTime"));
        s.setEndTime(rs.getTimestamp("endTime"));
        s.setStatus(rs.getString("showtime_status"));

        Movie m = new Movie();
        m.setId_Movie(rs.getInt("id_Movie"));
        m.setTitle(rs.getString("title"));
        m.setPosterUrl(rs.getString("posterUrl"));

        s.setMovie(m);
        return s;
    }

    public Showtime findById(int id) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.id_Showtime = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRowWithMovie, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Showtime> findAll() {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "ORDER BY st.showDate DESC, st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie);
    }

    public boolean save(Showtime s) {
        String sql = "INSERT INTO `Showtime` (showDate, startTime, endTime, status, movieId, roomId) VALUES (?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, s.getShowDate(), s.getStartTime(), s.getEndTime(), s.getStatus(), s.getMovieId(), s.getRoomId()) > 0;
    }

    public boolean update(Showtime s) {
        String sql = "UPDATE `Showtime` SET showDate = ?, startTime = ?, endTime = ?, status = ?, movieId = ?, roomId = ? WHERE id_Showtime = ?";
        return jdbcTemplate.update(sql, s.getShowDate(), s.getStartTime(), s.getEndTime(), s.getStatus(), s.getMovieId(), s.getRoomId(), s.getId_Showtime()) > 0;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM `Showtime` WHERE id_Showtime = ?";
        return jdbcTemplate.update(sql, id) > 0;
    }

    public List<Showtime> findByMovieId(int movieId) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.movieId = ? AND st.status = 'Active'";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, movieId);
    }

    public List<Showtime> findUpcomingShowtimesByMovie(int movieId) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.movieId = ? AND st.status = 'Active' "
                + "AND (st.showDate > CURRENT_DATE OR (st.showDate = CURRENT_DATE AND st.startTime >= CURRENT_TIME)) "
                + "ORDER BY st.showDate ASC, st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, movieId);
    }

    public List<Showtime> findByDate(Date date) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.showDate = ? AND st.status = 'Active' "
                + "ORDER BY st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, date);
    }

    public List<Showtime> findByMovieAndDate(int movieId, Date date) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.movieId = ? AND st.showDate = ? AND st.status = 'Active' "
                + "ORDER BY st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, movieId, date);
    }

    public List<Showtime> findByRoomId(int roomId) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.roomId = ? "
                + "ORDER BY st.showDate DESC, st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, roomId);
    }

    public boolean updateStatus(int showtimeId, String status) {
        String sql = "UPDATE `Showtime` SET status = ? WHERE id_Showtime = ?";
        return jdbcTemplate.update(sql, status, showtimeId) > 0;
    }

    public boolean checkOverlap(int roomId, Timestamp start, Timestamp end) {
        String sql = "SELECT COUNT(*) FROM `Showtime` WHERE roomId = ? AND status != 'Cancelled' AND (? < endTime AND ? > showDate + INTERVAL TIME_TO_SEC(startTime) SECOND)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, roomId, start, end);
        return count != null && count > 0;
    }

    public boolean checkOverlapForUpdate(int showtimeId, int roomId, Timestamp start, Timestamp end) {
        String sql = "SELECT COUNT(*) FROM `Showtime` WHERE roomId = ? AND id_Showtime != ? AND status != 'Cancelled' AND (? < endTime AND ? > showDate + INTERVAL TIME_TO_SEC(startTime) SECOND)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, roomId, showtimeId, start, end);
        return count != null && count > 0;
    }

    public List<Showtime> getActiveShowtimesForRoom(int roomId) {
        String sql = "SELECT st.id_Showtime, st.movieId, st.roomId, st.showDate, st.startTime, st.endTime, st.status AS showtime_status, "
                + "m.title, m.posterUrl, COUNT(t.id_Ticket) AS sold_count "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "INNER JOIN `Ticket` t ON t.showtimeId = st.id_Showtime "
                + "WHERE st.roomId = ? "
                + "AND t.status = 'Sold' "
                + "AND CONCAT(st.showDate, ' ', st.startTime) >= NOW() "
                + "AND CONCAT(st.showDate, ' ', st.startTime) <= DATE_ADD(NOW(), INTERVAL 7 DAY) "
                + "GROUP BY st.id_Showtime, st.movieId, st.roomId, st.showDate, st.startTime, st.endTime, st.status, m.title, m.posterUrl "
                + "HAVING sold_count >= 1 "
                + "ORDER BY st.showDate ASC, st.startTime ASC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Showtime s = new Showtime();
            s.setId_Showtime(rs.getInt("id_Showtime"));
            s.setMovieId(rs.getInt("movieId"));
            s.setRoomId(rs.getInt("roomId"));
            s.setShowDate(rs.getDate("showDate"));
            s.setStartTime(rs.getTime("startTime"));
            s.setEndTime(rs.getTimestamp("endTime"));

            s.setStatus(String.valueOf(rs.getInt("sold_count")));

            Movie m = new Movie();
            m.setId_Movie(rs.getInt("movieId"));
            m.setTitle(rs.getString("title"));
            m.setPosterUrl(rs.getString("posterUrl"));
            s.setMovie(m);

            return s;
        }, roomId);
    }

    public List<Showtime> findByMovieAndSpecificDate(int movieId, java.sql.Date date) {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.movieId = ? AND st.showDate = ? AND st.status = 'Active' "
                + "AND (st.showDate > CURRENT_DATE OR (st.showDate = CURRENT_DATE AND st.startTime >= CURRENT_TIME)) "
                + "ORDER BY st.startTime ASC";
        return jdbcTemplate.query(sql, this::mapRowWithMovie, movieId, date);
    }
    // Giữ nguyên các hàm cũ của bạn, chỉnh sửa câu truy vấn SQL trong hàm findAll() để lấy thêm cột tên phòng chiếu:

    // Thay thế riêng hàm findAlll() của bạn bằng đoạn này:
    public List<Showtime> findAlll() {
        String sql = "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl, r.roomName, r.roomType "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "INNER JOIN `Room` r ON st.roomId = r.id_Room "
                + "ORDER BY st.showDate DESC, st.startTime ASC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Showtime s = new Showtime();
            s.setId_Showtime(rs.getInt("id_Showtime"));
            s.setMovieId(rs.getInt("movieId"));
            s.setRoomId(rs.getInt("roomId"));
            s.setShowDate(rs.getDate("showDate"));
            s.setStartTime(rs.getTime("startTime"));
            s.setEndTime(rs.getTimestamp("endTime"));
            s.setStatus(rs.getString("showtime_status"));

            Movie m = new Movie();
            m.setId_Movie(rs.getInt("id_Movie"));
            m.setTitle(rs.getString("title"));
            m.setPosterUrl(rs.getString("posterUrl"));
            s.setMovie(m);

            // Tạo đối tượng Room giả lập gắn vào Showtime để hiển thị tên phòng và loại phòng
            Room r = new Room();
            r.setId_Room(rs.getInt("roomId"));
            r.setRoomName(rs.getString("roomName"));
            r.setRoomType(rs.getString("roomType")); // <-- Bổ sung lấy loại phòng để load ảnh
            s.setRoom(r);

            return s;
        });
    }

    private Showtime mapRowWithFullMovie(ResultSet rs, int rowNum) throws SQLException {
        Showtime s = new Showtime();
        s.setId_Showtime(rs.getInt("id_Showtime"));
        s.setMovieId(rs.getInt("movieId"));
        s.setRoomId(rs.getInt("roomId"));
        s.setShowDate(rs.getDate("showDate"));
        s.setStartTime(rs.getTime("startTime"));
        s.setEndTime(rs.getTimestamp("endTime"));
        s.setStatus(rs.getString("showtime_status"));

        Movie m = new Movie();
        m.setId_Movie(rs.getInt("id_Movie"));
        m.setTitle(rs.getString("title"));
        m.setDescription(rs.getString("description"));
        m.setDirector(rs.getString("director"));
        m.setDuration(rs.getInt("duration"));
        m.setCast(rs.getString("cast"));
        m.setLanguage(rs.getString("language"));
        m.setReleaseDate(rs.getDate("releaseDate"));
        m.setGenre(rs.getString("genre"));
        m.setProductionYear(rs.getInt("productionYear"));
        m.setCensorship(rs.getString("censorship"));
        m.setPosterUrl(rs.getString("posterUrl"));
        m.setTrailerUrl(rs.getString("trailerUrl"));
        m.setCategory(rs.getString("category"));
        m.setBasePrice(rs.getDouble("basePrice"));
        m.setStatus(rs.getString("movie_status")); // Tránh trùng lặp tên cột status

        s.setMovie(m);
        return s;
    }

    // Lấy chi tiết suất chiếu kèm TOÀN BỘ thông tin Phim
    public Showtime findFullDetailsById(int id) {
        String sql = "SELECT st.*, st.status AS showtime_status, "
                + "m.id_Movie, m.title, m.description, m.director, m.duration, m.cast, "
                + "m.language, m.releaseDate, m.genre, m.productionYear, m.censorship, "
                + "m.posterUrl, m.trailerUrl, m.category, m.basePrice, m.status AS movie_status "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "WHERE st.id_Showtime = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRowWithFullMovie, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    // =========================================================================
    // HÀM MỚI BỔ SUNG: LỌC KẾT HỢP NHIỀU ĐIỀU KIỆN (DYNAMIC SQL)
    // =========================================================================
    public List<Showtime> filterShowtimes(String title, String status, String roomName, String roomType, String roomStatus, String filterDate, String filterTime) {
        StringBuilder sql = new StringBuilder(
                "SELECT st.*, st.status AS showtime_status, m.id_Movie, m.title, m.posterUrl, r.roomName, r.roomType "
                + "FROM `Showtime` st "
                + "INNER JOIN `Movie` m ON st.movieId = m.id_Movie "
                + "INNER JOIN `Room` r ON st.roomId = r.id_Room "
                + "WHERE 1=1 ");

        // 1. Lọc theo tên phim
        if (title != null && !title.trim().isEmpty()) {
            sql.append(" AND LOWER(m.title) LIKE LOWER('%").append(title.trim()).append("%') ");
        }

        // 2. Lọc theo tên phòng
        if (roomName != null && !roomName.trim().isEmpty() && !roomName.equals("Tất cả phòng")) {
            sql.append(" AND r.roomName = '").append(roomName.trim()).append("' ");
        }

        // 3. Lọc theo loại phòng (STANDARD, VIP, IMAX, 4DX, Sweetbox)
        if (roomType != null && !roomType.trim().isEmpty()) {
            sql.append(" AND r.roomType = '").append(roomType.trim()).append("' ");
        }

        // 4. Lọc theo trạng thái phòng (Active, Maintenance)
        if (roomStatus != null && !roomStatus.trim().isEmpty()) {
            sql.append(" AND r.status = '").append(roomStatus.trim()).append("' ");
        }

        // 5. Lọc theo thời gian (Ngày và Giờ)
        if (filterDate != null && !filterDate.trim().isEmpty()) {
            sql.append(" AND st.showDate = '").append(filterDate.trim()).append("' ");
        }
        if (filterTime != null && !filterTime.trim().isEmpty()) {
            // Lọc các suất chiếu bắt đầu SAU HOẶC BẰNG giờ đã chọn
            sql.append(" AND st.startTime >= '").append(filterTime.trim()).append(":00' ");
        }

        // 6. Lọc theo Trạng thái Suất Chiếu (Logic thời gian: Đang chiếu, Sắp chiếu, Đã chiếu)
        if (status != null && !status.trim().isEmpty()) {
            if ("sap_chieu".equals(status)) {
                // Sắp chiếu: Trạng thái DB là Active VÀ Thời gian bắt đầu > hiện tại
                sql.append(" AND st.status = 'Active' AND CAST(CONCAT(st.showDate, ' ', st.startTime) AS DATETIME) > NOW() ");
            } else if ("dang_chieu".equals(status)) {
                // Đang chiếu: Trạng thái DB là Active VÀ Thời gian hiện tại nằm giữa StartTime và EndTime
                sql.append(" AND st.status = 'Active' AND NOW() BETWEEN CAST(CONCAT(st.showDate, ' ', st.startTime) AS DATETIME) AND st.endTime ");
            } else if ("da_chieu".equals(status)) {
                // Đã chiếu: Thời gian kết thúc < hiện tại HOẶC bị đánh dấu Finished trong DB
                sql.append(" AND (st.status = 'Finished' OR st.endTime < NOW()) ");
            } else {
                // Dành cho lọc các trạng thái vật lý trong DB như Cancelled, Ended...
                sql.append(" AND st.status = '").append(status.trim()).append("' ");
            }
        }

        sql.append(" ORDER BY st.showDate DESC, st.startTime ASC");

        return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            Showtime s = new Showtime();
            s.setId_Showtime(rs.getInt("id_Showtime"));
            s.setMovieId(rs.getInt("movieId"));
            s.setRoomId(rs.getInt("roomId"));
            s.setShowDate(rs.getDate("showDate"));
            s.setStartTime(rs.getTime("startTime"));
            s.setEndTime(rs.getTimestamp("endTime"));
            s.setStatus(rs.getString("showtime_status"));

            Movie m = new Movie();
            m.setId_Movie(rs.getInt("id_Movie"));
            m.setTitle(rs.getString("title"));
            m.setPosterUrl(rs.getString("posterUrl"));
            s.setMovie(m);

            Room r = new Room();
            r.setId_Room(rs.getInt("roomId"));
            r.setRoomName(rs.getString("roomName"));
            r.setRoomType(rs.getString("roomType"));
            s.setRoom(r);

            return s;
        });
    }
    // Thêm hàm này vào trong lớp ShowtimeRepository

    public int countSoldTicketsByShowtimeId(int showtimeId) {
        String sql = "SELECT COUNT(*) FROM `Ticket` WHERE showtimeId = ? AND status = 'Sold'";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, showtimeId);
        return count != null ? count : 0;
    }
    // =========================================================================
    // HÀM MỚI BỔ SUNG: Lấy danh sách suất chiếu của phim kèm Tỉ lệ vé & Tên phòng
    // =========================================================================
    public List<Showtime> findShowtimeDetailsByMovieId(int movieId) {
        String sql = "SELECT st.*, st.status AS showtime_status, "
                   + "r.roomName, "
                   + "(SELECT COUNT(*) FROM `Seat` s WHERE s.roomId = st.roomId) AS total_seats, "
                   + "(SELECT COUNT(*) FROM `Ticket` t WHERE t.showtimeId = st.id_Showtime AND t.status = 'Sold') AS sold_count "
                   + "FROM `Showtime` st "
                   + "INNER JOIN `Room` r ON st.roomId = r.id_Room "
                   + "WHERE st.movieId = ? "
                   + "ORDER BY st.showDate DESC, st.startTime ASC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Showtime s = new Showtime();
            s.setId_Showtime(rs.getInt("id_Showtime"));
            s.setMovieId(rs.getInt("movieId"));
            s.setRoomId(rs.getInt("roomId"));
            s.setShowDate(rs.getDate("showDate"));
            s.setStartTime(rs.getTime("startTime"));
            s.setEndTime(rs.getTimestamp("endTime"));
            s.setStatus(rs.getString("showtime_status"));

            // Tận dụng đối tượng Room trong Showtime để lưu các thông tin phụ
            Room r = new Room();
            r.setRoomName(rs.getString("roomName"));
            r.setTotalRows(rs.getInt("total_seats")); // Mượn biến totalRows để chứa tổng số ghế
            r.setTotalCols(rs.getInt("sold_count"));  // Mượn biến totalCols để chứa số vé đã bán
            s.setRoom(r);

            return s;
        }, movieId);
    }
}
