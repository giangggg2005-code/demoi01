package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

public class BookingDetail {

    @Min(value = 0, message = "ID chi tiết đặt vé không được là số âm")
    private int id_Detail;

    @PositiveOrZero(message = "Giá vé trong chi tiết phải lớn hơn hoặc bằng 0")
    @Digits(integer = 10, fraction = 2, message = "Giá vé vượt quá giới hạn hoặc sai định dạng thập phân")
    @Max(value = 5000000, message = "Giá vé không thực tế (Không được vượt quá 5.000.000 VND)")
    private double price;

    @Min(value = 1, message = "Mã hóa đơn đặt vé (bookingId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int bookingId;

    @Min(value = 1, message = "Mã vé (ticketId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int ticketId;

    @NotNull(message = "Thông tin đối tượng Vé (Ticket) không được để trống")
    @Valid
    private Ticket ticket;

    @AssertTrue(message = "Ngoại lệ dữ liệu: Mã ticketId phẳng và ID bên trong đối tượng Ticket không trùng khớp nhau!")
    public boolean isTicketIdValid() {
        if (this.ticket != null) {
            return this.ticketId == this.ticket.getId_Ticket();
        }
        return true;
    }

    public BookingDetail() {
        this.id_Detail = 0;
        this.price = 0.0;
        this.bookingId = 0;
        this.ticketId = 0;
        this.ticket = null;
    }

    public BookingDetail(int id_Detail, double price, int bookingId, int ticketId, Ticket ticket) {
        this.id_Detail = id_Detail;
        this.price = price;
        this.bookingId = bookingId;
        this.ticketId = ticketId;
        this.ticket = ticket;
    }

    public int getId_Detail() { return id_Detail; }
    public void setId_Detail(int id_Detail) { this.id_Detail = id_Detail; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public Ticket getTicket() { 
        return ticket; 
    }

    public void setTicket(Ticket ticket) { 
        this.ticket = ticket; 
        
        if (ticket != null) {
            this.ticketId = ticket.getId_Ticket();
        }
    }
}