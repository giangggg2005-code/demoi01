package uef.edu.vn.service;

import java.sql.Date;
import java.util.List;
import uef.edu.vn.model.Room;
import uef.edu.vn.model.Showtime;

public interface ShowtimeService {

    // Hàm cũ (giữ nguyên cho quản lý phòng chiếu nếu có dùng)
    List<Showtime> getAllShowtimes();

    // HÀM MỚI BỔ SUNG: Dành riêng cho giao diện Quản lý suất chiếu (load kèm ảnh)
    List<Showtime> getAlllShowtimes();

    Showtime getShowtimeById(int id);

    List<Showtime> getSchedulesByMovie(int movieId);

    List<Showtime> getUpcomingShowtimesByMovie(int movieId);

    List<Showtime> getShowtimesByDate(Date date);

    List<Showtime> getShowtimesByRoom(int roomId);

    boolean addShowtime(Showtime data);

    boolean editShowtime(int id, Showtime data);

    boolean deleteShowtime(int id);

    boolean updateShowtimeStatus(int id, String status);

    boolean validateSchedule(Showtime st);

    boolean validateScheduleForUpdate(int showtimeId, Showtime st);

    List<Showtime> filterShowtimesAdvanced(String title, String status, String roomName, String roomType, String roomStatus, String date, String time);

    Showtime getFullShowtimeDetailsById(int id);
    // Khai báo thêm hàm này trong Interface ShowtimeService của bạn
    // Thêm hàm lấy chi tiết vé
    java.util.Map<String, Object> getTicketAndBookingInfo(int showtimeId, int seatId);
    boolean hasSoldTickets(int showtimeId);
    List<Showtime> getOtherShowtimesDetailsByMovie(int movieId);
}
