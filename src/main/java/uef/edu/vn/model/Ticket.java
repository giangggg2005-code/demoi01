package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.util.Arrays;
import java.util.List;

public class Ticket {

    @Min(value = 0, message = "ID vé không được là số âm")
    private int id_Ticket;

    @Min(value = 1, message = "Mã suất chiếu (showtimeId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int showtimeId;

    @Min(value = 1, message = "Mã ghế ngồi (seatId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int seatId;

    @PositiveOrZero(message = "Giá vé không được là số âm")
    @Digits(integer = 8, fraction = 2, message = "Giá vé vượt quá giới hạn số tiền hoặc sai định dạng thập phân")
    private double price;

    @NotBlank(message = "Trạng thái vé không được để trống")
    @Size(max = 30, message = "Trạng thái vé quá dài (Tối đa 30 ký tự)")
    private String status;

    @Valid
    private Showtime showtime;

    @Valid
    private Seat seat;

    @AssertTrue(message = "Lỗi toàn vẹn dữ liệu: Mã showtimeId phẳng không trùng khớp với ID trong thực thể Showtime!")
    public boolean isShowtimeIdMatched() {
        if (this.showtime != null) {
            return this.showtimeId == this.showtime.getId_Showtime();
        }
        return true;
    }

    @AssertTrue(message = "Lỗi toàn vẹn dữ liệu: Mã seatId phẳng không trùng khớp với ID trong thực thể Seat!")
    public boolean isSeatIdMatched() {
        if (this.seat != null) {
            return this.seatId == this.seat.getId_Seat();
        }
        return true;
    }

    @AssertTrue(message = "Lỗi logic: Trạng thái vé không hợp lệ! (Chỉ chấp nhận: Available, Booked, Sold, Pending)")
    public boolean isTicketStatusValid() {
        if (this.status != null) {
            List<String> validStatuses = Arrays.asList("Available", "Booked", "Sold", "Pending");
            return validStatuses.contains(this.status);
        }
        return true;
    }
    public Ticket() {
        this.id_Ticket = 0;
        this.showtimeId = 0;
        this.seatId = 0;
        this.price = 0.0;
        this.status = "Available";
        this.showtime = null;
        this.seat = null;
    }

    public Ticket(int id_Ticket, int showtimeId, int seatId, double price, String status) {
        this.id_Ticket = id_Ticket;
        this.showtimeId = showtimeId;
        this.seatId = seatId;
        this.price = price;
        this.status = status;
        this.showtime = null;
        this.seat = null;
    }

    public Ticket(int id_Ticket, int showtimeId, int seatId, double price, String status, Showtime showtime, Seat seat) {
        this.id_Ticket = id_Ticket;
        this.showtimeId = showtimeId;
        this.seatId = seatId;
        this.price = price;
        this.status = status;
        this.showtime = showtime;
        this.seat = seat;
    }

    public int getId_Ticket() {
        return id_Ticket;
    }

    public void setId_Ticket(int id_Ticket) {
        this.id_Ticket = id_Ticket;
    }

    public int getShowtimeId() {
        return showtimeId;
    }

    public void setShowtimeId(int showtimeId) {
        this.showtimeId = showtimeId;
    }

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Showtime getShowtime() {
        return showtime;
    }

    public void setShowtime(Showtime showtime) {
        this.showtime = showtime;
        if (showtime != null) {
            this.showtimeId = showtime.getId_Showtime();
        }
    }

    public Seat getSeat() {
        return seat;
    }

    public void setSeat(Seat seat) {
        this.seat = seat;
        if (seat != null) {
            this.seatId = seat.getId_Seat();
        }
    }
}
