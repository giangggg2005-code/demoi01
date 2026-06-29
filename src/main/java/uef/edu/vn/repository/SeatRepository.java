package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import uef.edu.vn.model.Seat;

@Repository
public class SeatRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Seat mapRow(ResultSet rs, int rowNum) throws SQLException {
        Seat s = new Seat();
        s.setId_Seat(rs.getInt("id_Seat"));
        s.setSeatName(rs.getString("seatName"));
        s.setRowPos(rs.getInt("rowPos"));
        s.setColPos(rs.getInt("colPos"));
        s.setStatus(rs.getString("status"));
        s.setRoomId(rs.getInt("roomId"));
        return s;
    }

    public Seat findById(int id) {
        String sql = "SELECT * FROM `Seat` WHERE id_Seat = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Seat> findAll() {
        String sql = "SELECT * FROM `Seat`";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public boolean save(Seat s) {
        String sql = "INSERT INTO `Seat` (seatName, rowPos, colPos, status, roomId) VALUES (?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, s.getSeatName(), s.getRowPos(), s.getColPos(), s.getStatus(), s.getRoomId()) > 0;
    }

    public boolean update(Seat s) {
        String sql = "UPDATE `Seat` SET seatName = ?, rowPos = ?, colPos = ?, status = ?, roomId = ? WHERE id_Seat = ?";
        return jdbcTemplate.update(sql, s.getSeatName(), s.getRowPos(), s.getColPos(), s.getStatus(), s.getRoomId(), s.getId_Seat()) > 0;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM `Seat` WHERE id_Seat = ?";
        return jdbcTemplate.update(sql, id) > 0;
    }

    public List<Seat> getByRoomId(int roomId) {
        String sql = "SELECT * FROM `Seat` WHERE roomId = ? ORDER BY rowPos, colPos";
        return jdbcTemplate.query(sql, this::mapRow, roomId);
    }

    public Seat getSeatByPosition(int roomId, int row, int col) {
        String sql = "SELECT * FROM `Seat` WHERE roomId = ? AND rowPos = ? AND colPos = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, roomId, row, col);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public boolean updateSeatStatus(int id, String status) {
        String sql = "UPDATE `Seat` SET status = ? WHERE id_Seat = ?";
        return jdbcTemplate.update(sql, status, id) > 0;
    }

    public boolean isSeatAvailable(int seatId) {
        String sql = "SELECT status FROM `Seat` WHERE id_Seat = ?";
        try {
            String status = jdbcTemplate.queryForObject(sql, String.class, seatId);
            return "Available".equalsIgnoreCase(status);
        } catch (EmptyResultDataAccessException e) {
            return false;
        }
    }

    public boolean areAllSeatsAvailable(List<Integer> seatIds) {
        if (seatIds == null || seatIds.isEmpty()) {
            return false;
        }

        String placeholders = seatIds.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql = "SELECT COUNT(*) FROM `Seat` WHERE status = 'Available' AND id_Seat IN (" + placeholders + ")";

        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, seatIds.toArray());
        return count != null && count == seatIds.size();
    }

    public List<Seat> getAllAvailableSeatsByRoom(int roomId) {
        String sql = "SELECT * FROM `Seat` WHERE roomId = ? AND status = 'Available'";
        return jdbcTemplate.query(sql, this::mapRow, roomId);
    }

    public List<Seat> findByRoomId(int roomId) {
        String sql = "SELECT * FROM `Seat` WHERE roomId = ? ORDER BY rowPos ASC, colPos ASC";
        return jdbcTemplate.query(sql, this::mapRow, roomId);
    }

    public int countFutureSoldTicketsBySeatId(int seatId) {
        String sql = "SELECT COUNT(*) FROM `Ticket` t "
                + "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime "
                + "WHERE t.seatId = ? AND t.status = 'Sold' "
                + "AND CONCAT(st.showDate, ' ', st.startTime) >= NOW() "
                + "AND CONCAT(st.showDate, ' ', st.startTime) <= DATE_ADD(NOW(), INTERVAL 7 DAY)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, seatId);
        return count != null ? count : 0;
    }

    public void updateAllSeatsByRoomId(int roomId, String targetStatus) {
        String sql = "UPDATE `Seat` SET status = ? WHERE roomId = ?";
        jdbcTemplate.update(sql, targetStatus, roomId);
    }

    public void updateSeatsStatusByRoomId(int roomId, String oldStatus, String newStatus) {
        String sql = "UPDATE `Seat` SET status = ? WHERE roomId = ? AND status = ?";
        jdbcTemplate.update(sql, newStatus, roomId, oldStatus);
    }

    public void deleteAllSeatsByRoomId(int roomId) {
        String sql = "DELETE FROM `Seat` WHERE roomId = ?";
        jdbcTemplate.update(sql, roomId);
    }

    public void insertSeat(Seat seat) {
        String sql = "INSERT INTO `Seat` (seatName, rowPos, colPos, status, roomId) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, seat.getSeatName(), seat.getRowPos(), seat.getColPos(), seat.getStatus(), seat.getRoomId());
    }
}