package uef.edu.vn.service;

import java.util.List;
import uef.edu.vn.model.User;

public interface CustomerService {
    List<User> getAllCustomers();
    User getCustomerById(int customerId);
    List<User> getCustomersByStatus(String status);
    List<User> searchCustomers(String keyword);
    List<User> getCustomersWithPagination(int limit, int offset);
    List<User> getNewCustomers(int limit);
    List<User> getTopCustomersBySpending(int limit);
    int getTotalCustomerCount();
    boolean updateCustomer(User customer);
    boolean updateCustomerStatus(int customerId, String status);
    boolean lockCustomer(int customerId);
    boolean unlockCustomer(int customerId);
    boolean deleteCustomer(int customerId);
    boolean addCustomer(User customer);
    // Đổi String dateFilterType thành List<String>
    List<User> filterCustomersAdvanced(String nameKeyword, String contactKeyword, String status, Double minSpent, Double maxSpent, 
                                       String sortSpent, String startDate, String endDate, List<String> dateFilterType);
    boolean resetPassword(int customerId);
    boolean updateCustomerFullInfo(User customer);
    List<java.util.Map<String, Object>> getCustomerBookingHistory(int customerId);
    // Thêm hàm này vào interface CustomerService
    List<java.util.Map<String, Object>> getRoleDetailsByUserId(int userId);
}