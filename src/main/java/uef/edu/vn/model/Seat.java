package uef.edu.vn.model;

import jakarta.validation.constraints.*;
import java.util.Arrays;
import java.util.List;

public class Seat {

    @Min(value = 0, message = "ID ghế không được là số âm")
    private int id_Seat;

    @NotBlank(message = "Tên ghế không được để trống")
    @Size(min = 2, max = 10, message = "Tên ghế phải từ 2 đến 10 ký tự (Ví dụ: A1, B12)")
    @Pattern(regexp = "^[A-Z][0-9]{1,2}$", message = "Tên ghế không hợp lệ (Phải bắt đầu bằng 1 chữ in hoa và theo sau là 1 hoặc 2 chữ số. Ví dụ: A1, C12, Z99)")
    private String seatName;

    @Min(value = 1, message = "Vị trí hàng (Row) phải lớn hơn hoặc bằng 1.")
    @Max(value = 20, message = "Vị trí hàng vượt quá giới hạn tối đa của phòng chiếu (Tối đa 20).")
    private int rowPos;

    @Min(value = 1, message = "Vị trí cột (Column) phải lớn hơn hoặc bằng 1.")
    @Max(value = 20, message = "Vị trí cột vượt quá giới hạn tối đa của phòng chiếu (Tối đa 20).")
    private int colPos;

    @NotBlank(message = "Trạng thái ghế không được để trống")
    @Size(max = 20, message = "Trạng thái quá dài (Tối đa 20 ký tự)")
    private String status;

    @Min(value = 1, message = "ID phòng chiếu (roomId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int roomId;

    @AssertTrue(message = "Lỗi logic: Trạng thái ghế không hợp lệ! (Chỉ chấp nhận: Available, Booked, Maintenance, Reserved)")
    public boolean isStatusValid() {
        if (this.status != null) {
            List<String> allowedStatuses = Arrays.asList("Available", "Booked", "Maintenance", "Reserved");
            return allowedStatuses.contains(this.status);
        }
        return true;
    }

    public Seat() {
        this.id_Seat = 0;
        this.seatName = "";
        this.rowPos = 1;
        this.colPos = 1;
        this.status = "Available";
        this.roomId = 0;
    }

    public Seat(int id_Seat, String seatName, int rowPos, int colPos, String status, int roomId) {
        this.id_Seat = id_Seat;
        this.seatName = seatName;
        this.rowPos = rowPos;
        this.colPos = colPos;
        this.status = status;
        this.roomId = roomId;
    }

    public int getId_Seat() { return id_Seat; }
    public void setId_Seat(int id_Seat) { this.id_Seat = id_Seat; }

    public String getSeatName() { return seatName; }
    public void setSeatName(String seatName) { this.seatName = seatName; }

    public int getRowPos() { return rowPos; }
    public void setRowPos(int rowPos) { this.rowPos = rowPos; }

    public int getColPos() { return colPos; }
    public void setColPos(int colPos) { this.colPos = colPos; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
}