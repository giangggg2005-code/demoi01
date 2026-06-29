package uef.edu.vn.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Booking;
import uef.edu.vn.model.User;
import uef.edu.vn.model.Payment;

@Repository
public class BookingRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String BASE_SELECT_SQL = 
        "SELECT b.*, b.status AS booking_status, u.id_User, p.id_Payment " +
        "FROM `Booking` b " +
        "LEFT JOIN `User` u ON b.userId = u.id_User " +
        "LEFT JOIN `Payment` p ON b.paymentId = p.id_Payment";

    private Booking mapRow(ResultSet rs, int rowNum) throws SQLException {
        Booking b = new Booking();
        b.setId_Booking(rs.getInt("id_Booking"));
        b.setBookingDate(rs.getTimestamp("bookingDate"));
        b.setTotalAmount(rs.getDouble("totalAmount"));
        b.setPaymentMethod(rs.getString("paymentMethod"));
        b.setStatus(rs.getString("booking_status")); 

        int userId = rs.getInt("userId");
        if (rs.wasNull()) {
            b.setUserId(null);
            b.setUser(null);
        } else {
            b.setUserId(userId);
            User u = new User();
            u.setId_User(rs.getInt("id_User"));
            b.setUser(u);
        }

        int paymentId = rs.getInt("paymentId");
        if (rs.wasNull()) {
            b.setPaymentId(null);
            b.setPayment(null);
        } else {
            b.setPaymentId(paymentId);
            Payment p = new Payment();
            p.setId_Payment(rs.getInt("id_Payment"));
            b.setPayment(p);
        }

        return b;
    }

    public List<Booking> findAll() {
        String sql = BASE_SELECT_SQL + " ORDER BY b.bookingDate DESC";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public Booking findById(int id) {
        String sql = BASE_SELECT_SQL + " WHERE b.id_Booking = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public void save(Booking b) {
        String sql = "INSERT INTO `Booking` (bookingDate, totalAmount, paymentMethod, status, userId, paymentId) VALUES (?, ?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, b.getBookingDate(), b.getTotalAmount(), b.getPaymentMethod(), b.getStatus(), b.getUserId(), b.getPaymentId());
    }

    public int saveAndGetId(Booking b) {
        String sql = "INSERT INTO `Booking` (bookingDate, totalAmount, paymentMethod, status, userId, paymentId) VALUES (?, ?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setTimestamp(1, b.getBookingDate());
            ps.setDouble(2, b.getTotalAmount());
            ps.setString(3, b.getPaymentMethod());
            ps.setString(4, b.getStatus());
            
            if (b.getUserId() != null) {
                ps.setInt(5, b.getUserId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }

            if (b.getPaymentId() != null) {
                ps.setInt(6, b.getPaymentId());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            return ps;
        }, keyHolder);

        return keyHolder.getKey() != null ? keyHolder.getKey().intValue() : -1;
    }

    public void update(Booking b) {
        String sql = "UPDATE `Booking` SET bookingDate = ?, totalAmount = ?, paymentMethod = ?, status = ?, userId = ?, paymentId = ? WHERE id_Booking = ?";
        jdbcTemplate.update(sql, b.getBookingDate(), b.getTotalAmount(), b.getPaymentMethod(), b.getStatus(), b.getUserId(), b.getPaymentId(), b.getId_Booking());
    }

    public void deleteById(int id) {
        String sql = "DELETE FROM `Booking` WHERE id_Booking = ?";
        jdbcTemplate.update(sql, id);
    }

    public List<Booking> getHistoryByUser(int userId) {
        String sql = BASE_SELECT_SQL + " WHERE b.userId = ? ORDER BY b.bookingDate DESC";
        return jdbcTemplate.query(sql, this::mapRow, userId);
    }

    public List<Booking> findByStatus(String status) {
        String sql = BASE_SELECT_SQL + " WHERE b.status = ? ORDER BY b.bookingDate DESC";
        return jdbcTemplate.query(sql, this::mapRow, status);
    }

    public List<Booking> findWithPagination(int limit, int offset) {
        String sql = BASE_SELECT_SQL + " ORDER BY b.bookingDate DESC LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, this::mapRow, limit, offset);
    }

    public void updateStatus(int bookingId, String status) {
        String sql = "UPDATE `Booking` SET status = ? WHERE id_Booking = ?";
        jdbcTemplate.update(sql, status, bookingId);
    }
}