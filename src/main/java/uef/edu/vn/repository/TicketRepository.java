package uef.edu.vn.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Ticket;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.model.Seat;
import uef.edu.vn.model.Movie;

@Repository
public class TicketRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Ticket mapToTicketDetail(ResultSet rs, int rowNum) throws SQLException {
        Ticket t = new Ticket();
        t.setId_Ticket(rs.getInt("id_Ticket"));
        t.setShowtimeId(rs.getInt("showtimeId"));
        t.setSeatId(rs.getInt("seatId"));
        t.setPrice(rs.getDouble("price"));
        t.setStatus(rs.getString("ticket_status"));

        Showtime s = new Showtime();
        s.setId_Showtime(rs.getInt("id_Showtime"));
        s.setShowDate(rs.getDate("showDate"));
        s.setStartTime(rs.getTime("startTime"));
        s.setEndTime(rs.getTimestamp("endTime"));
        s.setStatus(rs.getString("showtime_status"));
        s.setMovieId(rs.getInt("movieId"));
        s.setRoomId(rs.getInt("roomId"));
        
        Movie m = new Movie();
        m.setId_Movie(rs.getInt("id_Movie"));
        m.setTitle(rs.getString("title"));
        m.setPosterUrl(rs.getString("posterUrl"));
        s.setMovie(m); 
        
        t.setShowtime(s); 

        Seat seat = new Seat();
        seat.setId_Seat(rs.getInt("id_Seat"));
        seat.setSeatName(rs.getString("seatName"));
        seat.setRowPos(rs.getInt("rowPos"));
        seat.setColPos(rs.getInt("colPos"));
        seat.setStatus(rs.getString("seat_status"));
        seat.setRoomId(rs.getInt("roomId"));
        
        t.setSeat(seat); 

        return t;
    }

    public Ticket findById(int id) {
        String sql = "SELECT t.*, t.status AS ticket_status, " +
                     "st.*, st.status AS showtime_status, " +
                     "s.*, s.status AS seat_status, " +
                     "m.id_Movie, m.title, m.posterUrl " +
                     "FROM `Ticket` t " +
                     "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "INNER JOIN `Seat` s ON t.seatId = s.id_Seat " +
                     "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     "WHERE t.id_Ticket = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapToTicketDetail, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Ticket> findAll() {
        String sql = "SELECT t.*, t.status AS ticket_status, " +
                     "st.*, st.status AS showtime_status, " +
                     "s.*, s.status AS seat_status, " +
                     "m.id_Movie, m.title, m.posterUrl " +
                     "FROM `Ticket` t " +
                     "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "INNER JOIN `Seat` s ON t.seatId = s.id_Seat " +
                     "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     "ORDER BY t.id_Ticket DESC";
        return jdbcTemplate.query(sql, this::mapToTicketDetail);
    }

    public boolean save(Ticket t) {
        String sql = "INSERT INTO `Ticket` (showtimeId, seatId, price, status) VALUES (?, ?, ?, ?)";
        return jdbcTemplate.update(sql, t.getShowtimeId(), t.getSeatId(), t.getPrice(), t.getStatus()) > 0;
    }

    public boolean update(Ticket t) {
        String sql = "UPDATE `Ticket` SET showtimeId = ?, seatId = ?, price = ?, status = ? WHERE id_Ticket = ?";
        return jdbcTemplate.update(sql, t.getShowtimeId(), t.getSeatId(), t.getPrice(), t.getStatus(), t.getId_Ticket()) > 0;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM `Ticket` WHERE id_Ticket = ?";
        return jdbcTemplate.update(sql, id) > 0;
    }

    public Ticket findDetailById(int id_Ticket) {
        return findById(id_Ticket);
    }

    public List<Ticket> findByBookingId(int bookingId) {
        String sql = "SELECT t.*, t.status AS ticket_status, " +
                     "st.*, st.status AS showtime_status, " +
                     "s.*, s.status AS seat_status, " +
                     "m.id_Movie, m.title, m.posterUrl " +
                     "FROM `Ticket` t " +
                     "INNER JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId " +
                     "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "INNER JOIN `Seat` s ON t.seatId = s.id_Seat " +
                     "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     "WHERE bd.bookingId = ?";
        return jdbcTemplate.query(sql, this::mapToTicketDetail, bookingId);
    }

    public List<Ticket> findByShowtime(int showtimeId) {
        String sql = "SELECT t.*, t.status AS ticket_status, " +
                     "st.*, st.status AS showtime_status, " +
                     "s.*, s.status AS seat_status, " +
                     "m.id_Movie, m.title, m.posterUrl " +
                     "FROM `Ticket` t " +
                     "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
                     "INNER JOIN `Seat` s ON t.seatId = s.id_Seat " +
                     "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
                     "WHERE t.showtimeId = ? ORDER BY s.seatName ASC";
        return jdbcTemplate.query(sql, this::mapToTicketDetail, showtimeId);
    }

    public boolean updateStatus(int ticketId, String status) {
        String sql = "UPDATE `Ticket` SET status = ? WHERE id_Ticket = ?";
        return jdbcTemplate.update(sql, status, ticketId) > 0;
    }

    public boolean updateMultipleTicketStatus(List<Integer> ticketIds, String status) {
        if (ticketIds == null || ticketIds.isEmpty()) return false;
        String sql = "UPDATE `Ticket` SET status = ? WHERE id_Ticket = ?";

        int[] results = jdbcTemplate.batchUpdate(sql, new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setString(1, status);
                ps.setInt(2, ticketIds.get(i));
            }

            @Override
            public int getBatchSize() {
                return ticketIds.size();
            }
        });

        return results.length == ticketIds.size();
    }
    // =========================================================================
    // HÀM BỔ SUNG: Lấy chi tiết Hóa đơn, Vé và Khách hàng dựa vào Suất chiếu & Ghế
    // =========================================================================
    public java.util.Map<String, Object> getTicketAndBookingInfo(int showtimeId, int seatId) {
        // Đã thay đổi từ JOIN sang LEFT JOIN để đảm bảo vé luôn được lấy lên 
        // ngay cả khi không có dữ liệu Booking hay User đi kèm.
        String sql = "SELECT t.id_Ticket, t.price AS ticketPrice, t.status AS ticketStatus, " +
                     "b.id_Booking, b.bookingDate, b.totalAmount, b.paymentMethod, " +
                     "u.id_User, u.fullName, u.phone, u.email " +
                     "FROM `Ticket` t " +
                     "LEFT JOIN `BookingDetail` bd ON t.id_Ticket = bd.ticketId " +
                     "LEFT JOIN `Booking` b ON bd.bookingId = b.id_Booking " +
                     "LEFT JOIN `User` u ON b.userId = u.id_User " +
                     "WHERE t.showtimeId = ? AND t.seatId = ?";
        try {
            return jdbcTemplate.queryForMap(sql, showtimeId, seatId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null; // Không tìm thấy vé
        }
    }
}