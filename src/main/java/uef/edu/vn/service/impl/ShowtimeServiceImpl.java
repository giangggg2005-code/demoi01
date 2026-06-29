package uef.edu.vn.service.impl;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.ShowtimeException;
import uef.edu.vn.model.Room;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.repository.RoomRepository;
import uef.edu.vn.repository.ShowtimeRepository;
import uef.edu.vn.service.ShowtimeService;

@Service
public class ShowtimeServiceImpl implements ShowtimeService {

    private final ShowtimeRepository showtimeRepo;
    private final uef.edu.vn.repository.TicketRepository ticketRepo;
    @Autowired
    public ShowtimeServiceImpl(ShowtimeRepository showtimeRepo, uef.edu.vn.repository.TicketRepository ticketRepo) {
        this.showtimeRepo = showtimeRepo;
        this.ticketRepo = ticketRepo; // Khởi tạo
    }

    // =========================================================================
    // 1. CÁC NGHIỆP VỤ TRA CỨU
    // =========================================================================

    @Override
    public List<Showtime> getAllShowtimes() {
        return showtimeRepo.findAll();
    }

    @Override
    public Showtime getShowtimeById(int id) {
        if (id <= 0) {
            throw new ShowtimeException("Lỗi: Mã suất chiếu không hợp lệ!");
        }
        Showtime st = showtimeRepo.findById(id);
        if (st == null) {
            throw new ShowtimeException("Lỗi truy xuất: Không tìm thấy suất chiếu mang mã số " + id);
        }
        return st;
    }

    @Override
    public List<Showtime> getSchedulesByMovie(int movieId) {
        if (movieId <= 0) {
            throw new ShowtimeException("Lỗi: Mã phim không hợp lệ!");
        }
        return showtimeRepo.findByMovieId(movieId);
    }

    @Override
    public List<Showtime> getUpcomingShowtimesByMovie(int movieId) {
        if (movieId <= 0) {
            throw new ShowtimeException("Lỗi: Mã phim không hợp lệ!");
        }
        return showtimeRepo.findUpcomingShowtimesByMovie(movieId);
    }

    @Override
    public List<Showtime> getShowtimesByDate(Date date) {
        if (date == null) {
            throw new ShowtimeException("Lỗi: Ngày chiếu để tra cứu không được trống!");
        }
        return showtimeRepo.findByDate(date);
    }

    @Override
    public List<Showtime> getShowtimesByRoom(int roomId) {
        if (roomId <= 0) {
            throw new ShowtimeException("Lỗi: Mã phòng chiếu không hợp lệ!");
        }
        return showtimeRepo.findByRoomId(roomId);
    }

    // =========================================================================
    // 2. CÁC NGHIỆP VỤ THỰC THI (CRUD)
    // =========================================================================

    @Override
    public boolean addShowtime(Showtime data) {
        if (data == null) {
            throw new ShowtimeException("Lỗi dữ liệu: Thông tin suất chiếu rỗng!");
        }
        
        // Chốt chặn nghiệp vụ: Kiểm tra trùng lặp lịch chiếu
        if (!validateSchedule(data)) {
            throw new ShowtimeException("Lỗi nghiệp vụ: Suất chiếu bị trùng lịch với một suất chiếu khác trong cùng phòng!");
        }

        // Đảm bảo trạng thái mặc định
        if (data.getStatus() == null || data.getStatus().trim().isEmpty()) {
            data.setStatus("Active");
        }

        try {
            return showtimeRepo.save(data);
        } catch (DataAccessException e) {
             throw new ShowtimeException("Lỗi hệ thống khi thêm suất chiếu mới: " + e.getMessage());
        }
    }

    // 3.1. Triển khai hàm kiểm tra vé đã bán
    @Override
    public boolean hasSoldTickets(int showtimeId) {
        if (showtimeId <= 0) return false;
        return showtimeRepo.countSoldTicketsByShowtimeId(showtimeId) > 0;
    }

    // 3.2. Cập nhật lại hàm editShowtime gốc của bạn như sau:
   @Override
    public boolean editShowtime(int id, Showtime data) {
        if (id <= 0 || data == null) {
            throw new ShowtimeException("Lỗi: Dữ liệu cập nhật hoặc Mã suất chiếu không hợp lệ!");
        }

        Showtime existing = showtimeRepo.findById(id);
        if (existing == null) {
            throw new ShowtimeException("Lỗi truy xuất: Không tìm thấy suất chiếu cần cập nhật!");
        }

        // =========================================================================
        // [BỔ SUNG MỚI]: Kiểm tra nếu suất chiếu gốc ĐÃ DIỄN RA TRONG QUÁ KHỨ
        // =========================================================================
        Timestamp now = new Timestamp(System.currentTimeMillis());
        Timestamp existingStartTimestamp = convertToTimestamp(existing.getShowDate(), existing.getStartTime());
        
        if (existingStartTimestamp.before(now)) {
            throw new ShowtimeException("Lỗi nghiêm trọng: Suất chiếu này đã diễn ra trong quá khứ! Hệ thống không cho phép chỉnh sửa bất kỳ thông tin nào của suất chiếu quá khứ.");
        }
        // =========================================================================


        // =========================================================================
        // RÀNG BUỘC CŨ: Kiểm tra nếu suất chiếu đã có khách mua vé
        // =========================================================================
        if (showtimeRepo.countSoldTicketsByShowtimeId(id) > 0) {
            boolean isMovieChanged = existing.getMovieId() != data.getMovieId();
            boolean isRoomChanged = existing.getRoomId() != data.getRoomId();
            
            boolean isDateChanged = false;
            if (existing.getShowDate() != null && data.getShowDate() != null) {
                isDateChanged = !existing.getShowDate().toString().equals(data.getShowDate().toString());
            } else if (existing.getShowDate() != data.getShowDate()) {
                isDateChanged = true;
            }

            boolean isTimeChanged = false;
            if (existing.getStartTime() != null && data.getStartTime() != null) {
                String t1 = existing.getStartTime().toString().substring(0, 5);
                String t2 = data.getStartTime().toString().substring(0, 5);
                isTimeChanged = !t1.equals(t2);
            } else if (existing.getStartTime() != data.getStartTime()) {
                isTimeChanged = true;
            }

            if (isMovieChanged || isRoomChanged || isDateChanged || isTimeChanged) {
                throw new ShowtimeException("Lỗi ràng buộc: Suất chiếu này đã có khách hàng mua vé! Bạn không thể thay đổi thông tin Phim, Phòng chiếu hoặc Thời gian chiếu.");
            }
        }
        // =========================================================================

        // Đảm bảo cập nhật đúng ID
        data.setId_Showtime(id);

        // Kiểm tra trùng lịch (bỏ qua chính nó)
        if (!validateScheduleForUpdate(id, data)) {
            throw new ShowtimeException("Lỗi nghiệp vụ: Lịch chiếu mới bị trùng lặp với một suất chiếu khác trong phòng!");
        }

        try {
             return showtimeRepo.update(data);
        } catch (DataAccessException e) {
             throw new ShowtimeException("Lỗi hệ thống khi cập nhật suất chiếu: " + e.getMessage());
        }
    }

    @Override
    public boolean deleteShowtime(int id) {
        if (showtimeRepo.findById(id) == null) {
            throw new ShowtimeException("Lỗi truy xuất: Không thể xóa! Suất chiếu không tồn tại.");
        }
        try {
             return showtimeRepo.deleteById(id);
        } catch (DataAccessException e) {
             throw new ShowtimeException("Lỗi hệ thống khi xóa suất chiếu: " + e.getMessage());
        }
    }

    @Override
    public boolean updateShowtimeStatus(int id, String status) {
        if (status == null || status.trim().isEmpty()) {
            throw new ShowtimeException("Lỗi: Trạng thái mới không hợp lệ!");
        }
        if (showtimeRepo.findById(id) == null) {
            throw new ShowtimeException("Lỗi truy xuất: Không tìm thấy suất chiếu để đổi trạng thái!");
        }
        try {
             return showtimeRepo.updateStatus(id, status.trim());
        } catch (DataAccessException e) {
             throw new ShowtimeException("Lỗi hệ thống khi đổi trạng thái suất chiếu: " + e.getMessage());
        }
    }

    // =========================================================================
    // 3. NGHIỆP VỤ KIỂM TRA ĐIỀU KIỆN (VALIDATION) THEO UML DIAGRAM
    // =========================================================================

    @Override
    public boolean validateSchedule(Showtime st) {
        if (st.getShowDate() == null || st.getStartTime() == null || st.getEndTime() == null) {
            throw new ShowtimeException("Lỗi: Dữ liệu thời gian của suất chiếu bị thiếu!");
        }

        Timestamp startTimestamp = convertToTimestamp(st.getShowDate(), st.getStartTime());
        
        // Trả về TRUE nếu KHÔNG bị trùng (checkOverlap trả về false nghĩa là an toàn)
        return !showtimeRepo.checkOverlap(st.getRoomId(), startTimestamp, st.getEndTime());
    }

    @Override
    public boolean validateScheduleForUpdate(int showtimeId, Showtime st) {
        if (st.getShowDate() == null || st.getStartTime() == null || st.getEndTime() == null) {
            throw new ShowtimeException("Lỗi: Dữ liệu thời gian của suất chiếu bị thiếu!");
        }

        Timestamp startTimestamp = convertToTimestamp(st.getShowDate(), st.getStartTime());
        
        // Trả về TRUE nếu KHÔNG bị trùng lịch với suất chiếu KHÁC
        return !showtimeRepo.checkOverlapForUpdate(showtimeId, st.getRoomId(), startTimestamp, st.getEndTime());
    }

    // =========================================================================
    // HÀM HELPER NỘI BỘ
    // =========================================================================
    
    /**
     * Hàm hỗ trợ: Gộp java.sql.Date và java.sql.Time thành một Timestamp hoàn chỉnh
     * để truy vấn logic Overlap trong Database
     */
    private Timestamp convertToTimestamp(Date date, java.sql.Time time) {
        Calendar dateCal = Calendar.getInstance();
        dateCal.setTime(date);
        
        Calendar timeCal = Calendar.getInstance();
        timeCal.setTime(time);
        
        dateCal.set(Calendar.HOUR_OF_DAY, timeCal.get(Calendar.HOUR_OF_DAY));
        dateCal.set(Calendar.MINUTE, timeCal.get(Calendar.MINUTE));
        dateCal.set(Calendar.SECOND, timeCal.get(Calendar.SECOND));
        dateCal.set(Calendar.MILLISECOND, 0);
        
        return new Timestamp(dateCal.getTimeInMillis());
    }
    @Override
    public List<Showtime> getAlllShowtimes() {
        // Đổi từ showtimeRepo.findAll() sang gọi hàm showtimeRepo.findAlll()
        return showtimeRepo.findAlll(); 
    }
    // ... CÁC HÀM CŨ Ở TRÊN ...

    // =========================================================================
    // HÀM MỚI BỔ SUNG: LỌC KẾT HỢP NÂNG CAO
    // =========================================================================
    @Override
    public List<Showtime> filterShowtimesAdvanced(String title, String status, String roomName, String roomType, String roomStatus, String date, String time) {
        return showtimeRepo.filterShowtimes(title, status, roomName, roomType, roomStatus, date, time);
    }
    @Override
    public Showtime getFullShowtimeDetailsById(int id) {
        if (id <= 0) {
            throw new ShowtimeException("Lỗi: Mã suất chiếu không hợp lệ!");
        }
        // Gọi xuống hàm mới tạo ở Repository
        Showtime st = showtimeRepo.findFullDetailsById(id);
        if (st == null) {
            throw new ShowtimeException("Lỗi truy xuất: Không tìm thấy suất chiếu mang mã số " + id);
        }
        return st;
    }
    @Override
    public List<Showtime> getOtherShowtimesDetailsByMovie(int movieId) {
        if (movieId <= 0) {
            throw new ShowtimeException("Lỗi: Mã phim không hợp lệ!");
        }
        return showtimeRepo.findShowtimeDetailsByMovieId(movieId);
    }
    @Override
    public java.util.Map<String, Object> getTicketAndBookingInfo(int showtimeId, int seatId) {
        return ticketRepo.getTicketAndBookingInfo(showtimeId, seatId);
    }
}
