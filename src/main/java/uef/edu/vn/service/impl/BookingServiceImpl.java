package uef.edu.vn.service.impl;

import java.sql.Timestamp;
import java.util.List;

// THÊM THƯ VIỆN CỦA SPRING
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.BookingException;
import uef.edu.vn.model.Booking;
import uef.edu.vn.repository.BookingRepository;
import uef.edu.vn.service.BookingService;

@Service // Đánh dấu lớp này là Service Component để Spring quản lý
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepo;

    // Sử dụng Dependency Injection để tiêm Repository thay vì truyền Connection thủ công
    @Autowired
    public BookingServiceImpl(BookingRepository bookingRepo) {
        this.bookingRepo = bookingRepo;
    }

    // =========================================================================
    // 1. CÁC NGHIỆP VỤ TRA CỨU & DANH SÁCH
    // =========================================================================

    @Override
    public List<Booking> getAllBookings() {
        return bookingRepo.findAll();
    }

    @Override
    public Booking getBookingById(int bookingId) {
        if (bookingId <= 0) {
            throw new BookingException("Lỗi: ID hóa đơn đặt vé không hợp lệ!");
        }
        Booking booking = bookingRepo.findById(bookingId);
        if (booking == null) {
            throw new BookingException("Lỗi truy xuất: Không tìm thấy đơn đặt vé mang mã số: " + bookingId);
        }
        return booking;
    }

    @Override
    public List<Booking> getBookingHistoryByUser(int userId) {
        if (userId <= 0) {
            throw new BookingException("Lỗi: ID người dùng không hợp lệ để tra cứu lịch sử!");
        }
        return bookingRepo.getHistoryByUser(userId);
    }

    @Override
    public List<Booking> getBookingsByStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            throw new BookingException("Lỗi: Trạng thái cần lọc không được để trống!");
        }
        return bookingRepo.findByStatus(status.trim());
    }

    @Override
    public List<Booking> getBookingsWithPagination(int limit, int offset) {
        if (limit < 0 || offset < 0) {
            throw new BookingException("Lỗi phân trang: Chỉ số dòng hiển thị hoặc vị trí bắt đầu không được âm!");
        }
        return bookingRepo.findWithPagination(limit, offset);
    }

    // =========================================================================
    // 2. CÁC NGHIỆP VỤ THỰC THI (CRUD & LOGIC GIAO DỊCH)
    // =========================================================================

    @Override
    public boolean createBooking(Booking booking) {
        validateBookingData(booking);
        
        // Gán trạng thái mặc định nếu bị bỏ trống
        if (booking.getStatus() == null || booking.getStatus().trim().isEmpty()) {
            booking.setStatus("Pending");
        }
        if (booking.getBookingDate() == null) {
            booking.setBookingDate(new Timestamp(System.currentTimeMillis()));
        }

        // Vì Repository đã cấu trúc lại hàm save() thành void, ta chỉ cần gọi và return true
        bookingRepo.save(booking);
        return true; 
    }

    @Override
    public int createBookingAndGetId(Booking booking) {
        validateBookingData(booking);
        
        if (booking.getStatus() == null || booking.getStatus().trim().isEmpty()) {
            booking.setStatus("Pending");
        }
        if (booking.getBookingDate() == null) {
            booking.setBookingDate(new Timestamp(System.currentTimeMillis()));
        }

        int generatedId = bookingRepo.saveAndGetId(booking);
        if (generatedId == -1) {
            throw new BookingException("Lỗi hệ thống: Không thể khởi tạo đơn đặt vé mới trong CSDL!");
        }
        return generatedId;
    }

    @Override
    public boolean updateBooking(Booking booking) {
        if (bookingRepo.findById(booking.getId_Booking()) == null) {
            throw new BookingException("Lỗi truy xuất: Không tìm thấy đơn đặt vé cần cập nhật dữ liệu!");
        }
        validateBookingData(booking);
        
        bookingRepo.update(booking);
        return true;
    }

    @Override
    public boolean deleteBooking(int bookingId) {
        if (bookingRepo.findById(bookingId) == null) {
            throw new BookingException("Lỗi truy xuất: Không thể xóa! Không tìm thấy đơn đặt vé yêu cầu.");
        }
        
        bookingRepo.deleteById(bookingId);
        return true;
    }

    @Override
    public boolean updateBookingStatus(int bookingId, String status) {
        if (bookingRepo.findById(bookingId) == null) {
            throw new BookingException("Lỗi truy xuất: Không tìm thấy đơn đặt vé để thực hiện đổi trạng thái!");
        }
        if (status == null || status.trim().isEmpty()) {
            throw new BookingException("Lỗi: Trạng thái mới của đơn đặt vé không hợp lệ!");
        }
        
        bookingRepo.updateStatus(bookingId, status.trim());
        return true;
    }

    // =========================================================================
    // 3. HÀM KIỂM TRA NỘI BỘ (VALIDATION HELPER)
    // =========================================================================
    
    private void validateBookingData(Booking booking) {
        if (booking == null) {
            throw new BookingException("Lỗi: Dữ liệu đơn đặt vé (Booking) trống rỗng!");
        }
        
        // Kiểm tra an toàn cho khách vãng lai (Cho phép userId = null)
        if (booking.getUserId() != null && booking.getUserId() <= 0) {
            throw new BookingException("Lỗi nghiệp vụ: Mã khách hàng (User ID) không hợp lệ!");
        }
        
        if (booking.getTotalAmount() < 0) {
            throw new BookingException("Lỗi nghiệp vụ: Tổng số tiền thanh toán của hóa đơn không được phép nhỏ hơn 0!");
        }
        if (booking.getPaymentMethod() == null || booking.getPaymentMethod().trim().isEmpty()) {
            throw new BookingException("Lỗi dữ liệu: Vui lòng chọn phương thức thanh toán!");
        }
    }
}