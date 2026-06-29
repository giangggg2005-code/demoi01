package uef.edu.vn.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.CustomerException;
import uef.edu.vn.model.User;
import uef.edu.vn.repository.CustomerRepository;
import uef.edu.vn.service.CustomerService;

@Service
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepo;

    @Autowired
    public CustomerServiceImpl(CustomerRepository customerRepo) {
        this.customerRepo = customerRepo;
    }

    // =========================================================================
    // 1. CÁC NGHIỆP VỤ TRA CỨU & DANH SÁCH
    // =========================================================================

    @Override
    public List<User> getAllCustomers() {
        return customerRepo.findAll();
    }

    @Override
    public User getCustomerById(int customerId) {
        if (customerId <= 0) {
            throw new CustomerException("Lỗi: ID khách hàng không hợp lệ!");
        }
        User customer = customerRepo.findById(customerId);
        if (customer == null) {
            throw new CustomerException("Lỗi truy xuất: Không tìm thấy khách hàng với mã số: " + customerId);
        }
        return customer;
    }

    @Override
    public List<User> getCustomersByStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            throw new CustomerException("Lỗi: Trạng thái cần lọc không được để trống!");
        }
        return customerRepo.findByStatus(status.trim());
    }

    @Override
    public List<User> searchCustomers(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            throw new CustomerException("Lỗi: Từ khóa tìm kiếm không được để trống!");
        }
        return customerRepo.searchByKeyword(keyword.trim());
    }

    @Override
    public List<User> getCustomersWithPagination(int limit, int offset) {
        if (limit < 0 || offset < 0) {
            throw new CustomerException("Lỗi phân trang: Chỉ số dòng hiển thị hoặc vị trí bắt đầu không được âm!");
        }
        return customerRepo.findWithPagination(limit, offset);
    }

    @Override
    public List<User> getNewCustomers(int limit) {
        if (limit <= 0) {
            throw new CustomerException("Lỗi: Số lượng khách hàng cần lấy phải lớn hơn 0!");
        }
        return customerRepo.findNewCustomers(limit);
    }

    @Override
    public List<User> getTopCustomersBySpending(int limit) {
        if (limit <= 0) {
            throw new CustomerException("Lỗi: Số lượng khách hàng hàng đầu phải lớn hơn 0!");
        }
        return customerRepo.findTopBySpending(limit);
    }

    @Override
    public int getTotalCustomerCount() {
        return customerRepo.countAll();
    }

    // =========================================================================
    // 2. NGHIỆP VỤ CẬP NHẬT TRẠNG THÁI & THÔNG TIN
    // =========================================================================

    @Override
    public boolean updateCustomer(User customer) {
        if (customerRepo.findById(customer.getId_User()) == null) {
            throw new CustomerException("Lỗi truy xuất: Không tìm thấy khách hàng cần cập nhật!");
        }
        validateCustomerData(customer);

        if (customerRepo.isEmailTakenByOther(customer.getEmail().trim(), customer.getId_User())) {
            throw new CustomerException("Lỗi trùng lặp: Email '" + customer.getEmail() + "' đã thuộc về khách hàng khác!");
        }

        try {
            customerRepo.update(customer);
            return true;
        } catch (DataAccessException e) {
            throw new CustomerException("Lỗi hệ thống khi cập nhật thông tin khách hàng: " + e.getMessage());
        }
    }

   @Override
    public boolean updateCustomerStatus(int customerId, String status) {
        if (customerRepo.findById(customerId) == null) {
            throw new CustomerException("Lỗi truy xuất: Không tìm thấy khách hàng để cập nhật trạng thái!");
        }
        if (status == null || status.trim().isEmpty()) {
            throw new CustomerException("Lỗi: Trạng thái mới không hợp lệ!");
        }

        String cleanStatus = status.trim();
        
        // ĐÃ SỬA LỖI: Kiểm tra trực tiếp chuỗi trạng thái thay vì dùng đối tượng rỗng
        // Chỉ cho phép 2 trạng thái là Active và Locked theo đúng ý bạn
        if (!cleanStatus.equals("Active") && !cleanStatus.equals("Locked")) {
            throw new CustomerException("Lỗi logic: Trạng thái khách hàng chỉ được phép là Active hoặc Locked!");
        }

        try {
            customerRepo.updateStatus(customerId, cleanStatus);
            return true;
        } catch (DataAccessException e) {
            throw new CustomerException("Lỗi hệ thống khi đổi trạng thái khách hàng: " + e.getMessage());
        }
    }

    @Override
    public boolean lockCustomer(int customerId) {
        return updateCustomerStatus(customerId, "Locked");
    }

    @Override
    public boolean unlockCustomer(int customerId) {
        return updateCustomerStatus(customerId, "Active");
    }

    // =========================================================================
    // 3. HÀM KIỂM TRA NỘI BỘ (VALIDATION HELPER)
    // =========================================================================

    private void validateCustomerData(User customer) {
        if (customer == null) {
            throw new CustomerException("Lỗi: Dữ liệu khách hàng (Customer) trống rỗng!");
        }
        if (customer.getId_User() <= 0) {
            throw new CustomerException("Lỗi nghiệp vụ: Mã khách hàng không hợp lệ!");
        }
        if (!customer.isStatusValid()) {
            throw new CustomerException("Lỗi logic: Trạng thái khách hàng không hợp lệ!");
        }
        if (customer.getFullName() == null || customer.getFullName().trim().isEmpty()) {
            throw new CustomerException("Lỗi dữ liệu: Họ và tên khách hàng không được để trống!");
        }
        if (customer.getEmail() == null || customer.getEmail().trim().isEmpty()) {
            throw new CustomerException("Lỗi dữ liệu: Email khách hàng không được để trống!");
        }
        // Đã bổ sung validate số điện thoại từ đoạn code cũ của bạn
        if (customer.getPhone() == null || customer.getPhone().trim().isEmpty()) {
            throw new CustomerException("Lỗi dữ liệu: Số điện thoại khách hàng không được để trống!");
        }
    }
    @Override
    public boolean deleteCustomer(int customerId) {
        if (customerId <= 0) throw new CustomerException("ID Khách hàng không hợp lệ!");
        try {
            return customerRepo.deleteCustomer(customerId);
        } catch (DataAccessException e) {
            throw new CustomerException("Lỗi hệ thống: Không thể xóa khách hàng này vì đang có dữ liệu ràng buộc (Hóa đơn, Vé...)!");
        }
    }

    @Override
    public List<User> filterCustomersAdvanced(String nameKeyword, String contactKeyword, String status, Double minSpent, Double maxSpent, 
                                              String sortSpent, String startDate, String endDate, List<String> dateFilterType) {
        return customerRepo.filterCustomersAdvanced(nameKeyword, contactKeyword, status, minSpent, maxSpent, sortSpent, startDate, endDate, dateFilterType);
    }
    // Trong CustomerServiceImpl.java
    @Override
    public boolean resetPassword(int customerId) {
        // Mật khẩu mặc định, trong thực tế nhớ mã hóa Bcrypt nếu hệ thống bạn có dùng
        customerRepo.resetPassword(customerId, "Pass@123"); 
        return true;
    }

    @Override
    public boolean updateCustomerFullInfo(User customer) {
        // 1. Kiểm tra xem khách hàng có tồn tại không
        if (customerRepo.findById(customer.getId_User()) == null) {
            throw new CustomerException("Lỗi truy xuất: Không tìm thấy khách hàng cần cập nhật!");
        }

        // 2. KHÔNG CHO PHÉP TRÙNG EMAIL
        if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) {
            if (customerRepo.isEmailTakenByOther(customer.getEmail().trim(), customer.getId_User())) {
                throw new CustomerException("Lỗi trùng lặp: Email '" + customer.getEmail() + "' đã được sử dụng bởi tài khoản khác!");
            }
        }

        // 3. Thực hiện cập nhật và bắt lỗi an toàn
        try {
            customerRepo.updateCustomerFullInfo(customer);
            return true;
        } catch (DataAccessException e) {
            throw new CustomerException("Lỗi hệ thống khi cập nhật thông tin khách hàng: " + e.getMessage());
        }
    }

    @Override
    public List<java.util.Map<String, Object>> getCustomerBookingHistory(int customerId) {
        return customerRepo.getBookingHistory(customerId);
    }
    // Thêm hàm này vào CustomerServiceImpl
    @Override
    public List<java.util.Map<String, Object>> getRoleDetailsByUserId(int userId) {
        return customerRepo.getRoleDetailsByUserId(userId);
    }
    @Override
    public boolean addCustomer(User customer) {
        // 🛡️ LỚP 3: KIỂM TRA NGHIỆP VỤ (TRÙNG LẶP DỮ LIỆU ĐỘC QUYỀN)
        
        // 1. Kiểm tra trùng Username
        if (customer.getUsername() != null && !customer.getUsername().trim().isEmpty()) {
            if (customerRepo.isUsernameTaken(customer.getUsername().trim())) {
                throw new CustomerException("Tên đăng nhập '" + customer.getUsername() + "' đã tồn tại trong hệ thống! Vui lòng chọn tên khác.");
            }
        }

        // 2. Kiểm tra trùng Email
        if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) {
            if (customerRepo.isEmailTakenByOther(customer.getEmail().trim(), 0)) { // 0 vì là tạo mới
                throw new CustomerException("Địa chỉ Email '" + customer.getEmail() + "' đã được sử dụng bởi một tài khoản khác!");
            }
        }

        // 3. Kiểm tra trùng Số điện thoại (Bổ sung theo ý bạn)
        if (customer.getPhone() != null && !customer.getPhone().trim().isEmpty()) {
            if (customerRepo.isPhoneTakenByOther(customer.getPhone().trim(), 0)) { // 0 vì là tạo mới
                throw new CustomerException("Số điện thoại '" + customer.getPhone() + "' đã được đăng ký! Vui lòng sử dụng số khác.");
            }
        }

        // 🛡️ LỚP 4: TIẾN HÀNH LƯU VÀ BẮT LỖI DATABASE (Safety Net)
        try {
            customerRepo.addCustomer(customer);
            return true;
        } catch (org.springframework.dao.DataAccessException e) {
            throw new CustomerException("Lỗi hệ thống Database khi thêm khách hàng: " + e.getMessage());
        }
    }
}