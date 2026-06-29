package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.sql.Timestamp;

public class Booking {

    @Min(value = 0, message = "ID Booking không được là số âm")
    private int id_Booking;

    @NotNull(message = "Ngày đặt vé không được để trống")
    @PastOrPresent(message = "Ngày đặt vé không thể là một ngày trong tương lai")
    private Timestamp bookingDate;

    @PositiveOrZero(message = "Tổng tiền phải lớn hơn hoặc bằng 0")
    private double totalAmount;

    @NotBlank(message = "Vui lòng chọn phương thức thanh toán")
    @Size(min = 2, max = 50, message = "Tên phương thức thanh toán phải từ 2 đến 50 ký tự")
    private String paymentMethod;

    @NotBlank(message = "Trạng thái không được để trống")
    @Size(min = 3, max = 50, message = "Trạng thái phải từ 3 đến 50 ký tự")
    private String status;

    @Min(value = 1, message = "Mã ID người dùng phải hợp lệ (lớn hơn hoặc bằng 1)")
    private Integer userId;

    @Min(value = 1, message = "Mã ID thanh toán phải lớn hơn hoặc bằng 1")
    private Integer paymentId;

    @Valid
    private User user;

    @Valid
    private Payment payment;

    public Booking() {
        this.id_Booking = 0;
        this.bookingDate = new Timestamp(System.currentTimeMillis());
        this.totalAmount = 0.0;
        this.paymentMethod = "Cash";
        this.status = "Pending";
        this.userId = null;
        this.paymentId = null;

        this.user = null;
        this.payment = null;
    }

    public Booking(int id_Booking, Timestamp bookingDate, double totalAmount, String paymentMethod, String status,
            Integer userId, Integer paymentId, User user, Payment payment) {
        this.id_Booking = id_Booking;
        this.bookingDate = bookingDate;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.userId = userId;
        this.paymentId = paymentId;
        this.user = user;
        this.payment = payment;
    }

    public int getId_Booking() {
        return id_Booking;
    }

    public void setId_Booking(int id_Booking) {
        this.id_Booking = id_Booking;
    }

    public Timestamp getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(Timestamp bookingDate) {
        this.bookingDate = bookingDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Integer paymentId) {
        this.paymentId = paymentId;
    }

    public User getUser() {
        return user;
    }

    @AssertTrue(message = "Lỗi toàn vẹn dữ liệu: Mã userId phẳng không trùng khớp với ID trong thực thể User!")
    public boolean isUserIdMatched() {
        if (this.user != null && this.userId != null) {
            return this.userId.equals(this.user.getId_User());
        }
        return true;
    }

    @AssertTrue(message = "Lỗi toàn vẹn dữ liệu: Mã paymentId phẳng không trùng khớp với ID trong thực thể Payment!")
    public boolean isPaymentIdMatched() {
        if (this.payment != null && this.paymentId != null) {
            return this.paymentId.equals(this.payment.getId_Payment());
        }
        return true;
    }

    public void setUser(User user) {
        this.user = user;
        if (user != null) {
            this.userId = user.getId_User();
        } else {
            this.userId = null;
        }
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
        if (payment != null) {
            this.paymentId = payment.getId_Payment();
        } else {
            this.paymentId = null;
        }
    }
}