package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Room;
import uef.edu.vn.model.Seat;

@Repository
public class RoomRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // --- MAPPING METHOD ---
    private Room mapRow(ResultSet rs, int rowNum) throws SQLException {
        Room r = new Room();
        r.setId_Room(rs.getInt("id_Room"));
        r.setRoomName(rs.getString("roomName"));
        r.setTotalRows(rs.getInt("totalRows"));
        r.setTotalCols(rs.getInt("totalCols"));
        r.setStatus(rs.getString("status"));
        // Thêm 2 trường DB mới
        r.setRoomType(rs.getString("roomType"));
        r.setRoomPrice(rs.getDouble("roomPrice"));
        return r;
    }

    // --- CÁC HÀM TRUY VẤN CƠ BẢN (CRUD) ---
    
    public List<Room> findAll() {
        String sql = "SELECT * FROM `Room`";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public Room findById(int id) {
        String sql = "SELECT * FROM `Room` WHERE id_Room = ?";
        try { 
            return jdbcTemplate.queryForObject(sql, this::mapRow, id); 
        } catch (EmptyResultDataAccessException e) { 
            return null; 
        }
    }

    public void save(Room r) {
        String sql = "INSERT INTO `Room` (roomName, totalRows, totalCols, status, roomType, roomPrice) VALUES (?, ?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, r.getRoomName(), r.getTotalRows(), r.getTotalCols(), r.getStatus(), r.getRoomType(), r.getRoomPrice());
    }

   /**
     * Cập nhật thông tin phòng chiếu vào Database
     * @param r Đối tượng Room chứa thông tin mới
     * @return true nếu cập nhật thành công ít nhất 1 dòng, false nếu thất bại
     */
    public boolean update(Room r) {
        // [SỬA LỖI Ở ĐÂY]: Chốt chặn an toàn tuyệt đối. 
        // Nếu Server vì lý do nào đó vẫn nhận ID = 0, lập tức quăng lỗi ra màn hình để biết đường sửa, không được chạy SQL ngầm.
        if (r.getId_Room() <= 0) {
            throw new IllegalArgumentException("Lỗi hệ thống: ID phòng chiếu không hợp lệ (" + r.getId_Room() + "). Cập nhật bị từ chối.");
        }

        String sql = "UPDATE `Room` " +
                     "SET roomName = ?, totalRows = ?, totalCols = ?, status = ?, roomType = ?, roomPrice = ? " +
                     "WHERE id_Room = ?";
                     
        // jdbcTemplate.update trả về số dòng bị tác động (kiểu int)
        int rowsAffected = jdbcTemplate.update(sql, 
            r.getRoomName(), 
            r.getTotalRows(), 
            r.getTotalCols(), 
            r.getStatus(), 
            r.getRoomType(), 
            r.getRoomPrice(), 
            r.getId_Room()
        );
        
        // Nếu số dòng lớn hơn 0 nghĩa là DB đã cập nhật thành công -> trả về true
        return rowsAffected > 0;
    }

    public void deleteById(int id) {
        // Xóa ghế trước để tránh lỗi Foreign Key
        jdbcTemplate.update("DELETE FROM `Seat` WHERE roomId = ?", id);
        String sql = "DELETE FROM `Room` WHERE id_Room = ?";
        jdbcTemplate.update(sql, id);
    }

    // --- CÁC HÀM NGHIỆP VỤ ĐẶC THÙ (ĐÃ ĐƯỢC PHỤC HỒI TỪ CODE CŨ) ---
    
    public List<Room> findByStatus(String status) {
        String sql = "SELECT * FROM `Room` WHERE status = ?";
        return jdbcTemplate.query(sql, this::mapRow, status);
    }

    public Room findByName(String roomName) {
        String sql = "SELECT * FROM `Room` WHERE roomName = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, roomName);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public boolean changeStatus(int roomId, String newStatus) {
        String sql = "UPDATE `Room` SET status = ? WHERE id_Room = ?";
        return jdbcTemplate.update(sql, newStatus, roomId) > 0;
    }

    /**
     * Lấy thông tin phòng chiếu VÀ tự động gom cụm danh sách ghế phức tạp (Sử dụng ResultSetExtractor)
     * Đã được nâng cấp để lấy thêm roomType và roomPrice
     */
    
   /**
     * Lấy thông tin phòng chiếu VÀ tự động gom cụm danh sách ghế phức tạp (Sử dụng ResultSetExtractor)
     * Đã được nâng cấp để lấy thêm roomType, roomPrice và xử lý trạng thái kép (Vé đã bán + Ghế bảo trì)
     */
    public Room findRoomWithSeatStatusByShowtimeId(int showtimeId) {
        String sql = "SELECT r.id_Room, r.roomName, r.totalRows, r.totalCols, r.status AS room_status, r.roomType, r.roomPrice, " +
                     "s.id_Seat, s.seatName, s.rowPos, s.colPos, s.status AS origin_seat_status, t.status AS ticket_status " +
                     "FROM `Showtime` st " +
                     "JOIN `Room` r ON st.roomId = r.id_Room " +
                     "LEFT JOIN `Seat` s ON r.id_Room = s.roomId " +
                     "LEFT JOIN `Ticket` t ON s.id_Seat = t.seatId AND t.showtimeId = st.id_Showtime " +
                     "WHERE st.id_Showtime = ? " +
                     "ORDER BY s.rowPos, s.colPos ASC";

        return jdbcTemplate.query(sql, rs -> {
            Room room = null;
            List<Seat> seatList = new ArrayList<>();
            
            while (rs.next()) {
                if (room == null) {
                    room = new Room();
                    room.setId_Room(rs.getInt("id_Room"));
                    room.setRoomName(rs.getString("roomName"));
                    room.setTotalRows(rs.getInt("totalRows"));
                    room.setTotalCols(rs.getInt("totalCols"));
                    room.setStatus(rs.getString("room_status"));
                    // Lấy thêm trường mới ở đây để đồng bộ
                    room.setRoomType(rs.getString("roomType"));
                    room.setRoomPrice(rs.getDouble("roomPrice"));
                }
                
                int seatId = rs.getInt("id_Seat");
                if (seatId > 0) {
                    Seat seat = new Seat();
                    seat.setId_Seat(seatId);
                    seat.setRoomId(rs.getInt("id_Room"));
                    seat.setSeatName(rs.getString("seatName"));
                    seat.setRowPos(rs.getInt("rowPos"));
                    seat.setColPos(rs.getInt("colPos"));
                    
                    String originSeatStatus = rs.getString("origin_seat_status");
                    String ticketStatus = rs.getString("ticket_status");
                    
                    // =========================================================
                    // SỬA LỖI LOGIC: Ưu tiên kiểm tra vé đã bán (Sold) trước.
                    // Nếu vé đã bán mà ghế lại đang bảo trì -> Trạng thái kép
                    // =========================================================
                    if ("Sold".equalsIgnoreCase(ticketStatus)) {
                        if ("Broken".equalsIgnoreCase(originSeatStatus) || "Maintenance".equalsIgnoreCase(originSeatStatus)) {
                            seat.setStatus("Sold_Maintenance"); // Trạng thái nửa vàng nửa xám
                        } else {
                            seat.setStatus("Sold"); // Trạng thái vàng
                        }
                    } else {
                        // Nếu chưa bán vé, xét trạng thái vật lý của ghế
                        if ("Broken".equalsIgnoreCase(originSeatStatus) || "Maintenance".equalsIgnoreCase(originSeatStatus)) {
                            seat.setStatus("Broken"); // Trạng thái xám
                        } else {
                            seat.setStatus("Available"); // Trạng thái trống (đỏ)
                        }
                    }
                    // =========================================================

                    seatList.add(seat);
                }
            }
            
            if (room != null) {
                room.setSeats(seatList);
            }
            return room;
        }, showtimeId);
    }
    public boolean checkRoomNameExistsForUpdate(String roomName, int roomId) {
        String sql = "SELECT COUNT(*) FROM `Room` WHERE roomName = ? AND id_Room != ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, roomName, roomId);
        return count != null && count > 0;
    }
    // THÊM: Kiểm tra số lượng vé đã bán ở các suất chiếu tương lai thuộc phòng này
   // THÊM/SỬA: Kiểm tra toàn phòng có vé tương lai không
    public int countFutureSoldTicketsByRoomId(int roomId) {
        String sql = "SELECT COUNT(*) FROM `Ticket` t " +
                     "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "WHERE st.roomId = ? AND t.status = 'Sold' " +
                     "AND CONCAT(st.showDate, ' ', st.startTime) >= NOW() " +
                     "AND CONCAT(st.showDate, ' ', st.startTime) <= DATE_ADD(NOW(), INTERVAL 7 DAY)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, roomId);
        return count != null ? count : 0;
    }

    public boolean updateRoomStatusInDB(int roomId, String status) {
        String sql = "UPDATE `Room` SET status = ? WHERE id_Room = ?";
        return jdbcTemplate.update(sql, status, roomId) > 0;
    }
}