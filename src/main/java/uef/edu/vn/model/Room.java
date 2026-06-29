package uef.edu.vn.model;

import jakarta.validation.constraints.*;
import java.util.Arrays;
import java.util.List;

public class Room {

    @Min(value = 0, message = "ID phòng chiếu không được là số âm")
    private int id_Room;

    @NotBlank(message = "Tên phòng chiếu không được để trống")
    @Size(min = 2, max = 50, message = "Tên phòng chiếu phải từ 2 đến 50 ký tự")
    @Pattern(regexp = "^[a-zA-Z0-9\\s-_]+$", message = "Tên phòng không hợp lệ (Chỉ cho phép chữ cái, chữ số, khoảng trắng, dấu gạch ngang hoặc gạch dưới)")
    private String roomName;

   @Min(value = 1, message = "Số hàng ghế (Rows) phải có ít nhất là 1 hàng.")
    @Max(value = 20, message = "Kích thước vượt giới hạn! Tối đa chỉ cho phép 20 hàng.")
    private int totalRows;

    @Min(value = 1, message = "Số cột ghế (Columns) phải có ít nhất là 1 cột.")
    @Max(value = 20, message = "Kích thước vượt giới hạn! Tối đa chỉ cho phép 20 cột.")
    private int totalCols;

    @NotBlank(message = "Trạng thái không được để trống")
    @Size(max = 30, message = "Trạng thái quá dài (Tối đa 30 ký tự, ví dụ: Active, Maintenance)")
    private String status;

    @NotBlank(message = "Loại phòng chiếu không được để trống")
    private String roomType;

    @PositiveOrZero(message = "Tiền phòng (phụ thu) không được là số âm")
    private double roomPrice;

    private List<Seat> seats;

    @AssertTrue(message = "Lỗi bảo mật: Kích thước phòng không thực tế, nguy cơ gây tràn bộ nhớ (Memory Leak)!")
    public boolean isCapacityRealistic() {
        return (this.totalRows > 0 && this.totalCols > 0) && (this.totalRows * this.totalCols) <= 900;
    }

    @AssertTrue(message = "Lỗi logic: Loại phòng chiếu không hợp lệ! (Chỉ chấp nhận: Standard, IMAX, 4DX, Sweetbox, VIP)")
    public boolean isRoomTypeValid() {
        if (this.roomType != null) {
            List<String> validTypes = Arrays.asList("Standard", "IMAX", "4DX", "Sweetbox", "VIP");
            return validTypes.contains(this.roomType);
        }
        return true;
    }

    public Room() {
        this.id_Room = 0;
        this.roomName = "";
        this.totalRows = 10;
        this.totalCols = 10;
        this.status = "Active";
        this.roomType = "Standard";
        this.roomPrice = 0.0;
        this.seats = null;
    }

    public Room(int id_Room, String roomName, int totalRows, int totalCols, String status, String roomType, double roomPrice) {
        this.id_Room = id_Room;
        this.roomName = roomName;
        this.totalRows = totalRows;
        this.totalCols = totalCols;
        this.status = status;
        this.roomType = roomType;
        this.roomPrice = roomPrice;
        this.seats = null;
    }

    public Room(int id_Room, String roomName, int totalRows, int totalCols, String status, String roomType, double roomPrice, List<Seat> seats) {
        this.id_Room = id_Room;
        this.roomName = roomName;
        this.totalRows = totalRows;
        this.totalCols = totalCols;
        this.status = status;
        this.roomType = roomType;
        this.roomPrice = roomPrice;
        this.seats = seats;
    }

    public int getId_Room() { return id_Room; }
    public void setId_Room(int id_Room) { this.id_Room = id_Room; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public int getTotalRows() { return totalRows; }
    public void setTotalRows(int totalRows) { this.totalRows = totalRows; }

    public int getTotalCols() { return totalCols; }
    public void setTotalCols(int totalCols) { this.totalCols = totalCols; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public double getRoomPrice() { return roomPrice; }
    public void setRoomPrice(double roomPrice) { this.roomPrice = roomPrice; }

    public List<Seat> getSeats() { return seats; }
    public void setSeats(List<Seat> seats) { this.seats = seats; }

    public void printRoomLayout() {
        System.out.println("====== SƠ ĐỒ PHÒNG CHIẾU: " + this.roomName.toUpperCase() + " ======");
        System.out.println("Loại phòng: " + this.roomType + " | Phụ thu: " + this.roomPrice + " VNĐ");
        System.out.println("Sức chứa lý thuyết: " + this.totalRows + " hàng x " + this.totalCols + " cột = " + (this.totalRows * this.totalCols) + " ghế.");
        System.out.println("-------------------------------------------------");
        
        if (this.seats == null || this.seats.isEmpty()) {
            System.out.println("[THÔNG BÁO] Phòng chiếu này chưa được nạp danh sách ghế từ Database!");
            return;
        }

        System.out.println("                  [ MÀN HÌNH ]                   \n");

        int currentRow = 1;
        for (Seat seat : this.seats) {
            if (seat.getRowPos() > currentRow) {
                System.out.println(); 
                currentRow = seat.getRowPos();
            }

            String symbol;
            if ("Sold".equalsIgnoreCase(seat.getStatus())) {
                symbol = "[ XX ]"; 
            } else if ("Broken".equalsIgnoreCase(seat.getStatus()) || "Maintenance".equalsIgnoreCase(seat.getStatus())) {
                symbol = "[ !! ]"; 
            } else {
                symbol = String.format("[%4s]", seat.getSeatName());
            }
            System.out.print(symbol + " ");
        }
        System.out.println("\n\nChú thích: [ A1 ] - Trống | [ XX ] - Đã đặt | [ !! ] - Đang bảo trì");
    }
}