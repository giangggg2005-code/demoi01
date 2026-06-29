package uef.edu.vn.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import uef.edu.vn.model.Room;

import uef.edu.vn.model.Showtime;
import uef.edu.vn.service.ShowtimeService;
import uef.edu.vn.service.MovieService;
import uef.edu.vn.service.RoomService;

@Controller
@RequestMapping("/admin")
public class ShowtimeController {

    // BIẾN ĐƯỜNG DẪN PATH
    private final String path = "/WEB-INF/views/admin/";

    @Autowired
    private ShowtimeService showtimeService;

    @Autowired
    private MovieService movieService;

    @Autowired
    private RoomService roomService;

    // Sửa lỗi mapping ngày giờ từ Form HTML5 truyền lên
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(java.sql.Date.class, new java.beans.PropertyEditorSupport() {
            @Override
            public void setAsText(String text) {
                setValue((text == null || text.trim().isEmpty()) ? null : java.sql.Date.valueOf(text));
            }
        });

        binder.registerCustomEditor(java.sql.Time.class, new java.beans.PropertyEditorSupport() {
            @Override
            public void setAsText(String text) {
                if (text != null && !text.trim().isEmpty()) {
                    if (text.length() == 5) {
                        text += ":00"; // Định dạng HH:mm:ss
                    }
                    setValue(java.sql.Time.valueOf(text));
                } else {
                    setValue(null);
                }
            }
        });

        binder.registerCustomEditor(java.sql.Timestamp.class, new java.beans.PropertyEditorSupport() {
            @Override
            public void setAsText(String text) {
                if (text != null && !text.trim().isEmpty()) {
                    text = text.replace("T", " ");
                    if (text.length() == 16) {
                        text += ":00";
                    }
                    setValue(java.sql.Timestamp.valueOf(text));
                } else {
                    setValue(null);
                }
            }
        });
    }

    // 1. Giao diện Danh sách Suất Chiếu
    @GetMapping("/showtimes")
    public String listShowtimes(Model model) {

        // ĐÃ SỬA: Gọi đúng hàm getAlllShowtimes() mới được tạo
        model.addAttribute("showtimes", showtimeService.getAlllShowtimes());

        // Load danh sách phim và phòng từ cơ sở dữ liệu để phục vụ hiển thị & cấu trúc bộ lọc liên kết
        model.addAttribute("movies", movieService.searchAndFilterMovies("", "all", "all"));
        model.addAttribute("rooms", roomService.getAllRooms());

        // Truyền tên View và Body để main.jsp hiển thị
        model.addAttribute("view", "showtimes");
        model.addAttribute("body", path + "showtimes.jsp");

        return "layout/admin-layout/main";
    }

    // 2. Giao diện Xem Chi Tiết Suất Chiếu (Dành cho nút Icon Con Mắt)
    @GetMapping("/showtimes/detail/{id}")
    public String viewShowtimeDetail(@PathVariable("id") int id, Model model) {
        Showtime showtime = showtimeService.getShowtimeById(id);
        model.addAttribute("showtime", showtime);

        model.addAttribute("view", "showtimes");
        model.addAttribute("body", path + "showtime_detail.jsp");

        return "layout/admin-layout/main";
    }
    // --- BỔ SUNG: CHUYỂN HƯỚNG SANG TRANG THÊM MỚI ---
    // =========================================================================
    // ĐIỀU HƯỚNG SANG GIAO DIỆN THÊM MỚI HOẶC CHỈNH SỬA SUẤT CHIẾU FULL TRANG
    // =========================================================================

    @GetMapping("/showtimes/add")
    public String addShowtimePage(Model model) {
        model.addAttribute("showtime", new Showtime()); // Gửi một đối tượng rỗng

        // Load danh sách phim và phòng để đưa vào thẻ <select>
        model.addAttribute("movies", movieService.searchAndFilterMovies("", "all", "all"));
        model.addAttribute("rooms", roomService.getAllRooms());

        model.addAttribute("view", "showtimes");
        model.addAttribute("body", path + "showtime_add_edit.jsp");

        return "layout/admin-layout/main";
    }

    @GetMapping("/showtimes/edit/{id}")
    public String editShowtimePage(@PathVariable("id") int id, Model model, RedirectAttributes redirectAttributes) {
        try {
            // 1. Lấy thông tin FULL FULL của suất chiếu
            Showtime showtime = showtimeService.getFullShowtimeDetailsById(id);
            model.addAttribute("showtime", showtime);

            // =========================================================================
            // [BỔ SUNG MỚI]: Kiểm tra xem suất chiếu này có thuộc về quá khứ hay không
            // =========================================================================
            java.util.Calendar calNow = java.util.Calendar.getInstance();
            java.util.Calendar calShowtime = java.util.Calendar.getInstance();
            calShowtime.setTime(showtime.getShowDate());

            java.util.Calendar calTime = java.util.Calendar.getInstance();
            calTime.setTime(showtime.getStartTime());

            calShowtime.set(java.util.Calendar.HOUR_OF_DAY, calTime.get(java.util.Calendar.HOUR_OF_DAY));
            calShowtime.set(java.util.Calendar.MINUTE, calTime.get(java.util.Calendar.MINUTE));
            calShowtime.set(java.util.Calendar.SECOND, calTime.get(java.util.Calendar.SECOND));
            calShowtime.set(java.util.Calendar.MILLISECOND, 0);

            boolean isPastShowtime = calShowtime.before(calNow);
            model.addAttribute("isPastShowtime", isPastShowtime);

            // Kiểm tra vé đã bán (giữ nguyên từ phần trước)
            boolean hasSoldTickets = showtimeService.hasSoldTickets(id);
            model.addAttribute("hasSoldTickets", hasSoldTickets);
            // =========================================================================

            // 2. Load danh sách phim và phòng
            model.addAttribute("movies", movieService.searchAndFilterMovies("", "all", "all"));
            model.addAttribute("rooms", roomService.getAllRooms());

            // 3. LẤY SƠ ĐỒ GHẾ & TRẠNG THÁI VÉ CỦA PHÒNG
            Room roomDetail = roomService.findRoomWithSeatStatusByShowtimeId(id);
            model.addAttribute("roomDetail", roomDetail);

            // 4. Lấy danh sách các suất chiếu khác của bộ phim này (FULL Chi tiết)
            List<Showtime> otherShowtimes = showtimeService.getOtherShowtimesDetailsByMovie(showtime.getMovieId());
            model.addAttribute("otherShowtimes", otherShowtimes);
            model.addAttribute("view", "showtimes");
            model.addAttribute("body", path + "showtime_add_edit.jsp");
            return "layout/admin-layout/main";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("systemErrorMsg", "Lỗi tải trang chỉnh sửa: " + e.getMessage());
            return "redirect:/admin/showtimes";
        }
    }

    // 3. Lưu / Cập nhật Suất chiếu
    @PostMapping("/showtimes/save")
    public String saveShowtime(@ModelAttribute Showtime showtime, RedirectAttributes redirectAttributes) {
        try {
            if (showtime.getId_Showtime() > 0) {
                showtimeService.editShowtime(showtime.getId_Showtime(), showtime);
                redirectAttributes.addFlashAttribute("successMsg", "Cập nhật suất chiếu thành công!");
            } else {
                showtimeService.addShowtime(showtime);
                redirectAttributes.addFlashAttribute("successMsg", "Thêm suất chiếu mới thành công!");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("systemErrorMsg", e.getMessage());
        }
        return "redirect:/admin/showtimes";
    }

    // 4. Xóa Suất chiếu
  // 4. Xóa Suất chiếu
    @GetMapping("/showtimes/delete/{id}")
    public String deleteShowtime(@PathVariable("id") int id, RedirectAttributes redirectAttributes) {
        try {
            // 1. Lấy chi tiết thông tin suất chiếu để kiểm tra
            Showtime showtime = showtimeService.getFullShowtimeDetailsById(id);

            // 2. Ràng buộc 1: Kiểm tra xem suất chiếu này có thuộc về quá khứ hay không
            java.util.Calendar calNow = java.util.Calendar.getInstance();
            java.util.Calendar calShowtime = java.util.Calendar.getInstance();
            calShowtime.setTime(showtime.getShowDate());

            java.util.Calendar calTime = java.util.Calendar.getInstance();
            calTime.setTime(showtime.getStartTime());

            calShowtime.set(java.util.Calendar.HOUR_OF_DAY, calTime.get(java.util.Calendar.HOUR_OF_DAY));
            calShowtime.set(java.util.Calendar.MINUTE, calTime.get(java.util.Calendar.MINUTE));
            calShowtime.set(java.util.Calendar.SECOND, calTime.get(java.util.Calendar.SECOND));
            calShowtime.set(java.util.Calendar.MILLISECOND, 0);

            boolean isPastShowtime = calShowtime.before(calNow);
            if (isPastShowtime) {
                // Báo lỗi bằng khung cảnh báo đỏ
                redirectAttributes.addFlashAttribute("systemErrorMsg", "Từ chối xóa: Không thể xóa suất chiếu đã diễn ra trong quá khứ!");
                return "redirect:/admin/showtimes";
            }

            // 3. Ràng buộc 2: Kiểm tra xem suất chiếu đã có khách mua vé chưa
            boolean hasSoldTickets = showtimeService.hasSoldTickets(id);
            if (hasSoldTickets) {
                // Báo lỗi bằng khung cảnh báo đỏ
                redirectAttributes.addFlashAttribute("systemErrorMsg", "Từ chối xóa: Không thể xóa suất chiếu vì đã có khách hàng mua vé!");
                return "redirect:/admin/showtimes";
            }

            // Nếu vượt qua cả 2 ràng buộc an toàn -> Tiến hành xóa
            showtimeService.deleteShowtime(id);
            redirectAttributes.addFlashAttribute("successMsg", "Đã xóa suất chiếu thành công!");
            
        } catch (Exception e) {
            // Bắt và hiển thị các lỗi hệ thống nếu có
            redirectAttributes.addFlashAttribute("systemErrorMsg", "Lỗi khi xóa suất chiếu: " + e.getMessage());
        }
        return "redirect:/admin/showtimes";
    }
    // ... CÁC GETMAPPING VÀ POSTMAPPING CŨ Ở TRÊN ...

    // 5. Giao diện Lọc Suất Chiếu Nâng Cao
    @GetMapping("/showtimes/filter")
    public String filterShowtimesAdvanced(
            @RequestParam(value = "title", required = false) String title,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "roomName", required = false) String roomName,
            @RequestParam(value = "roomType", required = false) String roomType,
            @RequestParam(value = "roomStatus", required = false) String roomStatus,
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "time", required = false) String time,
            Model model) {

        // Gọi hàm lọc từ Service
        List<Showtime> filteredList = showtimeService.filterShowtimesAdvanced(title, status, roomName, roomType, roomStatus, date, time);
        model.addAttribute("showtimes", filteredList);

        // Giữ lại các bộ data để render dropdown
        model.addAttribute("movies", movieService.searchAndFilterMovies("", "all", "all"));
        model.addAttribute("rooms", roomService.getAllRooms());

        // Truyền lại các giá trị đã lọc để giữ trạng thái trên ô input của JSP
        model.addAttribute("selectedTitle", title);
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedRoomName", roomName);
        model.addAttribute("selectedRoomType", roomType);
        model.addAttribute("selectedRoomStatus", roomStatus);
        model.addAttribute("selectedDate", date);
        model.addAttribute("selectedTime", time);

        model.addAttribute("view", "showtimes");
        model.addAttribute("body", path + "showtimes.jsp");
        
        return "layout/admin-layout/main";
    }
    // =========================================================================
    // API BỔ SUNG: Cung cấp dữ liệu JSON cho AJAX khi ấn vào ghế đã bán
    // =========================================================================
    // =========================================================================
    // API BỔ SUNG: Cung cấp dữ liệu JSON cho AJAX (Xây dựng JSON thủ công an toàn 100%)
    // =========================================================================
    @GetMapping(value = "/showtimes/api/ticket-info", produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String getTicketInfoAPI(
            @RequestParam("showtimeId") int showtimeId, 
            @RequestParam("seatId") int seatId) {
        
        java.util.Map<String, Object> data = showtimeService.getTicketAndBookingInfo(showtimeId, seatId);
        if (data == null) {
            return "{\"error\": \"Không tìm thấy dữ liệu vé!\"}";
        }
        
        // Tạo JSON thủ công để đảm bảo 100% không bị lỗi do thiếu thư viện Jackson
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        // Lấy các giá trị an toàn
        Object idTicket = data.get("id_Ticket");
        Object ticketPrice = data.get("ticketPrice");
        Object idBooking = data.get("id_Booking");
        Object idUser = data.get("id_User");
        
        json.append("\"id_Ticket\":").append(idTicket != null ? idTicket : "null").append(",");
        json.append("\"ticketPrice\":").append(ticketPrice != null ? ticketPrice : "0").append(",");
        json.append("\"id_Booking\":").append(idBooking != null ? idBooking : "null").append(",");
        
        // Render chuỗi văn bản (Xử lý NullPointerException)
        json.append("\"bookingDate\":\"").append(data.get("bookingDate") != null ? data.get("bookingDate").toString() : "").append("\",");
        json.append("\"paymentMethod\":\"").append(data.get("paymentMethod") != null ? data.get("paymentMethod").toString() : "Tiền mặt").append("\",");
        json.append("\"fullName\":\"").append(data.get("fullName") != null ? data.get("fullName").toString() : "Khách vãng lai (Tại quầy)").append("\",");
        json.append("\"phone\":\"").append(data.get("phone") != null ? data.get("phone").toString() : "Không có").append("\",");
        json.append("\"email\":\"").append(data.get("email") != null ? data.get("email").toString() : "Không có").append("\",");
        
        json.append("\"id_User\":").append(idUser != null ? idUser : "null");
        
        json.append("}");
        
        return json.toString();
    }
}
