package uef.edu.vn.service.impl;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import uef.edu.vn.repository.MonitoringRepository;
import uef.edu.vn.service.MonitoringService;

@Service
public class MonitoringServiceImpl implements MonitoringService {

    @Autowired
    private MonitoringRepository monitoringRepository;

    @Override
    public List<Map<String, Object>> getNewUserRegistrationStats(String startDate, String endDate, String timeframe) {
        return monitoringRepository.getNewUserRegistrationStats(startDate, endDate, timeframe);
    }

    @Override
    public List<Map<String, Object>> getTransactionGrowthTrend(String startDate, String endDate, String timeframe) {
        return monitoringRepository.getTransactionGrowthTrend(startDate, endDate, timeframe);
    }

    @Override
    public List<Map<String, Object>> getNewUsersList(String type, String startDate, String endDate, 
                                                     String searchName, String searchEmail, String searchPhone) {
        // Gọi trực tiếp repository với 6 tham số mới
        return monitoringRepository.getNewUsersList(type, startDate, endDate, searchName, searchEmail, searchPhone);
    }

    @Override
    public List<Map<String, Object>> getRecentProfileUpdates(String startDate, String endDate, 
                                                             String searchName, String searchEmail, String searchPhone) {
        // Gọi trực tiếp repository với 6 tham số mới
        return monitoringRepository.getRecentProfileUpdates(startDate, endDate, searchName, searchEmail, searchPhone);
    }

    @Override
    public List<Map<String, Object>> getRecentRoleAssignments(String startDate, String endDate, 
                                                              String searchName, String searchEmail, String searchPhone) {
        // Gọi trực tiếp repository với 6 tham số mới
        return monitoringRepository.getRecentRoleAssignments(startDate, endDate, searchName, searchEmail, searchPhone);
    }

    @Override
    public List<Map<String, Object>> getRoomFacilityHealthMetrics() {
        return monitoringRepository.getRoomFacilityHealthMetrics();
    }

    @Override
    public List<Map<String, Object>> getZeroOrLowTicketShowtimeAlerts(int thresholdTickets) {
        return monitoringRepository.getZeroOrLowTicketShowtimeAlerts(thresholdTickets);
    }

   @Override
    public List<String> getAllPaymentMethods() {
        // Chuyển tiếp lời gọi xuống tầng Repository để truy vấn database
        return monitoringRepository.getAllPaymentMethods();
    }

    @Override
    public List<Map<String, Object>> getLiveTransactionStream(int page, int size, String startDate, String endDate,
                                                              String txName, String txMinPrice, String txMaxPrice, 
                                                              String txMethod, String txId) {
        return monitoringRepository.getLiveTransactionStream(page, size, startDate, endDate, txName, txMinPrice, txMaxPrice, txMethod, txId);
    }

    @Override
    public int getTotalTransactionCount(String startDate, String endDate, String txName, 
                                         String txMinPrice, String txMaxPrice, String txMethod, String txId) {
        return monitoringRepository.getTotalTransactionCount(startDate, endDate, txName, txMinPrice, txMaxPrice, txMethod, txId);
    }
}