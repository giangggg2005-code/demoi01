package uef.edu.vn.service.impl;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.CompletableFuture;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import uef.edu.vn.exception.ReportException;
import uef.edu.vn.repository.ReportRepository;
import uef.edu.vn.service.ReportService;

@Service
public class ReportServiceImpl implements ReportService {

    private final ReportRepository reportRepository;

    @Autowired
    public ReportServiceImpl(ReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    @Override
    public Map<String, Object> getDashboardSummary() {
        try { return reportRepository.getDashboardSummary(); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi hệ thống khi lấy số liệu tổng quan Dashboard: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getRevenueAndTicketsByDay(String startDate, String endDate) {
        try { return reportRepository.getRevenueAndTicketsByDay(startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy doanh thu từng ngày: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getRevenueAndTicketsByMonth(int year) {
        try { return reportRepository.getRevenueAndTicketsByMonth(year); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy doanh thu từng tháng: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getSalesByTimeOfDay(String startDate, String endDate) {
        try { return reportRepository.getSalesByTimeOfDay(startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy doanh số theo khung giờ: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getRevenueByMovie(String startDate, String endDate) {
        try { return reportRepository.getRevenueByMovie(startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy doanh thu theo phim: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getMovieRevenueGrowth(int movieId, String startDate, String endDate) {
        try { return reportRepository.getMovieRevenueGrowth(movieId, startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi tăng trưởng doanh thu phim: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getTopSellingMovies(int limit, String startDate, String endDate) {
        try { return reportRepository.getTopSellingMovies(limit, startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy top phim bán chạy: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getRevenueByScreeningRoom(String startDate, String endDate) {
        try { return reportRepository.getRevenueByScreeningRoom(startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi doanh thu phòng chiếu: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getTopCustomers(int limit) {
        try { return reportRepository.getTopCustomers(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lấy danh sách khách hàng VIP: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getBookingStatusRatio(String startDate, String endDate) {
        try { return reportRepository.getBookingStatusRatio(startDate, endDate); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi tỷ lệ đặt vé: " + e.getMessage(), e); }
    }

    @Override
    public Map<String, Object> getDashboardSummaryCurrentYear(int year) {
        try { return reportRepository.getDashboardSummaryCurrentYear(year); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi tổng quan năm hiện tại: " + e.getMessage(), e); }
    }

    @Override
    public List<Double> getMonthlyRevenueForYear(int year) {
        try { return reportRepository.getMonthlyRevenueForYear(year); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi biểu đồ doanh thu: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getTopSellingMoviesDashboard(int limit, int year) {
        try { return reportRepository.getTopSellingMoviesDashboard(limit, year); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi Top phim: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getUpcomingMoviesDashboard(int limit) {
        try { return reportRepository.getUpcomingMoviesDashboard(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi phim sắp chiếu: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getNewEmployeesDashboard(int limit) {
        try { return reportRepository.getNewEmployeesDashboard(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi danh sách nhân sự: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getNewCustomersDashboard(int limit) {
        try { return reportRepository.getNewCustomersDashboard(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi danh sách khách hàng mới: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getTodayShowtimesDashboard(int limit) {
        try { return reportRepository.getTodayShowtimesDashboard(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi lịch chiếu hôm nay: " + e.getMessage(), e); }
    }

    @Override
    public List<Map<String, Object>> getRecentTransactionsDashboard(int limit) {
        try { return reportRepository.getRecentTransactionsDashboard(limit); } 
        catch (DataAccessException e) { throw new ReportException("Lỗi danh sách giao dịch mới nhất: " + e.getMessage(), e); }
    }

    @Override
    public Map<String, Object> getDashboardData(int year) {
        Map<String, Object> data = new HashMap<>();
        try {
            CompletableFuture<Map<String, Object>> summaryFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getDashboardSummaryCurrentYear(year));
                
            CompletableFuture<List<Map<String, Object>>> topMoviesFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getTopSellingMoviesDashboard(10, year));
                
            CompletableFuture<List<Map<String, Object>>> upcomingMoviesFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getUpcomingMoviesDashboard(20));
                
            CompletableFuture<List<Double>> monthlyRevenueFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getMonthlyRevenueForYear(year));
                
            CompletableFuture<List<Map<String, Object>>> newCustomersFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getNewCustomersDashboard(12));
                
            CompletableFuture<List<Map<String, Object>>> newEmployeesFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getNewEmployeesDashboard(12));

            CompletableFuture<List<Map<String, Object>>> todayShowtimesFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getTodayShowtimesDashboard(10));

            CompletableFuture<List<Map<String, Object>>> recentTransactionsFuture = CompletableFuture.supplyAsync(() -> 
                reportRepository.getRecentTransactionsDashboard(10));

          
            CompletableFuture.allOf(
                summaryFuture, topMoviesFuture, upcomingMoviesFuture, 
                monthlyRevenueFuture, newCustomersFuture, newEmployeesFuture,
                todayShowtimesFuture, recentTransactionsFuture
            ).join();

            List<Map<String, Object>> topMovies = topMoviesFuture.get();
            List<Map<String, Object>> top3Movies = topMovies.size() > 3 ? topMovies.subList(0, 3) : topMovies;

            data.put("summary", summaryFuture.get());
            data.put("top3Movies", top3Movies);
            data.put("top10Movies", topMovies);
            data.put("upcomingMovies", upcomingMoviesFuture.get());
            data.put("monthlyRevenueData", monthlyRevenueFuture.get());
            data.put("newCustomers", newCustomersFuture.get());
            data.put("newEmployees", newEmployeesFuture.get());
            data.put("todayShowtimes", todayShowtimesFuture.get());      
            data.put("recentTransactions", recentTransactionsFuture.get()); 

        } catch (Exception e) {
            throw new ReportException("Lỗi xử lý đa luồng dữ liệu tại tầng Service: " + e.getMessage(), e);
        }
        return data;
    }
 @Override
    public Map<String, Object> getDashboardKPIs(String startDate, String endDate, Integer movieId, String roomType) {
        validateDates(startDate, endDate);
        return reportRepository.getAdvancedKPIs(startDate, endDate, movieId, roomType);
    }

    @Override
    public List<Map<String, Object>> getMovieRevenueStatistics(String startDate, String endDate, Integer movieId, String roomType) {
        validateDates(startDate, endDate);
        return reportRepository.getRevenueByMovieDetailed(startDate, endDate, movieId, roomType);
    }

    @Override
    public List<Map<String, Object>> getRoomTypeRevenueStatistics(String startDate, String endDate, Integer movieId, String roomType) {
        validateDates(startDate, endDate);
        return reportRepository.getRevenueByRoomTypeDetailed(startDate, endDate, movieId, roomType);
    }

    @Override
    public List<Map<String, Object>> getRevenueTrendData(String startDate, String endDate, Integer movieId, String roomType, String groupByOption) {
        validateDates(startDate, endDate);
        if (groupByOption == null || groupByOption.trim().isEmpty()) {
            groupByOption = "DAY";
        }
        return reportRepository.getRevenueTrend(startDate, endDate, movieId, roomType, groupByOption);
    }

    @Override
    public List<Map<String, Object>> getPaginatedTransactions(String startDate, String endDate, Integer movieId, String roomType, int page, int size, String sortBy, String sortDir) {
        validateDates(startDate, endDate);

        if (page < 1) page = 1;
        if (size < 1) size = 10;
        if (size > 100) size = 100; 

        int offset = (page - 1) * size;
        String safeSortBy = (sortBy != null && !sortBy.trim().isEmpty()) ? sortBy.trim() : "bookingDate";
        String safeSortDir = ("ASC".equalsIgnoreCase(sortDir)) ? "ASC" : "DESC";

        return reportRepository.getDetailedTransactions(startDate, endDate, movieId, roomType, size, offset, safeSortBy, safeSortDir);
    }

    @Override
    public int getTotalTransactionCount(String startDate, String endDate, Integer movieId, String roomType) {
        validateDates(startDate, endDate);
        return reportRepository.getTransactionCount(startDate, endDate, movieId, roomType);
    }

    private void validateDates(String startDate, String endDate) {
        if (startDate != null && endDate != null && !startDate.trim().isEmpty() && !endDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                LocalDate end = LocalDate.parse(endDate.trim());
                if (start.isAfter(end)) {
                    throw new IllegalArgumentException("Ngày bắt đầu không được lớn hơn ngày kết thúc!");
                }
            } catch (Exception e) {
                throw new IllegalArgumentException("Định dạng ngày tháng không hợp lệ (Chuẩn phải là YYYY-MM-DD)");
            }
        }
    }
    // BỔ SUNG MỚI: Triển khai phương thức lấy Top Users theo bộ lọc
    @Override
    public List<Map<String, Object>> getTopCustomersByFilters(String startDate, String endDate, Integer movieId, String roomType, int limit) {
        validateDates(startDate, endDate);
        return reportRepository.getTopCustomersByFilters(startDate, endDate, movieId, roomType, limit);
    }

    @Override
    public List<Map<String, Object>> getMovieDailyRevenue(Integer movieId, String startDate, String endDate) {
        // Gọi thẳng sang Repository mà bạn vừa viết ban nãy
        return reportRepository.getMovieDailyRevenue(movieId, startDate, endDate);
    }
    @Override
    public List<Map<String, Object>> getShowtimePerformance(
            String startDate, String endDate, Integer movieId, String roomType,
            String keyword, Double minRev, Double maxRev, Integer specificRoomId, 
            String sortBy, String sortDir) {
        
        // Bắt lỗi ngoại lệ cho bộ lọc doanh thu
        if (minRev != null && minRev < 0) {
            throw new IllegalArgumentException("Doanh thu tối thiểu không được là số âm.");
        }
        if (maxRev != null && maxRev < 0) {
            throw new IllegalArgumentException("Doanh thu tối đa không được là số âm.");
        }
        if (minRev != null && maxRev != null && minRev > maxRev) {
            throw new IllegalArgumentException("Doanh thu tối thiểu không thể lớn hơn doanh thu tối đa.");
        }

        validateDates(startDate, endDate);
        return reportRepository.getShowtimePerformance(startDate, endDate, movieId, roomType, keyword, minRev, maxRev, specificRoomId, sortBy, sortDir);
    }
}