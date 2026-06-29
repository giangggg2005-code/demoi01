package uef.edu.vn.controller;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import uef.edu.vn.service.ReportService;
import uef.edu.vn.exception.ReportException;

@Controller
@RequestMapping("/admin")
public class DashbroadController {

    private final ReportService reportService; 

    @Autowired
    public DashbroadController(ReportService reportService) {
        this.reportService = reportService;
    }

    private final String path = "/WEB-INF/views/admin/";
    private final String pathview = "layout/admin-layout/main";

    @GetMapping({"", "/", "/dashboard"})
    public String showDashboard(Model model, @RequestParam(value = "year", required = false) Integer year) {
        int targetYear;
        
        if (year != null && year >= 2000 && year <= 2100) {
            targetYear = year;
        } else {
            targetYear = Calendar.getInstance().get(Calendar.YEAR);
        }
        model.addAttribute("selectedYear", targetYear);
        model.addAttribute("currentYear", Calendar.getInstance().get(Calendar.YEAR));

        try {
            Map<String, Object> dashboardData = reportService.getDashboardData(targetYear);

            if (dashboardData != null) {
                model.addAttribute("summary", dashboardData.getOrDefault("summary", new HashMap<>()));
                model.addAttribute("top3Movies", dashboardData.getOrDefault("top3Movies", new ArrayList<>()));
                model.addAttribute("top10Movies", dashboardData.getOrDefault("top10Movies", new ArrayList<>()));
                model.addAttribute("upcomingMovies", dashboardData.getOrDefault("upcomingMovies", new ArrayList<>()));
                model.addAttribute("monthlyRevenueData", dashboardData.getOrDefault("monthlyRevenueData", new ArrayList<Double>()));
                model.addAttribute("newCustomers", dashboardData.getOrDefault("newCustomers", new ArrayList<>()));
                model.addAttribute("newEmployees", dashboardData.getOrDefault("newEmployees", new ArrayList<>()));
                model.addAttribute("todayShowtimes", dashboardData.getOrDefault("todayShowtimes", new ArrayList<>()));
                model.addAttribute("recentTransactions", dashboardData.getOrDefault("recentTransactions", new ArrayList<>()));
            } else {
                initEmptyDashboardModel(model);
            }
            
        } catch (ReportException re) {
            System.err.println("[ReportException] Lỗi truy xuất báo cáo: " + re.getMessage());
            initEmptyDashboardModel(model);
            model.addAttribute("errorMessage", "Có lỗi xảy ra khi lấy dữ liệu: " + re.getMessage());
            
        } catch (Exception e) {
            System.err.println("[Exception] Lỗi hệ thống không xác định tại DashbroadController: " + e.getMessage());
            e.printStackTrace();
            initEmptyDashboardModel(model);
            model.addAttribute("errorMessage", "Hệ thống đang bảo trì dữ liệu báo cáo, vui lòng thử lại sau!");
        }

        model.addAttribute("body", path + "dashboard.jsp");
        return pathview;
    }

    private void initEmptyDashboardModel(Model model) {
        model.addAttribute("summary", new HashMap<>());
        model.addAttribute("top3Movies", new ArrayList<>());
        model.addAttribute("top10Movies", new ArrayList<>());
        model.addAttribute("upcomingMovies", new ArrayList<>());
        model.addAttribute("monthlyRevenueData", Arrays.asList(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0));
        model.addAttribute("newCustomers", new ArrayList<>());
        model.addAttribute("newEmployees", new ArrayList<>());
        model.addAttribute("todayShowtimes", new ArrayList<>());
        model.addAttribute("recentTransactions", new ArrayList<>());
    }
}