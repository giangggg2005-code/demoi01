package uef.edu.vn.service;

import java.util.List;
import java.util.Map;

public interface ReportService {
    
    Map<String, Object> getDashboardSummary();
    
    List<Map<String, Object>> getRevenueAndTicketsByDay(String startDate, String endDate);
    List<Map<String, Object>> getRevenueAndTicketsByMonth(int year);
    
    List<Map<String, Object>> getSalesByTimeOfDay(String startDate, String endDate);

    List<Map<String, Object>> getRevenueByMovie(String startDate, String endDate);
    List<Map<String, Object>> getMovieRevenueGrowth(int movieId, String startDate, String endDate);
    List<Map<String, Object>> getTopSellingMovies(int limit, String startDate, String endDate);

    List<Map<String, Object>> getRevenueByScreeningRoom(String startDate, String endDate);

    List<Map<String, Object>> getTopCustomers(int limit);
    List<Map<String, Object>> getBookingStatusRatio(String startDate, String endDate);
    
    Map<String, Object> getDashboardSummaryCurrentYear(int year);
    List<Double> getMonthlyRevenueForYear(int year);
    List<Map<String, Object>> getTopSellingMoviesDashboard(int limit, int year);
    List<Map<String, Object>> getUpcomingMoviesDashboard(int limit);
    List<Map<String, Object>> getNewEmployeesDashboard(int limit);
    List<Map<String, Object>> getNewCustomersDashboard(int limit);

    List<Map<String, Object>> getTodayShowtimesDashboard(int limit);
    List<Map<String, Object>> getRecentTransactionsDashboard(int limit);

    Map<String, Object> getDashboardData(int year);
    Map<String, Object> getDashboardKPIs(String startDate, String endDate, Integer movieId, String roomType);
    
    // Thống kê phân rã chi tiết cơ cấu doanh thu theo từng bộ phim
    List<Map<String, Object>> getMovieRevenueStatistics(String startDate, String endDate, Integer movieId, String roomType);
    
    // Thống kê phân rã doanh thu cùng với biên phụ thu theo loại phòng chiếu
    List<Map<String, Object>> getRoomTypeRevenueStatistics(String startDate, String endDate, Integer movieId, String roomType);
    
    // Lấy chuỗi dữ liệu theo thời gian thực để đưa vào Chart biểu diễn đồ thị hình học
    List<Map<String, Object>> getRevenueTrendData(String startDate, String endDate, Integer movieId, String roomType, String groupByOption);
    
    // Đọc danh sách giao dịch chi tiết phục vụ hiển thị Data Table phân trang, sắp xếp động
    List<Map<String, Object>> getPaginatedTransactions(String startDate, String endDate, Integer movieId, String roomType, int page, int size, String sortBy, String sortDir);
    // BỔ SUNG MỚI: Lấy Top Khách Hàng có áp dụng bộ lọc báo cáo
    List<Map<String, Object>> getTopCustomersByFilters(String startDate, String endDate, Integer movieId, String roomType, int limit);
    // Đếm tổng số lượng giao dịch tương ứng bộ lọc hiện thời
    int getTotalTransactionCount(String startDate, String endDate, Integer movieId, String roomType);
    List<Map<String, Object>> getMovieDailyRevenue(Integer movieId, String startDate, String endDate);
   // 8. Thống kê hiệu suất suất chiếu (Đã nâng cấp bộ lọc Part 3)
    List<Map<String, Object>> getShowtimePerformance(
            String startDate, String endDate, Integer movieId, String roomType,
            String keyword, Double minRev, Double maxRev, Integer specificRoomId, 
            String sortBy, String sortDir);
}