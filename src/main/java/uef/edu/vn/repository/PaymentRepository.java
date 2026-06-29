package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.Payment;

@Repository
public class PaymentRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // --- MAPPING METHOD ---
    private Payment mapRow(ResultSet rs, int rowNum) throws SQLException {
        Payment p = new Payment();
        p.setId_Payment(rs.getInt("id_Payment"));
        p.setUserId(rs.getInt("userId"));
        p.setCardNumber(rs.getString("cardNumber"));
        p.setPinCode(rs.getString("pinCode"));
        p.setBalance(rs.getDouble("balance"));
        return p;
    }

    // --- CÁC HÀM TRUY VẤN CƠ BẢN (CRUD) ---
    
    public List<Payment> findAll() {
        String sql = "SELECT * FROM `Payment`";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public Payment findById(int id) {
        String sql = "SELECT * FROM `Payment` WHERE id_Payment = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public void save(Payment p) {
        String sql = "INSERT INTO `Payment` (userId, cardNumber, balance, pinCode) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql, p.getUserId(), p.getCardNumber(), p.getBalance(), p.getPinCode());
    }

    public void update(Payment p) {
        String sql = "UPDATE `Payment` SET userId = ?, cardNumber = ?, balance = ?, pinCode = ? WHERE id_Payment = ?";
        jdbcTemplate.update(sql, p.getUserId(), p.getCardNumber(), p.getBalance(), p.getPinCode(), p.getId_Payment());
    }

    public void deleteById(int id) {
        String sql = "DELETE FROM `Payment` WHERE id_Payment = ?";
        jdbcTemplate.update(sql, id);
    }

    // --- CÁC HÀM NGHIỆP VỤ ĐẶC THÙ VÀ BẢO MẬT ---

    /**
     * Lấy thông tin tài khoản thanh toán từ một mã hóa đơn Booking cụ thể
     */
    public Payment findByBookingId(int bookingId) {
        String sql = "SELECT p.* FROM `Payment` p " +
                     "INNER JOIN `Booking` b ON p.id_Payment = b.paymentId " +
                     "WHERE b.id_Booking = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, bookingId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * Lấy danh sách các thẻ/tài khoản thanh toán thuộc về một User
     */
    public List<Payment> getPaymentsByUser(int userId) {
        String sql = "SELECT * FROM `Payment` WHERE userId = ?";
        return jdbcTemplate.query(sql, this::mapRow, userId);
    }

    /**
     * Tìm kiếm thông tin thẻ dựa vào Số thẻ (Dùng khi người dùng liên kết thẻ mới)
     */
    public Payment findByCardNumber(String cardNumber) {
        String sql = "SELECT * FROM `Payment` WHERE cardNumber = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, cardNumber);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * KIỂM TRA MÃ PIN (Bảo mật thanh toán)
     */
    public boolean verifyPin(int paymentId, String inputPin) {
        String sql = "SELECT COUNT(*) FROM `Payment` WHERE id_Payment = ? AND pinCode = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, paymentId, inputPin);
        return count != null && count > 0;
    }

    /**
     * LOGIC TRỪ TIỀN TÀI KHOẢN (Giữ nguyên kiểu trả về boolean để báo trạng thái thành công cho Service)
     */
    public boolean deductBalance(int paymentId, double amount) {
        if (amount <= 0) return false;
        String sql = "UPDATE `Payment` SET balance = balance - ? WHERE id_Payment = ? AND balance >= ?";
        int rowsAffected = jdbcTemplate.update(sql, amount, paymentId, amount);
        return rowsAffected > 0;
    }

    /**
     * HOÀN TIỀN VÀO THẺ (Refund)
     */
    public boolean refundBalance(int paymentId, double amount) {
        if (amount <= 0) return false;
        String sql = "UPDATE `Payment` SET balance = balance + ? WHERE id_Payment = ?";
        int rowsAffected = jdbcTemplate.update(sql, amount, paymentId);
        return rowsAffected > 0;
    }

    /**
     * NẠP TIỀN VÀO THẺ (Top-up)
     */
    public boolean topUpBalance(int paymentId, double amount) {
        if (amount <= 0) return false;
        String sql = "UPDATE `Payment` SET balance = balance + ? WHERE id_Payment = ?";
        int rowsAffected = jdbcTemplate.update(sql, amount, paymentId);
        return rowsAffected > 0;
    }

    /**
     * ĐỔI MÃ PIN THẺ (Change PIN)
     */
    public boolean changePin(int paymentId, String newPin) {
        if (newPin == null || newPin.trim().isEmpty()) return false;
        String sql = "UPDATE `Payment` SET pinCode = ? WHERE id_Payment = ?";
        int rowsAffected = jdbcTemplate.update(sql, newPin, paymentId);
        return rowsAffected > 0;
    }
}