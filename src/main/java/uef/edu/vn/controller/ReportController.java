package uef.edu.vn.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import uef.edu.vn.repository.MovieRepository;
import uef.edu.vn.repository.RoomRepository;
import uef.edu.vn.service.ReportService;

@Controller
@RequestMapping("/admin")
public class ReportController {

    private final ReportService reportService;
    private final MovieRepository movieRepository;
    private final RoomRepository roomRepository;
    private final String path = "/WEB-INF/views/admin/";
    private final String pathview = "layout/admin-layout/main";

    @Autowired
    public ReportController(ReportService reportService, MovieRepository movieRepository, RoomRepository roomRepository) {
        this.reportService = reportService;
        this.movieRepository = movieRepository;
        this.roomRepository = roomRepository;
    }

    @GetMapping("/reports")
    public String showReportPage(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer movieId,
            @RequestParam(required = false) String roomType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "MONTH") String groupByOption,
            @RequestParam(defaultValue = "transactionTime") String sortBy,
            @RequestParam(required = false) String p3Keyword,
            @RequestParam(required = false) Double p3MinRev,
            @RequestParam(required = false) Double p3MaxRev,
            @RequestParam(required = false) Integer p3RoomId,
            @RequestParam(defaultValue = "default") String p3SortBy,
            @RequestParam(defaultValue = "DESC") String p3SortDir,
            @RequestParam(defaultValue = "DESC") String sortDir,
            Model model) {
        
        try {
            // 1. Nạp danh sách phim cho ô bộ lọc
            model.addAttribute("moviesList", movieRepository.getMoviesCurrentlyShowing());
            
            // 2. Đổ dữ liệu tĩnh ban đầu (Cho bảng HTML)
            model.addAttribute("movieRevenueList", reportService.getMovieRevenueStatistics(startDate, endDate, movieId, roomType));
            model.addAttribute("roomRevenueList", reportService.getRoomTypeRevenueStatistics(startDate, endDate, movieId, roomType));
            model.addAttribute("allRoomsList", roomRepository.findAll()); 
            
            // Gọi hàm Part 3 với các tham số mới (Đã dọn dẹp dòng trùng lặp)
            model.addAttribute("showtimeRevenueList", reportService.getShowtimePerformance(
                startDate, endDate, movieId, roomType, p3Keyword, p3MinRev, p3MaxRev, p3RoomId, p3SortBy, p3SortDir));
                
            model.addAttribute("p3Keyword", p3Keyword);
            model.addAttribute("p3MinRev", p3MinRev);
            model.addAttribute("p3MaxRev", p3MaxRev);
            model.addAttribute("p3RoomId", p3RoomId);
            model.addAttribute("p3SortBy", p3SortBy);
            model.addAttribute("p3SortDir", p3SortDir);

            // 3. Phân trang & Sắp xếp cho nhật ký đối soát giao dịch hiển thị trên giao diện
            List<Map<String, Object>> transactions = reportService.getPaginatedTransactions(
                    startDate, endDate, movieId, roomType, page, size, sortBy, sortDir);
            
            int totalRecords = reportService.getTotalTransactionCount(startDate, endDate, movieId, roomType);
            int totalPages = (int) Math.ceil((double) totalRecords / size);
            
            // === LẤY TOÀN BỘ DANH SÁCH GIAO DỊCH ĐỂ XUẤT EXCEL FULL ===
            try {
                List<Map<String, Object>> allTransactions = reportService.getPaginatedTransactions(
                        startDate, endDate, movieId, roomType, 1, totalRecords > 0 ? totalRecords : 1, sortBy, sortDir);
                model.addAttribute("allTransactionsList", allTransactions);
            } catch (Exception ex) {
                System.out.println("Lỗi load full Excel: " + ex.getMessage());
                model.addAttribute("allTransactionsList", transactions); // Dự phòng nếu lỗi
            }
            // =========================================================

            model.addAttribute("transactionsList", transactions);
            model.addAttribute("auditLogs", transactions); 
            model.addAttribute("currentPage", page);
            model.addAttribute("pageSize", size); 
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalRecords", totalRecords);

            // 4. Đổ dữ liệu KPI tổng quan lên đầu trang
            Map<String, Object> kpis = reportService.getDashboardKPIs(startDate, endDate, movieId, roomType);
            model.addAttribute("kpis", kpis);

            // Lấy danh sách Top 10 khách hàng dựa trên bộ lọc
            model.addAttribute("topUsersList", reportService.getTopCustomersByFilters(startDate, endDate, movieId, roomType, 10));

            // 5. Giữ lại các giá trị để Form không bị reset khi load lại trang
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
            model.addAttribute("movieId", movieId);
            model.addAttribute("roomType", roomType);
            model.addAttribute("groupByOption", groupByOption);
            model.addAttribute("sortBy", sortBy); 
            model.addAttribute("sortDir", sortDir); 
            
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Lỗi tải dữ liệu báo cáo: " + e.getMessage());
        }
        
        // Tương thích với cấu trúc layout chính main.jsp
        model.addAttribute("view", "reports");
        model.addAttribute("body", path + "reports.jsp");
        return pathview;
    }

    @GetMapping("/reports/api/kpis-and-charts")
    @ResponseBody
    public Map<String, Object> getKpisAndChartsData(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer movieId,
            @RequestParam(required = false) String roomType,
            @RequestParam(defaultValue = "MONTH") String groupByOption) {

        Map<String, Object> data = new HashMap<>();
        data.put("kpis", reportService.getDashboardKPIs(startDate, endDate, movieId, roomType));
        data.put("trend", reportService.getRevenueTrendData(startDate, endDate, movieId, roomType, groupByOption));
        return data;
    }

    @GetMapping("/reports/api/movie-revenue")
    @ResponseBody
    public List<Map<String, Object>> getMovieRevenueApi(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer movieId,
            @RequestParam(required = false) String roomType) {
        return reportService.getMovieRevenueStatistics(startDate, endDate, movieId, roomType);
    }

    @GetMapping("/reports/api/room-revenue")
    @ResponseBody
    public List<Map<String, Object>> getRoomRevenueApi(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer movieId,
            @RequestParam(required = false) String roomType) {
        return reportService.getRoomTypeRevenueStatistics(startDate, endDate, movieId, roomType);
    }

    @GetMapping("/reports/api/transactions")
    @ResponseBody
    public Map<String, Object> getTransactionsApi(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer movieId,
            @RequestParam(required = false) String roomType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "transactionTime") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDir) {

        Map<String, Object> response = new HashMap<>();
        List<Map<String, Object>> transactions = reportService.getPaginatedTransactions(
                startDate, endDate, movieId, roomType, page, size, sortBy, sortDir);
        int totalRecords = reportService.getTotalTransactionCount(startDate, endDate, movieId, roomType);
        int totalPages = (int) Math.ceil((double) totalRecords / size);

        response.put("data", transactions);
        response.put("currentPage", page);
        response.put("totalPages", totalPages);
        response.put("totalRecords", totalRecords);
        return response;
    }

    @GetMapping("/reports/api/movie-daily")
    @ResponseBody
    public List<Map<String, Object>> getMovieDailyRevenueApi(
            @RequestParam Integer movieId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return reportService.getMovieDailyRevenue(movieId, startDate, endDate);
    }
}