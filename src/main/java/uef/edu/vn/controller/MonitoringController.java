package uef.edu.vn.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import uef.edu.vn.service.MonitoringService;

@Controller
@RequestMapping("/admin")
public class MonitoringController {

    private final MonitoringService monitoringService;
    
    private final String path = "/WEB-INF/views/admin/";
    private final String pathview = "layout/admin-layout/main";

    // Regular Expression: Chỉ cho phép chữ cái Tiếng Việt có dấu và khoảng trắng, KHÔNG cho số hay ký tự đặc biệt
    private final Pattern NAME_PATTERN = Pattern.compile("^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲÝỴÝỳýỵỷỹ\\s]+$");

    @Autowired
    public MonitoringController(MonitoringService monitoringService) {
        this.monitoringService = monitoringService;
    }

    /**
     * Màn hình chính của Bảng Điều Khiển Giám Sát (Dashboard) - Đồng bộ Reload trang cơ bản
     */
    @GetMapping("/monitoring")
    public String showMonitoringDashboard(
            Model model,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "quickSelect", required = false, defaultValue = "CUSTOM") String quickSelect,
            @RequestParam(value = "timeframe", required = false, defaultValue = "MONTH") String timeframe,
            @RequestParam(value = "searchName", required = false) String searchName,   
            @RequestParam(value = "searchEmail", required = false) String searchEmail, 
            @RequestParam(value = "searchPhone", required = false) String searchPhone, 
            
            // Tham số của luồng giao dịch trực tiếp đặt vé
            @RequestParam(value = "txId", required = false) String txId,
            @RequestParam(value = "txName", required = false) String txName,
            @RequestParam(value = "txMethod", required = false) String txMethod,
            @RequestParam(value = "txMinPrice", required = false) String txMinPrice,
            @RequestParam(value = "txMaxPrice", required = false) String txMaxPrice,
            
            @RequestParam(value = "page", required = false, defaultValue = "1") int page,
            @RequestParam(value = "size", required = false, defaultValue = "8") int size) {

        try {
            // --- CÁC THÀNH PHẦN STATS KHÁC (GIỮ NGUYÊN) ---
            model.addAttribute("registrationStats", monitoringService.getNewUserRegistrationStats(startDate, endDate, timeframe));
            model.addAttribute("transactionTrend", monitoringService.getTransactionGrowthTrend(startDate, endDate, timeframe));
            model.addAttribute("newCustomers", monitoringService.getNewUsersList("CUSTOMER", startDate, endDate, searchName, searchEmail, searchPhone));
            model.addAttribute("newStaff", monitoringService.getNewUsersList("STAFF", startDate, endDate, searchName, searchEmail, searchPhone));
            model.addAttribute("recentUpdates", monitoringService.getRecentProfileUpdates(startDate, endDate, searchName, searchEmail, searchPhone));
            model.addAttribute("roleAssignments", monitoringService.getRecentRoleAssignments(startDate, endDate, searchName, searchEmail, searchPhone));
            model.addAttribute("roomHealth", monitoringService.getRoomFacilityHealthMetrics());
            model.addAttribute("zeroTicketAlerts", monitoringService.getZeroOrLowTicketShowtimeAlerts(5));

            // --- YÊU CẦU 1: Lấy danh sách loại thanh toán từ DATABASE truyền ra UI select box ---
            List<String> paymentMethods = monitoringService.getAllPaymentMethods();
            model.addAttribute("paymentMethods", paymentMethods);

            // --- KIỂM TRA VALIDATION KHI LOAD TRANG TRỰC TIẾP ---
            String txValidationError = null;
            Double minPriceVal = null;
            Double maxPriceVal = null;

            if (txMinPrice != null && !txMinPrice.trim().isEmpty()) {
                try {
                    minPriceVal = Double.parseDouble(txMinPrice.trim());
                    if (minPriceVal < 0) txValidationError = "Giá trị 'Tổng tiền từ' không được phép âm!";
                } catch (NumberFormatException e) {
                    txValidationError = "Giá trị 'Tổng tiền từ' phải là số hợp lệ!";
                }
            }
            if (txMaxPrice != null && !txMaxPrice.trim().isEmpty() && txValidationError == null) {
                try {
                    maxPriceVal = Double.parseDouble(txMaxPrice.trim());
                    if (maxPriceVal < 0) txValidationError = "Giá trị 'Đến giá' không được phép âm!";
                } catch (NumberFormatException e) {
                    txValidationError = "Giá trị 'Đến giá' phải là số hợp lệ!";
                }
            }
            if (minPriceVal != null && maxPriceVal != null && minPriceVal > maxPriceVal && txValidationError == null) {
                txValidationError = "'Tổng tiền từ' không được lớn hơn mức giá tối đa 'Đến giá'!";
            }
            if (txName != null && !txName.trim().isEmpty() && txValidationError == null) {
                if (!NAME_PATTERN.matcher(txName.trim()).matches()) {
                    txValidationError = "Tên khách hàng không hợp lệ! Vui lòng không nhập chữ số hoặc ký tự đặc biệt.";
                }
            }

            // Chuẩn hóa loại bỏ chuỗi ALL trước khi query DB
            String cleanMethod = (txMethod == null || "ALL".equalsIgnoreCase(txMethod.trim())) ? null : txMethod.trim();

            List<Map<String, Object>> liveTransactions;
            int totalRecords = 0;

            if (txValidationError != null) {
                liveTransactions = new java.util.ArrayList<>();
                model.addAttribute("txValidationError", txValidationError); 
            } else {
                liveTransactions = monitoringService.getLiveTransactionStream(page, size, startDate, endDate, txName, txMinPrice, txMaxPrice, cleanMethod, txId);
                totalRecords = monitoringService.getTotalTransactionCount(startDate, endDate, txName, txMinPrice, txMaxPrice, cleanMethod, txId);
            }
            
            model.addAttribute("liveTransactions", liveTransactions);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", (int) Math.ceil((double) totalRecords / size));
            model.addAttribute("totalRecords", totalRecords);
            
            // Trả ngược giữ trạng thái UI
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
            model.addAttribute("currentQuickSelect", quickSelect);
            model.addAttribute("currentTimeframe", timeframe);
            model.addAttribute("searchName", searchName);
            model.addAttribute("searchEmail", searchEmail);
            model.addAttribute("searchPhone", searchPhone);
            model.addAttribute("txId", txId);
            model.addAttribute("txName", txName);
            model.addAttribute("txMethod", txMethod);
            model.addAttribute("txMinPrice", txMinPrice);
            model.addAttribute("txMaxPrice", txMaxPrice);
            
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Lỗi tải dữ liệu giám sát: " + e.getMessage());
        }

        model.addAttribute("view", "monitoring");
        model.addAttribute("body", path + "monitoring.jsp");
        return pathview;
    }

    /**
     * API hỗ trợ AJAX cập nhật thời gian thực luồng giao dịch (BẮT NGOẠI LỆ NGHIÊM NGẶT TRẢ VỀ KHUNG ĐỎ AJAX)
     */
    @GetMapping("/monitoring/api/transactions")
    @ResponseBody
    public Map<String, Object> getLiveTransactionsApi(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "8") int size,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String txName,
            @RequestParam(required = false) String txMinPrice,
            @RequestParam(required = false) String txMaxPrice,
            @RequestParam(required = false) String txMethod,
            @RequestParam(required = false) String txId) {

        Map<String, Object> response = new HashMap<>();
        Double minPriceVal = null;
        Double maxPriceVal = null;
        
        // --- YÊU CẦU 2: Bắt lỗi ngoại lệ nghiêm ngặt và gán vào key "error" để đẩy ra khung đỏ phía giao diện ---
        if (txMinPrice != null && !txMinPrice.trim().isEmpty()) {
            try { 
                minPriceVal = Double.parseDouble(txMinPrice.trim());
                if (minPriceVal < 0) { 
                    response.put("error", "Giá trị 'Tổng tiền từ' không được phép âm!"); 
                    return response; 
                } 
            } catch(NumberFormatException e){
                response.put("error", "Giá trị 'Tổng tiền từ' phải nhập định dạng số hợp lệ!"); 
                return response;
            }
        }
        
        if (txMaxPrice != null && !txMaxPrice.trim().isEmpty()) {
            try { 
                maxPriceVal = Double.parseDouble(txMaxPrice.trim());
                if (maxPriceVal < 0) { 
                    response.put("error", "Giá trị 'Đến giá' không được phép âm!"); 
                    return response; 
                } 
            } catch(NumberFormatException e){
                response.put("error", "Giá trị 'Đến giá' phải nhập định dạng số hợp lệ!"); 
                return response;
            }
        }

        if (minPriceVal != null && maxPriceVal != null && minPriceVal > maxPriceVal) {
            response.put("error", "'Tổng tiền từ' không được phép lớn hơn giá trị tối đa 'Đến giá'!");
            return response;
        }

        // Bắt lỗi không cho phép nhập ký tự đặc biệt hoặc số vào ô Tên
        if (txName != null && !txName.trim().isEmpty()) {
            if (!NAME_PATTERN.matcher(txName.trim()).matches()) { 
                response.put("error", "Tên khách hàng không hợp lệ! Vui lòng không nhập chữ số hoặc ký tự đặc biệt."); 
                return response; 
            }
        }

        // Loại bỏ chuỗi "ALL" trước khi gửi xuống database query
        String cleanMethod = (txMethod == null || "ALL".equalsIgnoreCase(txMethod.trim())) ? null : txMethod.trim();

        List<Map<String, Object>> transactions = monitoringService.getLiveTransactionStream(page, size, startDate, endDate, txName, txMinPrice, txMaxPrice, cleanMethod, txId);
        int totalRecords = monitoringService.getTotalTransactionCount(startDate, endDate, txName, txMinPrice, txMaxPrice, cleanMethod, txId);
        int totalPages = (int) Math.ceil((double) totalRecords / size);

        response.put("data", transactions);
        response.put("currentPage", page);
        response.put("totalPages", totalPages);
        response.put("totalRecords", totalRecords);

        return response;
    }
}