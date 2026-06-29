package uef.edu.vn.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;

public class Showtime {

    @Min(value = 0, message = "ID suất chiếu không được là số âm")
    private int id_Showtime;

    @NotNull(message = "Ngày chiếu (Show Date) không được để trống")
    private Date showDate;

    @NotNull(message = "Giờ bắt đầu (Start Time) không được để trống")
    private Time startTime;

    @NotNull(message = "Thời gian kết thúc (End Time) không được để trống")
    private Timestamp endTime;

    @NotBlank(message = "Trạng thái suất chiếu không được để trống")
    @Size(max = 30, message = "Trạng thái quá dài (Tối đa 30 ký tự, ví dụ: Active, Cancelled, Ended)")
    private String status;

    @Min(value = 1, message = "Mã phim (movieId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int movieId;

    @Min(value = 1, message = "Mã phòng chiếu (roomId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int roomId;

    @Valid
    private Movie movie;

    @Valid
    private Room room;

    // ==========================================
    // CÁC CONSTRUCTOR
    // ==========================================
    public Showtime() {
        this.id_Showtime = 0;
        this.showDate = new Date(System.currentTimeMillis());
        this.startTime = new Time(System.currentTimeMillis());
        this.endTime = new Timestamp(System.currentTimeMillis());
        this.status = "Active";
        this.movieId = 0;
        this.roomId = 0;
        this.movie = null;
        this.room = null;
    }

    public Showtime(int id_Showtime, Date showDate, Time startTime, Timestamp endTime, String status, int movieId, int roomId, Movie movie, Room room) {
        this.id_Showtime = id_Showtime;
        this.showDate = showDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
        this.movieId = movieId;
        this.roomId = roomId;
        this.movie = movie;
        this.room = room;
    }

    // ==========================================
    // GETTER & SETTER TIÊU CHUẨN
    // ==========================================
    public int getId_Showtime() {
        return id_Showtime;
    }

    public void setId_Showtime(int id_Showtime) {
        this.id_Showtime = id_Showtime;
    }

    public Date getShowDate() {
        return showDate;
    }

    public void setShowDate(Date showDate) {
        this.showDate = showDate;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    // BỔ SUNG QUAN TRỌNG: Setter nhận kiểu String để Spring tự động Map form HTML5 "datetime-local" (ví dụ: 2026-06-17T15:00)
    public void setEndTime(String endTimeString) {
        if (endTimeString != null && !endTimeString.trim().isEmpty()) {
            try {
                String formatted = endTimeString.replace("T", " ");
                if (formatted.length() == 16) {
                    formatted += ":00";
                }
                this.endTime = Timestamp.valueOf(formatted);
            } catch (IllegalArgumentException e) {
                this.endTime = null;
            }
        }
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getMovieId() {
        return movieId;
    }

    public void setMovieId(int movieId) {
        this.movieId = movieId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public Movie getMovie() {
        return movie;
    }

    public void setMovie(Movie movie) {
        this.movie = movie;
        if (movie != null) {
            this.movieId = movie.getId_Movie();
        }
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
        if (room != null) {
            this.roomId = room.getId_Room();
        }
    }

    // ==========================================
    // VALIDATION LOGIC
    // ==========================================
    @AssertTrue(message = "Ngoại lệ dữ liệu: Mã movieId phẳng và ID bên trong đối tượng Movie không trùng khớp với nhau!")
    public boolean isMovieIdValid() {
        if (this.movie != null && this.movie.getId_Movie() > 0) {
            return this.movieId == this.movie.getId_Movie();
        }
        return true;
    }

    @AssertTrue(message = "Ngoại lệ dữ liệu: Mã roomId phẳng và ID bên trong đối tượng Room không trùng khớp với nhau!")
    public boolean isRoomIdValid() {
        if (this.room != null && this.room.getId_Room() > 0) {
            return this.roomId == this.room.getId_Room();
        }
        return true;
    }

    @AssertTrue(message = "Ngoại lệ logic: Thời gian kết thúc (EndTime) phải xảy ra SAU thời gian bắt đầu (StartTime) của suất chiếu!")
    public boolean isTimelineValid() {
        if (this.showDate != null && this.startTime != null && this.endTime != null) {
            Calendar calStart = Calendar.getInstance();
            calStart.setTime(this.showDate);

            Calendar calTime = Calendar.getInstance();
            calTime.setTime(this.startTime);

            calStart.set(Calendar.HOUR_OF_DAY, calTime.get(Calendar.HOUR_OF_DAY));
            calStart.set(Calendar.MINUTE, calTime.get(Calendar.MINUTE));
            calStart.set(Calendar.SECOND, calTime.get(Calendar.SECOND));
            calStart.set(Calendar.MILLISECOND, 0);

            return this.endTime.getTime() > calStart.getTimeInMillis();
        }
        return true;
    }

    @AssertTrue(message = "Ngoại lệ nghiệp vụ: Ngày chiếu của suất chiếu này không thể diễn ra trước Ngày khởi chiếu chính thức của bộ phim!")
    public boolean isShowDateValidWithMovie() {
        if (this.movie != null && this.movie.getReleaseDate() != null && this.showDate != null) {
            return !this.showDate.before(this.movie.getReleaseDate());
        }
        return true;
    }

    // ==========================================
    // DEBUG HỖ TRỢ HIỂN THỊ LOG
    // ==========================================
    @Override
    public String toString() {
        return "Showtime{"
                + "id_Showtime=" + id_Showtime
                + ", showDate=" + showDate
                + ", startTime=" + startTime
                + ", endTime=" + endTime
                + ", status='" + status + '\''
                + ", movieId=" + movieId
                + ", roomId=" + roomId
                + '}';
    }

    public String getDisplayStatus() {
        // Nếu bị hủy/khóa trong DB thì ưu tiên trạng thái đó
        if ("Finished".equalsIgnoreCase(this.status)) {
            return "Đã chiếu";
        }

        // Giả sử endTime là Timestamp
        java.util.Date now = new java.util.Date();
        java.util.Date start = convertToDateTime(this.showDate, this.startTime);
        java.util.Date end = this.endTime; // Assuming endTime is already a Date/Timestamp

        if (now.after(end)) {
            return "Đã chiếu";
        }
        if (now.after(start) && now.before(end)) {
            return "Đang chiếu";
        }
        return "Sắp chiếu";
    }
// Helper: chuyển đổi kết hợp ngày giờ để so sánh

    private java.util.Date convertToDateTime(java.sql.Date d, java.sql.Time t) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(d);
        java.util.Calendar timeCal = java.util.Calendar.getInstance();
        timeCal.setTime(t);
        cal.set(java.util.Calendar.HOUR_OF_DAY, timeCal.get(java.util.Calendar.HOUR_OF_DAY));
        cal.set(java.util.Calendar.MINUTE, timeCal.get(java.util.Calendar.MINUTE));
        return cal.getTime();
    }
}
